--- ÝŒÉˆÚ“®Žž‚É‚Í•K‚¸trngantts‚ð—p‚¢‚é‚±‚Æ
create or replace function 
	func_get_shelfnos_stk(itms_id numeric,processseq numeric,shelfnos_id numeric,prjnos_id numeric,OUT qty_stk numeric)
as $func$
BEGIN	
  EXECUTE 'select 	case sum(trn.qty_stk)
		when null then 0
		else sum(trn.qty_stk) end qty_stk 
	from trngantts trn 
	where trn.qty_stk > 0
		and trn.itms_id_trn = $1 and trn.processseq_trn = $2 and  trn.shelfnos_id_to_trn = $3
		and trn.prjnos_id = $4
 	group by trn.itms_id_trn,trn.processseq_trn, trn.shelfnos_id_to_trn,trn.prjnos_id' 
   INTO qty_stk
   USING  itms_id,processseq, shelfnos_id,prjnos_id;
END
$func$  LANGUAGE plpgsql;
	