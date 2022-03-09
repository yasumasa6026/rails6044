
  drop view if  exists r_suppliers cascade ; 
 create or replace view r_suppliers as select  
supplier.id id,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  payment.loca_code_payment  loca_code_payment ,
  payment.loca_name_payment  loca_name_payment ,
  payment.payment_loca_id_payment  payment_loca_id_payment ,
  payment.payment_chrg_id_payment  payment_chrg_id_payment ,
  payment.person_code_chrg_payment  person_code_chrg_payment ,
  payment.person_name_chrg_payment  person_name_chrg_payment ,
supplier.amtdecimal  supplier_amtdecimal,
supplier.remark  supplier_remark,
supplier.created_at  supplier_created_at,
supplier.update_ip  supplier_update_ip,
supplier.custtype  supplier_custtype,
supplier.expiredate  supplier_expiredate,
supplier.updated_at  supplier_updated_at,
supplier.id  supplier_id,
supplier.persons_id_upd   supplier_person_id_upd,
supplier.contents  supplier_contents,
supplier.contract_price  supplier_contract_price,
supplier.rule_price  supplier_rule_price,
supplier.amtround  supplier_amtround,
supplier.payments_id   supplier_payment_id,
supplier.personname  supplier_personname,
supplier.locas_id_supplier   supplier_loca_id_supplier,
supplier.chrgs_id_supplier   supplier_chrg_id_supplier,
supplier.crrs_id_supplier   supplier_crr_id_supplier,
  loca_supplier.loca_code  loca_code_supplier ,
  loca_supplier.loca_name  loca_name_supplier ,
  chrg_supplier.person_code_chrg  person_code_chrg_supplier ,
  chrg_supplier.person_name_chrg  person_name_chrg_supplier ,
  crr_supplier.crr_name  crr_name_supplier ,
  crr_supplier.crr_code  crr_code_supplier ,
  chrg_supplier.chrg_person_id_chrg  chrg_person_id_chrg_supplier ,
  payment.chrg_person_id_chrg_payment  chrg_person_id_chrg_payment ,
  chrg_supplier.person_sect_id_chrg  person_sect_id_chrg_supplier ,
  payment.person_sect_id_chrg_payment  person_sect_id_chrg_payment ,
  payment.payment_crr_id_payment  payment_crr_id_payment ,
  payment.crr_code_payment  crr_code_payment ,
  payment.crr_name_payment  crr_name_payment 
 from suppliers   supplier,
  r_persons  person_upd ,  r_payments  payment ,  r_locas  loca_supplier ,  r_chrgs  chrg_supplier ,  r_crrs  crr_supplier 
  where       supplier.persons_id_upd = person_upd.id      and supplier.payments_id = payment.id      and supplier.locas_id_supplier = loca_supplier.id      and supplier.chrgs_id_supplier = chrg_supplier.id      and supplier.crrs_id_supplier = crr_supplier.id     ;
 DROP TABLE IF EXISTS sio.sio_r_suppliers;
 CREATE TABLE sio.sio_r_suppliers (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_suppliers_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,loca_code_supplier  varchar (50) 
,loca_name_supplier  varchar (100) 
,person_code_chrg_supplier  varchar (50) 
,person_name_chrg_supplier  varchar (100) 
,crr_code_supplier  varchar (50) 
,crr_name_supplier  varchar (100) 
,loca_code_payment  varchar (50) 
,loca_name_payment  varchar (100) 
,person_code_chrg_payment  varchar (50) 
,person_name_chrg_payment  varchar (100) 
,supplier_rule_price  varchar (1) 
,supplier_amtdecimal  numeric (38,0)
,supplier_contract_price  varchar (1) 
,supplier_custtype  varchar (1) 
,supplier_expiredate   date 
,supplier_personname  varchar (30) 
,supplier_amtround  varchar (2) 
,crr_code_payment  varchar (50) 
,crr_name_payment  varchar (100) 
,supplier_contents  varchar (4000) 
,supplier_remark  varchar (4000) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,supplier_updated_at   timestamp(6) 
,supplier_loca_id_supplier  numeric (22,0)
,supplier_chrg_id_supplier  numeric (22,0)
,supplier_crr_id_supplier  numeric (22,0)
,supplier_update_ip  varchar (40) 
,supplier_created_at   timestamp(6) 
,id  numeric (38,0)
,supplier_id  numeric (38,0)
,supplier_payment_id  numeric (38,0)
,payment_crr_id_payment  numeric (22,0)
,supplier_person_id_upd  numeric (38,0)
,chrg_person_id_chrg_payment  numeric (38,0)
,person_sect_id_chrg_supplier  numeric (22,0)
,person_sect_id_chrg_payment  numeric (22,0)
,payment_chrg_id_payment  numeric (22,0)
,payment_loca_id_payment  numeric (38,0)
,chrg_person_id_chrg_supplier  numeric (38,0)
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
 CREATE INDEX sio_r_suppliers_uk1 
  ON sio.sio_r_suppliers(id,sio_id); 

 drop sequence  if exists sio.sio_r_suppliers_seq ;
 create sequence sio.sio_r_suppliers_seq ;
  drop view if  exists r_supplierwhs cascade ; 
 create or replace view r_supplierwhs as select  
  itm.itm_name  itm_name ,
  itm.itm_code  itm_code ,
  itm.unit_name  unit_name ,
  itm.unit_code  unit_code ,
supplierwh.id id,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  supplier.loca_code_payment  loca_code_payment ,
  supplier.loca_name_payment  loca_name_payment ,
  itm.classlist_code  classlist_code ,
  itm.classlist_name  classlist_name ,
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
  itm.itm_classlist_id  itm_classlist_id ,
  supplier.crr_code_payment  crr_code_payment ,
  supplier.crr_name_payment  crr_name_payment ,
supplierwh.suppliers_id   supplierwh_supplier_id,
supplierwh.qty_sch  supplierwh_qty_sch,
supplierwh.remark  supplierwh_remark,
supplierwh.expiredate  supplierwh_expiredate,
supplierwh.update_ip  supplierwh_update_ip,
supplierwh.created_at  supplierwh_created_at,
supplierwh.updated_at  supplierwh_updated_at,
supplierwh.persons_id_upd   supplierwh_person_id_upd,
supplierwh.itms_id   supplierwh_itm_id,
supplierwh.qty  supplierwh_qty,
supplierwh.depdate  supplierwh_depdate,
supplierwh.processseq  supplierwh_processseq,
supplierwh.lotno  supplierwh_lotno,
supplierwh.qty_stk  supplierwh_qty_stk,
supplierwh.id  supplierwh_id
 from supplierwhs   supplierwh,
  r_suppliers  supplier ,  r_persons  person_upd ,  r_itms  itm 
  where       supplierwh.suppliers_id = supplier.id      and supplierwh.persons_id_upd = person_upd.id      and supplierwh.itms_id = itm.id     ;
 DROP TABLE IF EXISTS sio.sio_r_supplierwhs;
 CREATE TABLE sio.sio_r_supplierwhs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_supplierwhs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,unit_code  varchar (50) 
,itm_code  varchar (50) 
,classlist_code  varchar (50) 
,itm_name  varchar (100) 
,classlist_name  varchar (100) 
,unit_name  varchar (100) 
,person_code_chrg_payment  varchar (50) 
,person_code_chrg_supplier  varchar (50) 
,loca_code_supplier  varchar (50) 
,crr_code_payment  varchar (50) 
,crr_code_supplier  varchar (50) 
,loca_code_payment  varchar (50) 
,crr_name_payment  varchar (100) 
,loca_name_payment  varchar (100) 
,person_name_chrg_payment  varchar (100) 
,loca_name_supplier  varchar (100) 
,person_name_chrg_supplier  varchar (100) 
,crr_name_supplier  varchar (100) 
,supplierwh_lotno  varchar (50) 
,supplierwh_expiredate   date 
,supplierwh_update_ip  varchar (40) 
,supplierwh_created_at   timestamp(6) 
,supplierwh_updated_at   timestamp(6) 
,supplierwh_itm_id  numeric (38,0)
,supplierwh_qty  numeric (22,6)
,supplierwh_depdate   timestamp(6) 
,supplierwh_processseq  numeric (38,0)
,supplierwh_qty_stk  numeric (22,6)
,supplierwh_id  numeric (38,0)
,id  numeric (38,0)
,supplierwh_supplier_id  numeric (22,0)
,supplierwh_qty_sch  numeric (22,6)
,supplierwh_remark  varchar (4000) 
,person_name_upd  varchar (100) 
,person_code_upd  varchar (50) 
,supplier_crr_id_supplier  numeric (22,0)
,itm_classlist_id  numeric (38,0)
,supplierwh_person_id_upd  numeric (22,0)
,supplier_payment_id  numeric (38,0)
,supplier_loca_id_supplier  numeric (22,0)
,supplier_chrg_id_supplier  numeric (22,0)
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
 CREATE INDEX sio_r_supplierwhs_uk1 
  ON sio.sio_r_supplierwhs(id,sio_id); 

 drop sequence  if exists sio.sio_r_supplierwhs_seq ;
 create sequence sio.sio_r_supplierwhs_seq ;
