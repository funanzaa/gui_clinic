select t_patient.patient_hn as HN,   
       to_char(t_visit.visit_begin_visit_time,'YYYYMMDD') as DATEOPD,
       (case when (b_map_rp1253_charitem.r_rp1253_charitem_id='2') then '21'
             when (b_map_rp1253_charitem.r_rp1253_charitem_id='3') then '31'
             when (b_map_rp1253_charitem.r_rp1253_charitem_id='4') then '31'
             when (b_map_rp1253_charitem.r_rp1253_charitem_id='5') then '51'
             when (b_map_rp1253_charitem.r_rp1253_charitem_id='6') then '61' 
             when (b_map_rp1253_charitem.r_rp1253_charitem_id='7') then '71'
             when (b_map_rp1253_charitem.r_rp1253_charitem_id='8') then '81'
             when (b_map_rp1253_charitem.r_rp1253_charitem_id='9') then '91'
             when (b_map_rp1253_charitem.r_rp1253_charitem_id='A') then 'A1'
             when (b_map_rp1253_charitem.r_rp1253_charitem_id='B') then 'B1'
             when (b_map_rp1253_charitem.r_rp1253_charitem_id='C') then 'C1'
             when (b_map_rp1253_charitem.r_rp1253_charitem_id='D') then 'D1'
             when (b_map_rp1253_charitem.r_rp1253_charitem_id='E') then 'E1'
             when (b_map_rp1253_charitem.r_rp1253_charitem_id='F') then 'J1'
             when (b_map_rp1253_charitem.r_rp1253_charitem_id='G') then 'J1'
             when (b_map_rp1253_charitem.r_rp1253_charitem_id='H') then 'H1'
             when (b_map_rp1253_charitem.r_rp1253_charitem_id='I') then 'J1'
             when (b_map_rp1253_charitem.r_rp1253_charitem_id='J') then 'J1'
             when (b_map_rp1253_charitem.r_rp1253_charitem_id='K') then 'K1'
             when (b_map_rp1253_charitem.r_rp1253_charitem_id='1') then 'J1'
             when b_map_rp1253_charitem.r_rp1253_charitem_id is not null
                then b_map_rp1253_charitem.r_rp1253_charitem_id || '2'
                else ''
         end) AS CHRGITEM,
        sum(t_billing_invoice_item.billing_invoice_item_payer_share) AS AMOUNT,
        sum(t_billing_invoice_item.billing_invoice_item_patient_share) AS AMOUNT_EXT,
        (case when (t_person.person_pid <> '' and length(t_person.person_pid) =13)
                    then t_person.person_pid
               when (t_person.person_pid = '' and t_person_foreigner.passport_no = '' 
                        and t_person_foreigner.f_person_foreigner_id in ('02','03','04','11','12','13','14','21','22','23'))
                     then 
                        lpad(t_patient.patient_hn,13,'0')                                      
               when (t_person_foreigner.foreigner_no <> '' and length(t_person_foreigner.foreigner_no) =13)
                     then  t_person_foreigner.foreigner_no
               else '' end) as PERSON_ID,
        --t_billing_invoice_item.billing_invoice_item_total as AMOUNT,        
        t_visit.visit_vn as SEQ
FROM  t_billing_invoice_item  
	INNER JOIN t_visit ON (t_billing_invoice_item.t_visit_id = t_visit.t_visit_id)  
	INNER JOIN t_patient ON (t_patient.t_patient_id = t_visit.t_patient_id)  
    inner join t_person on (t_person.t_person_id=t_patient.t_person_id)
	inner JOIN t_order ON (t_order.t_order_id = t_billing_invoice_item.t_order_item_id  and t_billing_invoice_item.billing_invoice_item_active='1')
    -- inner join b_item ON b_item.b_item_id = t_order.b_item_id // comment by golf
    inner join b_map_rp1253_charitem on b_map_rp1253_charitem.b_item_id = t_order.b_item_id -- add by golf
    left join t_person_foreigner ON t_person.t_person_id = t_person_foreigner.t_person_id
where  t_visit.f_visit_status_id ='3'--1=เข้าสู่กระบวนการ, 2=ค้างบันทึก, 3=จบกระบวนการ, 4=ยกเลิกการเข้ารับบริการ	
      and ((t_order.f_order_status_id <> '0') and (t_order.f_order_status_id <> '3')) 
      and t_person.active = '1'
      --and t_visit.visit_vn='06412993'
      AND t_visit.visit_begin_visit_time::date between '2020-01-01'::date and '2020-01-10'::date
    -- {0} {1}
group by HN,DATEOPD,CHRGITEM,PERSON_ID,SEQ
order by HN
---CHA 7/12/2563 change field b_item.r_rp1253_charitem_id to b_map_rp1253_charitem.r_rp1253_charitem_id by golf