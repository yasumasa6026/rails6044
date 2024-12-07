
  drop view if  exists bal_purschs cascade ; 
 create or replace view bal_purschs as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.unit_name  unit_name ,
  opeitm.unit_code  unit_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_processseq  opeitm_processseq ,
  opeitm.opeitm_packqty  opeitm_packqty ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
  opeitm.opeitm_duration  opeitm_duration ,
pursch.id id,
  prjno.prjno_name  prjno_name ,
  chrg.person_sect_id_chrg  person_sect_id_chrg ,
  person_upd.code  person_code_upd ,
  person_upd.name  person_name_upd ,
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
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  crr.code  crr_code ,
  crr.name  crr_name ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  opeitm.boxe_code  boxe_code ,
  opeitm.boxe_name  boxe_name ,
  opeitm.opeitm_boxe_id  opeitm_boxe_id ,
pursch.chrgs_id   pursch_chrg_id,
pursch.starttime  pursch_starttime,
  prjno.prjno_code_chil  prjno_code_chil ,
  opeitm.opeitm_unitofduration  opeitm_unitofduration ,
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
pursch.suppliers_id   pursch_supplier_id,
pursch.gno  pursch_gno,
  shelfno_to.shelfno_code  shelfno_code_to ,
  shelfno_to.shelfno_name  shelfno_name_to ,
  shelfno_to.loca_code_shelfno  loca_code_shelfno_to ,
  shelfno_to.loca_name_shelfno  loca_name_shelfno_to ,
  shelfno_to.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_to ,
pursch.shelfnos_id_to   pursch_shelfno_id_to,
pursch.crrs_id   pursch_crr_id,
pursch.qty_sch  pursch_qty_sch,
---linktbl.qty_src linktbl_qty_sch_bal,
func_get_purprd_qty_bal('purschs',pursch.id) linktbl_qty_sch_bal,
pursch.amt_sch  pursch_amt_sch,
  prjno.prjno_name_chil  prjno_name_chil ,
  opeitm.shelfno_code_to_opeitm  shelfno_code_to_opeitm ,
  opeitm.shelfno_name_to_opeitm  shelfno_name_to_opeitm ,
  opeitm.loca_code_shelfno_to_opeitm  loca_code_shelfno_to_opeitm ,
  opeitm.loca_name_shelfno_to_opeitm  loca_name_shelfno_to_opeitm ,
  opeitm.unit_name_case_shp  unit_name_case_shp ,
  opeitm.unit_code_case_shp  unit_code_case_shp ,
  opeitm.unit_name_case_prdpur  unit_name_case_prdpur ,
  opeitm.unit_code_case_prdpur  unit_code_case_prdpur ,
  supplier.loca_code_payment_supplier  loca_code_payment_supplier ,
  supplier.loca_name_payment_supplier  loca_name_payment_supplier ,
  supplier.person_code_chrg_payment_supplier  person_code_chrg_payment_supplier ,
  supplier.person_name_chrg_payment_supplier  person_name_chrg_payment_supplier ,
  supplier.crr_code_payment_supplier  crr_code_payment_supplier ,
  supplier.crr_name_payment_supplier  crr_name_payment_supplier ,
  opeitm.opeitm_shelfno_id_opeitm  opeitm_shelfno_id_opeitm ,
  opeitm.shelfno_code_opeitm  shelfno_code_opeitm ,
  opeitm.shelfno_name_opeitm  shelfno_name_opeitm ,
  opeitm.shelfno_loca_id_shelfno_opeitm  shelfno_loca_id_shelfno_opeitm ,
  opeitm.loca_code_shelfno_opeitm  loca_code_shelfno_opeitm ,
  opeitm.loca_name_shelfno_opeitm  loca_name_shelfno_opeitm ,
pursch.itm_code_client  pursch_itm_code_client,
  opeitm.opeitm_shpordauto  opeitm_shpordauto ,
  opeitm.opeitm_prdpurordauto  opeitm_prdpurordauto ,
  opeitm.opeitm_itmtype  opeitm_itmtype ,
pursch.taxrate  pursch_taxrate,
  opeitm.itm_taxflg  itm_taxflg ,
pursch.contents  pursch_contents,
pursch.contractprice  pursch_contractprice
 from purschs   pursch,
  persons  person_upd ,  r_opeitms  opeitm ,  r_prjnos  prjno ,  r_chrgs  chrg ,  r_suppliers  supplier ,
  r_shelfnos  shelfno_to ,  crrs  crr 
  ---,linktbls link 
  where       pursch.persons_id_upd = person_upd.id      and pursch.opeitms_id = opeitm.id
 				and pursch.prjnos_id = prjno.id      and pursch.chrgs_id = chrg.id      
 				and pursch.suppliers_id = supplier.id      and pursch.shelfnos_id_to = shelfno_to.id
 			    and pursch.crrs_id = crr.id      
 			    ---and link.tblname = link.srctblname and link.tblname = 'purschs'
 			   	---and link.srctblid = link.tblid and link.srctblid = pursch.id
 			   	;
 DROP TABLE IF EXISTS sio.sio_bal_purschs;
 CREATE TABLE sio.sio_bal_purschs (
          sio_id numeric(22,0)  CONSTRAINT SIO_bal_purschs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,pursch_isudate   timestamp(6) 
,pursch_sno  varchar (50) 
,pursch_duedate   timestamp(6) 
,itm_code  varchar (50) 
,opeitm_processseq  numeric (3,0)
,itm_name  varchar (100) 
,pursch_qty_sch  numeric (22,6)
,linktbl_qty_sch_bal  numeric (22,6)
,loca_code_shelfno_opeitm  varchar (50) 
,loca_name_shelfno_opeitm  varchar (100) 
,shelfno_code_opeitm  varchar (50) 
,shelfno_name_opeitm  varchar (100) 
,loca_code_to_opeitm  varchar (50) 
,loca_name_to_opeitm  varchar (100) 
,shelfno_code_to_opeitm  varchar (50) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_code_to  varchar (50) 
,loca_name_to  varchar (100) 
,shelfno_code_to  varchar (50) 
,shelfno_name_to  varchar (100) 
,unit_code  varchar (50) 
,unit_name  varchar (100) 
,crr_code  varchar (50) 
,prjno_code  varchar (50) 
,prjno_name  varchar (100) 
,crr_name  varchar (100) 
,boxe_code  varchar (50) 
,classlist_code  varchar (50) 
,boxe_name  varchar (100) 
,pursch_starttime   timestamp(6) 
,pursch_toduedate   timestamp(6) 
,classlist_name  varchar (100) 
,pursch_expiredate   date 
,unit_code_case_shp  varchar (50) 
,person_code_chrg_supplier  varchar (50) 
,loca_code_supplier  varchar (50) 
,crr_code_payment_supplier  varchar (50) 
,opeitm_unitofduration  varchar (4) 
,prjno_code_chil  varchar (50) 
,person_code_chrg  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,loca_code_payment_supplier  varchar (50) 
,loca_code_shelfno_to  varchar (50) 
,loca_name_shelfno_to  varchar (100) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,person_code_chrg_payment_supplier  varchar (50) 
,crr_code_supplier  varchar (50) 
,unit_name_case_shp  varchar (100) 
,person_name_chrg  varchar (100) 
,crr_name_payment_supplier  varchar (100) 
,loca_name_supplier  varchar (100) 
,person_name_chrg_supplier  varchar (100) 
,crr_name_supplier  varchar (100) 
,person_name_chrg_payment_supplier  varchar (100) 
,loca_name_payment_supplier  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,prjno_name_chil  varchar (100) 
,pursch_amt_sch  numeric (38,4)
,opeitm_duration  numeric (38,2)
,pursch_price  numeric (38,4)
,opeitm_packqty  numeric (38,0)
,opeitm_priority  numeric (3,0)
,pursch_contents  varchar (4000) 
,pursch_itm_code_client  varchar (50) 
,opeitm_itmtype  varchar (1) 
,pursch_taxrate  numeric (2,0)
,pursch_supplier_id  numeric (22,0)
,pursch_gno  varchar (40) 
,itm_taxflg  varchar (20) 
,pursch_crr_id  numeric (22,0)
,pursch_contractprice  varchar (1) 
,opeitm_shpordauto  varchar (1) 
,opeitm_prdpurordauto  varchar (1) 
,pursch_tax  numeric (38,4)
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,pursch_remark  varchar (4000) 
,pursch_created_at   timestamp(6) 
,person_sect_id_chrg  numeric (22,0)
,pursch_shelfno_id_to  numeric (38,0)
,opeitm_shelfno_id_opeitm  numeric (38,0)
,opeitm_loca_id_to  numeric (38,0)
,pursch_opeitm_id  numeric (38,0)
,pursch_id  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,supplier_crr_id_supplier  numeric (22,0)
,supplier_chrg_id_supplier  numeric (22,0)
,opeitm_id_opeitm  numeric (22,0)
,supplier_loca_id_supplier  numeric (22,0)
,pursch_chrg_id  numeric (38,0)
,opeitm_loca_id_opeitm  numeric (38,0)
,itm_unit_id  numeric (22,0)
,opeitm_boxe_id  numeric (22,0)
,pursch_update_ip  varchar (40) 
,boxe_unit_id_box  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,id  numeric (38,0)
,pursch_updated_at   timestamp(6) 
,chrg_person_id_chrg  numeric (38,0)
,pursch_prjno_id  numeric (38,0)
,pursch_person_id_upd  numeric (38,0)
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
 CREATE INDEX sio_bal_purschs_uk1 
  ON sio.sio_bal_purschs(id,sio_id); 

 drop sequence  if exists sio.sio_bal_purschs_seq ;
 create sequence sio.sio_bal_purschs_seq ;
