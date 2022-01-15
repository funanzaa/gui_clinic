--AER ข้อมูลอุบัติเหตุ ฉุกเฉิน และรับส่งเพื่อรักษา
select q1.hn as "HN"
, '' as "AN"
,q1.dateopd as "DATEOPD",
q1.claim_code as "AUTHAE",
             -- q1.authae,
q1.aedate as "AEDATE"
,q1.aetime as "AETIME"
,q1.aetype as "AETYPE"
,'' as "AESTATUS" -- add 
, '' as "DALERT"
, '' as "TALERT"
,(case when (q1.refer_no is not null) then q1.refer_no else '' end) as "RERER_NO",
              (case when (q1.refmaini is not null) then q1.refmaini else '' end) as "REFMAINI",
              (case when (q1.ireftype='0000') then '1100' else (case when (q1.ireftype is not null) then q1.ireftype else ''end) end) as "IREFTYPE",
              (case when (q1.refmaino is not null) then q1.refmaino else '' end) as "REFMAINO",
              q1.oreftype as "OREFTYPE",
              (case when (q1.ucae is not null) then q1.ucae else '' end) as "UCAE", 
               (case when (q1.emtype is not null) then q1.emtype else '' end) as "EMTYPE"
               ,q1.seq  as "SEQ"
from (
            select distinct t_visit.visit_hn as HN
            ,t_opbkk_claim.claim_code as claim_code
                  ,(CASE WHEN (length(t_visit.visit_begin_visit_time)>=10) 
                            THEN to_char(to_date(to_number(substr(t_visit.visit_begin_visit_time,1,4),'9999')-543 || 
                                 substr(t_visit.visit_begin_visit_time,5,6),'yyyy-mm-dd'),'yyyymmdd') 
                             ELSE ''   END) AS  dateopd 
                  ,(case when (t_accident.accident_claim_code is not null) then t_accident.accident_claim_code else '' end) AS authae
                  ,(CASE WHEN (length(t_accident.accident_date)>=10) 
                            then to_char(to_date(to_number(substr(t_accident.accident_date,1,4),'9999')-543 || 
                                 substr(t_accident.accident_date,5,6),'yyyy-mm-dd'),'yyyymmdd')  
                            ELSE''   END) AS  aedate 
                  ,(case when ((substr(t_accident.accident_time,1,2)||substr(t_accident.accident_time,4,2))  is not null) then substr(t_accident.accident_time,1,2)||substr(t_accident.accident_time,4,2) else '' end) as aetime
                  ,(case when ((CASE WHEN (t_accident.accident_accident_type='') 
                            then 'O'    
                            else t_accident.accident_accident_type end) is not null) then (CASE WHEN (t_accident.accident_accident_type='') 
                            then 'O'    
                            else t_accident.accident_accident_type end) else '' end) as aetype
                  ,(CASE WHEN (refer_in.f_visit_refer_type_id = '0') 
                            then (case when (refer_in.visit_refer_in_out_cause is not null) then refer_in.visit_refer_in_out_cause else ''/*refer_in.visit_refer_in_out_number*/ end)
                         WHEN (refer_out.f_visit_refer_type_id = '1')
                            then   refer_out.visit_refer_in_out_number end) as REFER_NO
                ,refer_in.visit_refer_in_out_refer_hospital as refmaini
               ,refer_in.visit_refer_in_out_observe||refer_in.visit_refer_in_out_treatment|| refer_in.visit_refer_in_out_lab || '0' as ireftype
                ,refer_out.visit_refer_in_out_refer_hospital as refmaino
                ,(CASE WHEN (t_visit.f_refer_cause_id='1')
                         then '1000'
                       WHEN (t_visit.f_refer_cause_id='2'
                            or t_visit.f_refer_cause_id='3'
                            or t_visit.f_refer_cause_id='4'
                            or t_visit.f_refer_cause_id='5'
                            or t_visit.f_refer_cause_id='6') 
                        then  '0100'
                       when (t_visit.f_refer_cause_id='7') 
                        then  '0001' 
                       else '0000' end) as oreftype
                 ,t_accident.accident_occur_type as ucae
                 ,t_accident.accident_emergency_type as emtype
                 ,(case when (t_accident.accident_vn is null) then refer_in.visit_refer_in_out_vn else t_accident.accident_vn end) as seq
            from t_visit left join t_accident on (t_visit.t_visit_id=t_accident.t_visit_id)
                      left join t_visit_refer_in_out as  refer_in on  (refer_in.t_visit_id = t_visit.t_visit_id    and refer_in.visit_refer_in_out_active = '1'   and refer_in.f_visit_refer_type_id = '0')
                      left join t_visit_refer_in_out  as refer_out on (refer_out.t_visit_id = t_visit.t_visit_id and refer_out.visit_refer_in_out_active = '1'  and refer_out.f_visit_refer_type_id = '1')
                      left join ( select *
									from (select t_visit_id ,claim_code ,ROW_NUMBER() OVER( PARTITION BY t_visit_id ORDER by t_visit_id desc) as chk_dup
					      					 from t_opbkk_claim where t_opbkk_claim.active = true ) q 
								where q.chk_dup = 1 ) t_opbkk_claim on t_visit.t_visit_id = t_opbkk_claim.t_visit_id -- dup claim code
            where  t_visit.f_visit_type_id <> 'S' 
                         and substring(t_visit.visit_begin_visit_time,1,10) between '2563-09-01' and '2564-10-05'
                         and  (t_accident_id is not null or refer_in.t_visit_refer_in_out_id is not null)
       ) q1 