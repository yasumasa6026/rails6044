drop function func_get_custord_stk_qty ; 
create or replace function  func_get_custord_stk_qty( custord_id numeric)
		returns table( itm_code varchar(30),itm_name varchar(50), loca_code varchar(30),loca_name varchar(50),
			 			shelfno_code varchar(30),shelfno_name varchar(50),lotno varchar(50),packno varchar(10),
			 			shelfnos_id numeric,locas_id numeric,
							qty_sch numeric,qty numeric,qty_stk numeric )
as $func$
DECLARE	
	rec_trn record;
	rec_org record;
	cur_trns CURSOR(custord_id numeric)  FOR 
			select a.srctblname,a.srctblid,a.qty_linkto_alloctbl alloc_qty from trngantts t
				inner join alloctbls a on a.trngantts_id = t.id and qty_linkto_alloctbl > 0
				where orgtblname = paretblname and paretblname != tblname and orgtblname = 'custords'
				and (orgtblid = paretblid or paretblid != tblid) and  orgtblid = custord_id
		union select a.srctblname,a.srctblid,a.qty_linkto_alloctbl from trngantts t
				inner join alloctbls a on a.trngantts_id = t.id and qty_linkto_alloctbl > 0
				inner join (select custsch.* from trngantts custsch 
									inner join linkcusts l on l.trngantts_id = custsch.id 
									where l.srctblname = 'custschs' and l.tblname = 'custords' and l.tblid = custord_id ) sch
						on t.orgtblname = sch.orgtblname  and t.paretblname = sch.paretblname
						and t.orgtblid = sch.orgtblid  and t.paretblid = sch.paretblid
				where  t.paretblname != t.tblname or t.paretblid != t.tblid ;
BEGIN	
	for rec_trn in cur_trns(custord_id) loop
		 EXECUTE $$
		 	select   
		 		ope.itm_code, shelf.loca_code, shelf.shelfno_code,
				shelf.shelfnos_id,shelf.locas_id,
		 		ope.itm_name, shelf.loca_name, shelf.shelfno_name,
				tbl.lotno,tbl.packno
			from $$||rec_trn.srctblname||$$ tbl
			inner join (select itm.code itm_code,itm.name itm_name,ope.id id
							from opeitms ope
							inner join itms itm on itm.id = ope.itms_id) ope
						on ope.id = tbl.opeitms_id
			inner join (select s.code shelfno_code,s.name shelfno_name,l.code loca_code,l.name loca_name,s.id shelfnos_id,l.id locas_id 
												from shelfnos s
												inner join locas l on l.id = s.locas_id_shelfno) shelf
						on shelf.shelfnos_id = tbl.shelfnos_id_to
			where tbl.id = $$||rec_trn.srctblid||$$ $$
			into rec_org 					 
			using rec_trn.srctblname,rec_trn.srctblid;
		
			itm_code := rec_org.itm_code;
			itm_name := rec_org.itm_name; 
			loca_code := rec_org.loca_code;
			loca_name := rec_org.loca_name;
			locas_id := rec_org.locas_id;
			shelfno_code := rec_org.shelfno_code;
			shelfno_name := rec_org.shelfno_name;
			shelfnos_id := rec_org.shelfnos_id;
			lotno := rec_org.lotno;
			packno := rec_org.packno;
			case  rec_trn.srctblname
			when   'prdschs' then 
					qty_sch := rec_trn.alloc_qty;
					qty := 0;
					qty_stk := 0;
			when   'purschs' then 
					qty_sch := rec_trn.alloc_qty;
					qty := 0;
					qty_stk := 0;
			when   'prdacts' then 
					qty_sch := 0;
					qty := 0;
					qty_stk := rec_trn.alloc_qty;
			when   'puracts' then
					qty_sch := 0;
					qty := 0;
					qty_stk := rec_trn.alloc_qty; 
			else
					qty_sch := 0;
					qty := rec_trn.alloc_qty;
					qty_stk := 0;
			end case;
			return next;
	end loop;
	
end;
$func$  LANGUAGE plpgsql;