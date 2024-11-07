# -*- coding: utf-8 -*-
# 2099/12/31を修正する時は　2100/01/01の修正も
module GanttChart
    extend self
	class GanttClass
		def initialize(buttonflg,tbl)
			@bgantts = {}  ###全体のtree構造　keyは階層レベル
      @ngantts = []  ###親直下の子ども処理用
			@level = tbl  ###itm or trn:gantt(reverse)
			@err = false
			@base = @level
		end

    	def proc_get_ganttchart_data(mst_code,id,buttonflg)   ###opeims_idはある。
        	time_now =  Time.now
			case mst_code
			when /itms/
				@max_time = Time.now.strftime("%Y-%m-%d")
				@min_time = Time.now.strftime("%Y-%m-%d")
				@bgantts[@base] = {:itm_code=>"",:itm_name=>"全行程",:processseq=>"",:loca_code=>"",:loca_name=>"",:opeitms_id=>"0",
												:parenum=>"親員数",:chilnum=>"子員数",:type=>"project",
												:depend => [""],:id=>"000"}
				case mst_code
				when "opeitms"
		 				rec = ActiveRecord::Base.connection.select_one("select * from r_opeitms where opeitm_id = #{id} and opeitm_Expiredate > current_date")
		    	when "itms"
             			rec = ActiveRecord::Base.connection.select_one("select * from r_opeitms where opeitm_itm_id = #{id} and opeitm_Expiredate > current_date
																and opeitm_processseq = 999  
																order by opeitm_priority desc")
				when "nditms"
					rec = ActiveRecord::Base.connection.select_one("select * from r_nditms where id = #{id} and nditm_Expiredate > current_date")
				else
				end
				if rec then
					case mst_code
					when /^opeitms|^itms/
						@ngantts << {	:itms_id=>rec["opeitm_itm_id"],:locas_id=>rec["shelfno_loca_id"],:opeitms_id=>rec["opeitm_id"],
										:itm_code=>rec["itm_code"],:itm_name=>rec["itm_name"],:qty=>1,:depend => [],:type=>"task",
										:loca_code=>rec["loca_code_shelfno"],:loca_name=>rec["loca_name"],:parenum=>1,:chilnum=>1,
										:duration=>rec["opeitm_duration"],:units_lttime=>rec["opeitm_units_lttime"],
										:prdpur=>rec["opeitm_prdpur"],
										:processseq=>"#{if mst_code =~ /^itms/ then '999' else  rec["opeitm_processseq"] end}",
										:priority=>"#{if mst_code =~ /^itms/ then '999' else rec["opeitm_priority"] end}",
										:start=>@min_time,:duedate=>@max_time,:id=>@level+ format('%07d',id.to_i)}  ###:id=>ganttのkey
					when "nditms"
						case buttonflg
						when /gantt/
								@ngantts << {	:itms_id=>rec["opeitm_itm_id"],:locas_id=>rec["shelfno_loca_id_shelfno_opeitm"],:type=>"task",
										:opeitms_id=>rec["nditm_opeitm_id"],:itm_code=>rec["itm_code"],:itm_name=>rec["itm_name"],:qty=>1,
										:loca_code=>rec["loca_code_shelfno"],:loca_name=>rec["loca_name_shelfno"],:depend => [],
										:parenum=>1,:chilnum=>1,:prdpur=>rec["opeitm_prdpur"],
										:duration=>rec["opeitm_duration"],:units_lttime=>rec["opeitm_units_lttime"],
										:processseq=>rec["opeitm_processseq"],:priority=>rec["opeitm_priority"],
										:start=>@min_time,:duedate=>@max_time,:id=>@level+format('%07d',id.to_i)}  ###:id=>
						when /reverse/
								ope = ActiveRecord::Base.connection.select_one("select ope.*,shelf.locas_id_shelfno locas_id from opeitms ope
																	inner join shelfnos shelf on shelf.id = ope.shelfnos_id_opeitm 
																	where ope.itms_id = #{rec["nditm_itm_id_nditm"]} 
																	and ope.processseq = #{rec["nditm_processseq_nditm"]}
																	and ope.priority = 999
																	and ope.Expiredate > current_date")
								if ope
									@ngantts << {	:itms_id=>ope["itms_id"],:locas_id=>ope["locas_id"],:type=>"task",
										:opeitms_id=>ope["id"],:qty=>1,:depend => [],:parenum=>1,:chilnum=>1,
										:duration=>ope["duration"],:units_lttime=>ope["units_lttime"],
										:prdpur=>ope["prdpur"],
										:processseq=>ope["processseq"],:priority=>ope["priority"],
										:start=>@max_time,:duedate=>@min_time,:id=>@level+format('%07d',ope["id"].to_i)}  ###:
								else
									@ngantts << {:itms_id=>rec["nditm_itm_id_nditm"],:locas_id=>"0",:type=>"task",
										:opeitms_id=>"0",:qty=>1,:depend => [],:parenum=>1,:chilnum=>1,
										:duration=>1,:units_lttime=>"DAY ",
										:prdpur=>"dummy",
										:processseq=>999,:priority=>999,
										:start=>@max_time,:duedate=>@min_time,:id=>@level+format('%07d',0)}  ###:
								end
						end
					end
					cnt = 0
					@bgantts[@ngantts[0][:id]] = @ngantts[0]
					until @ngantts.size == 0
						cnt += 1
						n0 = @ngantts.shift
						@level = n0[:id]
						  if n0.size > 0  ###子部品がいなかったとき{}になる。
							get_ganttchart_rec(n0)
						  end
						break if cnt >= 1000
					end
				else
					logger.debug "#{Time.now} #{__LINE__} logic err #{mst_code},#{id},#{buttonflg}"
					raise
				end
			when /prd|pur|cust/
				@bgantts[@base] = {:itm_code=>"",:itm_name=>"全行程",:loca_code=>"",:loca_name=>"",:opeitms_id=>"0",
												:start => "2099-12-31",:duedate => "2000-01-01",
												:type=>"project",:depend => [""],:id=>@level}
				trget = ActiveRecord::Base.connection.select_one(%Q&select * from #{mst_code} where id = #{id}&)
				@bgantts[@base] [:tblname] = mst_code
				@bgantts[@base] [:sno] = trget["sno"]
					###一度登録した trnganttsのtblname,tblidに変更はない。
				@max_time = trget["duedate"]
				@min_time = trget["starttime"]
				case mst_code
				when /purords|prdords|purschs|prdschs/
					strsql =	%Q&
									select  max(trn.itms_id_trn) itms_id_trn,max(s.locas_id_shelfno) locas_id_trn,max(trn.orgtblname) orgtblname,
											max(trn.orgtblid) orgtblid,max(trn.paretblname) paretblname,max(trn.paretblid) paretblid,
											a.srctblname linktblname,a.srctblid linktblid,
											a.srctblname tblname,a.srctblid tblid,
											max(trn.parenum) parenum,max(trn.chilnum) chilnum,max(trn.processseq_trn) processseq_trn,
											min(trn.starttime_trn) starttime_trn,max(trn.duedate_trn) duedate_trn,
											sum(a.qty_linkto_alloctbl) qty_src,max(trn.id) trngantts_id ,max(trn.key) "key"
										from trngantts trn
										inner join alloctbls a  on a.trngantts_id = trn.id  and a.qty_linkto_alloctbl > 0 
										inner join shelfnos s on s.id = trn.shelfnos_id_trn 
										inner join opeitms ope  on trn.itms_id_trn = ope.itms_id and trn.processseq_trn = ope.processseq
																	and ope.priority = 999
									where a.srctblname = '#{mst_code}' and a.srctblid = #{id}
									group by a.srctblname ,a.srctblid 
								& 
					if trget["remark"] =~ /create by mkord/  and buttonflg =~ /gantt/ ###mkprdpurordsで作成
						# ### gantxxxx
						# ### @ngantts はからのまま
						# @bgantts[@base][:itm_name] = " 下記のtop item の子部品として引き当っています。"
						# @bgantts[@base][:qty] = trget["qty"]
						# @bgantts[@base][:type] = "task"
						# ActiveRecord::Base.connection.select_all(strsql).each_with_index do |trn,idx|
						# 	n0 = 	{:itms_id=>trn["itms_id_org"],:locas_id=>trn["locas_id_org"],:type=>"task",
						# 					:linktblname=>trn["linktblname"],:linktblid=>trn["linktblid"],
						# 					:tblname=>trn["orgtblname"],:tblid=>trn["orgtblid"],:trngantts_id=>trn["id"],
						# 					:orgtblname=>trn["orgtblname"],:orgtblid=>trn["orgtblid"],
						# 					:paretblname=>trn["paretblname"],:paretblid=>trn["paretblid"],
						# 					:parenum=>1,:chilnum=>1,:processseq=>trn["processseq_org"],
						# 					:start=>trn["starttime_org"],:duedate=>trn["duedate_org"],
						# 					:depend => [@level],				
						# 					:qty =>case  trn["srctblname"]
						# 						when  /acts|dlvs|schs/
						# 							0
						# 						else	 
						# 							 trn["qty_src"].to_f
						# 						end,
						# 					:qty_sch =>case  trn["srctblname"]
						# 						when  /schs/
						# 							trn["qty_src"].to_f
						# 						else	 
						# 							0
						# 						end,
						# 					:qty_stk =>case  trn["srctblname"]
						# 						when  /acts/
						# 							trn["qty_src"].to_f
						# 						else	 
						# 							0
						# 						end,
						# 					:id=>@level +  format('%03d',idx) } 
						# 	n0 = get_item_loca_contents(n0,buttonflg) 
						# 	n0[:itm_code] = "top item " + n0[:itm_code] 
						# 	@bgantts[n0[:id]] = n0
						# 	if @max_time < n0[:duedate]
						# 		@max_time = n0[:duedate]
						# 	end
						# 	if @min_time > n0[:start]
						# 		@min_time = n0[:start]
						# 	end
						# end
					else
						ActiveRecord::Base.connection.select_all(strsql).each_with_index do |trn,idx|
							n0 = {:itms_id=>trn["itms_id_trn"],:locas_id=>trn["locas_id_trn"],:type=>"task",
									:depend => [],
									:linktblname=>trn["linktblname"],:linktblid=>trn["linktblid"],
									:tblname=>trn["tblname"],:tblid=>trn["tblid"],:trngantts_id=>trn["trngantts_id"],
									:orgtblname=>trn["orgtblname"],:orgtblid=>trn["orgtblid"],
									:paretblname=>trn["paretblname"],:paretblid=>trn["paretblid"],
									:parenum=>1,:chilnum=>1,:processseq=>trn["processseq_trn"],
									:start=>trn["starttime_trn"],:duedate=>trn["duedate_trn"],									
									:qty =>case  trn["tblname"]
										when  /acts|dlvs|schs|shpests/
											0
										else	 
								 			trn["qty_src"].to_f
										end,
									:qty_sch =>case  trn["tblname"]
										when  /schs|ests/
											trn["qty_src"].to_f
										else	 
											0
										end,
									:qty_stk =>case  trn["tblname"]
										when  /acts|dlvs/
											trn["qty_src"].to_f
										else	 
											0
										end,
									:id=> @level + trn["key"]  }
							n0 = get_item_loca_contents(n0,buttonflg) 
							###  @level = @level  +  format('%03d',idx)
							@ngantts << n0
							if @max_time < n0[:duedate]
								@max_time = n0[:duedate]
							end
							if @min_time > n0[:start]
								@min_time = n0[:start]
							end
						end
					end
				when /custschs|custords/  ###custords,custschs単独の時　custordsがcustschsを引き当てた時
					strsql = %Q&
									select trn.itms_id_trn,s.locas_id_shelfno locas_id_trn,
											trn.orgtblname,trn.orgtblid,trn.paretblname,trn.paretblid,
											trn.tblname,trn.tblid,
											trn.parenum,trn.chilnum,trn.processseq_trn,trn.starttime_trn,trn.duedate_trn,
											trn.id trngantts_id ,trn.qty_sch,trn.qty,trn.qty_stk
										from trngantts trn 
										inner join shelfnos s on s.id = trn.shelfnos_id_trn  
										where  trn.tblid = #{id} and trn.tblname = '#{mst_code}' --- -->画面でclickされたtableのid
							&
					trn = ActiveRecord::Base.connection.select_one(strsql)
					n0 = 	{:itms_id=>trn["itms_id_trn"],:locas_id=>trn["locas_id_trn"],:type=>"task",
								:depend => [],
								:tblname=>trn["tblname"],:tblid=>trn["tblid"],:trngantts_id=>trn["id"],
								:linktblname=>trn["tblname"],:linktblid=>trn["tblid"],
								:orgtblname=>trn["orgtblname"],:orgtblid=>trn["orgtblid"],
								:paretblname=>trn["paretblname"],:paretblid=>trn["paretblid"],
								:parenum=>1,:chilnum=>1,:processseq=>trn["processseq_trn"],
								:start=>trn["starttime_trn"],:duedate=>trn["duedate_trn"],
								:qty_sch =>trn["qty_sch"].to_f ,:qty =>trn["qty"].to_f ,:qty_stk=>trn["qty_stk"].to_f,
								:id=>@level + "000" } 
					
					strsql =	%Q&
							  	---  custordsがcustschsを引き当てた時
								--- org=pare=tblの子供org=pareの時　pare:tblは1:1
								select trn.mlevel ,trn.itms_id_trn,s.locas_id_shelfno locas_id_trn,
										trn.orgtblname,trn.orgtblid,trn.paretblname,trn.paretblid,
										trn.parenum,trn.chilnum,trn.processseq_trn,trn.starttime_trn,trn.duedate_trn,
										l.tblname tblname,l.tblid tblid, trn.alloc_tblname,trn.alloc_tblid, 
										custsch.srctblname linktblname,custsch.srctblid linktblid,---次への引継ぎ
										l.qty_src,trn.id trngantts_id
									from (select t.*,a.srctblname alloc_tblname,a.srctblid alloc_tblid from trngantts t
														inner join alloctbls a 
														on t.id = a.trngantts_id )   trn  ---  custschs
										inner join linkcusts l on l.srctblid = trn.paretblid
										inner join shelfnos s on s.id = trn.shelfnos_id_trn  
										inner join (select a.srctblname,srctblid  from trngantts t 
													inner join alloctbls a on t.id = a.trngantts_id
														and a.qty_linkto_alloctbl > 0 
														and t.mlevel = '1' and t.paretblname = 'custschs') custsch
													on trn.alloc_tblname = custsch.srctblname and  trn.alloc_tblid = custsch.srctblid  
									where l.tblname = 'custords' and l.tblid =  #{n0[:linktblid]} 
										and l.qty_src > 0 and ( l.tblname != l.srctblname or l.tblid !=  l.srctblid)
										and trn.paretblname = 'custschs' and l.tblname = 'custords'
										and trn.mlevel = 1
									& 	
					custschs = ActiveRecord::Base.connection.select_all(strsql)
					n1 =[]
					custschs.each_with_index do |custsch,idx|
						###gantt_id = n0[:id] + "1" + format('%02d',idx)
						n1[idx] =   {:itms_id=>custsch["itms_id_trn"],:locas_id=>custsch["locas_id_trn"],:type=>"task",
									:depend => [],
									:qty_sch =>0 ,:qty =>custsch["qty_src"].to_f ,:qty_stk =>0 ,
									:orgtblname=>custsch["orgtblname"],:orgtblid=>custsch["orgtblid"],
									:paretblname => custsch["paretblname"],:paretblid => custsch["paretblid"],
									:tblname=>custsch["linktblname"],:tblid=>custsch["linktblid"],
									:linktblname=>custsch["linktblname"],:linktblid=>custsch["linktblid"],
									:trngantts_id=>custsch["trngantts_id"],  ###trngantts.tblnameは変化している。
									:parenum=>custsch["parenum"],:chilnum=>custsch["chilnum"],:processseq=>custsch["processseq_trn"],
									:start=>custsch["starttime_trn"],:duedate=>custsch["duedate_trn"],:id=>n0[:id] + "1" + format('%02d',idx)}  
						n0[:depend] << n0[:id] + "1" + format('%02d',idx)
						if @max_time < n1[idx][:duedate]
								@max_time = n1[idx][:duedate]
						end
						if @min_time > n1[idx][:start]
								@min_time = n1[idx][:start]
						end
					end
					n0 = get_item_loca_contents(n0,buttonflg)
					###@level = n0[:id]
					if n1.size > 0 
						@bgantts[n0[:id]] = n0
						n1.each do |nx|
							@ngantts << nx
						end
					else 
						n0[:depend]  << (n0[:id] + "001")
						@bgantts[n0[:id]] = n0
						###@level = n0[:id]
						strsql = %Q&
										select trn.itms_id_trn,s.locas_id_shelfno locas_id_trn,
												trn.orgtblname,trn.orgtblid,trn.paretblname,trn.paretblid,
												a.srctblname tblname,a.srctblid tblid,
												trn.parenum,trn.chilnum,trn.processseq_trn,trn.starttime_trn,trn.duedate_trn,
												trn.id trngantts_id ,trn.qty_sch,trn.qty,trn.qty_stk,(a.qty_linkto_alloctbl) qty_src
												from trngantts trn 
											inner join alloctbls a on a.trngantts_id = trn.id
											inner join shelfnos s on s.id = trn.shelfnos_id_trn  
											where  trn.paretblid = #{id} and trn.paretblname = '#{mst_code}' --- -->画面でclickされたtableのid
											and a.qty_linkto_alloctbl > 0
											and (trn.paretblname != trn.tblname or trn.paretblid != trn.tblid)
								&
						trn = ActiveRecord::Base.connection.select_one(strsql)
						n0 = 	{:itms_id=>trn["itms_id_trn"],:locas_id=>trn["locas_id_trn"],:type=>"task",
									:depend => [],
									:linktblname=>trn["tblname"],:linktblid=>trn["tblid"],
									:tblname=>trn["tblname"],:tblid=>trn["tblid"],:trngantts_id=>trn["id"],
									:orgtblname=>trn["orgtblname"],:orgtblid=>trn["orgtblid"],
									:paretblname=>trn["paretblname"],:paretblid=>trn["paretblid"],
									:parenum=>1,:chilnum=>1,:processseq=>trn["processseq_trn"],
									:start=>trn["starttime_trn"],:duedate=>trn["duedate_trn"],									
									:qty =>case  trn["tblname"]
										when  /acts|dlvs|schs|ests/
											0
										else	 
								 			trn["qty_src"].to_f
										end,
									:qty_sch =>case  trn["tblname"]
										when  /schs|ests/
											trn["qty_src"].to_f
										else	 
											0
										end,
									:qty_stk =>case  trn["tblname"]
										when  /acts|dlvs/
											trn["qty_src"].to_f
										else	 
											0
										end,
									:id=>@level + "001" } 
									
						n0 = get_item_loca_contents(n0,buttonflg) 
						@ngantts << n0
					end
				end
				reverse_linkid = {}
				### pur,pur,custxxxの時　　itms,opitms,nditmsはget_ganttchart_recで展開
				until @ngantts.size == 0   ###子部品の展開
					ngantt = @ngantts.shift
					###@level = ngantt[:id]
					@bgantts[ngantt[:id]] = ngantt
					case buttonflg
					when /gantt/  ###custschs,custordsは対象済
						strsql =	%Q&
								select  max(trn.itms_id_trn) itms_id_trn,max(s.locas_id_shelfno) locas_id_trn,max(trn.orgtblname) orgtblname,
										max(trn.orgtblid) orgtblid,max(trn.paretblname) paretblname,max(trn.paretblid) paretblid,
										alloc.srctblname linktblname,alloc.srctblid linktblid,
										alloc.srctblname tblname,alloc.srctblid tblid,
										max(trn.parenum) parenum,max(trn.chilnum) chilnum,max(trn.processseq_trn) processseq_trn,
										min(trn.starttime_trn) starttime_trn,max(trn.duedate_trn) duedate_trn,
										sum(alloc.qty_linkto_alloctbl) qty_src,max(trn.id) trngantts_id ,max(trn.key) "key"
									from trngantts trn
									inner join (select orgtblname ,tblname,orgtblid,tblid,t.id,
														a.srctblname ,a.srctblid ,a.qty_linkto_alloctbl 
														from trngantts t 
													inner join alloctbls a on a.trngantts_id  = t.id  
													where  a.srctblname = '#{ngantt[:linktblname]}' and a.srctblid = #{ngantt[:linktblid]}
															and a.qty_linkto_alloctbl > 0 ) pare 
										on trn.orgtblname = pare.orgtblname and trn.paretblname = pare.tblname
																and trn.orgtblid = pare.orgtblid and trn.paretblid = pare.tblid
									inner join alloctbls alloc on alloc.trngantts_id = trn.id
																and alloc.qty_linkto_alloctbl > 0
									inner join shelfnos s on s.id = trn.shelfnos_id_trn
								where (trn.tblname != trn.paretblname or trn.tblid != trn.paretblid) 
								group by alloc.srctblname ,alloc.srctblid 
									& 
					else  ###custschs,custordsはganttのみ
						strsql = %Q&
								select  max(trn.itms_id_pare) itms_id_trn,max(s.locas_id_shelfno) locas_id_trn,max(trn.orgtblname) orgtblname,
										max(trn.orgtblid) orgtblid,max(trn.paretblname) paretblname,max(trn.paretblid) paretblid,
										pare.srctblname tblname,pare.srctblid tblid,
										pare.srctblname linktblname,pare.srctblid linktblid,
										max(trn.parenum) parenum,max(trn.chilnum) chilnum,max(trn.processseq_pare) processseq_trn,
										min(trn.starttime_pare) starttime_trn,max(trn.duedate_pare) duedate_trn,
										sum(pare.qty_linkto_alloctbl) qty_src,max(pare.id) trngantts_id ,max(trn.key) "key"
											from trngantts trn
											inner join (select orgtblname ,tblname,orgtblid,tblid,t.id,
																a.srctblname ,a.srctblid ,a.qty_linkto_alloctbl 
																from trngantts t 
															inner join alloctbls a on a.trngantts_id  = t.id  and a.qty_linkto_alloctbl > 0 ) pare 
												on trn.orgtblname = pare.orgtblname and trn.paretblname = pare.tblname
																		and trn.orgtblid = pare.orgtblid and trn.paretblid = pare.tblid
											inner join alloctbls alloc on alloc.trngantts_id = trn.id
											inner join shelfnos s on s.id = trn.shelfnos_id_trn
										where alloc.srctblname = '#{ngantt[:linktblname]}' and alloc.srctblid = #{ngantt[:linktblid]}
											and (trn.tblname != trn.paretblname or trn.tblid != trn.paretblid)
											and alloc.qty_linkto_alloctbl > 0 
										group by pare.srctblname ,pare.srctblid 
							union	---  custords										
								select  (trn.itms_id_pare) itms_id_trn,max(s.locas_id_shelfno) locas_id_trn,(trn.orgtblname) orgtblname,
										(trn.orgtblid) orgtblid,(trn.paretblname) paretblname,(trn.paretblid) paretblid,
										trn.paretblname tblname,trn.paretblid tblid,
										pare.srctblname linktblname,pare.srctblid linktblid,
										(trn.parenum) parenum,(trn.chilnum) chilnum,(trn.processseq_pare) processseq_trn,
										min(trn.starttime_pare) starttime_trn,max(trn.duedate_pare) duedate_trn,
										sum(pare.qty_src) qty_src,(pare.id) trngantts_id ,max(trn.key) "key"
											from trngantts trn
											inner join (select t.orgtblname ,t.tblname,orgtblid,t.tblid,t.id,
																l.srctblname ,l.srctblid ,l.qty_src 
																from trngantts t 
															inner join linkcusts l  on l.trngantts_id  = t.id  and l.srctblid = t.tblid  
															and l.qty_src > 0) pare 
												on trn.orgtblname = pare.orgtblname and trn.paretblname = pare.tblname
																		and trn.orgtblid = pare.orgtblid and trn.paretblid = pare.tblid		
										
										inner join alloctbls alloc on alloc.trngantts_id = trn.id
										inner join shelfnos s on s.id = trn.shelfnos_id_trn
										where alloc.srctblname = '#{ngantt[:linktblname]}' and alloc.srctblid = #{ngantt[:linktblid]}
											and (trn.tblname != trn.paretblname or trn.tblid != trn.paretblid) 
										group by  (trn.itms_id_pare) ,(trn.orgtblname) ,
										(trn.orgtblid) ,(trn.paretblname) ,(trn.paretblid) ,
										trn.paretblname ,trn.paretblid ,
										pare.srctblname ,pare.srctblid ,
										(trn.parenum) ,(trn.chilnum) ,(trn.processseq_pare) ,(pare.id)  
							union  ---  custordsがcustschsを引き当てた時
									--- org=pare=tblの子供org=pareの時　pare:tblは1:1
								select trn.itms_id_trn, s.locas_id_shelfno locas_id_trn,
										trn.orgtblname,	trn.orgtblid,trn.paretblname,trn.paretblid,
										trn.tblname ,trn.tblid,
										'' linktblname ,0 linktblid,
										trn.parenum,trn.chilnum,trn.processseq_trn,
										trn.starttime_trn,trn.duedate_trn,
										l.qty_src,trn.id trngantts_id,max(trn.key) "key"
									from trngantts trn
									inner join shelfnos s on s.id = trn.shelfnos_id_trn 
									inner join linkcusts l on l.tblname = trn.tblname and  l.tblid = trn.tblid
										where l.srctblname = '#{ngantt[:linktblname]}' and l.srctblid = #{ngantt[:linktblid]} 
											and l.qty_src > 0 and ( l.tblname != l.srctblname or l.tblid !=  l.srctblid)
						& 
					end
					n0 = {}
					ActiveRecord::Base.connection.select_all(strsql).each_with_index do |trn,idx|
						###gantt_id = @level + trn["key"] ### format('%03d',idx)
						n0 =   {:itms_id=>trn["itms_id_trn"],:locas_id=>trn["locas_id_trn"],:type=>"task",
								:depend => [],
								:qty =>case  trn["tblname"]
										when  /acts|dlvs|schs|ests/
											0
										else	 
											 trn["qty_src"].to_f
										end,
								:qty_sch =>case  trn["tblname"]
											when  /schs|ests/
												trn["qty_src"].to_f
											else	 
												0
											end,
								:qty_stk =>case  trn["tblname"]
											when  /acts|dlvs/
												trn["qty_src"].to_f
											else	 
												0
											end,
								:orgtblname=>trn["orgtblname"],:orgtblid=>trn["orgtblid"],
								:paretblname => trn["paretblname"],:paretblid => trn["paretblid"],
								:tblname=>trn["tblname"],:tblid=>trn["tblid"],
								:linktblname=>trn["linktblname"],:linktblid=>trn["linktblid"],
								:trngantts_id=>trn["trngantts_id"],  ###trngantts.tblnameは変化している。
								:parenum=>trn["parenum"],:chilnum=>trn["chilnum"],:processseq=>trn["processseq_trn"],
								:start=>trn["starttime_trn"],:duedate=>trn["duedate_trn"],:id=>ngantt[:id] + trn["key"]}  
						if buttonflg =~ /gantt/
							if trn["tblname"] =~ /^prd|^pur|^cust/
								@bgantts[ngantt[:id]][:depend] << ngantt[:id] + trn["key"]
							end
						else
							n0[:depend] << ngantt[:id]
						end
						n0 = get_item_loca_contents(n0,buttonflg) 
						@ngantts << n0
						if @max_time < n0[:duedate]
							@max_time = n0[:duedate]
						end
						if @min_time > n0[:start]
							@min_time = n0[:start]
						end
					end
				end
			end
        	@bgantts[@base][:duedate] = @max_time
        	@bgantts[@base][:start] = @min_time
        	## opeitmのsubtblidのopeitmは子のinsert用
			return @bgantts
    	end

		def get_item_loca_contents(n0,buttonflg)   ##n0[:itms_id] r0[:itms_id]
			  ###:autocreate_instは画面にはセットしない。
				if n0[:itm_code].nil? 
				  		itm = ActiveRecord::Base.connection.select_one("select * from itms where id = #{n0[:itms_id]}  ")
						n0[:itm_code] = itm["code"]
						n0[:itm_name] = itm["name"]
				end
				case n0[:tblname] 
				when /^prd/  
					strsql = %Q&
						select * from #{n0[:tblname]} tbl
							inner join shelfnos shelf on shelf.id = tbl.shelfnos_id
							where tbl.id = #{n0[:tblid]}
					&
					tbl =  ActiveRecord::Base.connection.select_one(strsql)
					if tbl["code"] !=  "000"  ### 000-->same as locas
						n0[:loca_code] = tbl["code"]
						n0[:loca_name] = tbl["name"]
					else
						loca = ActiveRecord::Base.connection.select_one("select * from locas where id = #{tbl["locas_id_shelfno"]}")
						n0[:loca_code] = loca["code"]
						n0[:loca_name] = loca["name"]
					end 
				when /^dvs/  
					strsql = %Q&
						select tbl.code fcode,tbl.name fname,s.code scode,s.name sname from facilities tbl
									inner join shelfnos s on s.id = tbl.shelfnos_id 	
									inner join  #{n0[:tblname]} dvs on tbl.id = dvs.facilities_id where dvs.id = #{n0[:tblid]} 
					&
					tbl =  ActiveRecord::Base.connection.select_one(strsql)
					n0[:loca_code] = tbl["scode"]
					n0[:loca_name] = tbl["sname"]
					n0[:itm_code] = tbl["fcode"]
					n0[:itm_name] = tbl["sname"]
					n0[:processseq] = ""
				when /^erc/  
					strsql = %Q&
						select erc.processname,c.code,c.name from fcoperators f
									inner join (select ch.id,code,name from chrgs ch
															inner join persons p on p.id = ch.persons_id_chrg)   
												c on c.id = f.chrgs_id 	
									inner join  #{n0[:tblname]} erc on f.id = erc.fcoperators_id where erc.id = #{n0[:tblid]} 
					&
					tbl =  ActiveRecord::Base.connection.select_one(strsql)
					n0[:loca_code] = tbl["code"]
					n0[:loca_name] = tbl["name"]
					n0[:itm_code] = tbl["processname"]
					n0[:itm_name] = ""
					n0[:processseq] = ""
				when /^pur/ 
					strsql = %Q&
						select * from #{n0[:tblname]} tbl
							inner join (select l.code ,l.name,s.id supp_id from locas l 
												inner join suppliers s on s.locas_id_supplier = l.id) supp on tbl.suppliers_id = supp.supp_id 
							where tbl.id = #{n0[:tblid]}
					&
					tbl =  ActiveRecord::Base.connection.select_one(strsql)
					n0[:loca_code] = tbl["code"]
					n0[:loca_name] = tbl["name"]
				else
					if n0[:loca_code].nil?
					  	loca = ActiveRecord::Base.connection.select_one("select * from locas where id = #{n0[:locas_id]}  ")
						n0[:loca_code] = loca["code"]
						n0[:loca_name] = loca["name"]
					end
				end
				if @level =~ /trn/
						if n0[:tblname] =~ /^cust|^dym|^dvs|^shp|^erc/ 
							rec = ActiveRecord::Base.connection.select_one("select * from #{n0[:tblname]} where id = #{n0[:tblid]}")
						else
							rec = tbl.dup  ###prd/purの時
						end
						n0[:sno] = rec["sno"]
						case n0[:tblname] 
						when /^shpacts|^puracts/   ### itmclass.code=mold,
							n0[:end] = rec["rcptdate"]
						when /^prdacts|^dvsacts/
							n0[:end] = rec["cmpldate"]
						else
							n0[:end] = rec["duedate"]  ###duedate? rcptdate? cmpldate?
						end
						case n0[:tblname] 
						when /^shp/   ### itmclass.code=mold,ITool
							n0[:start] = rec["depdate"]
						when /schs$/
							n0[:start] = rec["starttime"]
						when /^prd|^dvs/
							n0[:start] = rec["commencementdate"]
						else
							n0[:start] = rec["starttime"]
						end
						if buttonflg =~ /gantt/
							if @bgantts[@level][:start] < n0[:duedate]
								n0[:delay] = true
							else
								n0[:delay] = false
							end
						else
							if @bgantts[n0[:id]][:duedate] > n0[:start]
								n0[:delay] = true
							else
								n0[:delay] = false
							end
						end
				else
				end
			  	@min_time = n0[:start] if (@min_time||=n0[:start]) > n0[:start]
			  	@max_time = n0[:duedate] if (@max_time||= n0[:duedate])  < n0[:duedate]
				###@bgantts[@level] = n0
			return n0
		end
		
		def get_ganttchart_rec(n0)  ###工程の始まり=前工程の終わり nditms,opeitms,itms用
			##strsql = "select * from r_nditms where nditm_opeitm_id = #{n0[:opeitms_id]} 
			###			and nditm_Expiredate > current_date order by itm_code_nditm "
			###rnditms = ActiveRecord::Base.connection.select_all(strsql)
			depend = []
			duedate = n0[:start]
			start = n0[:start]
			###ActiveRecord::Base.connection.select_all(strsql).each_with_index  do |rec,idx|  ###子部品
			ActiveRecord::Base.connection.select_all(ArelCtl.proc_nditmSql(n0[:opeitms_id])).each_with_index  do |rec,idx|  ###子部品
				ope = get_opeitms_id_from_itm_by_processseq(rec["itms_id"],rec["processseq"])
					###new_start = (duedate.to_time - (rec["opeitm_duration"].to_i) * 24 * 60 * 60).strftime("%Y-%m-%d %H:%M:%S") 
				new_qty = n0[:qty].to_f * rec["chilnum"].to_f / rec["parenum"].to_f
				child = {}
				if ope
						nlevel = @level +  format('%07d',idx)
						# strsql = "select * from r_nditms where nditm_opeitm_id = #{ope["id"]}
						# 			and nditm_itm_id_nditm =  #{rec["nditm_itm_id_nditm"]} 
						# 			and nditm_Expiredate > current_date order by itm_code_nditm  "
						# child = ActiveRecord::Base.connection.select_one(strsql)
						##if child
							# if rec["shelfno_code_opeitm"] != "000"
							# 	child["loca_name_shelfno"]=rec["shelfno_name_opeitm"]
							# end
						###else	
								if ope["shelfno_code_opeitm"] == "000"
									child = {"shelfno_loca_id_shelfno"=>ope["shelfno_loca_id_shelfno_opeitm"],
										"loca_code_shelfno"=>ope["loca_code_shelfno_opeitm"],
										"loca_name_shelfno"=>ope["loca_name_shelfno_opeitm"]}
								else
									child = {"shelfno_loca_id_shelfno"=>ope["shelfno_loca_id_shelfno_opeitm"],
										"loca_code_shelfno"=>ope["shelfno_code_opeitm"],
										"loca_name_shelfno"=>ope["shelfno_name_opeitm"]}
								end
						###end
				else
					ope = {}
					ope["id"] = "9999999"
					ope["opeitm_processseq"] = ""
					case rec["classlist_code"]
					when "ITool","mold" ###工具、金型
						strsql = %Q&
								select s.code loca_code_shelfno,s.name loca_name_shelfno
									from lotstkhists l
									inner join shelfnos s on s.id = l.shelfnos_id
									where l.itms_id = #{rec["itms_id"]} and processseq = #{rec["processseq"]}
									and l.qty_stk > 0
									and not exists(select 1 from lotstkhists xx where l.itms_id = xx.itms_id and l.processseq = xx.processseq
														and xx.qty_stk <= 0 and xx.starttime > l.starttime)
									order by l.starttime
						&
						sh = ActiveRecord::Base.connection.select_one(strsql)
						if sh 
							child = {"shelfno_loca_id_shelfno"=>sh["shelfno_loca_id_shelfno"],
									"loca_code_shelfno"=>sh["loca_code_shelfno"],"loca_name_shelfno"=>sh["loca_name_shelfno"]}
						else
							child = {"shelfno_loca_id_shelfno"=>0,"loca_code_shelfno"=>"dummy","loca_name_shelfno"=>"dummy"}
						end
					when "apparatus"   ###装置
						child = {"shelfno_loca_id_shelfno"=>0,"loca_code_shelfno"=>"","loca_name_shelfno"=>""}
					else
						child = {"shelfno_loca_id_shelfno"=>0,"loca_code_shelfno"=>"dummy","loca_name_shelfno"=>"dummy"}
					end
					nlevel = @level +  format('%07d',idx)
				end
				contents = {:opeitms_id=>ope["id"],:processseq=>ope["opeitm_processseq"],
						:start=>start,:duedate=>duedate,  ###startはget_item_loca_contentsでset
						:duration=>rec["duration"],:units_lttime=>rec["units_lttime"],:id=>nlevel,:type=>"task",
						:parenum=>rec["parenum"],:chilnum=>rec["chilnum"],:qty=>new_qty,
						:itms_id=>rec["itms_id"],:itm_code=>rec["itm_code_nditm"],:itm_name=>rec["itm_name_nditm"],
   						:classlist_code=>rec["classlist_code"],
						:changeoverlt=>rec["changeoverlt"],
						:locas_id=>child["shelfno_loca_id_shelfno"],:loca_code=>child["loca_code_shelfno"],
						:loca_name=>child["loca_name_shelfno"]}
				depend << nlevel
				nd =  {"duration"=>contents[:duration],"units_lttime"=>contents[:units_lttime],
				   	"classlist_code"=>contents[:classlist_code],
					"changeoverlt"=>contents[:changeoverlt]}
				contents[:start] = field_starttime(contents[:duedate],nd,"gantt")
				@ngantts << contents
				@bgantts[nlevel] = contents	
				if @max_time < contents[:duedate]
					@max_time = contents[:duedate]
				end
				if @min_time > contents[:start]
					@min_time = contents[:start]
				end
			end
				###depend = get_prev_process(n0,duedate,depend)  ###前工程 nditmsに含まれる。
			@bgantts[@level][:depend] = depend.dup   ###親の依存を調べる。
		end
		
		def get_reverse_chart_rec(n0)  ###工程の始まり=前工程の終わり nditms,opeitms,itms用
			##strsql = "select * from r_nditms where nditm_opeitm_id = #{n0[:opeitms_id]} 
			###			and nditm_Expiredate > current_date order by itm_code_nditm "
			###rnditms = ActiveRecord::Base.connection.select_all(strsql)
			depend = []
			start = n0[:duedate]
			duedate = n0[:duedate]
			###ActiveRecord::Base.connection.select_all(strsql).each_with_index  do |rec,idx|  ###子部品
			ActiveRecord::Base.connection.select_all(ArelCtl.proc_reverse_nditmSql(n0[:itms_id],n0[:processseq])).each_with_index  do |rec,idx|  ###子部品
				new_qty = n0[:qty].to_f / rec["chilnum"].to_f * rec["parenum"].to_f
				pare = {}
					nlevel = @level +  format('%07d',idx)
					if rec["shelfno_code_opeitm"] == "000"
							pare = {"shelfno_loca_id_shelfno"=>rec["shelfno_loca_id_shelfno_opeitm"],
									"loca_code_shelfno"=>rec["loca_code_shelfno_opeitm"],
									"loca_name_shelfno"=>rec["loca_name_shelfno_opeitm"]}
					else
							pare = {"shelfno_loca_id_shelfno"=>rec["shelfno_loca_id_shelfno_opeitm"],
									"loca_code_shelfno"=>rec["shelfno_code_opeitm"],
									"loca_name_shelfno"=>rec["shelfno_name_opeitm"]}
					end
				nlevel = @level +  format('%07d',idx)
				contents = {:opeitms_id=>rec["opeitms_id"],:processseq=>ope["processseq_pare"],
						:start=>start,:duedate=>duedate,  ###startはget_item_loca_contentsでset
						:duration=>rec["duration"],:units_lttime=>rec["units_lttime"],:id=>nlevel,:type=>"task",
						:parenum=>rec["parenum"],:chilnum=>rec["chilnum"],:qty=>new_qty,
						:itms_id=>rec["itms_id"],:itm_code=>rec["itm_code_nditm"],:itm_name=>rec["itm_name"],
   						:classlist_code=>"",:changeoverlt=>0,
						:locas_id=>pare["shelfno_loca_id_shelfno"],:loca_code=>pare["loca_code_shelfno"],
						:loca_name=>pare["loca_name_shelfno"]}
				depend << nlevel
				nd =  {"duration"=>contents[:duration],"units_lttime"=>contents[:units_lttime],
				   	"classlist_code"=>"","changeoverlt"=>0,}
				contents[:duedate] = field_starttime(contents[:start],nd,"reverse")
				@ngantts << contents
				@bgantts[nlevel] = contents	
				if @max_time < contents[:duedate]
					@max_time = contents[:duedate]
				end
				if @min_time > contents[:start]
					@min_time = contents[:start]
				end
			end
				###depend = get_prev_process(n0,duedate,depend)  ###前工程 nditmsに含まれる。
			@bgantts[@level][:depend] = depend.dup   ###親の依存を調べる。
		end
	
		
	def field_starttime startEnd,nd,reverse
		###if tblnamechop =~ /dvs|erc/
			Rails.logger.debug " class:#{self} ,line:#{__LINE__},startEnd:#{startEnd} "
			Rails.logger.debug " class:#{self} ,line:#{__LINE__},nd:#{nd} "
		###end
		if reverse == "reverse"
			cal = -1
		else
			cal = 1
		end
		case nd["units_lttime"]  ###char(4)
		when "Day "
			dayHour = 24*3600   ###  duedate 16:00   starttime 10:00
		when "Hour"
			dayHour = 3600
		else 
			dayHour = 1
			starttime = Time.now
		end

		startEnd =  startEnd.to_time

		starttime = startEnd - (nd["duration"]||=1).to_f*dayHour * cal
	
		return starttime
	end

	
		def get_opeitms_id_from_itm_by_processseq itms_id,processseq  ###
				strsql = %Q& select * from r_opeitms where opeitm_itm_id = #{itms_id} 
						 	and opeitm_processseq = #{processseq} and opeitm_priority = 999 and opeitm_expiredate > current_date &
				ope = ActiveRecord::Base.connection.select_one(strsql)
			return ope
		end
	
		def get_ordtbl_ordid tblname,tblid
			if tblname =~ /ords$/
				strsql %Q&select srctblname,srctblid from linktbls 
										where tblname = '#{tblname} and tblid = #{tblid}		
				&
				ord = ActiveRecord::Base.connection.select_one(strsql)
				tblid = ord["srctblid"]
				tblname = ord["srctblname"]
			end	
			return tblname,tblid
		end
       
		def update_opeitm_from_gantt(copy_opeitm,value ,command_r)
			if copy_opeitm
				copy_opeitm.each do |k,v|
					command_r["#{k}"] = v if k =~ /^opeitm_/
				end
			end
			command_r["opeitm_itm_id"] = value[:itm_id]
			command_r["opeitm_loca_id_opeitm"] = value[:loca_id]
			command_r["sio_viewname"]  = command_r["sio_code"] = @screen_code = "r_opeitms"
			command_r["opeitm_priority"] = value[:priority]
			command_r["opeitm_processseq"] = value[:processseq]
			command_r["opeitm_prdpur"] = value[:prdpur]
			command_r["opeitm_parenum"] = value[:parenum]
			command_r["opeitm_chilnum"] = value[:chilnum]
			command_r["opeitm_duration"] = value[:duration]
			### command_r["opeitm_person_id_upd"] = command_r["sio_user_code"]
        	command_r["opeitm_expiredate"] = Time.parse("2099/12/31")
			yield
			proc_simple_sio_insert command_r  ###重複チェックは　params[:tasks][@tree[key]][:processseq] > value[:processseq]　が確定済なので不要
		end

	def update_nditm_from_gantt(key,value ,command_r)
		strsql = "select id from opeitms  
					where itms_id = #{params[:tasks][@tree[key]][:itm_id]} and 
					locas_id_shelfno = #{params[:tasks][@tree[key]][:shelfno_loca_id_shelfno_opeitm]} and
					processseq = #{params[:tasks][@tree[key]][:processseq]} and priority = #{params[:tasks][@tree[key]][:priority]}"
		pare_opeitm_id = ActiveRecord::Base.connection.select_value(strsql)
		if pare_opeitm_id
			###削除されてないか、再度確認
			yield
			update_nditm_rec(pare_opeitm_id,value ,command_r)
			##else
			##end
		else
			@ganttdata[key][:itm_name] = "opeitms is null line #{__LINE__} ,opeitm_id = #{pare_opeitm_id} "
			@err = true
		end
	end
	def chk_alreadt_exists_nditm(command_r)
		strsql = "select 1 from nditms where  opeitms_id = #{command_r["nditm_opeitm_id"]} and  itm_id_nditm = #{command_r["nditm_itm_id_nditm"]} and
					processseq_nditm = #{command_r["nditm_processseq_nditm"]} and   locas_id_nditm  = #{command_r["nditm_loca_id_nditm"]} "
		if ActiveRecord::Base.connection.select_one (strsql)
			@ganttdata[key][:itm_name] = " ??? !!! already exists !!!"
			@err= true
		end
	end
	def update_nditm_rec(pare_opeitm_id,value ,command_r)
		command_r["sio_viewname"]  = command_r["sio_code"] = @screen_code = "r_nditms"
		if value[:itm_id]
			command_r["nditm_itm_id_nditm"] = value[:itm_id]
			command_r["nditm_opeitm_id"] = pare_opeitm_id
			if value[:loca_id]
				command_r["nditm_loca_id_nditm"] = value[:loca_id]
				command_r["nditm_processseq_nditm"] = value[:processseq]
				command_r["nditm_expiredate"] = Time.parse("2099/12/31")
				command_r["nditm_parenum"] = value[:parenum]
				command_r["nditm_chilnum"] = value[:chilnum]
				command_r["nditm_duration"] = value[:duration]
				command_r["nditm_expiredate"] = Time.parse("2099/12/31")
				chk_alreadt_exists_nditm(command_r) if command_r["sio_classname"] =~ /_add_/
				proc_simple_sio_insert command_r  if @err == false
			else
				@ganttdata[key][:loca_code] = "???" 
				@err = true
			end
		else
			@ganttdata[key][:itm_code] = "???"
			@err = true
		end
	end
    def exits_opeitm_from_gantt(key,value ,command_r) ###画面の内容をcommand_r from gantt screen
		###itm_codeでユニークにならない時内容が保証されない。  processseq,priorityは必須
		strsql = "select * from r_opeitms where itm_code = '#{value["copy_itemcode"]}' and opeitm_processseq = 999 and opeitm_priority = 999 "
		copy_opeitm = ActiveRecord::Base.connection.select_one(strsql)
		if value[:opeitms_id]
			opeitm = ActiveRecord::Base.connection.select_one("select * from opeitms where id = #{value[:opeitms_id]} ")
			if opeitm
				if opeitm["itms_id"].to_s == value[:itm_id] and opeitm["processseq"].to_s == value[:processseq] and opeitm["priority"].to_s == value[:priority]
					update_opeitm_from_gantt(copy_opeitm,value ,command_r) do
						command_r["sio_classname"] = "_edit_opeitms_rec"
						command_r["opeitm_id"] = command_r["id"] = opeitm["id"]
					end
				else
					strsql = "select * from r_opeitms where itm_code = '#{value["copy_itemcode"]}' and
										 loca_code_opeitm = '#{value["loca_code"]}' and opeitm_processseq = #{value[:processseq]} "
					if ActiveRecord::Base.connection.select_one(strsql)
						@ganttdata[key][:priority] = "???"  ###priority違いで同じものがいる。
					else
						update_opeitm_from_gantt(copy_opeitm,value ,command_r) do
							command_r["sio_classname"] = "_edit_opeitms_rec"
							command_r["opeitm_id"] = command_r["id"] = opeitm["id"]
						end
					end
				end
			else
				@ganttdata[key][:itm_name] = "logic error LINE : #{__LINE__}"
				@err = true
			end
		else
			if copy_opeitm
				update_opeitm_from_gantt(copy_opeitm,value ,command_r)do
					command_r["sio_classname"] = "_add_opeitm_rec"
					command_r["opeitm_id"] = command_r["id"] = ArelCtl.proc_get_nextval("opeitms_seq")
				end
				params[:tasks][key][:opeitms_id] = command_r["opeitm_id"]
			else
				@ganttdata[key][:copy_itemcode] = "???"
				@err = true
			end
		end
	end
    def exits_nditm_from_gantt(key,value ,command_r) ###画面の内容をcommand_r from gantt screen
		if value[:nditms_id]
			r_nditm = ActiveRecord::Base.connection.select_one("select * from r_nditms where id = #{value[:nditms_id]} ")
			if r_nditm
				update_nditm_from_gantt(key,value ,command_r) do
					command_r["sio_classname"] = "_edit_nditm_rec"
					command_r["nditm_id"] = command_r["id"] = value[:nditms_id]
				end
			else ###
				@ganttdata[key][:itm_name] = "logic error  line #{__LINE__} "
				@err = true
			end
		else
			update_nditm_from_gantt(key,value ,command_r) do
				command_r["sio_classname"] = "_add_nditm_rec"
				command_r["nditm_id"] = command_r["id"] = ArelCtl.proc_get_nextval("nditms_seq")
			end
		end
	end

	def chk_opeitm_nditm_from_gantt(key,value ,command_r)
		if @tree[key]
			if  params[:tasks][@tree[key]][:itm_code] == value[:itm_code]
				if params[:tasks][@tree[key]][:processseq] > value[:processseq]
					if (params[:tasks][@tree[key]][:priority] > value[:priority] and params[:tasks][@tree[key]][:priority] == 999) or params[:tasks][@tree[key]][:priority] == value[:priority]
						if value[:prdpur] =~ /^prd|^pur/  ### prd,pur,shp以外に増えたときの対応
							exits_opeitm_from_gantt(key,value ,command_r)
						else
							@ganttdata[key][:prdpur] = "???"
							@err = true
						end
					else ###作業の一貫性
						@ganttdata[key][:priority] = "???"
						@err = true
					end
				else  ###seq error
					@ganttdata[key][:processseq] = "???"
					@err = true
				end
			else   ###nditms追加
				if  value[:processseq] =~ /999|1000/  ###品目違いの時はprocessseq == 999
					value[:processseq] = "999"
					if (params[:tasks][@tree[key]][:priority] > value[:priority] and params[:tasks][@tree[key]][:priority] == 999) or params[:tasks][@tree[key]][:priority] == value[:priority]
						if value[:itm_id] != "" and value[:shelfno_loca_id_shelfno_opeitm] != ""
							strsql = "select id from opeitms where itms_id = #{value[:itm_id]} and 
																processseq = #{value[:processseq]} and priority = #{value[:priority]} "
							ope = ActiveRecord::Base.connection.select_one(strsql)
							if value[:prdpur] =~ /^prd|^pur/  ### prd,pur,shp以外に増えたときの対応
								if  ope.nil?
									strsql = "select * from r_opeitms where itm_code = '#{value["copy_itemcode"]}' and opeitm_processseq = 999 and
																			 opeitm_priority = 999 "
									copy_opeitm = ActiveRecord::Base.connection.select_one(strsql)
									if copy_opeitm
										update_opeitm_from_gantt(copy_opeitm,value ,command_r)do
											command_r["sio_classname"] = "_add_opeitm_rec"
											command_r["opeitm_id"] = command_r["id"] = ArelCtl.proc_get_nextval("opeitms_seq")
										end
										params[:tasks][key][:opeitms_id] = command_r["opeitm_id"]
										blk =  RorBlkCtl::BlkClass.new("r_nditms")
										command_c = blk.command_init
										command_r["sio_session_counter"] =   @sio_session_counter
										exits_nditm_from_gantt(key,value ,command_r)
									else
										@ganttdata[key][:copy_itemcode] = "???"
										@err = true
									end
								else
									exits_nditm_from_gantt(key,value ,command_r)
								end
							else
								@ganttdata[key][:prdpur] = "???"
								@err = true
							end
						else
							@ganttdata[key][:itm_code] = @ganttdata[key][:loca_code] = "???"
							@err = true
						end
					else ###作業の一貫性
						@ganttdata[key][:priority] = "???"
						@err = true 
					end
				else  ###seq error
					@ganttdata[key][:processseq] = "???"
					@err = true
				end
			end
		else
			### topの時
			if value[:processseq]  == "999"
				if  value[:priority]
					if value[:prdpur] =~ /^prd|^pur/  ### prd,pur,shp以外に増えたときの対応
						exits_opeitm_from_gantt(key,value ,command_r)
					else
						@ganttdata[key][:prdpur] = "???"
						@err = true
					end
				else ###作業の一貫性
					@ganttdata[key][:priority] = "???"
					@err = true
				end
			else  ###seq error
				@ganttdata[key][:processseq] = "???"
				@err = true
			end
		end
	end

	###
	###  nditmsのチェックができれば不要では？
	###
	def uploadgantt params  ### trnは別
		ActiveRecord::Base.connection.begin_db_transaction()
        params["person_id_upd"] =  ActiveRecord::Base.connection.select_value("select id from persons where email = '#{reqparams["email"]}'")   ###########   LOGIN USER
		@sio_session_counter = user_seq_nextval
		@ganttdata = params[:tasks]
		@err = false
		@tree = {}   ###親のid
        params[:tasks].each do |key,value|
			value[:depend].split(",").each do |i|  ###子の親は必ず1つ　副産物も子として扱う
				@tree[i] = key
			end
			case value[:id]
                when  "000" then
                ##top record
                   next
                when /gantttmp/  then ### レコード追加
					if value[:itm_id] and  value[:processseq] =~ /[000-1000]/ and value[:priority] =~ /[000-999]/
						blk =  RorBlkCtl::BlkClass.new("r_opeitms")
						command_r = blk.command_init
						chk_opeitm_nditm_from_gantt(key,value ,command_r)
					else
						if value[:itm_id].nil? then 
							@ganttdata[key][:itm_code] = "???"
							@err = true 
						end
						if value[:processseq] !~ /[000-1000]/  then 
							@ganttdata[key][:processseq]  = "???"
							@err = true
						end
						if value[:priority] !~ /[000-999]/ then 
							@ganttdata[key][:priority] = "???"
							@err = true 
						end
					end
                when /opeitms/   ###追加更新もある?\
					params[:tasks][key][:opeitms_id] = value[:id].split("_")[1].to_i
					blk =  RorBlkCtl::BlkClass.new("r_opeitms")
					command_r = blk.command_init
					chk_opeitm_nditm_from_gantt(key,value ,command_r)
				when /nditms/
					params[:tasks][key][:nditms_id] = value[:id].split("_")[1].to_i
					blk =  RorBlkCtl::BlkClass.new("r_nditms")
					command_r = blk.command_init
					chk_opeitm_nditm_from_gantt(key,value ,command_r)  ### 子品目から前工程に変更されることもある。
				else
				    logger.debug "#{Time.now} #{__LINE__} new option????? not support   value #{value}"
            end
        end
		###画面のラインを削除された時
		if params[:deletedTaskIds] and @err == false
			params[:deletedTaskIds].each do |del_rec|
				tbl,id = del_rec.split("_")
				case tbl
					when "nditms"
						command_r["sio_classname"] = "_delete_nditm_rec"
						screencode = "r_nditms"
					when "opeitms"
						command_r["sio_classname"] = "_delete_opeitm_rec"
						screencode = "r_opeitms"
				end
				blk =  RorBlkCtl::BlkClass.new(screenCode)
				command_c = blk.command_init
				case tbl
					when "nditms"
						command_r["nditm_id"] = command_r["id"] = id.to_i
					when "opeitms"
						command_r["sio_classname"] = "_delete_opeitm_rec"
				end
				blk.proc_insert_sio_r(command_r)
			end
		end
		if @err == false
			ActiveRecord::Base.connection.commit_db_transaction()
			render :json=>'{"result":"ok"}'
		else
			## logger.debug  "#{Time.now} #{__LINE__} :#{@ganttdata} "
			ActiveRecord::Base.connection.rollback_db_transaction()
			strgantt = '{"tasks":['
			@ganttdata.each  do|key,value|
				strgantt << %Q&{"id":"#{value[:id]}","itm_code":"#{value[:itm_code]}","itm_name":"#{value[:itm_name]}",
				"loca_code":"#{value[:loca_code]}","loca_name":"#{value[:loca_name]}",
				"loca_id":"#{value[:loca_id]}","itm_id":"#{value[:itm_id]}",
				"parenum":"#{value[:parenum]}","chilnum":"#{value[:chilnum]}","start":#{value[:start]},"duration":"#{value[:duration]}",
				"end":#{value[:duedate]},"assigs":[],"depends":"#{value[:depend]}",
				"processseq":"#{value[:processseq]}","priority":"#{value[:priority]}","prdpur":"#{value[:prdpur]}",
				"subtblid":"#{value[:subtblid]}","paretblcode":""},&
			end
        ## opeitmのsubtblidのopeitmは子のinsert用
			@ganttdata = strgantt.chop + %Q|],"selectedRow":11,"deletedTaskIds":[],"canWrite":true,"canWriteOnParent":true }|
			render :json=>@ganttdata
		end
	end

		def prv_resch   ##本日を起点に再計算

			today = Time.now
			@bgantts.sort.reverse.each  do|key,value|  ###計算
				if key.size > 3  ###master は分割はない
					if  value[:depend] == ""
						if @bgantts[key][:start]  <  today
							@bgantts[key][:start]  =  today
							@bgantts[key][:duedate]  =   @bgantts[key][:start] + value[:duration]*24*60*60    ###稼働日考慮今なし
						end
					end
					 logger.debug  "### "
					 logger.debug  "### #{Time.now} #{__LINE__} :#{@ganttdata} "
					 logger.debug  "###"
					raise if @bgantts[key][:duedate].nil? or @bgantts[key[0..-4]][:start].nil?
					if  (@bgantts[key[0..-4]][:start] ) < @bgantts[key][:duedate]
						@bgantts[key[0..-4]][:start]  =   @bgantts[key][:duedate]   ###稼働日考慮今なし
						@bgantts[key[0..-4]][:duedate] =  @bgantts[key[0..-4]][:start]  + @bgantts[key[0..-4]][:duration] *24*60*60
					end
				end
			end

			@bgantts.sort.each  do|key,value|  ###topから再計算
				if key.size > 3
					if  (@bgantts[key[0..-4]][:start]  ) > @bgantts[key][:duedate]
						@bgantts[key][:duedate]  =   @bgantts[key[0..-4]][:start]    ###稼働日考慮今なし
						@bgantts[key][:start] =  @bgantts[key][:duedate]  - value[:duration] *24*60*60
					end
				end
			end
      		return
    	end   

    	def get_duration_by_loca(loca_id_fm,loca_id_to,priority)
        {:duration=>1,:transport_id =>ActiveRecord::Base.connection.select_value("select id from transports where code = 'dummy' ")}
    	end
   		def proc_get_opeitms_id_from_itm itms_id ###
			strsql = %Q& select max(processseq) from opeitms where itms_id = #{itms_id} 
					 and expiredate > current_date group by itms_id &
			max_processseq = ActiveRecord::Base.connection.select_value(strsql)
			if max_processseq 
				strsql = %Q& select max(priority) from opeitms where itms_id = #{itms_id} 
					 and processseq =#{max_processseq} and expiredate > current_date group by itms_id &
				max_priority = ActiveRecord::Base.connection.select_value(strsql)
				if max_priority
					strsql = %Q& select id from opeitms where itms_id = #{itms_id} 
						 and processseq =#{max_processseq} and priority =#{max_priority} and expiredate > current_date &
					opeitms_id = ActiveRecord::Base.connection.select_value(strsql)
				else 
					opeitms_id = nil	
				end		
			else
				opeitms_id = nil
			end		
			return opeitms_id
		end
	 end
end    
