drop function  if exists funcmkcustactbysno_linkheads;
CREATE OR REPLACE FUNCTION funcmkcustactbysno_linkheads(sno text)
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
  	custord.person_code_upd  person_code_upd ,
  	custord.person_name_upd  person_name_upd ,
	linkhead.id  linkhead_id,
	linkhead.remark  linkhead_remark,
	linkhead.expiredate  linkhead_expiredate,
	linkhead.update_ip  linkhead_update_ip,
	linkhead.created_at  linkhead_created_at,
	linkhead.updated_at  linkhead_updated_at,
	linkhead.persons_id_upd   linkhead_person_id_upd,
	linkhead.contents  linkhead_contents,
	'custords'  linkhead_tblname,
	'linkheads'  linkhead_paretblname,
	linkhead.paretblid  linkhead_paretblid,
	''  linkhead_packingListNo,
	custord.custord_sno  linkhead_sno,
	''  linkhead_cno,
	custord.itm_code itm_code,
	custord.itm_name itm_name,
	custord.custord_duedate custord_duedate,
	link.qty custord_qty,
	(link.qty * custord.custord_price) custord_amt, 
	custord.loca_code_cust loca_code_cust,
	custord.loca_name_cust loca_name_cust ,
	custord.loca_code_custrcvplc loca_code_custrcvplc,
	custord.loca_name_custrcvplc loca_name_custrcvplc 
 from r_custords custord
 inner join (select sum(qty_src) qty ,tblid from linkcusts link 
 				where srctblname = tblname and srctblid = tblid and srctblname = 'custords' and qty_src > 0
 				group by tblname,tblid) link on link.tblid = custord.id 
 left join linkheads   linkhead on linkhead.tblname = 'custords' and linkhead.tblid = custord.id
  where       custord.custord_sno = $1 

  
$function$
;
 	