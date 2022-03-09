
 alter table  inspacts ALTER COLUMN qty  TYPE numeric(22,6) ;

 alter table  inspacts  ADD COLUMN shelfnos_id_to_opeitm numeric(38,0)  DEFAULT 0  not null;

 alter table  inspacts  ADD COLUMN shelfnos_id_to numeric(38,0)  DEFAULT 0  not null;

 alter table inspacts DROP COLUMN shelfnos_id_act CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'shelfnos_id_act'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　shelfnos_id_actが削除　2022-03-04 19:43:47 +0900' 
 ---- where  pobject_code_sfd = 'shelfnos_id_act'
 alter table inspacts DROP COLUMN opeitms_id CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'opeitms_id'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　opeitms_idが削除　2022-03-04 19:43:47 +0900' 
 ---- where  pobject_code_sfd = 'opeitms_id'
 alter table inspacts DROP COLUMN prjnos_id CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'prjnos_id'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　prjnos_idが削除　2022-03-04 19:43:47 +0900' 
 ---- where  pobject_code_sfd = 'prjnos_id'
 alter table inspacts DROP COLUMN gno CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'gno'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　gnoが削除　2022-03-04 19:43:47 +0900' 
 ---- where  pobject_code_sfd = 'gno'
 alter table inspinsts DROP COLUMN prjnos_id CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'prjnos_id'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　prjnos_idが削除　2022-03-04 19:43:47 +0900' 
 ---- where  pobject_code_sfd = 'prjnos_id'
 alter table inspinsts DROP COLUMN opeitms_id CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'opeitms_id'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　opeitms_idが削除　2022-03-04 19:43:47 +0900' 
 ---- where  pobject_code_sfd = 'opeitms_id'
 alter table inspinsts DROP COLUMN gno CASCADE;

 --- 使用しているview 
 --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'gno'
 ---- update screenfields set expiredate ='2000/01/01',remark =' 項目　gnoが削除　2022-03-04 19:43:47 +0900' 
 ---- where  pobject_code_sfd = 'gno'
