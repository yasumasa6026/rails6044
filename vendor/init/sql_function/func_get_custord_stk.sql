
--- custords‚ªcustschs‚ğˆø‚«“–‚Ä‚½‚àl—¶
CREATE OR REPLACE FUNCTION public.func_get_custord_stk(custords_id numeric, OUT qty_stk numeric)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
BEGIN	
  EXECUTE 'select sum(qty_stk) qty_stk from  (select orgtblid custord_id, qty_stk  from trngantts 
								where orgtblname = ''custords'' and orgtblid = $1
                               and paretblname = ''custords'' and paretblid = $1
                               and mlevel = ''1''
union                               
select link.tblid custord_id,case when trn.qty_stk > link.qty_src then link.qty_src
			else trn.qty_stk end qty_stk from trngantts trn
			inner join linkcusts link on link.srctblname = trn.orgtblname  and link.srctblid = trn.orgtblid
									and  link.srctblname = trn.paretblname  and link.srctblid = trn.paretblid
			where trn.mlevel = ''1'' and link.tblname = ''custords'' and  link.tblid = $1 
union                               			
select link.srctblid custord_id,(link.qty_src * -1) qty_stk from linkcusts link
			where link.srctblname = ''custords'' and  link.srctblid = $1 ) custord
group by custord_id
 '
   INTO qty_stk
   USING  custords_id;
END
$function$
;
