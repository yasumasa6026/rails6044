 DROP FUNCTION  IF exists public.func_get_free_ord_stk_v1(varchar, numeric, numeric, numeric,numeric);
CREATE OR REPLACE FUNCTION public.func_get_free_ord_stk_v1(induedate character varying, inprjnos_id numeric, initms_id numeric, inprocessseq numeric,inshelfnos_id numeric)
 RETURNS TABLE(tblname character varying, tblid numeric, priority integer,  starttime timestamp without time zone, duedate timestamp without time zone, 
 				processseq numeric, mlevel numeric, itms_id numeric, shelfnos_id numeric,locas_id_shelfno numeric,locas_id_alloc numeric,
 				prjnos_id numeric, trngantts_id numeric, alloctbls_id numeric, qty numeric,
 				qty_stk numeric, qty_linkto_alloctbl numeric, shelfnos_id_to numeric,
 				update_ip character varying, updated_at timestamp without time zone)
 LANGUAGE plpgsql
AS $function$
BEGIN
	RETURN QUERY
	 EXECUTE 'select   ---  free　を求めるsql
						alloc.srctblname tblname,alloc.srctblid tblid,
	 	 				case
	 	 				when alloc.srctblname like '||'''%dlvs'''||'
	 	 					then 2
	 	 				when alloc.srctblname like '||'''%acts'''||'
	 	 					then 2 
	 	 				when  gantt.duedate_trn >  (current_date - cast((case gantt.unitofduration when '||'''Day '''||' then gantt.duration else gantt.duration / 24 end ) as integer )) 
	 	 					then 9	
	 	 				when  gantt.duedate_trn <= cast($1 as date) and gantt.qty > 0 
	 	 					then 1	
	 	 				else
	 	 					3 end  priority,
	 	 				gantt.starttime_trn starttime,gantt.duedate_trn duedate,
	 	 				gantt.processseq_trn processseq,gantt.mlevel mlevel,
	 	 				gantt.itms_id_trn itms_id,gantt.shelfnos_id_to_trn shelfnos_id,s.locas_id_shelfno,s.locas_id_alloc,
	 	 				gantt.prjnos_id,alloc.trngantts_id trngantts_id,
	 	 				alloc.id alloctbls_id	,
	 	 				gantt.qty qty,gantt.qty_stk qty_stk,alloc.qty_linkto_alloctbl qty_linkto_alloctbl,gantt.shelfnos_id_to_trn shelfnos_id_to,
						gantt.update_ip,gantt.updated_at	
	 	 				from trngantts gantt
	 	 				inner join alloctbls alloc on gantt.id = alloc.trngantts_id
						inner join shelfnos s on s.id = gantt.shelfnos_id_to_trn
	 	 				where gantt.prjnos_id =  $2 and  
	 	 						 gantt.orgtblname = gantt.paretblname and gantt.paretblname = gantt.tblname
	 	 					and gantt.orgtblid = gantt.paretblid  and gantt.paretblid = gantt.tblid
	 	 					and  gantt.itms_id_trn = $3 and gantt.processseq_trn = $4
							--- xxxordsはxxxinsts,xxxactsに変わってもtrngantts.tblname は xxxordsのまま
							and orgtblname = paretblname and paretblname = gantt.tblname
							and orgtblid = paretblid and paretblid = gantt.tblid
	 	 					and   alloc.qty_linkto_alloctbl > 0 and alloc.allocfree = '||'''free'''||'
							and   orgtblname not like  '||'''cust%'''||' and gantt.tblname not like '||'''%schs'''||' 
							and (gantt.shelfnos_id_to_trn = $5 
									or s.locas_id_shelfno = (select locas_id_shelfno from shelfnos where id = $5) 
									or s.locas_id_alloc = (select locas_id_alloc from shelfnos where id = $5)) 
	 	 					order by priority,duedate_trn
	 	 					--- tblname,tblidはlotstksの在庫の移動のためreturnに必要
	 	 				--- xxxacts等を登録するときは必ずxxxordsを前に登録すること。
	 	 		'	
		using induedate ,inprjnos_id ,initms_id ,inprocessseq ,inshelfnos_id;

END
$function$
;
