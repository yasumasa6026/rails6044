
  drop view if  exists foract_shpinsts cascade ; 
 create or replace view foract_shpinsts as select  
shpinst.packno  shpinst_packno,
case when shpinst.rcptdate is null then current_date else shpinst.rcptdate end  shpinst_rcptdate, 
shpinst.lotno shpinst_lotno, 
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  itm.itm_name  itm_name ,
  itm.itm_code  itm_code ,
  itm.unit_name  unit_name ,
  itm.unit_code  unit_code ,
  itm.itm_unit_id  itm_unit_id ,
  transport.transport_code  transport_code ,
  transport.transport_name  transport_name ,
shpinst.id id,
shpinst.tax  shpinst_tax,
shpinst.cartonno  shpinst_cartonno,
shpinst.expiredate  shpinst_expiredate,
shpinst.updated_at  shpinst_updated_at,
shpinst.sno  shpinst_sno,
shpinst.price  shpinst_price,
shpinst.itms_id   shpinst_itm_id,
shpinst.remark  shpinst_remark,
shpinst.created_at  shpinst_created_at,
shpinst.amt  shpinst_amt,
shpinst.update_ip  shpinst_update_ip,
shpinst.id  shpinst_id,
  prjno.prjno_name  prjno_name ,
  chrg.person_sect_id_chrg  person_sect_id_chrg ,
  person_upd.code  person_code_upd ,
  person_upd.name  person_name_upd ,
  prjno.prjno_code  prjno_code ,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  itm.classlist_code  classlist_code ,
  itm.classlist_name  classlist_name ,
shpinst.gno  shpinst_gno,
shpinst.isudate  shpinst_isudate,
shpinst.prjnos_id   shpinst_prjno_id,
shpinst.persons_id_upd   shpinst_person_id_upd,
shpinst.contents  shpinst_contents,
shpinst.contractprice  shpinst_contractprice,
shpinst.chrgs_id   shpinst_chrg_id,
shpinst.crrs_id   shpinst_crr_id,
shpinst.box  shpinst_box,
shpinst.cno  shpinst_cno,
shpinst.qty_case  shpinst_qty_case,
  prjno.prjno_code_chil  prjno_code_chil ,
shpinst.transports_id   shpinst_transport_id,
  itm.itm_classlist_id  itm_classlist_id ,
  shelfno_to.shelfno_code  shelfno_code_to ,
  shelfno_to.shelfno_name  shelfno_name_to ,
  shelfno_to.loca_code_shelfno  loca_code_shelfno_to ,
  shelfno_to.loca_name_shelfno  loca_name_shelfno_to ,
  shelfno_to.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_to ,
shpinst.processseq  shpinst_processseq,
shpinst.depdate  shpinst_depdate,
shpinst.paretblname  shpinst_paretblname,
shpinst.paretblid  shpinst_paretblid,
shpinst.qty_shortage  shpinst_qty_shortage,
shpinst.qty_stk  shpinst_qty_stk,
  prjno.prjno_name_chil  prjno_name_chil ,
  unit_case_shp.unit_name  unit_name_case_shp ,
  unit_case_shp.unit_code  unit_code_case_shp ,
shpinst.units_id_case_shp   shpinst_unit_id_case_shp,
shpinst.shelfnos_id_to   shpinst_shelfno_id_to,
shpinst.qty_real  shpinst_qty_real
 from shpinsts   shpinst,
  r_itms  itm ,  r_prjnos  prjno ,  persons  person_upd ,  r_chrgs  chrg ,  r_transports  transport ,  r_units  unit_case_shp ,  r_shelfnos  shelfno_to 
  where       shpinst.itms_id = itm.id      and shpinst.prjnos_id = prjno.id      and shpinst.persons_id_upd = person_upd.id      and shpinst.chrgs_id = chrg.id      and shpinst.transports_id = transport.id      and shpinst.units_id_case_shp = unit_case_shp.id      and shpinst.shelfnos_id_to = shelfno_to.id     ;
 DROP TABLE IF EXISTS sio.sio_foract_shpinsts;
 CREATE TABLE sio.sio_foract_shpinsts (
          sio_id numeric(22,0)  CONSTRAINT SIO_foract_shpinsts_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,shpinst_packno  varchar (50)
,shpinst_rcptdate  varchar (10)
,shpinst_lotno  varchar (50)
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,shpinst_sno  varchar (40) 
,prjno_code  varchar (50) 
,transport_code  varchar (50) 
,shpinst_cno  varchar (40) 
,shpinst_gno  varchar (40) 
,itm_code  varchar (50) 
,unit_code  varchar (50) 
,classlist_code  varchar (50) 
,classlist_name  varchar (100) 
,shpinst_box  varchar (50) 
,itm_name  varchar (100) 
,unit_name  varchar (100) 
,transport_name  varchar (100) 
,shpinst_tax  numeric (38,4)
,shpinst_cartonno  varchar (50) 
,shpinst_expiredate   date 
,shpinst_price  numeric (38,4)
,shpinst_amt  numeric (18,4)
,prjno_name  varchar (100) 
,shpinst_isudate   timestamp(6) 
,shpinst_contractprice  varchar (1) 
,shpinst_qty_case  numeric (22,0)
,shpinst_processseq  numeric (38,0)
,shpinst_starttime   timestamp(6) 
,shpinst_paretblname  varchar (30) 
,shpinst_paretblid  numeric (38,0)
,shpinst_qty_shortage  numeric (22,5)
,shpinst_qty_stk  numeric (22,6)
,prjno_code_chil  varchar (50) 
,shelfno_code_to  varchar (50) 
,person_code_chrg  varchar (50) 
,unit_code_case_shp  varchar (50) 
,loca_code_shelfno_to  varchar (50) 
,person_name_chrg  varchar (100) 
,loca_name_shelfno_to  varchar (100) 
,shelfno_name_to  varchar (100) 
,unit_name_case_shp  varchar (100) 
,prjno_name_chil  varchar (100) 
,shpinst_shelfno_id_to  numeric (38,0)
,shpinst_unit_id_case_shp  numeric (38,0)
,shpinst_depdate   timestamp(6) 
,shpinst_qty_real  numeric (38,0)
,shpinst_contents  varchar (4000) 
,shpinst_remark  varchar (4000) 
,shpinst_created_at   timestamp(6) 
,shpinst_updated_at   timestamp(6) 
,itm_unit_id  numeric (22,0)
,shpinst_crr_id  numeric (22,0)
,shpinst_prjno_id  numeric (38,0)
,shpinst_person_id_upd  numeric (38,0)
,shpinst_chrg_id  numeric (38,0)
,shpinst_transport_id  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,shpinst_update_ip  varchar (40) 
,shpinst_id  numeric (38,0)
,person_sect_id_chrg  numeric (22,0)
,shpinst_itm_id  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,id  numeric (38,0)
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
 CREATE INDEX sio_foract_shpinsts_uk1 
  ON sio.sio_foract_shpinsts(id,sio_id); 

 drop sequence  if exists sio.sio_foract_shpinsts_seq ;
 create sequence sio.sio_foract_shpinsts_seq ;
