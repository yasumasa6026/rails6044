
  drop view if  exists bal_custschs cascade ; 
 create or replace view bal_custschs as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_processseq  opeitm_processseq ,
  opeitm.opeitm_packqty  opeitm_packqty ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
  cust.loca_name_cust  loca_name_cust ,
  cust.loca_code_cust  loca_code_cust ,
  custrcvplc.loca_code_custrcvplc  loca_code_custrcvplc ,
  custrcvplc.loca_name_custrcvplc  loca_name_custrcvplc ,
custsch.id id,
  cust.cust_loca_id_cust  cust_loca_id_cust ,
  prjno.prjno_name  prjno_name ,
  person_upd.code  person_code_upd ,
  person_upd.name  person_name_upd ,
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
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  cust.person_code_chrg_cust  person_code_chrg_cust ,
  cust.person_name_chrg_cust  person_name_chrg_cust ,
  cust.person_sect_id_chrg_cust  person_sect_id_chrg_cust ,
  cust.cust_amtround  cust_amtround ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  crr.code  crr_code ,
  crr.name  crr_name ,
  crr.decimal	crr_decimal ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  prjno.prjno_code_chil  prjno_code_chil ,
  opeitm.itm_classlist_id  itm_classlist_id ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
custsch.opeitms_id   custsch_opeitm_id,
custsch.gno  custsch_gno,
custsch.starttime  custsch_starttime,
custsch.qty_sch  custsch_qty_sch,
l.qty_src  linkcust_qty_sch_bal,
custsch.shelfnos_id_fm   custsch_shelfno_id_fm,
custsch.amt_sch  custsch_amt_sch,
  prjno.prjno_name_chil  prjno_name_chil ,
  opeitm.unit_name_case_shp  unit_name_case_shp ,
  opeitm.unit_name_case_prdpur  unit_name_case_prdpur ,
  opeitm.unit_code_case_prdpur  unit_code_case_prdpur ,
custsch.custrcvplcs_id   custsch_custrcvplc_id,
  opeitm.opeitm_shelfno_id_opeitm  opeitm_shelfno_id_opeitm ,
  opeitm.shelfno_code_opeitm  shelfno_code_opeitm ,
  opeitm.shelfno_name_opeitm  shelfno_name_opeitm ,
  opeitm.shelfno_loca_id_shelfno_opeitm  shelfno_loca_id_shelfno_opeitm ,
  opeitm.loca_code_shelfno_opeitm  loca_code_shelfno_opeitm ,
  opeitm.loca_name_shelfno_opeitm  loca_name_shelfno_opeitm ,
  opeitm.opeitm_shpordauto  opeitm_shpordauto ,
  opeitm.opeitm_prdpurordauto  opeitm_prdpurordauto ,
  opeitm.opeitm_itmtype  opeitm_itmtype ,
custsch.chrgs_id   custsch_chrg_id,
custsch.taxrate  custsch_taxrate,
  opeitm.itm_taxflg  itm_taxflg ,
custsch.tax  custsch_tax,
custsch.contractprice  custsch_contractprice,
  cust.bill_chrg_id_bill_cust  bill_chrg_id_bill_cust ,
  cust.person_code_chrg_bill_cust  person_code_chrg_bill_cust ,
  cust.person_name_chrg_bill_cust  person_name_chrg_bill_cust ,
  cust.bill_crr_id_bill_cust  bill_crr_id_bill_cust ,
  cust.crr_code_bill_cust  crr_code_bill_cust ,
  cust.crr_name_bill_cust  crr_name_bill_cust ,
custsch.crrs_id   custsch_crr_id,
custsch.masterprice  custsch_masterprice
 from custschs   custsch,linkcusts l ,
  r_prjnos  prjno ,  persons  person_upd ,  r_custs  cust ,  r_opeitms  opeitm ,  r_shelfnos  shelfno_fm ,  r_custrcvplcs  custrcvplc ,
  r_chrgs  chrg ,  crrs  crr 
  where       custsch.prjnos_id = prjno.id      and custsch.persons_id_upd = person_upd.id      
 	and custsch.custs_id = cust.id      and custsch.opeitms_id = opeitm.id      and custsch.shelfnos_id_fm = shelfno_fm.id      
 	and custsch.custrcvplcs_id = custrcvplc.id      and custsch.chrgs_id = chrg.id      and custsch.crrs_id = crr.id
 	and l.srctblname = 'custschs' and l.tblname = 'custschs' and l.srctblid = l.tblid and l.tblid = custsch.id;
 DROP TABLE IF EXISTS sio.sio_bal_custschs;
 CREATE TABLE sio.sio_bal_custschs (
          sio_id numeric(22,0)  CONSTRAINT SIO_bal_custschs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,loca_code_cust  varchar (50) 
,loca_name_cust  varchar (100) 
,custsch_duedate   timestamp(6) 
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,opeitm_processseq  numeric (3,0)
,opeitm_priority  numeric (3,0)
,crr_code  varchar (50) 
,crr_name  varchar (100) 
,crr_decimal  numeric (1,0)
,custsch_qty_sch  numeric (22,6)
,linkcust_qty_sch_bal  numeric (22,6)
,custsch_masterprice  numeric (38,4)
,custsch_price  numeric (38,4)
,custsch_amt_sch  numeric (38,4)
,itm_taxflg  varchar (20) 
,custsch_taxrate  numeric (2,0)
,custsch_tax  numeric (38,4)
,loca_code_shelfno_opeitm  varchar (50) 
,loca_name_shelfno_opeitm  varchar (100) 
,shelfno_code_opeitm  varchar (50) 
,shelfno_name_opeitm  varchar (100) 
,loca_code_shelfno_fm  varchar (50) 
,loca_name_shelfno_fm  varchar (100) 
,shelfno_code_fm  varchar (50) 
,shelfno_name_fm  varchar (100) 
,loca_code_custrcvplc  varchar (50) 
,loca_name_custrcvplc  varchar (100) 
,person_code_chrg_cust  varchar (50) 
,person_name_chrg_cust  varchar (100) 
,prjno_code_chil  varchar (50) 
,prjno_code  varchar (50) 
,prjno_name  varchar (100) 
,custsch_expiredate   date 
,classlist_code  varchar (50) 
,classlist_name  varchar (100) 
,crr_code_bill_cust  varchar (50) 
,opeitm_packqty  numeric (38,0)
,unit_code_case_prdpur  varchar (50) 
,person_code_chrg  varchar (50) 
,person_code_chrg_bill_cust  varchar (50) 
,crr_name_bill_cust  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,unit_name_case_shp  varchar (100) 
,person_name_chrg_bill_cust  varchar (100) 
,person_name_chrg  varchar (100) 
,prjno_name_chil  varchar (100) 
,custsch_starttime   timestamp(6) 
,custsch_sno  varchar (50) 
,cust_amtround  varchar (2) 
,custsch_chrg_id  numeric (38,0)
,custsch_contractprice  varchar (20) 
,custsch_gno  varchar (40) 
,custsch_custrcvplc_id  numeric (38,0)
,custsch_crr_id  numeric (22,0)
,opeitm_shpordauto  varchar (1) 
,opeitm_prdpurordauto  varchar (1) 
,opeitm_itmtype  varchar (1) 
,custsch_contents  varchar (4000) 
,custsch_remark  varchar (4000) 
,person_name_upd  varchar (100) 
,person_code_upd  varchar (50) 
,opeitm_shelfno_id_opeitm  numeric (22,0)
,custsch_opeitm_id  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,shelfno_loca_id_shelfno_opeitm  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,boxe_unit_id_box  numeric (22,0)
,opeitm_itm_id  numeric (38,0)
,person_sect_id_chrg_cust  numeric (22,0)
,chrg_person_id_chrg  numeric (38,0)
,custsch_cust_id  numeric (38,0)
,itm_unit_id  numeric (22,0)
,custsch_person_id_upd  numeric (38,0)
,custsch_id  numeric (38,0)
,custsch_update_ip  varchar (40) 
,bill_chrg_id_bill_cust  numeric (22,0)
,custsch_created_at   timestamp(6) 
,id  numeric (38,0)
,bill_crr_id_bill_cust  numeric (22,0)
,custsch_updated_at   timestamp(6) 
,custsch_prjno_id  numeric (38,0)
,cust_loca_id_cust  numeric (38,0)
,custsch_shelfno_id_fm  numeric (22,0)
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
 CREATE INDEX sio_bal_custschs_uk1 
  ON sio.sio_bal_custschs(id,sio_id); 

 drop sequence  if exists sio.sio_bal_custschs_seq ;
 create sequence sio.sio_bal_custschs_seq ;
