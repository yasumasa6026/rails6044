
 create table mkprdpurords (
 processseq_org numeric(22,0 )   ,
 id numeric(38,0 )   not null  ,
 remark varchar(4000)   ,
 expiredate date  ,
 update_ip varchar(40)   ,
 created_at timestamp(6)  ,
 updated_at timestamp(6)  ,
 persons_id_upd numeric(38,0 )   not null ,
 isudate timestamp(6)  ,
 tblname varchar(30)   ,
 cmpldate timestamp(6)  ,
 runtime numeric(2,0 )   ,
 result_f char(1)   ,
 message_code varchar(256)   ,
 orgtblname varchar(30)   ,
 manual char(1)   ,
 processseq_pare numeric(38,0 )   ,
 sno_org varchar(50)   ,
 duedate_trn timestamp(6)  ,
 confirm char(1)   ,
 incnt numeric(38,0 )   ,
 outcnt numeric(38,0 )   ,
 inqty numeric(22,6 )   ,
 outqty numeric(22,6 )   ,
 inamt numeric(38,4 )   ,
 outamt numeric(38,4 )   ,
 skipcnt numeric(38,0 )   ,
 skipqty numeric(22,6 )   ,
 skipamt numeric(38,4 )   ,
 itm_code_pare varchar(50)   ,
 itm_code_trn varchar(50)   ,
 sno_pare varchar(50)   ,
 duedate_pare timestamp(6)  ,
 itm_code_org varchar(50)   ,
 itm_name_org varchar(100)   ,
 itm_name_trn varchar(100)   ,
 itm_name_pare varchar(100)   ,
 person_code_chrg_org varchar(50)   ,
 person_code_chrg_pare varchar(50)   ,
 person_code_chrg_trn varchar(50)   ,
 person_name_chrg_org varchar(100)   ,
 person_name_chrg_pare varchar(100)   ,
 person_name_chrg_trn varchar(100)   ,
 loca_code_pare varchar(50)   ,
 loca_code_trn varchar(50)   ,
 loca_name_trn varchar(100)   ,
 loca_name_pare varchar(100)   ,
 paretblname varchar(30)   ,
 duedate_org timestamp(6)  ,
 starttime_trn timestamp(6)  ,
 processseq_trn numeric(38,0 )   ,
 loca_code_org varchar(50)   ,
 loca_name_org varchar(100)   ,
 loca_name_to_trn varchar(100)   ,
  CONSTRAINT mkprdpurords_id_pk PRIMARY KEY (id));
  drop view if  exists r_mkprdpurords cascade ; 
 create or replace view r_mkprdpurords as select  
mkprdpurord.id id,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
mkprdpurord.processseq_org  mkprdpurord_processseq_org,
mkprdpurord.id  mkprdpurord_id,
mkprdpurord.remark  mkprdpurord_remark,
mkprdpurord.expiredate  mkprdpurord_expiredate,
mkprdpurord.update_ip  mkprdpurord_update_ip,
mkprdpurord.created_at  mkprdpurord_created_at,
mkprdpurord.updated_at  mkprdpurord_updated_at,
mkprdpurord.persons_id_upd   mkprdpurord_person_id_upd,
mkprdpurord.isudate  mkprdpurord_isudate,
mkprdpurord.tblname  mkprdpurord_tblname,
mkprdpurord.cmpldate  mkprdpurord_cmpldate,
mkprdpurord.runtime  mkprdpurord_runtime,
mkprdpurord.result_f  mkprdpurord_result_f,
mkprdpurord.message_code  mkprdpurord_message_code,
mkprdpurord.orgtblname  mkprdpurord_orgtblname,
mkprdpurord.manual  mkprdpurord_manual,
mkprdpurord.processseq_pare  mkprdpurord_processseq_pare,
mkprdpurord.sno_org  mkprdpurord_sno_org,
mkprdpurord.duedate_trn  mkprdpurord_duedate_trn,
mkprdpurord.confirm  mkprdpurord_confirm,
mkprdpurord.incnt  mkprdpurord_incnt,
mkprdpurord.outcnt  mkprdpurord_outcnt,
mkprdpurord.inqty  mkprdpurord_inqty,
mkprdpurord.outqty  mkprdpurord_outqty,
mkprdpurord.inamt  mkprdpurord_inamt,
mkprdpurord.outamt  mkprdpurord_outamt,
mkprdpurord.skipcnt  mkprdpurord_skipcnt,
mkprdpurord.skipqty  mkprdpurord_skipqty,
mkprdpurord.skipamt  mkprdpurord_skipamt,
mkprdpurord.itm_code_pare  mkprdpurord_itm_code_pare,
mkprdpurord.itm_code_trn  mkprdpurord_itm_code_trn,
mkprdpurord.sno_pare  mkprdpurord_sno_pare,
mkprdpurord.duedate_pare  mkprdpurord_duedate_pare,
mkprdpurord.itm_code_org  mkprdpurord_itm_code_org,
mkprdpurord.itm_name_org  mkprdpurord_itm_name_org,
mkprdpurord.itm_name_trn  mkprdpurord_itm_name_trn,
mkprdpurord.itm_name_pare  mkprdpurord_itm_name_pare,
mkprdpurord.person_code_chrg_org  mkprdpurord_person_code_chrg_org,
mkprdpurord.person_code_chrg_pare  mkprdpurord_person_code_chrg_pare,
mkprdpurord.person_code_chrg_trn  mkprdpurord_person_code_chrg_trn,
mkprdpurord.person_name_chrg_org  mkprdpurord_person_name_chrg_org,
mkprdpurord.person_name_chrg_pare  mkprdpurord_person_name_chrg_pare,
mkprdpurord.person_name_chrg_trn  mkprdpurord_person_name_chrg_trn,
mkprdpurord.loca_code_pare  mkprdpurord_loca_code_pare,
mkprdpurord.loca_code_trn  mkprdpurord_loca_code_trn,
mkprdpurord.loca_name_trn  mkprdpurord_loca_name_trn,
mkprdpurord.loca_name_pare  mkprdpurord_loca_name_pare,
mkprdpurord.paretblname  mkprdpurord_paretblname,
mkprdpurord.duedate_org  mkprdpurord_duedate_org,
mkprdpurord.starttime_trn  mkprdpurord_starttime_trn,
mkprdpurord.processseq_trn  mkprdpurord_processseq_trn,
mkprdpurord.loca_code_org  mkprdpurord_loca_code_org,
mkprdpurord.loca_name_org  mkprdpurord_loca_name_org,
mkprdpurord.loca_name_to_trn  mkprdpurord_loca_name_to_trn
 from mkprdpurords   mkprdpurord,
  r_persons  person_upd 
  where       mkprdpurord.persons_id_upd = person_upd.id     ;
 DROP TABLE IF EXISTS sio.sio_r_mkprdpurords;
 CREATE TABLE sio.sio_r_mkprdpurords (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_mkprdpurords_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,mkprdpurord_loca_name_to_trn  varchar (100) 
,mkprdpurord_starttime_trn   timestamp(6) 
,mkprdpurord_processseq_trn  numeric (38,0)
,mkprdpurord_loca_code_org  varchar (50) 
,mkprdpurord_loca_name_org  varchar (100) 
,mkprdpurord_processseq_org  numeric (22,0)
,mkprdpurord_id  numeric (38,0)
,mkprdpurord_remark  varchar (4000) 
,mkprdpurord_expiredate   date 
,mkprdpurord_update_ip  varchar (40) 
,mkprdpurord_created_at   timestamp(6) 
,mkprdpurord_updated_at   timestamp(6) 
,mkprdpurord_isudate   timestamp(6) 
,mkprdpurord_tblname  varchar (30) 
,mkprdpurord_cmpldate   timestamp(6) 
,mkprdpurord_runtime  numeric (2,0)
,mkprdpurord_result_f  varchar (1) 
,mkprdpurord_message_code  varchar (256) 
,mkprdpurord_orgtblname  varchar (30) 
,mkprdpurord_manual  varchar (1) 
,mkprdpurord_processseq_pare  numeric (38,0)
,mkprdpurord_sno_org  varchar (50) 
,mkprdpurord_duedate_trn   timestamp(6) 
,mkprdpurord_confirm  varchar (1) 
,mkprdpurord_incnt  numeric (38,0)
,mkprdpurord_outcnt  numeric (38,0)
,mkprdpurord_inqty  numeric (22,6)
,mkprdpurord_outqty  numeric (22,6)
,mkprdpurord_inamt  numeric (38,4)
,mkprdpurord_outamt  numeric (38,4)
,mkprdpurord_skipcnt  numeric (38,0)
,mkprdpurord_skipqty  numeric (22,6)
,mkprdpurord_skipamt  numeric (38,4)
,mkprdpurord_itm_code_pare  varchar (50) 
,mkprdpurord_itm_code_trn  varchar (50) 
,mkprdpurord_sno_pare  varchar (50) 
,mkprdpurord_duedate_pare   timestamp(6) 
,mkprdpurord_itm_code_org  varchar (50) 
,mkprdpurord_itm_name_org  varchar (100) 
,mkprdpurord_itm_name_trn  varchar (100) 
,mkprdpurord_itm_name_pare  varchar (100) 
,mkprdpurord_person_code_chrg_org  varchar (50) 
,mkprdpurord_person_code_chrg_pare  varchar (50) 
,mkprdpurord_person_code_chrg_trn  varchar (50) 
,mkprdpurord_person_name_chrg_org  varchar (100) 
,mkprdpurord_person_name_chrg_pare  varchar (100) 
,mkprdpurord_person_name_chrg_trn  varchar (100) 
,mkprdpurord_loca_code_pare  varchar (50) 
,mkprdpurord_loca_code_trn  varchar (50) 
,mkprdpurord_loca_name_trn  varchar (100) 
,mkprdpurord_loca_name_pare  varchar (100) 
,mkprdpurord_paretblname  varchar (30) 
,mkprdpurord_duedate_org   timestamp(6) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,id  numeric (38,0)
,mkprdpurord_person_id_upd  numeric (22,0)
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
 CREATE INDEX sio_r_mkprdpurords_uk1 
  ON sio.sio_r_mkprdpurords(id,sio_id); 

 drop sequence  if exists sio.sio_r_mkprdpurords_seq ;
 create sequence sio.sio_r_mkprdpurords_seq ;
 ALTER TABLE mkprdpurords ADD CONSTRAINT mkprdpurord_persons_id_upd FOREIGN KEY (persons_id_upd)
																		 REFERENCES persons (id);
 create sequence mkprdpurords_seq ;
