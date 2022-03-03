
  drop view if  exists r_bills cascade ; 
 create or replace view r_bills as select  
bill.id id,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
bill.personname  bill_personname,
bill.locas_id_bill   bill_loca_id_bill,
  loca_bill.loca_code  loca_code_bill ,
  loca_bill.loca_name  loca_name_bill ,
  loca_bill.loca_abbr  loca_abbr_bill ,
  loca_bill.loca_tel  loca_tel_bill ,
bill.contents  bill_contents,
bill.id  bill_id,
bill.remark  bill_remark,
bill.expiredate  bill_expiredate,
bill.update_ip  bill_update_ip,
bill.created_at  bill_created_at,
bill.updated_at  bill_updated_at,
bill.persons_id_upd   bill_person_id_upd,
bill.chrgs_id_bill   bill_chrg_id_bill,
  chrg_bill.person_code_chrg  person_code_chrg_bill ,
  chrg_bill.person_name_chrg  person_name_chrg_bill ,
  chrg_bill.person_sect_id_chrg  person_sect_id_chrg_bill ,
  chrg_bill.chrg_person_id_chrg  chrg_person_id_chrg_bill ,
bill.crrs_id_bill   bill_crr_id_bill,
  crr_bill.crr_code  crr_code_bill ,
  crr_bill.crr_name  crr_name_bill 
 from bills   bill,
  r_locas  loca_bill ,  r_persons  person_upd ,  r_chrgs  chrg_bill ,  r_crrs  crr_bill 
  where       bill.locas_id_bill = loca_bill.id      and bill.persons_id_upd = person_upd.id      and bill.chrgs_id_bill = chrg_bill.id      and bill.crrs_id_bill = crr_bill.id     ;
 DROP TABLE IF EXISTS sio.sio_r_bills;
 CREATE TABLE sio.sio_r_bills (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_bills_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,loca_code_bill  varchar (50) 
,loca_name_bill  varchar (100) 
,loca_abbr_bill  varchar (50) 
,person_code_chrg_bill  varchar (50) 
,person_name_chrg_bill  varchar (100) 
,bill_personname  varchar (30) 
,crr_code_bill  varchar (50) 
,crr_name_bill  varchar (100) 
,bill_contents  varchar (4000) 
,bill_expiredate   date 
,bill_remark  varchar (4000) 
,loca_tel_bill  varchar (20) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,bill_update_ip  varchar (40) 
,bill_updated_at   timestamp(6) 
,bill_person_id_upd  numeric (38,0)
,bill_chrg_id_bill  numeric (22,0)
,id  numeric (38,0)
,bill_loca_id_bill  numeric (38,0)
,bill_id  numeric (38,0)
,bill_created_at   timestamp(6) 
,bill_crr_id_bill  numeric (22,0)
,person_sect_id_chrg_bill  numeric (22,0)
,chrg_person_id_chrg_bill  numeric (38,0)
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
 CREATE INDEX sio_r_bills_uk1 
  ON sio.sio_r_bills(id,sio_id); 

 drop sequence  if exists sio.sio_r_bills_seq ;
 create sequence sio.sio_r_bills_seq ;
  drop view if  exists r_custs cascade ; 
 create or replace view r_custs as select  
cust.updated_at  cust_updated_at,
cust.custtype  cust_custtype,
cust.remark  cust_remark,
cust.persons_id_upd   cust_person_id_upd,
cust.expiredate  cust_expiredate,
cust.update_ip  cust_update_ip,
cust.id  cust_id,
cust.created_at  cust_created_at,
  loca_cust.loca_name  loca_name_cust ,
  loca_cust.loca_code  loca_code_cust ,
cust.id id,
cust.locas_id_cust   cust_loca_id_cust,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
cust.contract_price  cust_contract_price,
cust.rule_price  cust_rule_price,
cust.contents  cust_contents,
cust.chrgs_id_cust   cust_chrg_id_cust,
  chrg_cust.chrg_person_id_chrg  chrg_person_id_chrg_cust ,
  chrg_cust.person_code_chrg  person_code_chrg_cust ,
  chrg_cust.person_name_chrg  person_name_chrg_cust ,
  chrg_cust.person_sect_id_chrg  person_sect_id_chrg_cust ,
cust.amtdecimal  cust_amtdecimal,
cust.amtround  cust_amtround,
  bill.bill_loca_id_bill  bill_loca_id_bill ,
  bill.loca_code_bill  loca_code_bill ,
  bill.loca_name_bill  loca_name_bill ,
cust.personname  cust_personname,
cust.bills_id   cust_bill_id,
  crr_cust.crr_name  crr_name_cust ,
cust.crrs_id_cust   cust_crr_id_cust,
  crr_cust.crr_code  crr_code_cust ,
cust.autocreate_custact  cust_autocreate_custact,
  bill.bill_chrg_id_bill  bill_chrg_id_bill ,
  bill.person_code_chrg_bill  person_code_chrg_bill ,
  bill.person_name_chrg_bill  person_name_chrg_bill ,
  bill.person_sect_id_chrg_bill  person_sect_id_chrg_bill ,
  bill.chrg_person_id_chrg_bill  chrg_person_id_chrg_bill ,
  bill.bill_crr_id_bill  bill_crr_id_bill ,
  bill.crr_code_bill  crr_code_bill ,
  bill.crr_name_bill  crr_name_bill 
 from custs   cust,
  r_persons  person_upd ,  r_locas  loca_cust ,  r_chrgs  chrg_cust ,  r_bills  bill ,  r_crrs  crr_cust 
  where       cust.persons_id_upd = person_upd.id      and cust.locas_id_cust = loca_cust.id      and cust.chrgs_id_cust = chrg_cust.id      and cust.bills_id = bill.id      and cust.crrs_id_cust = crr_cust.id     ;
 DROP TABLE IF EXISTS sio.sio_r_custs;
 CREATE TABLE sio.sio_r_custs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_custs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,loca_code_cust  varchar (50) 
,loca_name_cust  varchar (100) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,person_code_chrg_cust  varchar (50) 
,person_name_chrg_cust  varchar (100) 
,loca_code_bill  varchar (50) 
,loca_name_bill  varchar (100) 
,person_code_chrg_bill  varchar (50) 
,person_name_chrg_bill  varchar (100) 
,crr_code_bill  varchar (50) 
,crr_code_cust  varchar (50) 
,crr_name_bill  varchar (100) 
,crr_name_cust  varchar (100) 
,cust_contract_price  varchar (1) 
,cust_rule_price  varchar (1) 
,cust_amtdecimal  numeric (38,0)
,cust_amtround  varchar (2) 
,cust_personname  varchar (30) 
,cust_crr_id_cust  numeric (38,0)
,cust_autocreate_custact  varchar (1) 
,cust_custtype  varchar (1) 
,cust_expiredate   date 
,cust_remark  varchar (4000) 
,cust_contents  varchar (4000) 
,cust_id  numeric (38,0)
,cust_update_ip  varchar (40) 
,chrg_person_id_chrg_bill  numeric (38,0)
,cust_bill_id  numeric (38,0)
,cust_updated_at   timestamp(6) 
,bill_crr_id_bill  numeric (22,0)
,person_sect_id_chrg_bill  numeric (22,0)
,cust_loca_id_cust  numeric (38,0)
,bill_chrg_id_bill  numeric (22,0)
,cust_person_id_upd  numeric (38,0)
,cust_chrg_id_cust  numeric (38,0)
,chrg_person_id_chrg_cust  numeric (38,0)
,id  numeric (38,0)
,cust_created_at   timestamp(6) 
,bill_loca_id_bill  numeric (38,0)
,person_sect_id_chrg_cust  numeric (22,0)
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
 CREATE INDEX sio_r_custs_uk1 
  ON sio.sio_r_custs(id,sio_id); 

 drop sequence  if exists sio.sio_r_custs_seq ;
 create sequence sio.sio_r_custs_seq ;
  drop view if  exists r_custwhs cascade ; 
 create or replace view r_custwhs as select  
  itm.itm_name  itm_name ,
  itm.itm_code  itm_code ,
  itm.unit_name  unit_name ,
  itm.unit_code  unit_code ,
  custrcvplc.loca_code_custrcvplc  loca_code_custrcvplc ,
  custrcvplc.loca_name_custrcvplc  loca_name_custrcvplc ,
custwh.id id,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  custrcvplc.custrcvplc_loca_id_custrcvplc  custrcvplc_loca_id_custrcvplc ,
  itm.classlist_code  classlist_code ,
  itm.classlist_name  classlist_name ,
  itm.itm_classlist_id  itm_classlist_id ,
custwh.qty_sch  custwh_qty_sch,
custwh.duedate  custwh_duedate,
custwh.remark  custwh_remark,
custwh.created_at  custwh_created_at,
custwh.update_ip  custwh_update_ip,
custwh.expiredate  custwh_expiredate,
custwh.updated_at  custwh_updated_at,
custwh.qty  custwh_qty,
custwh.id  custwh_id,
custwh.persons_id_upd   custwh_person_id_upd,
custwh.lotno  custwh_lotno,
custwh.qty_stk  custwh_qty_stk,
custwh.custrcvplcs_id   custwh_custrcvplc_id,
custwh.itms_id   custwh_itm_id,
custwh.processseq  custwh_processseq
 from custwhs   custwh,
  r_persons  person_upd ,  r_custrcvplcs  custrcvplc ,  r_itms  itm 
  where       custwh.persons_id_upd = person_upd.id      and custwh.custrcvplcs_id = custrcvplc.id      and custwh.itms_id = itm.id     ;
 DROP TABLE IF EXISTS sio.sio_r_custwhs;
 CREATE TABLE sio.sio_r_custwhs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_custwhs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,itm_code  varchar (50) 
,unit_code  varchar (50) 
,classlist_code  varchar (50) 
,classlist_name  varchar (100) 
,unit_name  varchar (100) 
,itm_name  varchar (100) 
,loca_code_custrcvplc  varchar (50) 
,loca_name_custrcvplc  varchar (100) 
,custwh_duedate   timestamp(6) 
,custwh_update_ip  varchar (40) 
,custwh_expiredate   date 
,custwh_updated_at   timestamp(6) 
,custwh_qty  numeric (22,6)
,custwh_lotno  varchar (50) 
,custwh_qty_stk  numeric (22,6)
,custwh_custrcvplc_id  numeric (38,0)
,custwh_qty_sch  numeric (22,6)
,custwh_remark  varchar (4000) 
,custwh_created_at   timestamp(6) 
,custwh_id  numeric (38,0)
,custwh_processseq  numeric (38,0)
,custwh_itm_id  numeric (38,0)
,id  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,custrcvplc_loca_id_custrcvplc  numeric (38,0)
,custwh_person_id_upd  numeric (22,0)
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
 CREATE INDEX sio_r_custwhs_uk1 
  ON sio.sio_r_custwhs(id,sio_id); 

 drop sequence  if exists sio.sio_r_custwhs_seq ;
 create sequence sio.sio_r_custwhs_seq ;
  drop view if  exists r_custrcvplcs cascade ; 
 create or replace view r_custrcvplcs as select  
  loca_custrcvplc.loca_code  loca_code_custrcvplc ,
  loca_custrcvplc.loca_name  loca_name_custrcvplc ,
custrcvplc.id id,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
custrcvplc.contents  custrcvplc_contents,
custrcvplc.locas_id_custrcvplc   custrcvplc_loca_id_custrcvplc,
custrcvplc.id  custrcvplc_id,
custrcvplc.remark  custrcvplc_remark,
custrcvplc.expiredate  custrcvplc_expiredate,
custrcvplc.update_ip  custrcvplc_update_ip,
custrcvplc.created_at  custrcvplc_created_at,
custrcvplc.updated_at  custrcvplc_updated_at,
custrcvplc.persons_id_upd   custrcvplc_person_id_upd,
custrcvplc.stktaking_proc  custrcvplc_stktaking_proc
 from custrcvplcs   custrcvplc,
  r_locas  loca_custrcvplc ,  r_persons  person_upd 
  where       custrcvplc.locas_id_custrcvplc = loca_custrcvplc.id      and custrcvplc.persons_id_upd = person_upd.id     ;
 DROP TABLE IF EXISTS sio.sio_r_custrcvplcs;
 CREATE TABLE sio.sio_r_custrcvplcs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_custrcvplcs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,loca_code_custrcvplc  varchar (50) 
,loca_name_custrcvplc  varchar (100) 
,custrcvplc_stktaking_proc  varchar (1) 
,custrcvplc_expiredate   date 
,custrcvplc_loca_id_custrcvplc  numeric (38,0)
,custrcvplc_remark  varchar (4000) 
,custrcvplc_contents  varchar (4000) 
,person_name_upd  varchar (100) 
,person_code_upd  varchar (50) 
,id  numeric (38,0)
,custrcvplc_update_ip  varchar (40) 
,custrcvplc_created_at   timestamp(6) 
,custrcvplc_updated_at   timestamp(6) 
,custrcvplc_person_id_upd  numeric (38,0)
,custrcvplc_id  numeric (38,0)
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
 CREATE INDEX sio_r_custrcvplcs_uk1 
  ON sio.sio_r_custrcvplcs(id,sio_id); 

 drop sequence  if exists sio.sio_r_custrcvplcs_seq ;
 create sequence sio.sio_r_custrcvplcs_seq ;
  drop view if  exists r_custschs cascade ; 
 create or replace view r_custschs as select  
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.unit_name  unit_name ,
  opeitm.unit_code  unit_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
  cust.loca_name_cust  loca_name_cust ,
  cust.loca_code_cust  loca_code_cust ,
  custrcvplc.loca_code_custrcvplc  loca_code_custrcvplc ,
  custrcvplc.loca_name_custrcvplc  loca_name_custrcvplc ,
custsch.id id,
  cust.cust_loca_id_cust  cust_loca_id_cust ,
  prjno.prjno_name  prjno_name ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  prjno.prjno_code  prjno_code ,
custsch.cno  custsch_cno,
custsch.isudate  custsch_isudate,
custsch.prjnos_id   custsch_prjno_id,
custsch.expiredate  custsch_expiredate,
custsch.updated_at  custsch_updated_at,
custsch.sno  custsch_sno,
custsch.price  custsch_price,
custsch.remark  custsch_remark,
custsch.created_at  custsch_created_at,
custsch.update_ip  custsch_update_ip,
custsch.duedate  custsch_duedate,
custsch.id  custsch_id,
custsch.persons_id_upd   custsch_person_id_upd,
custsch.contents  custsch_contents,
custsch.custs_id   custsch_cust_id,
custsch.contract_price  custsch_contract_price,
  cust.cust_chrg_id_cust  cust_chrg_id_cust ,
  cust.chrg_person_id_chrg_cust  chrg_person_id_chrg_cust ,
  cust.person_code_chrg_cust  person_code_chrg_cust ,
  cust.person_name_chrg_cust  person_name_chrg_cust ,
  cust.person_sect_id_chrg_cust  person_sect_id_chrg_cust ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  cust.bill_loca_id_bill  bill_loca_id_bill ,
  cust.loca_code_bill  loca_code_bill ,
  cust.loca_name_bill  loca_name_bill ,
  cust.cust_bill_id  cust_bill_id ,
  cust.crr_name_cust  crr_name_cust ,
  cust.cust_crr_id_cust  cust_crr_id_cust ,
  cust.crr_code_cust  crr_code_cust ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  opeitm.unit_code_box  unit_code_box ,
  opeitm.unit_name_box  unit_name_box ,
  opeitm.boxe_unit_id_outbox  boxe_unit_id_outbox ,
  opeitm.unit_code_outbox  unit_code_outbox ,
  opeitm.unit_name_outbox  unit_name_outbox ,
  opeitm.boxe_code  boxe_code ,
  opeitm.boxe_name  boxe_name ,
  opeitm.opeitm_boxe_id  opeitm_boxe_id ,
  prjno.prjno_code_chil  prjno_code_chil ,
  cust.bill_chrg_id_bill  bill_chrg_id_bill ,
  cust.person_code_chrg_bill  person_code_chrg_bill ,
  cust.person_name_chrg_bill  person_name_chrg_bill ,
  opeitm.itm_classlist_id  itm_classlist_id ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
custsch.opeitms_id   custsch_opeitm_id,
  cust.person_sect_id_chrg_bill  person_sect_id_chrg_bill ,
  cust.chrg_person_id_chrg_bill  chrg_person_id_chrg_bill ,
custsch.gno  custsch_gno,
  cust.bill_crr_id_bill  bill_crr_id_bill ,
  cust.crr_code_bill  crr_code_bill ,
  cust.crr_name_bill  crr_name_bill ,
custsch.starttime  custsch_starttime,
custsch.qty_sch  custsch_qty_sch,
custsch.shelfnos_id_fm   custsch_shelfno_id_fm,
custsch.amt_sch  custsch_amt_sch,
  prjno.prjno_name_chil  prjno_name_chil ,
  opeitm.opeitm_loca_id_opeitm  opeitm_loca_id_opeitm ,
  opeitm.loca_code_opeitm  loca_code_opeitm ,
  opeitm.loca_name_opeitm  loca_name_opeitm ,
  opeitm.shelfno_code_fm_opeitm  shelfno_code_fm_opeitm ,
  opeitm.shelfno_name_fm_opeitm  shelfno_name_fm_opeitm ,
  opeitm.shelfno_loca_id_shelfno_fm_opeitm  shelfno_loca_id_shelfno_fm_opeitm ,
  opeitm.loca_code_shelfno_fm_opeitm  loca_code_shelfno_fm_opeitm ,
  opeitm.loca_name_shelfno_fm_opeitm  loca_name_shelfno_fm_opeitm ,
  opeitm.shelfno_code_to_opeitm  shelfno_code_to_opeitm ,
  opeitm.shelfno_name_to_opeitm  shelfno_name_to_opeitm ,
  opeitm.shelfno_loca_id_shelfno_to_opeitm  shelfno_loca_id_shelfno_to_opeitm ,
  opeitm.loca_code_shelfno_to_opeitm  loca_code_shelfno_to_opeitm ,
  opeitm.loca_name_shelfno_to_opeitm  loca_name_shelfno_to_opeitm ,
  opeitm.unit_name_case_shp  unit_name_case_shp ,
  opeitm.unit_code_case_shp  unit_code_case_shp ,
  opeitm.unit_name_case_prdpur  unit_name_case_prdpur ,
  opeitm.unit_code_case_prdpur  unit_code_case_prdpur ,
custsch.custrcvplcs_id   custsch_custrcvplc_id
 from custschs   custsch,
  r_prjnos  prjno ,  r_persons  person_upd ,  r_custs  cust ,  r_opeitms  opeitm ,  r_shelfnos  shelfno_fm ,  r_custrcvplcs  custrcvplc 
  where       custsch.prjnos_id = prjno.id      and custsch.persons_id_upd = person_upd.id      and custsch.custs_id = cust.id      and custsch.opeitms_id = opeitm.id      and custsch.shelfnos_id_fm = shelfno_fm.id      and custsch.custrcvplcs_id = custrcvplc.id     ;
 DROP TABLE IF EXISTS sio.sio_r_custschs;
 CREATE TABLE sio.sio_r_custschs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_custschs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,custsch_isudate   timestamp(6) 
,custsch_cno  varchar (40) 
,person_code_upd  varchar (50) 
,itm_code  varchar (50) 
,person_name_upd  varchar (100) 
,itm_name  varchar (100) 
,loca_code_cust  varchar (50) 
,loca_name_cust  varchar (100) 
,custsch_duedate   timestamp(6) 
,custsch_price  numeric (38,4)
,custsch_contract_price  varchar (1) 
,unit_code  varchar (50) 
,unit_name  varchar (100) 
,unit_code_box  varchar (50) 
,unit_name_box  varchar (100) 
,unit_code_outbox  varchar (50) 
,unit_name_outbox  varchar (100) 
,prjno_code  varchar (50) 
,prjno_name  varchar (100) 
,classlist_code  varchar (50) 
,person_code_chrg_cust  varchar (50) 
,boxe_code  varchar (50) 
,person_name_chrg_cust  varchar (100) 
,person_code_chrg_bill  varchar (50) 
,person_name_chrg_bill  varchar (100) 
,prjno_code_chil  varchar (50) 
,loca_code_bill  varchar (50) 
,classlist_name  varchar (100) 
,custsch_expiredate   date 
,boxe_name  varchar (100) 
,shelfno_code_fm_opeitm  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,loca_code_custrcvplc  varchar (50) 
,unit_code_case_shp  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,loca_code_opeitm  varchar (50) 
,crr_code_cust  varchar (50) 
,crr_code_bill  varchar (50) 
,shelfno_code_fm  varchar (50) 
,loca_name_bill  varchar (100) 
,unit_name_case_shp  varchar (100) 
,crr_name_bill  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,shelfno_name_fm  varchar (100) 
,loca_name_custrcvplc  varchar (100) 
,prjno_name_chil  varchar (100) 
,loca_name_opeitm  varchar (100) 
,crr_name_cust  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,custsch_shelfno_id_fm  numeric (22,0)
,custsch_starttime   timestamp(6) 
,cust_crr_id_cust  numeric (38,0)
,custsch_amt_sch  numeric (38,4)
,custsch_qty_sch  numeric (22,6)
,custsch_sno  varchar (40) 
,opeitm_priority  numeric (3,0)
,custsch_custrcvplc_id  numeric (38,0)
,custsch_gno  varchar (40) 
,custsch_contents  varchar (4000) 
,custsch_remark  varchar (4000) 
,person_sect_id_chrg_bill  numeric (22,0)
,chrg_person_id_chrg_bill  numeric (38,0)
,itm_unit_id  numeric (22,0)
,bill_crr_id_bill  numeric (22,0)
,bill_chrg_id_bill  numeric (22,0)
,opeitm_boxe_id  numeric (22,0)
,boxe_unit_id_outbox  numeric (22,0)
,boxe_unit_id_box  numeric (22,0)
,cust_bill_id  numeric (38,0)
,bill_loca_id_bill  numeric (38,0)
,person_sect_id_chrg_cust  numeric (22,0)
,opeitm_loca_id_opeitm  numeric (22,0)
,chrg_person_id_chrg_cust  numeric (38,0)
,cust_chrg_id_cust  numeric (38,0)
,custsch_cust_id  numeric (38,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,custsch_person_id_upd  numeric (38,0)
,custsch_id  numeric (38,0)
,custsch_update_ip  varchar (40) 
,custsch_created_at   timestamp(6) 
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,custsch_updated_at   timestamp(6) 
,custsch_prjno_id  numeric (38,0)
,cust_loca_id_cust  numeric (38,0)
,id  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,custsch_opeitm_id  numeric (38,0)
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
 CREATE INDEX sio_r_custschs_uk1 
  ON sio.sio_r_custschs(id,sio_id); 

 drop sequence  if exists sio.sio_r_custschs_seq ;
 create sequence sio.sio_r_custschs_seq ;
  drop view if  exists r_custinsts cascade ; 
 create or replace view r_custinsts as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.unit_name  unit_name ,
  opeitm.unit_code  unit_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
  cust.loca_name_cust  loca_name_cust ,
  cust.loca_code_cust  loca_code_cust ,
custinst.isudate  custinst_isudate,
custinst.created_at  custinst_created_at,
custinst.sno  custinst_sno,
custinst.amt  custinst_amt,
  custrcvplc.loca_code_custrcvplc  loca_code_custrcvplc ,
custinst.updated_at  custinst_updated_at,
custinst.remark  custinst_remark,
custinst.update_ip  custinst_update_ip,
custinst.price  custinst_price,
custinst.qty  custinst_qty,
custinst.duedate  custinst_duedate,
custinst.persons_id_upd   custinst_person_id_upd,
custinst.id  custinst_id,
  custrcvplc.loca_name_custrcvplc  loca_name_custrcvplc ,
custinst.id id,
  cust.cust_loca_id_cust  cust_loca_id_cust ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
custinst.expiredate  custinst_expiredate,
custinst.cno  custinst_cno,
custinst.custs_id   custinst_cust_id,
custinst.gno  custinst_gno,
  custrcvplc.custrcvplc_loca_id_custrcvplc  custrcvplc_loca_id_custrcvplc ,
custinst.custrcvplcs_id   custinst_custrcvplc_id,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  cust.cust_chrg_id_cust  cust_chrg_id_cust ,
  cust.chrg_person_id_chrg_cust  chrg_person_id_chrg_cust ,
  cust.person_code_chrg_cust  person_code_chrg_cust ,
  cust.person_name_chrg_cust  person_name_chrg_cust ,
  cust.person_sect_id_chrg_cust  person_sect_id_chrg_cust ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  cust.bill_loca_id_bill  bill_loca_id_bill ,
  cust.loca_code_bill  loca_code_bill ,
  cust.loca_name_bill  loca_name_bill ,
  cust.cust_bill_id  cust_bill_id ,
  cust.crr_name_cust  crr_name_cust ,
  cust.cust_crr_id_cust  cust_crr_id_cust ,
  cust.crr_code_cust  crr_code_cust ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  opeitm.unit_code_box  unit_code_box ,
  opeitm.unit_name_box  unit_name_box ,
  opeitm.boxe_unit_id_outbox  boxe_unit_id_outbox ,
  opeitm.unit_code_outbox  unit_code_outbox ,
  opeitm.unit_name_outbox  unit_name_outbox ,
  opeitm.boxe_code  boxe_code ,
  opeitm.boxe_name  boxe_name ,
  opeitm.opeitm_boxe_id  opeitm_boxe_id ,
custinst.contract_price  custinst_contract_price,
custinst.chrgs_id   custinst_chrg_id,
custinst.itm_code_client  custinst_itm_code_client,
  cust.bill_chrg_id_bill  bill_chrg_id_bill ,
  cust.person_code_chrg_bill  person_code_chrg_bill ,
  cust.person_name_chrg_bill  person_name_chrg_bill ,
  opeitm.itm_classlist_id  itm_classlist_id ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
  cust.person_sect_id_chrg_bill  person_sect_id_chrg_bill ,
  cust.chrg_person_id_chrg_bill  chrg_person_id_chrg_bill ,
  cust.bill_crr_id_bill  bill_crr_id_bill ,
  cust.crr_code_bill  crr_code_bill ,
  cust.crr_name_bill  crr_name_bill ,
custinst.starttime  custinst_starttime,
custinst.shelfnos_id_fm   custinst_shelfno_id_fm,
custinst.opeitms_id   custinst_opeitm_id,
  opeitm.loca_code_opeitm  loca_code_opeitm ,
  opeitm.loca_name_opeitm  loca_name_opeitm ,
  opeitm.shelfno_code_fm_opeitm  shelfno_code_fm_opeitm ,
  opeitm.shelfno_name_fm_opeitm  shelfno_name_fm_opeitm ,
  opeitm.shelfno_loca_id_shelfno_fm_opeitm  shelfno_loca_id_shelfno_fm_opeitm ,
  opeitm.loca_code_shelfno_fm_opeitm  loca_code_shelfno_fm_opeitm ,
  opeitm.loca_name_shelfno_fm_opeitm  loca_name_shelfno_fm_opeitm ,
  opeitm.shelfno_code_to_opeitm  shelfno_code_to_opeitm ,
  opeitm.shelfno_name_to_opeitm  shelfno_name_to_opeitm ,
  opeitm.shelfno_loca_id_shelfno_to_opeitm  shelfno_loca_id_shelfno_to_opeitm ,
  opeitm.loca_code_shelfno_to_opeitm  loca_code_shelfno_to_opeitm ,
  opeitm.loca_name_shelfno_to_opeitm  loca_name_shelfno_to_opeitm ,
  opeitm.unit_name_case_shp  unit_name_case_shp ,
  opeitm.unit_code_case_shp  unit_code_case_shp ,
  opeitm.unit_name_case_prdpur  unit_name_case_prdpur ,
  opeitm.unit_code_case_prdpur  unit_code_case_prdpur ,
custinst.sno_custord  custinst_sno_custord,
custinst.cno_custord  custinst_cno_custord
 from custinsts   custinst,
  r_persons  person_upd ,  r_custs  cust ,  r_custrcvplcs  custrcvplc ,  r_chrgs  chrg ,  r_shelfnos  shelfno_fm ,  r_opeitms  opeitm 
  where       custinst.persons_id_upd = person_upd.id      and custinst.custs_id = cust.id      and custinst.custrcvplcs_id = custrcvplc.id      and custinst.chrgs_id = chrg.id      and custinst.shelfnos_id_fm = shelfno_fm.id      and custinst.opeitms_id = opeitm.id     ;
 DROP TABLE IF EXISTS sio.sio_r_custinsts;
 CREATE TABLE sio.sio_r_custinsts (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_custinsts_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,unit_code  varchar (50) 
,itm_code  varchar (50) 
,boxe_code  varchar (50) 
,classlist_code  varchar (50) 
,boxe_name  varchar (100) 
,classlist_name  varchar (100) 
,unit_name  varchar (100) 
,itm_name  varchar (100) 
,loca_code_opeitm  varchar (50) 
,loca_code_custrcvplc  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,person_code_chrg  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,loca_code_cust  varchar (50) 
,shelfno_code_fm  varchar (50) 
,unit_code_box  varchar (50) 
,person_code_chrg_bill  varchar (50) 
,crr_code_cust  varchar (50) 
,loca_code_bill  varchar (50) 
,unit_code_outbox  varchar (50) 
,crr_code_bill  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,person_code_chrg_cust  varchar (50) 
,unit_code_case_shp  varchar (50) 
,unit_name_outbox  varchar (100) 
,person_name_chrg  varchar (100) 
,loca_name_cust  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,unit_name_case_shp  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,loca_name_custrcvplc  varchar (100) 
,loca_name_opeitm  varchar (100) 
,crr_name_bill  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,person_name_chrg_cust  varchar (100) 
,shelfno_name_fm  varchar (100) 
,loca_name_bill  varchar (100) 
,person_name_chrg_bill  varchar (100) 
,crr_name_cust  varchar (100) 
,unit_name_box  varchar (100) 
,cust_crr_id_cust  numeric (38,0)
,custinst_gno  varchar (40) 
,custinst_shelfno_id_fm  numeric (22,0)
,custinst_opeitm_id  numeric (38,0)
,custinst_starttime   timestamp(6) 
,opeitm_priority  numeric (3,0)
,custinst_isudate   timestamp 
,custinst_duedate   timestamp 
,custinst_cno_custord  varchar (50) 
,custinst_chrg_id  numeric (38,0)
,custinst_sno_custord  varchar (50) 
,custinst_qty  numeric (38,4)
,custinst_price  numeric (38,4)
,custinst_amt  numeric (38,4)
,custinst_contract_price  varchar (1) 
,custinst_expiredate   date 
,custinst_sno  varchar (40) 
,custinst_remark  varchar (4000) 
,custinst_cno  varchar (40) 
,custinst_itm_code_client  varchar (50) 
,chrg_person_id_chrg_cust  numeric (38,0)
,cust_chrg_id_cust  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,person_sect_id_chrg_bill  numeric (22,0)
,chrg_person_id_chrg_bill  numeric (38,0)
,bill_crr_id_bill  numeric (22,0)
,chrg_person_id_chrg  numeric (38,0)
,cust_bill_id  numeric (38,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,bill_chrg_id_bill  numeric (22,0)
,itm_unit_id  numeric (22,0)
,opeitm_itm_id  numeric (38,0)
,boxe_unit_id_outbox  numeric (38,0)
,opeitm_boxe_id  numeric (22,0)
,custrcvplc_loca_id_custrcvplc  numeric (38,0)
,person_sect_id_chrg_cust  numeric (22,0)
,bill_loca_id_bill  numeric (38,0)
,cust_loca_id_cust  numeric (38,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,custinst_custrcvplc_id  numeric (22,0)
,custinst_update_ip  varchar (40) 
,custinst_cust_id  numeric (22,0)
,custinst_person_id_upd  numeric (22,0)
,custinst_updated_at   timestamp(6) 
,custinst_created_at   timestamp(6) 
,id  numeric (22,0)
,custinst_id  numeric (22,0)
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
 CREATE INDEX sio_r_custinsts_uk1 
  ON sio.sio_r_custinsts(id,sio_id); 

 drop sequence  if exists sio.sio_r_custinsts_seq ;
 create sequence sio.sio_r_custinsts_seq ;
  drop view if  exists r_custords cascade ; 
 create or replace view r_custords as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.unit_name  unit_name ,
  opeitm.unit_code  unit_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_processseq  opeitm_processseq ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
custord.remark  custord_remark,
custord.update_ip  custord_update_ip,
custord.duedate  custord_duedate,
custord.updated_at  custord_updated_at,
custord.price  custord_price,
custord.id  custord_id,
custord.persons_id_upd   custord_person_id_upd,
custord.created_at  custord_created_at,
custord.toduedate  custord_toduedate,
custord.expiredate  custord_expiredate,
custord.sno  custord_sno,
  cust.loca_name_cust  loca_name_cust ,
custord.amt  custord_amt,
custord.qty  custord_qty,
custord.isudate  custord_isudate,
  cust.loca_code_cust  loca_code_cust ,
  custrcvplc.loca_code_custrcvplc  loca_code_custrcvplc ,
  custrcvplc.loca_name_custrcvplc  loca_name_custrcvplc ,
custord.id id,
custord.custs_id   custord_cust_id,
custord.sno_custsch  custord_sno_custsch,
  prjno.prjno_name  prjno_name ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
custord.cno  custord_cno,
  prjno.prjno_code  prjno_code ,
custord.prjnos_id   custord_prjno_id,
custord.gno  custord_gno,
  custrcvplc.custrcvplc_loca_id_custrcvplc  custrcvplc_loca_id_custrcvplc ,
custord.contract_price  custord_contract_price,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
custord.chrgs_id   custord_chrg_id,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  cust.bill_loca_id_bill  bill_loca_id_bill ,
  cust.loca_code_bill  loca_code_bill ,
  cust.loca_name_bill  loca_name_bill ,
  cust.cust_bill_id  cust_bill_id ,
  crr.crr_code  crr_code ,
  crr.crr_name  crr_name ,
  crr.crr_pricedecimal  crr_pricedecimal ,
  cust.crr_name_cust  crr_name_cust ,
  cust.crr_code_cust  crr_code_cust ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  opeitm.unit_code_box  unit_code_box ,
  opeitm.unit_name_box  unit_name_box ,
  opeitm.boxe_unit_id_outbox  boxe_unit_id_outbox ,
  opeitm.unit_code_outbox  unit_code_outbox ,
  opeitm.unit_name_outbox  unit_name_outbox ,
custord.custrcvplcs_id   custord_custrcvplc_id,
custord.itm_code_client  custord_itm_code_client,
custord.contents  custord_contents,
  cust.bill_chrg_id_bill  bill_chrg_id_bill ,
  cust.person_code_chrg_bill  person_code_chrg_bill ,
  cust.person_name_chrg_bill  person_name_chrg_bill ,
  opeitm.itm_classlist_id  itm_classlist_id ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
  cust.person_sect_id_chrg_bill  person_sect_id_chrg_bill ,
  cust.chrg_person_id_chrg_bill  chrg_person_id_chrg_bill ,
custord.opeitms_id   custord_opeitm_id,
  cust.crr_code_bill  crr_code_bill ,
  cust.crr_name_bill  crr_name_bill ,
custord.starttime  custord_starttime,
custord.shelfnos_id_fm   custord_shelfno_id_fm,
  prjno.prjno_priority  prjno_priority ,
  opeitm.opeitm_loca_id_opeitm  opeitm_loca_id_opeitm ,
  opeitm.loca_code_opeitm  loca_code_opeitm ,
  opeitm.loca_name_opeitm  loca_name_opeitm ,
  opeitm.shelfno_code_fm_opeitm  shelfno_code_fm_opeitm ,
  opeitm.shelfno_name_fm_opeitm  shelfno_name_fm_opeitm ,
  opeitm.shelfno_loca_id_shelfno_fm_opeitm  shelfno_loca_id_shelfno_fm_opeitm ,
  opeitm.loca_code_shelfno_fm_opeitm  loca_code_shelfno_fm_opeitm ,
  opeitm.loca_name_shelfno_fm_opeitm  loca_name_shelfno_fm_opeitm ,
  opeitm.shelfno_code_to_opeitm  shelfno_code_to_opeitm ,
  opeitm.shelfno_name_to_opeitm  shelfno_name_to_opeitm ,
  opeitm.shelfno_loca_id_shelfno_to_opeitm  shelfno_loca_id_shelfno_to_opeitm ,
  opeitm.loca_code_shelfno_to_opeitm  loca_code_shelfno_to_opeitm ,
  opeitm.loca_name_shelfno_to_opeitm  loca_name_shelfno_to_opeitm ,
  opeitm.unit_name_case_shp  unit_name_case_shp ,
  opeitm.unit_code_case_shp  unit_code_case_shp ,
  opeitm.unit_name_case_prdpur  unit_name_case_prdpur ,
  opeitm.unit_code_case_prdpur  unit_code_case_prdpur ,
custord.crrs_id   custord_crr_id
 from custords   custord,
  r_persons  person_upd ,  r_custs  cust ,  r_prjnos  prjno ,  r_chrgs  chrg ,  r_custrcvplcs  custrcvplc ,  r_opeitms  opeitm ,  r_shelfnos  shelfno_fm ,  r_crrs  crr 
  where       custord.persons_id_upd = person_upd.id      and custord.custs_id = cust.id      and custord.prjnos_id = prjno.id      and custord.chrgs_id = chrg.id      and custord.custrcvplcs_id = custrcvplc.id      and custord.opeitms_id = opeitm.id      and custord.shelfnos_id_fm = shelfno_fm.id      and custord.crrs_id = crr.id     ;
 DROP TABLE IF EXISTS sio.sio_r_custords;
 CREATE TABLE sio.sio_r_custords (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_custords_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,custord_isudate   date 
,custord_cno  varchar (40) 
,loca_code_cust  varchar (50) 
,loca_name_cust  varchar (100) 
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,opeitm_processseq  numeric (3,0)
,opeitm_priority  numeric (3,0)
,custord_itm_code_client  varchar (50) 
,loca_code_opeitm  varchar (50) 
,loca_name_opeitm  varchar (100) 
,custord_duedate   timestamp(6) 
,custord_qty  numeric (18,4)
,custord_price  numeric (22,0)
,custord_contract_price  varchar (1) 
,custord_amt  numeric (18,4)
,person_code_chrg_bill  varchar (50) 
,loca_code_bill  varchar (50) 
,loca_name_bill  varchar (100) 
,crr_code  varchar (50) 
,unit_code  varchar (50) 
,unit_name  varchar (100) 
,prjno_code  varchar (50) 
,crr_code_cust  varchar (50) 
,crr_name_cust  varchar (100) 
,prjno_name  varchar (100) 
,prjno_priority  numeric (38,0)
,person_name_chrg_bill  varchar (100) 
,unit_code_box  varchar (50) 
,unit_name_box  varchar (100) 
,crr_code_bill  varchar (50) 
,unit_code_outbox  varchar (50) 
,crr_name_bill  varchar (100) 
,unit_name_outbox  varchar (100) 
,crr_name  varchar (100) 
,classlist_code  varchar (50) 
,custord_starttime   timestamp(6) 
,classlist_name  varchar (100) 
,custord_sno  varchar (40) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_custrcvplc  varchar (50) 
,shelfno_code_fm  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,person_code_chrg  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,unit_code_case_shp  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,shelfno_name_fm_opeitm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,person_name_chrg  varchar (100) 
,loca_name_custrcvplc  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,unit_name_case_shp  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,shelfno_name_fm  varchar (100) 
,custord_shelfno_id_fm  numeric (22,0)
,custord_gno  varchar (40) 
,custord_sno_custsch  varchar (50) 
,custord_crr_id  numeric (22,0)
,custord_chrg_id  numeric (38,0)
,crr_pricedecimal  numeric (22,0)
,person_name_upd  varchar (100) 
,person_code_upd  varchar (50) 
,custord_toduedate   timestamp(6) 
,custord_expiredate   date 
,custord_contents  varchar (4000) 
,custord_remark  varchar (4000) 
,chrg_person_id_chrg  numeric (38,0)
,custord_prjno_id  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,boxe_unit_id_outbox  numeric (38,0)
,custord_custrcvplc_id  numeric (38,0)
,itm_unit_id  numeric (22,0)
,bill_chrg_id_bill  numeric (22,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,person_sect_id_chrg_bill  numeric (22,0)
,chrg_person_id_chrg_bill  numeric (38,0)
,custord_opeitm_id  numeric (38,0)
,opeitm_loca_id_opeitm  numeric (22,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,custrcvplc_loca_id_custrcvplc  numeric (38,0)
,bill_loca_id_bill  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,id  numeric (22,0)
,custord_updated_at   timestamp(6) 
,custord_update_ip  varchar (40) 
,cust_bill_id  numeric (22,0)
,custord_cust_id  numeric (22,0)
,custord_created_at   timestamp(6) 
,custord_person_id_upd  numeric (22,0)
,custord_id  numeric (22,0)
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
 CREATE INDEX sio_r_custords_uk1 
  ON sio.sio_r_custords(id,sio_id); 

 drop sequence  if exists sio.sio_r_custords_seq ;
 create sequence sio.sio_r_custords_seq ;
  drop view if  exists r_custacts cascade ; 
 create or replace view r_custacts as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.unit_name  unit_name ,
  opeitm.unit_code  unit_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
  cust.loca_name_cust  loca_name_cust ,
  cust.loca_code_cust  loca_code_cust ,
  custrcvplc.loca_code_custrcvplc  loca_code_custrcvplc ,
  custrcvplc.loca_name_custrcvplc  loca_name_custrcvplc ,
custact.id id,
  cust.cust_loca_id_cust  cust_loca_id_cust ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  custrcvplc.custrcvplc_loca_id_custrcvplc  custrcvplc_loca_id_custrcvplc ,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  cust.cust_chrg_id_cust  cust_chrg_id_cust ,
  cust.chrg_person_id_chrg_cust  chrg_person_id_chrg_cust ,
  cust.person_code_chrg_cust  person_code_chrg_cust ,
  cust.person_name_chrg_cust  person_name_chrg_cust ,
  cust.person_sect_id_chrg_cust  person_sect_id_chrg_cust ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  cust.bill_loca_id_bill  bill_loca_id_bill ,
  cust.loca_code_bill  loca_code_bill ,
  cust.loca_name_bill  loca_name_bill ,
  cust.cust_bill_id  cust_bill_id ,
  cust.crr_name_cust  crr_name_cust ,
  cust.cust_crr_id_cust  cust_crr_id_cust ,
  cust.crr_code_cust  crr_code_cust ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  opeitm.unit_code_box  unit_code_box ,
  opeitm.unit_name_box  unit_name_box ,
  opeitm.boxe_unit_id_outbox  boxe_unit_id_outbox ,
  opeitm.unit_code_outbox  unit_code_outbox ,
  opeitm.unit_name_outbox  unit_name_outbox ,
  opeitm.boxe_code  boxe_code ,
  opeitm.boxe_name  boxe_name ,
  opeitm.opeitm_boxe_id  opeitm_boxe_id ,
custact.custrcvplcs_id   custact_custrcvplc_id,
custact.chrgs_id   custact_chrg_id,
custact.itm_code_client  custact_itm_code_client,
custact.isudate  custact_isudate,
custact.expiredate  custact_expiredate,
custact.updated_at  custact_updated_at,
custact.qty  custact_qty,
custact.sno  custact_sno,
custact.price  custact_price,
custact.remark  custact_remark,
custact.created_at  custact_created_at,
custact.update_ip  custact_update_ip,
custact.amt  custact_amt,
custact.id  custact_id,
custact.persons_id_upd   custact_person_id_upd,
custact.custs_id   custact_cust_id,
custact.contract_price  custact_contract_price,
custact.saledate  custact_saledate,
  cust.bill_chrg_id_bill  bill_chrg_id_bill ,
  cust.person_code_chrg_bill  person_code_chrg_bill ,
  cust.person_name_chrg_bill  person_name_chrg_bill ,
  opeitm.itm_classlist_id  itm_classlist_id ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
  cust.person_sect_id_chrg_bill  person_sect_id_chrg_bill ,
  cust.chrg_person_id_chrg_bill  chrg_person_id_chrg_bill ,
  cust.bill_crr_id_bill  bill_crr_id_bill ,
  cust.crr_code_bill  crr_code_bill ,
  cust.crr_name_bill  crr_name_bill ,
custact.shelfnos_id_fm   custact_shelfno_id_fm,
custact.opeitms_id   custact_opeitm_id,
  opeitm.loca_code_opeitm  loca_code_opeitm ,
  opeitm.loca_name_opeitm  loca_name_opeitm ,
  opeitm.shelfno_code_fm_opeitm  shelfno_code_fm_opeitm ,
  opeitm.shelfno_name_fm_opeitm  shelfno_name_fm_opeitm ,
  opeitm.shelfno_loca_id_shelfno_fm_opeitm  shelfno_loca_id_shelfno_fm_opeitm ,
  opeitm.loca_code_shelfno_fm_opeitm  loca_code_shelfno_fm_opeitm ,
  opeitm.loca_name_shelfno_fm_opeitm  loca_name_shelfno_fm_opeitm ,
  opeitm.shelfno_code_to_opeitm  shelfno_code_to_opeitm ,
  opeitm.shelfno_name_to_opeitm  shelfno_name_to_opeitm ,
  opeitm.shelfno_loca_id_shelfno_to_opeitm  shelfno_loca_id_shelfno_to_opeitm ,
  opeitm.loca_code_shelfno_to_opeitm  loca_code_shelfno_to_opeitm ,
  opeitm.loca_name_shelfno_to_opeitm  loca_name_shelfno_to_opeitm ,
  opeitm.unit_name_case_shp  unit_name_case_shp ,
  opeitm.unit_code_case_shp  unit_code_case_shp ,
  opeitm.unit_name_case_prdpur  unit_name_case_prdpur ,
  opeitm.unit_code_case_prdpur  unit_code_case_prdpur ,
custact.sno_custord  custact_sno_custord,
custact.sno_custinst  custact_sno_custinst,
custact.cno_custord  custact_cno_custord,
custact.cno_custinst  custact_cno_custinst,
custact.sno_custdlv  custact_sno_custdlv,
custact.cno_custdlv  custact_cno_custdlv,
custact.invoiceno  custact_invoiceno,
custact.cartonno  custact_cartonno
 from custacts   custact,
  r_custrcvplcs  custrcvplc ,  r_chrgs  chrg ,  r_persons  person_upd ,  r_custs  cust ,  r_shelfnos  shelfno_fm ,  r_opeitms  opeitm 
  where       custact.custrcvplcs_id = custrcvplc.id      and custact.chrgs_id = chrg.id      and custact.persons_id_upd = person_upd.id      and custact.custs_id = cust.id      and custact.shelfnos_id_fm = shelfno_fm.id      and custact.opeitms_id = opeitm.id     ;
 DROP TABLE IF EXISTS sio.sio_r_custacts;
 CREATE TABLE sio.sio_r_custacts (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_custacts_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,unit_code  varchar (50) 
,boxe_code  varchar (50) 
,classlist_code  varchar (50) 
,itm_code  varchar (50) 
,boxe_name  varchar (100) 
,itm_name  varchar (100) 
,classlist_name  varchar (100) 
,unit_name  varchar (100) 
,loca_code_cust  varchar (50) 
,loca_code_custrcvplc  varchar (50) 
,person_code_chrg_bill  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,unit_code_box  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,loca_code_opeitm  varchar (50) 
,crr_code_bill  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,person_code_chrg_cust  varchar (50) 
,unit_code_outbox  varchar (50) 
,shelfno_code_fm  varchar (50) 
,crr_code_cust  varchar (50) 
,loca_code_bill  varchar (50) 
,unit_code_case_shp  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,person_code_chrg  varchar (50) 
,loca_name_custrcvplc  varchar (100) 
,loca_name_cust  varchar (100) 
,person_name_chrg  varchar (100) 
,person_name_chrg_cust  varchar (100) 
,loca_name_bill  varchar (100) 
,crr_name_cust  varchar (100) 
,unit_name_box  varchar (100) 
,unit_name_outbox  varchar (100) 
,person_name_chrg_bill  varchar (100) 
,shelfno_name_fm  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,crr_name_bill  varchar (100) 
,loca_name_opeitm  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,unit_name_case_shp  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,opeitm_priority  numeric (3,0)
,custact_opeitm_id  numeric (38,0)
,custact_shelfno_id_fm  numeric (22,0)
,cust_crr_id_cust  numeric (38,0)
,custact_sno_custinst  varchar (50) 
,custact_sno_custdlv  varchar (50) 
,custact_cno_custord  varchar (50) 
,custact_chrg_id  numeric (38,0)
,custact_cno_custinst  varchar (50) 
,custact_invoiceno  varchar (50) 
,custact_sno_custord  varchar (50) 
,custact_cartonno  varchar (50) 
,custact_cno_custdlv  varchar (50) 
,custact_qty  numeric (18,4)
,custact_saledate   timestamp(6) 
,custact_sno  varchar (40) 
,custact_price  numeric (22,0)
,custact_remark  varchar (4000) 
,custact_expiredate   date 
,custact_isudate   timestamp(6) 
,custact_amt  numeric (18,4)
,custact_itm_code_client  varchar (50) 
,custact_contract_price  varchar (1) 
,opeitm_boxe_id  numeric (22,0)
,bill_chrg_id_bill  numeric (22,0)
,bill_loca_id_bill  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,person_sect_id_chrg_cust  numeric (22,0)
,chrg_person_id_chrg_cust  numeric (38,0)
,itm_unit_id  numeric (22,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,person_sect_id_chrg_bill  numeric (22,0)
,chrg_person_id_chrg_bill  numeric (38,0)
,bill_crr_id_bill  numeric (22,0)
,cust_chrg_id_cust  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,custrcvplc_loca_id_custrcvplc  numeric (38,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,cust_loca_id_cust  numeric (38,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,boxe_unit_id_outbox  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,cust_bill_id  numeric (38,0)
,custact_updated_at   timestamp(6) 
,custact_cust_id  numeric (22,0)
,custact_custrcvplc_id  numeric (22,0)
,custact_person_id_upd  numeric (22,0)
,custact_id  numeric (22,0)
,custact_update_ip  varchar (40) 
,custact_created_at   timestamp(6) 
,id  numeric (22,0)
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
 CREATE INDEX sio_r_custacts_uk1 
  ON sio.sio_r_custacts(id,sio_id); 

 drop sequence  if exists sio.sio_r_custacts_seq ;
 create sequence sio.sio_r_custacts_seq ;
  drop view if  exists r_custrets cascade ; 
 create or replace view r_custrets as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.unit_name  unit_name ,
  opeitm.unit_code  unit_code ,
  opeitm.opeitm_processseq  opeitm_processseq ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
  cust.loca_name_cust  loca_name_cust ,
  cust.loca_code_cust  loca_code_cust ,
  custrcvplc.loca_code_custrcvplc  loca_code_custrcvplc ,
  custrcvplc.loca_name_custrcvplc  loca_name_custrcvplc ,
custret.id id,
  cust.cust_loca_id_cust  cust_loca_id_cust ,
  opeitm.opeitm_operation  opeitm_operation ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  opeitm.opeitm_prdpurshp  opeitm_prdpurshp ,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  cust.cust_chrg_id_cust  cust_chrg_id_cust ,
  cust.person_code_chrg_cust  person_code_chrg_cust ,
  cust.person_name_chrg_cust  person_name_chrg_cust ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  cust.loca_code_bill  loca_code_bill ,
  cust.loca_name_bill  loca_name_bill ,
  cust.cust_bill_id  cust_bill_id ,
  cust.crr_name_cust  crr_name_cust ,
  cust.crr_code_cust  crr_code_cust ,
  opeitm.unit_code_box  unit_code_box ,
  opeitm.unit_name_box  unit_name_box ,
  opeitm.unit_code_outbox  unit_code_outbox ,
  opeitm.unit_name_outbox  unit_name_outbox ,
  opeitm.boxe_code  boxe_code ,
  opeitm.boxe_name  boxe_name ,
  cust.person_code_chrg_bill  person_code_chrg_bill ,
  cust.person_name_chrg_bill  person_name_chrg_bill ,
  shelfno_to.shelfno_code  shelfno_code_to ,
  shelfno_to.shelfno_name  shelfno_name_to ,
  shelfno_to.loca_code_shelfno  loca_code_shelfno_to ,
  shelfno_to.loca_name_shelfno  loca_name_shelfno_to ,
  shelfno_to.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_to ,
  cust.crr_code_bill  crr_code_bill ,
  cust.crr_name_bill  crr_name_bill ,
  opeitm.loca_code_opeitm  loca_code_opeitm ,
  opeitm.loca_name_opeitm  loca_name_opeitm ,
  opeitm.shelfno_code_fm_opeitm  shelfno_code_fm_opeitm ,
  opeitm.shelfno_name_fm_opeitm  shelfno_name_fm_opeitm ,
  opeitm.shelfno_loca_id_shelfno_fm_opeitm  shelfno_loca_id_shelfno_fm_opeitm ,
  opeitm.loca_code_shelfno_fm_opeitm  loca_code_shelfno_fm_opeitm ,
  opeitm.loca_name_shelfno_fm_opeitm  loca_name_shelfno_fm_opeitm ,
  opeitm.shelfno_code_to_opeitm  shelfno_code_to_opeitm ,
  opeitm.shelfno_name_to_opeitm  shelfno_name_to_opeitm ,
  opeitm.shelfno_loca_id_shelfno_to_opeitm  shelfno_loca_id_shelfno_to_opeitm ,
  opeitm.loca_code_shelfno_to_opeitm  loca_code_shelfno_to_opeitm ,
  opeitm.loca_name_shelfno_to_opeitm  loca_name_shelfno_to_opeitm ,
  opeitm.unit_name_case_shp  unit_name_case_shp ,
  opeitm.unit_code_case_shp  unit_code_case_shp ,
  opeitm.unit_name_case_prdpur  unit_name_case_prdpur ,
  opeitm.unit_code_case_prdpur  unit_code_case_prdpur ,
custret.cno_custact  custret_cno_custact,
custret.sno_custact  custret_sno_custact,
custret.remark  custret_remark,
custret.expiredate  custret_expiredate,
custret.update_ip  custret_update_ip,
custret.created_at  custret_created_at,
custret.updated_at  custret_updated_at,
custret.persons_id_upd   custret_person_id_upd,
custret.qty  custret_qty,
custret.price  custret_price,
custret.amt  custret_amt,
custret.sno  custret_sno,
custret.isudate  custret_isudate,
custret.custs_id   custret_cust_id,
custret.opeitms_id   custret_opeitm_id,
custret.contract_price  custret_contract_price,
custret.custrcvplcs_id   custret_custrcvplc_id,
custret.retdate  custret_retdate,
custret.itm_code_client  custret_itm_code_client,
custret.shelfnos_id_to   custret_shelfno_id_to,
custret.id  custret_id,
custret.chrgs_id   custret_chrg_id
 from custrets   custret,
  r_persons  person_upd ,  r_custs  cust ,  r_opeitms  opeitm ,  r_custrcvplcs  custrcvplc ,  r_shelfnos  shelfno_to ,  r_chrgs  chrg 
  where       custret.persons_id_upd = person_upd.id      and custret.custs_id = cust.id      and custret.opeitms_id = opeitm.id      and custret.custrcvplcs_id = custrcvplc.id      and custret.shelfnos_id_to = shelfno_to.id      and custret.chrgs_id = chrg.id     ;
 DROP TABLE IF EXISTS sio.sio_r_custrets;
 CREATE TABLE sio.sio_r_custrets (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_custrets_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,boxe_code  varchar (50) 
,unit_code  varchar (50) 
,classlist_code  varchar (50) 
,itm_code  varchar (50) 
,boxe_name  varchar (100) 
,itm_name  varchar (100) 
,classlist_name  varchar (100) 
,unit_name  varchar (100) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,person_code_chrg  varchar (50) 
,loca_code_cust  varchar (50) 
,loca_code_custrcvplc  varchar (50) 
,loca_code_bill  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,loca_code_opeitm  varchar (50) 
,crr_code_bill  varchar (50) 
,loca_code_shelfno_to  varchar (50) 
,shelfno_code_to  varchar (50) 
,person_code_chrg_bill  varchar (50) 
,person_code_chrg_cust  varchar (50) 
,unit_code_box  varchar (50) 
,crr_code_cust  varchar (50) 
,unit_code_outbox  varchar (50) 
,unit_code_case_shp  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,person_name_chrg  varchar (100) 
,loca_name_cust  varchar (100) 
,loca_name_custrcvplc  varchar (100) 
,person_name_chrg_cust  varchar (100) 
,loca_name_bill  varchar (100) 
,crr_name_cust  varchar (100) 
,unit_name_box  varchar (100) 
,unit_name_outbox  varchar (100) 
,person_name_chrg_bill  varchar (100) 
,shelfno_name_to  varchar (100) 
,loca_name_shelfno_to  varchar (100) 
,crr_name_bill  varchar (100) 
,loca_name_opeitm  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,unit_name_case_shp  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,custret_contract_price  varchar (1) 
,opeitm_operation  varchar (20) 
,custret_custrcvplc_id  numeric (38,0)
,custret_update_ip  varchar (40) 
,custret_created_at   timestamp(6) 
,custret_updated_at   timestamp(6) 
,custret_qty  numeric (22,6)
,custret_price  numeric (38,4)
,custret_amt  numeric (18,4)
,custret_sno  varchar (40) 
,custret_isudate   timestamp(6) 
,opeitm_prdpurshp  varchar (20) 
,custret_cust_id  numeric (38,0)
,custret_opeitm_id  numeric (38,0)
,custret_retdate   date 
,id  numeric (38,0)
,custret_itm_code_client  varchar (50) 
,custret_shelfno_id_to  numeric (38,0)
,custret_id  numeric (38,0)
,opeitm_priority  numeric (3,0)
,custret_chrg_id  numeric (38,0)
,opeitm_processseq  numeric (3,0)
,custret_cno_custact  varchar (50) 
,custret_sno_custact  varchar (50) 
,custret_remark  varchar (4000) 
,custret_expiredate   date 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,custret_person_id_upd  numeric (22,0)
,chrg_person_id_chrg  numeric (38,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,cust_bill_id  numeric (38,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,cust_chrg_id_cust  numeric (38,0)
,cust_loca_id_cust  numeric (38,0)
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
 CREATE INDEX sio_r_custrets_uk1 
  ON sio.sio_r_custrets(id,sio_id); 

 drop sequence  if exists sio.sio_r_custrets_seq ;
 create sequence sio.sio_r_custrets_seq ;
  drop view if  exists r_custdlvs cascade ; 
 create or replace view r_custdlvs as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.unit_name  unit_name ,
  opeitm.unit_code  unit_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
  cust.loca_name_cust  loca_name_cust ,
  cust.loca_code_cust  loca_code_cust ,
  custrcvplc.loca_code_custrcvplc  loca_code_custrcvplc ,
  custrcvplc.loca_name_custrcvplc  loca_name_custrcvplc ,
custdlv.id id,
  cust.cust_loca_id_cust  cust_loca_id_cust ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  custrcvplc.custrcvplc_loca_id_custrcvplc  custrcvplc_loca_id_custrcvplc ,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  cust.cust_chrg_id_cust  cust_chrg_id_cust ,
  cust.chrg_person_id_chrg_cust  chrg_person_id_chrg_cust ,
  cust.person_code_chrg_cust  person_code_chrg_cust ,
  cust.person_name_chrg_cust  person_name_chrg_cust ,
  cust.person_sect_id_chrg_cust  person_sect_id_chrg_cust ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  cust.bill_loca_id_bill  bill_loca_id_bill ,
  cust.loca_code_bill  loca_code_bill ,
  cust.loca_name_bill  loca_name_bill ,
  cust.cust_bill_id  cust_bill_id ,
  cust.crr_name_cust  crr_name_cust ,
  cust.cust_crr_id_cust  cust_crr_id_cust ,
  cust.crr_code_cust  crr_code_cust ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  opeitm.unit_code_box  unit_code_box ,
  opeitm.unit_name_box  unit_name_box ,
  opeitm.boxe_unit_id_outbox  boxe_unit_id_outbox ,
  opeitm.unit_code_outbox  unit_code_outbox ,
  opeitm.unit_name_outbox  unit_name_outbox ,
  opeitm.boxe_code  boxe_code ,
  opeitm.boxe_name  boxe_name ,
  opeitm.opeitm_boxe_id  opeitm_boxe_id ,
  cust.bill_chrg_id_bill  bill_chrg_id_bill ,
  cust.person_code_chrg_bill  person_code_chrg_bill ,
  cust.person_name_chrg_bill  person_name_chrg_bill ,
  opeitm.itm_classlist_id  itm_classlist_id ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
  cust.person_sect_id_chrg_bill  person_sect_id_chrg_bill ,
  cust.chrg_person_id_chrg_bill  chrg_person_id_chrg_bill ,
  cust.bill_crr_id_bill  bill_crr_id_bill ,
  cust.crr_code_bill  crr_code_bill ,
  cust.crr_name_bill  crr_name_bill ,
custdlv.custs_id   custdlv_cust_id,
custdlv.itm_code_client  custdlv_itm_code_client,
custdlv.cno  custdlv_cno,
custdlv.custrcvplcs_id   custdlv_custrcvplc_id,
custdlv.id  custdlv_id,
custdlv.gno  custdlv_gno,
custdlv.contract_price  custdlv_contract_price,
custdlv.starttime  custdlv_starttime,
custdlv.price  custdlv_price,
custdlv.expiredate  custdlv_expiredate,
custdlv.amt  custdlv_amt,
custdlv.isudate  custdlv_isudate,
custdlv.sno  custdlv_sno,
custdlv.remark  custdlv_remark,
custdlv.persons_id_upd   custdlv_person_id_upd,
custdlv.update_ip  custdlv_update_ip,
custdlv.created_at  custdlv_created_at,
custdlv.updated_at  custdlv_updated_at,
custdlv.shelfnos_id_fm   custdlv_shelfno_id_fm,
custdlv.opeitms_id   custdlv_opeitm_id,
  opeitm.loca_code_opeitm  loca_code_opeitm ,
  opeitm.loca_name_opeitm  loca_name_opeitm ,
  opeitm.shelfno_code_fm_opeitm  shelfno_code_fm_opeitm ,
  opeitm.shelfno_name_fm_opeitm  shelfno_name_fm_opeitm ,
  opeitm.shelfno_loca_id_shelfno_fm_opeitm  shelfno_loca_id_shelfno_fm_opeitm ,
  opeitm.loca_code_shelfno_fm_opeitm  loca_code_shelfno_fm_opeitm ,
  opeitm.loca_name_shelfno_fm_opeitm  loca_name_shelfno_fm_opeitm ,
  opeitm.shelfno_code_to_opeitm  shelfno_code_to_opeitm ,
  opeitm.shelfno_name_to_opeitm  shelfno_name_to_opeitm ,
  opeitm.shelfno_loca_id_shelfno_to_opeitm  shelfno_loca_id_shelfno_to_opeitm ,
  opeitm.loca_code_shelfno_to_opeitm  loca_code_shelfno_to_opeitm ,
  opeitm.loca_name_shelfno_to_opeitm  loca_name_shelfno_to_opeitm ,
  opeitm.unit_name_case_shp  unit_name_case_shp ,
  opeitm.unit_code_case_shp  unit_code_case_shp ,
  opeitm.unit_name_case_prdpur  unit_name_case_prdpur ,
  opeitm.unit_code_case_prdpur  unit_code_case_prdpur ,
custdlv.sno_custord  custdlv_sno_custord,
custdlv.sno_custinst  custdlv_sno_custinst,
custdlv.cno_custord  custdlv_cno_custord,
custdlv.cno_custinst  custdlv_cno_custinst,
custdlv.depdate  custdlv_depdate,
custdlv.cartonno  custdlv_cartonno,
custdlv.qty_stk  custdlv_qty_stk,
custdlv.qty_case  custdlv_qty_case,
custdlv.invoiceno  custdlv_invoiceno,
custdlv.chrgs_id   custdlv_chrg_id
 from custdlvs   custdlv,
  r_custs  cust ,  r_custrcvplcs  custrcvplc ,  r_persons  person_upd ,  r_shelfnos  shelfno_fm ,  r_opeitms  opeitm ,  r_chrgs  chrg 
  where       custdlv.custs_id = cust.id      and custdlv.custrcvplcs_id = custrcvplc.id      and custdlv.persons_id_upd = person_upd.id      and custdlv.shelfnos_id_fm = shelfno_fm.id      and custdlv.opeitms_id = opeitm.id      and custdlv.chrgs_id = chrg.id     ;
 DROP TABLE IF EXISTS sio.sio_r_custdlvs;
 CREATE TABLE sio.sio_r_custdlvs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_custdlvs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,unit_code  varchar (50) 
,boxe_code  varchar (50) 
,classlist_code  varchar (50) 
,itm_code  varchar (50) 
,boxe_name  varchar (100) 
,itm_name  varchar (100) 
,classlist_name  varchar (100) 
,unit_name  varchar (100) 
,loca_code_cust  varchar (50) 
,loca_code_custrcvplc  varchar (50) 
,person_code_chrg_bill  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,unit_code_box  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,loca_code_opeitm  varchar (50) 
,crr_code_bill  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,person_code_chrg_cust  varchar (50) 
,unit_code_outbox  varchar (50) 
,shelfno_code_fm  varchar (50) 
,crr_code_cust  varchar (50) 
,loca_code_bill  varchar (50) 
,unit_code_case_shp  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,person_code_chrg  varchar (50) 
,loca_name_custrcvplc  varchar (100) 
,loca_name_cust  varchar (100) 
,person_name_chrg  varchar (100) 
,person_name_chrg_cust  varchar (100) 
,loca_name_bill  varchar (100) 
,crr_name_cust  varchar (100) 
,unit_name_box  varchar (100) 
,unit_name_outbox  varchar (100) 
,person_name_chrg_bill  varchar (100) 
,shelfno_name_fm  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,crr_name_bill  varchar (100) 
,loca_name_opeitm  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,unit_name_case_shp  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,custdlv_remark  varchar (4000) 
,custdlv_updated_at   timestamp(6) 
,custdlv_update_ip  varchar (40) 
,custdlv_created_at   timestamp(6) 
,id  numeric (38,0)
,custdlv_opeitm_id  numeric (38,0)
,custdlv_shelfno_id_fm  numeric (22,0)
,cust_crr_id_cust  numeric (38,0)
,custdlv_cust_id  numeric (38,0)
,custdlv_itm_code_client  varchar (50) 
,custdlv_cno  varchar (40) 
,custdlv_custrcvplc_id  numeric (38,0)
,opeitm_priority  numeric (3,0)
,custdlv_gno  varchar (40) 
,custdlv_contract_price  varchar (1) 
,custdlv_starttime   timestamp(6) 
,custdlv_price  numeric (38,4)
,custdlv_expiredate   date 
,custdlv_amt  numeric (18,4)
,custdlv_isudate   timestamp(6) 
,custdlv_sno  varchar (40) 
,custdlv_sno_custord  varchar (50) 
,custdlv_sno_custinst  varchar (50) 
,custdlv_cno_custord  varchar (50) 
,custdlv_id  numeric (38,0)
,custdlv_cno_custinst  varchar (50) 
,custdlv_depdate   timestamp(6) 
,custdlv_cartonno  varchar (50) 
,custdlv_qty_stk  numeric (22,6)
,custdlv_qty_case  numeric (22,0)
,custdlv_invoiceno  varchar (50) 
,custdlv_chrg_id  numeric (38,0)
,bill_chrg_id_bill  numeric (22,0)
,cust_loca_id_cust  numeric (38,0)
,bill_loca_id_bill  numeric (38,0)
,chrg_person_id_chrg_bill  numeric (38,0)
,itm_unit_id  numeric (22,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,person_sect_id_chrg_cust  numeric (22,0)
,person_sect_id_chrg_bill  numeric (22,0)
,boxe_unit_id_outbox  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,chrg_person_id_chrg_cust  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,cust_bill_id  numeric (38,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,cust_chrg_id_cust  numeric (38,0)
,bill_crr_id_bill  numeric (22,0)
,chrg_person_id_chrg  numeric (38,0)
,opeitm_boxe_id  numeric (22,0)
,custrcvplc_loca_id_custrcvplc  numeric (38,0)
,custdlv_person_id_upd  numeric (22,0)
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
 CREATE INDEX sio_r_custdlvs_uk1 
  ON sio.sio_r_custdlvs(id,sio_id); 

 drop sequence  if exists sio.sio_r_custdlvs_seq ;
 create sequence sio.sio_r_custdlvs_seq ;
 ALTER TABLE custinsts ADD CONSTRAINT custinst_chrgs_id FOREIGN KEY (chrgs_id)
																		 REFERENCES chrgs (id);
 ALTER TABLE custords ADD CONSTRAINT custord_chrgs_id FOREIGN KEY (chrgs_id)
																		 REFERENCES chrgs (id);
 ALTER TABLE custords ADD CONSTRAINT custord_crrs_id FOREIGN KEY (crrs_id)
																		 REFERENCES crrs (id);
 ALTER TABLE custacts ADD CONSTRAINT custact_chrgs_id FOREIGN KEY (chrgs_id)
																		 REFERENCES chrgs (id);
 ALTER TABLE custrets ADD CONSTRAINT custret_chrgs_id FOREIGN KEY (chrgs_id)
																		 REFERENCES chrgs (id);
 ALTER TABLE custdlvs ADD CONSTRAINT custdlv_chrgs_id FOREIGN KEY (chrgs_id)
																		 REFERENCES chrgs (id);
