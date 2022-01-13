--INS ผู้มีสิทธิการรักษาพยาบาล
select t_visit.visit_hn as "HN",
       r_rp1853_instype.maininscl AS "INSCL",  
       b_contract_plans.r_rp1853_instype_id AS "SUBTYPE"
       ,(case when (t_health_family.patient_pid <> '' and length(t_health_family.patient_pid) =13)
                    then t_health_family.patient_pid
               when (t_health_family.patient_pid = '' 
                        and t_health_family.passport_no = '' 
                        and t_health_family.r_rp1853_foreign_id in ('02','03','04','11','12','13','14','21','22','23'))
                     then 
                        lpad(t_patient.patient_hn,13,'0')                                      
               when (t_health_family.health_family_foreigner_card_no <> '' and length(t_health_family.health_family_foreigner_card_no) =13)
                     then  t_health_family.health_family_foreigner_card_no
               else '' end) as "CID"
        ,b_site.b_visit_office_id as "HCODE"
       ,(CASE  WHEN (t_patient_payment.patient_payment_card_issue_date  <> '' and t_patient_payment.patient_payment_card_issue_date  <> 'null')       
        		  then (to_number(substring(t_patient_payment.patient_payment_card_issue_date,1,4),'9999')-543)
                        || substring(t_patient_payment.patient_payment_card_issue_date,6,2)       
 				        || substring(t_patient_payment.patient_payment_card_issue_date,9,2) 
                  else '' end)  AS "DATEIN", 
       (CASE  WHEN (t_patient_payment.patient_payment_card_expire_date  <> '' and t_patient_payment.patient_payment_card_expire_date  <> 'null')       
        		  then (to_number(substring(t_patient_payment.patient_payment_card_expire_date,1,4),'9999')-543)
                        || substring(t_patient_payment.patient_payment_card_expire_date,6,2)       
 				        || substring(t_patient_payment.patient_payment_card_expire_date,9,2) 
                  else '' end)  AS "DATEEXP",
       t_visit_payment.visit_payment_main_hospital as "HOSPMAIN",
       t_visit_payment.visit_payment_sub_hospital as "HOSPSUB",
       '' as "GOVCODE",
       '' as "GOVNAME",
       t_opbkk_claim.claim_code as "PERMITNO"
       ,'' as "DOCNO"
       ,(case when (r_rp1853_instype.maininscl IN ('OFC','LGO')) then t_health_family.patient_pid else '' end) as "OWNRPID"
       ,(case when (r_rp1853_instype.maininscl IN ('OFC','LGO'))  then (f_patient_prefix.patient_prefix_description || t_patient.patient_firstname || ' ' ||  t_patient.patient_lastname ) end) as "OWNNAME"
		,'' as "AN"
		,t_visit.visit_vn  as "SEQ"
		,'' as "SUBINSCL"
		,'' as "RELINSCL"
		,'' as "HTYPE"
       from t_patient
     inner join f_patient_prefix on f_patient_prefix.f_patient_prefix_id = t_patient.f_patient_prefix_id
     left join t_health_family on t_patient.t_health_family_id =t_health_family.t_health_family_id
     left join t_patient_payment on t_patient.t_patient_id=t_patient_payment.t_patient_id
     left join t_visit on t_patient.t_patient_id=t_visit.t_patient_id
     left join t_billing on t_visit.t_visit_id=t_billing.t_visit_id
     left join t_visit_payment on t_visit.t_visit_id=t_visit_payment.t_visit_id
     left join t_order on t_visit.t_visit_id=t_order.t_visit_id
     left join b_item on t_order.b_item_id=b_item.b_item_id
     left join b_contract_plans on t_visit_payment.b_contract_plans_id=b_contract_plans.b_contract_plans_id
     left join r_rp1853_instype ON (b_contract_plans.r_rp1853_instype_id = r_rp1853_instype.id)
     left join ( select *
					from (select t_visit_id ,claim_code ,ROW_NUMBER() OVER( PARTITION BY t_visit_id ORDER by t_visit_id desc) as chk_dup
					       from t_opbkk_claim where t_opbkk_claim.active = true ) q 
					where q.chk_dup = 1 ) t_opbkk_claim on t_visit.t_visit_id = t_opbkk_claim.t_visit_id -- dup claim code
     ,b_site
where t_visit.f_visit_status_id ='3'--1=เข้าสู่กระบวนการ, 2=ค้างบันทึก, 3=จบกระบวนการ, 4=ยกเลิกการเข้ารับบริการ	
      and ((t_order.f_order_status_id <> '0') and (t_order.f_order_status_id <> '3')) 
      and t_visit_payment.visit_payment_active='1'
--      and t_visit.visit_vn='050000013'      
      and substring(t_visit.visit_begin_visit_time,1,10) between '2564-10-01' and '2564-10-05'
GROUP BY t_visit.visit_hn
,r_rp1853_instype.maininscl
,b_contract_plans.r_rp1853_instype_id
,t_patient_payment.patient_payment_card_issue_date
,t_patient_payment.patient_payment_card_expire_date
,t_health_family.patient_pid,t_health_family.passport_no
,t_visit_payment.visit_payment_main_hospital
,t_visit_payment.visit_payment_sub_hospital
,t_health_family.r_rp1853_foreign_id
,t_patient.patient_hn
,t_health_family.health_family_foreigner_card_no
,f_patient_prefix.patient_prefix_description
, t_patient.patient_firstname
,t_patient.patient_lastname
 ,"HCODE","PERMITNO","SEQ"