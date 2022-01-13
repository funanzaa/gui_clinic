select  b_site.b_visit_office_id as HCODE,
         t_patient.patient_hn as HN,   
         (case when  (b_report_12files_map_clinic.b_report_12files_std_clinic_id in ('1300','1301','1302','1303','1304','1305'))
                        then (t_visit.f_visit_type_id || b_report_12files_map_clinic.b_report_12files_std_clinic_id )
               when  b_report_12files_map_clinic.b_report_12files_std_clinic_id not in ('1300','1301','1302','1303','1304','1305')
                        then (t_visit.f_visit_type_id || b_report_12files_map_clinic.b_report_12files_std_clinic_id || '00' )
               else '00000' end) AS CLINIC
         ,(case when (t_person.person_pid <> '' and length(t_person.person_pid) =13)
                    then t_person.person_pid
               when (t_person.person_pid = '' and t_person_foreigner.passport_no = '' 
                        and t_person_foreigner.f_person_foreigner_id in ('02','03','04','11','12','13','14','21','22','23'))
                     then 
                        lpad(t_patient.patient_hn,13,'0')                                      
               when (t_person_foreigner.foreigner_no <> '' and length(t_person_foreigner.foreigner_no) =13)
                     then  t_person_foreigner.foreigner_no
               else '' end) as PERSON_ID
     ,  to_char(t_visit.visit_begin_visit_time,'YYYYMMDD') as DATESERV
            ,trim(b_item.item_number) AS DID
            ,b_item.item_common_name AS DIDNAME
            , substr(n2.f_nhso_drug_id,1,24) as DIDSTD
            ,substr(n3.b_drug_tmt_tpucode,1,7) AS TMTCODE
          ,sum(cast(t_order.order_qty as decimal(8,2))) AS AMOUNT 
        ,sum(t_billing_invoice_item.billing_invoice_item_payer_share) AS DRUGPRICE
        ,sum(t_billing_invoice_item.billing_invoice_item_patient_share) AS PRICE_EXT
          ,(case when (t_order.order_cost IS NULL) 
                     then '0.00'  else cast(t_order.order_cost as decimal(8,2)) end) AS DRUGCOST 
            ,(b_item_drug_uom.item_drug_uom_description) as UNIT
            ,'' as UNIT_PACKING
            , t_visit.visit_vn as SEQ
 , max(case when t_order.order_dispense_date_time is not null and t_order.order_dispense_date_time >= t_order_drug.order_drug_modify_datetime
                              then staff_dispense.provider
                      when t_order.order_dispense_date_time is not null and t_order.order_dispense_date_time < t_order_drug.order_drug_modify_datetime
                              then staff_modifier.provider
                       when t_order.order_dispense_date_time is null and t_order.order_executed_date_time is not null
                                    and t_order.order_executed_date_time >= t_order.order_verify_date_time
                              then staff_execute.provider
                       when t_order.order_dispense_date_time is null and t_order.order_executed_date_time is not null 
                                    and t_order.order_executed_date_time < t_order_drug.order_drug_modify_datetime
                              then staff_modifier.provider
                       when t_order.order_dispense_date_time is null and t_order.order_executed_date_time is null
                                    and t_order.order_verify_date_time >= t_order_drug.order_drug_modify_datetime
                              then staff_verify.provider 
                       when t_order.order_dispense_date_time is null and t_order.order_executed_date_time is null
                                    and t_order.order_verify_date_time < t_order_drug.order_drug_modify_datetime
                              then staff_modifier.provider  end ) as PROVIDER    
FROM  t_billing_invoice_item  
	INNER JOIN t_visit ON (t_billing_invoice_item.t_visit_id = t_visit.t_visit_id)  
	INNER JOIN t_patient ON (t_patient.t_patient_id = t_visit.t_patient_id)  
    inner join t_person on (t_person.t_person_id=t_patient.t_person_id)
    left join t_person_foreigner ON t_person.t_person_id = t_person_foreigner.t_person_id
	inner JOIN t_order ON (t_order.t_order_id = t_billing_invoice_item.t_order_item_id  and t_billing_invoice_item.billing_invoice_item_active='1' )
    left join (select substr(f_nhso_drug_id,1,24) as f_nhso_drug_id,b_item_id from b_nhso_map_drug group by substr(f_nhso_drug_id,1,24),b_item_id) n2 on t_order.b_item_id = n2.b_item_id
    left join (select substr(b_drug_tmt_tpucode,1,7) as b_drug_tmt_tpucode,b_item_id from b_map_drug_tmt group by substr(b_drug_tmt_tpucode,1,7),b_item_id) n3 on t_order.b_item_id = n3.b_item_id
 inner join t_order_drug on (t_order.t_order_id=t_order_drug.t_order_id and t_order_drug.order_drug_active='1')
 left join b_item_drug_uom on t_order_drug.b_item_drug_uom_id_purch=b_item_drug_uom.b_item_drug_uom_id
 inner join b_item ON b_item.b_item_id = t_order.b_item_id
 inner join (select t_diag_icd10.diag_icd10_vn,t_diag_icd10.b_visit_clinic_id,t_diag_icd10.diag_icd10_active,t_diag_icd10.f_diag_icd10_type_id from t_diag_icd10 group by t_diag_icd10.f_diag_icd10_type_id,t_diag_icd10.diag_icd10_active,t_diag_icd10.b_visit_clinic_id,t_diag_icd10.diag_icd10_vn ) t_diag_icd10 on t_visit.t_visit_id = t_diag_icd10.diag_icd10_vn and t_diag_icd10.diag_icd10_active = '1' and t_diag_icd10.f_diag_icd10_type_id='1'
  left join b_report_12files_map_clinic  ON t_diag_icd10.b_visit_clinic_id = b_report_12files_map_clinic.b_visit_clinic_id
 left join b_employee as staff_dispense on t_order.order_staff_dispense = staff_dispense.b_employee_id
        left join b_employee as staff_modifier on t_order_drug.order_drug_modifier = staff_modifier.b_employee_id
        left join b_employee as staff_execute on t_order.order_staff_execute = staff_execute.b_employee_id
        left join b_employee as staff_verify on t_order.order_staff_verify  = staff_verify.b_employee_id
,b_site
where  t_visit.f_visit_status_id ='3'--1=เข้าสู่กระบวนการ, 2=ค้างบันทึก, 3=จบกระบวนการ, 4=ยกเลิกการเข้ารับบริการ	
      and ((t_order.f_order_status_id <> '0') and (t_order.f_order_status_id <> '3')) 
      and t_person.active = '1'
     -- and t_visit.visit_vn='057004836'
      --and substring(t_visit.visit_begin_visit_time,1,10) between '2556-12-16' and '2556-12-17'
      --AND t_visit.visit_begin_visit_time::date between '2020-01-01'::date and '2020-01-10'::date
      --{0} {1}
group by
b_site.b_visit_office_id
,t_patient.patient_hn
,b_report_12files_map_clinic.b_report_12files_std_clinic_id
,t_visit.f_visit_type_id
,t_person.person_pid
,t_person_foreigner.passport_no
,t_person_foreigner.f_person_foreigner_id
,t_person_foreigner.foreigner_no
,t_visit.visit_begin_visit_time
,b_item.item_number
,b_item.item_common_name
,n2.f_nhso_drug_id
,n3.b_drug_tmt_tpucode
,t_order.order_cost
,b_item_drug_uom.item_drug_uom_description
,t_visit.visit_vn
order by HN
---dru_ 15/12/57
---drug 19/04/62 by aoy แก้ไข จำหนวนหลัก TMTCODE จาก 1,6 เป็น 1,7