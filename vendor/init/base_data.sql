
INSERT INTO public.locas VALUES (0, 'system', '未定　仮設定', '未定', '', 'jpn', '未定', '', '', '', '', '', NULL, '00002', '2099-12-31',0, '', '0001-01-01 00: 00: 00 BC', '2023-03-07 20: 33: 21');

INSERT INTO public.persons VALUES (0, '0', 'system',0,0,0, NULL, NULL, '2099-12-31',0, NULL, NULL, '2024-09-01 15: 26: 13', 'system@rrrp.com',5505.000);

INSERT INTO public.chrgs VALUES (NULL, '2015-04-12 03: 02: 13.151', '2099-12-31',0,102,0, NULL, '127.0.0.1', '2015-04-12 03: 02: 13.151');


INSERT INTO public.scrlvs
(code, created_at, expiredate, id, level1, persons_id_upd, contents, remark, update_ip, updated_at)
VALUES('000', '2025/01/01', '2099/12/31', 0, '0', 0, '', '', '', '2025/01/01');


INSERT INTO public.sects
(id, locas_id_sect, contents, remark, expiredate, persons_id_upd, update_ip, created_at, updated_at, locas_id_pare)
VALUES(0, 0, '', '', '2099/12/31', 0, '', '2025/01/01', '2025/01/01', 0);


INSERT INTO public.usrgrps
(id, code, "name", email, contents, remark, expiredate, persons_id_upd, update_ip, created_at, updated_at)
VALUES(0, '000', 'system', '', '', '', '2099/12/31', 0, '', '2025/01/01', '2025/01/01');

insert into mkprdpurords(
created_at,id,isudate,
confirm,result_f,tblname,runtime,cmpldate,processseq_trn,duedate_trn,
paretblname,sno_org,orgtblname,processseq_org,expiredate,duedate_org,manual,processseq_pare,
message_code,itm_code_pare,starttime_trn,duedate_pare,
incnt,inamt,outamt,skipcnt,skipamt,skipqty,outcnt,inqty,outqty,sno_pare,remark,
updated_at,update_ip,persons_id_upd) values( 
to_timestamp('2000/01/0 0:0:0','yyyy/mm/dd hh24:mi:ss'),0, to_timestamp('2000/01/01','yyyy/mm/dd hh24:mi:ss'),
'','','purords',0, to_timestamp('','yyyy/mm/dd hh24:mi:ss'),'999', to_timestamp('2099/12/31','yyyy/mm/dd hh24:mi:ss'),
'purords','sno_org','custords','999',to_date('2099/12/31','yyyy/mm/dd'), to_timestamp('2099/12/31','yyyy/mm/dd hh24:mi:ss'),
'','999','','dummy','2099/12/31', to_timestamp('2099/12/31','yyyy/mm/dd hh24:mi:ss'),0,0,0,0,0,0,0,0,0,'sno_pare','remark',
to_timestamp('2000/01/01 0:0:0','yyyy/mm/dd hh24:mi:ss'),'',0);

