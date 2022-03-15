
 alter table  suppliers  ADD COLUMN payments_id_supplier numeric(22,0)  DEFAULT 0  not null;

 alter table suppliers DROP COLUMN payments_id CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'payments_id'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　payments_idが削除　2022-03-13 11:57:38 +0900' 
 ---- where  pobject_code_sfd = 'payments_id'
  drop view if  exists r_suppliers cascade ; 
 create or replace view r_suppliers as select  
supplier.id id,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
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
  chrg_supplier.person_sect_id_chrg  person_sect_id_chrg_supplier ,
supplier.payments_id_supplier   supplier_payment_id_supplier,
  payment_supplier.loca_code_payment  loca_code_payment_supplier ,
  payment_supplier.loca_name_payment  loca_name_payment_supplier ,
  payment_supplier.payment_loca_id_payment  payment_loca_id_payment_supplier ,
  payment_supplier.payment_chrg_id_payment  payment_chrg_id_payment_supplier ,
  payment_supplier.person_code_chrg_payment  person_code_chrg_payment_supplier ,
  payment_supplier.person_name_chrg_payment  person_name_chrg_payment_supplier ,
  payment_supplier.crr_code_payment  crr_code_payment_supplier ,
  payment_supplier.crr_name_payment  crr_name_payment_supplier 
 from suppliers   supplier,
  r_persons  person_upd ,  r_locas  loca_supplier ,  r_chrgs  chrg_supplier ,  r_crrs  crr_supplier ,  r_payments  payment_supplier 
  where       supplier.persons_id_upd = person_upd.id      and supplier.locas_id_supplier = loca_supplier.id      and supplier.chrgs_id_supplier = chrg_supplier.id      and supplier.crrs_id_supplier = crr_supplier.id      and supplier.payments_id_supplier = payment_supplier.id     ;
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
,supplier_personname  varchar (30) 
,supplier_custtype  varchar (1) 
,supplier_contract_price  varchar (1) 
,supplier_rule_price  varchar (1) 
,supplier_amtround  varchar (2) 
,supplier_amtdecimal  numeric (38,0)
,supplier_expiredate   date 
,crr_code_payment_supplier  varchar (50) 
,person_code_chrg_payment_supplier  varchar (50) 
,loca_code_payment_supplier  varchar (50) 
,crr_name_payment_supplier  varchar (100) 
,person_name_chrg_payment_supplier  varchar (100) 
,loca_name_payment_supplier  varchar (100) 
,supplier_payment_id_supplier  numeric (22,0)
,supplier_contents  varchar (4000) 
,supplier_remark  varchar (4000) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,supplier_chrg_id_supplier  numeric (22,0)
,supplier_created_at   timestamp(6) 
,supplier_update_ip  varchar (40) 
,supplier_updated_at   timestamp(6) 
,supplier_id  numeric (38,0)
,supplier_person_id_upd  numeric (38,0)
,supplier_loca_id_supplier  numeric (22,0)
,id  numeric (38,0)
,supplier_crr_id_supplier  numeric (22,0)
,payment_loca_id_payment_supplier  numeric (38,0)
,payment_chrg_id_payment_supplier  numeric (22,0)
,person_sect_id_chrg_supplier  numeric (22,0)
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
 ALTER TABLE suppliers ADD CONSTRAINT supplier_payments_id_supplier FOREIGN KEY (payments_id_supplier)
																		 REFERENCES payments (id);
