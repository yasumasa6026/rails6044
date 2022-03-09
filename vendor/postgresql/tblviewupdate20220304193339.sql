
 alter table asstwhs DROP COLUMN acceptance_proc CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'acceptance_proc'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　acceptance_procが削除　2022-03-04 19:33:37 +0900' 
 ---- where  pobject_code_sfd = 'acceptance_proc'
 alter table asstwhs  ADD COLUMN acceptance_proc varchar(30);

 alter table crrs ALTER COLUMN remark  TYPE varchar(4000) ;

  drop view if  exists r_asstwhs cascade ; 
 create or replace view r_asstwhs as select  
asstwh.id id,
  loca_asstwh.loca_code  loca_code_asstwh ,
  loca_asstwh.loca_name  loca_name_asstwh ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
asstwh.id  asstwh_id,
asstwh.remark  asstwh_remark,
asstwh.expiredate  asstwh_expiredate,
asstwh.update_ip  asstwh_update_ip,
asstwh.created_at  asstwh_created_at,
asstwh.updated_at  asstwh_updated_at,
asstwh.persons_id_upd   asstwh_person_id_upd,
asstwh.locas_id_asstwh   asstwh_loca_id_asstwh,
  chrg_asstwh.person_code_chrg  person_code_chrg_asstwh ,
  chrg_asstwh.person_name_chrg  person_name_chrg_asstwh ,
  chrg_asstwh.person_sect_id_chrg  person_sect_id_chrg_asstwh ,
asstwh.chrgs_id_asstwh   asstwh_chrg_id_asstwh,
asstwh.contents  asstwh_contents,
asstwh.autocreate_inst  asstwh_autocreate_inst,
asstwh.stktaking_proc  asstwh_stktaking_proc,
asstwh.acceptance_proc  asstwh_acceptance_proc,
  chrg_asstwh.chrg_person_id_chrg  chrg_person_id_chrg_asstwh 
 from asstwhs   asstwh,
  r_persons  person_upd ,  r_locas  loca_asstwh ,  r_chrgs  chrg_asstwh 
  where       asstwh.persons_id_upd = person_upd.id      and asstwh.locas_id_asstwh = loca_asstwh.id      and asstwh.chrgs_id_asstwh = chrg_asstwh.id     ;
 DROP TABLE IF EXISTS sio.sio_r_asstwhs;
 CREATE TABLE sio.sio_r_asstwhs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_asstwhs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,person_code_chrg_asstwh  varchar (50) 
,loca_code_asstwh  varchar (50) 
,asstwh_autocreate_inst  varchar (1) 
,person_name_chrg_asstwh  varchar (100) 
,loca_name_asstwh  varchar (100) 
,asstwh_stktaking_proc  varchar (1) 
,asstwh_acceptance_proc  varchar (30) 
,asstwh_contents  varchar (4000) 
,asstwh_remark  varchar (4000) 
,asstwh_expiredate   date 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,chrg_person_id_chrg_asstwh  numeric (38,0)
,person_sect_id_chrg_asstwh  numeric (22,0)
,asstwh_person_id_upd  numeric (22,0)
,asstwh_id  numeric (22,0)
,asstwh_update_ip  varchar (40) 
,asstwh_created_at   timestamp(6) 
,asstwh_updated_at   timestamp(6) 
,id  numeric (22,0)
,asstwh_loca_id_asstwh  numeric (22,0)
,asstwh_chrg_id_asstwh  numeric (22,0)
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
 CREATE INDEX sio_r_asstwhs_uk1 
  ON sio.sio_r_asstwhs(id,sio_id); 

 drop sequence  if exists sio.sio_r_asstwhs_seq ;
 create sequence sio.sio_r_asstwhs_seq ;
  drop view if  exists r_crrs cascade ; 
 create or replace view r_crrs as select  
crr.id id,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
crr.code  crr_code,
crr.name  crr_name,
crr.pricedecimal  crr_pricedecimal,
crr.amtdecimal  crr_amtdecimal,
crr.contents  crr_contents,
crr.id  crr_id,
crr.remark  crr_remark,
crr.expiredate  crr_expiredate,
crr.update_ip  crr_update_ip,
crr.created_at  crr_created_at,
crr.updated_at  crr_updated_at,
crr.persons_id_upd   crr_person_id_upd
 from crrs   crr,
  r_persons  person_upd 
  where       crr.persons_id_upd = person_upd.id     ;
 DROP TABLE IF EXISTS sio.sio_r_crrs;
 CREATE TABLE sio.sio_r_crrs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_crrs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,crr_code  varchar (50) 
,crr_name  varchar (100) 
,crr_pricedecimal  numeric (22,0)
,crr_amtdecimal  numeric (22,0)
,crr_expiredate   date 
,crr_remark  varchar (4000) 
,crr_contents  varchar (4000) 
,crr_created_at   timestamp(6) 
,crr_updated_at   timestamp(6) 
,crr_update_ip  varchar (40) 
,crr_person_id_upd  numeric (22,0)
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,crr_id  numeric (22,0)
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
 CREATE INDEX sio_r_crrs_uk1 
  ON sio.sio_r_crrs(id,sio_id); 

 drop sequence  if exists sio.sio_r_crrs_seq ;
 create sequence sio.sio_r_crrs_seq ;
  drop view if  exists r_payments cascade ; 
 create or replace view r_payments as select  
payment.id id,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
payment.id  payment_id,
payment.remark  payment_remark,
payment.expiredate  payment_expiredate,
payment.update_ip  payment_update_ip,
payment.created_at  payment_created_at,
payment.updated_at  payment_updated_at,
payment.persons_id_upd   payment_person_id_upd,
payment.contents  payment_contents,
  loca_payment.loca_code  loca_code_payment ,
  loca_payment.loca_name  loca_name_payment ,
payment.personname  payment_personname,
payment.locas_id_payment   payment_loca_id_payment,
payment.chrgs_id_payment   payment_chrg_id_payment,
  chrg_payment.person_code_chrg  person_code_chrg_payment ,
  chrg_payment.person_name_chrg  person_name_chrg_payment ,
  chrg_payment.chrg_person_id_chrg  chrg_person_id_chrg_payment ,
  chrg_payment.person_sect_id_chrg  person_sect_id_chrg_payment ,
payment.crrs_id_payment   payment_crr_id_payment,
  crr_payment.crr_code  crr_code_payment ,
  crr_payment.crr_name  crr_name_payment 
 from payments   payment,
  r_persons  person_upd ,  r_locas  loca_payment ,  r_chrgs  chrg_payment ,  r_crrs  crr_payment 
  where       payment.persons_id_upd = person_upd.id      and payment.locas_id_payment = loca_payment.id      and payment.chrgs_id_payment = chrg_payment.id      and payment.crrs_id_payment = crr_payment.id     ;
 DROP TABLE IF EXISTS sio.sio_r_payments;
 CREATE TABLE sio.sio_r_payments (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_payments_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,loca_code_payment  varchar (50) 
,loca_name_payment  varchar (100) 
,person_code_chrg_payment  varchar (50) 
,person_name_chrg_payment  varchar (100) 
,payment_personname  varchar (30) 
,payment_expiredate   date 
,crr_code_payment  varchar (50) 
,crr_name_payment  varchar (100) 
,payment_crr_id_payment  numeric (22,0)
,payment_remark  varchar (4000) 
,payment_contents  varchar (4000) 
,person_name_upd  varchar (100) 
,person_code_upd  varchar (50) 
,payment_chrg_id_payment  numeric (22,0)
,payment_id  numeric (38,0)
,id  numeric (38,0)
,payment_person_id_upd  numeric (38,0)
,payment_created_at   timestamp(6) 
,payment_update_ip  varchar (40) 
,payment_loca_id_payment  numeric (38,0)
,payment_updated_at   timestamp(6) 
,chrg_person_id_chrg_payment  numeric (38,0)
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
 CREATE INDEX sio_r_payments_uk1 
  ON sio.sio_r_payments(id,sio_id); 

 drop sequence  if exists sio.sio_r_payments_seq ;
 create sequence sio.sio_r_payments_seq ;
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
