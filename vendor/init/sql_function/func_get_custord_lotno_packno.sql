drop function public.func_get_custord_lotno_packno;

CREATE OR REPLACE FUNCTION public.func_get_custord_lotno_packno(custords_id numeric)
 RETURNS Table(custord_id numeric,qty_stk  numeric,lotno  text,packno  text,shelfnos_id numeric)
 LANGUAGE sql
AS $function$
select custord_id,sum(qty_stk) qty_stk,lotno,packno,shelfnos_id from  (
	select orgtblid custord_id,i.qty_stk,l.lotno,l.packno,l.shelfnos_id  from trngantts trn
							inner join alloctbls a on a.trngantts_id = trn.id and a.qty_linkto_alloctbl > 0 
							inner join inoutlotstks i on i.trngantts_id = trn.id
							inner join lotstkhists l on l.itms_id = trn.itms_id_trn and l.processseq = trn.processseq_trn 
							where orgtblname = 'custords' and orgtblid = $1
                               and paretblname = 'custords' and paretblid = $1
                               and mlevel = '1'
                               and a.srctblname = i.tblname and a.srctblid = i.tblid 
                               and i.srctblid = l.id
union    ---�K�v���ȏ�̍݌ɐ��ɂȂ�B                          
	select link.tblid custord_id,
			case when i.qty_stk >=  link.qty_src then link.qty_src else i.qty_stk end  qty_stk,l.lotno,l.packno,l.shelfnos_id from trngantts trn
			inner join linkcusts link on link.srctblname = trn.orgtblname  and link.srctblid = trn.orgtblid
			inner join alloctbls a on a.trngantts_id = trn.id and a.qty_linkto_alloctbl > 0 
			inner join inoutlotstks i on i.trngantts_id = trn.id
			inner join lotstkhists l on l.itms_id = trn.itms_id_trn and l.processseq = trn.processseq_trn 
										and  link.srctblname = trn.paretblname  and link.srctblid = trn.paretblid
			where trn.mlevel = '1' and link.tblname = 'custords' and  link.tblid = $1 
            and a.srctblname = i.tblname and a.srctblid = i.tblid 
            and i.srctblid = l.id ) custord
group by custord_id,lotno,packno,shelfnos_id
$function$
;
								