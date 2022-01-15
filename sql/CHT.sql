--CHT ข้อมูลการเงิน
select q1.hn as "HN", 
       '' as "AN",
       q1.dateopd as "DATE",     
       --sum(cast(q1.actualcht as numeric)) as actualcht,     
       sum(cast(q1.total as numeric)) as "TOTAL",     
       sum(cast(q1.paid as numeric)) as "PAID",     
       max(q1.pttype) as "PTTYPE",   
       q1.person_id as "PERSON_ID",      
       q1.seq as "SEQ",        
       q1.opd_memo as "OPD_MEMO",
        max(q1.invoice) as "INVOICE_NO",
        max(q1.invoice_lotno) as "INVOICE_LT"
from (
with sub_payment as (select  distinct b_contract_plans.contract_plans_pttype,t_visit.t_visit_id,t_visit_payment_id
			from t_visit,t_visit_payment,b_contract_plans
     where t_visit.t_visit_id = t_visit_payment.t_visit_id
			and substring(t_visit.visit_begin_visit_time,1,10) between {0} and {1}
			and t_visit_payment.b_contract_plans_id=b_contract_plans.b_contract_plans_id)
			,
sub_query as (select t_patient.patient_hn as HN,   
       (substr(t_visit.visit_begin_visit_time,1,4)::int -543
          ||substr(t_visit.visit_begin_visit_time,6,2) 
          ||substr(t_visit.visit_begin_visit_time,9,2)) as DATEOPD,
       SUM(t_billing_invoice_item.billing_invoice_item_total) as ACTUALCHT,
       SUM(t_billing_invoice_item.billing_invoice_item_payer_share) as TOTAL,
       SUM(t_billing_invoice_item.billing_invoice_item_patient_share) AS PAID,
       null AS PTTYPE,
        (case when (t_health_family.patient_pid <> '' and length(t_health_family.patient_pid) =13)
                    then t_health_family.patient_pid
               when (t_health_family.patient_pid = '' and t_health_family.passport_no = '' 
                        and t_health_family.r_rp1853_foreign_id in ('02','03','04','11','12','13','14','21','22','23'))
                     then 
                        lpad(t_patient.patient_hn,13,'0')                                      
               when (t_health_family.health_family_foreigner_card_no <> '' and length(t_health_family.health_family_foreigner_card_no) =13)
                     then  t_health_family.health_family_foreigner_card_no
               else '' end) as PERSON_ID,
        t_visit.visit_vn as SEQ,
        '' as OPD_MEMO,
        t_billing_invoice_item.t_payment_id as invoice,
         t_billing_invoice.t_billing_id as invoice_lotno,
        t_visit.t_visit_id,
        t_billing_invoice_item.t_payment_id as t_visit_id_billing
FROM  --t_billing_invoice_item,t_visit,t_patient,t_health_family,t_order,b_item,t_billing_invoice,t_billing_receipt
--2877
t_billing_invoice 
INNER JOIN t_visit on(t_billing_invoice.t_visit_id=t_visit.t_visit_id)
left join t_billing_invoice_item on (t_billing_invoice.t_billing_invoice_id=t_billing_invoice_item.t_billing_invoice_id and t_billing_invoice_item.billing_invoice_item_active='1')
--left join t_billing_receipt on (t_billing_receipt.t_visit_id=t_visit.t_visit_id and t_billing_receipt.billing_receipt_active='1')
left join t_patient on (t_patient.t_patient_id = t_visit.t_patient_id and t_patient.patient_active='1')
left join t_health_family on (t_health_family.t_health_family_id=t_patient.t_health_family_id and t_health_family.health_family_active = '1')
left join t_order on (t_order.t_order_id = t_billing_invoice_item.t_order_item_id)
left join b_item on (b_item.b_item_id = t_order.b_item_id and t_order.f_order_status_id <> '0' and t_order.f_order_status_id <> '3' )
where  t_visit.f_visit_status_id ='3'--1=เข้าสู่กระบวนการ, 2=ค้างบันทึก, 3=จบกระบวนการ, 4=ยกเลิกการเข้ารับบริการ	
     and substring(t_visit.visit_begin_visit_time,1,10) between {0} and {1}
      group by t_patient.patient_hn,t_visit.visit_begin_visit_time,t_health_family.patient_pid,t_health_family.passport_no,
         t_health_family.r_rp1853_foreign_id,t_health_family.health_family_foreigner_card_no,
         t_visit.visit_vn,t_visit.t_visit_id,t_billing_invoice_item.t_payment_id,t_billing_invoice.t_billing_id
)
         select sub_query.hn,
         sub_query.dateopd,
        sub_query.actualcht, 
        sub_query.total,
        sub_query.paid,
        (case when (sub_payment.contract_plans_pttype='A1')
                   then '10' else 
                                   (case when (sub_payment.contract_plans_pttype is not null)
                                            then sub_payment.contract_plans_pttype
                                            else ''
                                    end) end) AS PTTYPE,
         sub_query.person_id,
         sub_query.seq,
         sub_query.opd_memo,
         sub_query.invoice_lotno,
          sub_query.invoice
         from sub_query,sub_payment
         where sub_query.t_visit_id = sub_payment.t_visit_id
         and sub_query.t_visit_id_billing = sub_payment.t_visit_payment_id
) q1
group by q1.hn,q1.dateopd,q1.person_id,q1.seq,q1.opd_memo