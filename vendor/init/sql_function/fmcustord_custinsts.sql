
  drop view if  exists fmcustord_custinsts cascade ; 
 create or replace view fmcustord_custinsts as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_processseq  opeitm_processseq ,
  opeitm.opeitm_packqty  opeitm_packqty ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
custord.remark  custinst_remark,
custord.update_ip  custinst_update_ip,
custord.duedate  custinst_duedate,
custord.updated_at  custinst_updated_at,
custord.price  custinst_price,
null  custinst_id,
custord.persons_id_upd   custinst_person_id_upd,
custord.created_at  custinst_created_at,
custord.expiredate  custinst_expiredate,
''  custinst_sno,
  cust.loca_name_cust  loca_name_cust ,
custord.amt  custinst_amt,
custord.qty  custord_qty,
(case when func_get_custxxxs_qty_bal('custords',custord.id) is null then custord.qty else
					func_get_custxxxs_qty_bal('custords',custord.id) - custord.qty  end) custinst_qty,
(case when func_get_custxxxs_qty_bal('custords',custord.id) is null then custord.qty else
					func_get_custxxxs_qty_bal('custords',custord.id) - custord.qty  end) custord_qty_bal ,
lotpackno.lotno custinst_lotno,
lotpackno.packno custinst_packno,
lotpackno.qty_stk  custinst_qty_stk,
(lotpackno.qty_stk * custord.taxrate * custord.price / 100) custinst_tax  ,
custord.taxrate  custinst_taxrate,
current_date  custinst_isudate,
  cust.loca_code_cust  loca_code_cust ,
  custrcvplc.loca_code_custrcvplc  loca_code_custrcvplc ,
  custrcvplc.loca_name_custrcvplc  loca_name_custrcvplc ,
null id,
custord.custs_id   custinst_cust_id,
custord.sno  custinst_sno_custord,
custord.id  custord_id,
  cust.cust_loca_id_cust  cust_loca_id_cust ,
  prjno.prjno_name  prjno_name ,
  person_upd.code  person_code_upd ,
  person_upd.name  person_name_upd ,
custord.cno  custinst_cno,
  prjno.prjno_code  prjno_code ,
custord.prjnos_id   custinst_prjno_id,
''  custinst_gno,
  custrcvplc.custrcvplc_loca_id_custrcvplc  custrcvplc_loca_id_custrcvplc ,
custord.contractprice  custinst_contractprice,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
custord.chrgs_id   custinst_chrg_id,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  cust.bill_loca_id_bill_cust  bill_loca_id_bill_cust ,
  cust.loca_code_bill_cust  loca_code_bill_cust ,
  cust.loca_name_bill_cust  loca_name_bill_cust ,  crr.crr_code  crr_code ,
  crr.crr_name  crr_name ,
  crr.crr_decimal  crr_decimal ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
custord.custrcvplcs_id   custinst_custrcvplc_id,
custord.itm_code_client  custinst_itm_code_client,
custord.contents  custinst_contents,
  cust.bill_chrg_id_bill_cust  bill_chrg_id_bill_cust ,
  cust.person_code_chrg_bill_cust  person_code_chrg_bill_cust ,
  cust.person_name_chrg_bill_cust  person_name_chrg_bill_cust ,
  opeitm.itm_classlist_id  itm_classlist_id ,
  lotpackno.shelfno_code  shelfno_code_fm ,
  lotpackno.shelfno_name  shelfno_name_fm ,
  lotpackno.loca_code  loca_code_shelfno_fm ,
  lotpackno.loca_name  loca_name_shelfno_fm ,
  lotpackno.locas_id  shelfno_loca_id_shelfno_fm ,
custord.opeitms_id   custinst_opeitm_id,
  cust.crr_code_bill_cust  crr_code_bill_cust ,
  cust.crr_name_bill_cust  crr_name_bill_cust ,
custord.starttime  custinst_starttime,
lotpackno.shelfnos_id   custinst_shelfno_id_fm,
  prjno.prjno_priority  prjno_priority ,
custord.crrs_id   custinst_crr_id,
  opeitm.opeitm_shelfno_id_opeitm  opeitm_shelfno_id_opeitm ,
  opeitm.shelfno_code_opeitm  shelfno_code_opeitm ,
  opeitm.shelfno_name_opeitm  shelfno_name_opeitm ,
  opeitm.shelfno_loca_id_shelfno_opeitm  shelfno_loca_id_shelfno_opeitm ,
  opeitm.loca_code_shelfno_opeitm  loca_code_shelfno_opeitm ,
  opeitm.loca_name_shelfno_opeitm  loca_name_shelfno_opeitm ,
  opeitm.opeitm_shpordauto  opeitm_shpordauto ,
  opeitm.opeitm_prdpurordauto  opeitm_prdpurordauto ,
  opeitm.opeitm_itmtype  opeitm_itmtype ,
  '' custinst_packingListNo
 from custords   custord,func_get_custord_stk_qty(custord.id) lotpackno,
  persons  person_upd ,  r_custs  cust ,  r_prjnos  prjno ,  r_chrgs  chrg ,  r_custrcvplcs  custrcvplc ,
  r_opeitms  opeitm ,   r_crrs  crr 
  where       custord.persons_id_upd = person_upd.id      and custord.custs_id = cust.id      
  	and custord.prjnos_id = prjno.id      and custord.chrgs_id = chrg.id      
 	and custord.custrcvplcs_id = custrcvplc.id      and custord.opeitms_id = opeitm.id      
 	and custord.crrs_id = crr.id 
 	and exists(select 1 from linkcusts link where qty_src > 0 and tblname = 'custords' and tblid = custord.id)
 	and not exists(select 1 from linkcusts link where qty_src >= custord.qty and srctblname = 'custords' and srctblid = custord.id AND 
 								(tblname = 'custinsts' or tblname = 'custdlvs' OR tblname = 'custacts' )) ;
 DROP TABLE IF EXISTS sio.sio_fmcustord_custinsts;
 CREATE TABLE sio.sio_fmcustord_custinsts (
          sio_id numeric(22,0)  CONSTRAINT SIO_fmcustord_custinsts_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,custinst_isudate   timestamp(6) 
,custinst_cno  varchar (40) 
,loca_code_cust  varchar (50) 
,loca_name_cust  varchar (100) 
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,opeitm_processseq  numeric (3,0)
,opeitm_priority  numeric (3,0)
,custinst_itm_code_client  varchar (50) 
,custinst_duedate   timestamp(6) 
,custord_qty  numeric (18,4)
,custord_qty_bal  numeric (18,4)
,custinst_qty_stk numeric (18,4)
,custinst_qty numeric (18,4)
,custinst_tax numeric (18,4)
,custinst_taxrate numeric (18,4)
,custinst_price  numeric (22,0)
,custinst_contractprice  varchar (1) 
,custinst_amt  numeric (18,4)
,loca_code_bill  varchar (50) 
,loca_name_bill  varchar (100) 
,prjno_code  varchar (50) 
,prjno_name  varchar (100) 
,prjno_code_chil  varchar (50) 
,prjno_name_chil  varchar (100) 
,prjno_priority  numeric (38,0)
,crr_code  varchar (50) 
,crr_name  varchar (100) 
,crr_name_bill  varchar (100) 
,crr_code_bill  varchar (50) 
,classlist_code  varchar (50) 
,custinst_starttime   timestamp(6) 
,classlist_name  varchar (100) 
,custinst_sno  varchar (40) 
,opeitm_packqty  numeric (38,0)
,loca_code_custrcvplc  varchar (50) 
,loca_code_shelfno_opeitm  varchar (50) 
,loca_name_shelfno_opeitm  varchar (100) 
,shelfno_code_opeitm  varchar (50) 
,shelfno_name_opeitm  varchar (100) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,shelfno_code_to_opeitm  varchar (50) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_code_shelfno_fm  varchar (50) 
,loca_name_shelfno_fm  varchar (100) 
,shelfno_code_fm  varchar (50) 
,shelfno_name_fm  varchar (100) 
,loca_name_custrcvplc  varchar (100) 
,person_code_chrg  varchar (50) 
,person_name_chrg  varchar (100) 
,person_name_chrg_bill  varchar (100) 
,custinst_gno  varchar (40) 
,custinst_shelfno_id_fm  numeric (22,0)
,unit_code_case_prdpur  varchar (50) 
,unit_name_case_prdpur  varchar (100) 
,opeitm_itmtype  varchar (1) 
,opeitm_shpordauto  varchar (1) 
,opeitm_prdpurordauto  varchar (1) 
,custinst_sno_custord  varchar (50) 
,custinst_packinglistno  varchar (40) 
,custinst_crr_id  numeric (22,0)
,custinst_chrg_id  numeric (38,0)
,person_name_upd  varchar (100) 
,person_code_upd  varchar (50) 
,person_name_chrg_cust  varchar (100) 
,person_code_chrg_cust  varchar (50) 
,custinst_expiredate   date 
,custinst_contents  varchar (4000) 
,custinst_remark  varchar (4000) 
,custinst_opeitm_id  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,cust_loca_id_cust  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,custinst_custrcvplc_id  numeric (38,0)
,bill_loca_id_bill  numeric (38,0)
,bill_chrg_id_bill  numeric (22,0)
,chrg_person_id_chrg  numeric (38,0)
,custrcvplc_loca_id_custrcvplc  numeric (38,0)
,custinst_prjno_id  numeric (38,0)
,itm_unit_id  numeric (22,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,chrg_person_id_chrg_bill  numeric (38,0),
opeitm_shelfno_id_opeitm  numeric (22,0)
,shelfno_loca_id_shelfno_opeitm  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,custinst_created_at   timestamp(6) 
,custinst_person_id_upd  numeric (22,0)
,custinst_id  numeric (22,0)
,custinst_updated_at   timestamp(6) 
,custinst_cust_id  numeric (22,0)
,custinst_update_ip  varchar (40) 
,custinst_packno  varchar (10) 
,custinst_lotno  varchar (50) 
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
 CREATE INDEX sio_fmcustord_custinsts_uk1 
  ON sio.sio_fmcustord_custinsts(id,sio_id); 

 drop sequence  if exists sio.sio_fmcustord_custinsts_seq ;
 create sequence sio.sio_fmcustord_custinsts_seq ;
