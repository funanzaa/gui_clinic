select q1.hn,q1.dateopd,
              q1.authae,q1.aedate,q1.aetime,q1.aetype,
              (case when (q1.refer_no is not null) then q1.refer_no else '' end) as refer_no,
              (case when (q1.refmaini is not null) then q1.refmaini else '' end) as refmaini,
              (case when (q1.ireftype='0000') then '1100' else (case when (q1.ireftype is not null) then q1.ireftype else ''end) end) as ireftype,
              (case when (q1.refmaino is not null) then q1.refmaino else '' end) as refmaino,
              q1.oreftype,
              (case when (q1.ucae is not null) then q1.ucae else '' end) as ucae, 
               (case when (q1.emtype is not null) then q1.emtype else '' end) as emtype,q1.seq 
from (select distinct t_visit.visit_hn as HN
                  ,(CASE WHEN t_visit.visit_begin_visit_time is not null
                            THEN to_char(t_visit.visit_begin_visit_time,'yyyymmdd') 
                             ELSE ''   END) AS  dateopd 
                  ,(case when (t_accident.accident_claim_code is not null) then t_accident.accident_claim_code else '' end) AS authae
                  ,(CASE WHEN t_accident.accident_date is not null
                            then to_char(t_accident.accident_date,'yyyymmdd')  
                            ELSE''   END) AS  aedate 
                  ,(case when (t_accident.accident_time is not null) then to_char(t_accident.accident_date,'HH24MI')  else '' end) as aetime
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
            where  t_visit.f_visit_type_id <> 'S' 
                          --and t_visit.visit_vn='05609611'
                          --and substring(t_visit.visit_begin_visit_time,1,10) between '2014010100' and '2014011000'
                         --{0} {1}
                         and  (t_accident_id is not null or refer_in.t_visit_refer_in_out_id is not null)
       ) q1