							
drop function  get_alloctbls;

create or replace function get_alloctbls(tablename in regclass,sno in text )
	returns table( itms_id_trn numeric, locas_id_trn numeric,
			parenum numeric, chilnum numeric, processseq_trn numeric,
			paretblname varchar(30),paretblid numeric,orgtblname varchar(30),orgtblid numeric,
			srctblname varchar(30),srctblid numeric,alloc_id numeric,
			starttime timestamp,duedate timestamp,alloc_qty numeric,trngantts_id numeric )
as $func$
BEGIN	
RETURN QUERY 
  EXECUTE 'select   trn.itms_id_trn, trn.locas_id_trn, 
			parenum, chilnum, trn.processseq_trn,
			trn.paretblname,trn.paretblid,trn.orgtblname,trn.orgtblid,
			alloc.srctblname ,alloc.srctblid ,alloc.id alloc_id,
			tbl.starttime,tbl.duedate,
			alloc.qty_linkto_alloctbl alloc_qty,trn.id trngantts_id 
									from alloctbls alloc
									inner join trngantts trn on alloc.trngantts_id = trn.id	
									inner join ' || tablename ||' tbl on alloc.srctblid = tbl.id								
								where	tbl.sno = $1 and alloc.qty_linkto_alloctbl > 0 '
   USING sno;
END
$func$  LANGUAGE plpgsql;

/*
 * https://qiita.com/17ec084/items/197a505704b2b44d8067
 */




create or replace function reverse_alloctbls(tablename in regclass,sno in text )
		returns table( itm_code_trn varchar(30),itm_name_trn varchar(30), loca_code_trn varchar(30),loca_name_trn varchar(30),
			itm_code_org varchar(30),itm_name_org varchar(30), loca_code_org varchar(30),loca_name_org varchar(30),
			parenum numeric, chilnum numeric, processseq_trn numeric,
			paretblname varchar(30),paretblid numeric,orgtblname varchar(30),orgtblid numeric,sno_org varchar(30),cno_org varchar(30),
			starttime timestamp,duedate timestamp,duedate_org timestamp,alloc_qty numeric,alloctbls_id numeric,id numeric )
as $func$
DECLARE	
	rec_trn record;
	rec_org record;
	cur_trns CURSOR  FOR 
		SELECT g.orgtblname ,g.orgtblid ,g.parenum,g.chilnum,g.processseq_trn,g.starttime,g.duedate,g.trngantts_id,
			g.alloc_qty,g.alloc_id alloctbls_id FROM get_alloctbls(tablename,sno) g;
BEGIN	
	for rec_trn in cur_trns loop
		 EXECUTE $$
		 	select   
		 		itm_trn.code itm_code_trn, loca_trn.code loca_code_trn, 
		 		itm_trn.name itm_name_trn, loca_trn.name loca_name_trn, 
		 		itm_org.code itm_code_org, loca_org.code loca_code_org, 
		 		itm_org.name itm_name_org, loca_org.name loca_name_org, 
				trn.orgtblname,org.sno sno_org,org.cno cno_org,org.duedate duedate_org
			from trngantts trn 
				inner join $$||rec_trn.orgtblname||$$ org on org.id = trn.orgtblid and trn.id = $$||rec_trn.trngantts_id||$$
				inner join itms itm_trn on itm_trn.id =  trn.itms_id_trn 
				inner join itms itm_org on itm_org.id =  trn.itms_id_org 
				inner join locas loca_trn on loca_trn.id =  trn.locas_id_trn 
				inner join locas loca_org on loca_org.id =  trn.locas_id_org $$ 
			into rec_org 					 
			using rec_trn.trngantts_id;
		
			itm_code_trn := rec_org.itm_code_trn;
			itm_name_trn := rec_org.itm_name_trn; 
			loca_code_trn := rec_org.loca_code_trn;
			loca_name_trn := rec_org.loca_name_trn;
			itm_code_org  := rec_org.itm_code_org;
			itm_name_org := rec_org.itm_name_org;
			loca_code_org  := rec_org.loca_code_org;
			loca_name_org  := rec_org.loca_name_org;
			parenum := rec_trn.parenum;
			chilnum := rec_trn.chilnum;
			processseq_trn := rec_trn.processseq_trn;
			orgtblname := rec_trn.orgtblname;
			starttime := rec_trn.starttime;
			duedate := rec_trn.duedate;
			duedate_org := rec_org.duedate_org;
			sno_org := rec_org.sno_org;
			cno_org := rec_org.cno_org;
			alloc_qty := rec_trn.alloc_qty;
			alloctbls_id := rec_trn.alloctbls_id;
			id := rec_trn.alloctbls_id;
			return next;
	end loop;
	
end;
$func$  LANGUAGE plpgsql;





