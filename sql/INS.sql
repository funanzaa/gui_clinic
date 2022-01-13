select t_visit.visit_hn as HN,
       r_rp1853_instype.maininscl AS INSCL,  
       b_contract_plans.r_rp1853_instype_id AS SUBTYPE,
       (case when (t_person.person_pid <> '' and length(t_person.person_pid) =13)
                    then t_person.person_pid
               when (t_person.person_pid = '' and t_person_foreigner.passport_no = '' 
                        and t_person_foreigner.f_person_foreigner_id in ('02','03','04','11','12','13','14','21','22','23'))
                     then 
                        lpad(t_patient.patient_hn,13,'0')                                      
               when (t_person_foreigner.foreigner_no <> '' and length(t_person_foreigner.foreigner_no) =13)
                     then  t_person_foreigner.foreigner_no
               else '' end) as CID,
       (CASE  WHEN (t_patient_payment.patient_payment_card_issue_date is not null)       
        		  then to_char(t_patient_payment.patient_payment_card_issue_date,'YYYYMMDD')
                  else '' end)  AS DATEIN, 
       (CASE  WHEN (t_patient_payment.patient_payment_card_expire_date is not null)       
        		  then to_char(t_patient_payment.patient_payment_card_expire_date,'YYYYMMDD')
                  else '' end)  AS DATEEXP,
       t_visit_payment.visit_payment_main_hospital as HOSPMAIN,
       t_visit_payment.visit_payment_sub_hospital as HOSPSUB,
       '' as GOVCODE,
       '' as GOVNAME,
       '' as PERMITNO,
       '' as DOCNO
       ,(case when (r_rp1853_instype.maininscl IN ('OFC','LGO')) then t_person.person_pid else '' end) as OWNRPID
       ,(case when (r_rp1853_instype.maininscl IN ('OFC','LGO'))  then (f_patient_prefix.patient_prefix_description || t_person.person_firstname || ' ' ||  t_person.person_lastname ) end) as OWNNAME
from t_patient
     inner join t_person on (t_person.t_person_id=t_patient.t_person_id)
     inner join f_patient_prefix on f_patient_prefix.f_patient_prefix_id = t_person.f_prefix_id
     left join t_person_foreigner ON t_person.t_person_id = t_person_foreigner.t_person_id
     left join t_patient_payment on t_patient.t_patient_id=t_patient_payment.t_patient_id
     left join t_visit on t_patient.t_patient_id=t_visit.t_patient_id
     left join t_billing on t_visit.t_visit_id=t_billing.t_visit_id
     left join t_visit_payment on t_visit.t_visit_id=t_visit_payment.t_visit_id
     left join t_order on t_visit.t_visit_id=t_order.t_visit_id
     left join b_item on t_order.b_item_id=b_item.b_item_id
     left join b_contract_plans on t_visit_payment.b_contract_plans_id=b_contract_plans.b_contract_plans_id
     left join r_rp1853_instype ON (b_contract_plans.r_rp1853_instype_id = r_rp1853_instype.id)
where t_visit.f_visit_status_id ='3'--1=เข้าสู่กระบวนการ, 2=ค้างบันทึก, 3=จบกระบวนการ, 4=ยกเลิกการเข้ารับบริการ	
      and ((t_order.f_order_status_id <> '0') and (t_order.f_order_status_id <> '3')) 
      and t_visit_payment.visit_payment_active='1'
      --and t_visit.visit_vn='050000013'      
      --and substring(t_visit.visit_begin_visit_time,1,10) between '2014010100' and '2014011000'
      --AND t_visit.visit_begin_visit_time::date between '2020-01-01'::date and '2020-01-10'::date
      --{0} {1}
GROUP BY t_visit.visit_hn,r_rp1853_instype.maininscl,b_contract_plans.r_rp1853_instype_id,t_patient_payment.patient_payment_card_issue_date,
         t_patient_payment.patient_payment_card_expire_date,t_person.person_pid,t_person_foreigner.passport_no,
         t_visit_payment.visit_payment_main_hospital,t_visit_payment.visit_payment_sub_hospital,t_person_foreigner.f_person_foreigner_id,
         t_patient.patient_hn,t_person_foreigner.foreigner_no,f_patient_prefix.patient_prefix_description,
         t_person.person_firstname,t_person.person_lastname