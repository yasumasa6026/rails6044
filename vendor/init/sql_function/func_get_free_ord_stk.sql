 DROP FUNCTION public.func_get_free_ord_stk(varchar, numeric, numeric, numeric);
CREATE OR REPLACE FUNCTION public.func_get_free_ord_stk(induedate character varying, inprjnos_id numeric, initms_id numeric, inprocessseq numeric)
 RETURNS TABLE(tblname character varying, tblid numeric, priority text, due numeric, starttime timestamp without time zone, duedate timestamp without time zone, processseq numeric, mlevel numeric, itms_id numeric, shelfnos_id numeric, prjnos_id numeric, trngantts_id numeric, alloctbls_id numeric, qty numeric, qty_stk numeric, qty_linkto_alloctbl numeric, update_ip character varying, updated_at timestamp without time zone)
 LANGUAGE plpgsql
AS $function$
BEGIN
	RETURN QUERY
	 EXECUTE 'select   ---  free　を求めるsql
						alloc.srctblname tblname,alloc.srctblid tblid,
	 	 				case
	 	 				when alloc.srctblname like '||'''%dlvs'''||'
	 	 					then '||'''02'''||' 
	 	 				when alloc.srctblname like '||'''%acts'''||'
	 	 					then '||'''02'''||' 
	 	 				when  gantt.duedate_trn <= cast($1 as date)
	 	 					then '||'''01'''||'	
	 	 				else
	 	 					'||'''03'''||' end  priority,
	 	 				to_number(to_char(gantt.duedate_trn,'||'''yyyymmdd'''||'),'||'''99999999'''||')*-1 due,
	 	 				gantt.starttime_trn starttime,gantt.duedate_trn duedate,
	 	 				gantt.processseq_trn processseq,gantt.mlevel mlevel,
	 	 				gantt.itms_id_trn itms_id,gantt.shelfnos_id_to_trn shelfnos_id,
	 	 				gantt.prjnos_id,alloc.trngantts_id trngantts_id,
	 	 				alloc.id alloctbls_id	,
	 	 				gantt.qty qty,gantt.qty_stk qty_stk,alloc.qty_linkto_alloctbl qty_linkto_alloctbl,
						gantt.update_ip,gantt.updated_at	
	 	 				from trngantts gantt
	 	 				inner join alloctbls alloc on gantt.id = alloc.trngantts_id
	 	 				where gantt.prjnos_id =  $2 and  
	 	 						 gantt.orgtblname = gantt.paretblname and gantt.paretblname = gantt.tblname
	 	 					and gantt.orgtblid = gantt.paretblid  and gantt.paretblid = gantt.tblid
	 	 					and  gantt.itms_id_trn = $3 and gantt.processseq_trn = $4
							--- xxxordsはxxxinsts,xxxactsに変わってもtrngantts.tblname は xxxordsのまま
							and orgtblname = paretblname and paretblname = gantt.tblname
							and orgtblid = paretblid and paretblid = gantt.tblid
	 	 					and   alloc.qty_linkto_alloctbl > 0 and alloc.allocfree = '||'''free'''||'
							and   orgtblname not like  '||'''cust%'''||' 
	 	 					order by priority,due
	 	 					---for update
	 	 				--- xxxacts等を登録するときは必ずxxxordsを前に登録すること。
	 	 		'	
		using induedate ,inprjnos_id ,initms_id ,inprocessseq ;

END
$function$
;
