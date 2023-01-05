
truncate table purschs;
truncate table purords;
truncate table purinsts;
truncate table purdlvs;
truncate table puracts;
truncate table inamts;
truncate table outamts;

truncate table alloctbls cascade;
truncate table lotstkhists cascade;

truncate table prdschs;
truncate table prdords;
truncate table prdinsts;
truncate table prdacts;


truncate table custschs;
truncate table custords cascade;
truncate table custinsts;
truncate table custacts;
truncate table custdlvs;
truncate table custwhs;

truncate table trngantts cascade;
truncate table inspschs;
truncate table inspords;
truncate table inspinsts;
truncate table inspacts;
truncate table payschs;
truncate table payords;
truncate table payinsts;
----truncate table payacts;

truncate table processreqs;

truncate table shpschs;
truncate table shpords;
truncate table shpinsts;
truncate table supplierwhs ;
truncate table shpacts;
truncate table custwhs ;

truncate table conschs ;
truncate table conords;
truncate table conacts ;
truncate table linkheads ;
truncate table custactheads;
truncate table linktbls;
truncate table linkcusts;

truncate table mkordopeitms cascade;

truncate table mkprdpurords  cascade;
truncate table srctbls;
truncate table instks cascade;
truncate table outstks cascade;
truncate table mkordorgs cascade;

--insert into lotstkhists(id,
--									itms_id,shelfnos_id,
--									prjnos_id,
--									starttime,processseq,
--									lotno,packno,
--									qty_sch,
--									qty_stk,
--									qty,
--									stktaking_proc,
--									created_at,
--									updated_at,
--									update_ip,persons_id_upd,expiredate,remark)
--							values(0,
--									0,0,
--									0,
--									'2000/01/01',999,
--									'','',
--									0,
--									0,
--									0,
--									'',
--									to_timestamp('2000/01/01 0:0:0','yyyy/mm/dd hh24:mi:ss'),
--									to_timestamp('2000/01/01 0:0:0','yyyy/mm/dd hh24:mi:ss'),
--									' ',0,'2099/12/31','')
--;
INSERT INTO public.mkprdpurords 
(id, 
cmpldate, result_f, runtime, 
isudate, orgtblname, confirm, manual, incnt, inqty, inamt, outcnt, outqty, outamt, skipcnt, skipqty, skipamt, expiredate,update_ip,
created_at, remark, message_code, persons_id_upd, 
updated_at, sno_org, sno_pare, tblname, paretblname, itm_code_pare, loca_code_org, 
duedate_trn, 
duedate_pare, 
duedate_org, processseq_org, processseq_pare, itm_code_trn, itm_code_org, itm_name_org, itm_name_trn, itm_name_pare, 
person_code_chrg_org, person_code_chrg_pare, person_code_chrg_trn, person_name_chrg_org, person_name_chrg_pare, person_name_chrg_trn,
loca_code_pare, loca_code_trn, loca_name_trn, loca_name_pare, processseq_trn, loca_name_org, loca_name_to_trn, 
starttime_trn)
VALUES(0, 
to_timestamp('2000/01/01 0:0:0','yyyy/mm/dd hh24:mi:ss'), 'r', 0, 
to_timestamp('2000/01/01 0:0:0','yyyy/mm/dd hh24:mi:ss'), 'org', 'c', 'm', 0, 0, 0, 0, 0, 0, 0, 0, 0, '2099/12/31', '',
to_timestamp('2000/01/01 0:0:0','yyyy/mm/dd hh24:mi:ss'), 'rem', 'mes', 0, 
to_timestamp('2000/01/01 0:0:0','yyyy/mm/dd hh24:mi:ss'), 'sno', 'sno', 'tbl', 'pare', 'itm', 'loca',
to_timestamp('2000/01/01 0:0:0','yyyy/mm/dd hh24:mi:ss'),
to_timestamp('2000/01/01 0:0:0','yyyy/mm/dd hh24:mi:ss'),
to_timestamp('2000/01/01 0:0:0','yyyy/mm/dd hh24:mi:ss'), 0, 0, 'itm', 'itm', 'itm_n_o', 'i_n_t', 'i_n_p', 
'person', 'person', 'person', '', 'p_n', 'p_n', 'p_n', 
'l_c_p', 'p_c_t', 'p_n_p', 0, 'l_n_o', 'l_n_t',
to_timestamp('2000/01/01 0:0:0','yyyy/mm/dd hh24:mi:ss'));
;
commit;

truncate table sio.sio_custact_linkheads;
truncate table sio.sio_r_purschs;
truncate table sio.sio_r_purords;
truncate table sio.sio_r_purinsts;
truncate table sio.sio_r_purdlvs;
truncate table sio.sio_r_puracts;
truncate table sio.sio_r_instks;
truncate table sio.sio_r_outstks;
truncate table sio.sio_r_inamts;
truncate table sio.sio_r_outamts;
truncate table sio.sio_r_lotstkhists;
truncate table sio.sio_r_custactheads;

truncate table sio.sio_r_alloctbls cascade;

truncate table sio.sio_r_prdschs;
truncate table sio.sio_r_prdords;
truncate table sio.sio_r_prdinsts;
truncate table sio.sio_r_prdacts;


truncate table sio.sio_r_custschs;
truncate table sio.sio_r_custords;
truncate table sio.sio_r_custinsts;
truncate table sio.sio_r_custdlvs;
truncate table sio.sio_fmcustinst_custdlvs ;
truncate table sio.sio_fmcustord_custinsts;
truncate table sio.sio_r_custacts;

truncate table sio.sio_r_trngantts cascade;
truncate table sio.sio_r_inspschs;
truncate table sio.sio_r_inspords;
truncate table sio.sio_r_inspinsts;
truncate table sio.sio_r_inspacts;
truncate table sio.sio_r_payschs;
truncate table sio.sio_r_payords;
truncate table sio.sio_r_payinsts;
----truncate table sio.sio_r_payacts;

truncate table sio.sio_r_processreqs;

truncate table sio.sio_r_shpschs;
truncate table sio.sio_r_shpords;

truncate table sio.sio_r_mkords;

truncate table sio.sio_r_srctbls;
truncate table sio.sio_r_shpacts;

truncate table mkordterms ;
truncate table sio.sio_r_mkordterms ;
truncate table sio.sio_r_mkordorgs cascade;


REFRESH MATERIALIZED view  r_pobjects;
REFRESH MATERIALIZED view  r_fieldcodes;
REFRESH MATERIALIZED view r_blktbs ;
REFRESH MATERIALIZED view r_tblfields; 
REFRESH MATERIALIZED view r_screenfields; 
---REFRESH MATERIALIZED view r_itms ;
---REFRESH MATERIALIZED view r_opeitms; 
---REFRESH MATERIALIZED view r_nditms; 
commit;

