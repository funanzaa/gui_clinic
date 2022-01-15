-- ORF v1.0
SELECT  
	t_patient.patient_hn AS "HN" 
	,(CASE WHEN (length(t_visit.visit_begin_visit_time)>=10)
                then to_char(to_date(to_number(substr(t_visit.visit_begin_visit_time,1,4),'9999')-543 || 
                    substr(t_visit.visit_begin_visit_time,5,6),'yyyy-mm-dd'),'yyyymmdd') 
                ELSE ''   END) AS "DATEOPD"  
    ,(case when (b_report_12files_map_clinic.b_report_12files_std_clinic_id IN ('01','02','03','04','05','06','07','08','09','10','11'))
              then (t_visit.f_visit_type_id || b_report_12files_map_clinic.b_report_12files_std_clinic_id || '00') 
           when b_report_12files_map_clinic.b_report_12files_std_clinic_id is null then ''
              else  (t_visit.f_visit_type_id || '121') end) AS "CLINIC"   
    , t_visit_refer_in_out.visit_refer_in_out_refer_hospital as "REFER"  
    , (CASE WHEN (t_visit_refer_in_out.f_visit_refer_type_id ='1')
                THEN '2' 
                ELSE '1' END) AS "REFERTYPE"
      ,t_visit.visit_vn AS "SEQ"
      ,(CASE WHEN (length(t_visit_refer_in_out.record_date_time)>=10)
                then to_char(to_date(to_number(substr(t_visit_refer_in_out.record_date_time,1,4),'9999')-543 || 
                    substr(t_visit_refer_in_out.record_date_time,5,6),'yyyy-mm-dd'),'yyyymmdd') 
                ELSE ''   END) AS "REFERDATE"  
 --   , t_visit_refer_in_out.record_date_time as REFERDATE
--,t_visit.visit_vn AS SEQ
FROM t_visit_refer_in_out
	INNER JOIN t_visit  on (t_visit.t_visit_id = t_visit_refer_in_out.t_visit_id) 
	LEFT JOIN t_patient ON (t_patient.t_patient_id = t_visit.t_patient_id)  
	LEFT JOIN t_diag_icd10  ON (t_diag_icd10.diag_icd10_vn = t_visit.t_visit_id 
        AND t_diag_icd10.f_diag_icd10_type_id = '1'
        AND t_diag_icd10.diag_icd10_active = '1' ) 
	LEFT JOIN b_report_12files_map_clinic  ON (t_diag_icd10.b_visit_clinic_id = b_report_12files_map_clinic.b_visit_clinic_id)
WHERE    t_visit.f_visit_status_id = '3' 
	AND visit_refer_in_out_active = '1'
	AND t_visit.f_visit_type_id = '0'
	  and substring(t_visit.visit_begin_visit_time,1,10) between {0} and {1}
    and t_visit.f_visit_type_id <> 'S'
