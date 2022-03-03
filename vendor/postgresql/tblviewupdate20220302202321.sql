
 alter table  custinsts  ADD COLUMN chrgs_id numeric(38,0)  DEFAULT 0  not null;

 alter table custinsts DROP COLUMN chrgs_id_custord CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'chrgs_id_custord'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　chrgs_id_custordが削除　2022-03-02 20:23:12 +0900' 
 ---- where  pobject_code_sfd = 'chrgs_id_custord'
 alter table  custords  ADD COLUMN chrgs_id numeric(38,0)  DEFAULT 0  not null;

 alter table  custords  ADD COLUMN crrs_id numeric(22,0)  DEFAULT 0  not null;

 alter table custords DROP COLUMN chrgs_id_custord CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'chrgs_id_custord'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　chrgs_id_custordが削除　2022-03-02 20:23:13 +0900' 
 ---- where  pobject_code_sfd = 'chrgs_id_custord'
 alter table custords DROP COLUMN crrs_id_custord CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'crrs_id_custord'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　crrs_id_custordが削除　2022-03-02 20:23:13 +0900' 
 ---- where  pobject_code_sfd = 'crrs_id_custord'
 alter table  custacts  ADD COLUMN chrgs_id numeric(38,0)  DEFAULT 0  not null;

 alter table custacts DROP COLUMN chrgs_id_custord CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'chrgs_id_custord'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　chrgs_id_custordが削除　2022-03-02 20:23:13 +0900' 
 ---- where  pobject_code_sfd = 'chrgs_id_custord'
 alter table  custrets  ADD COLUMN chrgs_id numeric(38,0)  DEFAULT 0  not null;

 alter table custrets DROP COLUMN chrgs_id_custord CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'chrgs_id_custord'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　chrgs_id_custordが削除　2022-03-02 20:23:13 +0900' 
 ---- where  pobject_code_sfd = 'chrgs_id_custord'
 alter table  custdlvs  ADD COLUMN chrgs_id numeric(38,0)  DEFAULT 0  not null;

 alter table custdlvs DROP COLUMN chrgs_id_custord CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'chrgs_id_custord'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　chrgs_id_custordが削除　2022-03-02 20:23:13 +0900' 
 ---- where  pobject_code_sfd = 'chrgs_id_custord'
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
