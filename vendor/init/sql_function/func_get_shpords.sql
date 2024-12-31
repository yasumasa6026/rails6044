 CREATE OR REPLACE FUNCTION public.func_get_shpords(tblname text,tblid numeric)
 RETURNS TABLE(itms_id numeric, processseq numeric,prjnos_id numeric,chrgs_id_trn numeric,
			consumtype character varying,parenum numeric,chilnum numeric ,consumunitqty numeric,
			consumminqty numeric,consumchgoverqty numeric,shelfnos_id_pare numeric,   ---親作業場所
								 shelfnos_id_to numeric,   ---子の保管先
								units_id_case_shp numeric,consumauto character ,shpordauto character,
                  qty_sch numeric,qty numeric, qty_stk numeric)
 LANGUAGE plpgsql
AS $function$
BEGIN
	RETURN QUERY
	 EXECUTE ' select t.itms_id_trn itms_id,t.processseq_trn processseq,
								t.prjnos_id,t.chrgs_id_trn,
								t.consumtype,t.parenum,t.chilnum,t.consumunitqty,t.consumminqty,t.consumchgoverqty,
								t.shelfnos_id_pare,   ---親作業場所
								t.shelfnos_id_to_trn shelfnos_id_to,   ---子の保管先
								ope.units_id_case_shp,ope.consumauto,ope.shpordauto,
               --- alloc.srctblname ,alloc.srctblid,
                  sum(alloc.qty_linkto_alloctbl) qty_sch,0 qty,0 qty_stk  from trngantts t
              inner join (select pare.*	from trngantts pare
							                  inner join alloctbls alloc on alloc.trngantts_id = pare.id 
							                  where alloc.srctblname =  '||'''$1'''||' and  alloc.srctblid = $2	
                                and alloc.qty_linkto_alloctbl  > 0) p
                              on p.orgtblname = t.orgtblname and p.orgtblid = t.orgtblid 
                              and p.tblname = t.paretblname and p.tblid = t.paretblid 
                              and p.paretblname != t.paretblname and p.paretblid != t.paretblid   
							inner join opeitms ope on t.itms_id_trn = ope.itms_id and t.processseq_trn = ope.processseq
											and t.shelfnos_id_trn = ope.shelfnos_id_opeitm
							inner join alloctbls alloc on alloc.trngantts_id = t.id and alloc.qty_linkto_alloctbl  > 0    
							where not exists(select 1 from shpords s where paretblname =  '||'''$1'''||' and  paretblid = $2
																and s.qty > 0	)		
              and alloc.srctblname like '||'''%schs'''||'
              group by t.itms_id_trn ,t.processseq_trn ,	t.prjnos_id,t.chrgs_id_trn,
								t.consumtype,t.parenum,t.chilnum,t.consumunitqty,t.consumminqty,t.consumchgoverqty,
								t.shelfnos_id_pare, t.shelfnos_id_to_trn ,  ope.units_id_case_shp,ope.consumauto,ope.shpordauto	
          union
            select t.itms_id_trn itms_id,t.processseq_trn processseq,
								t.prjnos_id,t.chrgs_id_trn,
								t.consumtype,t.parenum,t.chilnum,t.consumunitqty,t.consumminqty,t.consumchgoverqty,
								t.shelfnos_id_pare,   ---親作業場所
								t.shelfnos_id_to_trn shelfnos_id_to,   ---子の保管先
								ope.units_id_case_shp,ope.consumauto,ope.shpordauto,
               --- alloc.srctblname ,alloc.srctblid,
                  0 qty_sch,sum(alloc.qty_linkto_alloctbl)  qty,0 qty_stk  from trngantts t
              inner join (select pare.*	from trngantts pare
							                  inner join alloctbls alloc on alloc.trngantts_id = pare.id 
							                  where alloc.srctblname =  '||'''$1'''||' and  alloc.srctblid = $2	
                                and alloc.qty_linkto_alloctbl  > 0) p
                              on p.orgtblname = t.orgtblname and p.orgtblid = t.orgtblid 
                              and p.tblname = t.paretblname and p.tblid = t.paretblid   
                              and (p.paretblname != t.paretblname or p.paretblid != t.paretblid ) 
							inner join opeitms ope on t.itms_id_trn = ope.itms_id and t.processseq_trn = ope.processseq
											and t.shelfnos_id_trn = ope.shelfnos_id_opeitm
							inner join alloctbls alloc on alloc.trngantts_id = t.id and alloc.qty_linkto_alloctbl  > 0    
							where not exists(select 1 from shpords s where paretblname =  '||'''$1'''||' and  paretblid = $2
																and s.qty > 0	)		
              and (alloc.srctblname like '||'''%ords'''||' or alloc.srctblname like '||'''%insts'''||' or alloc.srctblname like '||'''%reply'''||')  
              group by t.itms_id_trn ,t.processseq_trn ,	t.prjnos_id,t.chrgs_id_trn,
								t.consumtype,t.parenum,t.chilnum,t.consumunitqty,t.consumminqty,t.consumchgoverqty,
								t.shelfnos_id_pare, t.shelfnos_id_to_trn ,  ope.units_id_case_shp,ope.consumauto,ope.shpordauto	
          union 
            select t.itms_id_trn itms_id,t.processseq_trn processseq,
								t.prjnos_id,t.chrgs_id_trn,
								t.consumtype,t.parenum,t.chilnum,t.consumunitqty,t.consumminqty,t.consumchgoverqty,
								t.shelfnos_id_pare,   ---親作業場所
								t.shelfnos_id_to_trn shelfnos_id_to,   ---子の保管先
								ope.units_id_case_shp,ope.consumauto,ope.shpordauto,
               --- alloc.srctblname ,alloc.srctblid,
                  0 qty_sch,0 qty,sum(alloc.qty_linkto_alloctbl)  qty_stk  from trngantts t
              inner join (select pare.*	from trngantts pare
							                  inner join alloctbls alloc on alloc.trngantts_id = pare.id 
							                  where alloc.srctblname =  '||'''$1'''||' and  alloc.srctblid = $2	
                                and alloc.qty_linkto_alloctbl  > 0) p
                              on p.orgtblname = t.orgtblname and p.orgtblid = t.orgtblid 
                              and p.tblname = t.paretblname and p.tblid = t.paretblid   
                              and (p.paretblname != t.paretblname or p.paretblid != t.paretblid ) 
							inner join opeitms ope on t.itms_id_trn = ope.itms_id and t.processseq_trn = ope.processseq
											and t.shelfnos_id_trn = ope.shelfnos_id_opeitm
							inner join alloctbls alloc on alloc.trngantts_id = t.id and alloc.qty_linkto_alloctbl  > 0    
							where not exists(select 1 from shpords s where paretblname =  '||'''$1'''||' and  paretblid = $2
																and s.qty > 0	)		
              and (alloc.srctblname like '||'''%acts'''||' or alloc.srctblname like '||'''%dlvs'''||' )  
              group by t.itms_id_trn ,t.processseq_trn ,	t.prjnos_id,t.chrgs_id_trn,
								t.consumtype,t.parenum,t.chilnum,t.consumunitqty,t.consumminqty,t.consumchgoverqty,
								t.shelfnos_id_pare, t.shelfnos_id_to_trn ,  ope.units_id_case_shp,ope.consumauto,ope.shpordauto	'
              
using tblname ,tblid ;

END
$function$
;