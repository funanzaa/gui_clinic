select q.*
from (
select distinct
        b_site.b_visit_office_id as HCODE
        ,t_visit.visit_hn as HN
        ,(case when (t_person.person_pid <> '' and length(t_person.person_pid) =13)
                    then t_person.person_pid
               when (t_person.person_pid = '' and t_person_foreigner.passport_no = '' 
                        and t_person_foreigner.f_person_foreigner_id in ('02','03','04','11','12','13','14','21','22','23'))
                     then 
                        lpad(t_patient.patient_hn,13,'0')                                      
               when (t_person_foreigner.foreigner_no <> '' and length(t_person_foreigner.foreigner_no) =13)
                     then  t_person_foreigner.foreigner_no
               else '' end) as PERSON_ID
        ,max(to_char(t_visit.visit_begin_visit_time,'YYYYMMDD')) as DATE_SERV
        ,t_visit.visit_vn as SEQ
        ,(case when b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000002'
                                then '03'
                when b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000003'
                                then '04'
                when b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000004'
                                then '01'
                when b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000005'
                                then '02'
                when b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000006'
                                then '05'
                when b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000007'
                                then '07'
                when b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000008'
                                then '06'
                when b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000009'
                                then '08'
                when b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000010'
                                then '09'
                when b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000011'
                                then '10'
                when b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000012'
                                then '11'
                when b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000013'
                                then '14'
                when b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000014'
                                then '15'
                when b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000015'
                                then '16'
                when b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000016'
                                then '18'
                when b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000017'
                                then '17'
                when b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000018'
                                then '19'
                when b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000019'
                                then '20'
                when b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000020'
                                then '21'
                when b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000022'
                                then '12'
                when b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000023'
                                then '12'
                when b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000028'
                                then '13'
             else '' end) as LABTEST
     -- ,t_result_lab.result_lab_value
        ,max(case when lower(t_result_lab.result_lab_value) like '%neg%'
                    then '0.00'
                    when lower(t_result_lab.result_lab_value) like '%trace%'
                    then '1.00'
                    when lower(t_result_lab.result_lab_value) like '%pos%' OR t_result_lab.result_lab_value like '1+' OR t_result_lab.result_lab_value like '2+'
                    OR t_result_lab.result_lab_value like '3+' OR t_result_lab.result_lab_value like '4+'
                    then '2.00'
            else t_result_lab.result_lab_value end) as LABRESULT
from  --t_chronic inner join t_visit on t_chronic.t_visit_id = t_visit.t_visit_id
        t_visit
        inner join t_patient on t_visit.t_patient_id = t_patient.t_patient_id
        inner join t_person on (t_person.t_person_id=t_patient.t_person_id)
        left join t_person_foreigner ON t_person.t_person_id = t_person_foreigner.t_person_id
        inner join t_result_lab on t_visit.t_visit_id = t_result_lab.t_visit_id
        inner join t_order on t_result_lab.t_order_id = t_order.t_order_id
        inner join b_item_map_lab_ncd on t_result_lab.b_item_id = b_item_map_lab_ncd.b_item_id and b_item_map_lab_ncd.active='1'
        inner join b_item_lab_ncd_std on b_item_map_lab_ncd.b_item_lab_ncd_std_id = b_item_lab_ncd_std.b_item_lab_ncd_std_id and b_item_lab_ncd_std.active='1'
        ,b_site
where  t_result_lab.result_lab_active='1'
        and t_order.f_order_status_id <> '3'
        and (b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000002' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000003' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000004' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000005' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000006' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000007' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000008' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000009' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000010' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000011' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000012' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000013' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000014' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000015' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000016' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000017' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000018' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000019' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000020' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000021' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000022' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000023' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000024' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000025' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000026' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000027' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000028' OR
                            b_item_lab_ncd_std.b_item_lab_ncd_std_id='ncd201000000000029' )
        AND t_visit.f_visit_type_id <> 'S'
        AND t_visit.f_visit_status_id ='3'
        AND t_visit.visit_money_discharge_status='1'
        AND t_visit.visit_doctor_discharge_status='1' 
        --AND t_visit.visit_vn='06100001'    
        --AND substring(t_visit.visit_begin_visit_time,1,10) between '2561-03-01' and '2561-03-31'
        --AND t_visit.visit_begin_visit_time::date between '2020-01-01'::date and '2020-01-10'::date
        --{0} {1}
group by 
    b_site.b_visit_office_id
    ,t_visit.visit_hn
    ,t_person.person_pid
    ,t_person_foreigner.passport_no
    ,t_person_foreigner.foreigner_no
    ,t_person_foreigner.f_person_foreigner_id
    ,t_patient.patient_hn
    ,b_item_lab_ncd_std.b_item_lab_ncd_std_id
    ,t_person.person_hcis
    ,t_visit.visit_vn
    ,t_visit.visit_staff_doctor_discharge_date_time
-- ,t_chronic.modify_date_time
--t_result_lab.result_lab_value
order by t_visit.visit_vn
) q
where q.labtest <>''
--------21-06-61 By Busaya 16:37 น.