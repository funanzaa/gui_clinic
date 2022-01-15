--CHA ข้อมูลการเงินแบบละเอียด
select t_patient.patient_hn as "HN",   
         '' as "AN",
       (substr(t_visit.visit_begin_visit_time,1,4)::int -543
          ||substr(t_visit.visit_begin_visit_time,6,2) 
          ||substr(t_visit.visit_begin_visit_time,9,2)) as "DATEOPD",
       (case when (b_item.r_rp1253_charitem_id='2') then '21'
             when (b_item.r_rp1253_charitem_id='3') then '31'
             when (b_item.r_rp1253_charitem_id='4') then '31'
             when (b_item.r_rp1253_charitem_id='5') then '51'
             when (b_item.r_rp1253_charitem_id='6') then '61' 
             when (b_item.r_rp1253_charitem_id='7') then '71'
             when (b_item.r_rp1253_charitem_id='8') then '81'
             when (b_item.r_rp1253_charitem_id='9') then '91'
             when (b_item.r_rp1253_charitem_id='A') then 'A1'
             when (b_item.r_rp1253_charitem_id='B') then 'B1'
             when (b_item.r_rp1253_charitem_id='C') then 'C1'
             when (b_item.r_rp1253_charitem_id='D') then 'D1'
             when (b_item.r_rp1253_charitem_id='E') then 'E1'
             when (b_item.r_rp1253_charitem_id='F') then 'J1'
             when (b_item.r_rp1253_charitem_id='G') then 'J1'
             when (b_item.r_rp1253_charitem_id='H') then 'H1'
             when (b_item.r_rp1253_charitem_id='I') then 'J1'
             when (b_item.r_rp1253_charitem_id='J') then 'J1'
             when (b_item.r_rp1253_charitem_id='K') then 'K1'
             when (b_item.r_rp1253_charitem_id='1') then 'J1'
             when b_item.r_rp1253_charitem_id is not null
                then b_item.r_rp1253_charitem_id || '2'
                else ''
         end) AS "CHRGITEM",
        sum(t_billing_invoice_item.billing_invoice_item_payer_share)::decimal(12,2) AS "AMOUNT",
       -- sum(t_billing_invoice_item.billing_invoice_item_patient_share) AS AMOUNT_EXT,
        (case when (t_health_family.patient_pid <> '' and length(t_health_family.patient_pid) =13)
                    then t_health_family.patient_pid
               when (t_health_family.patient_pid = '' and t_health_family.passport_no = '' 
                        and t_health_family.r_rp1853_foreign_id in ('02','03','04','11','12','13','14','21','22','23'))
                     then 
                        lpad(t_patient.patient_hn,13,'0')                                      
               when (t_health_family.health_family_foreigner_card_no <> '' and length(t_health_family.health_family_foreigner_card_no) =13)
                     then  t_health_family.health_family_foreigner_card_no
               else '' end) as "PERSON_ID",
        --t_billing_invoice_item.billing_invoice_item_total as AMOUNT,        
        t_visit.visit_vn as "SEQ"
FROM  t_billing_invoice_item  
	INNER JOIN t_visit ON (t_billing_invoice_item.t_visit_id = t_visit.t_visit_id)  
	INNER JOIN t_patient ON (t_patient.t_patient_id = t_visit.t_patient_id)  
    inner join t_health_family on (t_health_family.t_health_family_id=t_patient.t_health_family_id)
	inner JOIN t_order ON (t_order.t_order_id = t_billing_invoice_item.t_order_item_id  and t_billing_invoice_item.billing_invoice_item_active='1')
    inner join b_item ON b_item.b_item_id = t_order.b_item_id
where  t_visit.f_visit_status_id ='3'--1=เข้าสู่กระบวนการ, 2=ค้างบันทึก, 3=จบกระบวนการ, 4=ยกเลิกการเข้ารับบริการ	
      and ((t_order.f_order_status_id <> '0') and (t_order.f_order_status_id <> '3')) 
      and t_health_family.health_family_active = '1'
      and substring(t_visit.visit_begin_visit_time,1,10) between {0} and {1}
group by "HN","DATEOPD","CHRGITEM","PERSON_ID","SEQ"
order by "HN"