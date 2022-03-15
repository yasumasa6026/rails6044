
 alter table  mkordtmpfs  ADD COLUMN mkprdpurords_id numeric(22,0)  DEFAULT 0  not null;

 alter table mkordtmpfs DROP COLUMN mkords_id CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'mkords_id'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　mkords_idが削除　2022-03-10 17:00:37 +0900' 
 ---- where  pobject_code_sfd = 'mkords_id'
  drop view if  exists r_mkordtmpfs cascade ; 
 create or replace view r_mkordtmpfs as select  
  itm.itm_name  itm_name ,
  itm.itm_code  itm_code ,
  itm.unit_name  unit_name ,
  itm.unit_code  unit_code ,
  loca.loca_code  loca_code ,
  loca.loca_name  loca_name ,
  itm.itm_unit_id  itm_unit_id ,
mkordtmpf.id id,
  prjno.prjno_name  prjno_name ,
  person_upd.person_code  person_code_upd ,
  person_upd.person_name  person_name_upd ,
  itm_pare.itm_code  itm_code_pare ,
  itm_pare.itm_name  itm_name_pare ,
  itm_pare.unit_code  unit_code_pare ,
  itm_pare.unit_name  unit_name_pare ,
  prjno.prjno_code  prjno_code ,
  itm.classlist_code  classlist_code ,
  itm.classlist_name  classlist_name ,
  prjno.prjno_code_chil  prjno_code_chil ,
  itm.itm_classlist_id  itm_classlist_id ,
  itm_pare.itm_classlist_id  itm_classlist_id_pare ,
  itm_pare.classlist_name  classlist_name_pare ,
  itm_pare.classlist_code  classlist_code_pare ,
  shelfno_to.shelfno_code  shelfno_code_to ,
  shelfno_to.shelfno_name  shelfno_name_to ,
  shelfno_to.loca_code_shelfno  loca_code_shelfno_to ,
  shelfno_to.loca_name_shelfno  loca_name_shelfno_to ,
  shelfno_to.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_to ,
  prjno.prjno_name_chil  prjno_name_chil ,
mkordtmpf.qty_sch  mkordtmpf_qty_sch,
mkordtmpf.qty_require  mkordtmpf_qty_require,
mkordtmpf.remark  mkordtmpf_remark,
mkordtmpf.expiredate  mkordtmpf_expiredate,
mkordtmpf.update_ip  mkordtmpf_update_ip,
mkordtmpf.created_at  mkordtmpf_created_at,
mkordtmpf.updated_at  mkordtmpf_updated_at,
mkordtmpf.persons_id_upd   mkordtmpf_person_id_upd,
mkordtmpf.itms_id   mkordtmpf_itm_id,
mkordtmpf.qty  mkordtmpf_qty,
mkordtmpf.duedate  mkordtmpf_duedate,
mkordtmpf.toduedate  mkordtmpf_toduedate,
mkordtmpf.packqty  mkordtmpf_packqty,
mkordtmpf.contents  mkordtmpf_contents,
mkordtmpf.locas_id   mkordtmpf_loca_id,
mkordtmpf.processseq  mkordtmpf_processseq,
mkordtmpf.prjnos_id   mkordtmpf_prjno_id,
mkordtmpf.parenum  mkordtmpf_parenum,
mkordtmpf.chilnum  mkordtmpf_chilnum,
mkordtmpf.itms_id_pare   mkordtmpf_itm_id_pare,
mkordtmpf.processseq_pare  mkordtmpf_processseq_pare,
mkordtmpf.mlevel  mkordtmpf_mlevel,
mkordtmpf.qty_stk  mkordtmpf_qty_stk,
mkordtmpf.qty_handover  mkordtmpf_qty_handover,
mkordtmpf.shelfnos_id_to   mkordtmpf_shelfno_id_to,
mkordtmpf.tblname  mkordtmpf_tblname,
mkordtmpf.tblid  mkordtmpf_tblid,
mkordtmpf.incnt  mkordtmpf_incnt,
mkordtmpf.consumminqty  mkordtmpf_consumminqty,
mkordtmpf.consumchgoverqty  mkordtmpf_consumchgoverqty,
mkordtmpf.consumunitqty  mkordtmpf_consumunitqty,
  mkprdpurord.mkprdpurord_tblname  mkprdpurord_tblname ,
  mkprdpurord.mkprdpurord_message_code  mkprdpurord_message_code ,
  mkprdpurord.mkprdpurord_sno_org  mkprdpurord_sno_org ,
  mkprdpurord.mkprdpurord_itm_code_pare  mkprdpurord_itm_code_pare ,
  mkprdpurord.mkprdpurord_itm_code_trn  mkprdpurord_itm_code_trn ,
  mkprdpurord.mkprdpurord_sno_pare  mkprdpurord_sno_pare ,
  mkprdpurord.mkprdpurord_itm_code_org  mkprdpurord_itm_code_org ,
  mkprdpurord.mkprdpurord_itm_name_org  mkprdpurord_itm_name_org ,
  mkprdpurord.mkprdpurord_itm_name_trn  mkprdpurord_itm_name_trn ,
  mkprdpurord.mkprdpurord_itm_name_pare  mkprdpurord_itm_name_pare ,
  mkprdpurord.mkprdpurord_person_code_chrg_org  mkprdpurord_person_code_chrg_org ,
  mkprdpurord.mkprdpurord_person_code_chrg_pare  mkprdpurord_person_code_chrg_pare ,
  mkprdpurord.mkprdpurord_person_code_chrg_trn  mkprdpurord_person_code_chrg_trn ,
  mkprdpurord.mkprdpurord_person_name_chrg_org  mkprdpurord_person_name_chrg_org ,
  mkprdpurord.mkprdpurord_person_name_chrg_pare  mkprdpurord_person_name_chrg_pare ,
  mkprdpurord.mkprdpurord_person_name_chrg_trn  mkprdpurord_person_name_chrg_trn ,
  mkprdpurord.mkprdpurord_loca_code_pare  mkprdpurord_loca_code_pare ,
  mkprdpurord.mkprdpurord_loca_code_trn  mkprdpurord_loca_code_trn ,
  mkprdpurord.mkprdpurord_loca_name_trn  mkprdpurord_loca_name_trn ,
  mkprdpurord.mkprdpurord_loca_name_pare  mkprdpurord_loca_name_pare ,
  mkprdpurord.mkprdpurord_loca_code_org  mkprdpurord_loca_code_org ,
  mkprdpurord.mkprdpurord_loca_name_org  mkprdpurord_loca_name_org ,
  mkprdpurord.mkprdpurord_loca_name_to_trn  mkprdpurord_loca_name_to_trn ,
mkordtmpf.mkprdpurords_id   mkordtmpf_mkprdpurord_id,
mkordtmpf.id  mkordtmpf_id
 from mkordtmpfs   mkordtmpf,
  r_persons  person_upd ,  r_itms  itm ,  r_locas  loca ,  r_prjnos  prjno ,  r_itms  itm_pare ,  r_shelfnos  shelfno_to ,  r_mkprdpurords  mkprdpurord 
  where       mkordtmpf.persons_id_upd = person_upd.id      and mkordtmpf.itms_id = itm.id      and mkordtmpf.locas_id = loca.id      and mkordtmpf.prjnos_id = prjno.id      and mkordtmpf.itms_id_pare = itm_pare.id      and mkordtmpf.shelfnos_id_to = shelfno_to.id      and mkordtmpf.mkprdpurords_id = mkprdpurord.id     ;
 DROP TABLE IF EXISTS sio.sio_r_mkordtmpfs;
 CREATE TABLE sio.sio_r_mkordtmpfs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_mkordtmpfs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,prjno_code  varchar (50) 
,loca_code  varchar (50) 
,mkprdpurord_message_code  varchar (256) 
,classlist_code  varchar (50) 
,itm_name  varchar (100) 
,itm_name_pare  varchar (100) 
,unit_code  varchar (50) 
,itm_code_pare  varchar (50) 
,classlist_name  varchar (100) 
,classlist_name_pare  varchar (100) 
,itm_code  varchar (50) 
,unit_name  varchar (100) 
,loca_name  varchar (100) 
,prjno_name  varchar (100) 
,mkprdpurord_loca_code_org  varchar (50) 
,prjno_code_chil  varchar (50) 
,mkprdpurord_loca_code_trn  varchar (50) 
,classlist_code_pare  varchar (50) 
,shelfno_code_to  varchar (50) 
,loca_code_shelfno_to  varchar (50) 
,mkprdpurord_loca_code_pare  varchar (50) 
,mkprdpurord_itm_code_pare  varchar (50) 
,mkprdpurord_itm_code_trn  varchar (50) 
,mkprdpurord_itm_code_org  varchar (50) 
,mkprdpurord_person_code_chrg_org  varchar (50) 
,mkprdpurord_person_code_chrg_pare  varchar (50) 
,mkprdpurord_person_code_chrg_trn  varchar (50) 
,unit_code_pare  varchar (50) 
,mkprdpurord_loca_name_trn  varchar (100) 
,mkprdpurord_person_name_chrg_org  varchar (100) 
,mkprdpurord_person_name_chrg_pare  varchar (100) 
,mkprdpurord_itm_name_org  varchar (100) 
,shelfno_name_to  varchar (100) 
,unit_name_pare  varchar (100) 
,mkprdpurord_loca_name_to_trn  varchar (100) 
,mkprdpurord_loca_name_org  varchar (100) 
,mkprdpurord_person_name_chrg_trn  varchar (100) 
,prjno_name_chil  varchar (100) 
,loca_name_shelfno_to  varchar (100) 
,mkprdpurord_loca_name_pare  varchar (100) 
,mkprdpurord_itm_name_trn  varchar (100) 
,mkprdpurord_itm_name_pare  varchar (100) 
,mkprdpurord_sno_pare  varchar (50) 
,mkprdpurord_sno_org  varchar (50) 
,mkordtmpf_qty_handover  numeric (22,6)
,mkordtmpf_qty_sch  numeric (22,6)
,mkordtmpf_qty_require  numeric (22,6)
,mkordtmpf_remark  varchar (4000) 
,mkordtmpf_expiredate   date 
,mkordtmpf_update_ip  varchar (40) 
,mkordtmpf_created_at   timestamp(6) 
,mkordtmpf_updated_at   timestamp(6) 
,mkordtmpf_itm_id  numeric (38,0)
,mkordtmpf_qty  numeric (22,6)
,mkordtmpf_duedate   timestamp(6) 
,mkordtmpf_toduedate   timestamp(6) 
,mkordtmpf_packqty  numeric (18,2)
,mkordtmpf_contents  varchar (4000) 
,mkordtmpf_loca_id  numeric (38,0)
,mkordtmpf_processseq  numeric (38,0)
,mkordtmpf_prjno_id  numeric (38,0)
,mkordtmpf_parenum  numeric (22,6)
,mkordtmpf_chilnum  numeric (22,6)
,mkordtmpf_itm_id_pare  numeric (38,0)
,mkordtmpf_processseq_pare  numeric (38,0)
,mkordtmpf_mlevel  numeric (3,0)
,mkordtmpf_qty_stk  numeric (22,6)
,mkordtmpf_shelfno_id_to  numeric (38,0)
,mkordtmpf_tblname  varchar (30) 
,mkordtmpf_tblid  numeric (38,0)
,mkordtmpf_incnt  numeric (38,0)
,mkordtmpf_consumminqty  numeric (22,6)
,mkordtmpf_consumchgoverqty  numeric (22,6)
,mkordtmpf_consumunitqty  numeric (22,6)
,mkprdpurord_tblname  varchar (20) 
,mkordtmpf_mkprdpurord_id  numeric (22,0)
,mkordtmpf_id  numeric (38,0)
,person_name_upd  varchar (100) 
,person_code_upd  varchar (50) 
,shelfno_loca_id_shelfno_to  numeric (38,0)
,mkordtmpf_person_id_upd  numeric (22,0)
,itm_classlist_id_pare  numeric (38,0)
,id  numeric (38,0)
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
 CREATE INDEX sio_r_mkordtmpfs_uk1 
  ON sio.sio_r_mkordtmpfs(id,sio_id); 

 drop sequence  if exists sio.sio_r_mkordtmpfs_seq ;
 create sequence sio.sio_r_mkordtmpfs_seq ;
 ALTER TABLE mkordtmpfs ADD CONSTRAINT mkordtmpf_mkprdpurords_id FOREIGN KEY (mkprdpurords_id)
																		 REFERENCES mkprdpurords (id);
