
drop function func_get_cust_stk;
create or replace function 
	func_get_cust_stk(custords_id numeric,OUT qty_stk numeric)
as $func$
BEGIN	
  EXECUTE 'select 	qty_stk from trngantts
	where orgtblname = paretblname and orgtblid = paretblid  
	and (tblname != paretblname or tblid != paretblid)
	and orgtblid = ''custords'' and tblid = $1
 '
   INTO qty_stk
   USING  custords_id;
END
$func$  LANGUAGE plpgsql;
	