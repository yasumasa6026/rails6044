 drop function public.func_get_custxxxs_qty_bal cascade;
CREATE OR REPLACE FUNCTION public.func_get_custxxxs_qty_bal(tblname text, id numeric, OUT qty_bal numeric)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
BEGIN	
  EXECUTE 'select 	sum(qty_src)  qty_bal
 from linkcusts
	where  tblname = $1 and tblid = $2 and (srctblname != tblname or srctblid != tblid)
	group by tblname,tblid '
   INTO qty_bal
   USING  tblname,id;
END
$function$
;
