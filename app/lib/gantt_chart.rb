# -*- coding: utf-8 -*-
# 2099/12/31を修正する時は　2100/01/01の修正も
module GanttChart
    extend self
	class GanttClass
		def initialize(gantt_reverse)
			@bgantts = {}  ###全体のtree構造　keyは階層レベル
        	@ngantts = []  ###親直下の子ども処理用
			@level = "000"
			@err = false
			if gantt_reverse =~ /gantt|mst/
				@base = "000"
			else
				@base = "999"
			end
		end

    	def  proc_get_ganttchart_data(mst_code,id,gantt_reverse)   ###opeims_idはある。
        	time_now =  Time.now
			case gantt_reverse
			when /mst/
				if gantt_reverse =~ /gantt/
					@min_time = "2099-12-31"
					@max_time = Time.now.strftime("%Y-%m-%d")
				else
					@max_time =  Time.now.strftime("%Y-%m-%d")
					@min_time = Time.now.strftime("%Y-%m-%d")
				end
				@bgantts[@base] = {:itm_code=>"",:itm_name=>"全行程",:loca_code=>"",:loca_name=>"",:opeitms_id=>"0",
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
						@ngantts << {	:itms_id=>rec["opeitm_itm_id"],:locas_id=>rec["shelfno_loca_id_shelfno_opeitm"],:opeitms_id=>rec["id"],
										:itm_code=>rec["itm_code"],:itm_name=>rec["itm_name"],:qty=>1,:depend => [],:type=>"task",
										:loca_code=>rec["loca_code_shelfno_opeitm"],:loca_name=>rec["loca_name"],
										:parenum=>1,:chilnum=>1,:duration=>rec["opeitm_duration"],:prdpur=>rec["opeitm_prdpur"],
										:processseq=>"#{if mst_code =~ /^itms/ then '999' else  rec["opeitm_processseq"] end}",
										:priority=>"#{if mst_code =~ /^itms/ then '999' else rec["opeitm_priority"] end}",
										:start=>@min_time,:duedate=>@max_time,:id=>@level+ format('%07d',id.to_i)}  ###:id=>ganttのkey
					when "nditms"
						case gantt_reverse
						when /gantt/
								@ngantts << {	:itms_id=>rec["opeitm_itm_id"],:locas_id=>rec["shelfno_loca_id_shelfno_opeitm"],:type=>"task",
										:opeitms_id=>rec["nditm_opeitm_id"],:itm_code=>rec["itm_code"],:itm_name=>rec["itm_name"],:qty=>1,
										:loca_code=>rec["loca_code_shelfno_opeitm"],:loca_name=>rec["loca_name_shelfno_opeitm"],:depend => [],
										:parenum=>1,:chilnum=>1,:duration=>rec["opeitm_duration"],:prdpur=>rec["opeitm_prdpur"],
										:processseq=>rec["nditm_processseq"],
										:start=>@min_time,:duedate=>@max_time,:id=>@level+format('%07d',id.to_i)}  ###:id=>
						when "reverse"
								ope = ActiveRecord::Base.connection.select_one("select ope.*,shelf.locas_id_shelfno locas_id from opeitms ope
																	inner join shelfnos shelf on shelf.id = ope.shelfnos_id_opeitm 
																	where ope.itms_id = #{rec["itm_id_nditm"]} 
																	and ope.processseq = #{rec["nditm_processseq"]}
																	and ope.Expiredate > current_date")
								@ngantts << {	:itms_id=>rec["itm_id_nditm"],:locas_id=>ope["locas_id_shelfno"],:type=>"task",
										:opeitms_id=>ope["id"],:qty=>1,:depend => [],
										:parenum=>1,:chilnum=>1,:duration=>ope["duration"],:prdpur=>ope["prdpur"],
										:processseq=>ope["processseq"],:priority=>ope["priority"],
										:start=>@max_time,:duedate=>@min_time,:id=>@level+format('%07d',id.to_i)}  ###:
						end
					end
					cnt = 0
					until @ngantts.size == 0
						cnt += 1
						get_tree_itms_locas(gantt_reverse)  ###trngantt 作成時も利用
						break if cnt >= 1000
					end
				else
				end
			when /trn/
				@bgantts[@base] = {:itm_code=>"",:itm_name=>"全行程",:loca_code=>"",:loca_name=>"",:opeitms_id=>"0",
												:type=>"project",:depend => [""],:id=>@level}
				case mst_code
				when /purords|prdords|purschs|prdschs/
						strsql = %Q&
								select trn.* ,alloc.srctblname,alloc.srctblid,alloc.qty_linkto_alloctbl 
										from trngantts trn 
										inner join  alloctbls    alloc   on alloc.trngantts_id = trn.id
										where  alloc.srctblid = #{id} and alloc.srctblname = '#{mst_code}'
										and alloc.qty_linkto_alloctbl > 0
							&
						trns = ActiveRecord::Base.connection.select_all(strsql)
						trns.each.each_with_index do |trn, idx|  ###custordsがcustschsを引き当てた時も考慮
							if trn["srctblname"] =~ /dlvs|acts/
										qty = 0
										qty_stk = trn["qty_linkto_alloctbl"].to_f
							else 
										qty_stk = 0
										qty = trn["qty_linkto_alloctbl"].to_f
							end
							@ngantts << {	:itms_id=>trn["itms_id_trn"],:locas_id=>trn["locas_id_trn"],:type=>"task",
								:depend => [],:key=>trn["key"],:tblname=>trn["srctblname"],:tblid=>trn["srctblid"],
								:qty=>qty ,:qty_stk=>qty_stk,:trngantts_id=>trn["id"],
								:orgtblname=>trn["orgtblname"],:orgtblid=>trn["orgtblid"],
								:parenum=>1,:chilnum=>1,:processseq=>trn["processseq_trn"],
								:start=>trn["starttime_trn"],:duedate=>trn["duedate_trn"],
								:key=>trn["key"],:id=>@level + format('%07d',id.to_i) + trn["key"]} ###id-->画面でclickされたtableのid
						end
				when /custschs|custords/  ###custords,custschs単独の時　custordsがcustschsを引き当てた時
					strsql = %Q&
								select trn.*,link.tblname basetblname,link.tblid basetblid,link.qty_src,
												link.srctblname,link.srctblid 
												from trngantts trn ---custschsに引き当らなった時も同じ
												inner join  linkcusts  link	on link.trngantts_id = trn.id
										where link.tblid = #{id}  and link.tblname =  '#{mst_code}'
					&
					trns = ActiveRecord::Base.connection.select_all(strsql)
					trns.each.each_with_index do |trn, idx|  ###custordsがcustschsを引き当てた時も考慮
						qty = 	if trn["qty_src"].to_f > (trn["qty"].to_f + trn["qty_sch"].to_f)
									(trn["qty"].to_f + trn["qty_sch"].to_f)
								else 
									trn["qty_src"].to_f 
								end
						qty_stk = 	 trn["qty_src"].to_f  - qty
						if trn["basetblname"] == trn["srctblname"] and trn["basetblid"] == trn["srctblid"]
							@ngantts << {:itms_id=>trn["itms_id_trn"],:locas_id=>trn["locas_id_trn"],:type=>"task",
								:depend => [],:key=>trn["key"],:tblname=>trn["tblname"],:tblid=>trn["tblid"],
								:qty=>qty,:qty_stk=>qty_stk,:orgtblname=>trn["orgtblname"],:orgtblid=>trn["orgtblid"],
								:parenum=>1,:chilnum=>1,:processseq=>trn["processseq_trn"],:trngantts_id=>trn["id"],
								:start=>trn["starttime_trn"],:duedate=>trn["duedate_trn"],
								:paretblname =>trn["paretblname"],
								:key=>trn["key"],:id=>@level + format('%07d',id.to_i) + trn["key"]} 
						else  
							ngantt =  {:itms_id=>trn["itms_id_trn"],:locas_id=>trn["locas_id_trn"],:type=>"task",
								:depend => [],:key=>trn["key"],:tblname=>trn["tblname"],:tblid=>trn["tblid"],
								:qty=>qty,:qty_stk=>qty_stk,:orgtblname=>trn["orgtblname"],:orgtblid=>trn["orgtblid"],
								:parenum=>1,:chilnum=>1,:processseq=>trn["processseq_trn"],:trngantts_id=>trn["id"],
								:start=>trn["starttime_trn"],:duedate=>trn["duedate_trn"],
								:key=>trn["key"],:id=>@level + format('%07d',id.to_i) + trn["key"]} 
							ngantt = get_item_loca_contents(ngantt,"gantt")
							@bgantts[ngantt[:id]] = ngantt
							ord = ActiveRecord::Base.connection.select_one("select * from trngantts where id = #{trn["id"]}")
							ngantt[:orgtblname] = ord["orgtblname"]
							ngantt[:orgtblid] = ord["orgtblid"]
							ngantt[:start] = ord["starttime_trn"]
							ngantt[:duedate] = ord["duedate_trn"],
							ngantt["key"] = ord[key]
							ngantt[:id] = @level + format('%07d',ord["orgtblid"].to_i) + ord["key"]
							@bgantts[ngantt[:id]][:depend] << ngantt[:id]
							@ngantts << ngantt  
						end
					end
				end
				until @ngantts.size == 0
					ngantt = @ngantts.shift
					ngantt = get_item_loca_contents(ngantt,gantt_reverse) 
					@bgantts[ngantt[:id]] = ngantt
					case gantt_reverse
					when /gantt/  ###custschs,custordsはganttのみ
						strsql =	%Q&
										select trn.*,link.srctblname,link.qty_linkto_alloctbl qty_src,link.srctblid ,pare.key pare_key,trn.key child_key
											from trngantts trn
											inner join alloctbls link  on link.trngantts_id = trn.id  and link.qty_linkto_alloctbl > 0 
											inner join trngantts pare on pare.tblname = trn.paretblname and  pare.tblid = trn.paretblid
										where pare.tblname = '#{ngantt[:tblname]}' and pare.tblid = #{ngantt[:tblid]}
										and  pare.key = '#{ngantt[:key]}' and pare.id = #{ngantt[:trngantts_id]}
										and  trn.id != pare.id
									& 
					else  ###custschs,custordsはganttのみ
						strsql = %Q&
								select trn.*,a.srctblname,a.qty_linkto_alloctbl qty_src,a.srctblid ,child.key child_key,trn.key pare_key
											from trngantts trn
											inner join alloctbls a  on a.trngantts_id = trn.id and a.qty_linkto_alloctbl > 0
											inner join (select t.*,a.srctblname,a.srctblid from trngantts t
																inner join alloctbls a on a.trngantts_id = t.id and a.qty_linkto_alloctbl > 0) child
													on child.orgtblname = trn.orgtblname and  child.orgtblid = trn.orgtblid
														and child.paretblname = trn.tblname and  child.paretblid = trn.tblid
									where child.srctblname = '#{ngantt[:tblname]}' and child.srctblid = #{ngantt[:tblid]}
									and child.key = '#{ngantt[:key]}' and child.id = #{ngantt[:trngantts_id]}
									and  trn.id != child.id 
						& 
					end
					ActiveRecord::Base.connection.select_all(strsql).each do |trn|
						gantt_id = @level +  format('%07d',trn["orgtblid"].to_i) + trn["key"]
						pare_gantt_id = @level + format('%07d',trn["orgtblid"].to_i) + trn["pare_key"]
						child_gantt_id = @level + format('%07d',trn["orgtblid"].to_i) + trn["child_key"]
						n0 =   {:itms_id=>trn["itms_id_trn"],:locas_id=>trn["locas_id_trn"],:type=>"task",
								:depend => [],:key=>trn["key"],
								:qty =>if trn["srctblname"] =~ /acts/ then  0 else trn["qty_src"].to_f end,
								:qty_stk =>if trn["srctblname"] =~ /acts/ then  trn["qty_src"].to_f else 0 end,
								:orgtblname=>trn["orgtblname"],:orgtblid=>trn["orgtblid"],:paretblname => trn["paretblname"],
								:tblname=>trn["srctblname"],:tblid=>trn["srctblid"],:trngantts_id=>trn["id"],  ###trngantts.tblnameは変化している。
								:parenum=>trn["parenum"],:chilnum=>trn["chilnum"],:processseq=>trn["processseq_trn"],
								:start=>trn["starttime_trn"],:duedate=>trn["duedate_trn"],:id=>gantt_id}  
						if gantt_reverse =~ /gantt/
							@bgantts[pare_gantt_id][:depend] << gantt_id
						else
							n0[:depend] << child_gantt_id
						end
						@ngantts << n0
					end
				end
			end
        	##prv_resch  	if gantt_reverse =~ /^gantt/  ####再計算
        		@bgantts[@base][:duedate] = @max_time
        		@bgantts[@base][:start] = @min_time
        	## opeitmのsubtblidのopeitmは子のinsert用
			return @bgantts
    	end

		
    	def get_tree_itms_locas(gantt_reverse) ### bgantts 表示内容　ngantt treeスタック  itms_idは必須
			n0 = @ngantts.shift
			@level = n0[:id]
		  	if n0.size > 0  ###子部品がいなかったとき{}になる。
				n0 = get_item_loca_contents(n0,gantt_reverse)
				@bgantts[@level] = n0
				if n0[:opeitms_id]
			  		case gantt_reverse
			  		when /gantt/
						get_ganttchart_data(n0)
			  		when /reverse/
						vproc_get_pare_itms(n0,n0[:duedate])
				  		#@ngantts.concat(tmp) if tmp[0].size > 0
				  		# tmp = vproc_get_after_process(n0,duedate)
				  		# @ngantts.concat(tmp) if tmp[0].size > 0
			  		end
				else
					###opeitms_id未登録　pur,prd対象外品
				end
		  	end
	  	end  ##

		def get_item_loca_contents(n0,gantt_reverse)   ##n0[:itms_id] r0[:itms_id]
			  ###:autocreate_instは画面にはセットしない。
				if n0[:itm_code].nil? 
				  		itm = ActiveRecord::Base.connection.select_one("select * from itms where id = #{n0[:itms_id]}  ")
						n0[:itm_code] = itm["code"]
						n0[:itm_name] = itm["name"]
				end
				if n0[:loca_code].nil?
					  	loca = ActiveRecord::Base.connection.select_one("select * from locas where id = #{n0[:locas_id]}  ")
						n0[:loca_code] = loca["code"]
						n0[:loca_name] = loca["name"]
				end
				if n0[:opeitms_id]
			  		case gantt_reverse
			  		when /gantt/
						n0[:start] = (CtlFields.proc_field_starttime(n0[:duedate],n0[:opeitms_id],"gantt"))
			  		when /reverse/
				  		n0[:duedate] = (CtlFields.proc_field_starttime(n0[:start],n0[:opeitms_id],"reverse"))
			  		end
				else
					case gantt_reverse
					when /mst/
						case gantt_reverse
						when /gantt/
					  		n0[:start] = n0[:duedate]
						when /reverse/
							n0[:duedate] = n0[:start]
						end
					when /trn/
						rec = ActiveRecord::Base.connection.select_one("select * from #{n0[:tblname]} where id = #{n0[:tblid]}")
						n0[:sno] = rec["sno"]
						n0[:duedate] = (CtlFields.proc_get_endtime(n0[:tblname],rec))
						n0[:start] = rec["starttime"]
					end
				end
			  	@min_time = n0[:start] if (@min_time||=n0[:start]) > n0[:start]
			  	@max_time = n0[:duedate] if (@max_time||= n0[:duedate])  < n0[:duedate]
			return n0
		end
		
		def get_ganttchart_data(n0)  ###工程の始まり=前工程の終わり
				strsql = "select * from r_nditms where nditm_opeitm_id = #{n0[:opeitms_id]} 
						and nditm_Expiredate > current_date order by itm_code_nditm  "
				rnditms = ActiveRecord::Base.connection.select_all(strsql)
				depend = []
				duedate = @bgantts[@level][:start]
				rnditms.each_with_index  do |rec,idx|  ###子部品
					nopeitms_id = get_opeitms_id_from_itm_by_processseq(rec["nditm_itm_id_nditm"],
																rec["nditm_processseq_nditm"])
					duration = rec["nditm_duration"].to_i
					###new_start = (duedate.to_time - (rec["opeitm_duration"].to_i) * 24 * 60 * 60).strftime("%Y-%m-%d %H:%M:%S") 
					new_qty = n0[:qty].to_f * rec["nditm_chilnum"].to_f / rec["nditm_parenum"].to_f  
					nlevel = @level +  format('%07d',nopeitms_id.to_i)
					contents = {:opeitms_id=>nopeitms_id,:processseq=>rec["nditm_processseq_nditm"],
						:start=>duedate,:duedate=>duedate,:id=>nlevel,:type=>"task",
						:parenum=>rec["nditm_parenum"],:chilnum=>rec["nditm_chilnum"],:qty=>new_qty,
						:itms_id=>rec["nditm_itm_id_nditm"],:itm_code=>rec["itm_code_nditm"],:itm_name=>rec["itm_name_nditm"],
						:locas_id=>rec["shelfno_loca_id_shelfno_opeitm"],:loca_code=>rec["loca_code_shelfno_opeitm"],
						:loca_name=>rec["loca_name_shelfno_opeitm"]}
					depend << nlevel
					@ngantts << contents
				end
				###depend = get_prev_process(n0,duedate,depend)  ###前工程 nditmsに含まれる。
				@bgantts[@level][:depend] = depend.dup   ###親の依存を調べる。
		end
	
		def get_opeitms_id_from_itm_by_processseq itms_id,processseq  ###
				strsql = %Q& select id from opeitms where itms_id = #{itms_id} 
						 	and processseq =#{processseq} and priority = 999 and expiredate > current_date &
				opeitms_id = ActiveRecord::Base.connection.select_value(strsql)
			return opeitms_id
		end
	
		
		def sql_trn_gantt_alloctbl orgtblname,orgtblid   ###opeitms_idはない。
	    	### a.trngantt 引当て先　　b.trngantt オリジナル
        	%Q& select trn.*,alloc.tblname alloc_tblname,alloc.tblid alloc_tblid,alloc.srctblname,alloc.srctblid,
					(trn.qty_sch + trn.qty + trn.qty_stk) qty_bal		
	  			from trngantts trn
	  				inner join alloctbls alloc on trn.id = alloc.trngantts_id
	  				where   trn.orgtblname = '#{orgtblname}' and trn.orgtblid = #{orgtblid}
	  				and (trn.qty_sch + trn.qty + trn.qty_stk) > 0
					and (trn.orgtblname != trn.tblname or trn.orgtblid != trn.tblid)   --- topは除く 
	  				order by trn.key&
		end

    	def trn_gantt  orgtblname,orgtblid,gantt,gkey,idx
			ActiveRecord::Base.connection.select_all(sql_trn_gantt_alloctbl(orgtblname,orgtblid)).each do |trn|
				break if idx > 1000
				gantt[gkey+trn["key"]] = trn
				tblname,tblid = get_ordtbl_ordid(trn["srctblname"],trn["srctblid"])
				gantt,idx = trn_gantt(tblname,tblid,gkey+trn["key"],idx)
				idx += 1
			end	
			return gantt,idx
		end

		def get_ordtbl_ordid tblname,tblid
			until tblname =~ /ords$/
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
        $person_code_chrg =  ActiveRecord::Base.connection.select_value("select id from persons where email = '#{$email}'")   ###########   LOGIN USER
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


    def prv_resch_trn   ##本日を起点に再計算
        today = Time.now
        @bgantts.sort.reverse.each  do|key,value|  ###計算
		    if key.size > 3
                if  value[:depend] == ""
		    	    if @bgantts[key][:start]  <  today
                       @bgantts[key][:start]  =  today
                       @bgantts[key][:duedate]  =   CtlFields.proc_field_starttime(@bgantts[key[0..-4]][:start],@bgantts[key[0..-4]][:id],"reverse")    ###稼働日考慮今なし
                    end
			    end
                if  (@bgantts[key[0..-4]][:start] ) < @bgantts[key][:duedate]
                    @bgantts[key[0..-4]][:start]  =   @bgantts[key][:duedate]   ###稼働日考慮今なし
                    @bgantts[key[0..-4]][:duedate] =  CtlFields.proc_field_starttime(@bgantts[key[0..-4]][:start],@bgantts[key[0..-4]][:id],"reverse")
				    ##p key
				    ##p @bgantts[key]
			    end
            end
        end
        @bgantts.sort.each  do|key,value|  ###topから再計算
		    if key.size > 3
                if  (@bgantts[key[0..-4]][:start]  ) > @bgantts[key][:duedate]
                      @bgantts[key][:duedate]  =   @bgantts[key[0..-4]][:start]    ###稼働日考慮今なし
                      @bgantts[key][:start] = CtlFields.proc_field_starttime(@bgantts[key][:duedate],@bgantts[key][:id],nil)
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

		def vproc_set_dummy_process(n0,starttime)
			@ngantts = []
			@ngantts << {:itms_id=>0,
					   :locas_id=>0,:opeitms_id=>0,
					   :locas_id_to=>0,:shelfnos_id=>0,:shuffleflg=>0,
					   :duedate=>Time.now,:prdpur=>"",:duration=>1,
					   :parenum=>0,:chilnum=>0,
					   :autocreate_inst=>"",
					   :consumtype=>"",
					   :safestkqty=>0,:id=>0,
					   :priority=>0,:processseq=>0,
					   :start => Time.now}  ###基準日　期間　タイプ　休日考慮
		end
	
    	def vproc_get_pare_itms(n0,duedate)  ###
          	strsql = "select nditm.* from nditms nditm 
							where itms_id_nditm = #{n0[:itms_id]} 
							and processseq_nditm = #{n0[:processseq]} and Expiredate > current_date  "
          	nditms = ActiveRecord::Base.connection.select_all(strsql)
            nditms.each.with_index(1)  do |i,cnt|
				strsql = %Q&select ope.*,shelf.locas_id_shelfno locas_id  from opeitms ope
									inner join shelfnos shelf on shelf.id = ope.shelfnos_id_opeitm
									where ope.id = #{i["opeitms_id"]}  
						&
                ope = ActiveRecord::Base.connection.select_one(strsql)
				nlevel = (@level +  "_" + format('%07d',i["opeitms_id"].to_i))
                if ope
                      @ngantts << {:parenum => i["chilnum"],:chilnum => i["parenum"],:prdpur => ope["prdpur"],:consumtype => i["consumtype"],
                              :opeitms_id => i["opeitms_id"],:depend=>[@level],
                              :itms_id => ope["itms_id"],:locas_id => ope["locas_id"],:processseq=>ope["processseq"],:priority=>ope["priority"],
                              :start=>duedate,:duration=>(i["duration"]||=1),:duedate=>CtlFields.proc_field_starttime(n0[:start],ope["id"],"reverse"),
                              :id=>nlevel }  ###
                else
                    	3.times{Rails.logger.debug "logic error opeitms missing  line :#{__LINE_} select * from opeitms where id = #{i["opeitms_id"]} "}
                      	@errmsg =  "logic error opeitms missing  line :#{__LINE_} select * from opeitms where id = #{i["opeitms_id"]} "
                      	raise
                end
            end
    	end
	end
end    
