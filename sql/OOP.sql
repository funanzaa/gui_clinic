SELECT t_patient.patient_hn as HN,
        to_char(t_visit.visit_begin_visit_time,'YYYYMMDD') as DATEOPD,
        (case when (b_report_12files_map_clinic.b_report_12files_std_clinic_id IN ('01','02','03','04','05','06','07','08','09','10','11'))
                then (t_visit.f_visit_type_id || b_report_12files_map_clinic.b_report_12files_std_clinic_id || '00') 
                when (b_report_12files_map_clinic.b_report_12files_std_clinic_id is null) then ''
                else  (t_visit.f_visit_type_id || '121') end) AS CLINIC
        ,replace(t_diag_icd9.diag_icd9_icd9_number,'.','') AS OPER
        , (case when (replace(t_diag_icd9.diag_icd9_icd9_number,'.','') in ('1007700','1007713','1007810','1007811','1007812','1007818','1007819','1547700',
                                                                                                                                        '1547713','1547810','1547811','1547812','1547818','1547819','3027713','4007713',
                                                                                                                                        '4007810','4007811','4007812','4007818','4007819','5907700','5907713','5907810',
                                                                                                                                        '5907811','5907812','5907818','5907819','7217700','7217713','7217810','7217811',
                                                                                                                                        '7217812','7217818','7217819','7227700','7227713','7227810','7227811','7227812',
                                                                                                                                        '7227818','7227819','7247700','7247713','7247810','7247811','7247812','7247818',
                                                                                                                                        '7247819','7257700','7257713','7257810','7257811','7257812','7257818','7257819',
                                                                                                                                        '7267700','7267713','7267810','7267811','7267812','7267818','7267819','8717700',
                                                                                                                                        '8717713','8717810','8717811','8717812','8717818','8717819','8727700','8727713',
                                                                                                                                        '8727810','8727811','8727812','8727818','8727819','8737700','8737713','8737810',
                                                                                                                                        '8737811','8737812','8737818','8737819','8747700','8747713','8747811','8747812',
                                                                                                                                        '8747818','8747819','8757700','8757713','8757810','8757811','8757812','8757818',
                                                                                                                                        '8757819','8767700','8767713','8767810','8767811','8767812','8767818','8767819',
                                                                                                                                        '9007700','9007810','9007811','9007812','9007818','9007819','9997700','9997713',
                                                                                                                                        '9997810','9997811','9997812','9997818','9997819','1007701','1007714','1007820',
                                                                                                                                        '1007821','1007822','1547701','1547714','1547820','1547821','1547822','3027714',
                                                                                                                                        '4007714','4007820','4007821','4007822','5907701','5907714','5907820','5907821',
                                                                                                                                        '5907822','7217701','7217714','7217820','7217821','7217822','7227701','7227714',
                                                                                                                                        '7227820','7227821','7227822','7247701','7247714','7247820','7247821','7247822',
                                                                                                                                        '7257701','7257714','7257820','7257821','7257822','7267701','7267714','7267820',
                                                                                                                                        '7267821','7267822','8717701','8717714','8717820','8717821','8717822','8727701',
                                                                                                                                        '8727714','8727820','8727821','8727822','8737701','8737714','8737820','8737821',
                                                                                                                                        '8737822','8747701','8747714','8747820','8747821','8747822','8757701','8757714',
                                                                                                                                        '8757820','8757821','8757822','8767701','8767714','8767820','8767821','8767822',
                                                                                                                                        '9007701','9007820','9007821','9007822','9997701','9997714','9997820','9997821',
                                                                                                                                        '9997822','9007712','9007713','9007714','9007716','9007730','9007715','9007800',
                                                                                                                                        '9007802')) 
                     then SUM(case when (Q.order_price * Q.order_qty) is not null and Q.b_item_16_group_id = '3120000000011'   then (Q.order_price * Q.order_qty)  else 0  end) 
                     else 0 end) AS SERVPRICE
        ,b_employee.employee_number AS DROPID
        , case when (t_person.person_pid <> '' and length(t_person.person_pid) =13)
                then t_person.person_pid
                else ''
          end  as PERSON_ID
        , t_visit.visit_vn  AS SEQ,t_diag_icd9.diag_icd9_icd9_number,t_diag_icd9.t_diag_icd9_id
FROM b_site,t_diag_icd9 
        INNER JOIN t_visit  ON (t_visit.t_visit_id = t_diag_icd9.diag_icd9_vn)
        INNER JOIN t_patient  ON (t_visit.t_patient_id = t_patient.t_patient_id )
        inner join t_person on (t_person.t_person_id = t_patient.t_person_id)
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
                            --and t_visit.visit_vn='05902369'
                            --and substring(t_visit.visit_begin_visit_time,1,10)  between '2556-10-01' and '2556-10-31'
                            --{0} {1}
                        group by b_item_service.icd9_number,t_order.order_qty,t_order.order_price,t_order.t_visit_id,t_order.b_item_16_group_id
                   ) as Q on (Q.icd9_number = t_diag_icd9.diag_icd9_icd9_number and Q.t_visit_id = t_visit.t_visit_id)
WHERE  t_diag_icd9.diag_icd9_active = '1'   
        and t_visit.f_visit_status_id ='3'
      --AND t_visit.visit_vn='05902369'
      AND t_visit.visit_begin_visit_time::date between '2020-01-01'::date and '2020-01-10'::date
      --{0} {1}
GROUP By  PERSON_ID,SEQ,DATEOPD,OPER
        ,t_diag_icd9.t_diag_icd9_id
        ,t_diag_icd9.record_date_time
        ,t_diag_icd9.diag_icd9_active
        ,t_diag_icd9.update_date_time
        ,t_patient.patient_hn
        ,t_visit.visit_begin_visit_time
        ,b_report_12files_map_clinic.b_report_12files_std_clinic_id
        ,t_visit.f_visit_type_id
        ,b_employee.employee_number
	,t_diag_icd9.diag_icd9_icd9_number
	,t_diag_icd9.t_diag_icd9_id
-- OOP  18/11/2559_15:08