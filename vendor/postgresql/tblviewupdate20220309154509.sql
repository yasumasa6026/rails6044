
 alter table  mkprdpurords  ADD COLUMN trngantts_id_mkprdpurord numeric(22,0)  DEFAULT 0  not null;

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
mkprdpurord.loca_name_to_trn  mkprdpurord_loca_name_to_trn,
mkprdpurord.trngantts_id_mkprdpurord   mkprdpurord_trngantt_id_mkprdpurord,
  trngantt_mkprdpurord.prjno_name  prjno_name_mkprdpurord ,
  trngantt_mkprdpurord.itm_code_pare  itm_code_pare_mkprdpurord ,
  trngantt_mkprdpurord.itm_name_pare  itm_name_pare_mkprdpurord ,
  trngantt_mkprdpurord.unit_code_pare  unit_code_pare_mkprdpurord ,
  trngantt_mkprdpurord.unit_name_pare  unit_name_pare_mkprdpurord ,
  trngantt_mkprdpurord.trngantt_itm_id_pare  trngantt_itm_id_pare_mkprdpurord ,
  trngantt_mkprdpurord.unit_code_trn  unit_code_trn_mkprdpurord ,
  trngantt_mkprdpurord.unit_name_trn  unit_name_trn_mkprdpurord ,
  trngantt_mkprdpurord.loca_code_org  loca_code_org_mkprdpurord ,
  trngantt_mkprdpurord.loca_name_org  loca_name_org_mkprdpurord ,
  trngantt_mkprdpurord.loca_code_trn  loca_code_trn_mkprdpurord ,
  trngantt_mkprdpurord.loca_name_trn  loca_name_trn_mkprdpurord ,
  trngantt_mkprdpurord.itm_code_org  itm_code_org_mkprdpurord ,
  trngantt_mkprdpurord.itm_name_org  itm_name_org_mkprdpurord ,
  trngantt_mkprdpurord.unit_code_org  unit_code_org_mkprdpurord ,
  trngantt_mkprdpurord.unit_name_org  unit_name_org_mkprdpurord ,
  trngantt_mkprdpurord.itm_code_trn  itm_code_trn_mkprdpurord ,
  trngantt_mkprdpurord.itm_name_trn  itm_name_trn_mkprdpurord ,
  trngantt_mkprdpurord.prjno_code  prjno_code_mkprdpurord ,
  trngantt_mkprdpurord.trngantt_prjno_id  trngantt_prjno_id_mkprdpurord ,
  trngantt_mkprdpurord.chrg_person_id_chrg_org  chrg_person_id_chrg_org_mkprdpurord ,
  trngantt_mkprdpurord.person_code_chrg_org  person_code_chrg_org_mkprdpurord ,
  trngantt_mkprdpurord.person_name_chrg_org  person_name_chrg_org_mkprdpurord ,
  trngantt_mkprdpurord.chrg_person_id_chrg_trn  chrg_person_id_chrg_trn_mkprdpurord ,
  trngantt_mkprdpurord.person_code_chrg_trn  person_code_chrg_trn_mkprdpurord ,
  trngantt_mkprdpurord.person_name_chrg_trn  person_name_chrg_trn_mkprdpurord ,
  trngantt_mkprdpurord.loca_code_pare  loca_code_pare_mkprdpurord ,
  trngantt_mkprdpurord.loca_name_pare  loca_name_pare_mkprdpurord ,
  trngantt_mkprdpurord.prjno_code_chil  prjno_code_chil_mkprdpurord ,
  trngantt_mkprdpurord.trngantt_loca_id_pare  trngantt_loca_id_pare_mkprdpurord ,
  trngantt_mkprdpurord.itm_classlist_id_pare  itm_classlist_id_pare_mkprdpurord ,
  trngantt_mkprdpurord.classlist_name_pare  classlist_name_pare_mkprdpurord ,
  trngantt_mkprdpurord.classlist_code_pare  classlist_code_pare_mkprdpurord ,
  trngantt_mkprdpurord.shelfno_code_to  shelfno_code_to_mkprdpurord ,
  trngantt_mkprdpurord.shelfno_name_to  shelfno_name_to_mkprdpurord ,
  trngantt_mkprdpurord.loca_code_shelfno_to  loca_code_shelfno_to_mkprdpurord ,
  trngantt_mkprdpurord.loca_name_shelfno_to  loca_name_shelfno_to_mkprdpurord ,
  trngantt_mkprdpurord.shelfno_loca_id_shelfno_to  shelfno_loca_id_shelfno_to_mkprdpurord ,
  trngantt_mkprdpurord.itm_classlist_id_org  itm_classlist_id_org_mkprdpurord ,
  trngantt_mkprdpurord.classlist_code_org  classlist_code_org_mkprdpurord ,
  trngantt_mkprdpurord.classlist_name_org  classlist_name_org_mkprdpurord ,
  trngantt_mkprdpurord.itm_classlist_id_trn  itm_classlist_id_trn_mkprdpurord ,
  trngantt_mkprdpurord.classlist_code_trn  classlist_code_trn_mkprdpurord ,
  trngantt_mkprdpurord.classlist_name_trn  classlist_name_trn_mkprdpurord ,
  trngantt_mkprdpurord.prjno_name_chil  prjno_name_chil_mkprdpurord ,
  trngantt_mkprdpurord.mkord_message_code_trngantt  mkord_message_code_trngantt_mkprdpurord ,
  trngantt_mkprdpurord.mkord_sno_org_trngantt  mkord_sno_org_trngantt_mkprdpurord ,
  trngantt_mkprdpurord.mkord_tblname_trngantt  mkord_tblname_trngantt_mkprdpurord ,
  trngantt_mkprdpurord.mkord_sno_pare_trngantt  mkord_sno_pare_trngantt_mkprdpurord ,
  trngantt_mkprdpurord.mkord_itm_code_pare_trngantt  mkord_itm_code_pare_trngantt_mkprdpurord ,
  trngantt_mkprdpurord.person_name_chrg_pare  person_name_chrg_pare_mkprdpurord ,
  trngantt_mkprdpurord.person_code_chrg_pare  person_code_chrg_pare_mkprdpurord ,
  trngantt_mkprdpurord.chrg_person_id_chrg_pare  chrg_person_id_chrg_pare_mkprdpurord ,
  trngantt_mkprdpurord.mkord_itm_code_trn_trngantt  mkord_itm_code_trn_trngantt_mkprdpurord ,
  trngantt_mkprdpurord.mkord_itm_code_org_trngantt  mkord_itm_code_org_trngantt_mkprdpurord ,
  trngantt_mkprdpurord.mkord_itm_name_org_trngantt  mkord_itm_name_org_trngantt_mkprdpurord ,
  trngantt_mkprdpurord.mkord_itm_name_trn_trngantt  mkord_itm_name_trn_trngantt_mkprdpurord ,
  trngantt_mkprdpurord.mkord_person_code_chrg_trn_trngantt  mkord_person_code_chrg_trn_trngantt_mkprdpurord ,
  trngantt_mkprdpurord.mkord_person_name_chrg_trn_trngantt  mkord_person_name_chrg_trn_trngantt_mkprdpurord ,
  trngantt_mkprdpurord.mkord_loca_code_pare_trngantt  mkord_loca_code_pare_trngantt_mkprdpurord ,
  trngantt_mkprdpurord.mkord_loca_code_trn_trngantt  mkord_loca_code_trn_trngantt_mkprdpurord ,
  trngantt_mkprdpurord.mkord_loca_name_trn_trngantt  mkord_loca_name_trn_trngantt_mkprdpurord ,
  trngantt_mkprdpurord.mkord_loca_name_pare_trngantt  mkord_loca_name_pare_trngantt_mkprdpurord ,
  trngantt_mkprdpurord.mkord_itm_name_pare_trngantt  mkord_itm_name_pare_trngantt_mkprdpurord ,
  trngantt_mkprdpurord.mkord_loca_name_org_trngantt  mkord_loca_name_org_trngantt_mkprdpurord ,
  trngantt_mkprdpurord.mkord_loca_name_to_trn_trngantt  mkord_loca_name_to_trn_trngantt_mkprdpurord ,
  trngantt_mkprdpurord.mkord_person_code_chrg_org_trngantt  mkord_person_code_chrg_org_trngantt_mkprdpurord ,
  trngantt_mkprdpurord.mkord_person_code_chrg_pare_trngantt  mkord_person_code_chrg_pare_trngantt_mkprdpurord ,
  trngantt_mkprdpurord.mkord_person_name_chrg_org_trngantt  mkord_person_name_chrg_org_trngantt_mkprdpurord ,
  trngantt_mkprdpurord.mkord_person_name_chrg_pare_trngantt  mkord_person_name_chrg_pare_trngantt_mkprdpurord ,
  trngantt_mkprdpurord.shelfno_code_to_pare  shelfno_code_to_pare_mkprdpurord ,
  trngantt_mkprdpurord.shelfno_name_to_pare  shelfno_name_to_pare_mkprdpurord ,
  trngantt_mkprdpurord.shelfno_loca_id_shelfno_to_pare  shelfno_loca_id_shelfno_to_pare_mkprdpurord ,
  trngantt_mkprdpurord.loca_code_shelfno_to_pare  loca_code_shelfno_to_pare_mkprdpurord ,
  trngantt_mkprdpurord.loca_name_shelfno_to_pare  loca_name_shelfno_to_pare_mkprdpurord 
 from mkprdpurords   mkprdpurord,
  r_persons  person_upd ,  r_trngantts  trngantt_mkprdpurord 
  where       mkprdpurord.persons_id_upd = person_upd.id      and mkprdpurord.trngantts_id_mkprdpurord = trngantt_mkprdpurord.id     ;
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
,mkprdpurord_isudate   timestamp(6) 
,mkprdpurord_confirm  varchar (1) 
,mkprdpurord_runtime  numeric (2,0)
,mkprdpurord_cmpldate   timestamp(6) 
,mkprdpurord_tblname  varchar (20) 
,mkprdpurord_loca_code_trn  varchar (50) 
,mkprdpurord_loca_name_trn  varchar (100) 
,mkprdpurord_loca_name_to_trn  varchar (100) 
,mkprdpurord_itm_code_trn  varchar (50) 
,mkprdpurord_itm_name_trn  varchar (100) 
,mkprdpurord_processseq_trn  numeric (38,0)
,mkprdpurord_person_code_chrg_trn  varchar (50) 
,mkprdpurord_person_name_chrg_trn  varchar (100) 
,mkprdpurord_starttime_trn   timestamp(6) 
,mkprdpurord_duedate_trn   timestamp(6) 
,loca_code_shelfno_to_pare_mkprdpurord  varchar (50) 
,mkord_message_code_trngantt_mkprdpurord  varchar (256) 
,mkprdpurord_orgtblname  varchar (20) 
,classlist_code_trn_mkprdpurord  varchar (50) 
,classlist_code_org_mkprdpurord  varchar (50) 
,unit_code_pare_mkprdpurord  varchar (50) 
,mkord_loca_code_pare_trngantt_mkprdpurord  varchar (50) 
,itm_code_pare_mkprdpurord  varchar (50) 
,mkord_loca_code_trn_trngantt_mkprdpurord  varchar (50) 
,mkord_person_code_chrg_org_trngantt_mkprdpurord  varchar (50) 
,mkord_person_code_chrg_pare_trngantt_mkprdpurord  varchar (50) 
,shelfno_code_to_pare_mkprdpurord  varchar (50) 
,mkord_itm_code_pare_trngantt_mkprdpurord  varchar (50) 
,person_code_chrg_pare_mkprdpurord  varchar (50) 
,loca_code_shelfno_to_mkprdpurord  varchar (50) 
,shelfno_code_to_mkprdpurord  varchar (50) 
,classlist_code_pare_mkprdpurord  varchar (50) 
,prjno_code_chil_mkprdpurord  varchar (50) 
,loca_code_pare_mkprdpurord  varchar (50) 
,person_code_chrg_trn_mkprdpurord  varchar (50) 
,person_code_chrg_org_mkprdpurord  varchar (50) 
,prjno_code_mkprdpurord  varchar (50) 
,itm_code_trn_mkprdpurord  varchar (50) 
,unit_code_org_mkprdpurord  varchar (50) 
,mkord_itm_code_trn_trngantt_mkprdpurord  varchar (50) 
,itm_code_org_mkprdpurord  varchar (50) 
,loca_code_trn_mkprdpurord  varchar (50) 
,mkord_itm_code_org_trngantt_mkprdpurord  varchar (50) 
,loca_code_org_mkprdpurord  varchar (50) 
,unit_code_trn_mkprdpurord  varchar (50) 
,mkord_person_code_chrg_trn_trngantt_mkprdpurord  varchar (50) 
,mkprdpurord_sno_org  varchar (50) 
,mkprdpurord_loca_code_org  varchar (50) 
,mkprdpurord_loca_name_org  varchar (100) 
,mkprdpurord_duedate_org   timestamp(6) 
,mkprdpurord_itm_code_org  varchar (50) 
,mkprdpurord_itm_name_org  varchar (100) 
,mkprdpurord_person_code_chrg_org  varchar (50) 
,mkprdpurord_person_name_chrg_org  varchar (100) 
,loca_name_shelfno_to_pare_mkprdpurord  varchar (100) 
,prjno_name_mkprdpurord  varchar (100) 
,itm_name_pare_mkprdpurord  varchar (100) 
,unit_name_pare_mkprdpurord  varchar (100) 
,unit_name_trn_mkprdpurord  varchar (100) 
,loca_name_org_mkprdpurord  varchar (100) 
,loca_name_trn_mkprdpurord  varchar (100) 
,itm_name_org_mkprdpurord  varchar (100) 
,unit_name_org_mkprdpurord  varchar (100) 
,itm_name_trn_mkprdpurord  varchar (100) 
,person_name_chrg_org_mkprdpurord  varchar (100) 
,person_name_chrg_trn_mkprdpurord  varchar (100) 
,loca_name_pare_mkprdpurord  varchar (100) 
,classlist_name_pare_mkprdpurord  varchar (100) 
,shelfno_name_to_mkprdpurord  varchar (100) 
,loca_name_shelfno_to_mkprdpurord  varchar (100) 
,classlist_name_org_mkprdpurord  varchar (100) 
,classlist_name_trn_mkprdpurord  varchar (100) 
,prjno_name_chil_mkprdpurord  varchar (100) 
,person_name_chrg_pare_mkprdpurord  varchar (100) 
,mkord_itm_name_org_trngantt_mkprdpurord  varchar (100) 
,mkord_itm_name_trn_trngantt_mkprdpurord  varchar (100) 
,mkord_person_name_chrg_trn_trngantt_mkprdpurord  varchar (100) 
,mkord_loca_name_trn_trngantt_mkprdpurord  varchar (100) 
,mkord_loca_name_pare_trngantt_mkprdpurord  varchar (100) 
,mkord_itm_name_pare_trngantt_mkprdpurord  varchar (100) 
,mkord_loca_name_org_trngantt_mkprdpurord  varchar (100) 
,mkord_loca_name_to_trn_trngantt_mkprdpurord  varchar (100) 
,mkord_person_name_chrg_org_trngantt_mkprdpurord  varchar (100) 
,mkord_person_name_chrg_pare_trngantt_mkprdpurord  varchar (100) 
,shelfno_name_to_pare_mkprdpurord  varchar (100) 
,mkprdpurord_paretblname  varchar (20) 
,mkprdpurord_sno_pare  varchar (50) 
,mkprdpurord_loca_code_pare  varchar (50) 
,mkprdpurord_loca_name_pare  varchar (100) 
,mkprdpurord_itm_code_pare  varchar (50) 
,mkprdpurord_itm_name_pare  varchar (100) 
,mkprdpurord_processseq_pare  numeric (38,0)
,mkprdpurord_person_code_chrg_pare  varchar (50) 
,mkprdpurord_person_name_chrg_pare  varchar (100) 
,mkprdpurord_outcnt  numeric (38,0)
,mkprdpurord_inqty  numeric (22,6)
,mkprdpurord_incnt  numeric (38,0)
,mkprdpurord_processseq_org  numeric (22,0)
,mkord_sno_org_trngantt_mkprdpurord  varchar (50) 
,mkord_sno_pare_trngantt_mkprdpurord  varchar (50) 
,mkprdpurord_duedate_pare   timestamp(6) 
,mkprdpurord_inamt  numeric (38,4)
,mkprdpurord_outqty  numeric (22,6)
,mkprdpurord_outamt  numeric (38,4)
,mkprdpurord_skipcnt  numeric (38,0)
,mkprdpurord_skipqty  numeric (22,6)
,mkprdpurord_skipamt  numeric (38,4)
,mkprdpurord_trngantt_id_mkprdpurord  numeric (22,0)
,mkord_tblname_trngantt_mkprdpurord  varchar (20) 
,mkprdpurord_manual  varchar (1) 
,person_code_upd  varchar (50) 
,mkprdpurord_remark  varchar (4000) 
,person_name_upd  varchar (100) 
,mkprdpurord_expiredate   date 
,mkprdpurord_updated_at   timestamp(6) 
,mkprdpurord_created_at   timestamp(6) 
,mkprdpurord_update_ip  varchar (40) 
,chrg_person_id_chrg_pare_mkprdpurord  numeric (38,0)
,trngantt_itm_id_pare_mkprdpurord  numeric (38,0)
,itm_classlist_id_pare_mkprdpurord  numeric (38,0)
,id  numeric (38,0)
,chrg_person_id_chrg_trn_mkprdpurord  numeric (38,0)
,trngantt_loca_id_pare_mkprdpurord  numeric (38,0)
,mkprdpurord_person_id_upd  numeric (22,0)
,itm_classlist_id_org_mkprdpurord  numeric (38,0)
,itm_classlist_id_trn_mkprdpurord  numeric (38,0)
,shelfno_loca_id_shelfno_to_pare_mkprdpurord  numeric (38,0)
,trngantt_prjno_id_mkprdpurord  numeric (38,0)
,chrg_person_id_chrg_org_mkprdpurord  numeric (38,0)
,shelfno_loca_id_shelfno_to_mkprdpurord  numeric (38,0)
,mkprdpurord_message_code  varchar (256) 
,mkprdpurord_result_f  varchar (1) 
,mkprdpurord_id  numeric (38,0)
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
 ALTER TABLE mkprdpurords ADD CONSTRAINT mkprdpurord_trngantts_id_mkprdpurord FOREIGN KEY (trngantts_id_mkprdpurord)
																		 REFERENCES trngantts (id);
