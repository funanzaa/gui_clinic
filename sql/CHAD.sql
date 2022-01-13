select  q1.hn,q1.dateserve,q1.seq,q1.clinic,q1.itemtype,q1.itemcode,q1.qty,
              (case when (q1.diag_icd9 in ('1007700','1007713','1007810','1007811','1007812','1007818','1007819','1547700',
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
                                                                        '9007802')) then (case when (q1.itemtype='11') then '0' else q1.amount end) else q1.amount end) amount,
              (case when (q1.diag_icd9 in ('1007700','1007713','1007810','1007811','1007812','1007818','1007819','1547700',
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
                                                                        '9007802')) then (case when (q1.itemtype='11') then '0' else q1.amount_ext end) else q1.amount_ext end) amount_ext,                                                         
              q1.provider,q1.addon_desc,q1.b_item_16_group_id--,q1.diag_icd9
from (
		select q2.hn,q2.dateserve,q2.seq,q2.clinic,q2.itemtype,q2.itemcode,sum(q2.qty) as qty,sum(q2.amount) as amount,sum(q2.amount_ext) as amount_ext,q2.provider,q2.addon_desc,q2.b_item_16_group_id,q2.diag_icd9
		from (
				select t_patient.patient_hn as HN,   
					       to_char(t_visit.visit_begin_visit_time,'YYYYMMDD') as DATESERVE,
					       t_visit.visit_vn as SEQ,
					       case when b_report_12files_map_clinic.b_report_12files_std_clinic_id IN ('01','02','03','04','05','06','07','08','09','10','11') 
						  then (t_visit.f_visit_type_id || b_report_12files_map_clinic.b_report_12files_std_clinic_id || '00') 
						  when b_report_12files_map_clinic.b_report_12files_std_clinic_id is null then ''
						  else  (t_visit.f_visit_type_id || '121') end AS CLINIC ,
					       (case when(b_item.b_item_16_group_id='3120000000002') then '2' 
                             when(b_item.b_item_16_group_id='3120000000005') then '5'
						     when(b_item.b_item_16_group_id='3120000000006') then '6'
						     when(b_item.b_item_16_group_id='3120000000007') then '7'
						     when(b_item.b_item_16_group_id='3120000000008') then '8'
						     when(b_item.b_item_16_group_id='3120000000009') then '9'
						     when(b_item.b_item_16_group_id='3120000000010') then '10'
						     when(b_item.b_item_16_group_id='3120000000011') then '11'
						     when(b_item.b_item_16_group_id='3120000000012') then '12'
						     when(b_item.b_item_16_group_id='3120000000013') then '13'
						     when(b_item.b_item_16_group_id='3120000000014') then '14'
						     when(b_item.b_item_16_group_id='3120000000016') then '16'
						     when(b_item.b_item_16_group_id='3120000000018') then '18'
						    else '99' end) AS ITEMTYPE,								
							case when(item_general_number is null or item_general_number = '') 
								  then (
									     case when (b_item.b_item_16_group_id='3120000000012') 
											then  (case when b_item.item_number in ('55021','55020') then b_item.item_number else '' end)
										  when (b_item.b_item_16_group_id='3120000000016')
											then  (case when b_item.item_number in ('S1801','S1802','S1803','S1804') then b_item.item_number else '' end)
										  else b_item.item_number end
								       )  
								  else (
									     case when (b_item.b_item_16_group_id='3120000000012') 
											then  (case when item_general_number in ('55021','55020') then item_general_number else item_general_number end)
										  when (b_item.b_item_16_group_id='3120000000016')
											then  (case when item_general_number in ('S1801','S1802','S1803','S1804') then item_general_number else item_general_number end)
										  else item_general_number end
								       )  
							    end	AS ITEMCODE
						    ,
					      t_order.order_qty AS QTY,
					      t_billing_invoice_item.billing_invoice_item_payer_share AS AMOUNT,
					      t_billing_invoice_item.billing_invoice_item_patient_share AS AMOUNT_EXT
					      ,max(b_employee.employee_number) as PROVIDER 
						  ,(case when(b_item.b_item_16_group_id='3120000000013') then t_order.order_notice
						    else '' end) AS addon_desc														
						  ,b_item.b_item_16_group_id,
					       replace(b_item_service.icd9_number,'.','') as diag_icd9,t_order.t_order_id
					FROM  t_billing_invoice_item  
					    INNER JOIN t_visit ON (t_billing_invoice_item.t_visit_id = t_visit.t_visit_id)                         
					    INNER JOIN t_patient ON (t_patient.t_patient_id = t_visit.t_patient_id)  
					    inner join t_person on (t_person.t_person_id=t_patient.t_person_id)
					    inner JOIN t_order ON (t_order.t_order_id = t_billing_invoice_item.t_order_item_id  and t_billing_invoice_item.billing_invoice_item_active='1')
					    left join b_item_service on (b_item_service.b_item_id = t_order.b_item_id and b_item_service.item_service_active='1')
					    left JOIN t_diag_icd9  ON (t_diag_icd9.diag_icd9_vn=t_visit.t_visit_id and t_diag_icd9.diag_icd9_active='1')
					    left join b_employee on (t_diag_icd9.diag_icd9_staff_doctor=b_employee.b_employee_id)
					    LEFT JOIN (select max(b_report_12files_map_clinic.b_visit_clinic_id) as b_visit_clinic_id,max(b_report_12files_map_clinic.b_report_12files_std_clinic_id) as b_report_12files_std_clinic_id 
							from b_report_12files_map_clinic) b_report_12files_map_clinic  ON (t_diag_icd9.b_visit_clinic_id = b_report_12files_map_clinic.b_visit_clinic_id)
					    left join b_item_16_group on (b_item_16_group.b_item_16_group_id=t_order.b_item_16_group_id and b_item_16_group.item_16_group_active='1')
					    left join t_order_drug on (t_order.t_order_id=t_order_drug.t_order_id and t_order_drug.order_drug_active='1')
					    inner join b_item ON (b_item.b_item_id = t_order.b_item_id	and b_item.item_active='1')
					where  t_visit.f_visit_status_id ='3'--1=เข้าสู่กระบวนการ, 2=ค้างบันทึก, 3=จบกระบวนการ, 4=ยกเลิกการเข้ารับบริการ	
					      and ((t_order.f_order_status_id <> '0') and (t_order.f_order_status_id <> '3')) 
					      and t_person.active = '1'
					      --and t_visit.visit_vn in ('05702116')
					      --and substring(t_visit.visit_begin_visit_time,1,10) between '2560-10-01' and '2560-10-15'
                          --AND t_visit.visit_begin_visit_time::date between '2020-01-01'::date and '2020-01-10'::date
					      --{0} {1}
					GROUP BY t_patient.patient_hn,t_visit.visit_begin_visit_time,t_visit.visit_vn,b_report_12files_map_clinic.b_report_12files_std_clinic_id,
						t_visit.f_visit_type_id,b_item_16_group.b_item_16_group_id,b_item.item_number,b_item.item_general_number,
						t_billing_invoice_item.billing_invoice_item_patient_share,t_billing_invoice_item.billing_invoice_item_payer_share,replace(b_item_service.icd9_number,'.','')
						,t_order.order_qty,t_billing_invoice_item.billing_invoice_item_payer_share,t_billing_invoice_item.billing_invoice_item_patient_share,t_order.t_order_id,b_item.b_item_16_group_id,t_order.order_notice
		 ) q2
		 group by q2.hn,q2.dateserve,q2.seq,q2.clinic,q2.itemtype,q2.itemcode,q2.provider,q2.addon_desc,q2.b_item_16_group_id,q2.diag_icd9
) as q1
where q1.ITEMTYPE<>'99' and 
      q1.itemcode<>''
order by q1.seq,q1.itemtype,q1.itemcode
--CHAD 09/12/2559 TIME:13.06
--CHAD 14/06/2559 edit eakchai add itemcode 5
--CHAD 14/09/2560 edit eakchai add addon_detail
--CHAD 01/10/2560 edit eakchai edit addon_detail
--CHAD 11/06/2562 edit eakchai edit addon_detail t_order.order_notice
--CHAD 11/12/2562 edit eakchai edit Rename column addon_detail -> addon_desc