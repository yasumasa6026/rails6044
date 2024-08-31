
  drop view if  exists gantt_nditms cascade ; 
 create or replace view gantt_nditms as select  
nditm.contents  nditm_contents,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_processseq  opeitm_processseq ,
  opeitm.opeitm_packqty  opeitm_packqty ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
nditm.parenum  nditm_parenum,
nditm.created_at  nditm_created_at,
nditm.opeitms_id   nditm_opeitm_id,
nditm.consumunitqty  nditm_consumunitqty,
nditm.persons_id_upd   nditm_person_id_upd,
nditm.updated_at  nditm_updated_at,
nditm.id  nditm_id,
nditm.remark  nditm_remark,
nditm.expiredate  nditm_expiredate,
nditm.update_ip  nditm_update_ip,
nditm.consumtype  nditm_consumtype,
  itm_nditm.itm_code  itm_code_nditm ,
  itm_nditm.itm_design  itm_design_nditm ,
  itm_nditm.itm_deth  itm_deth_nditm ,
  itm_nditm.itm_length  itm_length_nditm ,
  itm_nditm.itm_material  itm_material_nditm ,
  itm_nditm.itm_model  itm_model_nditm ,
  itm_nditm.itm_name  itm_name_nditm ,
  itm_nditm.itm_std  itm_std_nditm ,
  itm_nditm.itm_weight  itm_weight_nditm ,
nditm.itms_id_nditm   nditm_itm_id_nditm,
  itm_nditm.unit_code  unit_code_nditm ,
  itm_nditm.unit_name  unit_name_nditm ,
nditm.chilnum  nditm_chilnum,
  opeitm.opeitm_duration  opeitm_duration ,
  itm_nditm.itm_wide  itm_wide_nditm ,
nditm.id id,
  itm_nditm.itm_unit_id  itm_unit_id_nditm ,
  opeitm.opeitm_operation  opeitm_operation ,
  person_upd.code  person_code_upd ,
  person_upd.name  person_name_upd ,
  opeitm.opeitm_prdpur  opeitm_prdpur ,
  opeitm.opeitm_chkord_proc  opeitm_chkord_proc ,
  opeitm.opeitm_esttosch  opeitm_esttosch ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  opeitm.opeitm_mold  opeitm_mold ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  opeitm.boxe_code  boxe_code ,
  opeitm.boxe_name  boxe_name ,
  opeitm.opeitm_boxe_id  opeitm_boxe_id ,
nditm.processseq_nditm  nditm_processseq_nditm,
  opeitm.opeitm_prjalloc_flg  opeitm_prjalloc_flg ,
nditm.byproduct  nditm_byproduct,
nditm.consumminqty  nditm_consumminqty,
nditm.consumchgoverqty  nditm_consumchgoverqty,
  opeitm.itm_classlist_id  itm_classlist_id ,
  itm_nditm.itm_classlist_id  itm_classlist_id_nditm ,
  itm_nditm.classlist_name  classlist_name_nditm ,
  itm_nditm.classlist_code  classlist_code_nditm ,
  opeitm.shelfno_code_to_opeitm  shelfno_code_to_opeitm ,
  opeitm.shelfno_name_to_opeitm  shelfno_name_to_opeitm ,
  opeitm.loca_code_shelfno_to_opeitm  loca_code_shelfno_to_opeitm ,
  opeitm.loca_name_shelfno_to_opeitm  loca_name_shelfno_to_opeitm ,
  opeitm.unit_name_case_shp  unit_name_case_shp ,
  opeitm.unit_code_case_shp  unit_code_case_shp ,
  opeitm.unit_name_case_prdpur  unit_name_case_prdpur ,
  opeitm.unit_code_case_prdpur  unit_code_case_prdpur ,
  opeitm.opeitm_shelfno_id_opeitm  opeitm_shelfno_id_opeitm ,
  opeitm.shelfno_code_opeitm  shelfno_code_opeitm ,
  opeitm.shelfno_name_opeitm  shelfno_name_opeitm ,
  opeitm.shelfno_loca_id_shelfno_opeitm  shelfno_loca_id_shelfno_opeitm ,
  opeitm.loca_code_shelfno_opeitm  loca_code_shelfno_opeitm ,
  opeitm.loca_name_shelfno_opeitm  loca_name_shelfno_opeitm ,
  opeitm.opeitm_shpordauto  opeitm_shpordauto ,
  opeitm.opeitm_prdpurordauto  opeitm_prdpurordauto ,
  opeitm.opeitm_itmtype  opeitm_itmtype 
 from nditms   nditm,
  r_opeitms  opeitm ,  persons  person_upd ,  r_itms  itm_nditm 
  where       nditm.opeitms_id = opeitm.id      and nditm.persons_id_upd = person_upd.id      and nditm.itms_id_nditm = itm_nditm.id     ;
 DROP TABLE IF EXISTS sio.sio_gantt_nditms;
 CREATE TABLE sio.sio_gantt_nditms (
          sio_id numeric(22,0)  CONSTRAINT SIO_gantt_nditms_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,opeitm_processseq  numeric (3,0)
,opeitm_priority  numeric (3,0)
,itm_code_nditm  varchar (50) 
,itm_name_nditm  varchar (100) 
,nditm_processseq_nditm  numeric (38,0)
,nditm_parenum  numeric (38,2)
,nditm_chilnum  numeric (38,2)
,loca_code_shelfno_opeitm  varchar (50) 
,loca_name_shelfno_opeitm  varchar (100) 
,shelfno_code_opeitm  varchar (50) 
,shelfno_name_opeitm  varchar (100) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,shelfno_code_to_opeitm  varchar (50) 
,shelfno_name_to_opeitm  varchar (100) 
,opeitm_packqty  numeric (38,0)
,classlist_code_nditm  varchar (50) 
,classlist_name_nditm  varchar (100) 
,nditm_consumunitqty  numeric (38,0)
,boxe_name  varchar (100) 
,boxe_code  varchar (50) 
,nditm_expiredate   date 
,nditm_consumchgoverqty  numeric (22,6)
,nditm_consumminqty  numeric (22,6)
,nditm_byproduct  varchar (1) 
,unit_code_case_shp  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,itm_material_nditm  varchar (50) 
,opeitm_prdpur  varchar (20) 
,itm_std_nditm  varchar (50) 
,unit_code_nditm  varchar (50) 
,itm_model_nditm  varchar (50) 
,itm_design_nditm  varchar (50) 
,itm_weight_nditm  numeric (22,0)
,itm_length_nditm  numeric (22,0)
,itm_wide_nditm  numeric (22,0)
,itm_deth_nditm  numeric (22,0)
,unit_name_nditm  varchar (100) 
,unit_name_case_shp  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,classlist_code  varchar (50) 
,classlist_name  varchar (100) 
,opeitm_operation  varchar (20) 
,nditm_consumtype  varchar (20) 
,opeitm_prdpurordauto  varchar (1) 
,opeitm_itmtype  varchar (1) 
,opeitm_shpordauto  varchar (1) 
,nditm_remark  varchar (4000) 
,nditm_contents  varchar (4000) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,shelfno_loca_id_shelfno_opeitm  numeric (38,0)
,opeitm_shelfno_id_opeitm  numeric (22,0)
,nditm_opeitm_id  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,itm_unit_id  numeric (22,0)
,itm_unit_id_nditm  numeric (22,0)
,itm_classlist_id  numeric (38,0)
,opeitm_boxe_id  numeric (22,0)
,itm_classlist_id_nditm  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,nditm_update_ip  varchar (40) 
,opeitm_chkord_proc  varchar (1) 
,opeitm_esttosch  numeric (22,0)
,opeitm_mold  varchar (1) 
,opeitm_duration  numeric (38,2)
,opeitm_prjalloc_flg  numeric (22,0)
,nditm_itm_id_nditm  numeric (38,0)
,id  numeric (38,0)
,nditm_id  numeric (38,0)
,nditm_updated_at   timestamp(6) 
,nditm_person_id_upd  numeric (38,0)
,nditm_created_at   timestamp(6) 
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
 CREATE INDEX sio_gantt_nditms_uk1 
  ON sio.sio_gantt_nditms(id,sio_id); 

 drop sequence  if exists sio.sio_gantt_nditms_seq ;
 create sequence sio.sio_gantt_nditms_seq ;
