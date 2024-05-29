select gantt.orgtblid 
										from trngantts gantt 	
									inner join  itms itm_trn  on  gantt.itms_id_trn = itm_trn.id 
									inner join  shelfnos shelfno_trn  on  gantt.shelfnos_id_trn = shelfno_trn.id 	
									inner join  r_chrgs person_trn  on  gantt.chrgs_id_trn = person_trn.id 	
									inner join  (select loca.*,s.id shelfno_id from locas loca
																inner join shelfnos s on s.locas_id_shelfno = loca.id )
											loca_trn  on  gantt.shelfnos_id_trn = loca_trn.shelfno_id  inner join  purschs pur  on  gantt.tblid = pur.id 
										where	gantt.qty_sch > 0   and
												--- gantt.tblname = 'purschs'       and 
												itm_trn.code  = 'ITEM2002' and  
							  gantt.starttime_trn >= to_date('2000/01/01','yyyy/mm/dd hh24:mi:ss')   
								 and gantt.duedate_trn <= to_date('2099/12/31','yyyy/mm/dd hh24:mi:ss')  
								
										group by gantt.orgtblid				
;

select * from itms where code =    'ITEM2002';25261;
select * from trngantts where itms_id_trn = 25261;
；

select gantt.orgtblid 
										from trngantts gantt 	inner join  itms itm_trn  on  gantt.itms_id_trn = itm_trn.id 
									inner join  shelfnos shelfno_trn  on  gantt.shelfnos_id_trn = shelfno_trn.id 	
									inner join  r_chrgs person_trn  on  gantt.chrgs_id_trn = person_trn.id 	
									inner join  (select loca.*,s.id shelfno_id from locas loca
																inner join shelfnos s on s.locas_id_shelfno = loca.id )
											loca_trn  on  gantt.shelfnos_id_trn = loca_trn.shelfno_id  inner join  purschs pur  on  gantt.tblid = pur.id 
										where	--gantt.qty_sch > 0 
											   --and
											   gantt.tblname = 'purschs'       and itm_trn.code  = 'ITEM2002' 
							 and gantt.starttime_trn >= to_date('2000/01/01','yyyy/mm/dd hh24:mi:ss')   
								 and gantt.duedate_trn <= to_date('2099/12/31','yyyy/mm/dd hh24:mi:ss')  
								
										group by gantt.orgtblid
					;
					
				select * from trngantts t where tblname = 'purschs' and t.qty_sch = 0;