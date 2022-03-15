
 alter table  puracts  ADD COLUMN payments_id numeric(38,0)  DEFAULT 0  not null;

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
  payment.loca_code_payment  loca_code_payment ,
  payment.loca_name_payment  loca_name_payment ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
puract.cno  puract_cno,
  payment.payment_loca_id_payment  payment_loca_id_payment ,
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
  payment.payment_chrg_id_payment  payment_chrg_id_payment ,
  payment.person_code_chrg_payment  person_code_chrg_payment ,
  payment.person_name_chrg_payment  person_name_chrg_payment ,
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
  payment.chrg_person_id_chrg_payment  chrg_person_id_chrg_payment ,
  supplier.person_sect_id_chrg_supplier  person_sect_id_chrg_supplier ,
  payment.person_sect_id_chrg_payment  person_sect_id_chrg_payment ,
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
  payment.crr_code_payment  crr_code_payment ,
  payment.crr_name_payment  crr_name_payment ,
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
puract.cartonno  puract_cartonno,
  supplier.loca_code_payment_supplier  loca_code_payment_supplier ,
  supplier.loca_name_payment_supplier  loca_name_payment_supplier ,
  supplier.payment_loca_id_payment_supplier  payment_loca_id_payment_supplier ,
  supplier.payment_chrg_id_payment_supplier  payment_chrg_id_payment_supplier ,
  supplier.person_code_chrg_payment_supplier  person_code_chrg_payment_supplier ,
  supplier.person_name_chrg_payment_supplier  person_name_chrg_payment_supplier ,
  supplier.crr_code_payment_supplier  crr_code_payment_supplier ,
  supplier.crr_name_payment_supplier  crr_name_payment_supplier ,
puract.payments_id   puract_payment_id
 from puracts   puract,
  r_opeitms  opeitm ,  r_persons  person_upd ,  r_chrgs  chrg ,  r_prjnos  prjno ,  r_suppliers  supplier ,  r_shelfnos  shelfno_to ,  r_crrs  crr ,  r_shelfnos  shelfno_fm ,  r_payments  payment 
  where       puract.opeitms_id = opeitm.id      and puract.persons_id_upd = person_upd.id      and puract.chrgs_id = chrg.id      and puract.prjnos_id = prjno.id      and puract.suppliers_id = supplier.id      and puract.shelfnos_id_to = shelfno_to.id      and puract.crrs_id = crr.id      and puract.shelfnos_id_fm = shelfno_fm.id      and puract.payments_id = payment.id     ;
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
,unit_code_box  varchar (50) 
,boxe_name  varchar (100) 
,prjno_code  varchar (50) 
,loca_code_payment  varchar (50) 
,loca_name_payment  varchar (100) 
,classlist_code  varchar (50) 
,classlist_name  varchar (100) 
,boxe_code  varchar (50) 
,prjno_name  varchar (100) 
,prjno_code_chil  varchar (50) 
,unit_name_box  varchar (100) 
,puract_lotno  varchar (50) 
,puract_cno_purinst  varchar (50) 
,puract_expiredate   date 
,crr_name  varchar (100) 
,puract_cno_purdlv  varchar (50) 
,loca_code_shelfno_to  varchar (50) 
,crr_code_payment_supplier  varchar (50) 
,opeitm_priority  numeric (3,0)
,person_code_chrg_payment_supplier  varchar (50) 
,loca_code_payment_supplier  varchar (50) 
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
,shelfno_code_to  varchar (50) 
,unit_name_case_shp  varchar (100) 
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
,unit_name_case_prdpur  varchar (100) 
,loca_name_payment_supplier  varchar (100) 
,person_name_chrg_payment_supplier  varchar (100) 
,crr_name_payment_supplier  varchar (100) 
,puract_cno  varchar (40) 
,puract_sno  varchar (40) 
,puract_sno_purinst  varchar (50) 
,puract_sno_purdlv  varchar (50) 
,puract_packno  varchar (10) 
,puract_crr_id  numeric (22,0)
,puract_shelfno_id_fm  numeric (22,0)
,crr_pricedecimal  numeric (22,0)
,puract_cartonno  varchar (50) 
,puract_payment_id  numeric (38,0)
,puract_invoiceno  varchar (50) 
,puract_amt  numeric (18,4)
,puract_remark  varchar (4000) 
,puract_contents  varchar (4000) 
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,puract_updated_at   timestamp(6) 
,chrg_person_id_chrg  numeric (38,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,boxe_unit_id_outbox  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,puract_created_at   timestamp(6) 
,chrg_person_id_chrg_supplier  numeric (38,0)
,chrg_person_id_chrg_payment  numeric (38,0)
,payment_loca_id_payment_supplier  numeric (38,0)
,puract_update_ip  varchar (40) 
,puract_supplier_id  numeric (22,0)
,puract_prjno_id  numeric (38,0)
,puract_shelfno_id_to  numeric (38,0)
,payment_chrg_id_payment_supplier  numeric (22,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,puract_opeitm_id  numeric (38,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,puract_chrg_id  numeric (38,0)
,puract_person_id_upd  numeric (38,0)
,payment_loca_id_payment  numeric (38,0)
,person_sect_id_chrg  numeric (22,0)
,id  numeric (38,0)
,itm_unit_id  numeric (22,0)
,opeitm_itm_id  numeric (38,0)
,puract_id  numeric (38,0)
,supplier_crr_id_supplier  numeric (22,0)
,supplier_chrg_id_supplier  numeric (22,0)
,supplier_loca_id_supplier  numeric (22,0)
,payment_chrg_id_payment  numeric (22,0)
,opeitm_boxe_id  numeric (22,0)
,itm_classlist_id  numeric (38,0)
,person_sect_id_chrg_supplier  numeric (22,0)
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
 CREATE INDEX sio_r_puracts_uk1 
  ON sio.sio_r_puracts(id,sio_id); 

 drop sequence  if exists sio.sio_r_puracts_seq ;
 create sequence sio.sio_r_puracts_seq ;
 ALTER TABLE puracts ADD CONSTRAINT puract_payments_id FOREIGN KEY (payments_id)
																		 REFERENCES payments (id);
