
 alter table opeitms  ADD COLUMN prdpur varchar(5);

 alter table opeitms DROP COLUMN prdpurshp CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'prdpurshp'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　prdpurshpが削除　2022-03-04 16:11:10 +0900' 
 ---- where  pobject_code_sfd = 'prdpurshp'
  drop view if  exists r_opeitms cascade ; 
 create or replace view r_opeitms as select  
  itm.itm_name  itm_name ,
  itm.itm_std  itm_std ,
  itm.itm_code  itm_code ,
  itm.unit_name  unit_name ,
  itm.unit_code  unit_code ,
  itm.itm_unit_id  itm_unit_id ,
opeitm.processseq  opeitm_processseq,
opeitm.expiredate  opeitm_expiredate,
opeitm.persons_id_upd   opeitm_person_id_upd,
opeitm.update_ip  opeitm_update_ip,
opeitm.updated_at  opeitm_updated_at,
opeitm.packqty  opeitm_packqty,
opeitm.priority  opeitm_priority,
opeitm.created_at  opeitm_created_at,
opeitm.itms_id   opeitm_itm_id,
opeitm.id  opeitm_id,
opeitm.duration  opeitm_duration,
opeitm.id id,
opeitm.remark  opeitm_remark,
opeitm.operation  opeitm_operation,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
opeitm.maxqty  opeitm_maxqty,
opeitm.autocreate_inst  opeitm_autocreate_inst,
opeitm.prdpur  opeitm_prdpur,
opeitm.safestkqty  opeitm_safestkqty,
opeitm.contents  opeitm_contents,
opeitm.autocreate_act  opeitm_autocreate_act,
opeitm.shuffle_flg  opeitm_shuffle_flg,
opeitm.shuffle_loca  opeitm_shuffle_loca,
opeitm.chkord_proc  opeitm_chkord_proc,
opeitm.esttosch  opeitm_esttosch,
  itm.classlist_code  classlist_code ,
  itm.classlist_name  classlist_name ,
opeitm.rule_price  opeitm_rule_price,
opeitm.mold  opeitm_mold,
  boxe.boxe_boxtype  boxe_boxtype ,
  boxe.boxe_unit_id_box  boxe_unit_id_box ,
  boxe.unit_code_box  unit_code_box ,
  boxe.unit_name_box  unit_name_box ,
  boxe.boxe_unit_id_outbox  boxe_unit_id_outbox ,
  boxe.unit_code_outbox  unit_code_outbox ,
  boxe.unit_name_outbox  unit_name_outbox ,
  boxe.boxe_code  boxe_code ,
  boxe.boxe_name  boxe_name ,
opeitm.boxes_id   opeitm_boxe_id,
opeitm.prjalloc_flg  opeitm_prjalloc_flg,
opeitm.units_lttime  opeitm_units_lttime,
opeitm.consumauto  opeitm_consumauto,
opeitm.autoinst_p  opeitm_autoinst_p,
opeitm.autoact_p  opeitm_autoact_p,
  itm.itm_classlist_id  itm_classlist_id ,
opeitm.stktaking_proc  opeitm_stktaking_proc,
opeitm.acceptance_proc  opeitm_acceptance_proc,
opeitm.lotno_proc  opeitm_lotno_proc,
opeitm.chkinst_proc  opeitm_chkinst_proc,
opeitm.packno_proc  opeitm_packno_proc,
opeitm.locas_id_opeitm   opeitm_loca_id_opeitm,
  loca_opeitm.loca_code  loca_code_opeitm ,
  loca_opeitm.loca_name  loca_name_opeitm ,
opeitm.optfixoterm  opeitm_optfixoterm,
opeitm.optfixflg  opeitm_optfixflg,
opeitm.shelfnos_id_fm_opeitm   opeitm_shelfno_id_fm_opeitm,
  shelfno_fm_opeitm.shelfno_code  shelfno_code_fm_opeitm ,
  shelfno_fm_opeitm.shelfno_name  shelfno_name_fm_opeitm ,
  shelfno_fm_opeitm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm_opeitm ,
  shelfno_fm_opeitm.loca_code_shelfno  loca_code_shelfno_fm_opeitm ,
  shelfno_fm_opeitm.loca_name_shelfno  loca_name_shelfno_fm_opeitm ,
opeitm.shelfnos_id_to_opeitm   opeitm_shelfno_id_to_opeitm,
  shelfno_to_opeitm.shelfno_code  shelfno_code_to_opeitm ,
  shelfno_to_opeitm.shelfno_name  shelfno_name_to_opeitm ,
  shelfno_to_opeitm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_to_opeitm ,
  shelfno_to_opeitm.loca_code_shelfno  loca_code_shelfno_to_opeitm ,
  shelfno_to_opeitm.loca_name_shelfno  loca_name_shelfno_to_opeitm ,
opeitm.units_id_case_shp   opeitm_unit_id_case_shp,
  unit_case_shp.unit_name  unit_name_case_shp ,
  unit_case_shp.unit_code  unit_code_case_shp ,
opeitm.units_id_case_prdpur   opeitm_unit_id_case_prdpur,
  unit_case_prdpur.unit_name  unit_name_case_prdpur ,
  unit_case_prdpur.unit_code  unit_code_case_prdpur 
 from opeitms   opeitm,
  r_persons  person_upd ,  r_itms  itm ,  r_boxes  boxe ,  r_locas  loca_opeitm ,  r_shelfnos  shelfno_fm_opeitm ,  r_shelfnos  shelfno_to_opeitm ,  r_units  unit_case_shp ,  r_units  unit_case_prdpur 
  where       opeitm.persons_id_upd = person_upd.id      and opeitm.itms_id = itm.id      and opeitm.boxes_id = boxe.id      and opeitm.locas_id_opeitm = loca_opeitm.id      and opeitm.shelfnos_id_fm_opeitm = shelfno_fm_opeitm.id      and opeitm.shelfnos_id_to_opeitm = shelfno_to_opeitm.id      and opeitm.units_id_case_shp = unit_case_shp.id      and opeitm.units_id_case_prdpur = unit_case_prdpur.id     ;
 DROP TABLE IF EXISTS sio.sio_r_opeitms;
 CREATE TABLE sio.sio_r_opeitms (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_opeitms_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,opeitm_processseq  numeric (3,0)
,itm_name  varchar (100) 
,opeitm_packqty  numeric (38,0)
,opeitm_maxqty  numeric (22,0)
,opeitm_duration  numeric (38,2)
,opeitm_autoinst_p  numeric (3,0)
,unit_code  varchar (50) 
,unit_name  varchar (100) 
,boxe_code  varchar (50) 
,boxe_name  varchar (100) 
,unit_code_box  varchar (50) 
,unit_name_box  varchar (100) 
,unit_code_outbox  varchar (50) 
,unit_name_outbox  varchar (100) 
,classlist_code  varchar (50) 
,classlist_name  varchar (100) 
,opeitm_stktaking_proc  varchar (1) 
,opeitm_acceptance_proc  varchar (30) 
,opeitm_autocreate_act  varchar (1) 
,opeitm_shuffle_flg  varchar (1) 
,opeitm_autocreate_inst  varchar (1) 
,opeitm_units_lttime  varchar (4) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,itm_std  varchar (50) 
,opeitm_esttosch  numeric (22,0)
,unit_code_case_shp  varchar (50) 
,loca_code_opeitm  varchar (50) 
,opeitm_mold  varchar (1) 
,unit_name_case_shp  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,loca_name_opeitm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,opeitm_chkord_proc  numeric (3,0)
,opeitm_priority  numeric (3,0)
,opeitm_operation  varchar (20) 
,opeitm_prdpur  varchar (20) 
,opeitm_safestkqty  numeric (38,0)
,opeitm_shuffle_loca  varchar (1) 
,opeitm_rule_price  varchar (1) 
,opeitm_prjalloc_flg  numeric (22,0)
,opeitm_autoact_p  numeric (3,0)
,opeitm_lotno_proc  varchar (3) 
,opeitm_chkinst_proc  varchar (1) 
,opeitm_packno_proc  varchar (1) 
,opeitm_consumauto  varchar (1) 
,opeitm_optfixoterm  numeric (5,2)
,opeitm_optfixflg  varchar (1) 
,opeitm_shelfno_id_fm_opeitm  numeric (22,0)
,opeitm_unit_id_case_shp  numeric (38,0)
,opeitm_unit_id_case_prdpur  numeric (38,0)
,opeitm_shelfno_id_to_opeitm  numeric (38,0)
,opeitm_loca_id_opeitm  numeric (22,0)
,opeitm_expiredate   date 
,boxe_boxtype  varchar (20) 
,opeitm_contents  varchar (4000) 
,opeitm_remark  varchar (4000) 
,opeitm_itm_id  numeric (38,0)
,opeitm_created_at   timestamp(6) 
,opeitm_person_id_upd  numeric (38,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,opeitm_update_ip  varchar (40) 
,opeitm_id  numeric (38,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,itm_unit_id  numeric (22,0)
,boxe_unit_id_outbox  numeric (38,0)
,id  numeric (22,0)
,person_code_upd  varchar (50) 
,opeitm_boxe_id  numeric (22,0)
,person_name_upd  varchar (100) 
,opeitm_updated_at   timestamp 
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
 CREATE INDEX sio_r_opeitms_uk1 
  ON sio.sio_r_opeitms(id,sio_id); 

 drop sequence  if exists sio.sio_r_opeitms_seq ;
 create sequence sio.sio_r_opeitms_seq ;
  drop view if  exists r_nditms cascade ; 
 create or replace view r_nditms as select  
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
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  opeitm.opeitm_prdpur  opeitm_prdpur ,
  opeitm.opeitm_chkord_proc  opeitm_chkord_proc ,
  opeitm.opeitm_esttosch  opeitm_esttosch ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  opeitm.opeitm_mold  opeitm_mold ,
  crr.crr_code  crr_code ,
  crr.crr_name  crr_name ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  opeitm.boxe_unit_id_outbox  boxe_unit_id_outbox ,
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
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
nditm.price  nditm_price,
nditm.crrs_id   nditm_crr_id,
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
nditm.shelfnos_id_fm   nditm_shelfno_id_fm
 from nditms   nditm,
  r_opeitms  opeitm ,  r_persons  person_upd ,  r_itms  itm_nditm ,  r_crrs  crr ,  r_shelfnos  shelfno_fm 
  where       nditm.opeitms_id = opeitm.id      and nditm.persons_id_upd = person_upd.id      and nditm.itms_id_nditm = itm_nditm.id      and nditm.crrs_id = crr.id      and nditm.shelfnos_id_fm = shelfno_fm.id     ;
 DROP TABLE IF EXISTS sio.sio_r_nditms;
 CREATE TABLE sio.sio_r_nditms (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_nditms_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,nditm_parenum  numeric (38,0)
,nditm_chilnum  numeric (38,0)
,opeitm_packqty  numeric (38,0)
,nditm_consumunitqty  numeric (38,0)
,classlist_code_nditm  varchar (50) 
,crr_name  varchar (100) 
,boxe_code  varchar (50) 
,classlist_name  varchar (100) 
,classlist_code  varchar (50) 
,boxe_name  varchar (100) 
,crr_code  varchar (50) 
,classlist_name_nditm  varchar (100) 
,nditm_expiredate   date 
,nditm_byproduct  varchar (1) 
,nditm_price  numeric (38,4)
,nditm_consumchgoverqty  numeric (22,6)
,nditm_consumminqty  numeric (22,6)
,unit_code_case_prdpur  varchar (50) 
,loca_code_opeitm  varchar (50) 
,opeitm_prdpur  varchar (20) 
,itm_material_nditm  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,unit_code_case_shp  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,shelfno_code_fm  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,itm_std_nditm  varchar (50) 
,unit_code_nditm  varchar (50) 
,itm_model_nditm  varchar (50) 
,itm_design_nditm  varchar (50) 
,itm_weight_nditm  numeric (22,0)
,itm_length_nditm  numeric (22,0)
,itm_wide_nditm  numeric (22,0)
,itm_deth_nditm  numeric (22,0)
,unit_name_nditm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,unit_name_case_shp  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,shelfno_name_fm  varchar (100) 
,loca_name_opeitm  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,nditm_shelfno_id_fm  numeric (22,0)
,nditm_contents  varchar (4000) 
,nditm_remark  varchar (4000) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,nditm_opeitm_id  numeric (38,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,nditm_crr_id  numeric (22,0)
,opeitm_loca_id_opeitm  numeric (22,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,itm_unit_id_nditm  numeric (22,0)
,opeitm_boxe_id  numeric (22,0)
,itm_classlist_id  numeric (38,0)
,itm_classlist_id_nditm  numeric (38,0)
,boxe_unit_id_outbox  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,itm_unit_id  numeric (22,0)
,opeitm_prjalloc_flg  numeric (22,0)
,nditm_itm_id_nditm  numeric (38,0)
,nditm_update_ip  varchar (40) 
,opeitm_operation  varchar (20) 
,nditm_id  numeric (38,0)
,opeitm_chkord_proc  numeric (3,0)
,nditm_updated_at   timestamp(6) 
,nditm_person_id_upd  numeric (38,0)
,opeitm_esttosch  numeric (22,0)
,nditm_created_at   timestamp(6) 
,opeitm_mold  varchar (1) 
,id  numeric (38,0)
,opeitm_duration  numeric (38,2)
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
 CREATE INDEX sio_r_nditms_uk1 
  ON sio.sio_r_nditms(id,sio_id); 

 drop sequence  if exists sio.sio_r_nditms_seq ;
 create sequence sio.sio_r_nditms_seq ;
