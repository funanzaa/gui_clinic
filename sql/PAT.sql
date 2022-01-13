select distinct b_site.b_visit_office_id as HCODE,
       t_patient.patient_hn as HN,
       (case when (t_address.province_id <> '' and t_address.province_id is not null) 
                 then substr(t_address.province_id,1,2) 
                 else '99' end) as CHANGWAT,
       (case when (t_address.district_id <> '' and t_address.district_id is not null) 
                 then substr(t_address.district_id,3,2) 
                 else '99' end) as AMPHUR,
       (case  when (t_person.person_dob is not null and t_person.person_dob_true = '1')
                    then to_char(t_person.person_dob,'YYYYMMDD')
              else '' end) as DOB,
        (case when (t_person.f_sex_id is not null and trim(t_person.f_sex_id) in ('1','2'))
                   then t_person.f_sex_id
                   else '3'  end) AS SEX,
         f_patient_marriage_status.r_rp1853_marriage_id AS MARRIAGE,
        (case when (r_rp1855_occupation.code is not null)
                   then r_rp1855_occupation.code
                   else ''
              end) as OCCUPA,
        (case when (nation.r_rp1855_nation_id is not null)
                   then nation.r_rp1855_nation_id
                   else ''
                   end) as NATION,
         (case when (t_person.person_pid <> '' and length(t_person.person_pid) =13)
                    then t_person.person_pid
               when (t_person.person_pid = '' and t_person_foreigner.passport_no = '' 
                        and t_person_foreigner.f_person_foreigner_id in ('02','03','04','11','12','13','14','21','22','23'))
                     then 
                        lpad(t_patient.patient_hn,13,'0')                                      
               when (t_person_foreigner.foreigner_no <> '' and length(t_person_foreigner.foreigner_no) =13)
                     then  t_person_foreigner.foreigner_no
               else '' end) as PERSON_ID,
          ((case when (length(t_person.person_firstname)>50)
                     then substring(t_person.person_firstname,1,50)
                     else t_person.person_firstname end)||' '||
          (case when (length(t_person.person_lastname)>50)
                     then substring(t_person.person_lastname,1,50)
                     else t_person.person_lastname end)) as NAMEPAT,
          (case when (f_patient_prefix.r_rp1853_prefix_id is not null and f_patient_prefix.r_rp1853_prefix_id <> '')
                     then lpad(f_patient_prefix.r_rp1853_prefix_id,3,'0')
                     else '' end) AS TITLE,
          (case when (length(t_person.person_firstname)>50)
                     then substring(t_person.person_firstname,1,50)
                     else t_person.person_firstname end) as FNAME,
          (case when (length(t_person.person_lastname)>50)
                     then substring(t_person.person_lastname,1,50)
                     else t_person.person_lastname end) as LNAME,
          (case when (t_person.person_pid <> '' and length(t_person.person_pid) =13) then '1'
                when (t_person_foreigner.passport_no <> '') then '2'
                when (t_person.person_pid = '' and t_person_foreigner.passport_no = '' 
                        and t_person_foreigner.f_person_foreigner_id in ('02','03','04','11','12','13','14','21','22','23')) then '3'
                else '4' end) as IDTYPE
from t_patient
    -- left join t_health_family on t_patient.t_health_family_id =t_health_family.t_health_family_id
	 INNER JOIN t_person ON t_person.t_person_id = t_patient.t_person_id
     LEFT JOIN t_person_address on t_person.t_person_id = t_person_address.t_person_id
                              and t_person_address.f_address_type_id = '1'
                              and t_person_address.priority = '1'
                              and t_person_address.active = '1'
     LEFT JOIN t_address on t_address.t_address_id = t_person_address.t_address_id
                              and t_address.active = '1'
     left join t_person_foreigner ON t_person.t_person_id = t_person_foreigner.t_person_id
     left join f_patient_prefix on t_person.f_prefix_id = f_patient_prefix.f_patient_prefix_id
     left join f_patient_marriage_status on t_person.f_patient_marriage_status_id = f_patient_marriage_status.f_patient_marriage_status_id
     left join t_patient_payment on t_patient.t_patient_id=t_patient_payment.t_patient_id
     left join t_visit on t_patient.t_patient_id=t_visit.t_patient_id
     left join t_billing on t_visit.t_visit_id=t_billing.t_visit_id
     left join t_visit_payment on t_visit.t_visit_id=t_visit_payment.t_visit_id
     left join t_order on t_visit.t_visit_id=t_order.t_visit_id
     left join b_item on t_order.b_item_id=b_item.b_item_id
     left join b_contract_plans on t_visit_payment.b_contract_plans_id=b_contract_plans.b_contract_plans_id 
     left join f_patient_occupation on t_person.f_patient_occupation_id = f_patient_occupation.f_patient_occupation_id
     left join b_map_rp1855_occupation on f_patient_occupation.f_patient_occupation_id = b_map_rp1855_occupation.f_patient_occupation_id
     left join r_rp1855_occupation on b_map_rp1855_occupation.r_rp1855_occupation_id = r_rp1855_occupation.id
     left join f_patient_nation as race_1 on t_person.f_patient_race_id = race_1.f_patient_nation_id
     left join b_map_rp1855_nation as race on race_1.f_patient_nation_id = race.f_patient_nation_id
     left join f_patient_nation as nation_1 on t_person.f_patient_nation_id = nation_1.f_patient_nation_id
     left join b_map_rp1855_nation as nation on race_1.f_patient_nation_id = nation.f_patient_nation_id
     cross join b_site
where t_visit.f_visit_status_id ='3'--1=เข้าสู่กระบวนการ, 2=ค้างบันทึก, 3=จบกระบวนการ, 4=ยกเลิกการเข้ารับบริการ	
      and ((t_order.f_order_status_id <> '0') and (t_order.f_order_status_id <> '3')) 
      and t_visit_payment.visit_payment_active='1'
      and t_person.active = '1'
      --and t_visit.visit_vn='050000013'
      AND t_visit.visit_begin_visit_time::date between '2020-01-01'::date and '2020-01-10'::date