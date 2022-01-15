--IOP  
	select '' as "AN"
	,'' as "OPER"
	,'' as "OPTYPE"
	,'' as "DROPID"
	,'' as "DATEIN" 
	,'' as "TIMEIN" 
	,'' as "DATEOUT" 
	,'' as "TIMEOUT" 
from t_visit 
where t_visit.visit_hn  = 'xxxx'