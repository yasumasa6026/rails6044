
 alter table  trngantts  ADD COLUMN shelfnos_id_to_pare numeric(22,0)  DEFAULT 0  not null;

  drop view if  exists r_trngantts cascade ; 
 create or replace view r_trngantts as select  
trngantt.id id,
  prjno.prjno_name  prjno_name ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  itm_pare.itm_code  itm_code_pare ,
  itm_pare.itm_name  itm_name_pare ,
  itm_pare.itm_unit_id  itm_unit_id_pare ,
  itm_pare.unit_code  unit_code_pare ,
  itm_pare.unit_name  unit_name_pare ,
trngantt.processseq_pare  trngantt_processseq_pare,
trngantt.qty_alloc  trngantt_qty_alloc,
trngantt.orgtblname  trngantt_orgtblname,
trngantt.orgtblid  trngantt_orgtblid,
trngantt.id  trngantt_id,
trngantt.persons_id_upd   trngantt_person_id_upd,
trngantt.itms_id_pare   trngantt_itm_id_pare,
trngantt.parenum  trngantt_parenum,
trngantt.chilnum  trngantt_chilnum,
trngantt.expiredate  trngantt_expiredate,
trngantt.updated_at  trngantt_updated_at,
trngantt.qty  trngantt_qty,
trngantt.remark  trngantt_remark,
trngantt.created_at  trngantt_created_at,
trngantt.update_ip  trngantt_update_ip,
trngantt.tblid  trngantt_tblid,
trngantt.tblname  trngantt_tblname,
trngantt.key  trngantt_key,
trngantt.mlevel  trngantt_mlevel,
trngantt.qty_stk  trngantt_qty_stk,
  itm_trn.unit_code  unit_code_trn ,
  itm_trn.unit_name  unit_name_trn ,
  loca_org.loca_code  loca_code_org ,
  loca_org.loca_name  loca_name_org ,
  loca_trn.loca_code  loca_code_trn ,
  loca_trn.loca_name  loca_name_trn ,
  itm_org.itm_code  itm_code_org ,
  itm_org.itm_name  itm_name_org ,
  itm_org.unit_code  unit_code_org ,
  itm_org.unit_name  unit_name_org ,
  itm_trn.itm_code  itm_code_trn ,
  itm_trn.itm_name  itm_name_trn ,
  prjno.prjno_code  prjno_code ,
trngantt.prjnos_id   trngantt_prjno_id,
  chrg_org.chrg_person_id_chrg  chrg_person_id_chrg_org ,
  chrg_org.person_code_chrg  person_code_chrg_org ,
  chrg_org.person_name_chrg  person_name_chrg_org ,
  chrg_trn.chrg_person_id_chrg  chrg_person_id_chrg_trn ,
  chrg_trn.person_code_chrg  person_code_chrg_trn ,
  chrg_trn.person_name_chrg  person_name_chrg_trn ,
  loca_pare.loca_code  loca_code_pare ,
  loca_pare.loca_name  loca_name_pare ,
  prjno.prjno_code_chil  prjno_code_chil ,
trngantt.shuffle_flg  trngantt_shuffle_flg,
trngantt.consumunitqty  trngantt_consumunitqty,
trngantt.paretblname  trngantt_paretblname,
trngantt.paretblid  trngantt_paretblid,
trngantt.consumminqty  trngantt_consumminqty,
trngantt.consumchgoverqty  trngantt_consumchgoverqty,
trngantt.locas_id_pare   trngantt_loca_id_pare,
  itm_pare.itm_classlist_id  itm_classlist_id_pare ,
  itm_pare.classlist_name  classlist_name_pare ,
  itm_pare.classlist_code  classlist_code_pare ,
trngantt.qty_stk_pare  trngantt_qty_stk_pare,
trngantt.qty_pare  trngantt_qty_pare,
  shelfno_to.shelfno_code  shelfno_code_to ,
  shelfno_to.shelfno_name  shelfno_name_to ,
  shelfno_to.loca_code_shelfno  loca_code_shelfno_to ,
  shelfno_to.loca_name_shelfno  loca_name_shelfno_to ,
  shelfno_to.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_to ,
trngantt.qty_pare_alloc  trngantt_qty_pare_alloc,
trngantt.duedate_org  trngantt_duedate_org,
  itm_org.itm_classlist_id  itm_classlist_id_org ,
  itm_org.classlist_code  classlist_code_org ,
  itm_org.classlist_name  classlist_name_org ,
  itm_trn.itm_classlist_id  itm_classlist_id_trn ,
  itm_trn.classlist_code  classlist_code_trn ,
  itm_trn.classlist_name  classlist_name_trn ,
trngantt.qty_handover  trngantt_qty_handover,
trngantt.qty_bal  trngantt_qty_bal,
trngantt.qty_pare_bal  trngantt_qty_pare_bal,
trngantt.qty_sch  trngantt_qty_sch,
  prjno.prjno_name_chil  prjno_name_chil ,
trngantt.mkords_id_trngantt   trngantt_mkord_id_trngantt,
  mkord_trngantt.mkord_message_code  mkord_message_code_trngantt ,
  mkord_trngantt.mkord_sno_org  mkord_sno_org_trngantt ,
  mkord_trngantt.mkord_tblname  mkord_tblname_trngantt ,
  mkord_trngantt.mkord_sno_pare  mkord_sno_pare_trngantt ,
  mkord_trngantt.mkord_itm_code_pare  mkord_itm_code_pare_trngantt ,
trngantt.starttime_org  trngantt_starttime_org,
trngantt.starttime_pare  trngantt_starttime_pare,
trngantt.itms_id_org   trngantt_itm_id_org,
trngantt.locas_id_org   trngantt_loca_id_org,
trngantt.duedate_trn  trngantt_duedate_trn,
trngantt.duedate_pare  trngantt_duedate_pare,
trngantt.starttime_trn  trngantt_starttime_trn,
trngantt.chrgs_id_pare   trngantt_chrg_id_pare,
  chrg_pare.person_name_chrg  person_name_chrg_pare ,
  chrg_pare.person_code_chrg  person_code_chrg_pare ,
  chrg_pare.chrg_person_id_chrg  chrg_person_id_chrg_pare ,
trngantt.chrgs_id_org   trngantt_chrg_id_org,
trngantt.chrgs_id_trn   trngantt_chrg_id_trn,
trngantt.processseq_org  trngantt_processseq_org,
trngantt.locas_id_trn   trngantt_loca_id_trn,
trngantt.itms_id_trn   trngantt_itm_id_trn,
trngantt.processseq_trn  trngantt_processseq_trn,
  mkord_trngantt.mkord_itm_code_trn  mkord_itm_code_trn_trngantt ,
  mkord_trngantt.mkord_itm_code_org  mkord_itm_code_org_trngantt ,
  mkord_trngantt.mkord_itm_name_org  mkord_itm_name_org_trngantt ,
  mkord_trngantt.mkord_itm_name_trn  mkord_itm_name_trn_trngantt ,
  mkord_trngantt.mkord_person_code_chrg_trn  mkord_person_code_chrg_trn_trngantt ,
  mkord_trngantt.mkord_person_name_chrg_trn  mkord_person_name_chrg_trn_trngantt ,
  mkord_trngantt.mkord_loca_code_pare  mkord_loca_code_pare_trngantt ,
  mkord_trngantt.mkord_loca_code_trn  mkord_loca_code_trn_trngantt ,
  mkord_trngantt.mkord_loca_name_trn  mkord_loca_name_trn_trngantt ,
  mkord_trngantt.mkord_loca_name_pare  mkord_loca_name_pare_trngantt ,
  mkord_trngantt.mkord_itm_name_pare  mkord_itm_name_pare_trngantt ,
  mkord_trngantt.mkord_loca_name_org  mkord_loca_name_org_trngantt ,
  mkord_trngantt.mkord_loca_name_to_trn  mkord_loca_name_to_trn_trngantt ,
  mkord_trngantt.mkord_person_code_chrg_org  mkord_person_code_chrg_org_trngantt ,
  mkord_trngantt.mkord_person_code_chrg_pare  mkord_person_code_chrg_pare_trngantt ,
  mkord_trngantt.mkord_person_name_chrg_org  mkord_person_name_chrg_org_trngantt ,
  mkord_trngantt.mkord_person_name_chrg_pare  mkord_person_name_chrg_pare_trngantt ,
trngantt.qty_require  trngantt_qty_require,
trngantt.shelfnos_id_to   trngantt_shelfno_id_to,
trngantt.qty_free  trngantt_qty_free,
trngantt.shelfnos_id_to_pare   trngantt_shelfno_id_to_pare,
  shelfno_to_pare.shelfno_code  shelfno_code_to_pare ,
  shelfno_to_pare.shelfno_name  shelfno_name_to_pare ,
  shelfno_to_pare.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_to_pare ,
  shelfno_to_pare.loca_code_shelfno  loca_code_shelfno_to_pare ,
  shelfno_to_pare.loca_name_shelfno  loca_name_shelfno_to_pare 
 from trngantts   trngantt,
  r_persons  person_upd ,  r_itms  itm_pare ,  r_prjnos  prjno ,  r_locas  loca_pare ,  r_mkords  mkord_trngantt ,  r_itms  itm_org ,  r_locas  loca_org ,  r_chrgs  chrg_pare ,  r_chrgs  chrg_org ,  r_chrgs  chrg_trn ,  r_locas  loca_trn ,  r_itms  itm_trn ,  r_shelfnos  shelfno_to ,  r_shelfnos  shelfno_to_pare 
  where       trngantt.persons_id_upd = person_upd.id      and trngantt.itms_id_pare = itm_pare.id      and trngantt.prjnos_id = prjno.id      and trngantt.locas_id_pare = loca_pare.id      and trngantt.mkords_id_trngantt = mkord_trngantt.id      and trngantt.itms_id_org = itm_org.id      and trngantt.locas_id_org = loca_org.id      and trngantt.chrgs_id_pare = chrg_pare.id      and trngantt.chrgs_id_org = chrg_org.id      and trngantt.chrgs_id_trn = chrg_trn.id      and trngantt.locas_id_trn = loca_trn.id      and trngantt.itms_id_trn = itm_trn.id      and trngantt.shelfnos_id_to = shelfno_to.id      and trngantt.shelfnos_id_to_pare = shelfno_to_pare.id     ;
 DROP TABLE IF EXISTS sio.sio_r_trngantts;
 CREATE TABLE sio.sio_r_trngantts (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_trngantts_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,trngantt_orgtblname  varchar (30) 
,trngantt_orgtblid  numeric (22,0)
,trngantt_paretblname  varchar (30) 
,trngantt_paretblid  numeric (38,0)
,trngantt_tblname  varchar (30) 
,trngantt_tblid  numeric (38,0)
,trngantt_qty  numeric (18,4)
,trngantt_qty_stk  numeric (22,0)
,trngantt_qty_alloc  numeric (22,6)
,trngantt_qty_pare  numeric (22,6)
,trngantt_qty_stk_pare  numeric (22,6)
,trngantt_qty_pare_alloc  numeric (22,6)
,trngantt_consumminqty  numeric (22,6)
,trngantt_consumunitqty  numeric (22,6)
,trngantt_consumchgoverqty  numeric (22,6)
,trngantt_qty_pare_bal  numeric (22,6)
,trngantt_processseq_pare  numeric (38,0)
,trngantt_key  varchar (250) 
,trngantt_mlevel  numeric (3,0)
,mkord_person_code_chrg_org_trngantt  varchar (50) 
,unit_code_org  varchar (50) 
,unit_code_pare  varchar (50) 
,itm_code_trn  varchar (50) 
,shelfno_code_to_pare  varchar (50) 
,classlist_code_org  varchar (50) 
,loca_code_shelfno_to  varchar (50) 
,person_code_chrg_org  varchar (50) 
,person_code_chrg_trn  varchar (50) 
,shelfno_code_to  varchar (50) 
,loca_code_pare  varchar (50) 
,classlist_code_pare  varchar (50) 
,mkord_loca_code_trn_trngantt  varchar (50) 
,mkord_loca_code_pare_trngantt  varchar (50) 
,mkord_person_code_chrg_trn_trngantt  varchar (50) 
,mkord_itm_code_org_trngantt  varchar (50) 
,mkord_itm_code_trn_trngantt  varchar (50) 
,person_code_chrg_pare  varchar (50) 
,mkord_itm_code_pare_trngantt  varchar (50) 
,mkord_message_code_trngantt  varchar (256) 
,classlist_code_trn  varchar (50) 
,unit_code_trn  varchar (50) 
,mkord_person_code_chrg_pare_trngantt  varchar (50) 
,loca_code_org  varchar (50) 
,itm_code_pare  varchar (50) 
,loca_code_trn  varchar (50) 
,loca_code_shelfno_to_pare  varchar (50) 
,itm_code_org  varchar (50) 
,loca_name_shelfno_to_pare  varchar (100) 
,itm_name_pare  varchar (100) 
,unit_name_pare  varchar (100) 
,unit_name_trn  varchar (100) 
,loca_name_org  varchar (100) 
,loca_name_trn  varchar (100) 
,itm_name_org  varchar (100) 
,unit_name_org  varchar (100) 
,itm_name_trn  varchar (100) 
,person_name_chrg_org  varchar (100) 
,person_name_chrg_trn  varchar (100) 
,loca_name_pare  varchar (100) 
,classlist_name_pare  varchar (100) 
,shelfno_name_to  varchar (100) 
,loca_name_shelfno_to  varchar (100) 
,classlist_name_org  varchar (100) 
,classlist_name_trn  varchar (100) 
,prjno_name_chil  varchar (100) 
,person_name_chrg_pare  varchar (100) 
,mkord_itm_name_org_trngantt  varchar (100) 
,mkord_itm_name_trn_trngantt  varchar (100) 
,mkord_person_name_chrg_trn_trngantt  varchar (100) 
,mkord_loca_name_trn_trngantt  varchar (100) 
,mkord_loca_name_pare_trngantt  varchar (100) 
,mkord_itm_name_pare_trngantt  varchar (100) 
,mkord_loca_name_org_trngantt  varchar (100) 
,mkord_loca_name_to_trn_trngantt  varchar (100) 
,mkord_person_name_chrg_org_trngantt  varchar (100) 
,mkord_person_name_chrg_pare_trngantt  varchar (100) 
,shelfno_name_to_pare  varchar (100) 
,trngantt_qty_bal  numeric (22,6)
,mkord_sno_org_trngantt  varchar (50) 
,trngantt_duedate_org   timestamp(6) 
,trngantt_qty_sch  numeric (22,6)
,mkord_sno_pare_trngantt  varchar (50) 
,trngantt_qty_handover  numeric (22,6)
,trngantt_mkord_id_trngantt  numeric (22,0)
,mkord_tblname_trngantt  varchar (20) 
,trngantt_starttime_org   timestamp(6) 
,trngantt_starttime_pare   timestamp(6) 
,trngantt_itm_id_org  numeric (38,0)
,trngantt_loca_id_org  numeric (38,0)
,trngantt_duedate_trn   timestamp(6) 
,trngantt_duedate_pare   timestamp(6) 
,trngantt_starttime_trn  varchar (18) 
,trngantt_chrg_id_pare  numeric (22,0)
,trngantt_chrg_id_org  numeric (38,0)
,trngantt_chrg_id_trn  numeric (38,0)
,trngantt_processseq_org  numeric (22,0)
,trngantt_loca_id_trn  numeric (38,0)
,trngantt_itm_id_trn  numeric (38,0)
,trngantt_processseq_trn  numeric (38,0)
,trngantt_qty_require  numeric (22,6)
,trngantt_shelfno_id_to  numeric (38,0)
,trngantt_qty_free  numeric (22,6)
,trngantt_shelfno_id_to_pare  numeric (22,0)
,trngantt_parenum  numeric (22,0)
,trngantt_chilnum  numeric (22,0)
,trngantt_shuffle_flg  varchar (1) 
,prjno_code  varchar (50) 
,prjno_name  varchar (100) 
,trngantt_expiredate   date 
,trngantt_remark  varchar (4000) 
,itm_classlist_id_pare  numeric (38,0)
,itm_classlist_id_trn  numeric (38,0)
,trngantt_loca_id_pare  numeric (38,0)
,itm_classlist_id_org  numeric (38,0)
,shelfno_loca_id_shelfno_to_pare  numeric (38,0)
,trngantt_itm_id_pare  numeric (38,0)
,trngantt_person_id_upd  numeric (38,0)
,trngantt_id  numeric (38,0)
,itm_unit_id_pare  numeric (22,0)
,trngantt_updated_at   timestamp(6) 
,trngantt_update_ip  varchar (40) 
,chrg_person_id_chrg_org  numeric (38,0)
,chrg_person_id_chrg_pare  numeric (38,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,trngantt_prjno_id  numeric (38,0)
,chrg_person_id_chrg_trn  numeric (38,0)
,prjno_code_chil  varchar (50) 
,person_code_upd  varchar (50) 
,trngantt_created_at  numeric (22,0)
,id  numeric (38,0)
,person_name_upd  varchar (100) 
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
 CREATE INDEX sio_r_trngantts_uk1 
  ON sio.sio_r_trngantts(id,sio_id); 

 drop sequence  if exists sio.sio_r_trngantts_seq ;
 create sequence sio.sio_r_trngantts_seq ;
 ALTER TABLE trngantts ADD CONSTRAINT trngantt_shelfnos_id_to_pare FOREIGN KEY (shelfnos_id_to_pare)
																		 REFERENCES shelfnos (id);
