
 alter table  mkordterms  ADD COLUMN mkprdpurord_id numeric(22,0)  DEFAULT 0  not null;

 alter table mkordterms DROP COLUMN mkords_id CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'mkords_id'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　mkords_idが削除　2022-03-10 16:49:44 +0900' 
 ---- where  pobject_code_sfd = 'mkords_id'
  drop view if  exists r_mkordterms cascade ; 
 create or replace view r_mkordterms as select  
  itm.itm_name  itm_name ,
  itm.itm_code  itm_code ,
  itm.unit_name  unit_name ,
  itm.unit_code  unit_code ,
  loca.loca_code  loca_code ,
  loca.loca_name  loca_name ,
mkordterm.id id,
  prjno.prjno_name  prjno_name ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  prjno.prjno_code  prjno_code ,
  itm.classlist_code  classlist_code ,
  itm.classlist_name  classlist_name ,
  prjno.prjno_code_chil  prjno_code_chil ,
  itm.itm_classlist_id  itm_classlist_id ,
  shelfno_to.shelfno_code  shelfno_code_to ,
  shelfno_to.shelfno_name  shelfno_name_to ,
  shelfno_to.loca_code_shelfno  loca_code_shelfno_to ,
  shelfno_to.loca_name_shelfno  loca_name_shelfno_to ,
  shelfno_to.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_to ,
  prjno.prjno_name_chil  prjno_name_chil ,
mkordterm.remark  mkordterm_remark,
mkordterm.expiredate  mkordterm_expiredate,
mkordterm.created_at  mkordterm_created_at,
mkordterm.updated_at  mkordterm_updated_at,
mkordterm.persons_id_upd   mkordterm_person_id_upd,
mkordterm.itms_id   mkordterm_itm_id,
mkordterm.duedate  mkordterm_duedate,
mkordterm.toduedate  mkordterm_toduedate,
mkordterm.contents  mkordterm_contents,
mkordterm.locas_id   mkordterm_loca_id,
mkordterm.processseq  mkordterm_processseq,
mkordterm.prjnos_id   mkordterm_prjno_id,
mkordterm.shelfnos_id_to   mkordterm_shelfno_id_to,
mkordterm.mlevel  mkordterm_mlevel,
mkordterm.mkprdpurords_id   mkordterm_mkprdpurord_id,
mkordterm.id  mkordterm_id
 from mkordterms   mkordterm,
  r_persons  person_upd ,  r_itms  itm ,  r_locas  loca ,  r_prjnos  prjno ,  r_shelfnos  shelfno_to ,  r_mkprdpurords  mkprdpurord 
  where       mkordterm.persons_id_upd = person_upd.id      and mkordterm.itms_id = itm.id      and mkordterm.locas_id = loca.id      and mkordterm.prjnos_id = prjno.id      and mkordterm.shelfnos_id_to = shelfno_to.id      and mkordterm.mkprdpurords_id = mkprdpurord.id     ;
 DROP TABLE IF EXISTS sio.sio_r_mkordterms;
 CREATE TABLE sio.sio_r_mkordterms (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_mkordterms_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,unit_code  varchar (50) 
,loca_code  varchar (50) 
,classlist_code  varchar (50) 
,prjno_code  varchar (50) 
,classlist_name  varchar (100) 
,unit_name  varchar (100) 
,loca_name  varchar (100) 
,itm_name  varchar (100) 
,prjno_name  varchar (100) 
,shelfno_code_to  varchar (50) 
,loca_code_shelfno_to  varchar (50) 
,prjno_code_chil  varchar (50) 
,loca_name_shelfno_to  varchar (100) 
,shelfno_name_to  varchar (100) 
,prjno_name_chil  varchar (100) 
,mkordterm_mkprdpurord_id  numeric (22,0)
,mkordterm_loca_id  numeric (38,0)
,mkordterm_processseq  numeric (38,0)
,mkordterm_prjno_id  numeric (38,0)
,mkordterm_shelfno_id_to  numeric (38,0)
,mkordterm_mlevel  numeric (3,0)
,id  numeric (38,0)
,mkordterm_id  numeric (38,0)
,mkordterm_remark  varchar (4000) 
,mkordterm_expiredate   date 
,mkordterm_created_at   timestamp(6) 
,mkordterm_updated_at   timestamp(6) 
,mkordterm_itm_id  numeric (38,0)
,mkordterm_duedate   timestamp(6) 
,mkordterm_toduedate   timestamp(6) 
,mkordterm_contents  varchar (4000) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,mkordterm_person_id_upd  numeric (22,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,itm_classlist_id  numeric (38,0)
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
 CREATE INDEX sio_r_mkordterms_uk1 
  ON sio.sio_r_mkordterms(id,sio_id); 

 drop sequence  if exists sio.sio_r_mkordterms_seq ;
 create sequence sio.sio_r_mkordterms_seq ;
