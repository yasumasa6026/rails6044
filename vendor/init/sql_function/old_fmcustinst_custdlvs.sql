
  drop view if  exists fmcustinst_custdlvs cascade ; 
 create or replace view fmcustinst_custdlvs as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.unit_name  unit_name ,
  opeitm.unit_code  unit_code ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
  cust.loca_name_cust  loca_name_cust ,
  cust.loca_code_cust  loca_code_cust ,
  custrcvplc.loca_code_custrcvplc  loca_code_custrcvplc ,
  custrcvplc.loca_name_custrcvplc  loca_name_custrcvplc ,
'' id,
  cust.cust_loca_id_cust  cust_loca_id_cust ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  custrcvplc.custrcvplc_loca_id_custrcvplc  custrcvplc_loca_id_custrcvplc ,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  cust.person_code_chrg_cust  person_code_chrg_cust ,
  cust.person_name_chrg_cust  person_name_chrg_cust ,
  cust.person_sect_id_chrg_cust  person_sect_id_chrg_cust ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  cust.bill_loca_id_bill  bill_loca_id_bill ,
  cust.loca_code_bill  loca_code_bill ,
  cust.loca_name_bill  loca_name_bill ,
  cust.cust_bill_id  cust_bill_id ,
  cust.crr_name_cust  crr_name_cust ,
  cust.crr_code_cust  crr_code_cust ,
  ''  boxe_code_custdlv ,
  ''  boxe_name_custdlv ,
  ''  boxe_width_custdlv ,
  ''  boxe_heigh_custdlv ,
  ''  boxe_depth_custdlv ,
  0  custdlv_boxe_id_custdlv ,
  ''  custdlv_dimension ,
  opeitm.opeitm_unitofduration  opeitm_unitofduration ,
  cust.bill_chrg_id_bill  bill_chrg_id_bill ,
  cust.person_code_chrg_bill  person_code_chrg_bill ,
  cust.person_name_chrg_bill  person_name_chrg_bill ,
  opeitm.itm_classlist_id  itm_classlist_id ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
  cust.person_sect_id_chrg_bill  person_sect_id_chrg_bill ,
  cust.chrg_person_id_chrg_bill  chrg_person_id_chrg_bill ,
  cust.crr_code_bill  crr_code_bill ,
  cust.crr_name_bill  crr_name_bill ,
custinst.custs_id   custdlv_cust_id,
custinst.itm_code_client  custdlv_itm_code_client,
custinst.cno  custdlv_cno,
custinst.custrcvplcs_id   custdlv_custrcvplc_id,
''  custdlv_id,
custinst.gno  custdlv_gno,
custinst.contract_price  custdlv_contract_price,
custinst.starttime  custdlv_starttime,
custinst.price  custdlv_price,
custinst.expiredate  custdlv_expiredate,
custinst.amt  custdlv_amt,
current_date  custdlv_isudate,
''  custdlv_sno,
''  custdlv_remark,
custinst.persons_id_upd   custdlv_person_id_upd,
custinst.update_ip  custdlv_update_ip,
current_timestamp  custdlv_created_at,
current_timestamp  custdlv_updated_at,
link.shelfnos_id   custdlv_shelfno_id_fm,
custinst.opeitms_id   custdlv_opeitm_id,
custinst.sno  custdlv_sno_custinst,
custinst.cno  custdlv_cno_custinst,
current_date  custdlv_depdate,
''  custdlv_cartonno,
link.qty_stk  custdlv_qty_stk,
0  custdlv_qty_case,
''  custdlv_invoiceno,
custinst.chrgs_id   custdlv_chrg_id,
link.lotno custdlv_lotno,
  opeitm.opeitm_shelfno_id_opeitm  opeitm_shelfno_id_opeitm ,
  opeitm.shelfno_code_opeitm  shelfno_code_opeitm ,
  opeitm.shelfno_name_opeitm  shelfno_name_opeitm ,
  opeitm.shelfno_loca_id_shelfno_opeitm  shelfno_loca_id_shelfno_opeitm ,
  opeitm.loca_code_shelfno_opeitm  loca_code_shelfno_opeitm ,
  opeitm.loca_name_shelfno_opeitm  loca_name_shelfno_opeitm ,
  opeitm.opeitm_shpordauto  opeitm_shpordauto ,
  opeitm.opeitm_prdpurordauto  opeitm_prdpurordauto ,
  opeitm.opeitm_itmtype  opeitm_itmtype ,
0  custdlv_weight,
0  custdlv_unit_id_weight,
''  custdlv_unit_code_weight,
''  custdlv_unit_name_weight,
link.packno  custdlv_packno
 from r_custs  cust ,  r_custrcvplcs  custrcvplc ,  r_persons  person_upd ,  r_shelfnos  shelfno_fm ,
  r_opeitms  opeitm ,  r_chrgs  chrg , 
  custinsts   custinst
  inner join (select link.tblname,link.tblid,qty_stk,shelfnos_id,lotno,packno 
  					from linkcusts link , func_get_custord_lotno_packno(link.srctblid)
  					where link.srctblname = 'custords') link 
			on link.tblid = custinst.id and link.tblname = 'custinsts' 
  where       custinst.custs_id = cust.id      and custinst.custrcvplcs_id = custrcvplc.id     
 	and custinst.persons_id_upd = person_upd.id      and link.shelfnos_id = shelfno_fm.id      
 	and custinst.opeitms_id = opeitm.id      and custinst.chrgs_id = chrg.id    
 	and exists(select 1 from linkcusts link where tblname = 'custinsts' and tblid = custinst.id and qty_src > 0)
	  
;
 DROP TABLE IF EXISTS sio.sio_r_custdlvs;
 CREATE TABLE sio.sio_r_custdlvs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_custdlvs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,unit_code  varchar (50) 
,boxe_code_custdlv  varchar (50)
,boxe_name_custdlv  varchar (100)  
,boxe_width_custdlv  varchar (20)  
,boxe_heigh_custdlv  varchar (20)  
,boxe_depth_custdlv  varchar (20)  
,itm_code  varchar (50) 
,classlist_code  varchar (50) 
,unit_name  varchar (100) 
,custdlv_lotno  varchar (50) 
,itm_name  varchar (100) 
,classlist_name  varchar (100) 
,shelfno_code_opeitm  varchar (50) 
,loca_code_custrcvplc  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,crr_code_bill  varchar (50) 
,crr_code_cust  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,person_code_chrg_cust  varchar (50) 
,unit_code_case_shp  varchar (50) 
,unit_code_outbox_custdlv  varchar (50) 
,person_code_chrg_bill  varchar (50) 
,person_code_chrg  varchar (50) 
,loca_code_shelfno_opeitm  varchar (50) 
,loca_code_bill  varchar (50) 
,loca_code_cust  varchar (50) 
,unit_code_box_custdlv  varchar (50) 
,shelfno_code_fm  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,unit_name_case_prdpur  varchar (100) 
,unit_name_case_shp  varchar (100) 
,person_name_chrg  varchar (100) 
,loca_name_cust  varchar (100) 
,loca_name_custrcvplc  varchar (100) 
,unit_name_outbox_custdlv  varchar (100) 
,person_name_chrg_cust  varchar (100) 
,unit_name_box_custdlv  varchar (100) 
,loca_name_bill  varchar (100) 
,crr_name_cust  varchar (100) 
,loca_name_shelfno_opeitm  varchar (100) 
,person_name_chrg_bill  varchar (100) 
,shelfno_name_opeitm  varchar (100) 
,shelfno_name_fm  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,crr_name_bill  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,custdlv_custrcvplc_id  numeric (38,0)
,custdlv_cust_id  numeric (38,0)
,custdlv_gno  varchar (40) 
,custdlv_contract_price  varchar (1) 
,custdlv_starttime   timestamp(6) 
,custdlv_price  numeric (38,4)
,custdlv_expiredate   date 
,custdlv_amt  numeric (18,4)
,custdlv_isudate   timestamp(6) 
,custdlv_sno  varchar (40) 
,custdlv_remark  varchar (4000) 
,opeitm_priority  numeric (3,0)
,custdlv_update_ip  varchar (40) 
,custdlv_created_at   timestamp(6) 
,custdlv_updated_at   timestamp(6) 
,custdlv_shelfno_id_fm  numeric (22,0)
,custdlv_opeitm_id  numeric (38,0)
,id  numeric (38,0)
,custdlv_itm_code_client  varchar (50) 
,custdlv_cno  varchar (40) 
,custdlv_packno  varchar (10) 
,opeitm_unitofduration  varchar (4) 
,custdlv_id  numeric (38,0)
,custdlv_sno_custinst  varchar (50) 
,custdlv_cno_custinst  varchar (50) 
,custdlv_depdate   timestamp(6) 
,custdlv_cartonno  varchar (50) 
,custdlv_qty_stk  numeric (22,6)
,custdlv_qty_case  numeric (22,0)
,custdlv_invoiceno  varchar (50) 
,custdlv_chrg_id  numeric (38,0)
,opeitm_shpordauto  varchar (1) 
,opeitm_prdpurordauto  varchar (1) 
,opeitm_itmtype  varchar (1) 
,custdlv_dimension  varchar (20) 
,custdlv_boxe_id_custdlv  numeric (38,0)
,custdlv_weight  numeric (7,2)
,custdlv_unit_id_weight   numeric (38,0)
,custdlv_unit_code_weight varchar(3)
,custdlv_unit_name_weight varchar(50)
,opeitm_shelfno_id_opeitm  numeric (22,0)
,itm_classlist_id  numeric (38,0)
,shelfno_loca_id_shelfno_opeitm  numeric (38,0)
,bill_chrg_id_bill  numeric (22,0)
,person_sect_id_chrg_cust  numeric (22,0)
,opeitm_unit_id_case_shp  numeric (38,0)
,opeitm_unit_id_case_prdpur  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,chrg_person_id_chrg_bill  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,custrcvplc_loca_id_custrcvplc  numeric (38,0)
,cust_loca_id_cust  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,cust_bill_id  numeric (38,0)
,bill_loca_id_bill  numeric (38,0)
,person_sect_id_chrg_bill  numeric (22,0)
,custdlv_person_id_upd  numeric (22,0)
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
 CREATE INDEX sio_r_custdlvs_uk1 
  ON sio.sio_r_custdlvs(id,sio_id); 

 drop sequence  if exists sio.sio_r_custdlvs_seq ;
 create sequence sio.sio_r_custdlvs_seq ;