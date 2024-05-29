--- prd,pur�p�@cust,shpords�ɂ͎g�p�ł��Ȃ��B
drop function func_ord_amt_bal;
create or replace function 
	func_ord_amt_bal(tblname text,tblid numeric,OUT amt_bal numeric)
as $func$
BEGIN	
  EXECUTE 'select 	  sum(amt_src)  amt_bal   from srctbllinks
	where  srctblname = $1 and srctblid = $2
	and  (srctblname != tblname or  srctblid != tblid)
	group by srctblname,srctblid '
   INTO  amt_bal
   USING  tblname,tblid;
END
$func$  LANGUAGE plpgsql;
	