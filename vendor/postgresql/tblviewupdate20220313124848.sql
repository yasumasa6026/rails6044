
 alter table  payacts  ADD COLUMN payments_id numeric(38,0)  DEFAULT 0  not null;

 alter table payacts DROP COLUMN payments_id_pay CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'payments_id_pay'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　payments_id_payが削除　2022-03-13 12:48:34 +0900' 
 ---- where  pobject_code_sfd = 'payments_id_pay'
 alter table  payinsts  ADD COLUMN payments_id numeric(38,0)  DEFAULT 0  not null;

 alter table payinsts DROP COLUMN payments_id_pay CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'payments_id_pay'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　payments_id_payが削除　2022-03-13 12:48:34 +0900' 
 ---- where  pobject_code_sfd = 'payments_id_pay'
 alter table  payords  ADD COLUMN payments_id numeric(38,0)  DEFAULT 0  not null;

 alter table  payords  ADD COLUMN crrs_id numeric(22,0)  DEFAULT 0  not null;

 alter table payords DROP COLUMN payments_id_pay CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'payments_id_pay'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　payments_id_payが削除　2022-03-13 12:48:34 +0900' 
 ---- where  pobject_code_sfd = 'payments_id_pay'
 alter table payords DROP COLUMN crrs_id_payord CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'crrs_id_payord'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　crrs_id_payordが削除　2022-03-13 12:48:34 +0900' 
 ---- where  pobject_code_sfd = 'crrs_id_payord'
 alter table payords DROP COLUMN gno_paysch CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'gno_paysch'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　gno_payschが削除　2022-03-13 12:48:34 +0900' 
 ---- where  pobject_code_sfd = 'gno_paysch'
 alter table  payschs  ADD COLUMN payments_id numeric(38,0)  DEFAULT 0  not null;

 alter table payschs DROP COLUMN payments_id_pay CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'payments_id_pay'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　payments_id_payが削除　2022-03-13 12:48:34 +0900' 
 ---- where  pobject_code_sfd = 'payments_id_pay'
 alter table  puracts  ADD COLUMN payments_id numeric(38,0)  DEFAULT 0  not null;

 alter table  purinsts  ADD COLUMN payments_id numeric(38,0)  DEFAULT 0  not null;

 alter table  purschs  ADD COLUMN payments_id numeric(38,0)  DEFAULT 0  not null;

 alter table  purords  ADD COLUMN payments_id numeric(38,0)  DEFAULT 0  not null;

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
  drop view if  exists r_payinsts cascade ; 
 create or replace view r_payinsts as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
payinst.id id,
  chrg.person_sect_id_chrg  person_sect_id_chrg ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  payment.loca_code_payment  loca_code_payment ,
  payment.loca_name_payment  loca_name_payment ,
  payment.payment_loca_id_payment  payment_loca_id_payment ,
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
  supplier.chrg_person_id_chrg_supplier  chrg_person_id_chrg_supplier ,
  payment.chrg_person_id_chrg_payment  chrg_person_id_chrg_payment ,
  supplier.person_sect_id_chrg_supplier  person_sect_id_chrg_supplier ,
  payment.person_sect_id_chrg_payment  person_sect_id_chrg_payment ,
payinst.price  payinst_price,
payinst.remark  payinst_remark,
payinst.created_at  payinst_created_at,
payinst.update_ip  payinst_update_ip,
payinst.duedate  payinst_duedate,
payinst.amt  payinst_amt,
payinst.isudate  payinst_isudate,
payinst.expiredate  payinst_expiredate,
payinst.updated_at  payinst_updated_at,
payinst.sno  payinst_sno,
payinst.id  payinst_id,
payinst.persons_id_upd   payinst_person_id_upd,
payinst.contents  payinst_contents,
payinst.tax  payinst_tax,
payinst.contract_price  payinst_contract_price,
payinst.chrgs_id   payinst_chrg_id,
payinst.itm_code_client  payinst_itm_code_client,
payinst.suppliers_id   payinst_supplier_id,
  payment.crr_code_payment  crr_code_payment ,
  payment.crr_name_payment  crr_name_payment ,
  supplier.loca_code_payment_supplier  loca_code_payment_supplier ,
  supplier.loca_name_payment_supplier  loca_name_payment_supplier ,
  supplier.payment_loca_id_payment_supplier  payment_loca_id_payment_supplier ,
  supplier.payment_chrg_id_payment_supplier  payment_chrg_id_payment_supplier ,
  supplier.person_code_chrg_payment_supplier  person_code_chrg_payment_supplier ,
  supplier.person_name_chrg_payment_supplier  person_name_chrg_payment_supplier ,
  supplier.crr_code_payment_supplier  crr_code_payment_supplier ,
  supplier.crr_name_payment_supplier  crr_name_payment_supplier ,
payinst.payments_id   payinst_payment_id
 from payinsts   payinst,
  r_persons  person_upd ,  r_chrgs  chrg ,  r_suppliers  supplier ,  r_payments  payment 
  where       payinst.persons_id_upd = person_upd.id      and payinst.chrgs_id = chrg.id      and payinst.suppliers_id = supplier.id      and payinst.payments_id = payment.id     ;
 DROP TABLE IF EXISTS sio.sio_r_payinsts;
 CREATE TABLE sio.sio_r_payinsts (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_payinsts_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,payinst_sno  varchar (40) 
,person_code_chrg  varchar (50) 
,person_name_chrg  varchar (100) 
,crr_code_supplier  varchar (50) 
,crr_name_supplier  varchar (100) 
,person_name_chrg_supplier  varchar (100) 
,loca_code_payment  varchar (50) 
,loca_name_payment  varchar (100) 
,person_code_chrg_supplier  varchar (50) 
,loca_name_supplier  varchar (100) 
,person_code_chrg_payment  varchar (50) 
,loca_code_supplier  varchar (50) 
,person_name_chrg_payment  varchar (100) 
,payinst_expiredate   date 
,payinst_price  numeric (38,4)
,payinst_duedate   timestamp(6) 
,payinst_amt  numeric (18,4)
,payinst_isudate   timestamp(6) 
,payinst_tax  numeric (38,4)
,payinst_contract_price  varchar (1) 
,payinst_itm_code_client  varchar (50) 
,crr_code_payment  varchar (50) 
,person_code_chrg_payment_supplier  varchar (50) 
,crr_code_payment_supplier  varchar (50) 
,loca_code_payment_supplier  varchar (50) 
,person_name_chrg_payment_supplier  varchar (100) 
,loca_name_payment_supplier  varchar (100) 
,crr_name_payment  varchar (100) 
,crr_name_payment_supplier  varchar (100) 
,payinst_payment_id  numeric (38,0)
,payinst_remark  varchar (4000) 
,payinst_contents  varchar (4000) 
,person_name_upd  varchar (100) 
,person_code_upd  varchar (50) 
,payinst_updated_at   timestamp(6) 
,id  numeric (38,0)
,payinst_id  numeric (38,0)
,payinst_person_id_upd  numeric (38,0)
,payment_chrg_id_payment_supplier  numeric (22,0)
,payinst_update_ip  varchar (40) 
,payinst_created_at   timestamp(6) 
,payinst_chrg_id  numeric (38,0)
,payment_loca_id_payment_supplier  numeric (38,0)
,payinst_supplier_id  numeric (22,0)
,person_sect_id_chrg_payment  numeric (22,0)
,person_sect_id_chrg_supplier  numeric (22,0)
,chrg_person_id_chrg_payment  numeric (38,0)
,chrg_person_id_chrg_supplier  numeric (38,0)
,supplier_chrg_id_supplier  numeric (22,0)
,supplier_crr_id_supplier  numeric (22,0)
,supplier_loca_id_supplier  numeric (22,0)
,payment_chrg_id_payment  numeric (22,0)
,payment_loca_id_payment  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,person_sect_id_chrg  numeric (22,0)
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
 CREATE INDEX sio_r_payinsts_uk1 
  ON sio.sio_r_payinsts(id,sio_id); 

 drop sequence  if exists sio.sio_r_payinsts_seq ;
 create sequence sio.sio_r_payinsts_seq ;
  drop view if  exists r_payords cascade ; 
 create or replace view r_payords as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  itm.itm_name  itm_name ,
  itm.itm_code  itm_code ,
  itm.unit_name  unit_name ,
  itm.unit_code  unit_code ,
  itm.itm_unit_id  itm_unit_id ,
payord.id id,
  chrg.person_sect_id_chrg  person_sect_id_chrg ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  payment.loca_code_payment  loca_code_payment ,
  payment.loca_name_payment  loca_name_payment ,
  itm.classlist_code  classlist_code ,
  itm.classlist_name  classlist_name ,
  payment.payment_loca_id_payment  payment_loca_id_payment ,
  crr.crr_code  crr_code ,
  crr.crr_name  crr_name ,
  crr.crr_pricedecimal  crr_pricedecimal ,
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
  itm.itm_classlist_id  itm_classlist_id ,
  supplier.chrg_person_id_chrg_supplier  chrg_person_id_chrg_supplier ,
  payment.chrg_person_id_chrg_payment  chrg_person_id_chrg_payment ,
  supplier.person_sect_id_chrg_supplier  person_sect_id_chrg_supplier ,
  payment.person_sect_id_chrg_payment  person_sect_id_chrg_payment ,
payord.price  payord_price,
payord.itms_id   payord_itm_id,
payord.remark  payord_remark,
payord.created_at  payord_created_at,
payord.update_ip  payord_update_ip,
payord.duedate  payord_duedate,
payord.amt  payord_amt,
payord.isudate  payord_isudate,
payord.expiredate  payord_expiredate,
payord.updated_at  payord_updated_at,
payord.qty  payord_qty,
payord.sno  payord_sno,
payord.id  payord_id,
payord.persons_id_upd   payord_person_id_upd,
payord.contents  payord_contents,
payord.tax  payord_tax,
payord.sno_purord  payord_sno_purord,
payord.contract_price  payord_contract_price,
payord.chrgs_id   payord_chrg_id,
payord.itm_code_client  payord_itm_code_client,
payord.suppliers_id   payord_supplier_id,
payord.gno  payord_gno,
  payment.payment_crr_id_payment  payment_crr_id_payment ,
  payment.crr_code_payment  crr_code_payment ,
  payment.crr_name_payment  crr_name_payment ,
  supplier.loca_code_payment_supplier  loca_code_payment_supplier ,
  supplier.loca_name_payment_supplier  loca_name_payment_supplier ,
  supplier.payment_loca_id_payment_supplier  payment_loca_id_payment_supplier ,
  supplier.payment_chrg_id_payment_supplier  payment_chrg_id_payment_supplier ,
  supplier.person_code_chrg_payment_supplier  person_code_chrg_payment_supplier ,
  supplier.person_name_chrg_payment_supplier  person_name_chrg_payment_supplier ,
  supplier.crr_code_payment_supplier  crr_code_payment_supplier ,
  supplier.crr_name_payment_supplier  crr_name_payment_supplier ,
payord.payments_id   payord_payment_id,
payord.crrs_id   payord_crr_id
 from payords   payord,
  r_itms  itm ,  r_persons  person_upd ,  r_chrgs  chrg ,  r_suppliers  supplier ,  r_payments  payment ,  r_crrs  crr 
  where       payord.itms_id = itm.id      and payord.persons_id_upd = person_upd.id      and payord.chrgs_id = chrg.id      and payord.suppliers_id = supplier.id      and payord.payments_id = payment.id      and payord.crrs_id = crr.id     ;
 DROP TABLE IF EXISTS sio.sio_r_payords;
 CREATE TABLE sio.sio_r_payords (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_payords_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,payord_sno  varchar (40) 
,crr_code  varchar (50) 
,itm_name  varchar (100) 
,itm_code  varchar (50) 
,unit_name  varchar (100) 
,unit_code  varchar (50) 
,crr_code_supplier  varchar (50) 
,crr_name_supplier  varchar (100) 
,person_name_chrg_supplier  varchar (100) 
,person_code_chrg_supplier  varchar (50) 
,loca_name_supplier  varchar (100) 
,loca_code_payment  varchar (50) 
,loca_name_payment  varchar (100) 
,classlist_code  varchar (50) 
,classlist_name  varchar (100) 
,loca_code_supplier  varchar (50) 
,person_name_chrg  varchar (100) 
,person_code_chrg_payment  varchar (50) 
,person_name_chrg_payment  varchar (100) 
,person_code_chrg  varchar (50) 
,crr_name  varchar (100) 
,payord_price  numeric (38,4)
,payord_duedate   timestamp(6) 
,payord_amt  numeric (18,4)
,payord_isudate   timestamp(6) 
,payord_expiredate   date 
,payord_qty  numeric (18,4)
,payord_tax  numeric (38,4)
,payord_sno_purord  varchar (50) 
,payord_contract_price  varchar (1) 
,payord_itm_code_client  varchar (50) 
,crr_code_payment_supplier  varchar (50) 
,loca_code_payment_supplier  varchar (50) 
,person_code_chrg_payment_supplier  varchar (50) 
,crr_code_payment  varchar (50) 
,person_name_chrg_payment_supplier  varchar (100) 
,crr_name_payment_supplier  varchar (100) 
,loca_name_payment_supplier  varchar (100) 
,crr_name_payment  varchar (100) 
,payord_payment_id  numeric (38,0)
,payord_crr_id  numeric (22,0)
,crr_pricedecimal  numeric (22,0)
,payord_gno  varchar (40) 
,payord_contents  varchar (4000) 
,payord_remark  varchar (4000) 
,person_name_upd  varchar (100) 
,person_code_upd  varchar (50) 
,id  numeric (38,0)
,payord_itm_id  numeric (38,0)
,payord_created_at   timestamp(6) 
,payord_update_ip  varchar (40) 
,payment_loca_id_payment_supplier  numeric (38,0)
,payment_chrg_id_payment_supplier  numeric (22,0)
,payord_updated_at   timestamp(6) 
,payord_id  numeric (38,0)
,payord_person_id_upd  numeric (38,0)
,payord_chrg_id  numeric (38,0)
,payord_supplier_id  numeric (22,0)
,payment_crr_id_payment  numeric (22,0)
,person_sect_id_chrg  numeric (22,0)
,person_sect_id_chrg_payment  numeric (22,0)
,person_sect_id_chrg_supplier  numeric (22,0)
,payment_chrg_id_payment  numeric (22,0)
,chrg_person_id_chrg_payment  numeric (38,0)
,supplier_loca_id_supplier  numeric (22,0)
,supplier_chrg_id_supplier  numeric (22,0)
,supplier_crr_id_supplier  numeric (22,0)
,payment_loca_id_payment  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,chrg_person_id_chrg_supplier  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,itm_unit_id  numeric (22,0)
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
 CREATE INDEX sio_r_payords_uk1 
  ON sio.sio_r_payords(id,sio_id); 

 drop sequence  if exists sio.sio_r_payords_seq ;
 create sequence sio.sio_r_payords_seq ;
  drop view if  exists r_payschs cascade ; 
 create or replace view r_payschs as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  itm.itm_name  itm_name ,
  itm.itm_code  itm_code ,
  itm.unit_name  unit_name ,
  itm.unit_code  unit_code ,
  itm.itm_unit_id  itm_unit_id ,
paysch.id id,
  chrg.person_sect_id_chrg  person_sect_id_chrg ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
paysch.id  paysch_id,
paysch.remark  paysch_remark,
paysch.expiredate  paysch_expiredate,
paysch.update_ip  paysch_update_ip,
paysch.created_at  paysch_created_at,
paysch.updated_at  paysch_updated_at,
paysch.persons_id_upd   paysch_person_id_upd,
paysch.itms_id   paysch_itm_id,
paysch.price  paysch_price,
paysch.sno  paysch_sno,
paysch.duedate  paysch_duedate,
paysch.isudate  paysch_isudate,
paysch.contents  paysch_contents,
paysch.tax  paysch_tax,
paysch.payments_id   paysch_payment_id,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  payment.loca_code_payment  loca_code_payment ,
  payment.loca_name_payment  loca_name_payment ,
  itm.classlist_code  classlist_code ,
  itm.classlist_name  classlist_name ,
  payment.payment_loca_id_payment  payment_loca_id_payment ,
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
  itm.itm_classlist_id  itm_classlist_id ,
  supplier.chrg_person_id_chrg_supplier  chrg_person_id_chrg_supplier ,
  payment.chrg_person_id_chrg_payment  chrg_person_id_chrg_payment ,
  supplier.person_sect_id_chrg_supplier  person_sect_id_chrg_supplier ,
  payment.person_sect_id_chrg_payment  person_sect_id_chrg_payment ,
paysch.contract_price  paysch_contract_price,
paysch.chrgs_id   paysch_chrg_id,
paysch.itm_code_client  paysch_itm_code_client,
paysch.suppliers_id   paysch_supplier_id,
paysch.qty_sch  paysch_qty_sch,
  payment.crr_code_payment  crr_code_payment ,
  payment.crr_name_payment  crr_name_payment ,
paysch.amt_sch  paysch_amt_sch,
paysch.gno  paysch_gno,
  supplier.loca_code_payment_supplier  loca_code_payment_supplier ,
  supplier.loca_name_payment_supplier  loca_name_payment_supplier ,
  supplier.payment_loca_id_payment_supplier  payment_loca_id_payment_supplier ,
  supplier.payment_chrg_id_payment_supplier  payment_chrg_id_payment_supplier ,
  supplier.person_code_chrg_payment_supplier  person_code_chrg_payment_supplier ,
  supplier.person_name_chrg_payment_supplier  person_name_chrg_payment_supplier ,
  supplier.crr_code_payment_supplier  crr_code_payment_supplier ,
  supplier.crr_name_payment_supplier  crr_name_payment_supplier 
 from payschs   paysch,
  r_persons  person_upd ,  r_itms  itm ,  r_payments  payment ,  r_chrgs  chrg ,  r_suppliers  supplier 
  where       paysch.persons_id_upd = person_upd.id      and paysch.itms_id = itm.id      and paysch.payments_id = payment.id      and paysch.chrgs_id = chrg.id      and paysch.suppliers_id = supplier.id     ;
 DROP TABLE IF EXISTS sio.sio_r_payschs;
 CREATE TABLE sio.sio_r_payschs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_payschs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,paysch_sno  varchar (40) 
,person_code_chrg  varchar (50) 
,itm_name  varchar (100) 
,itm_code  varchar (50) 
,unit_name  varchar (100) 
,unit_code  varchar (50) 
,person_name_chrg  varchar (100) 
,classlist_code  varchar (50) 
,crr_code_supplier  varchar (50) 
,crr_name_supplier  varchar (100) 
,person_name_chrg_supplier  varchar (100) 
,person_code_chrg_supplier  varchar (50) 
,loca_name_supplier  varchar (100) 
,loca_code_supplier  varchar (50) 
,person_name_chrg_payment  varchar (100) 
,person_code_chrg_payment  varchar (50) 
,loca_code_payment  varchar (50) 
,loca_name_payment  varchar (100) 
,classlist_name  varchar (100) 
,paysch_tax  numeric (38,4)
,paysch_expiredate   date 
,paysch_price  numeric (38,4)
,paysch_duedate   timestamp(6) 
,paysch_isudate   timestamp(6) 
,paysch_itm_code_client  varchar (50) 
,paysch_contract_price  varchar (1) 
,loca_code_payment_supplier  varchar (50) 
,crr_code_payment  varchar (50) 
,crr_code_payment_supplier  varchar (50) 
,person_code_chrg_payment_supplier  varchar (50) 
,crr_name_payment_supplier  varchar (100) 
,crr_name_payment  varchar (100) 
,loca_name_payment_supplier  varchar (100) 
,person_name_chrg_payment_supplier  varchar (100) 
,paysch_qty_sch  numeric (22,6)
,paysch_amt_sch  numeric (38,4)
,paysch_payment_id  numeric (38,0)
,paysch_gno  varchar (40) 
,paysch_contents  varchar (4000) 
,paysch_remark  varchar (4000) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,paysch_chrg_id  numeric (38,0)
,paysch_itm_id  numeric (38,0)
,paysch_person_id_upd  numeric (38,0)
,paysch_updated_at   timestamp(6) 
,paysch_created_at   timestamp(6) 
,paysch_update_ip  varchar (40) 
,paysch_id  numeric (38,0)
,paysch_supplier_id  numeric (22,0)
,id  numeric (38,0)
,payment_loca_id_payment_supplier  numeric (38,0)
,payment_chrg_id_payment_supplier  numeric (22,0)
,chrg_person_id_chrg_supplier  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,itm_unit_id  numeric (22,0)
,supplier_crr_id_supplier  numeric (22,0)
,supplier_chrg_id_supplier  numeric (22,0)
,supplier_loca_id_supplier  numeric (22,0)
,payment_loca_id_payment  numeric (38,0)
,payment_chrg_id_payment  numeric (22,0)
,person_sect_id_chrg_payment  numeric (22,0)
,person_sect_id_chrg_supplier  numeric (22,0)
,chrg_person_id_chrg_payment  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,person_sect_id_chrg  numeric (22,0)
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
 CREATE INDEX sio_r_payschs_uk1 
  ON sio.sio_r_payschs(id,sio_id); 

 drop sequence  if exists sio.sio_r_payschs_seq ;
 create sequence sio.sio_r_payschs_seq ;
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
  payment.loca_code_payment  loca_code_payment ,
  payment.loca_name_payment  loca_name_payment ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
purinst.tax  purinst_tax,
  payment.payment_loca_id_payment  payment_loca_id_payment ,
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
purinst.autoact_p  purinst_autoact_p,
purinst.suppliers_id   purinst_supplier_id,
  supplier.chrg_person_id_chrg_supplier  chrg_person_id_chrg_supplier ,
  payment.chrg_person_id_chrg_payment  chrg_person_id_chrg_payment ,
  supplier.person_sect_id_chrg_supplier  person_sect_id_chrg_supplier ,
  payment.person_sect_id_chrg_payment  person_sect_id_chrg_payment ,
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
purinst.shelfnos_id_fm   purinst_shelfno_id_fm,
  supplier.loca_code_payment_supplier  loca_code_payment_supplier ,
  supplier.loca_name_payment_supplier  loca_name_payment_supplier ,
  supplier.payment_loca_id_payment_supplier  payment_loca_id_payment_supplier ,
  supplier.payment_chrg_id_payment_supplier  payment_chrg_id_payment_supplier ,
  supplier.person_code_chrg_payment_supplier  person_code_chrg_payment_supplier ,
  supplier.person_name_chrg_payment_supplier  person_name_chrg_payment_supplier ,
  supplier.crr_code_payment_supplier  crr_code_payment_supplier ,
  supplier.crr_name_payment_supplier  crr_name_payment_supplier ,
purinst.payments_id   purinst_payment_id
 from purinsts   purinst,
  r_opeitms  opeitm ,  r_persons  person_upd ,  r_prjnos  prjno ,  r_chrgs  chrg ,  r_suppliers  supplier ,  r_shelfnos  shelfno_to ,  r_shelfnos  shelfno_fm ,  r_payments  payment 
  where       purinst.opeitms_id = opeitm.id      and purinst.persons_id_upd = person_upd.id      and purinst.prjnos_id = prjno.id      and purinst.chrgs_id = chrg.id      and purinst.suppliers_id = supplier.id      and purinst.shelfnos_id_to = shelfno_to.id      and purinst.shelfnos_id_fm = shelfno_fm.id      and purinst.payments_id = payment.id     ;
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
,boxe_code  varchar (50) 
,classlist_code  varchar (50) 
,purinst_cno  varchar (40) 
,purinst_sno  varchar (40) 
,unit_code  varchar (50) 
,boxe_name  varchar (100) 
,purinst_starttime   timestamp(6) 
,purinst_itm_code_client  varchar (50) 
,unit_name  varchar (100) 
,purinst_expiredate   date 
,purinst_contract_price  varchar (1) 
,classlist_name  varchar (100) 
,purinst_autoact_p  numeric (3,0)
,crr_code_payment  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,shelfno_code_fm  varchar (50) 
,loca_code_shelfno_to  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,unit_code_case_shp  varchar (50) 
,crr_code_payment_supplier  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,loca_code_payment  varchar (50) 
,loca_code_payment_supplier  varchar (50) 
,person_code_chrg_payment_supplier  varchar (50) 
,prjno_code_chil  varchar (50) 
,person_code_chrg_payment  varchar (50) 
,crr_code_supplier  varchar (50) 
,person_code_chrg_supplier  varchar (50) 
,unit_code_box  varchar (50) 
,opeitm_priority  numeric (3,0)
,loca_code_supplier  varchar (50) 
,unit_code_outbox  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,loca_code_opeitm  varchar (50) 
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
,loca_name_payment_supplier  varchar (100) 
,person_name_chrg_payment_supplier  varchar (100) 
,crr_name_payment_supplier  varchar (100) 
,purinst_tax  numeric (38,4)
,purinst_duedate   timestamp(6) 
,purinst_amt  numeric (18,4)
,purinst_price  numeric (38,4)
,purinst_payment_id  numeric (38,0)
,purinst_shelfno_id_fm  numeric (22,0)
,purinst_remark  varchar (4000) 
,purinst_created_at   timestamp(6) 
,purinst_opeitm_id  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,purinst_shelfno_id_to  numeric (38,0)
,person_sect_id_chrg  numeric (22,0)
,purinst_update_ip  varchar (40) 
,id  numeric (38,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,itm_unit_id  numeric (22,0)
,payment_chrg_id_payment  numeric (22,0)
,opeitm_boxe_id  numeric (22,0)
,supplier_loca_id_supplier  numeric (22,0)
,supplier_chrg_id_supplier  numeric (22,0)
,supplier_crr_id_supplier  numeric (22,0)
,payment_loca_id_payment_supplier  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,purinst_updated_at   timestamp(6) 
,payment_loca_id_payment  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,person_sect_id_chrg_payment  numeric (22,0)
,chrg_person_id_chrg  numeric (38,0)
,purinst_prjno_id  numeric (38,0)
,purinst_person_id_upd  numeric (38,0)
,payment_chrg_id_payment_supplier  numeric (22,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,purinst_id  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,purinst_chrg_id  numeric (38,0)
,purinst_supplier_id  numeric (22,0)
,chrg_person_id_chrg_supplier  numeric (38,0)
,chrg_person_id_chrg_payment  numeric (38,0)
,person_sect_id_chrg_supplier  numeric (22,0)
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
  payment.loca_code_payment  loca_code_payment ,
  payment.loca_name_payment  loca_name_payment ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  payment.payment_loca_id_payment  payment_loca_id_payment ,
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
pursch.suppliers_id   pursch_supplier_id,
  supplier.person_sect_id_chrg_supplier  person_sect_id_chrg_supplier ,
  payment.person_sect_id_chrg_payment  person_sect_id_chrg_payment ,
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
  payment.crr_code_payment  crr_code_payment ,
  payment.crr_name_payment  crr_name_payment ,
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
  opeitm.unit_code_case_prdpur  unit_code_case_prdpur ,
  supplier.loca_code_payment_supplier  loca_code_payment_supplier ,
  supplier.loca_name_payment_supplier  loca_name_payment_supplier ,
  supplier.payment_loca_id_payment_supplier  payment_loca_id_payment_supplier ,
  supplier.payment_chrg_id_payment_supplier  payment_chrg_id_payment_supplier ,
  supplier.person_code_chrg_payment_supplier  person_code_chrg_payment_supplier ,
  supplier.person_name_chrg_payment_supplier  person_name_chrg_payment_supplier ,
  supplier.crr_code_payment_supplier  crr_code_payment_supplier ,
  supplier.crr_name_payment_supplier  crr_name_payment_supplier ,
pursch.payments_id   pursch_payment_id
 from purschs   pursch,
  r_persons  person_upd ,  r_opeitms  opeitm ,  r_prjnos  prjno ,  r_chrgs  chrg ,  r_suppliers  supplier ,  r_shelfnos  shelfno_to ,  r_shelfnos  shelfno_fm ,  r_payments  payment 
  where       pursch.persons_id_upd = person_upd.id      and pursch.opeitms_id = opeitm.id      and pursch.prjnos_id = prjno.id      and pursch.chrgs_id = chrg.id      and pursch.suppliers_id = supplier.id      and pursch.shelfnos_id_to = shelfno_to.id      and pursch.shelfnos_id_fm = shelfno_fm.id      and pursch.payments_id = payment.id     ;
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
,prjno_code  varchar (50) 
,itm_code  varchar (50) 
,boxe_code  varchar (50) 
,classlist_code  varchar (50) 
,unit_code  varchar (50) 
,unit_name_outbox  varchar (100) 
,unit_name  varchar (100) 
,unit_code_outbox  varchar (50) 
,unit_code_box  varchar (50) 
,unit_name_box  varchar (100) 
,pursch_toduedate   timestamp(6) 
,itm_name  varchar (100) 
,pursch_starttime   timestamp(6) 
,boxe_name  varchar (100) 
,prjno_name  varchar (100) 
,pursch_expiredate   date 
,classlist_name  varchar (100) 
,pursch_isudate   timestamp(6) 
,shelfno_code_to  varchar (50) 
,person_code_chrg  varchar (50) 
,loca_code_payment  varchar (50) 
,prjno_code_chil  varchar (50) 
,person_code_chrg_payment  varchar (50) 
,loca_code_supplier  varchar (50) 
,person_code_chrg_supplier  varchar (50) 
,crr_code_supplier  varchar (50) 
,loca_code_shelfno_to  varchar (50) 
,shelfno_code_fm  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,crr_code_payment  varchar (50) 
,loca_code_opeitm  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,unit_code_case_shp  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,loca_code_payment_supplier  varchar (50) 
,person_code_chrg_payment_supplier  varchar (50) 
,crr_code_payment_supplier  varchar (50) 
,loca_name_shelfno_to  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,unit_name_case_shp  varchar (100) 
,shelfno_name_fm  varchar (100) 
,prjno_name_chil  varchar (100) 
,person_name_chrg_supplier  varchar (100) 
,person_name_chrg_payment_supplier  varchar (100) 
,loca_name_opeitm  varchar (100) 
,person_name_chrg_payment  varchar (100) 
,loca_name_supplier  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,crr_name_supplier  varchar (100) 
,crr_name_payment  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,person_name_chrg  varchar (100) 
,shelfno_name_to  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,loca_name_payment_supplier  varchar (100) 
,loca_name_payment  varchar (100) 
,crr_name_payment_supplier  varchar (100) 
,opeitm_priority  numeric (3,0)
,pursch_amt_sch  numeric (38,4)
,pursch_price  numeric (38,4)
,pursch_tax  numeric (38,4)
,pursch_qty_sch  numeric (22,6)
,pursch_gno  varchar (40) 
,pursch_payment_id  numeric (38,0)
,pursch_shelfno_id_fm  numeric (22,0)
,pursch_remark  varchar (4000) 
,pursch_created_at   timestamp(6) 
,id  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,payment_loca_id_payment  numeric (38,0)
,pursch_chrg_id  numeric (38,0)
,itm_unit_id  numeric (22,0)
,payment_chrg_id_payment  numeric (22,0)
,payment_loca_id_payment_supplier  numeric (38,0)
,supplier_loca_id_supplier  numeric (22,0)
,supplier_chrg_id_supplier  numeric (22,0)
,supplier_crr_id_supplier  numeric (22,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,payment_chrg_id_payment_supplier  numeric (22,0)
,itm_classlist_id  numeric (38,0)
,chrg_person_id_chrg_supplier  numeric (38,0)
,chrg_person_id_chrg_payment  numeric (38,0)
,pursch_supplier_id  numeric (22,0)
,person_sect_id_chrg_supplier  numeric (22,0)
,person_sect_id_chrg_payment  numeric (22,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,pursch_shelfno_id_to  numeric (38,0)
,opeitm_loca_id_opeitm  numeric (22,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,pursch_person_id_upd  numeric (38,0)
,pursch_opeitm_id  numeric (38,0)
,pursch_updated_at   timestamp(6) 
,pursch_prjno_id  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,pursch_update_ip  varchar (40) 
,opeitm_boxe_id  numeric (22,0)
,boxe_unit_id_box  numeric (38,0)
,pursch_id  numeric (38,0)
,boxe_unit_id_outbox  numeric (38,0)
,person_sect_id_chrg  numeric (22,0)
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
  payment.loca_code_payment  loca_code_payment ,
  payment.loca_name_payment  loca_name_payment ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
purord.tax  purord_tax,
purord.gno  purord_gno,
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
purord.itm_code_client  purord_itm_code_client,
purord.starttime  purord_starttime,
  prjno.prjno_code_chil  prjno_code_chil ,
  payment.payment_chrg_id_payment  payment_chrg_id_payment ,
  payment.person_code_chrg_payment  person_code_chrg_payment ,
  payment.person_name_chrg_payment  person_name_chrg_payment ,
purord.suppliers_id   purord_supplier_id,
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
  payment.payment_crr_id_payment  payment_crr_id_payment ,
  payment.crr_code_payment  crr_code_payment ,
  payment.crr_name_payment  crr_name_payment ,
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
purord.shelfnos_id_fm   purord_shelfno_id_fm,
  supplier.loca_code_payment_supplier  loca_code_payment_supplier ,
  supplier.loca_name_payment_supplier  loca_name_payment_supplier ,
  supplier.payment_loca_id_payment_supplier  payment_loca_id_payment_supplier ,
  supplier.payment_chrg_id_payment_supplier  payment_chrg_id_payment_supplier ,
  supplier.person_code_chrg_payment_supplier  person_code_chrg_payment_supplier ,
  supplier.person_name_chrg_payment_supplier  person_name_chrg_payment_supplier ,
  supplier.crr_code_payment_supplier  crr_code_payment_supplier ,
  supplier.crr_name_payment_supplier  crr_name_payment_supplier ,
purord.payments_id   purord_payment_id
 from purords   purord,
  r_persons  person_upd ,  r_opeitms  opeitm ,  r_prjnos  prjno ,  r_chrgs  chrg ,  r_suppliers  supplier ,  r_shelfnos  shelfno_to ,  r_crrs  crr ,  r_shelfnos  shelfno_fm ,  r_payments  payment 
  where       purord.persons_id_upd = person_upd.id      and purord.opeitms_id = opeitm.id      and purord.prjnos_id = prjno.id      and purord.chrgs_id = chrg.id      and purord.suppliers_id = supplier.id      and purord.shelfnos_id_to = shelfno_to.id      and purord.crrs_id = crr.id      and purord.shelfnos_id_fm = shelfno_fm.id      and purord.payments_id = payment.id     ;
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
,person_code_upd  varchar (50) 
,itm_name  varchar (100) 
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
,person_code_chrg_supplier  varchar (50) 
,crr_code  varchar (50) 
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
,unit_name_box  varchar (100) 
,unit_code_box  varchar (50) 
,person_name_chrg_payment  varchar (100) 
,person_code_chrg_payment  varchar (50) 
,prjno_code_chil  varchar (50) 
,boxe_name  varchar (100) 
,boxe_code  varchar (50) 
,loca_code_payment  varchar (50) 
,loca_name_payment  varchar (100) 
,classlist_code  varchar (50) 
,classlist_name  varchar (100) 
,purord_toduedate   timestamp(6) 
,purord_expiredate   date 
,crr_name  varchar (100) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,shelfno_code_fm  varchar (50) 
,opeitm_priority  numeric (3,0)
,crr_code_payment_supplier  varchar (50) 
,loca_code_payment_supplier  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,crr_code_payment  varchar (50) 
,unit_code_case_shp  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,person_code_chrg_payment_supplier  varchar (50) 
,loca_code_opeitm  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,unit_name_case_prdpur  varchar (100) 
,person_name_chrg_payment_supplier  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,unit_name_case_shp  varchar (100) 
,loca_name_opeitm  varchar (100) 
,prjno_name_chil  varchar (100) 
,crr_name_payment  varchar (100) 
,crr_name_payment_supplier  varchar (100) 
,loca_name_payment_supplier  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,shelfno_name_fm  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,purord_gno  varchar (40) 
,purord_contract_price  varchar (1) 
,purord_payment_id  numeric (38,0)
,crr_pricedecimal  numeric (22,0)
,purord_crr_id  numeric (22,0)
,purord_shelfno_id_fm  numeric (22,0)
,purord_remark  varchar (4000) 
,purord_opeitm_id  numeric (38,0)
,purord_person_id_upd  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,id  numeric (38,0)
,opeitm_loca_id_opeitm  numeric (22,0)
,purord_id  numeric (38,0)
,purord_updated_at   timestamp(6) 
,payment_loca_id_payment_supplier  numeric (38,0)
,payment_chrg_id_payment_supplier  numeric (22,0)
,purord_created_at   timestamp(6) 
,purord_update_ip  varchar (40) 
,purord_shelfno_id_to  numeric (38,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,boxe_unit_id_outbox  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,payment_crr_id_payment  numeric (22,0)
,purord_chrg_id  numeric (38,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,purord_prjno_id  numeric (38,0)
,purord_supplier_id  numeric (22,0)
,payment_loca_id_payment  numeric (38,0)
,person_sect_id_chrg_supplier  numeric (22,0)
,chrg_person_id_chrg_payment  numeric (38,0)
,chrg_person_id_chrg_supplier  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,supplier_crr_id_supplier  numeric (22,0)
,supplier_chrg_id_supplier  numeric (22,0)
,supplier_loca_id_supplier  numeric (22,0)
,payment_chrg_id_payment  numeric (22,0)
,opeitm_boxe_id  numeric (22,0)
,person_sect_id_chrg_payment  numeric (22,0)
,chrg_person_id_chrg  numeric (38,0)
,person_sect_id_chrg  numeric (22,0)
,itm_unit_id  numeric (22,0)
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
 ALTER TABLE payacts ADD CONSTRAINT payact_payments_id FOREIGN KEY (payments_id)
																		 REFERENCES payments (id);
 ALTER TABLE payinsts ADD CONSTRAINT payinst_payments_id FOREIGN KEY (payments_id)
																		 REFERENCES payments (id);
 ALTER TABLE payords ADD CONSTRAINT payord_payments_id FOREIGN KEY (payments_id)
																		 REFERENCES payments (id);
 ALTER TABLE payords ADD CONSTRAINT payord_crrs_id FOREIGN KEY (crrs_id)
																		 REFERENCES crrs (id);
 ALTER TABLE payschs ADD CONSTRAINT paysch_payments_id FOREIGN KEY (payments_id)
																		 REFERENCES payments (id);
 ALTER TABLE puracts ADD CONSTRAINT puract_payments_id FOREIGN KEY (payments_id)
																		 REFERENCES payments (id);
 ALTER TABLE purinsts ADD CONSTRAINT purinst_payments_id FOREIGN KEY (payments_id)
																		 REFERENCES payments (id);
 ALTER TABLE purschs ADD CONSTRAINT pursch_payments_id FOREIGN KEY (payments_id)
																		 REFERENCES payments (id);
 ALTER TABLE purords ADD CONSTRAINT purord_payments_id FOREIGN KEY (payments_id)
																		 REFERENCES payments (id);
