select distinct qr1.person_id, qr1.hn, qr1.clinic, qr1.dateopd, qr1.timeopd, qr1.seq,  qr1.uuc, qr1.detail,
             qr1.optype,--(case when ('4' and qr1.visit_office_changwat='10')  then '4' else (case when (qr1.CHRGITEM='21') then '4' else qr1.optype end) end) optype, 
              qr1.typein, qr1.typeout ,qr1.maininscl,qr1.claim_code
              ,case when qr1.visit_vital_sign_blood_presure <> '' and length(split_part(qr1.visit_vital_sign_blood_presure, '/', 1)) <= 3 
              			then split_part(qr1.visit_vital_sign_blood_presure, '/', 1) 
              		when length(split_part(qr1.visit_vital_sign_blood_presure, '/', 1)) > 3 
              			then '' end as sbp
              ,case when qr1.visit_vital_sign_blood_presure <> '' and length(split_part(qr1.visit_vital_sign_blood_presure, '/', 2)) <= 3  
              			then split_part(qr1.visit_vital_sign_blood_presure, '/', 2) 
              		when length(split_part(qr1.visit_vital_sign_blood_presure, '/', 2)) > 4 
              			then '' end as dbp
              ,visit_vital_sign_temperature as btemp
              ,visit_vital_sign_heart_rate as pr
              ,visit_vital_sign_respiratory_rate as rr
from (
 SELECT  t_visit_id ,person_id, hn, clinic, dateopd, timeopd, seq,  uuc, detail, optype, typein, typeout ,maininscl,visit_office_changwat,diag_icd10_number,diag_icd9_icd9_number,claim_code
                ,visit_vital_sign_blood_presure,visit_vital_sign_temperature,visit_vital_sign_heart_rate,visit_vital_sign_respiratory_rate
                from (
                
                SELECT DISTINCT t_visit.t_visit_id ,b_contract_plans.r_rp1853_instype_id,
                    (case when (t_person.person_pid <> '' and length(t_person.person_pid) =13)
                    then t_person.person_pid
               when (t_person.person_pid = '' and t_person_foreigner.passport_no = '' 
                        and t_person_foreigner.f_person_foreigner_id in ('02','03','04','11','12','13','14','21','22','23'))
                     then 
                        lpad(t_patient.patient_hn,13,'0')                                      
               when (t_person_foreigner.foreigner_no <> '' and length(t_person_foreigner.foreigner_no) =13)
                     then  t_person_foreigner.foreigner_no
               else '' end) as PERSON_ID,
                    t_patient.patient_hn AS HN
                    ,case when b_report_12files_map_clinic.b_report_12files_std_clinic_id IN ('01','02','03','04','05','06','07','08','09','10','11') 
                          then (t_visit.f_visit_type_id || b_report_12files_map_clinic.b_report_12files_std_clinic_id || '00') 
                          when b_report_12files_map_clinic.b_report_12files_std_clinic_id is null then ''
                          else  (t_visit.f_visit_type_id || '121') end AS CLINIC   
                    ,case when t_visit.visit_begin_visit_time is not null
                                then to_char(t_visit.visit_begin_visit_time,'yyyymmdd')
                                ELSE ''   END AS DATEOPD
                    ,to_char(t_visit.visit_begin_visit_time,'HH24MI') as TIMEOPD
                    ,t_visit.visit_vn AS SEQ	
                    ,case when r_rp1853_instype.maininscl in ('UCS','WEL')
                            then '1'
                            else '2'
                     end as UUC
                     ,(case when (symptom.main_symptom is not null) then replace(symptom.main_symptom,'\n','') else '' end) as DETAIL
                     ,case 
                           -- Case OPTYPE=0 [No case]
			   -- Case OPTYPE=1	
                           when ((r_rp1853_instype.maininscl in ('UCS','WEL')) 
                                   and t_visit_refer_in_out.f_visit_refer_type_id = '0'
                                   and t_visit_refer_in_out.visit_refer_in_out_active = '1'
                                   and b_visit_office.visit_office_changwat in (select substr(site_changwat,1,2) from b_site)
                                   and b_site.b_visit_office_id = '14955')
                                      then '1' 
			   -- Case OPTYPE=3
			   when ((r_rp1853_instype.maininscl in ('UCS','WEL')) and t_accident.accident_active='1' or f_emergency_status_id='3')
                                       then '3'
                           -- Case OPTYPE=4 [In bkk]        
                           when (trim(b_contract_plans.r_rp1853_instype_id)='74' and (select vOF.visit_office_changwat from b_visit_office vOF where vOF.b_visit_office_id=t_visit_payment.visit_payment_main_hospital group by vOF.visit_office_changwat)='10')
                                      then '4'
                           -- Case OPTYPE=4 [Not in bkk]
                           when (trim(b_contract_plans.r_rp1853_instype_id)='74'
                                    and (select vOF.visit_office_changwat from b_visit_office vOF where vOF.b_visit_office_id=t_visit_payment.visit_payment_main_hospital group by vOF.visit_office_changwat)<>'10'
                                    and (select count(*)
                                         from t_order 
                                              INNER JOIN b_item on (b_item.b_item_id=t_order.b_item_id )
                                         where t_order.t_visit_id=t_visit.t_visit_id
                                               and ((t_order.f_order_status_id <> '0') and (t_order.f_order_status_id <> '3')) 
                                               and (b_item.r_rp1253_charitem_id in ('2','E')  or b_item.item_general_number in ('2501','2502','6006','8101','8102','8103','8104','8105','8106','8108','8109','8110',
                                                                                                                                '8111','8112','8201','8202','8203','8204','8205','8206','8207','8208','8209','8210',
                                                                                                                                '8211','8212','8213','8214','8215','8216','8217','8218','8219','8220','8221','8222',
                                                                                                                                '8223','8301','8302','8303','8304','8521','8522','8523','8524','8525','8526','8706',
                                                                                                                                '8707','8708','8709','8710','8801','8802','8803','8804','8805','8807','8808','8809',
                                                                                                                                '8810','8901','8902','9001','H0489','H9339','H9375','H9378','H9383','H9433',
                                                                                                                                'H9438','H9449','H9549')))>=1)
                                      then '4'
                            -- Case OPTYPE=5  [No case]
                            -- Case OPTYPE=6  [Clearing house]
                            when (t_visit_payment.visit_payment_sub_hospital=b_site.b_visit_office_id) and (r_rp1853_instype.maininscl in ('UCS','WEL')) and (b_site.site_name like 'ศูนย์%')
                                      then '6' --เงื่อนไขคือ ถ้าเป็นศูนย์บริการสาธารณสุข ถึงจะมี OPTYPE=6
		            -- Case OPTYPE=9  [Thai herb]
                            when (r_rp1853_instype.maininscl in ('UCS','WEL')) and  
                                      ((t_diag_icd10.diag_icd10_number like 'U5%' or t_diag_icd10.diag_icd10_number like 'U6%' or t_diag_icd10.diag_icd10_number like 'U7%') 
                                           or (replace(t_diag_icd9.diag_icd9_icd9_number,'.','') in ('1007700','1007713','1007810','1007811','1007812','1007818','1007819','1547700','1547713',
                                                                                                    '1547810','1547811','1547812','1547818','1547819','3027713','4007713','4007810','4007811',
                                                                                                    '4007812','4007818','4007819','5907700','5907713','5907810','5907811','5907812','5907818',
                                                                                                    '5907819','7217700','7217713','7217810','7217811','7217812','7217818','7217819','7227700',
                                                                                                    '7227713','7227810','7227811','7227812','7227818','7227819','7247700','7247713','7247810',
                                                                                                    '7247811','7247812','7247818','7247819','7257700','7257713','7257810','7257811','7257812',
                                                                                                    '7257818','7257819','7267700','7267713','7267810','7267811','7267812','7267818','7267819',
                                                                                                    '8717700','8717713','8717810','8717811','8717812','8717818','8717819','8727700','8727713',
                                                                                                    '8727810','8727811','8727812','8727818','8727819','8737700','8737713','8737810','8737811',
                                                                                                    '8737812','8737818','8737819','8747700','8747713','8747811','8747812','8747818','8747819',
                                                                                                    '8757700','8757713','8757810','8757811','8757812','8757818','8757819','8767700','8767713',
                                                                                                    '8767810','8767811','8767812','8767818','8767819','9007700','9007712','9007713','9007730',
                                                                                                    '9007810','9007811','9007812','9007818','9007819','9997700','9997713','9997810','9997811',
                                                                                                    '9997812','9997818','9997819','1007701','1007714','1007820','1007821','1007822','1547701',
                                                                                                    '1547714','1547820','1547821','1547822','3027714','4007714','4007820','4007821','4007822',
                                                                                                    '5907701','5907714','5907820','5907821','5907822','7217701','7217714','7217820','7217821',
                                                                                                    '7217822','7227701','7227714','7227820','7227821','7227822','7247701','7247714','7247820',
                                                                                                    '7247821','7247822','7257701','7257714','7257820','7257821','7257822','7267701','7267714',
                                                                                                    '7267820','7267821','7267822','8717701','8717714','8717820','8717821','8717822','8727701',
                                                                                                    '8727714','8727820','8727821','8727822','8737701','8737714','8737820','8737821','8737822',
                                                                                                    '8747701','8747714','8747820','8747821','8747822','8757701','8757714','8757820','8757821',
                                                                                                    '8757822','8767701','8767714','8767820','8767821','8767822','9007701','9007714','9007820',
                                                                                                    '9007821','9007822','9997701','9997714','9997820','9997821','9997822','9007715','9007716',
                                                                                                    '9007800','9007802','9007713','9007714','9007716','9007712','9007730')
                                                                                                ) 
                                             or  (select count(*)
					          from t_order 
						      INNER JOIN b_item on (b_item.b_item_id=t_order.b_item_id )
						  where t_order.t_visit_id=t_visit.t_visit_id
						       and ((t_order.f_order_status_id <> '0') and (t_order.f_order_status_id <> '3')) 
						       and b_item.b_item_subgroup_id = '1300000000050')>=1) then '9'
                           -- Case OPTYPE=7  [Individual]
                           else '7' end as OPTYPE
                     ,t_visit.f_visit_service_type_id as TYPEIN
                     ,(case when (t_visit.f_visit_opd_discharge_status_id in ('51','53') or t_visit.f_visit_ipd_discharge_type_id in ('1','5')) then '1' 
                                when (t_visit.f_visit_opd_discharge_status_id in ('54') or t_visit.f_visit_ipd_discharge_type_id in ('4')) then '3' 
                                when (t_visit.f_visit_opd_discharge_status_id in ('52','56') or t_visit.f_visit_ipd_discharge_type_id in ('8','9')) then '4' 
                                when (t_visit.f_visit_opd_discharge_status_id in ('55')) then '5' 
                                when (t_visit.f_visit_ipd_discharge_type_id in ('2')) then '7' 
                                when (t_visit.f_visit_ipd_discharge_type_id in ('3')) then '8' 
                                end)  as TYPEOUT
                     ,r_rp1853_instype.maininscl
                     ,b_visit_office.visit_office_changwat
                     ,t_diag_icd10.diag_icd10_number
                     ,t_diag_icd9.diag_icd9_icd9_number
                     ,t_opbkk_claim.claim_code 
                     ,t_visit_vital_sign.visit_vital_sign_blood_presure
                     ,t_visit_vital_sign.visit_vital_sign_temperature
                     ,t_visit_vital_sign.visit_vital_sign_heart_rate
                     ,t_visit_vital_sign.visit_vital_sign_respiratory_rate
                FROM  t_visit
                    INNER JOIN t_patient  ON (t_patient.t_patient_id = t_visit.t_patient_id)
                    inner join t_person on t_person.t_person_id = t_patient.t_person_id
                    left join t_person_foreigner ON t_person.t_person_id = t_person_foreigner.t_person_id
                    LEFT JOIN t_visit_payment ON (t_visit_payment.t_visit_id = t_visit.t_visit_id and t_visit_payment.visit_payment_active = '1'
                        and t_visit_payment.visit_payment_priority = '0')
                    INNER JOIN t_billing_invoice_item ON (t_visit.t_visit_id = t_billing_invoice_item.t_visit_id AND t_billing_invoice_item.billing_invoice_item_active='1' ) 
                    inner JOIN t_order ON (t_order.t_order_id = t_billing_invoice_item.t_order_item_id  and t_billing_invoice_item.billing_invoice_item_active='1')
                    inner join b_item ON b_item.b_item_id = t_order.b_item_id
                    LEFT JOIN b_contract_plans ON t_visit_payment.b_contract_plans_id = b_contract_plans.b_contract_plans_id
                    LEFT JOIN r_rp1853_instype ON b_contract_plans.r_rp1853_instype_id = r_rp1853_instype.id
                    LEFT JOIN t_diag_icd10  ON (t_diag_icd10.diag_icd10_vn = t_visit.t_visit_id AND t_diag_icd10.f_diag_icd10_type_id = '1')
                    LEFT JOIN t_diag_icd9  ON (t_visit.t_visit_id = t_diag_icd9.diag_icd9_vn and t_diag_icd9.f_diagnosis_operation_type_id='1' )
                    LEFT JOIN t_accident  ON (t_accident.t_visit_id = t_visit.t_visit_id)
                    LEFT JOIN t_visit_refer_in_out  ON (t_visit_refer_in_out.t_visit_id = t_visit.t_visit_id)
                    LEFT JOIN b_visit_office on t_visit_refer_in_out.visit_refer_in_out_refer_hospital = b_visit_office.b_visit_office_id
                    LEFT JOIN b_report_12files_map_clinic  ON (t_diag_icd10.b_visit_clinic_id = b_report_12files_map_clinic.b_visit_clinic_id)
                    left join (select distinct on (t_visit_id) t_visit_id,visit_vital_sign_blood_presure,visit_vital_sign_temperature,visit_vital_sign_heart_rate,visit_vital_sign_respiratory_rate
				from t_visit_vital_sign
				where visit_vital_sign_blood_presure <> ''
		       order by t_visit_id,record_time desc) t_visit_vital_sign on t_visit_vital_sign.t_visit_id = t_visit.t_visit_id 
                    left join (select t_opbkk_claim.t_visit_id,t_opbkk_claim.claim_code 
										from t_opbkk_claim
									inner join (select t_visit_id,max(record_datetime) as max_date from t_opbkk_claim group by t_visit_id) 
									cut_vn_dup on t_opbkk_claim.record_datetime = cut_vn_dup.max_date ) t_opbkk_claim on t_visit.t_visit_id = t_opbkk_claim.t_visit_id  -- cut visit_id dup in table claimcode
                     left join (select t_visit_primary_symptom.t_visit_id as t_visit_id,array_to_string(array_agg(t_visit_primary_symptom.visit_primary_symptom_main_symptom),' , ') as main_symptom
                                from  t_visit_primary_symptom
                                where t_visit_primary_symptom.visit_primary_symptom_active = '1'
                                group by t_visit_primary_symptom.t_visit_id) as symptom   on t_visit.t_visit_id = symptom.t_visit_id,
                   b_site
                WHERE   t_visit.f_visit_status_id = '3'--1=เข้าสู่กระบวนการ, 2=ค้างบันทึก, 3=จบกระบวนการ, 4=ยกเลิกการเข้ารับบริการ
                      and t_visit_payment.visit_payment_active='1'
                      and t_person.active = '1'
                      --and t_visit.visit_vn ='06400204'
                      AND t_visit.visit_begin_visit_time::date between '2020-01-01'::date and '2020-01-10'::date 
                 --  {0} {1}
                ) sq
                --where sq.optype <>'99' -- ใช้งานส่งให้ต๋ง ได้ โดยเอาเฉพาะที่อยู่ใน Case optype เท่านั้นหากเป็น = 99 จะเป็นข้อมูลที่ไม่อยู่ในเงื่อนไขของ OPBKK CLAIM
) qr1
ORDER  BY  qr1.HN,qr1.CLINIC,qr1.DATEOPD
----opd 22/09/2560 14:33
----22/09/2560 14:33 แก้ไขเพิ่ม เงื่อนไข ให้ t_diag_icd10.diag_icd10_active = '1'
----28/11/2560 12:33 เพิ่ม btemp,sbp,dbp,pr,rr
----19/01/2561 11:15 แก้ไข btemp,sbp,dbp,pr,rr ให้ดึง v/s มาหมด
----23/06/2562 18.37 แก้ไข OPTYPE5 Dental yaya
----opd 30/10/2563 14:33 by eakachai > add field claim_code 
----opd 11/11/2563 14:33 by eakachai > add Cut cancle claimcode
----opd 11/01/2564 by yaya cancel claim_code is not null
-- opd 22/06/2564 by eakachai get all row table claimcode
-- opd 29/07/2564 by eakachai add colunm  btemp,sbp,dbp,pr,rr (colunm hide)