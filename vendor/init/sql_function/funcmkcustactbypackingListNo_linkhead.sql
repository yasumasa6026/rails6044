drop function  if exists funcmkcustactbypackingListNo_linkheads;
CREATE OR REPLACE FUNCTION funcmkcustactbypackingListNo_linkheads(loca_code_cust text,linkhead_packingListNo text)
 RETURNS TABLE(id numeric, person_code_upd text, person_name_upd text, linkhead_id numeric,
				linkhead_remark text,  linkhead_expiredate date, linkhead_update_ip text ,linkhead_created_at timestamp,
				linkhead_updated_at timestamp,linkhead_person_id_upd numeric,linkhead_contents text,linkhead_tblname text,
				linkhead_paretblname text,linkhead_paretblid numeric,linkhead_packingListNo text,linkhead_sno text,
				linkhead_cno text,itm_code text,itm_name text,custord_duedate timestamp,custord_qty numeric,
				custord_amt numeric,loca_code_cust text,loca_name_cust text,
				loca_code_custrcvplc text,loca_name_custrcvplc text )
 LANGUAGE sql
AS $function$
select  
	linkhead.id id,
  	person_upd.person_code  person_code_upd ,
  	person_upd.person_name  person_name_upd ,
	linkhead.id  linkhead_id,
	linkhead.remark  linkhead_remark,
	linkhead.expiredate  linkhead_expiredate,
	linkhead.update_ip  linkhead_update_ip,
	linkhead.created_at  linkhead_created_at,
	linkhead.updated_at  linkhead_updated_at,
	linkhead.persons_id_upd   linkhead_person_id_upd,
	linkhead.contents  linkhead_contents,
	'custdlvs'  linkhead_tblname,
	'linkheads'  linkhead_paretblname,
	linkhead.paretblid  linkhead_paretblid,
	custdlv.packingListNo  linkhead_packingListNo,
	''  linkhead_sno,
	''   linkhead_cno,
	'' itm_code,
	'' itm_name,
	custdlv.depdate custord_duedate,
	custdlv.qty custord_qty,
	custdlv.amt custord_amt, 
	custdlv.loca_code_cust loca_code_cust,
	custdlv.loca_name_cust loca_name_cust ,
	custdlv.loca_code_custrcvplc loca_code_custrcvplc,
	custdlv.loca_name_custrcvplc loca_name_custrcvplc
 from 	r_persons  person_upd,
 		(select loca_code_cust,loca_name_cust,max(depdate) depdate ,sum(qty_stk) qty,sum(amt) amt ,packingListNo,
 			max(persons_id_upd) persons_id_upd,custrcvplc.loca_code_custrcvplc loca_code_custrcvplc,
			custrcvplc.loca_name_custrcvplc loca_name_custrcvplc
 			from custdlvs dlv 
 			inner join r_custs cust on dlv.custs_id = cust.cust_id and cust.loca_code_cust = $1
 			inner join r_custrcvplcs custrcvplc on dlv.custrcvplcs_id = custrcvplc.custrcvplc_id
 			group by loca_code_cust,loca_name_cust,packingListNo,custrcvplc.loca_code_custrcvplc,custrcvplc.loca_name_custrcvplc ) custdlv 
  	left join linkheads   linkhead on linkhead.tblname = 'custdlvs' and linkhead.packingListNo = custdlv.packingListNo
  where  custdlv.packingListNo = $2 and person_upd.id = custdlv.persons_id_upd
 		
$function$
;
 	
