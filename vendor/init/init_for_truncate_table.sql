
truncate table purschs cascade;
truncate table purords cascade;
truncate table purinsts cascade;
truncate table purdlvs cascade;
truncate table puracts cascade;
truncate table  srctbllinks cascade;

truncate table alloctbls cascade;
truncate table lotstkhists cascade;

truncate table prdschs cascade;
truncate table prdords cascade;
truncate table prdinsts cascade;
truncate table prdacts cascade;


truncate table custschs cascade;
truncate table custords cascade;
truncate table custordheads cascade;
truncate table custinsts cascade;
truncate table custacts cascade;
truncate table custdlvs cascade;
truncate table custwhs cascade;

truncate table trngantts cascade;
truncate table inspschs cascade;
truncate table inspords cascade;
truncate table inspinsts cascade;
truncate table inspacts cascade;

truncate table processreqs cascade;

truncate table shpests cascade;
truncate table shpschs cascade;
truncate table shpords cascade;
truncate table shpinsts cascade;
truncate table supplierwhs  cascade;
truncate table shpacts cascade;
truncate table custwhs  cascade;

truncate table conschs  cascade;
truncate table conords cascade;
truncate table conacts  cascade;
truncate table linkheads  cascade;
truncate table custactheads cascade;
truncate table linktbls cascade;
truncate table linkcusts cascade;

truncate table mkordopeitms cascade;

truncate table mkprdpurords  cascade;
truncate table srctbllinks cascade;;
truncate table mkordorgs cascade;


 truncate table  dvsacts cascade;
 truncate table  dvsinsts cascade;
 truncate table  dvsords cascade;
 truncate table  dvsschs cascade;
 truncate table  mnfacts cascade;
 truncate table  mnfinsts cascade;
 truncate table  mnfords cascade;
 truncate table  mnfschs cascade;

truncate  table billests cascade;
truncate  table billschs cascade;
truncate  table billords cascade;
truncate  table billinsts cascade;
truncate  table mkbillinsts cascade;
truncate  table billacts cascade;


truncate  table payschs cascade;
truncate  table payords cascade;
truncate  table payinsts cascade;
truncate  table mkpayinsts cascade;
truncate  table payacts cascade;
truncate  table dymschs cascade;


truncate table ercschs cascade;
truncate table ercords cascade;
truncate table ercinsts cascade;
truncate table ercacts cascade;


truncate table mkordtmpfs cascade;


truncate table sio.sio_r_ercschs cascade;
truncate table sio.sio_r_ercords cascade;
truncate table sio.sio_r_ercinsts cascade;
truncate table sio.sio_r_ercacts cascade;


truncate table sio.sio_r_custschs cascade;
truncate table sio.sio_r_custords cascade;
truncate table sio.sio_r_custordheads cascade;
truncate table sio.sio_r_custinsts cascade;
truncate table sio.sio_r_custacts cascade;
truncate table sio.sio_r_custdlvs cascade;
truncate table  sio.sio_r_srctbllinks cascade;


truncate table sio.sio_r_screenfields cascade;

truncate table sio.sio_r_tblfields cascade;

INSERT INTO public.mkprdpurords 
(id, 
cmpldate, result_f, runtime, 
isudate, orgtblname, confirm, manual, incnt, inqty, inamt, outcnt, outqty, outamt, skipcnt, skipqty, skipamt, expiredate,update_ip,
created_at, remark, message_code, persons_id_upd, 
updated_at, sno_org, sno_pare, tblname, paretblname, itm_code_pare, loca_code_org, 
duedate_trn, duedate_pare, 
duedate_org, processseq_org, processseq_pare, itm_code_trn, itm_code_org, itm_name_org, itm_name_trn, itm_name_pare, 
person_code_chrg_org, person_code_chrg_pare, person_code_chrg_trn, person_name_chrg_org, person_name_chrg_pare, person_name_chrg_trn,
loca_code_pare, loca_code_trn, loca_name_trn, loca_name_pare, processseq_trn, loca_name_org, 
shelfno_code_org,shelfno_code_pare, shelfno_code_trn,shelfno_name_org,shelfno_name_pare, shelfno_name_trn,  
starttime_trn)
VALUES(0, 
to_timestamp('2000/01/01 0:0:0','yyyy/mm/dd hh24:mi:ss'), 'r', 0, 
to_timestamp('2000/01/01 0:0:0','yyyy/mm/dd hh24:mi:ss'), 'org', 'c', 'm', 0, 0, 0, 0, 0, 0, 0, 0, 0, '2099/12/31', '',
to_timestamp('2000/01/01 0:0:0','yyyy/mm/dd hh24:mi:ss'), 'rem', 'mes', 0, 
to_timestamp('2000/01/01 0:0:0','yyyy/mm/dd hh24:mi:ss'), 'sno', 'sno', 'tbl', 'pare', 'itm', 'loca',
to_timestamp('2000/01/01 0:0:0','yyyy/mm/dd hh24:mi:ss'),to_timestamp('2000/01/01 0:0:0','yyyy/mm/dd hh24:mi:ss'),
to_timestamp('2000/01/01 0:0:0','yyyy/mm/dd hh24:mi:ss'), 999, 999, 'itm_code_trn', 'itm_code_org', 'itm_name_org', 'itm_name_trn', 'itm_name_pare',
'person_code_chrg_org', 'person_code_chrg_pare', 'person_code_chrg_trn', 'person_name_chrg_org', 'person_name_chrg_pare', 'person_name_chrg_trn',
'loca_code_pare', 'loca_code_trn', 'loca_name_trn', 'loca_name_pare', 999, 'loca_name_org', 
'shelfno_code_org','shelfno_code_pare', 'shelfno_code_trn','shelfno_name_org','shelfno_name_pare', 'shelfno_name_trn',  
to_timestamp('2000/01/01 0:0:0','yyyy/mm/dd hh24:mi:ss'));
commit;

truncate table sio.sio_r_purschs cascade;
truncate table sio.sio_bal_purschs cascade;
truncate table sio.sio_bal_purords cascade;
truncate table sio.sio_r_purords cascade;
truncate table sio.sio_r_purinsts cascade;
truncate table sio.sio_r_purdlvs cascade;
truncate table sio.sio_r_puracts cascade;
truncate table sio.sio_r_lotstkhists cascade;
truncate table sio.sio_r_custactheads cascade;

truncate table sio.sio_r_alloctbls cascade;

truncate table sio.sio_r_prdschs cascade;
truncate table sio.sio_r_prdords cascade;
truncate table sio.sio_r_prdinsts cascade;
truncate table sio.sio_r_prdacts cascade;


truncate table sio.sio_r_custschs cascade;
truncate table sio.sio_r_custordheads cascade;
truncate table sio.sio_r_custinsts cascade;
truncate table sio.sio_r_custdlvs cascade;
truncate table sio.sio_fmcustinst_custdlvs ;
truncate table sio.sio_fmcustord_custinsts;
truncate table sio.sio_r_custacts;

truncate table sio.sio_r_trngantts cascade;

truncate table sio.sio_r_processreqs cascade;

truncate table sio.sio_r_shpests cascade;
truncate table sio.sio_r_shpschs cascade;
truncate table sio.sio_r_shpords cascade;

truncate table sio.sio_r_mkords cascade;

truncate table sio.sio_r_shpacts cascade;

truncate table mkordterms  cascade;
truncate table sio.sio_r_mkordterms  cascade;
truncate table sio.sio_r_mkordorgs cascade;


truncate  table sio.sio_r_billests cascade;
truncate  table sio.sio_r_billschs cascade;
truncate  table sio.sio_r_billords cascade;
truncate  table sio.sio_r_billinsts cascade;
truncate  table sio.sio_r_mkbillinsts cascade;
truncate  table sio.sio_r_billacts cascade;


truncate  table sio.sio_r_payschs cascade;
truncate  table sio.sio_r_payords cascade;
truncate  table sio.sio_r_payinsts cascade;
truncate  table sio.sio_r_mkpayinsts cascade;
truncate  table sio.sio_r_payacts cascade;

 truncate table  sio.sio_r_dvsacts cascade;
 truncate table  sio.sio_r_dvsinsts cascade;
 truncate table  sio.sio_r_dvsords cascade;
 truncate table  sio.sio_r_dvsschs cascade;
 truncate table  sio.sio_r_mnfacts cascade;
 truncate table  sio.sio_r_mnfinsts cascade;
 truncate table  sio.sio_r_mnfords cascade;
 truncate table  sio.sio_r_mnfschs cascade;
 truncate table  sio.sio_r_dymschs cascade;


REFRESH MATERIALIZED view  r_pobjects;
REFRESH MATERIALIZED view  r_fieldcodes;
REFRESH MATERIALIZED view r_blktbs ;
REFRESH MATERIALIZED view r_tblfields;  
REFRESH MATERIALIZED view r_screens; 
REFRESH MATERIALIZED view r_screenfields;
---REFRESH MATERIALIZED view r_itms ;
---REFRESH MATERIALIZED view r_opeitms; 
---REFRESH MATERIALIZED view r_nditms; 
commit;

