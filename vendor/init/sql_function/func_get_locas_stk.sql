--- ÝŒÉˆÚ“®Žž‚É‚Í•K‚¸trngantts‚ð—p‚¢‚é‚±‚Æ
create or replace function 
	func_get_locas_stk(itms_id numeric,processseq numeric,locas_id numeric,OUT qty_stk numeric)
as $func$
BEGIN	
  EXECUTE 'select 	case sum(trn.qty_stk)
		when null then 0
		else sum(trn.qty_stk) end qty_stk 
	from trngantts trn 
	inner join shelfnos shelfno on trn.shelfnos_id_to_trn = shelfno.id
	where  trn.qty_stk > 0
		and trn.itms_id_trn = $1 and trn.processseq_trn = $2 
		and  shelfno.locas_id_shelfno = $3
 	group by trn.itms_id_trn,trn.processseq_trn, trn.shelfnos_id_to_trn' 
   INTO qty_stk
   USING  itms_id,processseq, locas_id;
END
$func$  LANGUAGE plpgsql;
	