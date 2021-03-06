--ODX วินิจฉัยโรคผู้ป่วยนอก v.1.0
select distinct --b_site.b_visit_office_id as HCODE,       
         t_patient.patient_hn as "HN",
         (substr(t_visit.visit_begin_visit_time,1,4)::int -543
          ||substr(t_visit.visit_begin_visit_time,6,2) 
          ||substr(t_visit.visit_begin_visit_time,9,2)) as "DATEDX",
          (case when (b_report_12files_map_clinic.b_report_12files_std_clinic_id IN ('01','02','03','04','05','06','07','08','09','10','11'))
                then (t_visit.f_visit_type_id || b_report_12files_map_clinic.b_report_12files_std_clinic_id || '00') 
                when (b_report_12files_map_clinic.b_report_12files_std_clinic_id is null) then ''
                else  (t_visit.f_visit_type_id || '121') end) AS "CLINIC",
         (CASE WHEN (t_diag_icd10.diag_icd10_number is not null)
                then replace(t_diag_icd10.diag_icd10_number,'.','')
                else '' end) AS "DIAG",
         (CASE WHEN (t_diag_icd10.f_diag_icd10_type_id is not null)
                then t_diag_icd10.f_diag_icd10_type_id
                else '' end) AS "DXTYPE",
         b_employee.employee_number AS "DRDX",
         (case when (t_health_family.patient_pid <> '' and length(t_health_family.patient_pid) =13)
                    then t_health_family.patient_pid
               when (t_health_family.patient_pid = '' and t_health_family.passport_no = '' 
                        and t_health_family.r_rp1853_foreign_id in ('02','03','04','11','12','13','14','21','22','23'))
                     then 
                        lpad(t_patient.patient_hn,13,'0')                                      
               when (t_health_family.health_family_foreigner_card_no <> '' and length(t_health_family.health_family_foreigner_card_no) =13)
                     then  t_health_family.health_family_foreigner_card_no
               else '' end) as "PERSON_ID",
          t_visit.visit_vn as "SEQ"
from t_patient
     left join t_health_family on t_patient.t_health_family_id =t_health_family.t_health_family_id
     left join f_patient_prefix on t_health_family.f_prefix_id = f_patient_prefix.f_patient_prefix_id
     left join f_patient_marriage_status  on t_health_family.f_patient_marriage_status_id = f_patient_marriage_status.f_patient_marriage_status_id
     left join t_patient_payment on t_patient.t_patient_id=t_patient_payment.t_patient_id
     left join t_visit on t_patient.t_patient_id=t_visit.t_patient_id
     left join t_diag_icd10 on (t_visit.t_visit_id = t_diag_icd10.diag_icd10_vn  AND t_diag_icd10.diag_icd10_active = '1')
     left join b_employee on t_diag_icd10.diag_icd10_staff_doctor=b_employee.b_employee_id
     left join b_report_12files_map_clinic  on t_diag_icd10.b_visit_clinic_id = b_report_12files_map_clinic.b_visit_clinic_id
     left join t_billing on t_visit.t_visit_id=t_billing.t_visit_id
     left join t_visit_payment on t_visit.t_visit_id=t_visit_payment.t_visit_id
     left join t_order on t_visit.t_visit_id=t_order.t_visit_id
     left join b_item on t_order.b_item_id=b_item.b_item_id
     left join b_contract_plans on t_visit_payment.b_contract_plans_id=b_contract_plans.b_contract_plans_id 
     left join f_patient_occupation on t_health_family.f_patient_occupation_id = f_patient_occupation.f_patient_occupation_id
     left join b_map_rp1855_occupation on f_patient_occupation.f_patient_occupation_id = b_map_rp1855_occupation.f_patient_occupation_id
     left join r_rp1855_occupation on b_map_rp1855_occupation.r_rp1855_occupation_id = r_rp1855_occupation.id
     left join f_patient_nation as race_1 on t_health_family.f_patient_race_id = race_1.f_patient_nation_id
     left join b_map_rp1855_nation as race on race_1.f_patient_nation_id = race.f_patient_nation_id
     left join f_patient_nation as nation_1 on t_health_family.f_patient_nation_id = nation_1.f_patient_nation_id
     left join b_map_rp1855_nation as nation on race_1.f_patient_nation_id = nation.f_patient_nation_id
     left join (select t_visit_primary_symptom.t_visit_id as t_visit_id
                      ,array_to_string(array_agg(t_visit_primary_symptom.visit_primary_symptom_main_symptom),' , ') as main_symptom
                from  t_visit_primary_symptom
                where t_visit_primary_symptom.visit_primary_symptom_active = '1'
                group by t_visit_primary_symptom.t_visit_id) as symptom   on t_visit.t_visit_id = symptom.t_visit_id
     cross join b_site
where  t_visit.f_visit_status_id ='3'--1=เข้าสู่กระบวนการ, 2=ค้างบันทึก, 3=จบกระบวนการ, 4=ยกเลิกการเข้ารับบริการ	
      and ((t_order.f_order_status_id <> '0') and (t_order.f_order_status_id <> '3')) 
      and t_visit_payment.visit_payment_active='1'
      and t_health_family.health_family_active = '1'    
	  and substring(t_visit.visit_begin_visit_time,1,10) between {0} and {1}