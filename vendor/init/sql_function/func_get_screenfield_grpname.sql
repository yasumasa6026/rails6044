CREATE OR REPLACE FUNCTION public.func_get_screenfield_grpname(email text, screen_code text)
 RETURNS TABLE(screenfield_name text, screenfield_hideflg numeric, screenfield_editable numeric, screenfield_indisp numeric, pobject_code_scr text, 
 screenfield_width numeric, screen_strwhere text, screen_strorder text, screen_strgrouporder text, screen_rows_per_page numeric, screen_rowlist text, 
 screenfield_type text, screenfield_dataprecision numeric, screenfield_datascale numeric, pobject_objecttype_sfd text, contents text, pobject_code_sfd text,
 screenfield_edoptvalue text,screenfield_tblfield_id numeric,screenfield_pobject_id_sfd numeric,screenfield_screen_id numeric)
 LANGUAGE sql
AS $function$
select case when x.name is null then  pobject_code_sfd else x.name  end screenfield_name,
       screenfield_hideflg,screenfield_editable,screenfield_indisp ,pobject_code_scr,screenfield_width,
	screen_strwhere,screen_strorder ,screen_strgrouporder ,
	screen_rows_per_page,screen_rowlist,screenfield_type,screenfield_dataprecision,
	screenfield_datascale,pobject_objecttype_sfd,x.contents,pobject_code_sfd,screenfield_edoptvalue,
	screenfield_tblfield_id,screenfield_pobject_id_sfd ,screenfield_screen_id 
      from r_screenfields s
	left join  ( select t.pobjects_id,t.name,t.contents from pobjgrps t 
				inner join  persons  p on p.usrgrps_id = t.usrgrps_id and email= $1
				where t.expiredate > current_date) x
        on x.pobjects_id = s.screenfield_pobject_id_sfd 
 where pobject_code_scr = $2 and  screenfield_expiredate > current_date and screenfield_selection != 0
        order by screenfield_seqno
$function$
;