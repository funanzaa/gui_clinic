--OOP หัตถการผู้ป่วยนอก v.1.0
--ต้องจับคู่ icd9 หน้า admin ราคาถึงจะขึ้นท่านั้น
SELECT
        t_patient.patient_hn as "HN",
        (substr(t_visit.visit_begin_visit_time,1,4)::int -543
          ||substr(t_visit.visit_begin_visit_time,6,2) 
          ||substr(t_visit.visit_begin_visit_time,9,2)) as "DATEOPD",
        (case when (b_report_12files_map_clinic.b_report_12files_std_clinic_id IN ('01','02','03','04','05','06','07','08','09','10','11'))
                then (t_visit.f_visit_type_id || b_report_12files_map_clinic.b_report_12files_std_clinic_id || '00') 
                when (b_report_12files_map_clinic.b_report_12files_std_clinic_id is null) then ''
                else  (t_visit.f_visit_type_id || '121') end) AS "CLINIC"
        ,replace(t_diag_icd9.diag_icd9_icd9_number,'.','') AS "OPER"
        ,(Q.order_price * Q.order_qty)::decimal(7,2) as "SERVPRICE"
        ,b_employee.employee_number AS "DROPID"
        , case when  (t_health_family.patient_pid IS NULL or t_health_family.patient_pid = '')
                then t_patient.patient_pid
                else t_health_family.patient_pid
          end  as "PERSON_ID"
        , t_visit.visit_vn  AS "SEQ"
        --,t_diag_icd9.diag_icd9_icd9_number,t_diag_icd9.t_diag_icd9_id
FROM b_site,t_diag_icd9 
        INNER JOIN t_visit  ON (t_visit.t_visit_id = t_diag_icd9.diag_icd9_vn)
        INNER JOIN t_patient  ON (t_visit.t_patient_id = t_patient.t_patient_id )
        INNER JOIN t_health_family  ON t_health_family.t_health_family_id = t_patient.t_health_family_id
        left join b_report_12files_map_clinic  on t_diag_icd9.b_visit_clinic_id = b_report_12files_map_clinic.b_visit_clinic_id
        left join b_employee on t_diag_icd9.diag_icd9_staff_doctor=b_employee.b_employee_id
        LEFT JOIN (
                        select b_item_service.icd9_number,t_order.order_qty,t_order.order_price,t_order.t_visit_id,b_item_16_group_id
                        from t_order
                            inner join t_visit on t_order.t_visit_id=t_visit.t_visit_id
                            inner join b_item_service on (b_item_service.b_item_id = t_order.b_item_id and b_item_service.item_service_active='1')
                        where icd9_number <> '' and order_price <> 0
                         and t_order.f_item_group_id = '5'
                          and t_order.f_order_status_id <> '3'
                           and substring(t_visit.visit_begin_visit_time,1,10)  between {0} and {1}
                        group by b_item_service.icd9_number,t_order.order_qty,t_order.order_price,t_order.t_visit_id,t_order.b_item_16_group_id
                   ) as Q on (Q.icd9_number = t_diag_icd9.diag_icd9_icd9_number and Q.t_visit_id = t_visit.t_visit_id)
WHERE  t_diag_icd9.diag_icd9_active = '1'   
and t_visit.f_visit_status_id ='3'
      and substring(t_visit.visit_begin_visit_time,1,10) between {0} and {1}
GROUP By  "PERSON_ID","SEQ","DATEOPD","OPER"
        --,t_diag_icd9.t_diag_icd9_id
        --,t_diag_icd9.diag_icd9_record_date_time
        --,t_diag_icd9.diag_icd9_active
       -- ,t_diag_icd9.diag_icd9_update_date_time
       ,t_patient.patient_hn
       -- ,t_visit.visit_begin_visit_time
        ,b_report_12files_map_clinic.b_report_12files_std_clinic_id
        ,t_visit.f_visit_type_id
        ,b_employee.employee_number
	,t_diag_icd9.diag_icd9_icd9_number
	,t_diag_icd9.t_diag_icd9_id,"SERVPRICE"