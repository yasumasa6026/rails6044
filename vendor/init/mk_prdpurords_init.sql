



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
to_timestamp('2000/01/01 0:0:0','yyyy/mm/dd hh24:mi:ss'),'',0)


