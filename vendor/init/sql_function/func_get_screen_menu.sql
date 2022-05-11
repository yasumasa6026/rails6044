CREATE OR REPLACE FUNCTION func_get_screen_menu(email text)
 RETURNS TABLE(grp_name text, scr_name text, screen_code text, page_size numeric, contents text, pobject_code_sgrp text)
 LANGUAGE sql
AS $function$
select case  when q.pobjgrp_name is null then s.pobject_code_sgrp else q.pobjgrp_name end as grp_name ,
	case  when x.pobjgrp_name is null then s.pobject_code_scr else x.pobjgrp_name end as scr_name ,
	s.pobject_code_scr screen_code,to_number(split_part(s.screen_rowlist,',',1),'9999') page_size,x.pobjgrp_contents as contents,
        s.pobject_code_sgrp
from r_screens s
      inner join persons on screen_scrlv_id = persons.scrlvs_id and  persons.email = $1
      left join  ( select t.pobject_code,t.pobjgrp_name  from r_pobjgrps t 
			inner join  persons  p on p.usrgrps_id = t.pobjgrp_usrgrp_id and email= $1 and  t.pobject_objecttype ='screen_group') q
        on q.pobject_code = s.pobject_code_sgrp 
      left join  ( select t.pobject_code,t.pobjgrp_name ,t.pobjgrp_contents  from r_pobjgrps t 
			inner join  persons  p on p.usrgrps_id = t.pobjgrp_usrgrp_id and email= $1 and  t.pobject_objecttype ='screen' ) x
        on x.pobject_code = s.pobject_code_scr
where s.pobject_code_sgrp !='#' and s.screen_expiredate > current_date order by  s.pobject_code_sgrp,s.screen_seqno
$function$
;
