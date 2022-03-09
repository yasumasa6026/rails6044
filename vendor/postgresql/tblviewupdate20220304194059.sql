
 alter table prdords  ADD COLUMN commencementdate timestamp(6);

 alter table  prdords  ADD COLUMN crrs_id numeric(22,0)  DEFAULT 0  not null;

 alter table prdords DROP COLUMN crrs_id_prdord CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'crrs_id_prdord'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　crrs_id_prdordが削除　2022-03-04 19:40:49 +0900' 
 ---- where  pobject_code_sfd = 'crrs_id_prdord'
 alter table prdords DROP COLUMN gno_prdsch CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'gno_prdsch'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　gno_prdschが削除　2022-03-04 19:40:49 +0900' 
 ---- where  pobject_code_sfd = 'gno_prdsch'
 alter table prdords DROP COLUMN sno_prdsch CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'sno_prdsch'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　sno_prdschが削除　2022-03-04 19:40:49 +0900' 
 ---- where  pobject_code_sfd = 'sno_prdsch'
  drop view if  exists r_prdschs cascade ; 
 create or replace view r_prdschs as select  
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
prdsch.id id,
  prjno.prjno_name  prjno_name ,
  chrg.person_sect_id_chrg  person_sect_id_chrg ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
prdsch.id  prdsch_id,
prdsch.remark  prdsch_remark,
prdsch.expiredate  prdsch_expiredate,
prdsch.update_ip  prdsch_update_ip,
prdsch.created_at  prdsch_created_at,
prdsch.updated_at  prdsch_updated_at,
prdsch.persons_id_upd   prdsch_person_id_upd,
prdsch.sno  prdsch_sno,
prdsch.duedate  prdsch_duedate,
prdsch.toduedate  prdsch_toduedate,
prdsch.isudate  prdsch_isudate,
prdsch.opeitms_id   prdsch_opeitm_id,
  prjno.prjno_code  prjno_code ,
prdsch.prjnos_id   prdsch_prjno_id,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  opeitm.unit_code_box  unit_code_box ,
  opeitm.unit_name_box  unit_name_box ,
  opeitm.boxe_unit_id_outbox  boxe_unit_id_outbox ,
  opeitm.unit_code_outbox  unit_code_outbox ,
  opeitm.unit_name_outbox  unit_name_outbox ,
  opeitm.boxe_code  boxe_code ,
  opeitm.boxe_name  boxe_name ,
  opeitm.opeitm_boxe_id  opeitm_boxe_id ,
prdsch.chrgs_id   prdsch_chrg_id,
prdsch.starttime  prdsch_starttime,
  prjno.prjno_code_chil  prjno_code_chil ,
  opeitm.itm_classlist_id  itm_classlist_id ,
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
  workplace.workplace_loca_id_workplace  workplace_loca_id_workplace ,
  workplace.loca_code_workplace  loca_code_workplace ,
  workplace.loca_name_workplace  loca_name_workplace ,
prdsch.gno  prdsch_gno,
prdsch.shelfnos_id_to   prdsch_shelfno_id_to,
  workplace.workplace_chrg_id_workplace  workplace_chrg_id_workplace ,
  workplace.person_code_chrg_workplace  person_code_chrg_workplace ,
  workplace.person_name_chrg_workplace  person_name_chrg_workplace ,
  workplace.person_sect_id_chrg_workplace  person_sect_id_chrg_workplace ,
  workplace.chrg_person_id_chrg_workplace  chrg_person_id_chrg_workplace ,
prdsch.workplaces_id   prdsch_workplace_id,
prdsch.qty_sch  prdsch_qty_sch,
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
prdsch.shelfnos_id_fm   prdsch_shelfno_id_fm
 from prdschs   prdsch,
  r_persons  person_upd ,  r_opeitms  opeitm ,  r_prjnos  prjno ,  r_chrgs  chrg ,  r_shelfnos  shelfno_to ,  r_workplaces  workplace ,  r_shelfnos  shelfno_fm 
  where       prdsch.persons_id_upd = person_upd.id      and prdsch.opeitms_id = opeitm.id      and prdsch.prjnos_id = prjno.id      and prdsch.chrgs_id = chrg.id      and prdsch.shelfnos_id_to = shelfno_to.id      and prdsch.workplaces_id = workplace.id      and prdsch.shelfnos_id_fm = shelfno_fm.id     ;
 DROP TABLE IF EXISTS sio.sio_r_prdschs;
 CREATE TABLE sio.sio_r_prdschs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_prdschs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,prdsch_sno  varchar (40) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,prdsch_duedate   timestamp(6) 
,opeitm_processseq  numeric (3,0)
,opeitm_priority  numeric (3,0)
,loca_code_workplace  varchar (50) 
,loca_name_workplace  varchar (100) 
,unit_code  varchar (50) 
,boxe_code  varchar (50) 
,classlist_code  varchar (50) 
,loca_code_shelfno_to  varchar (50) 
,loca_name_shelfno_to  varchar (100) 
,shelfno_code_to  varchar (50) 
,shelfno_name_to  varchar (100) 
,prdsch_toduedate   timestamp(6) 
,person_code_chrg  varchar (50) 
,person_name_chrg  varchar (100) 
,prjno_code  varchar (50) 
,prjno_name  varchar (100) 
,unit_name  varchar (100) 
,classlist_name  varchar (100) 
,prdsch_expiredate   date 
,boxe_name  varchar (100) 
,unit_code_box  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,unit_code_case_shp  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,loca_code_opeitm  varchar (50) 
,unit_code_outbox  varchar (50) 
,person_code_chrg_workplace  varchar (50) 
,shelfno_code_fm  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,unit_name_outbox  varchar (100) 
,shelfno_name_fm  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,prjno_name_chil  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,person_name_chrg_workplace  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,unit_name_case_shp  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,loca_name_opeitm  varchar (100) 
,unit_name_box  varchar (100) 
,prdsch_isudate   timestamp(6) 
,prdsch_starttime   timestamp(6) 
,prdsch_qty_sch  numeric (22,6)
,prdsch_shelfno_id_fm  numeric (22,0)
,prjno_code_chil  varchar (50) 
,prdsch_gno  varchar (40) 
,prdsch_remark  varchar (4000) 
,itm_unit_id  numeric (22,0)
,prdsch_shelfno_id_to  numeric (38,0)
,workplace_chrg_id_workplace  numeric (22,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,person_sect_id_chrg_workplace  numeric (22,0)
,chrg_person_id_chrg_workplace  numeric (38,0)
,prdsch_workplace_id  numeric (22,0)
,prdsch_chrg_id  numeric (38,0)
,opeitm_boxe_id  numeric (22,0)
,opeitm_loca_id_opeitm  numeric (22,0)
,boxe_unit_id_outbox  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,prdsch_prjno_id  numeric (38,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,prdsch_opeitm_id  numeric (38,0)
,prdsch_person_id_upd  numeric (38,0)
,prdsch_updated_at   timestamp(6) 
,prdsch_created_at   timestamp(6) 
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,prdsch_update_ip  varchar (40) 
,prdsch_id  numeric (38,0)
,person_sect_id_chrg  numeric (22,0)
,id  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,workplace_loca_id_workplace  numeric (22,0)
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
 CREATE INDEX sio_r_prdschs_uk1 
  ON sio.sio_r_prdschs(id,sio_id); 

 drop sequence  if exists sio.sio_r_prdschs_seq ;
 create sequence sio.sio_r_prdschs_seq ;
  drop view if  exists r_prdacts cascade ; 
 create or replace view r_prdacts as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.unit_name  unit_name ,
  opeitm.unit_code  unit_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
prdact.id id,
  prjno.prjno_name  prjno_name ,
  chrg.person_sect_id_chrg  person_sect_id_chrg ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  prjno.prjno_code  prjno_code ,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
prdact.remark  prdact_remark,
prdact.created_at  prdact_created_at,
prdact.update_ip  prdact_update_ip,
prdact.id  prdact_id,
prdact.persons_id_upd   prdact_person_id_upd,
prdact.contents  prdact_contents,
prdact.cmpldate  prdact_cmpldate,
prdact.chrgs_id   prdact_chrg_id,
prdact.isudate  prdact_isudate,
prdact.prjnos_id   prdact_prjno_id,
prdact.opeitms_id   prdact_opeitm_id,
prdact.expiredate  prdact_expiredate,
prdact.updated_at  prdact_updated_at,
prdact.sno  prdact_sno,
prdact.cno  prdact_cno,
prdact.gno  prdact_gno,
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
prdact.lotno  prdact_lotno,
  prjno.prjno_code_chil  prjno_code_chil ,
  opeitm.itm_classlist_id  itm_classlist_id ,
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
  workplace.workplace_loca_id_workplace  workplace_loca_id_workplace ,
  workplace.loca_code_workplace  loca_code_workplace ,
  workplace.loca_name_workplace  loca_name_workplace ,
prdact.shelfnos_id_to   prdact_shelfno_id_to,
prdact.qty_stk  prdact_qty_stk,
prdact.sno_prdord  prdact_sno_prdord,
prdact.sno_prdinst  prdact_sno_prdinst,
prdact.cno_prdinst  prdact_cno_prdinst,
  workplace.workplace_chrg_id_workplace  workplace_chrg_id_workplace ,
  workplace.person_code_chrg_workplace  person_code_chrg_workplace ,
  workplace.person_name_chrg_workplace  person_name_chrg_workplace ,
  workplace.person_sect_id_chrg_workplace  person_sect_id_chrg_workplace ,
  workplace.chrg_person_id_chrg_workplace  chrg_person_id_chrg_workplace ,
prdact.workplaces_id   prdact_workplace_id,
prdact.packno  prdact_packno,
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
prdact.shelfnos_id_fm   prdact_shelfno_id_fm,
prdact.crrs_id   prdact_crr_id
 from prdacts   prdact,
  r_persons  person_upd ,  r_chrgs  chrg ,  r_prjnos  prjno ,  r_opeitms  opeitm ,  r_shelfnos  shelfno_to ,  r_workplaces  workplace ,  r_shelfnos  shelfno_fm ,  r_crrs  crr 
  where       prdact.persons_id_upd = person_upd.id      and prdact.chrgs_id = chrg.id      and prdact.prjnos_id = prjno.id      and prdact.opeitms_id = opeitm.id      and prdact.shelfnos_id_to = shelfno_to.id      and prdact.workplaces_id = workplace.id      and prdact.shelfnos_id_fm = shelfno_fm.id      and prdact.crrs_id = crr.id     ;
 DROP TABLE IF EXISTS sio.sio_r_prdacts;
 CREATE TABLE sio.sio_r_prdacts (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_prdacts_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,prdact_sno_prdord  varchar (50) 
,prdact_isudate   timestamp(6) 
,loca_code_workplace  varchar (50) 
,person_code_upd  varchar (50) 
,loca_name_workplace  varchar (100) 
,person_name_upd  varchar (100) 
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,prdact_qty_stk  numeric (22,6)
,prdact_cmpldate   timestamp(6) 
,loca_code_shelfno_to  varchar (50) 
,loca_name_shelfno_to  varchar (100) 
,prdact_gno  varchar (40) 
,prdact_sno  varchar (40) 
,prjno_code  varchar (50) 
,boxe_code  varchar (50) 
,classlist_code  varchar (50) 
,prdact_cno  varchar (40) 
,crr_code  varchar (50) 
,unit_code  varchar (50) 
,prdact_cno_prdinst  varchar (50) 
,unit_name  varchar (100) 
,prjno_name  varchar (100) 
,classlist_name  varchar (100) 
,prdact_expiredate   date 
,crr_name  varchar (100) 
,boxe_name  varchar (100) 
,prdact_lotno  varchar (50) 
,prdact_sno_prdinst  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,unit_code_box  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,prjno_code_chil  varchar (50) 
,person_code_chrg_workplace  varchar (50) 
,shelfno_code_to  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,unit_code_case_shp  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,shelfno_code_fm  varchar (50) 
,unit_code_outbox  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,loca_code_opeitm  varchar (50) 
,person_code_chrg  varchar (50) 
,loca_name_opeitm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,prjno_name_chil  varchar (100) 
,unit_name_box  varchar (100) 
,unit_name_outbox  varchar (100) 
,unit_name_case_shp  varchar (100) 
,person_name_chrg  varchar (100) 
,person_name_chrg_workplace  varchar (100) 
,shelfno_name_to  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,shelfno_name_fm  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,opeitm_priority  numeric (3,0)
,prdact_packno  varchar (10) 
,prdact_crr_id  numeric (22,0)
,crr_pricedecimal  numeric (22,0)
,prdact_shelfno_id_fm  numeric (22,0)
,prdact_contents  varchar (4000) 
,prdact_remark  varchar (4000) 
,shelfno_loca_id_shelfno_to  numeric (38,0)
,workplace_chrg_id_workplace  numeric (22,0)
,itm_classlist_id  numeric (38,0)
,opeitm_boxe_id  numeric (22,0)
,person_sect_id_chrg_workplace  numeric (22,0)
,chrg_person_id_chrg_workplace  numeric (38,0)
,prdact_workplace_id  numeric (22,0)
,boxe_unit_id_outbox  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,prdact_updated_at   timestamp(6) 
,prdact_opeitm_id  numeric (38,0)
,prdact_prjno_id  numeric (38,0)
,prdact_chrg_id  numeric (38,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,prdact_person_id_upd  numeric (38,0)
,prdact_id  numeric (38,0)
,prdact_update_ip  varchar (40) 
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,prdact_created_at   timestamp(6) 
,chrg_person_id_chrg  numeric (38,0)
,person_sect_id_chrg  numeric (22,0)
,id  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,itm_unit_id  numeric (22,0)
,workplace_loca_id_workplace  numeric (22,0)
,prdact_shelfno_id_to  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
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
 CREATE INDEX sio_r_prdacts_uk1 
  ON sio.sio_r_prdacts(id,sio_id); 

 drop sequence  if exists sio.sio_r_prdacts_seq ;
 create sequence sio.sio_r_prdacts_seq ;
  drop view if  exists r_prdinsts cascade ; 
 create or replace view r_prdinsts as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.unit_name  unit_name ,
  opeitm.unit_code  unit_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
prdinst.id id,
  loca_to.loca_code  loca_code_to ,
  loca_to.loca_name  loca_name_to ,
  prjno.prjno_name  prjno_name ,
  chrg.person_sect_id_chrg  person_sect_id_chrg ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  prjno.prjno_code  prjno_code ,
prdinst.prjnos_id   prdinst_prjno_id,
prdinst.cno  prdinst_cno,
prdinst.opeitms_id   prdinst_opeitm_id,
prdinst.contents  prdinst_contents,
prdinst.id  prdinst_id,
prdinst.remark  prdinst_remark,
prdinst.expiredate  prdinst_expiredate,
prdinst.update_ip  prdinst_update_ip,
prdinst.created_at  prdinst_created_at,
prdinst.updated_at  prdinst_updated_at,
prdinst.persons_id_upd   prdinst_person_id_upd,
prdinst.qty  prdinst_qty,
prdinst.sno  prdinst_sno,
prdinst.duedate  prdinst_duedate,
prdinst.isudate  prdinst_isudate,
prdinst.locas_id_to   prdinst_loca_id_to,
prdinst.qty_case  prdinst_qty_case,
prdinst.commencementdate  prdinst_commencementdate,
prdinst.commencement_f  prdinst_commencement_f,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
prdinst.chrgs_id   prdinst_chrg_id,
prdinst.gno  prdinst_gno,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  opeitm.unit_code_box  unit_code_box ,
  opeitm.unit_name_box  unit_name_box ,
  opeitm.boxe_unit_id_outbox  boxe_unit_id_outbox ,
  opeitm.unit_code_outbox  unit_code_outbox ,
  opeitm.unit_name_outbox  unit_name_outbox ,
  opeitm.boxe_code  boxe_code ,
  opeitm.boxe_name  boxe_name ,
  opeitm.opeitm_boxe_id  opeitm_boxe_id ,
prdinst.starttime  prdinst_starttime,
  prjno.prjno_code_chil  prjno_code_chil ,
  opeitm.itm_classlist_id  itm_classlist_id ,
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
  workplace.workplace_loca_id_workplace  workplace_loca_id_workplace ,
  workplace.loca_code_workplace  loca_code_workplace ,
  workplace.loca_name_workplace  loca_name_workplace ,
  workplace.workplace_chrg_id_workplace  workplace_chrg_id_workplace ,
  workplace.person_code_chrg_workplace  person_code_chrg_workplace ,
  workplace.person_name_chrg_workplace  person_name_chrg_workplace ,
  workplace.person_sect_id_chrg_workplace  person_sect_id_chrg_workplace ,
  workplace.chrg_person_id_chrg_workplace  chrg_person_id_chrg_workplace ,
prdinst.sno_prdord  prdinst_sno_prdord,
prdinst.shelfnos_id_to   prdinst_shelfno_id_to,
prdinst.workplaces_id   prdinst_workplace_id,
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
prdinst.shelfnos_id_fm   prdinst_shelfno_id_fm
 from prdinsts   prdinst,
  r_prjnos  prjno ,  r_opeitms  opeitm ,  r_persons  person_upd ,  r_locas  loca_to ,  r_chrgs  chrg ,  r_shelfnos  shelfno_to ,  r_workplaces  workplace ,  r_shelfnos  shelfno_fm 
  where       prdinst.prjnos_id = prjno.id      and prdinst.opeitms_id = opeitm.id      and prdinst.persons_id_upd = person_upd.id      and prdinst.locas_id_to = loca_to.id      and prdinst.chrgs_id = chrg.id      and prdinst.shelfnos_id_to = shelfno_to.id      and prdinst.workplaces_id = workplace.id      and prdinst.shelfnos_id_fm = shelfno_fm.id     ;
 DROP TABLE IF EXISTS sio.sio_r_prdinsts;
 CREATE TABLE sio.sio_r_prdinsts (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_prdinsts_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,prdinst_sno  varchar (40) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,prdinst_isudate   timestamp(6) 
,prdinst_duedate   timestamp(6) 
,loca_code_to  varchar (50) 
,prdinst_qty  numeric (18,4)
,prdinst_qty_case  numeric (38,0)
,person_name_chrg  varchar (100) 
,classlist_code  varchar (50) 
,boxe_code  varchar (50) 
,prjno_code  varchar (50) 
,unit_code  varchar (50) 
,prdinst_starttime   timestamp(6) 
,unit_name  varchar (100) 
,prjno_name  varchar (100) 
,prdinst_sno_prdord  varchar (50) 
,prdinst_expiredate   date 
,prdinst_commencementdate   timestamp(6) 
,prdinst_commencement_f  varchar (1) 
,classlist_name  varchar (100) 
,boxe_name  varchar (100) 
,loca_code_shelfno_fm  varchar (50) 
,shelfno_code_fm  varchar (50) 
,loca_code_shelfno_to  varchar (50) 
,shelfno_code_to  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,prjno_code_chil  varchar (50) 
,unit_code_case_shp  varchar (50) 
,person_code_chrg  varchar (50) 
,unit_code_outbox  varchar (50) 
,prdinst_cno  varchar (40) 
,loca_code_opeitm  varchar (50) 
,unit_code_box  varchar (50) 
,person_code_chrg_workplace  varchar (50) 
,loca_code_workplace  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,loca_name_to  varchar (100) 
,unit_name_box  varchar (100) 
,unit_name_outbox  varchar (100) 
,shelfno_name_to  varchar (100) 
,loca_name_shelfno_to  varchar (100) 
,shelfno_name_fm  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,loca_name_workplace  varchar (100) 
,person_name_chrg_workplace  varchar (100) 
,prjno_name_chil  varchar (100) 
,loca_name_opeitm  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,unit_name_case_shp  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,opeitm_priority  numeric (3,0)
,prdinst_gno  varchar (40) 
,prdinst_shelfno_id_fm  numeric (22,0)
,prdinst_contents  varchar (4000) 
,prdinst_remark  varchar (4000) 
,id  numeric (38,0)
,workplace_chrg_id_workplace  numeric (22,0)
,prdinst_id  numeric (38,0)
,person_sect_id_chrg_workplace  numeric (22,0)
,chrg_person_id_chrg_workplace  numeric (38,0)
,prdinst_shelfno_id_to  numeric (38,0)
,prdinst_workplace_id  numeric (22,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,prdinst_opeitm_id  numeric (38,0)
,boxe_unit_id_outbox  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,prdinst_prjno_id  numeric (38,0)
,prdinst_chrg_id  numeric (38,0)
,prdinst_created_at   timestamp(6) 
,prdinst_update_ip  varchar (40) 
,itm_unit_id  numeric (22,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,workplace_loca_id_workplace  numeric (22,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,person_sect_id_chrg  numeric (22,0)
,chrg_person_id_chrg  numeric (38,0)
,prdinst_loca_id_to  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,prdinst_person_id_upd  numeric (38,0)
,prdinst_updated_at   timestamp(6) 
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,opeitm_boxe_id  numeric (22,0)
,opeitm_itm_id  numeric (38,0)
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
 CREATE INDEX sio_r_prdinsts_uk1 
  ON sio.sio_r_prdinsts(id,sio_id); 

 drop sequence  if exists sio.sio_r_prdinsts_seq ;
 create sequence sio.sio_r_prdinsts_seq ;
  drop view if  exists r_prdords cascade ; 
 create or replace view r_prdords as select  
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
prdord.id id,
  prjno.prjno_name  prjno_name ,
  chrg.person_sect_id_chrg  person_sect_id_chrg ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
prdord.expiredate  prdord_expiredate,
prdord.updated_at  prdord_updated_at,
prdord.qty  prdord_qty,
prdord.sno  prdord_sno,
prdord.remark  prdord_remark,
prdord.created_at  prdord_created_at,
prdord.update_ip  prdord_update_ip,
prdord.duedate  prdord_duedate,
prdord.toduedate  prdord_toduedate,
prdord.id  prdord_id,
prdord.persons_id_upd   prdord_person_id_upd,
prdord.isudate  prdord_isudate,
  prjno.prjno_code  prjno_code ,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
prdord.prjnos_id   prdord_prjno_id,
prdord.gno  prdord_gno,
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
prdord.opeitms_id   prdord_opeitm_id,
prdord.chrgs_id   prdord_chrg_id,
prdord.starttime  prdord_starttime,
  prjno.prjno_code_chil  prjno_code_chil ,
prdord.confirm  prdord_confirm,
prdord.autoinst_p  prdord_autoinst_p,
prdord.autoact_p  prdord_autoact_p,
prdord.qty_case  prdord_qty_case,
  opeitm.itm_classlist_id  itm_classlist_id ,
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
  workplace.workplace_loca_id_workplace  workplace_loca_id_workplace ,
  workplace.loca_code_workplace  loca_code_workplace ,
  workplace.loca_name_workplace  loca_name_workplace ,
prdord.shelfnos_id_to   prdord_shelfno_id_to,
  workplace.workplace_chrg_id_workplace  workplace_chrg_id_workplace ,
  workplace.person_code_chrg_workplace  person_code_chrg_workplace ,
  workplace.person_name_chrg_workplace  person_name_chrg_workplace ,
  workplace.person_sect_id_chrg_workplace  person_sect_id_chrg_workplace ,
  workplace.chrg_person_id_chrg_workplace  chrg_person_id_chrg_workplace ,
prdord.workplaces_id   prdord_workplace_id,
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
prdord.shelfnos_id_fm   prdord_shelfno_id_fm,
prdord.commencementdate  prdord_commencementdate,
prdord.crrs_id   prdord_crr_id
 from prdords   prdord,
  r_persons  person_upd ,  r_prjnos  prjno ,  r_opeitms  opeitm ,  r_chrgs  chrg ,  r_shelfnos  shelfno_to ,  r_workplaces  workplace ,  r_shelfnos  shelfno_fm ,  r_crrs  crr 
  where       prdord.persons_id_upd = person_upd.id      and prdord.prjnos_id = prjno.id      and prdord.opeitms_id = opeitm.id      and prdord.chrgs_id = chrg.id      and prdord.shelfnos_id_to = shelfno_to.id      and prdord.workplaces_id = workplace.id      and prdord.shelfnos_id_fm = shelfno_fm.id      and prdord.crrs_id = crr.id     ;
 DROP TABLE IF EXISTS sio.sio_r_prdords;
 CREATE TABLE sio.sio_r_prdords (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_prdords_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,prdord_confirm  varchar (1) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,prdord_isudate   timestamp(6) 
,prdord_sno  varchar (40) 
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,opeitm_processseq  numeric (3,0)
,prdord_duedate   timestamp(6) 
,prdord_qty  numeric (18,4)
,loca_code_workplace  varchar (50) 
,loca_name_workplace  varchar (100) 
,opeitm_priority  numeric (3,0)
,prdord_toduedate   timestamp(6) 
,prdord_qty_case  numeric (38,0)
,prjno_code  varchar (50) 
,prjno_name  varchar (100) 
,person_code_chrg  varchar (50) 
,person_name_chrg  varchar (100) 
,classlist_code  varchar (50) 
,classlist_name  varchar (100) 
,crr_code  varchar (50) 
,prdord_autoact_p  numeric (3,0)
,loca_code_shelfno_to  varchar (50) 
,loca_name_shelfno_to  varchar (100) 
,shelfno_code_to  varchar (50) 
,shelfno_name_to  varchar (100) 
,prdord_autoinst_p  numeric (3,0)
,prdord_expiredate   date 
,person_code_chrg_workplace  varchar (50) 
,person_name_chrg_workplace  varchar (100) 
,crr_name  varchar (100) 
,loca_code_shelfno_fm  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,unit_code_case_shp  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_shelfno_fm_opeitm  varchar (50) 
,shelfno_code_fm_opeitm  varchar (50) 
,loca_code_opeitm  varchar (50) 
,prjno_code_chil  varchar (50) 
,shelfno_code_fm  varchar (50) 
,loca_name_shelfno_fm_opeitm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,prjno_name_chil  varchar (100) 
,loca_name_opeitm  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,shelfno_name_fm  varchar (100) 
,unit_name_case_shp  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,shelfno_name_fm_opeitm  varchar (100) 
,unit_code  varchar (50) 
,prdord_starttime   timestamp(6) 
,prdord_gno  varchar (40) 
,unit_name  varchar (100) 
,unit_code_outbox  varchar (50) 
,unit_name_outbox  varchar (100) 
,unit_code_box  varchar (50) 
,unit_name_box  varchar (100) 
,boxe_code  varchar (50) 
,boxe_name  varchar (100) 
,prdord_crr_id  numeric (22,0)
,crr_pricedecimal  numeric (22,0)
,prdord_shelfno_id_fm  numeric (22,0)
,prdord_commencementdate   timestamp(6) 
,prdord_remark  varchar (4000) 
,prdord_shelfno_id_to  numeric (38,0)
,workplace_chrg_id_workplace  numeric (22,0)
,itm_classlist_id  numeric (38,0)
,prdord_chrg_id  numeric (38,0)
,person_sect_id_chrg_workplace  numeric (22,0)
,chrg_person_id_chrg_workplace  numeric (38,0)
,prdord_workplace_id  numeric (22,0)
,prdord_opeitm_id  numeric (38,0)
,opeitm_loca_id_opeitm  numeric (22,0)
,opeitm_boxe_id  numeric (22,0)
,boxe_unit_id_outbox  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,prdord_prjno_id  numeric (38,0)
,shelfno_loca_id_shelfno_fm_opeitm  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,prdord_person_id_upd  numeric (38,0)
,prdord_id  numeric (38,0)
,prdord_update_ip  varchar (40) 
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,prdord_created_at   timestamp(6) 
,prdord_updated_at   timestamp(6) 
,person_sect_id_chrg  numeric (22,0)
,id  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,itm_unit_id  numeric (22,0)
,workplace_loca_id_workplace  numeric (22,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
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
 CREATE INDEX sio_r_prdords_uk1 
  ON sio.sio_r_prdords(id,sio_id); 

 drop sequence  if exists sio.sio_r_prdords_seq ;
 create sequence sio.sio_r_prdords_seq ;
 ALTER TABLE prdacts ADD CONSTRAINT prdact_crrs_id FOREIGN KEY (crrs_id)
																		 REFERENCES crrs (id);
 ALTER TABLE prdords ADD CONSTRAINT prdord_crrs_id FOREIGN KEY (crrs_id)
																		 REFERENCES crrs (id);
