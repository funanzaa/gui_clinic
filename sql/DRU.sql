--DRU การใช้ยา
select  b_site.b_visit_office_id as "HCODE",
         t_patient.patient_hn as "HN",   
         '' as "AN",
         (case when  (b_report_12files_map_clinic.b_report_12files_std_clinic_id in ('1300','1301','1302','1303','1304','1305'))
                        then (t_visit.f_visit_type_id || b_report_12files_map_clinic.b_report_12files_std_clinic_id )
               when  b_report_12files_map_clinic.b_report_12files_std_clinic_id not in ('1300','1301','1302','1303','1304','1305')
                        then (t_visit.f_visit_type_id || b_report_12files_map_clinic.b_report_12files_std_clinic_id || '00' )
               else '00000' end) AS "CLINIC"
         , (case when (t_health_family.patient_pid <> '' and length(t_health_family.patient_pid) =13)
                    then t_health_family.patient_pid
               when (t_health_family.patient_pid = '' and t_health_family.passport_no = '' 
                        and t_health_family.r_rp1853_foreign_id in ('02','03','04','11','12','13','14','21','22','23'))
                     then 
                        lpad(t_patient.patient_hn,13,'0')                                      
               when (t_health_family.health_family_foreigner_card_no <> '' and length(t_health_family.health_family_foreigner_card_no) =13)
                     then  t_health_family.health_family_foreigner_card_no
               else '' end) as "PERSON_ID"
     ,  (substr(t_visit.visit_begin_visit_time,1,4)::int -543
          ||substr(t_visit.visit_begin_visit_time,6,2) 
          ||substr(t_visit.visit_begin_visit_time,9,2)) as "DATE_SERV"
          ,trim(b_item.item_number) AS "DID"
          --,substr(n3.b_drug_tmt_tpucode,1,6) AS "DID"  
          ,b_item.item_common_name AS "DIDNAME"
           ,sum(cast(t_order.order_qty as decimal(8,2))) AS "AMOUNT"   
           ,sum(t_billing_invoice_item.billing_invoice_item_payer_share) AS "DRUGPRICE"
          ,(case when (t_order.order_cost IS NULL) 
                     then '0.00'  else cast(t_order.order_cost as decimal(8,2)) end) AS "DRUGCOST"        
         --, substr(n2.f_nhso_drug_id,1,24) as "DIDSTD"
          ,drugcode24.drugcode24  as "DIDSTD"  
          ,(b_item_drug_uom.item_drug_uom_description) as "UNIT"
           ,'' as "UNIT_PACK"
           , t_visit.visit_vn as "SEQ"
           , '' as "DRUGREMARK"
           , '' as "PA_NO"
			,'' as "TOTCOPAY"
			,'2' as "USE_STATUS"
			, '' as "TOTAL"
			,'' as "SIGCODE"
			, '' as "SIGTEXT"         
           -- ,substr(n3.b_drug_tmt_tpucode,1,6) AS "TMTCODE"             
     --   ,sum(t_billing_invoice_item.billing_invoice_item_patient_share) AS PRICE_EXT
 , max(case when t_order.order_dispense_date_time <> '' and t_order.order_dispense_date_time >= t_order_drug.order_drug_modify_datetime
                              then staff_dispense.provider
                      when t_order.order_dispense_date_time <> '' and t_order.order_dispense_date_time < t_order_drug.order_drug_modify_datetime
                              then staff_modifier.provider
                       when t_order.order_dispense_date_time = '' and t_order.order_executed_date_time <> '' 
                                    and t_order.order_executed_date_time >= t_order.order_verify_date_time
                              then staff_execute.provider
                       when t_order.order_dispense_date_time = '' and t_order.order_executed_date_time <> '' 
                                    and t_order.order_executed_date_time < t_order_drug.order_drug_modify_datetime
                              then staff_modifier.provider
                       when t_order.order_dispense_date_time = '' and t_order.order_executed_date_time = '' 
                                    and t_order.order_verify_date_time >= t_order_drug.order_drug_modify_datetime
                              then staff_verify.provider 
                       when t_order.order_dispense_date_time = '' and t_order.order_executed_date_time = '' 
                                    and t_order.order_verify_date_time < t_order_drug.order_drug_modify_datetime
                              then staff_modifier.provider  end ) as "PROVIDER"  
FROM  t_billing_invoice_item  
	INNER JOIN t_visit ON (t_billing_invoice_item.t_visit_id = t_visit.t_visit_id)  
	INNER JOIN t_patient ON (t_patient.t_patient_id = t_visit.t_patient_id)  
    inner join t_health_family on (t_health_family.t_health_family_id=t_patient.t_health_family_id)
	inner JOIN t_order ON (t_order.t_order_id = t_billing_invoice_item.t_order_item_id  and t_billing_invoice_item.billing_invoice_item_active='1' )
    left join (select substr(f_nhso_drug_id,1,24) as f_nhso_drug_id,b_item_id from b_nhso_map_drug group by substr(f_nhso_drug_id,1,24),b_item_id) n2 on t_order.b_item_id = n2.b_item_id
    left join (select substr(b_drug_tmt_tpucode,1,6) as b_drug_tmt_tpucode,b_item_id from b_map_drug_tmt group by substr(b_drug_tmt_tpucode,1,6),b_item_id) n3 on t_order.b_item_id = n3.b_item_id
 inner join t_order_drug on (t_order.t_order_id=t_order_drug.t_order_id and t_order_drug.order_drug_active='1')
 left join b_item_drug_uom on t_order_drug.b_item_drug_uom_id_purch=b_item_drug_uom.b_item_drug_uom_id
 inner join b_item ON b_item.b_item_id = t_order.b_item_id
 inner join (select t_diag_icd10.diag_icd10_vn,t_diag_icd10.b_visit_clinic_id,t_diag_icd10.diag_icd10_active,t_diag_icd10.f_diag_icd10_type_id from t_diag_icd10 group by t_diag_icd10.f_diag_icd10_type_id,t_diag_icd10.diag_icd10_active,t_diag_icd10.b_visit_clinic_id,t_diag_icd10.diag_icd10_vn ) t_diag_icd10 on t_visit.t_visit_id = t_diag_icd10.diag_icd10_vn and t_diag_icd10.diag_icd10_active = '1' and t_diag_icd10.f_diag_icd10_type_id='1'
  left join b_report_12files_map_clinic  ON t_diag_icd10.b_visit_clinic_id = b_report_12files_map_clinic.b_visit_clinic_id
 left join b_employee as staff_dispense on t_order.order_staff_dispense = staff_dispense.b_employee_id
        left join b_employee as staff_modifier on t_order_drug.order_drug_modifier = staff_modifier.b_employee_id
        left join b_employee as staff_execute on t_order.order_staff_execute = staff_execute.b_employee_id
        left join b_employee as staff_verify on t_order.order_staff_verify  = staff_verify.b_employee_id
 left join ( -- drugcode24
	 select b_nhso_map_drug.b_item_id,b_nhso_drugcode24.drugcode24 
	from b_nhso_map_drug
	inner join b_nhso_drugcode24 on b_nhso_map_drug.b_nhso_drugcode24_id = b_nhso_drugcode24.b_nhso_drugcode24_id ) drugcode24 on b_item.b_item_id = drugcode24.b_item_id
,b_site
where  t_visit.f_visit_status_id ='3'--1=เข้าสู่กระบวนการ, 2=ค้างบันทึก, 3=จบกระบวนการ, 4=ยกเลิกการเข้ารับบริการ	
      and ((t_order.f_order_status_id <> '0') and (t_order.f_order_status_id <> '3')) 
      and t_health_family.health_family_active = '1'
      and substring(t_visit.visit_begin_visit_time,1,10) between {0} and {1}
group by
b_site.b_visit_office_id
,t_patient.patient_hn
,b_report_12files_map_clinic.b_report_12files_std_clinic_id
,t_visit.f_visit_type_id
,t_health_family.patient_pid
,t_health_family.passport_no
,t_health_family.r_rp1853_foreign_id
,t_health_family.health_family_foreigner_card_no
,t_visit.visit_begin_visit_time
,b_item.item_number
,b_item.item_common_name
,n2.f_nhso_drug_id
,n3.b_drug_tmt_tpucode
,t_order.order_cost
,b_item_drug_uom.item_drug_uom_description
,t_visit.visit_vn,"DIDSTD"
order by "HN"