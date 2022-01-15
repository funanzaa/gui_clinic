-- PAT v1.0
select distinct b_site.b_visit_office_id as "HCODE",
       t_patient.patient_hn as "HN",
       (case when (t_patient.patient_changwat <> '' and t_patient.patient_changwat <> 'null') 
                 then substr(t_patient.patient_changwat,1,2) 
                 else '99' end) as "CHANGWAT",
       (case when (t_patient.patient_amphur <> '' and t_patient.patient_amphur <> 'null') 
                 then substr(t_patient.patient_amphur,3,2) 
                 else '99' end) as "AMPHUR",
       (case  when (length(t_health_family.patient_birthday)>9 and t_health_family.patient_birthday_true = '1')
                    then substring(t_health_family.patient_birthday,1,4)::int - 543
                         || substring(t_health_family.patient_birthday,6,2)
                         || substring(t_health_family.patient_birthday,9,2)
              when (length(t_health_family.patient_birthday)>9 and t_health_family.patient_birthday_true <> '1')
                    then substring(t_health_family.patient_birthday,1,4)::int - 543|| '0101'
              else '' end) as "DOB",
        (case when (t_health_family.f_sex_id is not null and trim(t_health_family.f_sex_id) in ('1','2'))
                   then t_health_family.f_sex_id
                   else '3'  end) AS "SEX",
         f_patient_marriage_status.r_rp1853_marriage_id AS "MARRIAGE",
        (case when (r_rp1855_occupation.code is not null)
                   then  substring(r_rp1855_occupation.code,2,4) 
                   else ''
              end) as "OCCUPA",
        (case when (nation.r_rp1855_nation_id is not null)
                   then nation.r_rp1855_nation_id
                   else ''
                   end) as "NATION",
         (case when (t_health_family.patient_pid <> '' and length(t_health_family.patient_pid) =13)
                    then t_health_family.patient_pid
               when (t_health_family.patient_pid = '' and t_health_family.passport_no = '' 
                        and t_health_family.r_rp1853_foreign_id in ('02','03','04','11','12','13','14','21','22','23'))
                     then 
                        lpad(t_patient.patient_hn,13,'0')                                      
               when (t_health_family.health_family_foreigner_card_no <> '' and length(t_health_family.health_family_foreigner_card_no) =13)
                     then  t_health_family.health_family_foreigner_card_no
               else '' end) as "PERSON_ID",
          ((case when (length(t_health_family.patient_name)>50)
                     then substring(t_health_family.patient_name,1,50)
                     else t_health_family.patient_name end)||' '||
          (case when (length(t_health_family.patient_last_name)>50)
                     then substring(t_health_family.patient_last_name,1,50)
                     else t_health_family.patient_last_name end) || ',' || f_patient_prefix.patient_prefix_description ) as "NAMEPAT",
--          (case when (f_patient_prefix.r_rp1853_prefix_id is not null and f_patient_prefix.r_rp1853_prefix_id <> '')
--                     then lpad(f_patient_prefix.r_rp1853_prefix_id,3,'0')
--                     else '' end) AS "TITLE",
          f_patient_prefix.patient_prefix_description as "TITLE",
          (case when (length(t_health_family.patient_name)>50)
                     then substring(t_health_family.patient_name,1,50)
                     else t_health_family.patient_name end) as "FNAME",
          (case when (length(t_health_family.patient_last_name)>50)
                     then substring(t_health_family.patient_last_name,1,50)
                     else t_health_family.patient_last_name end) as "LNAME",
          (case when (t_health_family.patient_pid <> '' and length(t_health_family.patient_pid) =13) then '1'
                when (t_health_family.passport_no <> '') then '2'
                when (t_health_family.patient_pid = '' and t_health_family.passport_no = '' 
                        and t_health_family.r_rp1853_foreign_id in ('02','03','04','11','12','13','14','21','22','23')) then '3'
                else '4' end) as "IDTYPE"
from t_patient
     left join t_health_family on t_patient.t_health_family_id =t_health_family.t_health_family_id
     left join f_patient_prefix on t_health_family.f_prefix_id = f_patient_prefix.f_patient_prefix_id
     left join f_patient_marriage_status  on t_health_family.f_patient_marriage_status_id = f_patient_marriage_status.f_patient_marriage_status_id
     left join t_patient_payment on t_patient.t_patient_id=t_patient_payment.t_patient_id
     left join t_visit on t_patient.t_patient_id=t_visit.t_patient_id
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
     cross join b_site
where t_visit.f_visit_status_id ='3'--1=เข้าสู่กระบวนการ, 2=ค้างบันทึก, 3=จบกระบวนการ, 4=ยกเลิกการเข้ารับบริการ	
      and ((t_order.f_order_status_id <> '0') and (t_order.f_order_status_id <> '3')) 
      and t_visit_payment.visit_payment_active='1'
      and t_health_family.health_family_active = '1'
      and substring(t_visit.visit_begin_visit_time,1,10) between {0} and {1}
      --{0} {1}
