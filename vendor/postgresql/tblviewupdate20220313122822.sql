
 alter table  payacts  ADD COLUMN payments_id numeric(38,0)  DEFAULT 0  not null;

 alter table payacts DROP COLUMN payments_id_pay CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'payments_id_pay'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　payments_id_payが削除　2022-03-13 12:28:21 +0900' 
 ---- where  pobject_code_sfd = 'payments_id_pay'
  drop view if  exists r_payacts cascade ; 
 create or replace view r_payacts as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
payact.id id,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  payment.loca_code_payment  loca_code_payment ,
  payment.loca_name_payment  loca_name_payment ,
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
payact.price  payact_price,
payact.remark  payact_remark,
payact.created_at  payact_created_at,
payact.update_ip  payact_update_ip,
payact.duedate  payact_duedate,
payact.isudate  payact_isudate,
payact.expiredate  payact_expiredate,
payact.updated_at  payact_updated_at,
payact.id  payact_id,
payact.persons_id_upd   payact_person_id_upd,
payact.contents  payact_contents,
payact.tax  payact_tax,
payact.contract_price  payact_contract_price,
payact.sno_payinst  payact_sno_payinst,
payact.chrgs_id   payact_chrg_id,
payact.itm_code_client  payact_itm_code_client,
payact.suppliers_id   payact_supplier_id,
payact.sno  payact_sno,
  payment.crr_code_payment  crr_code_payment ,
  payment.crr_name_payment  crr_name_payment ,
payact.cash  payact_cash,
  supplier.loca_code_payment_supplier  loca_code_payment_supplier ,
  supplier.loca_name_payment_supplier  loca_name_payment_supplier ,
  supplier.payment_loca_id_payment_supplier  payment_loca_id_payment_supplier ,
  supplier.payment_chrg_id_payment_supplier  payment_chrg_id_payment_supplier ,
  supplier.person_code_chrg_payment_supplier  person_code_chrg_payment_supplier ,
  supplier.person_name_chrg_payment_supplier  person_name_chrg_payment_supplier ,
  supplier.crr_code_payment_supplier  crr_code_payment_supplier ,
  supplier.crr_name_payment_supplier  crr_name_payment_supplier ,
payact.payments_id   payact_payment_id
 from payacts   payact,
  r_persons  person_upd ,  r_chrgs  chrg ,  r_suppliers  supplier ,  r_payments  payment 
  where       payact.persons_id_upd = person_upd.id      and payact.chrgs_id = chrg.id      and payact.suppliers_id = supplier.id      and payact.payments_id = payment.id     ;
 DROP TABLE IF EXISTS sio.sio_r_payacts;
 CREATE TABLE sio.sio_r_payacts (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_payacts_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,person_code_chrg  varchar (50) 
,crr_code_payment_supplier  varchar (50) 
,loca_code_payment  varchar (50) 
,person_code_chrg_payment  varchar (50) 
,person_code_chrg_payment_supplier  varchar (50) 
,loca_code_payment_supplier  varchar (50) 
,loca_code_supplier  varchar (50) 
,person_code_chrg_supplier  varchar (50) 
,crr_code_payment  varchar (50) 
,crr_code_supplier  varchar (50) 
,crr_name_supplier  varchar (100) 
,person_name_chrg  varchar (100) 
,person_name_chrg_payment_supplier  varchar (100) 
,loca_name_supplier  varchar (100) 
,loca_name_payment  varchar (100) 
,crr_name_payment_supplier  varchar (100) 
,person_name_chrg_payment  varchar (100) 
,person_name_chrg_supplier  varchar (100) 
,crr_name_payment  varchar (100) 
,loca_name_payment_supplier  varchar (100) 
,payact_sno  varchar (40) 
,id  numeric (38,0)
,payact_price  numeric (38,4)
,payact_remark  varchar (4000) 
,payact_created_at   timestamp(6) 
,payact_update_ip  varchar (40) 
,payact_duedate   timestamp(6) 
,payact_isudate   timestamp(6) 
,payact_expiredate   date 
,payact_updated_at   timestamp(6) 
,payact_id  numeric (38,0)
,payact_contents  varchar (4000) 
,payact_tax  numeric (38,4)
,payact_contract_price  varchar (1) 
,payact_sno_payinst  varchar (50) 
,payact_chrg_id  numeric (38,0)
,payact_itm_code_client  varchar (50) 
,payact_supplier_id  numeric (22,0)
,payact_cash  numeric (22,2)
,payact_payment_id  numeric (38,0)
,person_name_upd  varchar (100) 
,person_code_upd  varchar (50) 
,payment_loca_id_payment_supplier  numeric (38,0)
,payment_chrg_id_payment_supplier  numeric (22,0)
,supplier_crr_id_supplier  numeric (22,0)
,chrg_person_id_chrg  numeric (38,0)
,payact_person_id_upd  numeric (22,0)
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
 CREATE INDEX sio_r_payacts_uk1 
  ON sio.sio_r_payacts(id,sio_id); 

 drop sequence  if exists sio.sio_r_payacts_seq ;
 create sequence sio.sio_r_payacts_seq ;
 ALTER TABLE payacts ADD CONSTRAINT payact_payments_id FOREIGN KEY (payments_id)
																		 REFERENCES payments (id);
