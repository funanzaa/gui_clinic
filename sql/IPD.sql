--IPD
select t_visit.visit_hn as "HN"
,'' as "AN"
,'' as "DATEADM"
,'' as "TIMEADM"
,'' as "DATEDSC" 
,''as "TIMEDSC"
,'' as "DISCHS" 
,''as "DISCHT" 
, '' as "WARDDSC"
,'' as "DEPT"
,'' as "ADM_W"
,'' as "UUC"
,'' as "SVCTYPE"
from t_visit 
where t_visit.visit_hn  = 'xxxx'