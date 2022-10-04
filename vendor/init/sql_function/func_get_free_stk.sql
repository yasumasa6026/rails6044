--- İŒÉˆÚ“®‚É‚Í•K‚¸trngantts‚ğ—p‚¢‚é‚±‚Æ
create or replace function 
	func_get_free_stk(itms_id numeric,processseq numeric,OUT qty_stk numeric)
as $func$
BEGIN	
  EXECUTE 'select 	case sum(trn.qty_stk)
		when null then 0
		else sum(trn.qty_stk) end qty_stk 
	from trngantts trn 
	where  trn.qty_stk > 0
		and trn.itms_id_trn = $1 and trn.processseq_trn = $2 
		and trn.orgtblname = trn.paretblname and  trn.tblname = trn.paretblname
		and trn.orgtblid = trn.paretblid and  trn.tblid = trn.paretblid 
 	group by trn.itms_id_trn,trn.processseq_trn'
   INTO qty_stk
   USING  itms_id,processseq;
END
$func$  LANGUAGE plpgsql;
	