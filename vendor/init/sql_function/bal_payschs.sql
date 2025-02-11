
  drop view if  exists bal_payschs cascade ; 
 create or replace view bal_payschs as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
paysch.id id,
  chrg.person_sect_id_chrg  person_sect_id_chrg ,
  person_upd.code  person_code_upd ,
  person_upd.name  person_name_upd ,
paysch.id  paysch_id,
paysch.remark  paysch_remark,
paysch.expiredate  paysch_expiredate,
paysch.update_ip  paysch_update_ip,
paysch.created_at  paysch_created_at,
paysch.updated_at  paysch_updated_at,
paysch.persons_id_upd   paysch_person_id_upd,
paysch.sno  paysch_sno,
paysch.duedate  paysch_duedate,
paysch.isudate  paysch_isudate,
paysch.contents  paysch_contents,
paysch.tax  paysch_tax,
paysch.payments_id   paysch_payment_id,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  payment.loca_code_payment  loca_code_payment ,
  payment.loca_name_payment  loca_name_payment ,
  payment.person_code_chrg_payment  person_code_chrg_payment ,
  payment.person_name_chrg_payment  person_name_chrg_payment ,
  payment.chrg_person_id_chrg_payment  chrg_person_id_chrg_payment ,
  payment.person_sect_id_chrg_payment  person_sect_id_chrg_payment ,
paysch.chrgs_id   paysch_chrg_id,
  payment.crr_code_payment  crr_code_payment ,
  payment.crr_name_payment  crr_name_payment ,
(paysch.amt_sch - COALESCE(func_ord_amt_bal('payschs',paysch.id),0)) srctbllink_amt_bal,
paysch.amt_sch  paysch_amt_sch,
paysch.gno  paysch_gno,
paysch.taxrate  paysch_taxrate,
paysch.accounttitle  paysch_accounttitle
 from payschs   paysch,
  persons  person_upd ,  r_payments  payment ,  r_chrgs  chrg 
  where       paysch.persons_id_upd = person_upd.id      and paysch.payments_id = payment.id      and paysch.chrgs_id = chrg.id        ;
 DROP TABLE IF EXISTS sio.sio_bal_payschs;
 CREATE TABLE sio.sio_bal_payschs (
          sio_id numeric(22,0)  CONSTRAINT SIO_bal_payschs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,paysch_sno  varchar (50) 
,loca_code_payment  varchar (50) 
,loca_name_payment  varchar (100) 
,paysch_amt_sch  numeric (38,4)
,srctbllink_amt_bal  numeric (38,4)
,paysch_isudate   timestamp(6) 
,paysch_duedate   timestamp(6) 
,paysch_taxrate  numeric (2,0)
,paysch_tax  numeric (38,4)
,person_code_chrg  varchar (50) 
,person_name_chrg  varchar (100) 
,crr_code_payment  varchar (50) 
,crr_name_payment  varchar (100) 
,paysch_expiredate   date 
,person_code_chrg_payment  varchar (50) 
,person_name_chrg_payment  varchar (100) 
,paysch_payment_id  numeric (38,0)
,paysch_gno  varchar (40) 
,paysch_accounttitle  varchar (20) 
,paysch_remark  varchar (4000) 
,paysch_contents  varchar (4000) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,paysch_person_id_upd  numeric (38,0)
,paysch_id  numeric (38,0)
,paysch_chrg_id  numeric (38,0)
,paysch_updated_at   timestamp(6) 
,paysch_created_at   timestamp(6) 
,paysch_update_ip  varchar (40) 
,id  numeric (38,0)
,chrg_person_id_chrg_payment  numeric (38,0)
,person_sect_id_chrg  numeric (22,0)
,chrg_person_id_chrg  numeric (38,0)
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
 CREATE INDEX sio_bal_payschs_uk1 
  ON sio.sio_bal_payschs(id,sio_id); 

 drop sequence  if exists sio.sio_bal_payschs_seq ;
 create sequence sio.sio_bal_payschs_seq ;
