
 alter table  prdacts  ADD COLUMN crrs_id numeric(22,0)  DEFAULT 0  not null;

 alter table prdacts DROP COLUMN crrs_id_prdact CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'crrs_id_prdact'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　crrs_id_prdactが削除　2022-03-04 16:36:40 +0900' 
 ---- where  pobject_code_sfd = 'crrs_id_prdact'
 alter table  puracts  ADD COLUMN crrs_id numeric(22,0)  DEFAULT 0  not null;

 alter table puracts DROP COLUMN crrs_id_puract CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'crrs_id_puract'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　crrs_id_puractが削除　2022-03-04 16:36:40 +0900' 
 ---- where  pobject_code_sfd = 'crrs_id_puract'
 alter table  purords  ADD COLUMN crrs_id numeric(22,0)  DEFAULT 0  not null;

 alter table purords DROP COLUMN crrs_id_purord CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'crrs_id_purord'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　crrs_id_purordが削除　2022-03-04 16:36:40 +0900' 
 ---- where  pobject_code_sfd = 'crrs_id_purord'
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
  opeitm.opeitm_prdpur  opeitm_prdpur ,
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
,opeitm_prdpur  varchar (20) 
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
,crr_code_cust  varchar (50) 
,prjno_code  varchar (50) 
,crr_name_cust  varchar (100) 
,prjno_name  varchar (100) 
,prjno_priority  numeric (38,0)
,person_name_chrg_bill  varchar (100) 
,unit_code_box  varchar (50) 
,unit_name_box  varchar (100) 
,crr_code_bill  varchar (50) 
,crr_name_bill  varchar (100) 
,unit_code_outbox  varchar (50) 
,unit_name_outbox  varchar (100) 
,custord_starttime   timestamp(6) 
,classlist_code  varchar (50) 
,crr_name  varchar (100) 
,classlist_name  varchar (100) 
,custord_sno  varchar (40) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,shelfno_code_fm  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,loca_code_custrcvplc  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,person_code_chrg  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,loca_name_shelfno_fm  varchar (100) 
,shelfno_name_fm  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,person_name_chrg  varchar (100) 
,loca_name_custrcvplc  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,custord_shelfno_id_fm  numeric (22,0)
,custord_gno  varchar (40) 
,custord_crr_id  numeric (22,0)
,custord_sno_custsch  varchar (50) 
,custord_chrg_id  numeric (38,0)
,crr_pricedecimal  numeric (22,0)
,person_name_upd  varchar (100) 
,person_code_upd  varchar (50) 
,custord_toduedate   timestamp(6) 
,custord_expiredate   date 
,custord_contents  varchar (4000) 
,custord_remark  varchar (4000) 
,chrg_person_id_chrg_bill  numeric (38,0)
,custord_opeitm_id  numeric (38,0)
,bill_loca_id_bill  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,custrcvplc_loca_id_custrcvplc  numeric (38,0)
,custord_prjno_id  numeric (38,0)
,opeitm_loca_id_opeitm  numeric (22,0)
,itm_unit_id  numeric (22,0)
,custord_custrcvplc_id  numeric (38,0)
,boxe_unit_id_outbox  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,person_sect_id_chrg_bill  numeric (22,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,bill_chrg_id_bill  numeric (22,0)
,itm_classlist_id  numeric (38,0)
,custord_person_id_upd  numeric (22,0)
,custord_id  numeric (22,0)
,custord_updated_at   timestamp(6) 
,id  numeric (22,0)
,custord_cust_id  numeric (22,0)
,custord_update_ip  varchar (40) 
,custord_created_at   timestamp(6) 
,cust_bill_id  numeric (22,0)
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
  drop view if  exists r_purdlvs cascade ; 
 create or replace view r_purdlvs as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.unit_name  unit_name ,
  opeitm.unit_code  unit_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
purdlv.id id,
  prjno.prjno_name  prjno_name ,
  chrg.person_sect_id_chrg  person_sect_id_chrg ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  prjno.prjno_code  prjno_code ,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  supplier.loca_code_payment  loca_code_payment ,
  supplier.loca_name_payment  loca_name_payment ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  supplier.payment_loca_id_payment  payment_loca_id_payment ,
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
  supplier.payment_chrg_id_payment  payment_chrg_id_payment ,
  supplier.person_code_chrg_payment  person_code_chrg_payment ,
  supplier.person_name_chrg_payment  person_name_chrg_payment ,
  supplier.supplier_payment_id  supplier_payment_id ,
  supplier.supplier_loca_id_supplier  supplier_loca_id_supplier ,
  supplier.supplier_chrg_id_supplier  supplier_chrg_id_supplier ,
  supplier.supplier_crr_id_supplier  supplier_crr_id_supplier ,
  supplier.loca_code_supplier  loca_code_supplier ,
  supplier.loca_name_supplier  loca_name_supplier ,
  supplier.person_code_chrg_supplier  person_code_chrg_supplier ,
  supplier.person_name_chrg_supplier  person_name_chrg_supplier ,
  supplier.crr_name_supplier  crr_name_supplier ,
  supplier.crr_code_supplier  crr_code_supplier ,
  opeitm.itm_classlist_id  itm_classlist_id ,
  supplier.chrg_person_id_chrg_supplier  chrg_person_id_chrg_supplier ,
  supplier.chrg_person_id_chrg_payment  chrg_person_id_chrg_payment ,
purdlv.remark  purdlv_remark,
purdlv.created_at  purdlv_created_at,
purdlv.update_ip  purdlv_update_ip,
purdlv.isudate  purdlv_isudate,
purdlv.expiredate  purdlv_expiredate,
purdlv.updated_at  purdlv_updated_at,
purdlv.sno  purdlv_sno,
purdlv.id  purdlv_id,
purdlv.persons_id_upd   purdlv_person_id_upd,
purdlv.depdate  purdlv_depdate,
purdlv.prjnos_id   purdlv_prjno_id,
purdlv.opeitms_id   purdlv_opeitm_id,
purdlv.qty_case  purdlv_qty_case,
purdlv.cno  purdlv_cno,
purdlv.gno  purdlv_gno,
purdlv.chrgs_id   purdlv_chrg_id,
purdlv.itm_code_client  purdlv_itm_code_client,
purdlv.autoact_p  purdlv_autoact_p,
purdlv.suppliers_id   purdlv_supplier_id,
  supplier.person_sect_id_chrg_supplier  person_sect_id_chrg_supplier ,
  supplier.person_sect_id_chrg_payment  person_sect_id_chrg_payment ,
  shelfno_to.shelfno_code  shelfno_code_to ,
  shelfno_to.shelfno_name  shelfno_name_to ,
  shelfno_to.loca_code_shelfno  loca_code_shelfno_to ,
  shelfno_to.loca_name_shelfno  loca_name_shelfno_to ,
  shelfno_to.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_to ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
purdlv.sno_purinst  purdlv_sno_purinst,
purdlv.cno_purinst  purdlv_cno_purinst,
purdlv.shelfnos_id_to   purdlv_shelfno_id_to,
  supplier.crr_code_payment  crr_code_payment ,
  supplier.crr_name_payment  crr_name_payment ,
  prjno.prjno_name_chil  prjno_name_chil ,
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
purdlv.sno_purord  purdlv_sno_purord,
purdlv.shelfnos_id_fm   purdlv_shelfno_id_fm,
purdlv.cno_purord  purdlv_cno_purord,
purdlv.sno_purreplyinput  purdlv_sno_purreplyinput,
purdlv.cno_purreplyinput  purdlv_cno_purreplyinput,
purdlv.invoiceno  purdlv_invoiceno,
purdlv.cartonno  purdlv_cartonno,
purdlv.qty_stk  purdlv_qty_stk
 from purdlvs   purdlv,
  r_persons  person_upd ,  r_prjnos  prjno ,  r_opeitms  opeitm ,  r_chrgs  chrg ,  r_suppliers  supplier ,  r_shelfnos  shelfno_to ,  r_shelfnos  shelfno_fm 
  where       purdlv.persons_id_upd = person_upd.id      and purdlv.prjnos_id = prjno.id      and purdlv.opeitms_id = opeitm.id      and purdlv.chrgs_id = chrg.id      and purdlv.suppliers_id = supplier.id      and purdlv.shelfnos_id_to = shelfno_to.id      and purdlv.shelfnos_id_fm = shelfno_fm.id     ;
 DROP TABLE IF EXISTS sio.sio_r_purdlvs;
 CREATE TABLE sio.sio_r_purdlvs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_purdlvs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,prjno_code  varchar (50) 
,unit_code  varchar (50) 
,itm_code  varchar (50) 
,boxe_code  varchar (50) 
,classlist_code  varchar (50) 
,boxe_name  varchar (100) 
,unit_name  varchar (100) 
,itm_name  varchar (100) 
,classlist_name  varchar (100) 
,prjno_name  varchar (100) 
,person_code_chrg  varchar (50) 
,loca_code_opeitm  varchar (50) 
,crr_code_payment  varchar (50) 
,unit_code_box  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,unit_code_outbox  varchar (50) 
,shelfno_code_fm  varchar (50) 
,prjno_code_chil  varchar (50) 
,loca_code_shelfno_to  varchar (50) 
,person_code_chrg_payment  varchar (50) 
,shelfno_code_to  varchar (50) 
,crr_code_supplier  varchar (50) 
,person_code_chrg_supplier  varchar (50) 
,loca_code_supplier  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,unit_code_case_shp  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,loca_code_payment  varchar (50) 
,unit_name_outbox  varchar (100) 
,loca_name_payment  varchar (100) 
,unit_name_box  varchar (100) 
,person_name_chrg  varchar (100) 
,person_name_chrg_payment  varchar (100) 
,loca_name_supplier  varchar (100) 
,person_name_chrg_supplier  varchar (100) 
,crr_name_supplier  varchar (100) 
,shelfno_name_to  varchar (100) 
,loca_name_shelfno_to  varchar (100) 
,shelfno_name_fm  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,crr_name_payment  varchar (100) 
,prjno_name_chil  varchar (100) 
,loca_name_opeitm  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,unit_name_case_shp  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,purdlv_prjno_id  numeric (38,0)
,purdlv_shelfno_id_to  numeric (38,0)
,purdlv_sno_purinst  varchar (50) 
,purdlv_cno_purinst  varchar (50) 
,purdlv_opeitm_id  numeric (38,0)
,purdlv_qty_case  numeric (22,0)
,purdlv_cno  varchar (40) 
,purdlv_gno  varchar (40) 
,purdlv_chrg_id  numeric (38,0)
,purdlv_itm_code_client  varchar (50) 
,purdlv_autoact_p  numeric (3,0)
,purdlv_supplier_id  numeric (22,0)
,purdlv_updated_at   timestamp(6) 
,purdlv_expiredate   date 
,purdlv_isudate   timestamp(6) 
,purdlv_sno  varchar (40) 
,purdlv_update_ip  varchar (40) 
,purdlv_depdate   timestamp(6) 
,purdlv_created_at   timestamp(6) 
,purdlv_remark  varchar (4000) 
,opeitm_priority  numeric (3,0)
,id  numeric (38,0)
,purdlv_id  numeric (38,0)
,purdlv_invoiceno  varchar (50) 
,purdlv_cartonno  varchar (50) 
,purdlv_qty_stk  numeric (22,6)
,purdlv_sno_purord  varchar (50) 
,purdlv_shelfno_id_fm  numeric (22,0)
,purdlv_cno_purord  varchar (50) 
,purdlv_sno_purreplyinput  varchar (50) 
,purdlv_cno_purreplyinput  varchar (50) 
,payment_loca_id_payment  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,person_sect_id_chrg_payment  numeric (22,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,person_sect_id_chrg  numeric (22,0)
,person_sect_id_chrg_supplier  numeric (22,0)
,boxe_unit_id_outbox  numeric (38,0)
,supplier_crr_id_supplier  numeric (22,0)
,supplier_payment_id  numeric (38,0)
,supplier_chrg_id_supplier  numeric (22,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,supplier_loca_id_supplier  numeric (22,0)
,itm_classlist_id  numeric (38,0)
,chrg_person_id_chrg_supplier  numeric (38,0)
,chrg_person_id_chrg_payment  numeric (38,0)
,opeitm_boxe_id  numeric (22,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,itm_unit_id  numeric (22,0)
,payment_chrg_id_payment  numeric (22,0)
,purdlv_person_id_upd  numeric (22,0)
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
 CREATE INDEX sio_r_purdlvs_uk1 
  ON sio.sio_r_purdlvs(id,sio_id); 

 drop sequence  if exists sio.sio_r_purdlvs_seq ;
 create sequence sio.sio_r_purdlvs_seq ;
  drop view if  exists r_purschs cascade ; 
 create or replace view r_purschs as select  
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
pursch.id id,
  prjno.prjno_name  prjno_name ,
  chrg.person_sect_id_chrg  person_sect_id_chrg ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
pursch.id  pursch_id,
pursch.remark  pursch_remark,
pursch.expiredate  pursch_expiredate,
pursch.update_ip  pursch_update_ip,
pursch.created_at  pursch_created_at,
pursch.updated_at  pursch_updated_at,
pursch.persons_id_upd   pursch_person_id_upd,
pursch.price  pursch_price,
pursch.sno  pursch_sno,
pursch.duedate  pursch_duedate,
pursch.toduedate  pursch_toduedate,
pursch.isudate  pursch_isudate,
pursch.tax  pursch_tax,
pursch.opeitms_id   pursch_opeitm_id,
  prjno.prjno_code  prjno_code ,
pursch.prjnos_id   pursch_prjno_id,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  supplier.loca_code_payment  loca_code_payment ,
  supplier.loca_name_payment  loca_name_payment ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  supplier.payment_loca_id_payment  payment_loca_id_payment ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  opeitm.unit_code_box  unit_code_box ,
  opeitm.unit_name_box  unit_name_box ,
  opeitm.boxe_unit_id_outbox  boxe_unit_id_outbox ,
  opeitm.unit_code_outbox  unit_code_outbox ,
  opeitm.unit_name_outbox  unit_name_outbox ,
  opeitm.boxe_code  boxe_code ,
  opeitm.boxe_name  boxe_name ,
  opeitm.opeitm_boxe_id  opeitm_boxe_id ,
pursch.chrgs_id   pursch_chrg_id,
pursch.starttime  pursch_starttime,
  prjno.prjno_code_chil  prjno_code_chil ,
  supplier.payment_chrg_id_payment  payment_chrg_id_payment ,
  supplier.person_code_chrg_payment  person_code_chrg_payment ,
  supplier.person_name_chrg_payment  person_name_chrg_payment ,
  supplier.supplier_payment_id  supplier_payment_id ,
  supplier.supplier_loca_id_supplier  supplier_loca_id_supplier ,
  supplier.supplier_chrg_id_supplier  supplier_chrg_id_supplier ,
  supplier.supplier_crr_id_supplier  supplier_crr_id_supplier ,
  supplier.loca_code_supplier  loca_code_supplier ,
  supplier.loca_name_supplier  loca_name_supplier ,
  supplier.person_code_chrg_supplier  person_code_chrg_supplier ,
  supplier.person_name_chrg_supplier  person_name_chrg_supplier ,
  supplier.crr_name_supplier  crr_name_supplier ,
  supplier.crr_code_supplier  crr_code_supplier ,
  opeitm.itm_classlist_id  itm_classlist_id ,
  supplier.chrg_person_id_chrg_supplier  chrg_person_id_chrg_supplier ,
  supplier.chrg_person_id_chrg_payment  chrg_person_id_chrg_payment ,
pursch.suppliers_id   pursch_supplier_id,
  supplier.person_sect_id_chrg_supplier  person_sect_id_chrg_supplier ,
  supplier.person_sect_id_chrg_payment  person_sect_id_chrg_payment ,
pursch.gno  pursch_gno,
  shelfno_to.shelfno_code  shelfno_code_to ,
  shelfno_to.shelfno_name  shelfno_name_to ,
  shelfno_to.loca_code_shelfno  loca_code_shelfno_to ,
  shelfno_to.loca_name_shelfno  loca_name_shelfno_to ,
  shelfno_to.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_to ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
pursch.shelfnos_id_to   pursch_shelfno_id_to,
pursch.qty_sch  pursch_qty_sch,
  supplier.crr_code_payment  crr_code_payment ,
  supplier.crr_name_payment  crr_name_payment ,
pursch.amt_sch  pursch_amt_sch,
  prjno.prjno_name_chil  prjno_name_chil ,
  opeitm.opeitm_loca_id_opeitm  opeitm_loca_id_opeitm ,
  opeitm.loca_code_opeitm  loca_code_opeitm ,
  opeitm.loca_name_opeitm  loca_name_opeitm ,
pursch.shelfnos_id_fm   pursch_shelfno_id_fm,
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
  opeitm.unit_code_case_prdpur  unit_code_case_prdpur 
 from purschs   pursch,
  r_persons  person_upd ,  r_opeitms  opeitm ,  r_prjnos  prjno ,  r_chrgs  chrg ,  r_suppliers  supplier ,  r_shelfnos  shelfno_to ,  r_shelfnos  shelfno_fm 
  where       pursch.persons_id_upd = person_upd.id      and pursch.opeitms_id = opeitm.id      and pursch.prjnos_id = prjno.id      and pursch.chrgs_id = chrg.id      and pursch.suppliers_id = supplier.id      and pursch.shelfnos_id_to = shelfno_to.id      and pursch.shelfnos_id_fm = shelfno_fm.id     ;
 DROP TABLE IF EXISTS sio.sio_r_purschs;
 CREATE TABLE sio.sio_r_purschs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_purschs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,pursch_sno  varchar (40) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,pursch_duedate   timestamp(6) 
,opeitm_processseq  numeric (3,0)
,classlist_code  varchar (50) 
,prjno_code  varchar (50) 
,boxe_code  varchar (50) 
,itm_code  varchar (50) 
,unit_name_outbox  varchar (100) 
,unit_code_outbox  varchar (50) 
,unit_code  varchar (50) 
,unit_name  varchar (100) 
,unit_code_box  varchar (50) 
,unit_name_box  varchar (100) 
,prjno_name  varchar (100) 
,pursch_expiredate   date 
,pursch_isudate   timestamp(6) 
,itm_name  varchar (100) 
,pursch_toduedate   timestamp(6) 
,classlist_name  varchar (100) 
,pursch_starttime   timestamp(6) 
,boxe_name  varchar (100) 
,prjno_code_chil  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,unit_code_case_shp  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,loca_code_opeitm  varchar (50) 
,crr_code_payment  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,shelfno_code_fm  varchar (50) 
,loca_code_shelfno_to  varchar (50) 
,shelfno_code_to  varchar (50) 
,crr_code_supplier  varchar (50) 
,person_code_chrg_supplier  varchar (50) 
,loca_code_supplier  varchar (50) 
,person_code_chrg_payment  varchar (50) 
,loca_code_payment  varchar (50) 
,person_code_chrg  varchar (50) 
,shelfno_name_fm_opeitm  varchar (100) 
,loca_name_payment  varchar (100) 
,person_name_chrg_payment  varchar (100) 
,loca_name_supplier  varchar (100) 
,person_name_chrg_supplier  varchar (100) 
,crr_name_supplier  varchar (100) 
,shelfno_name_to  varchar (100) 
,loca_name_shelfno_to  varchar (100) 
,shelfno_name_fm  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,crr_name_payment  varchar (100) 
,prjno_name_chil  varchar (100) 
,loca_name_opeitm  varchar (100) 
,person_name_chrg  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,unit_name_case_shp  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,pursch_tax  numeric (38,4)
,opeitm_priority  numeric (3,0)
,pursch_amt_sch  numeric (38,4)
,pursch_price  numeric (38,4)
,pursch_qty_sch  numeric (22,6)
,pursch_gno  varchar (40) 
,pursch_shelfno_id_fm  numeric (22,0)
,pursch_remark  varchar (4000) 
,pursch_created_at   timestamp(6) 
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,pursch_updated_at   timestamp(6) 
,person_sect_id_chrg  numeric (22,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,pursch_shelfno_id_to  numeric (38,0)
,pursch_update_ip  varchar (40) 
,id  numeric (38,0)
,itm_unit_id  numeric (22,0)
,opeitm_loca_id_opeitm  numeric (22,0)
,boxe_unit_id_outbox  numeric (38,0)
,opeitm_boxe_id  numeric (22,0)
,pursch_chrg_id  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,payment_loca_id_payment  numeric (38,0)
,payment_chrg_id_payment  numeric (22,0)
,chrg_person_id_chrg  numeric (38,0)
,supplier_payment_id  numeric (38,0)
,supplier_loca_id_supplier  numeric (22,0)
,supplier_chrg_id_supplier  numeric (22,0)
,supplier_crr_id_supplier  numeric (22,0)
,pursch_prjno_id  numeric (38,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,pursch_opeitm_id  numeric (38,0)
,pursch_id  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,chrg_person_id_chrg_supplier  numeric (38,0)
,chrg_person_id_chrg_payment  numeric (38,0)
,pursch_supplier_id  numeric (22,0)
,person_sect_id_chrg_supplier  numeric (22,0)
,person_sect_id_chrg_payment  numeric (22,0)
,opeitm_itm_id  numeric (38,0)
,pursch_person_id_upd  numeric (38,0)
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
 CREATE INDEX sio_r_purschs_uk1 
  ON sio.sio_r_purschs(id,sio_id); 

 drop sequence  if exists sio.sio_r_purschs_seq ;
 create sequence sio.sio_r_purschs_seq ;
  drop view if  exists r_prdreplyinputs cascade ; 
 create or replace view r_prdreplyinputs as select  
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.unit_name  unit_name ,
  opeitm.unit_code  unit_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
prdreplyinput.id id,
  loca_to.loca_code  loca_code_to ,
  loca_to.loca_name  loca_name_to ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  opeitm.unit_code_box  unit_code_box ,
  opeitm.unit_name_box  unit_name_box ,
  opeitm.boxe_unit_id_outbox  boxe_unit_id_outbox ,
  opeitm.unit_code_outbox  unit_code_outbox ,
  opeitm.unit_name_outbox  unit_name_outbox ,
  opeitm.boxe_code  boxe_code ,
  opeitm.boxe_name  boxe_name ,
  opeitm.opeitm_boxe_id  opeitm_boxe_id ,
prdreplyinput.result_f  prdreplyinput_result_f,
prdreplyinput.qty_case  prdreplyinput_qty_case,
prdreplyinput.update_ip  prdreplyinput_update_ip,
prdreplyinput.id  prdreplyinput_id,
prdreplyinput.persons_id_upd   prdreplyinput_person_id_upd,
prdreplyinput.contents  prdreplyinput_contents,
prdreplyinput.isudate  prdreplyinput_isudate,
prdreplyinput.opeitms_id   prdreplyinput_opeitm_id,
prdreplyinput.expiredate  prdreplyinput_expiredate,
prdreplyinput.updated_at  prdreplyinput_updated_at,
prdreplyinput.qty  prdreplyinput_qty,
prdreplyinput.remark  prdreplyinput_remark,
prdreplyinput.created_at  prdreplyinput_created_at,
prdreplyinput.locas_id_to   prdreplyinput_loca_id_to,
prdreplyinput.message_code  prdreplyinput_message_code,
  opeitm.itm_classlist_id  itm_classlist_id ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
prdreplyinput.sno_prdord  prdreplyinput_sno_prdord,
prdreplyinput.sno_prdinst  prdreplyinput_sno_prdinst,
prdreplyinput.replydate  prdreplyinput_replydate,
prdreplyinput.cno  prdreplyinput_cno,
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
prdreplyinput.shelfnos_id_fm   prdreplyinput_shelfno_id_fm
 from prdreplyinputs   prdreplyinput,
  r_persons  person_upd ,  r_opeitms  opeitm ,  r_locas  loca_to ,  r_shelfnos  shelfno_fm 
  where       prdreplyinput.persons_id_upd = person_upd.id      and prdreplyinput.opeitms_id = opeitm.id      and prdreplyinput.locas_id_to = loca_to.id      and prdreplyinput.shelfnos_id_fm = shelfno_fm.id     ;
 DROP TABLE IF EXISTS sio.sio_r_prdreplyinputs;
 CREATE TABLE sio.sio_r_prdreplyinputs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_prdreplyinputs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,prdreplyinput_result_f  varchar (20) 
,itm_code  varchar (50) 
,boxe_code  varchar (50) 
,unit_code  varchar (50) 
,classlist_code  varchar (50) 
,boxe_name  varchar (100) 
,itm_name  varchar (100) 
,classlist_name  varchar (100) 
,unit_name  varchar (100) 
,unit_code_case_shp  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,shelfno_code_fm  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,unit_code_box  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,loca_code_opeitm  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,unit_code_outbox  varchar (50) 
,loca_code_to  varchar (50) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_to  varchar (100) 
,unit_name_box  varchar (100) 
,unit_name_outbox  varchar (100) 
,shelfno_name_fm  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,loca_name_opeitm  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,unit_name_case_shp  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,prdreplyinput_sno_prdord  varchar (50) 
,prdreplyinput_isudate   timestamp(6) 
,opeitm_priority  numeric (3,0)
,prdreplyinput_qty  numeric (18,4)
,prdreplyinput_cno  varchar (40) 
,prdreplyinput_replydate   date 
,prdreplyinput_qty_case  numeric (22,0)
,prdreplyinput_sno_prdinst  varchar (50) 
,prdreplyinput_shelfno_id_fm  numeric (22,0)
,prdreplyinput_expiredate   date 
,prdreplyinput_remark  varchar (4000) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,prdreplyinput_contents  varchar (4000) 
,prdreplyinput_message_code  varchar (256) 
,opeitm_itm_id  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,opeitm_boxe_id  numeric (22,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,boxe_unit_id_outbox  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,itm_unit_id  numeric (22,0)
,prdreplyinput_id  numeric (22,0)
,prdreplyinput_person_id_upd  numeric (22,0)
,prdreplyinput_loca_id_to  numeric (22,0)
,prdreplyinput_opeitm_id  numeric (22,0)
,prdreplyinput_updated_at   timestamp(6) 
,prdreplyinput_created_at   timestamp(6) 
,id  numeric (22,0)
,prdreplyinput_update_ip  varchar (40) 
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
 CREATE INDEX sio_r_prdreplyinputs_uk1 
  ON sio.sio_r_prdreplyinputs(id,sio_id); 

 drop sequence  if exists sio.sio_r_prdreplyinputs_seq ;
 create sequence sio.sio_r_prdreplyinputs_seq ;
  drop view if  exists r_prdrsltinputs cascade ; 
 create or replace view r_prdrsltinputs as select  
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.unit_name  unit_name ,
  opeitm.unit_code  unit_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
prdrsltinput.id id,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  opeitm.unit_code_box  unit_code_box ,
  opeitm.unit_name_box  unit_name_box ,
  opeitm.boxe_unit_id_outbox  boxe_unit_id_outbox ,
  opeitm.unit_code_outbox  unit_code_outbox ,
  opeitm.unit_name_outbox  unit_name_outbox ,
  opeitm.boxe_code  boxe_code ,
  opeitm.boxe_name  boxe_name ,
  opeitm.opeitm_boxe_id  opeitm_boxe_id ,
prdrsltinput.cmpldate  prdrsltinput_cmpldate,
prdrsltinput.result_f  prdrsltinput_result_f,
prdrsltinput.qty_case  prdrsltinput_qty_case,
prdrsltinput.id  prdrsltinput_id,
prdrsltinput.remark  prdrsltinput_remark,
prdrsltinput.expiredate  prdrsltinput_expiredate,
prdrsltinput.update_ip  prdrsltinput_update_ip,
prdrsltinput.created_at  prdrsltinput_created_at,
prdrsltinput.updated_at  prdrsltinput_updated_at,
prdrsltinput.persons_id_upd   prdrsltinput_person_id_upd,
prdrsltinput.qty  prdrsltinput_qty,
prdrsltinput.isudate  prdrsltinput_isudate,
prdrsltinput.contents  prdrsltinput_contents,
prdrsltinput.opeitms_id   prdrsltinput_opeitm_id,
prdrsltinput.message_code  prdrsltinput_message_code,
  opeitm.itm_classlist_id  itm_classlist_id ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
prdrsltinput.sno_prdinst  prdrsltinput_sno_prdinst,
prdrsltinput.cno  prdrsltinput_cno,
prdrsltinput.sno  prdrsltinput_sno,
prdrsltinput.sno_prdord  prdrsltinput_sno_prdord,
prdrsltinput.price  prdrsltinput_price,
prdrsltinput.amt  prdrsltinput_amt,
prdrsltinput.tax  prdrsltinput_tax,
prdrsltinput.sno_prdreplyinput  prdrsltinput_sno_prdreplyinput,
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
prdrsltinput.shelfnos_id_fm   prdrsltinput_shelfno_id_fm
 from prdrsltinputs   prdrsltinput,
  r_persons  person_upd ,  r_opeitms  opeitm ,  r_shelfnos  shelfno_fm 
  where       prdrsltinput.persons_id_upd = person_upd.id      and prdrsltinput.opeitms_id = opeitm.id      and prdrsltinput.shelfnos_id_fm = shelfno_fm.id     ;
 DROP TABLE IF EXISTS sio.sio_r_prdrsltinputs;
 CREATE TABLE sio.sio_r_prdrsltinputs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_prdrsltinputs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,classlist_code  varchar (50) 
,boxe_code  varchar (50) 
,unit_code  varchar (50) 
,itm_code  varchar (50) 
,prdrsltinput_result_f  varchar (20) 
,boxe_name  varchar (100) 
,itm_name  varchar (100) 
,classlist_name  varchar (100) 
,unit_name  varchar (100) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,unit_code_case_shp  varchar (50) 
,shelfno_code_fm  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,unit_code_box  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,loca_code_opeitm  varchar (50) 
,unit_code_outbox  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,shelfno_name_to_opeitm  varchar (100) 
,unit_name_box  varchar (100) 
,unit_name_outbox  varchar (100) 
,shelfno_name_fm  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,loca_name_opeitm  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,unit_name_case_shp  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,prdrsltinput_sno_prdinst  varchar (50) 
,prdrsltinput_isudate   timestamp(6) 
,opeitm_priority  numeric (3,0)
,prdrsltinput_cno  varchar (40) 
,prdrsltinput_sno_prdreplyinput  varchar (50) 
,prdrsltinput_tax  numeric (38,4)
,prdrsltinput_cmpldate   timestamp(6) 
,prdrsltinput_amt  numeric (18,4)
,prdrsltinput_price  numeric (38,4)
,prdrsltinput_sno_prdord  varchar (50) 
,prdrsltinput_sno  varchar (40) 
,prdrsltinput_shelfno_id_fm  numeric (22,0)
,prdrsltinput_qty  numeric (18,4)
,prdrsltinput_qty_case  numeric (22,0)
,prdrsltinput_expiredate   date 
,prdrsltinput_contents  varchar (4000) 
,prdrsltinput_remark  varchar (4000) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,prdrsltinput_message_code  varchar (256) 
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,opeitm_boxe_id  numeric (22,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,itm_unit_id  numeric (22,0)
,boxe_unit_id_box  numeric (38,0)
,boxe_unit_id_outbox  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,prdrsltinput_id  numeric (22,0)
,prdrsltinput_updated_at   timestamp(6) 
,prdrsltinput_person_id_upd  numeric (22,0)
,prdrsltinput_update_ip  varchar (40) 
,prdrsltinput_created_at   timestamp(6) 
,id  numeric (22,0)
,prdrsltinput_opeitm_id  numeric (22,0)
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
 CREATE INDEX sio_r_prdrsltinputs_uk1 
  ON sio.sio_r_prdrsltinputs(id,sio_id); 

 drop sequence  if exists sio.sio_r_prdrsltinputs_seq ;
 create sequence sio.sio_r_prdrsltinputs_seq ;
  drop view if  exists r_purrsltinputs cascade ; 
 create or replace view r_purrsltinputs as select  
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.unit_name  unit_name ,
  opeitm.unit_code  unit_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
purrsltinput.id id,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
purrsltinput.opeitms_id   purrsltinput_opeitm_id,
purrsltinput.result_f  purrsltinput_result_f,
purrsltinput.rcptdate  purrsltinput_rcptdate,
purrsltinput.id  purrsltinput_id,
purrsltinput.remark  purrsltinput_remark,
purrsltinput.expiredate  purrsltinput_expiredate,
purrsltinput.update_ip  purrsltinput_update_ip,
purrsltinput.created_at  purrsltinput_created_at,
purrsltinput.updated_at  purrsltinput_updated_at,
purrsltinput.persons_id_upd   purrsltinput_person_id_upd,
purrsltinput.qty  purrsltinput_qty,
purrsltinput.isudate  purrsltinput_isudate,
purrsltinput.contents  purrsltinput_contents,
  crr.crr_code  crr_code ,
  crr.crr_name  crr_name ,
purrsltinput.qty_case  purrsltinput_qty_case,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  opeitm.unit_code_box  unit_code_box ,
  opeitm.unit_name_box  unit_name_box ,
  opeitm.boxe_unit_id_outbox  boxe_unit_id_outbox ,
  opeitm.unit_code_outbox  unit_code_outbox ,
  opeitm.unit_name_outbox  unit_name_outbox ,
  opeitm.boxe_code  boxe_code ,
  opeitm.boxe_name  boxe_name ,
  opeitm.opeitm_boxe_id  opeitm_boxe_id ,
purrsltinput.message_code  purrsltinput_message_code,
  opeitm.itm_classlist_id  itm_classlist_id ,
  shelfno_to.shelfno_code  shelfno_code_to ,
  shelfno_to.shelfno_name  shelfno_name_to ,
  shelfno_to.loca_code_shelfno  loca_code_shelfno_to ,
  shelfno_to.loca_name_shelfno  loca_name_shelfno_to ,
  shelfno_to.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_to ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
purrsltinput.sno_purord  purrsltinput_sno_purord,
purrsltinput.sno_purinst  purrsltinput_sno_purinst,
purrsltinput.cno_purinst  purrsltinput_cno_purinst,
purrsltinput.sno  purrsltinput_sno,
purrsltinput.crrs_id   purrsltinput_crr_id,
purrsltinput.sno_purreplyinput  purrsltinput_sno_purreplyinput,
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
purrsltinput.shelfnos_id_fm   purrsltinput_shelfno_id_fm,
purrsltinput.shelfnos_id_to   purrsltinput_shelfno_id_to,
purrsltinput.invoiceno  purrsltinput_invoiceno,
purrsltinput.cartonno  purrsltinput_cartonno
 from purrsltinputs   purrsltinput,
  r_opeitms  opeitm ,  r_persons  person_upd ,  r_crrs  crr ,  r_shelfnos  shelfno_fm ,  r_shelfnos  shelfno_to 
  where       purrsltinput.opeitms_id = opeitm.id      and purrsltinput.persons_id_upd = person_upd.id      and purrsltinput.crrs_id = crr.id      and purrsltinput.shelfnos_id_fm = shelfno_fm.id      and purrsltinput.shelfnos_id_to = shelfno_to.id     ;
 DROP TABLE IF EXISTS sio.sio_r_purrsltinputs;
 CREATE TABLE sio.sio_r_purrsltinputs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_purrsltinputs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,purrsltinput_result_f  varchar (20) 
,itm_code  varchar (50) 
,unit_code  varchar (50) 
,crr_code  varchar (50) 
,classlist_code  varchar (50) 
,boxe_code  varchar (50) 
,classlist_name  varchar (100) 
,crr_name  varchar (100) 
,unit_name  varchar (100) 
,boxe_name  varchar (100) 
,itm_name  varchar (100) 
,purrsltinput_qty  numeric (18,4)
,shelfno_code_to  varchar (50) 
,loca_code_shelfno_to  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,shelfno_code_fm  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,unit_code_case_shp  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,unit_code_box  varchar (50) 
,unit_code_outbox  varchar (50) 
,loca_code_opeitm  varchar (50) 
,purrsltinput_qty_case  numeric (22,0)
,loca_name_shelfno_to  varchar (100) 
,shelfno_name_fm  varchar (100) 
,shelfno_name_to  varchar (100) 
,unit_name_box  varchar (100) 
,loca_name_opeitm  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,unit_name_outbox  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,unit_name_case_shp  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,purrsltinput_sno_purinst  varchar (50) 
,opeitm_priority  numeric (3,0)
,purrsltinput_sno_purreplyinput  varchar (50) 
,purrsltinput_crr_id  numeric (22,0)
,purrsltinput_sno  varchar (40) 
,purrsltinput_sno_purord  varchar (50) 
,purrsltinput_cno_purinst  varchar (50) 
,purrsltinput_rcptdate   date 
,purrsltinput_invoiceno  varchar (50) 
,purrsltinput_cartonno  varchar (50) 
,purrsltinput_shelfno_id_fm  numeric (22,0)
,purrsltinput_shelfno_id_to  numeric (38,0)
,purrsltinput_message_code  varchar (256) 
,purrsltinput_contents  varchar (4000) 
,purrsltinput_remark  varchar (4000) 
,purrsltinput_expiredate   date 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,purrsltinput_isudate   timestamp(6) 
,shelfno_loca_id_shelfno_to  numeric (38,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,opeitm_boxe_id  numeric (22,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,itm_unit_id  numeric (22,0)
,itm_classlist_id  numeric (38,0)
,boxe_unit_id_outbox  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,purrsltinput_id  numeric (22,0)
,purrsltinput_opeitm_id  numeric (22,0)
,purrsltinput_update_ip  varchar (40) 
,purrsltinput_created_at   timestamp(6) 
,id  numeric (22,0)
,purrsltinput_updated_at   timestamp(6) 
,purrsltinput_person_id_upd  numeric (22,0)
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
 CREATE INDEX sio_r_purrsltinputs_uk1 
  ON sio.sio_r_purrsltinputs(id,sio_id); 

 drop sequence  if exists sio.sio_r_purrsltinputs_seq ;
 create sequence sio.sio_r_purrsltinputs_seq ;
  drop view if  exists r_purreplyinputs cascade ; 
 create or replace view r_purreplyinputs as select  
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.unit_name  unit_name ,
  opeitm.unit_code  unit_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
purreplyinput.id id,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
purreplyinput.cno  purreplyinput_cno,
purreplyinput.id  purreplyinput_id,
purreplyinput.remark  purreplyinput_remark,
purreplyinput.expiredate  purreplyinput_expiredate,
purreplyinput.update_ip  purreplyinput_update_ip,
purreplyinput.created_at  purreplyinput_created_at,
purreplyinput.updated_at  purreplyinput_updated_at,
purreplyinput.persons_id_upd   purreplyinput_person_id_upd,
purreplyinput.qty  purreplyinput_qty,
purreplyinput.isudate  purreplyinput_isudate,
purreplyinput.contents  purreplyinput_contents,
purreplyinput.opeitms_id   purreplyinput_opeitm_id,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  opeitm.unit_code_box  unit_code_box ,
  opeitm.unit_name_box  unit_name_box ,
  opeitm.boxe_unit_id_outbox  boxe_unit_id_outbox ,
  opeitm.unit_code_outbox  unit_code_outbox ,
  opeitm.unit_name_outbox  unit_name_outbox ,
  opeitm.boxe_code  boxe_code ,
  opeitm.boxe_name  boxe_name ,
  opeitm.opeitm_boxe_id  opeitm_boxe_id ,
purreplyinput.qty_case  purreplyinput_qty_case,
purreplyinput.message_code  purreplyinput_message_code,
  opeitm.itm_classlist_id  itm_classlist_id ,
  shelfno_to.shelfno_code  shelfno_code_to ,
  shelfno_to.shelfno_name  shelfno_name_to ,
  shelfno_to.loca_code_shelfno  loca_code_shelfno_to ,
  shelfno_to.loca_name_shelfno  loca_name_shelfno_to ,
  shelfno_to.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_to ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
purreplyinput.sno  purreplyinput_sno,
purreplyinput.replydate  purreplyinput_replydate,
purreplyinput.sno_purinst  purreplyinput_sno_purinst,
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
purreplyinput.sno_purord  purreplyinput_sno_purord,
purreplyinput.shelfnos_id_fm   purreplyinput_shelfno_id_fm,
purreplyinput.shelfnos_id_to   purreplyinput_shelfno_id_to
 from purreplyinputs   purreplyinput,
  r_persons  person_upd ,  r_opeitms  opeitm ,  r_shelfnos  shelfno_fm ,  r_shelfnos  shelfno_to 
  where       purreplyinput.persons_id_upd = person_upd.id      and purreplyinput.opeitms_id = opeitm.id      and purreplyinput.shelfnos_id_fm = shelfno_fm.id      and purreplyinput.shelfnos_id_to = shelfno_to.id     ;
 DROP TABLE IF EXISTS sio.sio_r_purreplyinputs;
 CREATE TABLE sio.sio_r_purreplyinputs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_purreplyinputs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,classlist_code  varchar (50) 
,itm_code  varchar (50) 
,unit_code  varchar (50) 
,itm_name  varchar (100) 
,unit_name  varchar (100) 
,classlist_name  varchar (100) 
,boxe_name  varchar (100) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,unit_code_case_shp  varchar (50) 
,unit_code_outbox  varchar (50) 
,loca_code_opeitm  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,shelfno_code_fm  varchar (50) 
,loca_code_shelfno_to  varchar (50) 
,shelfno_code_to  varchar (50) 
,unit_code_box  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,unit_name_box  varchar (100) 
,unit_name_outbox  varchar (100) 
,shelfno_name_to  varchar (100) 
,loca_name_shelfno_to  varchar (100) 
,shelfno_name_fm  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,loca_name_opeitm  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,unit_name_case_shp  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,purreplyinput_sno  varchar (40) 
,purreplyinput_isudate   timestamp(6) 
,opeitm_priority  numeric (3,0)
,purreplyinput_cno  varchar (40) 
,purreplyinput_sno_purinst  varchar (50) 
,purreplyinput_replydate   date 
,purreplyinput_sno_purord  varchar (50) 
,purreplyinput_shelfno_id_to  numeric (38,0)
,purreplyinput_shelfno_id_fm  numeric (22,0)
,purreplyinput_qty  numeric (18,4)
,purreplyinput_qty_case  numeric (22,0)
,purreplyinput_contents  varchar (4000) 
,purreplyinput_remark  varchar (4000) 
,purreplyinput_message_code  varchar (256) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,purreplyinput_updated_at   timestamp 
,purreplyinput_created_at   timestamp 
,purreplyinput_expiredate   date 
,opeitm_itm_id  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,opeitm_boxe_id  numeric (22,0)
,itm_classlist_id  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,itm_unit_id  numeric (22,0)
,boxe_unit_id_outbox  numeric (38,0)
,id  numeric (22,0)
,purreplyinput_person_id_upd  numeric (22,0)
,purreplyinput_update_ip  varchar (40) 
,purreplyinput_opeitm_id  numeric (22,0)
,purreplyinput_id  numeric (22,0)
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
 CREATE INDEX sio_r_purreplyinputs_uk1 
  ON sio.sio_r_purreplyinputs(id,sio_id); 

 drop sequence  if exists sio.sio_r_purreplyinputs_seq ;
 create sequence sio.sio_r_purreplyinputs_seq ;
  drop view if  exists r_prdacts cascade ; 
 create or replace view r_prdacts as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.unit_name  unit_name ,
  opeitm.unit_code  unit_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
prdact.id id,
  prjno.prjno_name  prjno_name ,
  chrg.person_sect_id_chrg  person_sect_id_chrg ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  prjno.prjno_code  prjno_code ,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
prdact.remark  prdact_remark,
prdact.created_at  prdact_created_at,
prdact.update_ip  prdact_update_ip,
prdact.id  prdact_id,
prdact.persons_id_upd   prdact_person_id_upd,
prdact.contents  prdact_contents,
prdact.cmpldate  prdact_cmpldate,
prdact.chrgs_id   prdact_chrg_id,
prdact.isudate  prdact_isudate,
prdact.prjnos_id   prdact_prjno_id,
prdact.opeitms_id   prdact_opeitm_id,
prdact.expiredate  prdact_expiredate,
prdact.updated_at  prdact_updated_at,
prdact.sno  prdact_sno,
prdact.cno  prdact_cno,
prdact.gno  prdact_gno,
  crr.crr_code  crr_code ,
  crr.crr_name  crr_name ,
  crr.crr_pricedecimal  crr_pricedecimal ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  opeitm.unit_code_box  unit_code_box ,
  opeitm.unit_name_box  unit_name_box ,
  opeitm.boxe_unit_id_outbox  boxe_unit_id_outbox ,
  opeitm.unit_code_outbox  unit_code_outbox ,
  opeitm.unit_name_outbox  unit_name_outbox ,
  opeitm.boxe_code  boxe_code ,
  opeitm.boxe_name  boxe_name ,
  opeitm.opeitm_boxe_id  opeitm_boxe_id ,
prdact.lotno  prdact_lotno,
  prjno.prjno_code_chil  prjno_code_chil ,
  opeitm.itm_classlist_id  itm_classlist_id ,
  shelfno_to.shelfno_code  shelfno_code_to ,
  shelfno_to.shelfno_name  shelfno_name_to ,
  shelfno_to.loca_code_shelfno  loca_code_shelfno_to ,
  shelfno_to.loca_name_shelfno  loca_name_shelfno_to ,
  shelfno_to.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_to ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
  workplace.workplace_loca_id_workplace  workplace_loca_id_workplace ,
  workplace.loca_code_workplace  loca_code_workplace ,
  workplace.loca_name_workplace  loca_name_workplace ,
prdact.shelfnos_id_to   prdact_shelfno_id_to,
prdact.qty_stk  prdact_qty_stk,
prdact.sno_prdord  prdact_sno_prdord,
prdact.sno_prdinst  prdact_sno_prdinst,
prdact.cno_prdinst  prdact_cno_prdinst,
  workplace.workplace_chrg_id_workplace  workplace_chrg_id_workplace ,
  workplace.person_code_chrg_workplace  person_code_chrg_workplace ,
  workplace.person_name_chrg_workplace  person_name_chrg_workplace ,
  workplace.person_sect_id_chrg_workplace  person_sect_id_chrg_workplace ,
  workplace.chrg_person_id_chrg_workplace  chrg_person_id_chrg_workplace ,
prdact.workplaces_id   prdact_workplace_id,
prdact.packno  prdact_packno,
  prjno.prjno_name_chil  prjno_name_chil ,
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
prdact.shelfnos_id_fm   prdact_shelfno_id_fm,
prdact.crrs_id   prdact_crr_id
 from prdacts   prdact,
  r_persons  person_upd ,  r_chrgs  chrg ,  r_prjnos  prjno ,  r_opeitms  opeitm ,  r_shelfnos  shelfno_to ,  r_workplaces  workplace ,  r_shelfnos  shelfno_fm ,  r_crrs  crr 
  where       prdact.persons_id_upd = person_upd.id      and prdact.chrgs_id = chrg.id      and prdact.prjnos_id = prjno.id      and prdact.opeitms_id = opeitm.id      and prdact.shelfnos_id_to = shelfno_to.id      and prdact.workplaces_id = workplace.id      and prdact.shelfnos_id_fm = shelfno_fm.id      and prdact.crrs_id = crr.id     ;
 DROP TABLE IF EXISTS sio.sio_r_prdacts;
 CREATE TABLE sio.sio_r_prdacts (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_prdacts_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,prdact_sno_prdord  varchar (50) 
,prdact_isudate   timestamp(6) 
,loca_code_workplace  varchar (50) 
,person_code_upd  varchar (50) 
,loca_name_workplace  varchar (100) 
,person_name_upd  varchar (100) 
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,prdact_qty_stk  numeric (22,6)
,prdact_cmpldate   timestamp(6) 
,loca_code_shelfno_to  varchar (50) 
,loca_name_shelfno_to  varchar (100) 
,prdact_gno  varchar (40) 
,prdact_sno  varchar (40) 
,prjno_code  varchar (50) 
,boxe_code  varchar (50) 
,classlist_code  varchar (50) 
,prdact_cno  varchar (40) 
,crr_code  varchar (50) 
,unit_code  varchar (50) 
,prdact_cno_prdinst  varchar (50) 
,unit_name  varchar (100) 
,prjno_name  varchar (100) 
,classlist_name  varchar (100) 
,prdact_expiredate   date 
,crr_name  varchar (100) 
,boxe_name  varchar (100) 
,prdact_lotno  varchar (50) 
,prdact_sno_prdinst  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,unit_code_box  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,prjno_code_chil  varchar (50) 
,person_code_chrg_workplace  varchar (50) 
,shelfno_code_to  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,unit_code_case_shp  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,shelfno_code_fm  varchar (50) 
,unit_code_outbox  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,loca_code_opeitm  varchar (50) 
,person_code_chrg  varchar (50) 
,loca_name_opeitm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,prjno_name_chil  varchar (100) 
,unit_name_box  varchar (100) 
,unit_name_outbox  varchar (100) 
,unit_name_case_shp  varchar (100) 
,person_name_chrg  varchar (100) 
,person_name_chrg_workplace  varchar (100) 
,shelfno_name_to  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,shelfno_name_fm  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,opeitm_priority  numeric (3,0)
,prdact_packno  varchar (10) 
,prdact_crr_id  numeric (22,0)
,crr_pricedecimal  numeric (22,0)
,prdact_shelfno_id_fm  numeric (22,0)
,prdact_contents  varchar (4000) 
,prdact_remark  varchar (4000) 
,shelfno_loca_id_shelfno_to  numeric (38,0)
,workplace_chrg_id_workplace  numeric (22,0)
,itm_classlist_id  numeric (38,0)
,opeitm_boxe_id  numeric (22,0)
,person_sect_id_chrg_workplace  numeric (22,0)
,chrg_person_id_chrg_workplace  numeric (38,0)
,prdact_workplace_id  numeric (22,0)
,boxe_unit_id_outbox  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,prdact_updated_at   timestamp(6) 
,prdact_opeitm_id  numeric (38,0)
,prdact_prjno_id  numeric (38,0)
,prdact_chrg_id  numeric (38,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,prdact_person_id_upd  numeric (38,0)
,prdact_id  numeric (38,0)
,prdact_update_ip  varchar (40) 
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,prdact_created_at   timestamp(6) 
,chrg_person_id_chrg  numeric (38,0)
,person_sect_id_chrg  numeric (22,0)
,id  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,itm_unit_id  numeric (22,0)
,workplace_loca_id_workplace  numeric (22,0)
,prdact_shelfno_id_to  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
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
 CREATE INDEX sio_r_prdacts_uk1 
  ON sio.sio_r_prdacts(id,sio_id); 

 drop sequence  if exists sio.sio_r_prdacts_seq ;
 create sequence sio.sio_r_prdacts_seq ;
  drop view if  exists r_purrets cascade ; 
 create or replace view r_purrets as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.unit_name  unit_name ,
  opeitm.unit_code  unit_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
purret.id id,
  prjno.prjno_name  prjno_name ,
  chrg.person_sect_id_chrg  person_sect_id_chrg ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  prjno.prjno_code  prjno_code ,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
purret.qty_case  purret_qty_case,
purret.contract_price  purret_contract_price,
purret.chrgs_id   purret_chrg_id,
purret.id  purret_id,
purret.remark  purret_remark,
purret.expiredate  purret_expiredate,
purret.update_ip  purret_update_ip,
purret.created_at  purret_created_at,
purret.updated_at  purret_updated_at,
purret.persons_id_upd   purret_person_id_upd,
purret.qty  purret_qty,
purret.price  purret_price,
purret.amt  purret_amt,
purret.isudate  purret_isudate,
purret.contents  purret_contents,
purret.tax  purret_tax,
purret.prjnos_id   purret_prjno_id,
purret.opeitms_id   purret_opeitm_id,
  supplier.loca_code_payment  loca_code_payment ,
  supplier.loca_name_payment  loca_name_payment ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  supplier.payment_loca_id_payment  payment_loca_id_payment ,
  crr.crr_code  crr_code ,
  crr.crr_name  crr_name ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  opeitm.unit_code_box  unit_code_box ,
  opeitm.unit_name_box  unit_name_box ,
  opeitm.boxe_unit_id_outbox  boxe_unit_id_outbox ,
  opeitm.unit_code_outbox  unit_code_outbox ,
  opeitm.unit_name_outbox  unit_name_outbox ,
  opeitm.boxe_code  boxe_code ,
  opeitm.boxe_name  boxe_name ,
  opeitm.opeitm_boxe_id  opeitm_boxe_id ,
purret.retdate  purret_retdate,
purret.locas_id_fm   purret_loca_id_fm,
  loca_fm.loca_code  loca_code_fm ,
  loca_fm.loca_name  loca_name_fm ,
purret.sno  purret_sno,
  prjno.prjno_code_chil  prjno_code_chil ,
  supplier.payment_chrg_id_payment  payment_chrg_id_payment ,
  supplier.person_code_chrg_payment  person_code_chrg_payment ,
  supplier.person_name_chrg_payment  person_name_chrg_payment ,
  supplier.supplier_payment_id  supplier_payment_id ,
  supplier.supplier_loca_id_supplier  supplier_loca_id_supplier ,
  supplier.supplier_chrg_id_supplier  supplier_chrg_id_supplier ,
  supplier.supplier_crr_id_supplier  supplier_crr_id_supplier ,
  supplier.loca_code_supplier  loca_code_supplier ,
  supplier.loca_name_supplier  loca_name_supplier ,
  supplier.person_code_chrg_supplier  person_code_chrg_supplier ,
  supplier.person_name_chrg_supplier  person_name_chrg_supplier ,
  supplier.crr_name_supplier  crr_name_supplier ,
  supplier.crr_code_supplier  crr_code_supplier ,
  opeitm.itm_classlist_id  itm_classlist_id ,
  supplier.chrg_person_id_chrg_supplier  chrg_person_id_chrg_supplier ,
  supplier.chrg_person_id_chrg_payment  chrg_person_id_chrg_payment ,
  supplier.person_sect_id_chrg_supplier  person_sect_id_chrg_supplier ,
  supplier.person_sect_id_chrg_payment  person_sect_id_chrg_payment ,
purret.suppliers_id   purret_supplier_id,
purret.crrs_id   purret_crr_id,
  supplier.crr_code_payment  crr_code_payment ,
  supplier.crr_name_payment  crr_name_payment ,
  prjno.prjno_name_chil  prjno_name_chil ,
purret.sno_puract  purret_sno_puract,
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
  opeitm.unit_code_case_prdpur  unit_code_case_prdpur 
 from purrets   purret,
  r_chrgs  chrg ,  r_persons  person_upd ,  r_prjnos  prjno ,  r_opeitms  opeitm ,  r_locas  loca_fm ,  r_suppliers  supplier ,  r_crrs  crr 
  where       purret.chrgs_id = chrg.id      and purret.persons_id_upd = person_upd.id      and purret.prjnos_id = prjno.id      and purret.opeitms_id = opeitm.id      and purret.locas_id_fm = loca_fm.id      and purret.suppliers_id = supplier.id      and purret.crrs_id = crr.id     ;
 DROP TABLE IF EXISTS sio.sio_r_purrets;
 CREATE TABLE sio.sio_r_purrets (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_purrets_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,classlist_code  varchar (50) 
,prjno_code  varchar (50) 
,itm_code  varchar (50) 
,boxe_code  varchar (50) 
,unit_code  varchar (50) 
,crr_code  varchar (50) 
,unit_name  varchar (100) 
,itm_name  varchar (100) 
,classlist_name  varchar (100) 
,crr_name  varchar (100) 
,boxe_name  varchar (100) 
,prjno_name  varchar (100) 
,prjno_code_chil  varchar (50) 
,loca_code_fm  varchar (50) 
,unit_code_outbox  varchar (50) 
,unit_code_box  varchar (50) 
,loca_code_opeitm  varchar (50) 
,person_code_chrg  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,unit_code_case_shp  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,loca_code_payment  varchar (50) 
,crr_code_payment  varchar (50) 
,crr_code_supplier  varchar (50) 
,person_code_chrg_supplier  varchar (50) 
,loca_code_supplier  varchar (50) 
,person_code_chrg_payment  varchar (50) 
,shelfno_name_fm_opeitm  varchar (100) 
,loca_name_payment  varchar (100) 
,unit_name_box  varchar (100) 
,unit_name_outbox  varchar (100) 
,loca_name_fm  varchar (100) 
,person_name_chrg_payment  varchar (100) 
,loca_name_supplier  varchar (100) 
,person_name_chrg_supplier  varchar (100) 
,crr_name_supplier  varchar (100) 
,crr_name_payment  varchar (100) 
,prjno_name_chil  varchar (100) 
,loca_name_opeitm  varchar (100) 
,person_name_chrg  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,unit_name_case_shp  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,purret_qty_case  numeric (22,0)
,purret_contract_price  varchar (1) 
,opeitm_priority  numeric (3,0)
,purret_loca_id_fm  numeric (38,0)
,purret_supplier_id  numeric (22,0)
,purret_crr_id  numeric (22,0)
,purret_sno_puract  varchar (50) 
,purret_retdate   date 
,purret_remark  varchar (4000) 
,purret_expiredate   date 
,purret_qty  numeric (18,4)
,purret_price  numeric (22,0)
,purret_amt  numeric (18,4)
,purret_sno  varchar (40) 
,purret_isudate   timestamp(6) 
,purret_contents  varchar (4000) 
,purret_tax  numeric (22,0)
,opeitm_boxe_id  numeric (22,0)
,chrg_person_id_chrg  numeric (38,0)
,payment_chrg_id_payment  numeric (22,0)
,opeitm_itm_id  numeric (38,0)
,supplier_payment_id  numeric (38,0)
,supplier_loca_id_supplier  numeric (22,0)
,supplier_chrg_id_supplier  numeric (22,0)
,supplier_crr_id_supplier  numeric (22,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,person_sect_id_chrg  numeric (22,0)
,itm_classlist_id  numeric (38,0)
,chrg_person_id_chrg_supplier  numeric (38,0)
,chrg_person_id_chrg_payment  numeric (38,0)
,person_sect_id_chrg_supplier  numeric (22,0)
,person_sect_id_chrg_payment  numeric (22,0)
,itm_unit_id  numeric (22,0)
,payment_loca_id_payment  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,boxe_unit_id_outbox  numeric (38,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,purret_person_id_upd  numeric (22,0)
,purret_chrg_id  numeric (22,0)
,purret_id  numeric (22,0)
,purret_updated_at   timestamp(6) 
,purret_update_ip  varchar (40) 
,purret_prjno_id  numeric (22,0)
,purret_created_at   timestamp(6) 
,purret_opeitm_id  numeric (22,0)
,id  numeric (38,0)
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
 CREATE INDEX sio_r_purrets_uk1 
  ON sio.sio_r_purrets(id,sio_id); 

 drop sequence  if exists sio.sio_r_purrets_seq ;
 create sequence sio.sio_r_purrets_seq ;
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
  drop view if  exists r_prdinsts cascade ; 
 create or replace view r_prdinsts as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.unit_name  unit_name ,
  opeitm.unit_code  unit_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
prdinst.id id,
  loca_to.loca_code  loca_code_to ,
  loca_to.loca_name  loca_name_to ,
  prjno.prjno_name  prjno_name ,
  chrg.person_sect_id_chrg  person_sect_id_chrg ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  prjno.prjno_code  prjno_code ,
prdinst.prjnos_id   prdinst_prjno_id,
prdinst.cno  prdinst_cno,
prdinst.opeitms_id   prdinst_opeitm_id,
prdinst.contents  prdinst_contents,
prdinst.id  prdinst_id,
prdinst.remark  prdinst_remark,
prdinst.expiredate  prdinst_expiredate,
prdinst.update_ip  prdinst_update_ip,
prdinst.created_at  prdinst_created_at,
prdinst.updated_at  prdinst_updated_at,
prdinst.persons_id_upd   prdinst_person_id_upd,
prdinst.qty  prdinst_qty,
prdinst.sno  prdinst_sno,
prdinst.duedate  prdinst_duedate,
prdinst.isudate  prdinst_isudate,
prdinst.locas_id_to   prdinst_loca_id_to,
prdinst.qty_case  prdinst_qty_case,
prdinst.commencementdate  prdinst_commencementdate,
prdinst.commencement_f  prdinst_commencement_f,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
prdinst.chrgs_id   prdinst_chrg_id,
prdinst.gno  prdinst_gno,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  opeitm.unit_code_box  unit_code_box ,
  opeitm.unit_name_box  unit_name_box ,
  opeitm.boxe_unit_id_outbox  boxe_unit_id_outbox ,
  opeitm.unit_code_outbox  unit_code_outbox ,
  opeitm.unit_name_outbox  unit_name_outbox ,
  opeitm.boxe_code  boxe_code ,
  opeitm.boxe_name  boxe_name ,
  opeitm.opeitm_boxe_id  opeitm_boxe_id ,
prdinst.starttime  prdinst_starttime,
  prjno.prjno_code_chil  prjno_code_chil ,
  opeitm.itm_classlist_id  itm_classlist_id ,
  shelfno_to.shelfno_code  shelfno_code_to ,
  shelfno_to.shelfno_name  shelfno_name_to ,
  shelfno_to.loca_code_shelfno  loca_code_shelfno_to ,
  shelfno_to.loca_name_shelfno  loca_name_shelfno_to ,
  shelfno_to.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_to ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
  workplace.workplace_loca_id_workplace  workplace_loca_id_workplace ,
  workplace.loca_code_workplace  loca_code_workplace ,
  workplace.loca_name_workplace  loca_name_workplace ,
  workplace.workplace_chrg_id_workplace  workplace_chrg_id_workplace ,
  workplace.person_code_chrg_workplace  person_code_chrg_workplace ,
  workplace.person_name_chrg_workplace  person_name_chrg_workplace ,
  workplace.person_sect_id_chrg_workplace  person_sect_id_chrg_workplace ,
  workplace.chrg_person_id_chrg_workplace  chrg_person_id_chrg_workplace ,
prdinst.sno_prdord  prdinst_sno_prdord,
prdinst.shelfnos_id_to   prdinst_shelfno_id_to,
prdinst.workplaces_id   prdinst_workplace_id,
  prjno.prjno_name_chil  prjno_name_chil ,
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
prdinst.shelfnos_id_fm   prdinst_shelfno_id_fm
 from prdinsts   prdinst,
  r_prjnos  prjno ,  r_opeitms  opeitm ,  r_persons  person_upd ,  r_locas  loca_to ,  r_chrgs  chrg ,  r_shelfnos  shelfno_to ,  r_workplaces  workplace ,  r_shelfnos  shelfno_fm 
  where       prdinst.prjnos_id = prjno.id      and prdinst.opeitms_id = opeitm.id      and prdinst.persons_id_upd = person_upd.id      and prdinst.locas_id_to = loca_to.id      and prdinst.chrgs_id = chrg.id      and prdinst.shelfnos_id_to = shelfno_to.id      and prdinst.workplaces_id = workplace.id      and prdinst.shelfnos_id_fm = shelfno_fm.id     ;
 DROP TABLE IF EXISTS sio.sio_r_prdinsts;
 CREATE TABLE sio.sio_r_prdinsts (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_prdinsts_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,prdinst_sno  varchar (40) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,prdinst_isudate   timestamp(6) 
,prdinst_duedate   timestamp(6) 
,loca_code_to  varchar (50) 
,prdinst_qty  numeric (18,4)
,prdinst_qty_case  numeric (38,0)
,person_name_chrg  varchar (100) 
,classlist_code  varchar (50) 
,boxe_code  varchar (50) 
,prjno_code  varchar (50) 
,unit_code  varchar (50) 
,prdinst_starttime   timestamp(6) 
,unit_name  varchar (100) 
,prjno_name  varchar (100) 
,prdinst_sno_prdord  varchar (50) 
,prdinst_expiredate   date 
,prdinst_commencementdate   timestamp(6) 
,prdinst_commencement_f  varchar (1) 
,classlist_name  varchar (100) 
,boxe_name  varchar (100) 
,loca_code_shelfno_fm  varchar (50) 
,shelfno_code_fm  varchar (50) 
,loca_code_shelfno_to  varchar (50) 
,shelfno_code_to  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,prjno_code_chil  varchar (50) 
,unit_code_case_shp  varchar (50) 
,person_code_chrg  varchar (50) 
,unit_code_outbox  varchar (50) 
,prdinst_cno  varchar (40) 
,loca_code_opeitm  varchar (50) 
,unit_code_box  varchar (50) 
,person_code_chrg_workplace  varchar (50) 
,loca_code_workplace  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,loca_name_to  varchar (100) 
,unit_name_box  varchar (100) 
,unit_name_outbox  varchar (100) 
,shelfno_name_to  varchar (100) 
,loca_name_shelfno_to  varchar (100) 
,shelfno_name_fm  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,loca_name_workplace  varchar (100) 
,person_name_chrg_workplace  varchar (100) 
,prjno_name_chil  varchar (100) 
,loca_name_opeitm  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,unit_name_case_shp  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,opeitm_priority  numeric (3,0)
,prdinst_gno  varchar (40) 
,prdinst_shelfno_id_fm  numeric (22,0)
,prdinst_contents  varchar (4000) 
,prdinst_remark  varchar (4000) 
,id  numeric (38,0)
,workplace_chrg_id_workplace  numeric (22,0)
,prdinst_id  numeric (38,0)
,person_sect_id_chrg_workplace  numeric (22,0)
,chrg_person_id_chrg_workplace  numeric (38,0)
,prdinst_shelfno_id_to  numeric (38,0)
,prdinst_workplace_id  numeric (22,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,prdinst_opeitm_id  numeric (38,0)
,boxe_unit_id_outbox  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,prdinst_prjno_id  numeric (38,0)
,prdinst_chrg_id  numeric (38,0)
,prdinst_created_at   timestamp(6) 
,prdinst_update_ip  varchar (40) 
,itm_unit_id  numeric (22,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,workplace_loca_id_workplace  numeric (22,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,person_sect_id_chrg  numeric (22,0)
,chrg_person_id_chrg  numeric (38,0)
,prdinst_loca_id_to  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,prdinst_person_id_upd  numeric (38,0)
,prdinst_updated_at   timestamp(6) 
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,opeitm_boxe_id  numeric (22,0)
,opeitm_itm_id  numeric (38,0)
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
 CREATE INDEX sio_r_prdinsts_uk1 
  ON sio.sio_r_prdinsts(id,sio_id); 

 drop sequence  if exists sio.sio_r_prdinsts_seq ;
 create sequence sio.sio_r_prdinsts_seq ;
  drop view if  exists r_puracts cascade ; 
 create or replace view r_puracts as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.unit_name  unit_name ,
  opeitm.unit_code  unit_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
puract.id id,
  prjno.prjno_name  prjno_name ,
  chrg.person_sect_id_chrg  person_sect_id_chrg ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
puract.opeitms_id   puract_opeitm_id,
puract.id  puract_id,
puract.remark  puract_remark,
puract.expiredate  puract_expiredate,
puract.update_ip  puract_update_ip,
puract.created_at  puract_created_at,
puract.updated_at  puract_updated_at,
puract.persons_id_upd   puract_person_id_upd,
puract.amt  puract_amt,
puract.isudate  puract_isudate,
puract.contents  puract_contents,
puract.rcptdate  puract_rcptdate,
  prjno.prjno_code  prjno_code ,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
puract.chrgs_id   puract_chrg_id,
puract.prjnos_id   puract_prjno_id,
puract.sno  puract_sno,
  supplier.loca_code_payment  loca_code_payment ,
  supplier.loca_name_payment  loca_name_payment ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
puract.cno  puract_cno,
  supplier.payment_loca_id_payment  payment_loca_id_payment ,
  crr.crr_code  crr_code ,
  crr.crr_name  crr_name ,
  crr.crr_pricedecimal  crr_pricedecimal ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  opeitm.unit_code_box  unit_code_box ,
  opeitm.unit_name_box  unit_name_box ,
  opeitm.boxe_unit_id_outbox  boxe_unit_id_outbox ,
  opeitm.unit_code_outbox  unit_code_outbox ,
  opeitm.unit_name_outbox  unit_name_outbox ,
  opeitm.boxe_code  boxe_code ,
  opeitm.boxe_name  boxe_name ,
  opeitm.opeitm_boxe_id  opeitm_boxe_id ,
puract.lotno  puract_lotno,
puract.itm_code_client  puract_itm_code_client,
  prjno.prjno_code_chil  prjno_code_chil ,
  supplier.payment_chrg_id_payment  payment_chrg_id_payment ,
  supplier.person_code_chrg_payment  person_code_chrg_payment ,
  supplier.person_name_chrg_payment  person_name_chrg_payment ,
  supplier.supplier_payment_id  supplier_payment_id ,
  supplier.supplier_loca_id_supplier  supplier_loca_id_supplier ,
  supplier.supplier_chrg_id_supplier  supplier_chrg_id_supplier ,
  supplier.supplier_crr_id_supplier  supplier_crr_id_supplier ,
  supplier.loca_code_supplier  loca_code_supplier ,
  supplier.loca_name_supplier  loca_name_supplier ,
  supplier.person_code_chrg_supplier  person_code_chrg_supplier ,
  supplier.person_name_chrg_supplier  person_name_chrg_supplier ,
  supplier.crr_name_supplier  crr_name_supplier ,
  supplier.crr_code_supplier  crr_code_supplier ,
  opeitm.itm_classlist_id  itm_classlist_id ,
  supplier.chrg_person_id_chrg_supplier  chrg_person_id_chrg_supplier ,
  supplier.chrg_person_id_chrg_payment  chrg_person_id_chrg_payment ,
  supplier.person_sect_id_chrg_supplier  person_sect_id_chrg_supplier ,
  supplier.person_sect_id_chrg_payment  person_sect_id_chrg_payment ,
puract.suppliers_id   puract_supplier_id,
puract.sno_purinst  puract_sno_purinst,
puract.sno_purord  puract_sno_purord,
puract.sno_purdlv  puract_sno_purdlv,
puract.cno_purinst  puract_cno_purinst,
puract.cno_purdlv  puract_cno_purdlv,
puract.qty_stk  puract_qty_stk,
  shelfno_to.shelfno_code  shelfno_code_to ,
  shelfno_to.shelfno_name  shelfno_name_to ,
  shelfno_to.loca_code_shelfno  loca_code_shelfno_to ,
  shelfno_to.loca_name_shelfno  loca_name_shelfno_to ,
  shelfno_to.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_to ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
puract.shelfnos_id_to   puract_shelfno_id_to,
puract.packno  puract_packno,
puract.crrs_id   puract_crr_id,
  supplier.crr_code_payment  crr_code_payment ,
  supplier.crr_name_payment  crr_name_payment ,
  prjno.prjno_name_chil  prjno_name_chil ,
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
puract.shelfnos_id_fm   puract_shelfno_id_fm,
puract.invoiceno  puract_invoiceno,
puract.cartonno  puract_cartonno
 from puracts   puract,
  r_opeitms  opeitm ,  r_persons  person_upd ,  r_chrgs  chrg ,  r_prjnos  prjno ,  r_suppliers  supplier ,  r_shelfnos  shelfno_to ,  r_crrs  crr ,  r_shelfnos  shelfno_fm 
  where       puract.opeitms_id = opeitm.id      and puract.persons_id_upd = person_upd.id      and puract.chrgs_id = chrg.id      and puract.prjnos_id = prjno.id      and puract.suppliers_id = supplier.id      and puract.shelfnos_id_to = shelfno_to.id      and puract.crrs_id = crr.id      and puract.shelfnos_id_fm = shelfno_fm.id     ;
 DROP TABLE IF EXISTS sio.sio_r_puracts;
 CREATE TABLE sio.sio_r_puracts (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_puracts_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,puract_sno_purord  varchar (50) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,puract_isudate   timestamp(6) 
,puract_rcptdate   timestamp(6) 
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,puract_itm_code_client  varchar (50) 
,puract_qty_stk  numeric (38,4)
,unit_code  varchar (50) 
,unit_name  varchar (100) 
,unit_code_outbox  varchar (50) 
,unit_name_outbox  varchar (100) 
,crr_code_supplier  varchar (50) 
,crr_name_supplier  varchar (100) 
,crr_code  varchar (50) 
,loca_code_supplier  varchar (50) 
,loca_name_supplier  varchar (100) 
,person_code_chrg  varchar (50) 
,person_name_chrg  varchar (100) 
,person_code_chrg_supplier  varchar (50) 
,person_name_chrg_supplier  varchar (100) 
,person_code_chrg_payment  varchar (50) 
,person_name_chrg_payment  varchar (100) 
,boxe_name  varchar (100) 
,unit_code_box  varchar (50) 
,unit_name_box  varchar (100) 
,prjno_name  varchar (100) 
,boxe_code  varchar (50) 
,prjno_code  varchar (50) 
,prjno_code_chil  varchar (50) 
,loca_code_payment  varchar (50) 
,loca_name_payment  varchar (100) 
,classlist_code  varchar (50) 
,classlist_name  varchar (100) 
,puract_expiredate   date 
,puract_cno_purinst  varchar (50) 
,puract_cno_purdlv  varchar (50) 
,crr_name  varchar (100) 
,puract_lotno  varchar (50) 
,loca_code_shelfno_to  varchar (50) 
,shelfno_code_fm  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,crr_code_payment  varchar (50) 
,loca_code_opeitm  varchar (50) 
,opeitm_priority  numeric (3,0)
,unit_code_case_shp  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,shelfno_code_to  varchar (50) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,loca_name_opeitm  varchar (100) 
,prjno_name_chil  varchar (100) 
,crr_name_payment  varchar (100) 
,shelfno_name_fm  varchar (100) 
,loca_name_shelfno_to  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,shelfno_name_to  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,unit_name_case_shp  varchar (100) 
,puract_cno  varchar (40) 
,puract_sno  varchar (40) 
,puract_sno_purdlv  varchar (50) 
,puract_sno_purinst  varchar (50) 
,puract_packno  varchar (10) 
,puract_invoiceno  varchar (50) 
,puract_cartonno  varchar (50) 
,puract_crr_id  numeric (22,0)
,crr_pricedecimal  numeric (22,0)
,puract_amt  numeric (18,4)
,puract_shelfno_id_fm  numeric (22,0)
,puract_contents  varchar (4000) 
,puract_remark  varchar (4000) 
,puract_supplier_id  numeric (22,0)
,puract_opeitm_id  numeric (38,0)
,puract_update_ip  varchar (40) 
,puract_created_at   timestamp(6) 
,puract_updated_at   timestamp(6) 
,puract_person_id_upd  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,puract_chrg_id  numeric (38,0)
,puract_prjno_id  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,boxe_unit_id_outbox  numeric (38,0)
,chrg_person_id_chrg_supplier  numeric (38,0)
,chrg_person_id_chrg_payment  numeric (38,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,puract_shelfno_id_to  numeric (38,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,supplier_crr_id_supplier  numeric (22,0)
,supplier_chrg_id_supplier  numeric (22,0)
,supplier_loca_id_supplier  numeric (22,0)
,itm_unit_id  numeric (22,0)
,supplier_payment_id  numeric (38,0)
,payment_chrg_id_payment  numeric (22,0)
,opeitm_boxe_id  numeric (22,0)
,payment_loca_id_payment  numeric (38,0)
,puract_id  numeric (38,0)
,person_sect_id_chrg  numeric (22,0)
,id  numeric (38,0)
,person_sect_id_chrg_payment  numeric (22,0)
,person_sect_id_chrg_supplier  numeric (22,0)
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
 CREATE INDEX sio_r_puracts_uk1 
  ON sio.sio_r_puracts(id,sio_id); 

 drop sequence  if exists sio.sio_r_puracts_seq ;
 create sequence sio.sio_r_puracts_seq ;
  drop view if  exists r_purinsts cascade ; 
 create or replace view r_purinsts as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.unit_name  unit_name ,
  opeitm.unit_code  unit_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
purinst.id id,
  prjno.prjno_name  prjno_name ,
  chrg.person_sect_id_chrg  person_sect_id_chrg ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
purinst.qty_case  purinst_qty_case,
purinst.cno  purinst_cno,
purinst.isudate  purinst_isudate,
purinst.opeitms_id   purinst_opeitm_id,
purinst.expiredate  purinst_expiredate,
purinst.updated_at  purinst_updated_at,
purinst.qty  purinst_qty,
purinst.sno  purinst_sno,
purinst.price  purinst_price,
purinst.remark  purinst_remark,
purinst.created_at  purinst_created_at,
purinst.update_ip  purinst_update_ip,
purinst.duedate  purinst_duedate,
purinst.amt  purinst_amt,
purinst.id  purinst_id,
purinst.persons_id_upd   purinst_person_id_upd,
  prjno.prjno_code  prjno_code ,
purinst.prjnos_id   purinst_prjno_id,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
purinst.contract_price  purinst_contract_price,
purinst.chrgs_id   purinst_chrg_id,
  supplier.loca_code_payment  loca_code_payment ,
  supplier.loca_name_payment  loca_name_payment ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
purinst.tax  purinst_tax,
  supplier.payment_loca_id_payment  payment_loca_id_payment ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  opeitm.unit_code_box  unit_code_box ,
  opeitm.unit_name_box  unit_name_box ,
  opeitm.boxe_unit_id_outbox  boxe_unit_id_outbox ,
  opeitm.unit_code_outbox  unit_code_outbox ,
  opeitm.unit_name_outbox  unit_name_outbox ,
  opeitm.boxe_code  boxe_code ,
  opeitm.boxe_name  boxe_name ,
  opeitm.opeitm_boxe_id  opeitm_boxe_id ,
purinst.starttime  purinst_starttime,
purinst.itm_code_client  purinst_itm_code_client,
  prjno.prjno_code_chil  prjno_code_chil ,
  supplier.payment_chrg_id_payment  payment_chrg_id_payment ,
  supplier.person_code_chrg_payment  person_code_chrg_payment ,
  supplier.person_name_chrg_payment  person_name_chrg_payment ,
  supplier.supplier_payment_id  supplier_payment_id ,
  supplier.supplier_loca_id_supplier  supplier_loca_id_supplier ,
  supplier.supplier_chrg_id_supplier  supplier_chrg_id_supplier ,
  supplier.supplier_crr_id_supplier  supplier_crr_id_supplier ,
  supplier.loca_code_supplier  loca_code_supplier ,
  supplier.loca_name_supplier  loca_name_supplier ,
  supplier.person_code_chrg_supplier  person_code_chrg_supplier ,
  supplier.person_name_chrg_supplier  person_name_chrg_supplier ,
  supplier.crr_name_supplier  crr_name_supplier ,
  supplier.crr_code_supplier  crr_code_supplier ,
  opeitm.itm_classlist_id  itm_classlist_id ,
purinst.autoact_p  purinst_autoact_p,
purinst.suppliers_id   purinst_supplier_id,
  supplier.chrg_person_id_chrg_supplier  chrg_person_id_chrg_supplier ,
  supplier.chrg_person_id_chrg_payment  chrg_person_id_chrg_payment ,
  supplier.person_sect_id_chrg_supplier  person_sect_id_chrg_supplier ,
  supplier.person_sect_id_chrg_payment  person_sect_id_chrg_payment ,
purinst.sno_purord  purinst_sno_purord,
  shelfno_to.shelfno_code  shelfno_code_to ,
  shelfno_to.shelfno_name  shelfno_name_to ,
  shelfno_to.loca_code_shelfno  loca_code_shelfno_to ,
  shelfno_to.loca_name_shelfno  loca_name_shelfno_to ,
  shelfno_to.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_to ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
purinst.shelfnos_id_to   purinst_shelfno_id_to,
  supplier.crr_code_payment  crr_code_payment ,
  supplier.crr_name_payment  crr_name_payment ,
  prjno.prjno_name_chil  prjno_name_chil ,
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
purinst.shelfnos_id_fm   purinst_shelfno_id_fm
 from purinsts   purinst,
  r_opeitms  opeitm ,  r_persons  person_upd ,  r_prjnos  prjno ,  r_chrgs  chrg ,  r_suppliers  supplier ,  r_shelfnos  shelfno_to ,  r_shelfnos  shelfno_fm 
  where       purinst.opeitms_id = opeitm.id      and purinst.persons_id_upd = person_upd.id      and purinst.prjnos_id = prjno.id      and purinst.chrgs_id = chrg.id      and purinst.suppliers_id = supplier.id      and purinst.shelfnos_id_to = shelfno_to.id      and purinst.shelfnos_id_fm = shelfno_fm.id     ;
 DROP TABLE IF EXISTS sio.sio_r_purinsts;
 CREATE TABLE sio.sio_r_purinsts (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_purinsts_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,purinst_sno_purord  varchar (50) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,purinst_isudate   timestamp(6) 
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,purinst_qty  numeric (18,4)
,purinst_qty_case  numeric (38,0)
,shelfno_code_to  varchar (50) 
,shelfno_name_to  varchar (100) 
,prjno_code  varchar (50) 
,prjno_name  varchar (100) 
,person_code_chrg  varchar (50) 
,purinst_cno  varchar (40) 
,purinst_sno  varchar (40) 
,boxe_code  varchar (50) 
,classlist_code  varchar (50) 
,unit_code  varchar (50) 
,purinst_expiredate   date 
,boxe_name  varchar (100) 
,purinst_starttime   timestamp(6) 
,unit_name  varchar (100) 
,purinst_autoact_p  numeric (3,0)
,purinst_contract_price  varchar (1) 
,classlist_name  varchar (100) 
,purinst_itm_code_client  varchar (50) 
,loca_code_shelfno_to  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,unit_code_box  varchar (50) 
,crr_code_supplier  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,person_code_chrg_supplier  varchar (50) 
,loca_code_payment  varchar (50) 
,unit_code_case_shp  varchar (50) 
,opeitm_priority  numeric (3,0)
,unit_code_outbox  varchar (50) 
,loca_code_supplier  varchar (50) 
,person_code_chrg_payment  varchar (50) 
,prjno_code_chil  varchar (50) 
,loca_code_opeitm  varchar (50) 
,crr_code_payment  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,shelfno_code_fm  varchar (50) 
,person_name_chrg  varchar (100) 
,loca_name_payment  varchar (100) 
,unit_name_box  varchar (100) 
,unit_name_outbox  varchar (100) 
,person_name_chrg_payment  varchar (100) 
,loca_name_supplier  varchar (100) 
,person_name_chrg_supplier  varchar (100) 
,crr_name_supplier  varchar (100) 
,loca_name_shelfno_to  varchar (100) 
,shelfno_name_fm  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,crr_name_payment  varchar (100) 
,prjno_name_chil  varchar (100) 
,loca_name_opeitm  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,unit_name_case_shp  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,purinst_amt  numeric (18,4)
,purinst_tax  numeric (38,4)
,purinst_duedate   timestamp(6) 
,purinst_price  numeric (38,4)
,purinst_shelfno_id_fm  numeric (22,0)
,purinst_remark  varchar (4000) 
,purinst_created_at   timestamp(6) 
,purinst_person_id_upd  numeric (38,0)
,purinst_id  numeric (38,0)
,purinst_opeitm_id  numeric (38,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,purinst_update_ip  varchar (40) 
,itm_unit_id  numeric (22,0)
,person_sect_id_chrg  numeric (22,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,purinst_shelfno_id_to  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,opeitm_boxe_id  numeric (22,0)
,boxe_unit_id_box  numeric (38,0)
,payment_chrg_id_payment  numeric (22,0)
,payment_loca_id_payment  numeric (38,0)
,id  numeric (38,0)
,supplier_payment_id  numeric (38,0)
,supplier_loca_id_supplier  numeric (22,0)
,supplier_chrg_id_supplier  numeric (22,0)
,supplier_crr_id_supplier  numeric (22,0)
,purinst_updated_at   timestamp(6) 
,purinst_chrg_id  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,purinst_prjno_id  numeric (38,0)
,purinst_supplier_id  numeric (22,0)
,chrg_person_id_chrg_supplier  numeric (38,0)
,chrg_person_id_chrg_payment  numeric (38,0)
,person_sect_id_chrg_supplier  numeric (22,0)
,person_sect_id_chrg_payment  numeric (22,0)
,itm_classlist_id  numeric (38,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,boxe_unit_id_outbox  numeric (22,0)
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
 CREATE INDEX sio_r_purinsts_uk1 
  ON sio.sio_r_purinsts(id,sio_id); 

 drop sequence  if exists sio.sio_r_purinsts_seq ;
 create sequence sio.sio_r_purinsts_seq ;
  drop view if  exists r_purords cascade ; 
 create or replace view r_purords as select  
purord.autoinst_p  purord_autoinst_p,
purord.autoact_p  purord_autoact_p,
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
purord.qty  purord_qty,
purord.duedate  purord_duedate,
purord.isudate  purord_isudate,
purord.remark  purord_remark,
purord.update_ip  purord_update_ip,
purord.created_at  purord_created_at,
purord.updated_at  purord_updated_at,
purord.id  purord_id,
purord.sno  purord_sno,
purord.id id,
  prjno.prjno_name  prjno_name ,
  chrg.person_sect_id_chrg  person_sect_id_chrg ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
purord.amt  purord_amt,
purord.toduedate  purord_toduedate,
purord.persons_id_upd   purord_person_id_upd,
purord.expiredate  purord_expiredate,
purord.price  purord_price,
purord.qty_case  purord_qty_case,
purord.confirm  purord_confirm,
purord.opeitms_id   purord_opeitm_id,
  prjno.prjno_code  prjno_code ,
purord.prjnos_id   purord_prjno_id,
purord.contract_price  purord_contract_price,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
purord.chrgs_id   purord_chrg_id,
  supplier.loca_code_payment  loca_code_payment ,
  supplier.loca_name_payment  loca_name_payment ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
purord.tax  purord_tax,
purord.gno  purord_gno,
  supplier.payment_loca_id_payment  payment_loca_id_payment ,
  crr.crr_code  crr_code ,
  crr.crr_name  crr_name ,
  crr.crr_pricedecimal  crr_pricedecimal ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  opeitm.unit_code_box  unit_code_box ,
  opeitm.unit_name_box  unit_name_box ,
  opeitm.boxe_unit_id_outbox  boxe_unit_id_outbox ,
  opeitm.unit_code_outbox  unit_code_outbox ,
  opeitm.unit_name_outbox  unit_name_outbox ,
  opeitm.boxe_code  boxe_code ,
  opeitm.boxe_name  boxe_name ,
  opeitm.opeitm_boxe_id  opeitm_boxe_id ,
purord.itm_code_client  purord_itm_code_client,
purord.starttime  purord_starttime,
  prjno.prjno_code_chil  prjno_code_chil ,
  supplier.payment_chrg_id_payment  payment_chrg_id_payment ,
  supplier.person_code_chrg_payment  person_code_chrg_payment ,
  supplier.person_name_chrg_payment  person_name_chrg_payment ,
purord.suppliers_id   purord_supplier_id,
  supplier.supplier_payment_id  supplier_payment_id ,
  supplier.supplier_loca_id_supplier  supplier_loca_id_supplier ,
  supplier.supplier_chrg_id_supplier  supplier_chrg_id_supplier ,
  supplier.supplier_crr_id_supplier  supplier_crr_id_supplier ,
  supplier.loca_code_supplier  loca_code_supplier ,
  supplier.loca_name_supplier  loca_name_supplier ,
  supplier.person_code_chrg_supplier  person_code_chrg_supplier ,
  supplier.person_name_chrg_supplier  person_name_chrg_supplier ,
  supplier.crr_name_supplier  crr_name_supplier ,
  supplier.crr_code_supplier  crr_code_supplier ,
  opeitm.itm_classlist_id  itm_classlist_id ,
  supplier.chrg_person_id_chrg_supplier  chrg_person_id_chrg_supplier ,
  supplier.chrg_person_id_chrg_payment  chrg_person_id_chrg_payment ,
  supplier.person_sect_id_chrg_supplier  person_sect_id_chrg_supplier ,
  supplier.person_sect_id_chrg_payment  person_sect_id_chrg_payment ,
purord.shelfnos_id_to   purord_shelfno_id_to,
  shelfno_to.shelfno_code  shelfno_code_to ,
  shelfno_to.shelfno_name  shelfno_name_to ,
  shelfno_to.loca_code_shelfno  loca_code_shelfno_to ,
  shelfno_to.loca_name_shelfno  loca_name_shelfno_to ,
  shelfno_to.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_to ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
purord.crrs_id   purord_crr_id,
  supplier.payment_crr_id_payment  payment_crr_id_payment ,
  supplier.crr_code_payment  crr_code_payment ,
  supplier.crr_name_payment  crr_name_payment ,
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
purord.shelfnos_id_fm   purord_shelfno_id_fm
 from purords   purord,
  r_persons  person_upd ,  r_opeitms  opeitm ,  r_prjnos  prjno ,  r_chrgs  chrg ,  r_suppliers  supplier ,  r_shelfnos  shelfno_to ,  r_crrs  crr ,  r_shelfnos  shelfno_fm 
  where       purord.persons_id_upd = person_upd.id      and purord.opeitms_id = opeitm.id      and purord.prjnos_id = prjno.id      and purord.chrgs_id = chrg.id      and purord.suppliers_id = supplier.id      and purord.shelfnos_id_to = shelfno_to.id      and purord.crrs_id = crr.id      and purord.shelfnos_id_fm = shelfno_fm.id     ;
 DROP TABLE IF EXISTS sio.sio_r_purords;
 CREATE TABLE sio.sio_r_purords (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_purords_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,purord_confirm  char (01) 
,purord_sno  varchar (40) 
,purord_isudate   timestamp(6) 
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,opeitm_processseq  numeric (3,0)
,purord_starttime   timestamp(6) 
,purord_duedate   timestamp(6) 
,purord_qty  numeric (18,4)
,loca_code_supplier  varchar (50) 
,loca_name_supplier  varchar (100) 
,purord_qty_case  numeric (38,0)
,purord_price  numeric (38,4)
,purord_amt  numeric (18,4)
,purord_tax  numeric (38,4)
,crr_code_supplier  varchar (50) 
,crr_name_supplier  varchar (100) 
,shelfno_code_to  varchar (50) 
,shelfno_name_to  varchar (100) 
,loca_code_shelfno_to  varchar (50) 
,loca_name_shelfno_to  varchar (100) 
,prjno_code  varchar (50) 
,prjno_name  varchar (100) 
,crr_code  varchar (50) 
,person_code_chrg_supplier  varchar (50) 
,person_name_chrg_supplier  varchar (100) 
,person_code_chrg  varchar (50) 
,person_name_chrg  varchar (100) 
,purord_itm_code_client  varchar (50) 
,purord_autoinst_p  numeric (3,0)
,purord_autoact_p  numeric (3,0)
,unit_code  varchar (50) 
,unit_name  varchar (100) 
,unit_name_outbox  varchar (100) 
,unit_code_outbox  varchar (50) 
,loca_name_payment  varchar (100) 
,classlist_code  varchar (50) 
,classlist_name  varchar (100) 
,boxe_name  varchar (100) 
,boxe_code  varchar (50) 
,unit_name_box  varchar (100) 
,person_name_chrg_payment  varchar (100) 
,person_code_chrg_payment  varchar (50) 
,prjno_code_chil  varchar (50) 
,loca_code_payment  varchar (50) 
,unit_code_box  varchar (50) 
,purord_toduedate   timestamp(6) 
,purord_expiredate   date 
,crr_name  varchar (100) 
,loca_code_opeitm  varchar (50) 
,unit_code_case_shp  varchar (50) 
,shelfno_code_fm  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,crr_code_payment  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,opeitm_priority  numeric (3,0)
,loca_code_shelfno_fm_opeitm  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,unit_name_case_prdpur  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,crr_name_payment  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_opeitm  varchar (100) 
,prjno_name_chil  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,unit_name_case_shp  varchar (100) 
,shelfno_name_fm  varchar (100) 
,purord_gno  varchar (40) 
,purord_contract_price  varchar (1) 
,purord_crr_id  numeric (22,0)
,purord_shelfno_id_fm  numeric (22,0)
,crr_pricedecimal  numeric (22,0)
,purord_remark  varchar (4000) 
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,boxe_unit_id_outbox  numeric (38,0)
,id  numeric (38,0)
,purord_id  numeric (38,0)
,purord_chrg_id  numeric (38,0)
,purord_supplier_id  numeric (22,0)
,purord_updated_at   timestamp(6) 
,purord_created_at   timestamp(6) 
,purord_update_ip  varchar (40) 
,purord_shelfno_id_to  numeric (38,0)
,purord_prjno_id  numeric (38,0)
,purord_person_id_upd  numeric (38,0)
,purord_opeitm_id  numeric (38,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,payment_crr_id_payment  numeric (22,0)
,opeitm_loca_id_opeitm  numeric (22,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,person_sect_id_chrg_supplier  numeric (22,0)
,chrg_person_id_chrg_payment  numeric (38,0)
,chrg_person_id_chrg_supplier  numeric (38,0)
,payment_loca_id_payment  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,supplier_crr_id_supplier  numeric (22,0)
,supplier_chrg_id_supplier  numeric (22,0)
,person_sect_id_chrg  numeric (22,0)
,supplier_loca_id_supplier  numeric (22,0)
,supplier_payment_id  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,payment_chrg_id_payment  numeric (22,0)
,itm_unit_id  numeric (22,0)
,opeitm_boxe_id  numeric (22,0)
,person_sect_id_chrg_payment  numeric (22,0)
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
 CREATE INDEX sio_r_purords_uk1 
  ON sio.sio_r_purords(id,sio_id); 

 drop sequence  if exists sio.sio_r_purords_seq ;
 create sequence sio.sio_r_purords_seq ;
  drop view if  exists r_prdschs cascade ; 
 create or replace view r_prdschs as select  
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
prdsch.id id,
  prjno.prjno_name  prjno_name ,
  chrg.person_sect_id_chrg  person_sect_id_chrg ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
prdsch.id  prdsch_id,
prdsch.remark  prdsch_remark,
prdsch.expiredate  prdsch_expiredate,
prdsch.update_ip  prdsch_update_ip,
prdsch.created_at  prdsch_created_at,
prdsch.updated_at  prdsch_updated_at,
prdsch.persons_id_upd   prdsch_person_id_upd,
prdsch.sno  prdsch_sno,
prdsch.duedate  prdsch_duedate,
prdsch.toduedate  prdsch_toduedate,
prdsch.isudate  prdsch_isudate,
prdsch.opeitms_id   prdsch_opeitm_id,
  prjno.prjno_code  prjno_code ,
prdsch.prjnos_id   prdsch_prjno_id,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  opeitm.unit_code_box  unit_code_box ,
  opeitm.unit_name_box  unit_name_box ,
  opeitm.boxe_unit_id_outbox  boxe_unit_id_outbox ,
  opeitm.unit_code_outbox  unit_code_outbox ,
  opeitm.unit_name_outbox  unit_name_outbox ,
  opeitm.boxe_code  boxe_code ,
  opeitm.boxe_name  boxe_name ,
  opeitm.opeitm_boxe_id  opeitm_boxe_id ,
prdsch.chrgs_id   prdsch_chrg_id,
prdsch.starttime  prdsch_starttime,
  prjno.prjno_code_chil  prjno_code_chil ,
  opeitm.itm_classlist_id  itm_classlist_id ,
  shelfno_to.shelfno_code  shelfno_code_to ,
  shelfno_to.shelfno_name  shelfno_name_to ,
  shelfno_to.loca_code_shelfno  loca_code_shelfno_to ,
  shelfno_to.loca_name_shelfno  loca_name_shelfno_to ,
  shelfno_to.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_to ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
  workplace.workplace_loca_id_workplace  workplace_loca_id_workplace ,
  workplace.loca_code_workplace  loca_code_workplace ,
  workplace.loca_name_workplace  loca_name_workplace ,
prdsch.gno  prdsch_gno,
prdsch.shelfnos_id_to   prdsch_shelfno_id_to,
  workplace.workplace_chrg_id_workplace  workplace_chrg_id_workplace ,
  workplace.person_code_chrg_workplace  person_code_chrg_workplace ,
  workplace.person_name_chrg_workplace  person_name_chrg_workplace ,
  workplace.person_sect_id_chrg_workplace  person_sect_id_chrg_workplace ,
  workplace.chrg_person_id_chrg_workplace  chrg_person_id_chrg_workplace ,
prdsch.workplaces_id   prdsch_workplace_id,
prdsch.qty_sch  prdsch_qty_sch,
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
prdsch.shelfnos_id_fm   prdsch_shelfno_id_fm
 from prdschs   prdsch,
  r_persons  person_upd ,  r_opeitms  opeitm ,  r_prjnos  prjno ,  r_chrgs  chrg ,  r_shelfnos  shelfno_to ,  r_workplaces  workplace ,  r_shelfnos  shelfno_fm 
  where       prdsch.persons_id_upd = person_upd.id      and prdsch.opeitms_id = opeitm.id      and prdsch.prjnos_id = prjno.id      and prdsch.chrgs_id = chrg.id      and prdsch.shelfnos_id_to = shelfno_to.id      and prdsch.workplaces_id = workplace.id      and prdsch.shelfnos_id_fm = shelfno_fm.id     ;
 DROP TABLE IF EXISTS sio.sio_r_prdschs;
 CREATE TABLE sio.sio_r_prdschs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_prdschs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,prdsch_sno  varchar (40) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,prdsch_duedate   timestamp(6) 
,opeitm_processseq  numeric (3,0)
,opeitm_priority  numeric (3,0)
,loca_code_workplace  varchar (50) 
,loca_name_workplace  varchar (100) 
,unit_code  varchar (50) 
,boxe_code  varchar (50) 
,classlist_code  varchar (50) 
,loca_code_shelfno_to  varchar (50) 
,loca_name_shelfno_to  varchar (100) 
,shelfno_code_to  varchar (50) 
,shelfno_name_to  varchar (100) 
,prdsch_toduedate   timestamp(6) 
,person_code_chrg  varchar (50) 
,person_name_chrg  varchar (100) 
,prjno_code  varchar (50) 
,prjno_name  varchar (100) 
,unit_name  varchar (100) 
,classlist_name  varchar (100) 
,prdsch_expiredate   date 
,boxe_name  varchar (100) 
,unit_code_box  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,unit_code_case_shp  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,loca_code_opeitm  varchar (50) 
,unit_code_outbox  varchar (50) 
,person_code_chrg_workplace  varchar (50) 
,shelfno_code_fm  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,unit_name_outbox  varchar (100) 
,shelfno_name_fm  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,prjno_name_chil  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,person_name_chrg_workplace  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,unit_name_case_shp  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,loca_name_opeitm  varchar (100) 
,unit_name_box  varchar (100) 
,prdsch_isudate   timestamp(6) 
,prdsch_starttime   timestamp(6) 
,prdsch_qty_sch  numeric (22,6)
,prdsch_shelfno_id_fm  numeric (22,0)
,prjno_code_chil  varchar (50) 
,prdsch_gno  varchar (40) 
,prdsch_remark  varchar (4000) 
,itm_unit_id  numeric (22,0)
,prdsch_shelfno_id_to  numeric (38,0)
,workplace_chrg_id_workplace  numeric (22,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,person_sect_id_chrg_workplace  numeric (22,0)
,chrg_person_id_chrg_workplace  numeric (38,0)
,prdsch_workplace_id  numeric (22,0)
,prdsch_chrg_id  numeric (38,0)
,opeitm_boxe_id  numeric (22,0)
,opeitm_loca_id_opeitm  numeric (22,0)
,boxe_unit_id_outbox  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,prdsch_prjno_id  numeric (38,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,prdsch_opeitm_id  numeric (38,0)
,prdsch_person_id_upd  numeric (38,0)
,prdsch_updated_at   timestamp(6) 
,prdsch_created_at   timestamp(6) 
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,prdsch_update_ip  varchar (40) 
,prdsch_id  numeric (38,0)
,person_sect_id_chrg  numeric (22,0)
,id  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,workplace_loca_id_workplace  numeric (22,0)
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
 CREATE INDEX sio_r_prdschs_uk1 
  ON sio.sio_r_prdschs(id,sio_id); 

 drop sequence  if exists sio.sio_r_prdschs_seq ;
 create sequence sio.sio_r_prdschs_seq ;
  drop view if  exists r_nditms cascade ; 
 create or replace view r_nditms as select  
nditm.contents  nditm_contents,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_processseq  opeitm_processseq ,
  opeitm.opeitm_packqty  opeitm_packqty ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
nditm.parenum  nditm_parenum,
nditm.created_at  nditm_created_at,
nditm.opeitms_id   nditm_opeitm_id,
nditm.consumunitqty  nditm_consumunitqty,
nditm.persons_id_upd   nditm_person_id_upd,
nditm.updated_at  nditm_updated_at,
nditm.id  nditm_id,
nditm.remark  nditm_remark,
nditm.expiredate  nditm_expiredate,
nditm.update_ip  nditm_update_ip,
  itm_nditm.itm_code  itm_code_nditm ,
  itm_nditm.itm_design  itm_design_nditm ,
  itm_nditm.itm_deth  itm_deth_nditm ,
  itm_nditm.itm_length  itm_length_nditm ,
  itm_nditm.itm_material  itm_material_nditm ,
  itm_nditm.itm_model  itm_model_nditm ,
  itm_nditm.itm_name  itm_name_nditm ,
  itm_nditm.itm_std  itm_std_nditm ,
  itm_nditm.itm_weight  itm_weight_nditm ,
nditm.itms_id_nditm   nditm_itm_id_nditm,
  itm_nditm.unit_code  unit_code_nditm ,
  itm_nditm.unit_name  unit_name_nditm ,
nditm.chilnum  nditm_chilnum,
  opeitm.opeitm_duration  opeitm_duration ,
  itm_nditm.itm_wide  itm_wide_nditm ,
nditm.id id,
  itm_nditm.itm_unit_id  itm_unit_id_nditm ,
  opeitm.opeitm_operation  opeitm_operation ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  opeitm.opeitm_prdpur  opeitm_prdpur ,
  opeitm.opeitm_chkord_proc  opeitm_chkord_proc ,
  opeitm.opeitm_esttosch  opeitm_esttosch ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  opeitm.opeitm_mold  opeitm_mold ,
  crr.crr_code  crr_code ,
  crr.crr_name  crr_name ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  opeitm.boxe_unit_id_outbox  boxe_unit_id_outbox ,
  opeitm.boxe_code  boxe_code ,
  opeitm.boxe_name  boxe_name ,
  opeitm.opeitm_boxe_id  opeitm_boxe_id ,
nditm.processseq_nditm  nditm_processseq_nditm,
  opeitm.opeitm_prjalloc_flg  opeitm_prjalloc_flg ,
nditm.byproduct  nditm_byproduct,
nditm.consumminqty  nditm_consumminqty,
nditm.consumchgoverqty  nditm_consumchgoverqty,
  opeitm.itm_classlist_id  itm_classlist_id ,
  itm_nditm.itm_classlist_id  itm_classlist_id_nditm ,
  itm_nditm.classlist_name  classlist_name_nditm ,
  itm_nditm.classlist_code  classlist_code_nditm ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
nditm.price  nditm_price,
nditm.crrs_id   nditm_crr_id,
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
nditm.shelfnos_id_fm   nditm_shelfno_id_fm
 from nditms   nditm,
  r_opeitms  opeitm ,  r_persons  person_upd ,  r_itms  itm_nditm ,  r_crrs  crr ,  r_shelfnos  shelfno_fm 
  where       nditm.opeitms_id = opeitm.id      and nditm.persons_id_upd = person_upd.id      and nditm.itms_id_nditm = itm_nditm.id      and nditm.crrs_id = crr.id      and nditm.shelfnos_id_fm = shelfno_fm.id     ;
 DROP TABLE IF EXISTS sio.sio_r_nditms;
 CREATE TABLE sio.sio_r_nditms (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_nditms_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,opeitm_processseq  numeric (3,0)
,opeitm_priority  numeric (3,0)
,itm_code_nditm  varchar (50) 
,itm_name_nditm  varchar (100) 
,nditm_processseq_nditm  numeric (38,0)
,nditm_parenum  numeric (38,0)
,nditm_chilnum  numeric (38,0)
,opeitm_packqty  numeric (38,0)
,nditm_consumunitqty  numeric (38,0)
,classlist_code_nditm  varchar (50) 
,crr_name  varchar (100) 
,boxe_code  varchar (50) 
,classlist_name  varchar (100) 
,classlist_code  varchar (50) 
,boxe_name  varchar (100) 
,crr_code  varchar (50) 
,classlist_name_nditm  varchar (100) 
,nditm_expiredate   date 
,nditm_byproduct  varchar (1) 
,nditm_price  numeric (38,4)
,nditm_consumchgoverqty  numeric (22,6)
,nditm_consumminqty  numeric (22,6)
,unit_code_case_prdpur  varchar (50) 
,loca_code_opeitm  varchar (50) 
,opeitm_prdpur  varchar (20) 
,itm_material_nditm  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,unit_code_case_shp  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,shelfno_code_fm  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,itm_std_nditm  varchar (50) 
,unit_code_nditm  varchar (50) 
,itm_model_nditm  varchar (50) 
,itm_design_nditm  varchar (50) 
,itm_weight_nditm  numeric (22,0)
,itm_length_nditm  numeric (22,0)
,itm_wide_nditm  numeric (22,0)
,itm_deth_nditm  numeric (22,0)
,unit_name_nditm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,unit_name_case_shp  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,shelfno_name_fm  varchar (100) 
,loca_name_opeitm  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,nditm_shelfno_id_fm  numeric (22,0)
,nditm_contents  varchar (4000) 
,nditm_remark  varchar (4000) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,nditm_opeitm_id  numeric (38,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,nditm_crr_id  numeric (22,0)
,opeitm_loca_id_opeitm  numeric (22,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,itm_unit_id_nditm  numeric (22,0)
,opeitm_boxe_id  numeric (22,0)
,itm_classlist_id  numeric (38,0)
,itm_classlist_id_nditm  numeric (38,0)
,boxe_unit_id_outbox  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,itm_unit_id  numeric (22,0)
,opeitm_prjalloc_flg  numeric (22,0)
,nditm_itm_id_nditm  numeric (38,0)
,nditm_update_ip  varchar (40) 
,opeitm_operation  varchar (20) 
,nditm_id  numeric (38,0)
,opeitm_chkord_proc  numeric (3,0)
,nditm_updated_at   timestamp(6) 
,nditm_person_id_upd  numeric (38,0)
,opeitm_esttosch  numeric (22,0)
,nditm_created_at   timestamp(6) 
,opeitm_mold  varchar (1) 
,id  numeric (38,0)
,opeitm_duration  numeric (38,2)
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
 CREATE INDEX sio_r_nditms_uk1 
  ON sio.sio_r_nditms(id,sio_id); 

 drop sequence  if exists sio.sio_r_nditms_seq ;
 create sequence sio.sio_r_nditms_seq ;
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
 ALTER TABLE prdacts ADD CONSTRAINT prdact_crrs_id FOREIGN KEY (crrs_id)
																		 REFERENCES crrs (id);
 ALTER TABLE puracts ADD CONSTRAINT puract_crrs_id FOREIGN KEY (crrs_id)
																		 REFERENCES crrs (id);
 ALTER TABLE purords ADD CONSTRAINT purord_crrs_id FOREIGN KEY (crrs_id)
																		 REFERENCES crrs (id);
