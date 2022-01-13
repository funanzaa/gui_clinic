select q1.hn,         
       q1.dateopd,     
       sum(cast(q1.actualcht as numeric)) as actualcht,     
       sum(cast(q1.total as numeric)) as total,     
       sum(cast(q1.paid as numeric)) as paid,     
       max(q1.pttype) as pttype,   
       q1.person_id,      
       q1.seq,        
       q1.opd_memo,
        max(q1.invoice) as invoice_no,
        max(q1.invoice_lotno) as invoice_lt
from (
with sub_payment as (select  distinct b_contract_plans.contract_plans_pttype,t_visit.t_visit_id,t_visit_payment_id
			from t_visit,t_visit_payment,b_contract_plans
		--	where t_visit.visit_vn='057001141' 
	     --  and t_visit_payment.visit_payment_priority = '0'
     where t_visit.t_visit_id = t_visit_payment.t_visit_id
			-- and substring(t_visit.visit_begin_visit_time,1,10) between '2556-01-01' and '2556-01-30'
            --AND t_visit.visit_begin_visit_time::date between '2020-01-01'::date and '2020-01-10'::date
            --{0} {1}
			and t_visit_payment.b_contract_plans_id=b_contract_plans.b_contract_plans_id)
			,
sub_query as (select t_patient.patient_hn as HN,   
       to_char(t_visit.visit_begin_visit_time,'YYYYMMDD') as DATEOPD,
       SUM(t_billing_invoice_item.billing_invoice_item_total) as ACTUALCHT,
       SUM(t_billing_invoice_item.billing_invoice_item_payer_share) as TOTAL,
       SUM(t_billing_invoice_item.billing_invoice_item_patient_share) AS PAID,
       null AS PTTYPE,
        (case when (t_person.person_pid <> '' and length(t_person.person_pid) =13)
                    then t_person.person_pid
               when (t_person.person_pid = '' and t_person_foreigner.passport_no = '' 
                        and t_person_foreigner.f_person_foreigner_id in ('02','03','04','11','12','13','14','21','22','23'))
                     then 
                        lpad(t_patient.patient_hn,13,'0')                                      
               when (t_person_foreigner.foreigner_no <> '' and length(t_person_foreigner.foreigner_no) =13)
                     then  t_person_foreigner.foreigner_no
               else '' end) as PERSON_ID,
        t_visit.visit_vn as SEQ,
        'OPD'::Text as OPD_MEMO,
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
left join t_person on (t_person.t_person_id=t_patient.t_person_id and t_person.active = '1')
left join t_person_foreigner ON t_person.t_person_id = t_person_foreigner.t_person_id
left join t_order on (t_order.t_order_id = t_billing_invoice_item.t_order_item_id)
left join b_item on (b_item.b_item_id = t_order.b_item_id and t_order.f_order_status_id <> '0' and t_order.f_order_status_id <> '3' )
where  t_visit.f_visit_status_id ='3'--1=เข้าสู่กระบวนการ, 2=ค้างบันทึก, 3=จบกระบวนการ, 4=ยกเลิกการเข้ารับบริการ	
   --  and t_visit.visit_vn='057001141'
    -- and substring(t_visit.visit_begin_visit_time,1,10) between '2556-01-01' and '2556-01-02'
    --AND t_visit.visit_begin_visit_time::date between '2020-01-01'::date and '2020-01-10'::date
       -- {0} {1}
      group by t_patient.patient_hn,t_visit.visit_begin_visit_time,t_person.person_pid,t_person_foreigner.passport_no,
         t_person_foreigner.f_person_foreigner_id,t_person_foreigner.foreigner_no,
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
---CHT 5/11/2558