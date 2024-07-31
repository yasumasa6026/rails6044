CREATE OR REPLACE FUNCTION funcmk_custactheads(sno text,cno text,linkhead_packingListNo text)
 RETURNS TABLE(id numeric, person_code_upd text, person_name_upd text, linkhead_id numeric,
				linkhead_remark text,  linkhead_expiredate date, linkhead_update_ip text ,linkhead_created_at timestamp,
				linkhead_updated_at timestamp,linkhead_person_id_upd numeric,linkhead_contents text,linkhead_tblname text,
				linkhead_paretblname text,linkhead_paretblid numeric,linkhead_packingListNo text,linkhead_sno text,
				linkhead_cno text,itm_code text,itm_name text,custord_duedate timestamp,custord_qty numeric,
				custord_amt numeric,loca_code_cust text,loca_name_cust text )
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
	'custactheads'  linkhead_paretblname,
	linkhead.paretblid  linkhead_paretblid,
	''  linkhead_packingListNo,
	custord.custord_sno  linkhead_sno,
	''  linkhead_cno,
	custord.itm_code itm_code,
	custord.itm_name itm_name,
	custord.custord_duedate custord_duedate,
	custord.custord_qty custord_qty,
	custord.custord_amt custord_amt, 
	custord.loca_code_cust loca_code_cust,
	custord.loca_name_cust loca_name_cust 
 from r_custords custord
 left join linkheads   linkhead on linkhead.tblname = 'custords' and linkhead.tblid = custord.id
  where       custord.custord_sno = $1
union 
select  
	linkhead.id id,
  	custord.person_code_upd person_code_upd ,
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
	'custactheads'  linkhead_paretblname,
	linkhead.paretblid  linkhead_paretblid,
	''  linkhead_packingListNo,
	''  linkhead_sno,
	custord.custord_cno   linkhead_cno,
	custord.itm_code itm_code,
	custord.itm_name itm_name,
	custord.custord_duedate custord_duedate,
	custord.custord_qty custord_qty,
	custord.custord_amt custord_amt, 
	custord.loca_code_cust loca_code_cust,
	custord.loca_name_cust loca_name_cust 
 from 	r_custords custord
 	left join  linkheads   linkhead on linkhead.tblname = 'custords' and linkhead.tblid = custord.id  
  where       custord.custord_cno = $2
 		
union
select  
	linkhead.id id,
  	person_upd.code  person_code_upd ,
  	person_upd.name  person_name_upd ,
	linkhead.id  linkhead_id,
	linkhead.remark  linkhead_remark,
	linkhead.expiredate  linkhead_expiredate,
	linkhead.update_ip  linkhead_update_ip,
	linkhead.created_at  linkhead_created_at,
	linkhead.updated_at  linkhead_updated_at,
	linkhead.persons_id_upd   linkhead_person_id_upd,
	linkhead.contents  linkhead_contents,
	'custdlvs'  linkhead_tblname,
	'custactheads'  linkhead_paretblname,
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
	custdlv.loca_name_cust loca_name_cust 
 from 	persons  person_upd,
 		(select dlv.id,loca_code_cust,loca_name_cust,depdate depdate ,qty_stk qty,amt amt ,packingListNo,
 			persons_id_upd persons_id_upd
 			from custdlvs dlv inner join r_custs cust on dlv.custs_id = cust.cust_id) custdlv
  	left join linkheads   linkhead on linkhead.tblname = 'custdlvs' and linkhead.id = custdlv.id
  where  custdlv.packingListNo = $3 and person_upd.id = custdlv.persons_id_upd
 		
$function$
;
 	
 	DROP TABLE IF EXISTS sio.sio_fmcustorddlv_linkheads;
 CREATE TABLE sio.sio_fmcustorddlv_linkheads (
          sio_id numeric(22,0)  CONSTRAINT SIO_fmcustorddlv_linkheads_id_pk PRIMARY KEY           
          ,sio_user_code numeric(22,0)
          ,sio_Term_id varchar(30)
          ,sio_session_id numeric(22,0)
          ,sio_Command_Response char(1)
          ,sio_session_counter numeric(22,0)
          ,sio_classname varchar(50)
          ,sio_viewname varchar(30)
          ,sio_code varchar(30)
          ,sio_strsql varchar(4000)
          ,sio_totalcount numeric(22,0)
          ,sio_recordcount numeric(22,0)
          ,sio_start_record numeric(22,0)
          ,sio_end_record numeric(22,0)
          ,sio_sord varchar(256)
          ,sio_search varchar(10)
          ,sio_sidx varchar(256)
,id  numeric (38,0)
,linkhead_sno  varchar (40) 
,linkhead_cno  varchar (40) 
,linkhead_id  numeric (38,0)
,linkhead_remark  varchar (4000) 
,linkhead_expiredate   date 
,linkhead_update_ip  varchar (40) 
,linkhead_created_at   timestamp(6) 
,linkhead_updated_at   timestamp(6) 
,linkhead_contents  varchar (4000) 
,linkhead_tblname  varchar (30) 
,linkhead_paretblname  varchar (30) 
,linkhead_paretblid  numeric (38,0)
,linkhead_packingListNo  varchar (20) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,linkhead_person_id_upd  numeric (22,0)
          ,sio_errline varchar(4000)
          ,sio_org_tblname varchar(30)
          ,sio_org_tblid numeric(22,0)
          ,sio_add_time date
          ,sio_replay_time date
          ,sio_result_f char(1)
          ,sio_message_code char(10)
          ,sio_message_contents varchar(4000)
          ,sio_chk_done char(1)
);

drop index if exists sio_fmcustorddlv_linkheads_uk1;

 CREATE INDEX sio_fmcustorddlv_linkheads_uk1 
  ON sio.sio_fmcustorddlv_linkheads(id,sio_id); 

 drop sequence  if exists sio.sio_fmcustorddlv_linkheads_seq ;
 create sequence sio.sio_fmcustorddlv_linkheads_seq ;
