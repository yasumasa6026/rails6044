--- prd,pur�p�@cust,shpords�ɂ͎g�p�ł��Ȃ��B
--drop function func_sch_amt_bal  ;
create or replace function 	func_sch_amt_bal(intblname in character varying,intblid in numeric,amt_total out numeric)
 RETURNS numeric
as $func$

DECLARE		
	src_tblname  character varying;
	src_tblid numeric;		
	tbl_name  character varying;
	tbl_id numeric;
	amt_src numeric;
	--- amt_total numeric;
	rec_trn record;
	rec_bal record;
	rec_bal_1 record;
	rec_bal_2 record;
	rec_bal_3 record;

	cur_amt CURSOR(intblname character varying,intblid numeric)  FOR 
		select  srctblname,srctblid 
			from srctbllinks where tblname = intblname and tblid = intblid ;
	cur_bal CURSOR(src_tblname character varying,src_tblid numeric)  FOR 
		select  tblname,tblid 
			from linktbls where srctblname = src_tblname and srctblid = src_tblid
			group by tblname,tblid  ;

	cur_bal_1 CURSOR(src_tblname character varying,src_tblid numeric)  FOR 
		select  tblname,tblid 
			from linktbls where srctblname = src_tblname and srctblid = src_tblid
			group by tblname,tblid  ;
	cur_bal_2 CURSOR(src_tblname character varying,src_tblid numeric)  FOR 
		select  tblname,tblid 
			from linktbls where srctblname = $1 and srctblid = $2
			group by tblname,tblid  ;
	cur_bal_3 CURSOR(src_tblname character varying,src_tblid numeric)  FOR 
		select  tblname,tblid 
			from linktbls where srctblname = $1 and srctblid = $2
			group by tblname,tblid ;
BEGIN	
	amt_total := 0.0;
		
	for rec_amt in cur_amt(intblname,intblid) loop
		for rec_bal in cur_bal(rec_amt.srctblname,rec_amt.srctblid) loop
			if rec_bal.tblname like '%acts' 
		 	 then	EXECUTE $$
		 				select amt  from $$||rec_bal.tblname||$$
		 						where id = $$||rec_bal.tblid||$$  $$
					into amt_src;
					amt_total := amt_total + amt_src;
				else  ---insts,dlvs,rely
					for rec_bal_1 in cur_bal_1(rec_bal.tblname,rec_bal.tblid) loop
		 				if rec_bal_1.tblname like '%acts' 
		 					then EXECUTE $$
		 					select amt  from $$||rec_bal_1.tblname||$$
		 						where id = $$||rec_bal_1.tblid||$$ $$
								into amt_src;
							amt_total := amt_total + amt_src;	 
						else  ---dlvs,rely
							for rec_bal_2 in cur_bal_2(rec_bal_1.tblname,rec_bal_1.tblid) loop
		 						if rec_bal_2.tblname like '%acts' 
		 							then EXECUTE $$
		 								select amt  from $$||rec_bal_2.tblname||$$
		 									where id = $$||rec_bal_2.tblid||$$ $$
												into amt_src;
												amt_total := amt_total + amt_src;  
								else  ---dlvs
									for rec_bal_3 in cur_bal_3(rec_bal_2.tblname,rec_bal_2.tblid) loop
		 								if rec_bal_3.tblname like '%acts' 
		 									then EXECUTE $$
		 										select amt  from $$||rec_bal_3.tblname||$$
		 											where id = $$||rec_bal_3.tblid||$$ $$
											into amt_src;
											amt_total := amt_total + amt_src;
										end if;
									end loop;
								end if;
							end loop; 
						end if;
					end loop;		  
				end if;
			end loop;	
		end loop;		

end;
$func$  LANGUAGE plpgsql ;






		
	
