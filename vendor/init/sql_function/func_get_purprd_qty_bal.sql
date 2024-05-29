-- DROP FUNCTION public.func_get_purprd_qty_bal(varchar, numeric, numeric);

CREATE OR REPLACE FUNCTION public.func_get_purprd_qty_bal(tblname character varying, tblid numeric, qty_linkto_alloctbl numeric)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
BEGIN	
  EXECUTE 'select 	 sum(qty_linkto_alloctbl) qty_linkto_alloctbl
	from alloctbls 
	where  srctblname = $1 and  srctblid = $2
 	group by srctblid '
   INTO qty_linkto_alloctbl
   USING  tblname,tblid;
END
$function$
;
