--- Žg—p‚µ‚È‚¢
CREATE OR REPLACE FUNCTION public.func_get_cust_stk(custords_id numeric, OUT qty_stk numeric)
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
	and trn.orgtblname = ''custords'' and trn.orgtblid = $1
	and pare.orgtblname = ''custords'' and trn.orgtblid = $1
	and trn.paretblname = ''custords'' and trn.paretblid = $1
	and pare.paretblname = ''custords'' and pare.orgtblid = $1
	group by pare.srctblid
 '
   INTO qty_stk
   USING  custords_id;
END
$function$
;
