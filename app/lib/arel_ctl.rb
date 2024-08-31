module ArelCtl
	extend self
	def proc_get_opeitms_rec itms_id,locas_id,processseq = nil,priority = nil  ###
		strsql = %Q& select * from opeitms where itms_id = #{itms_id} 
					#{if locas_id then " and locas_id = " + locas_id.to_s else "" end}
				   #{if processseq then " and processseq = " + processseq.to_s else "" end}
				   #{if priority then " and priority = " + priority.to_s else "" end}
				   and expiredate > current_date  order by  priority desc &
		newrec = ActiveRecord::Base.connection.select_one(strsql)
		if newrec
			return newrec
		else
			return nil
        end
	end

    def proc_materiallized tblname
		if $materiallized[tblname]
		  	$materiallized[tblname].each do |view|
				strsql = %Q%select 1 from pg_catalog.pg_matviews pm 
				  where matviewname = '#{view}' %
				if ActiveRecord::Base.connection.select_one(strsql)			
				  strsql = %Q%REFRESH MATERIALIZED VIEW #{view} %
				  ActiveRecord::Base.connection.execute(strsql)
				else
				  3.times{p "materiallized error :#{view}"}
				end
		  	end
		end
	end

    
	def proc_get_nextval tbl_seq
		ActiveRecord::Base.uncached() do
			case ActiveRecord::Base.configurations[Rails.env]['adapter']
				when /post/
					ActiveRecord::Base.connection.select_value("SELECT nextval('#{tbl_seq}')")  ##post
				# when /oracle/  ###oracle対応中止
				# 	ActiveRecord::Base.connection.select_value("select #{tbl_seq}.nextval from dual")  ##oracle
			end
		end
	end
	
	def proc_processreqs_add params
		processreqs_id = proc_get_nextval("processreqs_seq")
		if params["seqno"].nil?
			params["seqno"] = []
		end	
		params["seqno"] << processreqs_id  ###
		setParams = params.dup
		setParams.delete(:parse_linedata)  ###size 8192対策
		setParams.delete(:lineData)
		if setParams["where_str"]
			setParams["where_str"] = setParams["where_str"].gsub("'","#!")
		end
		strsql = %Q&
			insert into processreqs(
						contents,remark,
						created_at,updated_at,
						update_ip,persons_id_upd,reqparams,
						seqno,id,result_f)
					values(
						'','#{setParams["remark"]}',
						to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
						to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
						'',#{setParams["person_id_upd"]},'#{setParams.to_json}',
						#{setParams["seqno"][0]},#{processreqs_id},'0')
		&
		ActiveRecord::Base.connection.insert(strsql) 
		return processreqs_id,params
	end

	def proc_createtable fmtbl,totbl,fmview,params  ### fmtbl:元のテーブル totbl:fmtblから自動作成するテーブル
		strsql = %Q% select pobject_code_sfd from  func_get_screenfield_grpname('#{params["email"]}','r_#{totbl}')
		%
		toFields = ActiveRecord::Base.connection.select_values(strsql) 
		blk = RorBlkCtl::BlkClass.new("r_#{totbl}")
		command_c = blk.command_init
		toFields.each do |key|
			prevkey = key.gsub(totbl.chop,fmtbl.chop)
			case key.to_s
			when /^id$/ 
				if params[:classname] =~ /_add_|_insert_/
					command_c["id"] = ""
				else
					command_c["id"] = fmview["id"]
				end
			when /_sno$|_cno$|_gno$/ 
				if params[:classname] =~ /_add_|_insert_/
					command_c[key] = ""
				else
					command_c[key] = fmview[prevkey]
				end
			when /_amt|_qty/   ###例：qty_schとqtyは同一項目とみなす
				if fmview[prevkey]
					if key.split(/_amt|_qty/)[0] == prevkey.to_s.split(/_amt|_qty/)[0]
						command_c[key] = fmview[prevkey]
					end
				end
			else
				if toFields.index(prevkey)  ###配列に該当のkeyがあった時
					command_c[key] = fmview[prevkey]
				end	
			end
		end
		case fmtbl   ###元のテーブル
			when /^custs$/	
				case totbl
				when "custrcvplcs"
						command_c["custrcvplc_cust_id"] = command["id"]  
						command_c["custrcvplc_code"] = "000"  
						command_c["custrcvplc_name"] = "same as customer"  
						command_c["id"] = nil
				end
			when /^suppliers/
				case totbl
				when "shelfnos"
						strsql = %Q&
								select id from shelfnos where code = '000' and locas_id_shelfno = #{fmview["supplier_loca_id_supplier"]}
						& 
						if ActiveRecord::Base.connection.select_value(strsql)
						else
							command_c["shelfno_code"] = "000"
							command_c["shelfno_name"] = "same as loca name"
							command_c["shelfno_loca_id_shelfno"] = fmview["supplier_loca_id_supplier"]
							command_c["id"] = nil
						end
				end
			when /^workplaces/
				case totbl
				when "shelfnos"  
					strsql = %Q&
								select id from shelfnos where code = '000' and locas_id_shelfno = #{fmview["workplace_loca_id_workplace"]}
					& 
					if ActiveRecord::Base.connection.select_value(strsql)
					else
						command_c["shelfno_code"] =  "000"
						command_c["shelfno_name"] = "same as loca name"  
						command_c["shelfno_loca_id_shelfno"] = fmview["workplace_loca_id_workplace"]
						command_c["id"] = nil
					end
				end
			when /rlstinputs/
				case totbl 
					when /^puracts/
						qty_stk = fmview["purrsltinput_qty"].to_f
						sym_qty_stk = "purrsltinput_qty_stk"
						sym_packno = "purrsltinput_packno"
					when /^prdacts/
						qty_stk = fmview["prdsltinput_qty"].to_f
						sym_qty_stk = "prdrsltinput_qty_stk"
						sym_packno = "prdrsltinput_packno"
				end    
				packqty = fmview["opeitm_packqty"].to_f
				fmview["opeitm_packno_proc"] = 0 if packqty <= 0  ###保険　画面でチェック済
				case parent["opeitm_packno_proc"]
				when "1"
						idx = 0
						 packqty = fmview["opeitm_packqty"].to_f
						 until qty_stk <= 0 do
							fmview[sym_packno] = format('%03d', idx)
							fmview[sym_qty_stk] = packqty
						   proc_createtable fmtbl,totbl,fmview,params["classname"] 
						   qty_stk -=  packqty 
						   idx += 1
						 end
				else
					fmview[sym_qty_stk] = qty_stk
					proc_createtable fmtbl,totbl,fmview,params["cassname"]
				end
			else
				 	Rails.logger.debug " calss:#{self},line:#{__LINE__},create table not support table:#{fmtbl}"
				 	Rails.logger.debug " calss:#{self},line:#{__LINE__},create table not support table:#{totbl}"
				 	raise
				return
		end
		if params[:classname] =~ /_add_|_insert_/
				command_c["sio_classname"] ="_add_proc_createtable_data"
				command_c["#{totbl.chop}_created_at"] = Time.now
				command_c["#{totbl.chop}_expiredate"] = "2099/12/31"
		else
				command_c["sio_classname"] ="_update_proc_createtable_data"
		end
		command_c["#{totbl.chop}_person_id_upd"] = params["person_id_upd"]
		command_c["id"] = ArelCtl.proc_get_nextval("#{totbl}_seq")
		blk.proc_create_tbldata(command_c)
		blk.proc_private_aud_rec({},command_c)
	end	

	def proc_createDetailTableFmHead  headTbl,baseTbl,headCommand,fmview,params
		detailTbl = headTbl.sub(/heads$/,"s") 
		strsql = %Q% select pobject_code_sfd from  func_get_screenfield_grpname('#{params["email"]}','r_#{detailTbl}')
		%
		toFields = ActiveRecord::Base.connection.select_values(strsql) 
		blk = RorBlkCtl::BlkClass.new("r_#{detailTbl}")
		command_c = blk.command_init
		toFields.each do |key|
			prevkey = key.gsub(detailTbl.chop,baseTbl.chop)
			case key
			when /updated_at|created_at|remark|contents|_upd/
				next
			when /^id$/ 
				if params[:classname] =~ /_add_|_insert_/
					command_c["id"] = ""
				else
					command_c["id"] = fmview["id"]
				end
			when /_sno$|_cno$|_gno$/ 
				if params[:classname] =~ /_add_|_insert_/
					command_c[key] = ""
				else
					command_c[key] = fmview[prevkey]
				end
			when /_amt|_qty/   ###例：qty_sch,qty,qty_stkは同一項目とみなす
				if fmview[prevkey]
					if key.to_s.split(/_amt|_qty/)[0] == prevkey.split(/_amt|_qty/)[0]
						command_c[key] = fmview[prevkey]
					end
				end
			else
				if toFields.index(prevkey)  ###配列に該当のkeyがあった時
					command_c[key] = fmview[prevkey]
				end	
			end
		end
		case headTbl
		when "custactheads"
			command_c["custact_invoiceno"] = headCommand["custacthead_invoiceno"]
			command_c["custact_packinglistno"] = headCommand["custacthead_packinglistno"]  
			amt = command_c["custact_amt"]
			taxrate = command_c["custact_taxrate"] 
		end
		command_c["sio_classname"] =
			if params[:classname] =~ /_add_|_insert_/
				"_add_proc_createtable_data"
				command_c["#{headTbl.chop}_created_at"] = Time.now
			else
				"_update_proc_createtable_data"
			end
		command_c["#{headTbl.chop}_person_id_upd"] = params["person_id_upd"]
		command_c["id"] = ArelCtl.proc_get_nextval("#{headTbl}_seq")
		blk.proc_create_tbldata(command_c)
		blk.proc_private_aud_rec({},command_c)
		head = {"amt" => amt,"taxrate" => taxrate,"#{headTbl.chop}_id" => command_c["id"]}
		return head
	end	

	# def consume_amt_sch_by_act fmtbl,fmtblid,prev_totbl
	# 	taxrate = 0.1  ###変更要
	# 	srctbl = fmtbl
	# 	srctblid = fmtblid
	# 	flg = false
	# 	until flg == true
	# 		strsql = %Q&select * from linktbls where tblname = '#{srctbl}' and tblid = #{srctblid}&
	# 		flg = true
	# 		ActiveRecord::Base.connection.select_all(strsql).each do |link|
	# 			case link["srctblname"] 
	# 			when /ords/
	# 				linl_sql = %Q&select sum(qty_src) from linktbls 
	# 								where  srctblname = #{link["srctblname"]} and srctblid = #{link["srctblid"]} 
	# 								group by srctblname,srctblid
	# 								&
	# 				link_rec = ActiveRecord::Base.connection.select_one(link_sql)
	# 				prev_sql = %Q&select * from #{link["srctblname"]} 	where  srctblid = #{link["srctblid"]} 
	# 								&
	# 				prev_rec = ActiveRecord::Base.connection.select_one(link_sql)
	# 				amt_sch = prev_rec["amt"].to_f - link_rec["qty_src"].to_f * prev_rec["price"]
	# 				tax = amt_sch * taxrate
	# 				amt_sch_sql = %Q& select * from  r_#{prev_totbl} 
	# 									where  #{prev_totbl.chop}_sno_#{link["srctblname"].chop} = #{ord["sno"]}&
	# 				command_c = ActiveRecord::Base.connection.select_one(amt_sch_sql)
	# 				command_c["#{prev_totbl.chop}_amt_sch"] = amt_sch
	# 				command_c["#{prev_totbl.chop}_tax"] = tax
	# 				command_c["sio_code"] = command_c["sio_viewname"] =  "r_" + prev_totbl
	# 				command_c["sio_classname"] = "_update_consume_amt_sch_by_act"
	# 			when /insts$|dlvs$|acts$|replyinputs$/
	# 				srctbl = link["srctblname"]
	# 				srctblid = link["srctblid"]
	# 				flg = false
	# 			end
	# 		end
	# 	end
	# end

	def proc_insert_linktbls(src,base)
		linktbl_id = proc_get_nextval("linktbls_seq")
		strsql = %Q&
				insert into linktbls(id,trngantts_id,
					srctblname,srctblid,
					tblname,tblid,qty_src,amt_src,
					created_at,
					updated_at,
					update_ip,persons_id_upd,expiredate,remark)
				values(#{linktbl_id},#{src["trngantts_id"]},
					'#{src["tblname"]}',#{src["tblid"]}, 
					'#{base["tblname"]}',#{base["tblid"]},#{base["qty_src"]} ,#{base["amt_src"]} , 
					to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
					to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
					' ',0,'2099/12/31','#{base["remark"]}')  ---persons.id=0はテーブルに必須
				&
		ActiveRecord::Base.connection.insert(strsql)
		return linktbl_id
	end

	
	def proc_insert_srctbllinks(src,base)
		linktbl_id = proc_get_nextval("srctbllinks_seq")
		strsql = %Q&
				insert into srctbllinks(id,
					srctblname,srctblid,
					tblname,tblid,amt_src,
					created_at,
					updated_at,
					update_ip,persons_id_upd,expiredate,remark)
				values(#{linktbl_id},
					'#{src["tblname"]}',#{src["tblid"]}, 
					'#{base["tblname"]}',#{base["tblid"]},#{base["amt_src"]} , 
					to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
					to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
					' ',0,'2099/12/31','#{base["remark"]}')  ---persons.id=0ははテーブルに必須
				&
		ActiveRecord::Base.connection.insert(strsql)
	end

	def proc_insert_linkheads(head,detail)
		linkhead_id = proc_get_nextval("linkheads_seq")
		strsql = %Q&
				insert into linkheads(id,
					paretblname,paretblid,
					tblname,tblid,
					created_at,
					updated_at,
					update_ip,persons_id_upd,expiredate,remark)
				values(#{linkhead_id},
					'#{head["paretblname"]}',#{head["paretblid"]}, 
					'#{detail["tblname"]}',#{detail["tblid"]}, 
					to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
					to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
					' ',#{detail["persons_id_upd"]},'2099/12/31','#{detail["remark"]}')
				&
		ActiveRecord::Base.connection.insert(strsql)
		return linkhead_id
	end

	def proc_insert_linkcusts(src,base)
		linkcust_id = proc_get_nextval("linkcusts_seq")
		strsql = %Q&
				insert into linkcusts(id,trngantts_id,
					srctblname,srctblid,
					tblname,tblid,qty_src,amt_src,
					created_at,
					updated_at,
					update_ip,persons_id_upd,expiredate,remark)
				values(#{linkcust_id},#{src["trngantts_id"]},
					'#{src["tblname"]}',#{src["tblid"]}, 
					'#{base["tblname"]}',#{base["tblid"]},#{base["qty_src"]} ,#{base["amt_src"]} , 
					to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
					to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
					' ',#{base["persons_id_upd"]},'2099/12/31','#{base["remark"]}')
				&
		ActiveRecord::Base.connection.insert(strsql)
		return linkcust_id
	end

	def proc_insert_alloctbls(rec_alloc)
		strsql = %Q&
					select id from alloctbls 
									where srctblname = '#{rec_alloc["srctblname"]}' and srctblid = #{rec_alloc["srctblid"]}
									and   trngantts_id = #{rec_alloc["trngantts_id"]}  
		&
		alloctbl_id = ActiveRecord::Base.connection.select_value(strsql)
		if alloctbl_id
			strsql = %Q&
						update alloctbls set qty_linkto_alloctbl = qty_linkto_alloctbl +  #{rec_alloc["qty_linkto_alloctbl"]},
									remark = '#{rec_alloc["remark"]}'}',   --- persond_id_upd=0
									where id = #{alloc_id}
					&
			ActiveRecord::Base.connection.update(strsql)
		else
			alloctbl_id = proc_get_nextval("alloctbls_seq")
			strsql = %Q&
				insert into alloctbls(id,
							srctblname,srctblid,
							trngantts_id,
							qty_linkto_alloctbl,
							created_at,
							updated_at,
							update_ip,persons_id_upd,expiredate,remark,allocfree)
					values(#{alloctbl_id},
							'#{rec_alloc["srctblname"]}',#{rec_alloc["srctblid"]},
							#{rec_alloc["trngantts_id"]},
							#{rec_alloc["qty_linkto_alloctbl"]},
							to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
							to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
							' ',0,'2099/12/31','#{rec_alloc["remark"]}',   --- persond_id_upd=0
							'#{rec_alloc["allocfree"]}')
			&
			ActiveRecord::Base.connection.insert(strsql)
		end
		return alloctbl_id
	end

	###custschs,custords,prdschs,prdords,purschs,purords xxxx(在庫)  の時のみ作成
	def proc_insert_trngantts(gantt) ## ###@tblname,@tblid,@gantt・・・・セット
		strsql = %Q&
		insert into trngantts(id,key,
						orgtblname,orgtblid,paretblname,paretblid,
						tblname,tblid,
						mlevel,
						shuffle_flg,
						parenum,chilnum,
						qty_sch,qty,qty_stk,
						qty_require,
						qty_pare,qty_sch_pare,
						qty_handover,
						prjnos_id,
						shelfnos_id_to_trn,shelfnos_id_to_pare,
						itms_id_trn,processseq_trn,shelfnos_id_trn,
						itms_id_pare,processseq_pare,shelfnos_id_pare,
						itms_id_org,processseq_org,shelfnos_id_org,
						consumunitqty,
						consumminqty,consumchgoverqty,
						starttime_trn,
						starttime_pare,
						starttime_org,
						duedate_trn,
						duedate_pare,
						duedate_org,
						toduedate_trn,
						toduedate_pare,
						toduedate_org,
						consumtype,
						chrgs_id_trn,chrgs_id_pare,chrgs_id_org,
						created_at,
						updated_at,
						update_ip,persons_id_upd,expiredate,remark)
		values(#{gantt["trngantts_id"]},'#{gantt["key"]}',
					'#{gantt["orgtblname"]}',#{gantt["orgtblid"]},'#{gantt["paretblname"]}',#{gantt["paretblid"]},
					'#{gantt["tblname"]}',#{gantt["tblid"]},
					'#{gantt["mlevel"]}',
					'#{gantt["shuffle_flg"]}',
					#{gantt["parenum"]},#{gantt["chilnum"]},
					#{gantt["qty_sch"]},#{gantt["qty"]},#{gantt["qty_stk"]},
					#{gantt["qty_require"]},
					#{gantt["qty_pare"]},#{gantt["qty_sch_pare"]},
					#{gantt["qty_handover"]},
					#{gantt["prjnos_id"]},
					#{gantt["shelfnos_id_to_trn"]},#{gantt["shelfnos_id_to_pare"]},
					#{gantt["itms_id_trn"]},#{gantt["processseq_trn"]},#{gantt["shelfnos_id_trn"]},
					#{gantt["itms_id_pare"]},#{gantt["processseq_pare"]},#{gantt["shelfnos_id_pare"]},
					#{gantt["itms_id_org"]},#{gantt["processseq_org"]},#{gantt["shelfnos_id_org"]},
					#{case gantt["consumunitqty"].to_i when 0 then 1 else gantt["consumunitqty"] end},
					#{gantt["consumminqty"]},#{gantt["consumchgoverqty"]},
					to_timestamp('#{gantt["starttime_trn"]}','yyyy/mm/dd hh24:mi:ss'),
					to_timestamp('#{gantt["starttime_pare"]}','yyyy/mm/dd hh24:mi:ss'),
					to_timestamp('#{gantt["starttime_org"]}','yyyy/mm/dd hh24:mi:ss'),
					to_timestamp('#{gantt["duedate_trn"]}','yyyy/mm/dd hh24:mi:ss'),
					to_timestamp('#{gantt["duedate_pare"]}','yyyy/mm/dd hh24:mi:ss'),
					to_timestamp('#{gantt["duedate_org"]}','yyyy/mm/dd hh24:mi:ss'),
					to_timestamp('#{gantt["toduedate_trn"]}','yyyy/mm/dd hh24:mi:ss'),
					to_timestamp('#{gantt["toduedate_pare"]}','yyyy/mm/dd hh24:mi:ss'),
					to_timestamp('#{gantt["toduedate_org"]}','yyyy/mm/dd hh24:mi:ss'),
					'#{gantt["consumtype"]}',   ---custxxxsの時は""
					#{gantt["chrgs_id_trn"]},#{gantt["chrgs_id_pare"]},#{gantt["chrgs_id_org"]},
					to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
					to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
					' ',#{gantt["persons_id_upd"]},'2099/12/31','#{gantt["remark"]}')
		&
		ActiveRecord::Base.connection.insert(strsql)
		src = {"tblname" => gantt["tblname"],"tblid" => gantt["tblid"],"trngantts_id" => gantt["trngantts_id"]}
		qty_src = gantt["qty_sch"].to_f + gantt["qty"].to_f + gantt["qty_stk"].to_f  ###qty_sch,qty,qty_stkの一つのみ有効
		base = {"tblname" => gantt["tblname"],"tblid" => gantt["tblid"],"qty_src" => qty_src,"amt_src" => 0,
					"remark" => "#{self} line #{__LINE__}", 
					"persons_id_upd" => gantt["persons_id_upd"]}
		alloc = {"srctblname" => gantt["tblname"],"srctblid" => gantt["tblid"],"trngantts_id" => gantt["trngantts_id"],
					"qty_linkto_alloctbl" => gantt["qty_sch"].to_f + gantt["qty"].to_f + gantt["qty_stk"].to_f,
					"remark" => "#{self} line #{__LINE__} #{Time.now}","persons_id_upd" => gantt["persons_id_upd"],
					"allocfree" => 	if gantt["tblid"] == gantt["paretblid"] and gantt["tblid"] == gantt["orgtblid"] and
											gantt["tblname"] == gantt["paretblname"] and gantt["tblname"] == gantt["orgtblname"] 
												"free" 
									else
												"alloc"
									end}
		case gantt["tblname"] 
		when /^prd|^pur|dymschs|^dvs|^shp/   ### shp itmclass,code=mold,ITollの時
			linktbl_id = proc_insert_linktbls(src,base)
			alloctbl_id = proc_insert_alloctbls(alloc)
		when /^cust/
			linktbl_id = proc_insert_linkcusts(src,base)
			alloctbl_id = proc_insert_alloctbls(alloc)
		end
		return linktbl_id,alloctbl_id
	end
	
   	def proc_set_stkinout(tmptbldata)
		stkinout = {"tblname" => tmptbldata["tblname"],"tblid" => tmptbldata["tblid"],
				"srctblname" => tmptbldata["tblname"],"srctblid" => tmptbldata["tblid"],
				"itms_id" => tmptbldata["itms_id"] ,"processseq" => tmptbldata["processseq"] ,
				"shelfnos_id" => tmptbldata["shelfnos_id_to"],  ###shpxxx,custxxxでは個別の設定が必要
				"prjnos_id" => tmptbldata["prjnos_id"] ,
				"starttime" => tmptbldata["duedate"],"packno" => (tmptbldata["packno"]||=""),"lotno" => (tmptbldata["lotno"]||=""),
				"lotstkhists_id" => "","trngantts_id" =>  tmptbldata["trngantts_id"],"alloctbls_id" => "",
				"qty_src" => 0,"amt_src" => 0,"qty_linkto_alloctbl" => 0,
				"qty_sch" => tmptbldata["qty_sch"].to_f,"qty" =>tmptbldata["qty"].to_f,"qty_stk" => tmptbldata["qty_stk"].to_f,
				"qty_real" => tmptbldata["qty_stk"].to_f}	
		return stkinout		
	end
	
	def proc_add_linktbls_update_alloctbls(src,base)  ###前の状態から現状への変更
		###
		###  今の関係(linktbls.qty_src)は変更しない。履歴として残している。
		###
		###      src["qty_linkto_alloctbl"]=>変化前のqty
		###      src["tblname"],src["tblid"] =>変化前tbl,id
		###      src["trngantts_id"] => 変化前trngantts_id 
		###
		###      base["qty_src"]=> 変化先のqty
		###      base["tblname"],src["tblid"] =>変化先tbl,id
		###
		###################################################################       
		free_qty = base["qty_src"].to_f   ###  xxxordsからxxxacts等に変わった時も同じ
		if src["qty_linkto_alloctbl"].to_f > base["qty_src"].to_f
			qty_src = src["qty_linkto_alloctbl"].to_f - base["qty_src"].to_f   ###引当残  qty_sch
			base["remark"] = "#{self} line:(#{__LINE__})" + base["remark"]
			proc_insert_linktbls(src,base)  ###linktbls.qty_src作成後free_qty=base["qty_src"] = 0
			base["qty_src"] = 0
			free_qty = 0
	   	else
			qty_src = 0  ###全て引き合ったった qty_sch
			base["qty_src"] =  src["qty_linkto_alloctbl"].to_f
			base["remark"] = "#{self} line:(#{__LINE__})" +  base["remark"]
			proc_insert_linktbls(src,base)
			free_qty -=  src["qty_linkto_alloctbl"].to_f
		end
		###
		#    dvsxxxs linktbls alloctbls作成 
		###
		if src["tblname"] == "prdschs" and base["tblname"] !~ /acts$|dlvs$/
			strsql = %Q&
					select * from dvsschs where prdschs_id_dvssch = #{src["tblid"]}			
			&
			dvssch = ActiveRecord::Base.connection.select_one(strsql)
			strsql = %Q&
					select * from dvs#{base["tblname"].sub("prd","")} where #{base["tblname"].chop}_id_dvs#{base["tblname"].sub("prd","").chop} = #{base["tblid"]}			
			&
			dvsbase = ActiveRecord::Base.connection.select_one(strsql)
			link_update_sql = %Q&
					update linktbls set qty_src = 0 ,remark = '#{self} #{__LINE__} #{Time.now}'||remark 
						where tblname  = 'dvsschs' and tblid = #{dvssch["id"]}   
					& 
			ActiveRecord::Base.connection.update(link_update_sql)
			alloc_update_sql = %Q&
					update alloctbls set qty_linkto_alloctbl = 0 ,remark = '#{self} #{__LINE__} #{Time.now}'||remark
						where srctblname  = 'dvsschs' and srctblid = #{dvssch["id"]}  ---xxxschs.id unique on alloctbls
					& 
			ActiveRecord::Base.connection.update(alloc_update_sql)
			strsql = %Q&
					select trngantts_id from  linktbls where tblname  = '#{dvsschs}' and tblid = #{dvssch["id"]}   
			&
			trngantts_id = ActiveRecord::Base.connection.select_value(strsql)
			src = {"tblname" => "dlvschs","tblid" => dvssch["id"],"trngantts_id" => trngantts_id}
			base = {"tblname" =>"dvs#{base["tblname"].sub("prd","")}","tblid" => basedvs["id"],"qty_src" => 1,"amt_src" => 0,
					"remark" => "#{self} line #{__LINE__}", 
					"persons_id_upd" => 0}
			alloc = {"srctblname" => "dvs#{base["tblname"].sub("prd","")}","srctblid" => basedvs["id"],"trngantts_id" => trngantts_id,
					"qty_linkto_alloctbl" => 1,
					"remark" => "#{self} line #{__LINE__} #{Time.now}","persons_id_upd" => 0,
					"allocfree" => 	"alloc"}
			linktbl_id = proc_insert_linktbls(src,base)  ###prdords,prdinsts,prdactsにlinkするdvsxxxsのtrnganttsはない
			alloctbl_id = proc_insert_alloctbls(alloc)
		end
		strsql = %Q&
			update alloctbls set qty_linkto_alloctbl =  #{qty_src},
						updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
						remark = '#{self} line:(#{__LINE__})'|| remark
					where id = #{src["alloctbls_id"]} 
			 &
		ActiveRecord::Base.connection.update(strsql)
		str_qty = case src["tblname"]
		 			when /schs$/
						"qty_sch"
					when /acts$|dlvs$/
						"qty_stk"
					else
						"qty"
					end

		new_str_qty = case base["tblname"]
					when /schs$/
					   "qty_sch"
				   	when /acts$|dlvs$/
					   "qty_stk"
				   	else
					   "qty"
				   	end

		 strsql = %Q&  ---   tblname=xxxschsのqty,qty_sch
			 update trngantts set #{str_qty} = #{str_qty}  - #{base["qty_src"]},
			 						#{new_str_qty} =  #{new_str_qty} + #{base["qty_src"].to_f},
						 updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
						 remark = '#{self} line:(#{__LINE__})'|| remark
					 where id = #{src["trngantts_id"]} 
			  &
		  ActiveRecord::Base.connection.update(strsql)

		strsql = %Q&
		 	  update alloctbls set qty_linkto_alloctbl =  #{free_qty},  ---引き当て元の残数
			   				updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
		 					remark = '#{self} line:(#{__LINE__})'||remark
		 			where id = #{base["alloctbls_id"]} 
		 	  &
		ActiveRecord::Base.connection.update(strsql)

		alloc = {"trngantts_id" => src["trngantts_id"],"srctblname" => base["tblname"] ,
			 "srctblid" => base["tblid"],"allocfree" => "alloc",
			"qty_linkto_alloctbl" => base["qty_src"] ,
			 "remark" => "#{self} (line: #{__LINE__} #{Time.now})"}
		proc_insert_alloctbls(alloc)
		base["qty_src"] = free_qty
		# ###在庫の修正はproc_src_base_trn_stk_update
		return  base
	end
	
	 def proc_nditmSql(opeitms_id)  
        %Q%
            select pare.processseq processseq_pare,pare.packqty packqty_pare,pare.id opeitms_id_pare,
				pare.duration duration_pare,pare.units_lttime units_lttime,
				nditm.itms_id_nditm itms_id,  ---itms_id = itms_id_nditm
               nditm.processseq_nditm processseq,ope.packqty,
               nditm.consumtype,nditm.parenum,nditm.chilnum,
               nditm.consumunitqty,nditm.consumminqty,nditm.consumchgoverqty,
               ope.id opeitms_id,ope.packno_proc,
               ope.prdpur,ope.units_id_case_shp,itm.units_id,
               ope.locas_id_shelfno locas_id_shelfno,ope.shelfnos_id_opeitm,  ---子部品作業場所
               ope.locas_id_shelfno_to locas_id_shelfno_to,ope.shelfnos_id_to_opeitm,   ---子部品保管場所
			   ope.consumauto,
			    itm.taxflg, itm.classlist_code,itm.itm_code_nditm,itm.itm_name_nditm,
				nditm.packqtyfacility,nditm.changeoverlt,postprocessinglt,
				case ope.duration
				when null then 
					1
				else
					ope.duration
				end duration
           from nditms nditm 
				inner join opeitms pare on pare.id = nditm.opeitms_id
               	inner join (select i.id,i.taxflg,i.units_id,c.code classlist_code,i.code itm_code_nditm,i.name itm_name_nditm,
								i.units_id itm_unit_id
			   					from itms i 
								inner join classlists c on i.classlists_id = c.id ) itm on itm.id = nditm.itms_id_nditm 
               	left join (select o.*,s.locas_id_shelfno locas_id_shelfno,xto.locas_id_shelfno locas_id_shelfno_to
                           from opeitms o 
                           inner join shelfnos s on o.shelfnos_id_opeitm = s.id
                           inner join shelfnos xto on o.shelfnos_id_to_opeitm = xto.id
						   where  o.priority = 999) ope ---完成後の移動場所から親の場所に
                   on  ope.itms_id = nditm.itms_id_nditm  and ope.processseq = nditm.processseq_nditm
                   where nditm.expiredate > current_date and nditm.opeitms_id = #{opeitms_id} 
			order by itm.classlist_code,itm.itm_code_nditm 
        %  
	end
    	
	def proc_reverse_nditmSql(itms_id,processseq)  
			%Q%
				select ope.opeitm_processseq processseq_pare,ope.opeitm_packqty packqty_pare,
					ope.opeitm_duration duration_pare,ope.opeitm_units_lttime units_lttime,
					ope.opeitm_itm_id itms_id,ope.itm_name,
					nditm.itms_id_nditm,  ---itms_id = itms_id_nditm
				   	nditm.processseq_nditm processseq,ope.opeitm_packqty,
				   	nditm.consumtype,nditm.parenum,nditm.chilnum,
				   	nditm.consumunitqty,nditm.consumminqty,nditm.consumchgoverqty,
				   	ope.id opeitms_id,ope.opeitm_prdpur prdpur,ope.opeitm_packno_proc packno_proc,
				   	ope.opeitm_unit_id_case_shp units_id_case_shp,ope.itm_unit_id unit_id,
				   	ope.shelfno_loca_id_shelfno_opeitm locas_id_shelfno,ope.opeitm_shelfno_id_opeitm,  ---子部品作業場所
				   	ope.opeitm_shelfno_id_to_opeitm shelfnos_id_to_opeitm,   ---子部品保管場所
				   	ope.opeitm_consumauto,ope.shelfno_code_opeitm,ope.shelfno_name_opeitm,
					ope.itm_taxflg taxflg, '' classlist_code ,ope.itm_code,ope.itm_name,
					ope.loca_code_shelfno_opeitm,ope.loca_name_shelfno_opeitm,
					nditm.packqtyfacility,nditm.changeoverlt,
					case ope.opeitm_duration
					when null then 
						1
					else
						ope.opeitm_duration
					end duration
			   from nditms nditm  
				inner join r_opeitms ope ---完成後の移動場所から親の場所に
					   on  ope.id = nditm.opeitms_id
				where nditm.expiredate > current_date 
					   and nditm.itms_id_nditm = #{itms_id}  and nditm.processseq_nditm = #{processseq}
					   ---and nditm.itms_id_nditm = 0  and nditm.processseq_nditm = 999 
					   order by ope.itm_code
			%  
	end
	
    def proc_pareChildTrnsSqlGroupByChildItem(parent)
         %Q%
             select pare.id pare_trngantts_id,trn.itms_id_trn itms_id, trn.processseq_trn processseq,
                max(trn.consumtype) consumtype,max(trn.parenum) parenum,max(trn.chilnum) chilnum,
                max(trn.consumunitqty) consumunitqty,max(trn.consumminqty) consumminqty,max(trn.consumchgoverqty) consumchgoverqty,
                pare.shelfnos_id_trn,   ---親作業場所
                trn.shelfnos_id_to_trn shelfnos_id_to,   ---子の保管先
	 		   max(ope.units_id_case_shp) units_id_case_shp,
	 		   sum(pare.qty_linkto_alloctbl) qty_sch,max(ope.consumauto) consumauto,max(ope.shpordauto) shpordauto
             from trngantts trn
                inner join (select p.*, alloc.qty_linkto_alloctbl 
                            from trngantts p 
                            inner join alloctbls alloc on alloc.trngantts_id = p.id
	 					   			where alloc.srctblname = '#{parent["tblname"]}' and alloc.srctblid = #{parent["tblid"]} 
	 								and alloc.qty_linkto_alloctbl > 0) pare 
                    on  trn.orgtblname = pare.orgtblname and   trn.orgtblid = pare.orgtblid  
                    and trn.paretblname = pare.tblname and   trn.paretblid = pare.tblid 
	 			inner join opeitms ope on trn.itms_id_trn = ope.itms_id and trn.processseq_trn = ope.processseq
	 							and trn.shelfnos_id_trn = ope.shelfnos_id_opeitm
	 		where (trn.paretblname != trn.tblname or trn.paretblid != trn.tblid) and pare.mlevel < trn.mlevel
	 		group by trn.itms_id_trn ,trn.processseq_trn ,pare.shelfnos_id_trn,trn.shelfnos_id_to_trn,pare.id
         %  
    end
	
    def proc_pareChildTrnsSql(parent)
         %Q%
             select trn.orgtblname,trn.orgtblid,trn.tblname,trn.tblid,
			 		trn.qty_sch,trn.qty,trn.qty_stk,
					trn.mlevel,trn.parenum,trn.chilnum,trn.consumunitqty,trn.consumminqty,
					trn.consumchgoverqty,pare.qty_linkto_alloctbl pare_qty,
					ope.duration ,ope.units_lttime
             	from trngantts trn
                inner join (select p.*, alloc.qty_linkto_alloctbl 
                            from trngantts p 
                            inner join alloctbls alloc on alloc.trngantts_id = p.id
	 					   			where alloc.srctblname = '#{parent["tblname"]}' and alloc.srctblid = #{parent["tblid"]} 
	 								and alloc.qty_linkto_alloctbl > 0) pare 
                    on  trn.orgtblname = pare.orgtblname and   trn.orgtblid = pare.orgtblid  
                    and trn.paretblname = pare.tblname and   trn.paretblid = pare.tblid 
	 			inner join opeitms ope on trn.itms_id_trn = ope.itms_id and trn.processseq_trn = ope.processseq
	 							and trn.shelfnos_id_trn = ope.shelfnos_id_opeitm
	 		where (trn.paretblname != trn.tblname or trn.paretblid != trn.tblid) and pare.mlevel < trn.mlevel
         %  
    end
	
    def proc_PrevConSql(parent,child,prev_contblname)
        %Q$
            --- select pare.srctblname prev_paretblname,pare.srctblid prev_paretblid,pare.qty_src  ,
			--- 		trn.id trngantts_id ,pare.tblname_pare paretblname,pare.tblid_pare paretblid
			--- 	from trngantts trn 
			--- 	inner join (select link.*,t.orgtblname,t.orgtblid,link.tblname tblname_pare,link.tblid tblid_pare,
			--- 							t.tblname tblname_sch,t.tblid tblid_sch,
			--- 							t.shelfnos_id_trn pare_shelfnos_id from trngantts t 
			--- 				inner join linktbls link on t.id = link.trngantts_id
			--- 				where link.tblname = '#{parent["tblname"]}' and link.tblid = #{parent["id"]}) pare
			--- 		on trn.orgtblid = pare.orgtblid and trn.orgtblname = pare.orgtblname
			--- 		and trn.paretblid = pare.tblid_sch and trn.paretblname = pare.tblname_sch
			--- 	inner join #{prev_contblname} con on con.paretblid  = pare.srctblid 
			--- 	where  con.itms_id = #{child["itms_id"]} and con.processseq = #{child["processseq"]}  
			--- 	and con.shelfnos_id_fm = #{child["shelfnos_id_fm"]}
			--- 	and trn.itms_id_trn = #{child["itms_id"]} and trn.processseq_trn = #{child["processseq"]}  
			--- 	and pare.pare_shelfnos_id = #{child["shelfnos_id_fm"]}

			select prevcon.paretblname prev_paretblname,prevcon.paretblid prev_paretblid,link.qty_src,link.trngantts_id 
					from  #{prev_contblname}  prevcon
				inner join  linktbls link on link.srctblid = prevcon.paretblid
				where  prevcon.itms_id = #{child["itms_id"]} and prevcon.processseq = #{child["processseq"]} 
				and prevcon.shelfnos_id_fm = #{child["shelfnos_id_fm"]}
				and link.tblid =#{parent["id"]} and link.tblname = '#{parent["tblname"]}'
        $
    end
	
    def proc_ChildConSql(parent)  
        %Q&
            select trn.itms_id_trn itms_id, trn.processseq_trn processseq,
               max(trn.consumtype) consumtype,max(trn.parenum) parenum,max(trn.chilnum) chilnum,
               max(trn.consumunitqty) consumunitqty,max(trn.consumminqty) consumminqty,max(trn.consumchgoverqty) consumchgoverqty,
			   sum(pare_qty) qty_stk,max(ope.consumauto) consumauto
           from trngantts trn
               inner join (select p.*,alloc.srctblname,alloc.srctblid,alloc.qty_linkto_alloctbl pare_qty
                           from trngantts p 
                           inner join alloctbls alloc on alloc.trngantts_id = p.id
						   		where  qty_linkto_alloctbl > 0 
								and alloc.srctblname = '#{parent["tblname"]}' and alloc.srctblid = #{parent["id"]}
								and (p.tblname != p.paretblname or p.tblid != p.paretblid)
								and not exists(select 1 from linktbls link where link.tblname = alloc.srctblname
																			and link.tblid = alloc.srctblid and srctblname != tblname
																			and link.srctblname = 'purdlvs' and link.qty_src > 0)) pare 
                   on  trn.orgtblname = pare.orgtblname and   trn.orgtblid = pare.orgtblid  
                   and trn.paretblname = pare.tblname and   trn.paretblid = pare.tblid
				inner join opeitms ope on ope.itms_id = trn.itms_id_trn and ope.processseq = trn.processseq_trn
									and ope.shelfnos_id_opeitm = trn.shelfnos_id_trn     
			where  (trn.tblname != trn.paretblname or trn.tblid != trn.paretblid)   
			group by trn.itms_id_trn , trn.processseq_trn 
		&
    end
end
