
  drop view if  exists bal_payords cascade ; 
 create or replace view bal_payords as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
payord.id id,
  chrg.person_sect_id_chrg  person_sect_id_chrg ,
  person_upd.code  person_code_upd ,
  person_upd.name  person_name_upd ,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  payment.loca_code_payment  loca_code_payment ,
  payment.loca_name_payment  loca_name_payment ,
  payment.person_code_chrg_payment  person_code_chrg_payment ,
  payment.person_name_chrg_payment  person_name_chrg_payment ,
  payment.chrg_person_id_chrg_payment  chrg_person_id_chrg_payment ,
  payment.person_sect_id_chrg_payment  person_sect_id_chrg_payment ,
payord.remark  payord_remark,
payord.created_at  payord_created_at,
payord.update_ip  payord_update_ip,
payord.duedate  payord_duedate,
payord.amt  payord_amt,
(payord.amt - COALESCE(func_ord_amt_bal('payords',payord.id),0)) srctbllink_amt_bal,
payord.isudate  payord_isudate,
payord.expiredate  payord_expiredate,
payord.updated_at  payord_updated_at,
payord.sno  payord_sno,
payord.id  payord_id,
payord.persons_id_upd   payord_person_id_upd,
payord.contents  payord_contents,
payord.tax  payord_tax,
payord.chrgs_id   payord_chrg_id,
payord.suppliers_id   payord_supplier_id,
payord.gno  payord_gno,
  payment.crr_code_payment  crr_code_payment ,
  payment.crr_name_payment  crr_name_payment ,
  supplier.loca_code_payment_supplier  loca_code_payment_supplier ,
  supplier.loca_name_payment_supplier  loca_name_payment_supplier ,
payord.payments_id   payord_payment_id,
payord.taxrate  payord_taxrate,
payord.denomination  payord_denomination,
payord.billingdate  payord_billingdate,
payord.accounttitle  payord_accounttitle
 from payords   payord,
  persons  person_upd ,  r_chrgs  chrg ,  r_suppliers  supplier ,  r_payments  payment 
  where       payord.persons_id_upd = person_upd.id      and payord.chrgs_id = chrg.id      and payord.suppliers_id = supplier.id      and payord.payments_id = payment.id      ;
 DROP TABLE IF EXISTS sio.sio_bal_payords;
 CREATE TABLE sio.sio_bal_payords (
          sio_id numeric(22,0)  CONSTRAINT SIO_bal_payords_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,payord_isudate   timestamp(6) 
,payord_sno  varchar (50) 
,payord_billingdate   date 
,payord_duedate   timestamp(6) 
,loca_code_payment  varchar (50) 
,loca_name_payment  varchar (100) 
,payord_amt  numeric (18,4)
,srctbllink_amt_bal  numeric (18,4)
,payord_taxrate  numeric (2,0)
,payord_tax  numeric (38,4)
,payord_denomination  varchar (20) 
,payord_accounttitle  varchar (20) 
,person_code_chrg  varchar (50) 
,person_name_chrg  varchar (100) 
,person_code_chrg_payment  varchar (50) 
,person_name_chrg_payment  varchar (100) 
,payord_expiredate   date 
,crr_code_payment  varchar (50) 
,crr_name_payment  varchar (100) 
,payord_gno  varchar (40) 
,loca_code_payment_supplier  varchar (50) 
,loca_name_payment_supplier  varchar (100) 
,payord_payment_id  numeric (38,0)
,payord_remark  varchar (4000) 
,payord_contents  varchar (4000) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,payord_created_at   timestamp(6) 
,payord_update_ip  varchar (40) 
,payord_updated_at   timestamp(6) 
,id  numeric (38,0)
,payord_id  numeric (38,0)
,payord_person_id_upd  numeric (38,0)
,payord_chrg_id  numeric (38,0)
,payord_supplier_id  numeric (22,0)
,chrg_person_id_chrg  numeric (38,0)
,chrg_person_id_chrg_payment  numeric (38,0)
,person_sect_id_chrg  numeric (22,0)
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
 CREATE INDEX sio_bal_payords_uk1 
  ON sio.sio_bal_payords(id,sio_id); 

 drop sequence  if exists sio.sio_bal_payords_seq ;
 create sequence sio.sio_bal_payords_seq ;
