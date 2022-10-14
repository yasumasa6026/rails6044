
--- custords��custschs���������Ă������l��
CREATE OR REPLACE FUNCTION public.func_get_custord_stk(custords_id numeric, OUT qty_stk numeric)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
BEGIN	
  EXECUTE 'select 	sum(trn.qty_stk) from trngantts trn
			inner join (select * from trngantts t 
								inner join alloctbls a on t.id = a.trngantts_id  
							where a.srctblname = ''custords'' and a.srctblid = $1)
						pare on trn.orgtblname = pare.orgtblname and  trn.orgtblid = pare.orgtblid  
							and trn.paretblname = pare.paretblname and  trn.paretblid = pare.paretblid  
	where trn.mlevel = ''1'' and pare.mlevel = ''0''
	group by pare.srctblid
 '
   INTO qty_stk
   USING  custords_id;
END
$function$
;
