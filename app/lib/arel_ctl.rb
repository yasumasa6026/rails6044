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
	
	def proc_processreqs_add reqparams
		processreqs_id = proc_get_nextval("processreqs_seq")
		if reqparams["seqno"].nil?
			reqparams["seqno"] = []
		end	
		strsql = %Q%select id from persons where email = '#{reqparams[:email]}'
		%
		person_id = ActiveRecord::Base.connection.select_value(strsql)
		reqparams["seqno"] << processreqs_id  ###
		setParams = reqparams.dup
		setParams.delete(:parse_linedata)  ###size 8192対策
		setParams.delete(:lineData)
		strsql = %Q&
			insert into processreqs(
						contents,remark,
						created_at,updated_at,
						update_ip,persons_id_upd,reqparams,
						seqno,id,result_f)
					values(
						'','#{reqparams["remark"]}',
						to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
						to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
						'',#{person_id},'#{setParams.to_json}',
						#{reqparams["seqno"][0]},#{processreqs_id},'0')
		&
		ActiveRecord::Base.connection.insert(strsql) 
		return processreqs_id,reqparams
	end

	def proc_createtable fmtbl,totbl,fmview,params  ### fmtbl:元のテーブル totbl:fmtblから自動作成するテーブル
		strsql = %Q% select pobject_code_sfd from  func_get_screenfield_grpname('#{params[:email]}','r_#{totbl}')
		%
		toFields = ActiveRecord::Base.connection.select_values(strsql) 
		blk = RorBlkCtl::RorClass.new("r_#{totbl}")
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
						command_c["shelfno_code"] = "000"
						command_c["shelfno_name"] = "same as loca name"  
						command_c["id"] = nil
				end
			when /^workplaces/
				case totbl
				when "shelfnos"  
						command_c["shelfno_code"] =  "000"
						command_c["shelfno_name"] = "same as loca name"  
						command_c["shelfno_content"] = "作業用"
						command_c["id"] = nil
				end
			when /^purords/
				case totbl
				when /pay/
					###支払日の計算 要
				end
			when /^puracts/
				case totbl
				
				when /pay/
					strsql = %Q&
							select * from r_putacts where puract_sno = '#{fmview["prdact_sno_puract"]}'
						&
					puract = ActiveRecord::Base.connection.select_one(strsql)
					toFields.each do |key|
						prevkey = key.to_s.gsub("payord","prdact")
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
								command_c[key] = puract[prevkey]
							end
						when /_amt|_qty/   ###例：qty_schとqtyは同一項目とみなす
							if puract[prevkey]
								if key.to_s.split(/_amt|_qty/)[0] == prevkey.to_s.split(/_amt|_qty/)[0]
									command_c[key] = puract[prevkey]
								end
							end
						else
							if toFields.index(prevkey)
								command_c[key] = puract[prevkey]
							end	
						end
					end
					###支払日の計算　要
				# when /^prdords/
				# 	command_c["prdord_sno_puract"] =  fmview["puract_sno"]
				# 	command_c["prdord_duedate"] =  fmview["puract_rcptdate"].to_time + 24*3600  ###!!!稼働日考慮要
				end
			when /^prdacts/
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
						   proc_createtable fmtbl,totbl,fmview,reqparams["classname"] 
						   qty_stk -=  packqty 
						   idx += 1
						 end
				else
					fmview[sym_qty_stk] = qty_stk
					proc_createtable fmtbl,totbl,fmview,reqparams["cassname"]
				end
			when /custords|custdlvs|custacts/
				case totbl
				when /bil/
					###入金日の計算
				end
		end
		command_c["sio_classname"] =
			if params[:classname] =~ /_add_|_insert_/
				"_add_proc_createtable_data"
				command_c["#{totbl.chop}_created_at"] = Time.now
			else
				"_update_proc_createtable_data"
			end
		command_c["#{totbl.chop}_person_id_upd"] = params[:person_id_upd]
		command_c["id"] = ArelCtl.proc_get_nextval("#{totbl}_seq")
		blk.proc_create_tbldata(command_c)
		blk.proc_private_aud_rec({},command_c)
	end	

	def proc_createDetailTableFmHead  headTbl,baseTbl,headCommand,fmView,params
		detailTbl = headTbl.sub(/heads$/,"s") 
		strsql = %Q% select pobject_code_sfd from  func_get_screenfield_grpname('#{params[:email]}','r_#{detailTbl}')
		%
		toFields = ActiveRecord::Base.connection.select_values(strsql) 
		blk = RorBlkCtl::RorClass.new("r_#{detailTbl}")
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
					command_c["id"] = fmView["id"]
				end
			when /_sno$|_cno$|_gno$/ 
				if params[:classname] =~ /_add_|_insert_/
					command_c[key] = ""
				else
					command_c[key] = fmView[prevkey]
				end
			when /_amt|_qty/   ###例：qty_sch,qty,qty_stkは同一項目とみなす
				if fmView[prevkey]
					if key.to_s.split(/_amt|_qty/)[0] == prevkey.split(/_amt|_qty/)[0]
						command_c[key] = fmView[prevkey]
					end
				end
			else
				if toFields.index(prevkey)  ###配列に該当のkeyがあった時
					command_c[key] = fmView[prevkey]
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
		command_c["#{headTbl.chop}_person_id_upd"] = params[:person_id_upd]
		command_c["id"] = ArelCtl.proc_get_nextval("#{headTbl}_seq")
		blk.proc_create_tbldata(command_c)
		blk.proc_private_aud_rec({},command_c)
		head = {"amt" => amt,"taxrate" => taxrate,"#{headTbl.chop}_id" => command_c["id"]}
		returen head
	end	

	def consume_amt_sch_by_act fmtbl,fmtblid,prev_totbl
		taxrate = 0.1  ###変更要
		srctbl = fmtbl
		srctblid = fmtblid
		flg = false
		until flg == true
			strsql = %Q&select * from linktbls where tblname = '#{srctbl}' and tblid = #{srctblid}&
			flg = true
			ActiveRecord::Base.connection.select_all(strsql).each do |link|
				case link["srctblname"] 
				when /ords/
					linl_sql = %Q&select sum(qty_src) from linktbls 
									where  srctblname = #{link["srctblname"]} and srctblid = #{link["srctblid"]} 
									group by srctblname,srctblid
									&
					link_rec = ActiveRecord::Base.connection.select_one(link_sql)
					prev_sql = %Q&select * from #{link["srctblname"]} 	where  srctblid = #{link["srctblid"]} 
									&
					prev_rec = ActiveRecord::Base.connection.select_one(link_sql)
					amt_sch = prev_rec["amt"].to_f - link_rec["qty_src"].to_f * prev_rec["price"]
					tax = amt_sch * taxrate
					amt_sch_sql = %Q& select * from  r_#{prev_totbl} 
										where  #{prev_totbl.chop}_sno_#{link["srctblname"].chop} = #{ord["sno"]}&
					command_c = ActiveRecord::Base.connection.select_one(amt_sch_sql)
					command_c["#{prev_totbl.chop}_amt_sch"] = amt_sch
					command_c["#{prev_totbl.chop}_tax"] = tax
					command_c["sio_code"] = command_c["sio_viewname"] =  "r_" + prev_totbl
					command_c["sio_classname"] = "_update_consume_amt_sch_by_act"
				when /insts$|dlvs$|acts$|replyinputs$/
					srctbl = link["srctblname"]
					srctblid = link["srctblid"]
					flg = false
				end
			end
		end
	end

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
					' ',#{base["persons_id_upd"]},'2099/12/31','#{base["remark"]}')
				&
		ActiveRecord::Base.connection.insert(strsql)
		return linktbl_id
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
							' ',#{rec_alloc["persons_id_upd"]},'2099/12/31','#{rec_alloc["remark"]}',
							'#{rec_alloc["allocfree"]}')
		&
		ActiveRecord::Base.connection.insert(strsql)
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
						itms_id_org,processseq_org,locas_id_org,
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
					#{gantt["itms_id_org"]},#{gantt["processseq_org"]},#{gantt["locas_id_org"]},
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
					"persons_id_upd" => gantt["persons_id_upd"]}
		case gantt["tblname"] 
		when /^prd|^pur|dymschs/
			linktbl_id = proc_insert_linktbls(src,base)
			alloc = {"srctblname" => gantt["tblname"],"srctblid" => gantt["tblid"],"trngantts_id" => gantt["trngantts_id"],
						"qty_linkto_alloctbl" => gantt["qty_sch"].to_f + gantt["qty"].to_f + gantt["qty_stk"].to_f,
						"remark" => "#{self} line #{__LINE__} #{Time.now}","persons_id_upd" => gantt["persons_id_upd"],
						"allocfree" => 	if gantt["tblid"] == gantt["paretblid"] and gantt["tblid"] == gantt["orgtblid"] and
											gantt["tblname"] == gantt["paretblname"] and gantt["tblname"] == gantt["orgtblname"] 
												"free" 
										else
												"alloc"
										end}
			alloctbl_id = proc_insert_alloctbls(alloc)
		when /^cust/
			linktbl_id = proc_insert_linkcusts(src,base)
			alloctbl_id = nil
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
		stkinout["duedate"] = stkinout["starttime"] =  CtlFields.proc_get_endtime stkinout["tblname"],tmptbldata
		return stkinout		
	end
	
	def proc_add_linktbls_update_alloctbls(src,base,linktbl_ids,alloctbl_ids)  ###前の状態から現状への変更
		###
		###  今の関係(linktbls)は変更しない。履歴として残している。
		###
		linktbl_ids << proc_insert_linktbls(src,base)
		###
		strsql = %Q&
			update alloctbls set qty_linkto_alloctbl = qty_linkto_alloctbl - #{base["qty_src"]},
						updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
						remark = '#{self} line:(#{__LINE__})'|| remark,
						persons_id_upd = #{base["persons_id_upd"]}
					where id = #{src["alloc_id"]} 
			 &
		 ActiveRecord::Base.connection.update(strsql)

		strsql = %Q&
		 	  update alloctbls set qty_linkto_alloctbl = qty_linkto_alloctbl - #{base["qty_src"]},
			   				updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
		 					remark = '#{self} line:(#{__LINE__})'||remark,
							persons_id_upd =  #{base["persons_id_upd"]}
		 			where id = #{base["alloc_id"]} 
		 	  &
		ActiveRecord::Base.connection.update(strsql)

		alloc = {"trngantts_id" => src["trngantts_id"],"srctblname" => base["tblname"] ,
			 "srctblid" => base["tblid"],"allocfree" => "alloc",
			"qty_linkto_alloctbl" => base["qty_src"],"persons_id_upd" => base["persons_id_upd"],
			 "remark" => "#{self} (line: #{__LINE__} #{Time.now})"}
		alloctbl_ids << proc_insert_alloctbls(alloc)

		# ###在庫の修正はproc_src_base_trn_stk_update
		return linktbl_ids ,alloctbl_ids
	end
	
	
	def proc_update_linktbls_alloctbls_inoutlotstks(src)  ###schs 数量変更
		###
		strsql = %Q&
			update linktbls set qty_src = #{src["qty_sch"]},
						updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
						remark = '#{self} line:(#{__LINE__})'|| remark,
						persons_id_upd = #{src["persons_id_upd"]}
					where trngantts_id = #{scr["trngantts_id"]} and srctblid = #{src["tblid"]} and tblid = #{src["tblid"]}
					and srctblname = #{src["tblname"]} and tblname = #{src["tblname"]}   
			 &
		 ActiveRecord::Base.connection.update(strsql)
		 ###
		strsql = %Q&
			update alloctbls set qty_linkto_alloctbl = #{src["qty_sch"]},
					 updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
						 remark = '#{self} line:(#{__LINE__})'|| remark,
						 persons_id_upd = #{src["persons_id_upd"]}
					 where trngantts_id = #{scr["trngantts_id"]} and srctblid = #{src["tblid"]} and srctblname = #{src["tblname"]}   
			  &
		ActiveRecord::Base.connection.update(strsql)

		src["itms_id"] = src["itms_id_trn"]
		src["shlfnos_id"] = src["shlfnos_id_trn"]
		src["processseq"] = src["processseq_trn"]
		src["qty_sch"] = src["new_qty_sch"] - src["qty_sch"]
		src = Shipment.proc_lotstkhists_in_out("in",src)

		src["wh"] = "lotstkhists"
		src["srctblid"] = src["lotstkhists_id"]
		Shipment.proc_check_inoutlotstk("in",src)
		return 
	end



	### freeがschsを引き当てた時,schsがfreeに引きあったとき!trngantts_id==nil ordsがinsts,actsになった時 trngantts_id==nil
	###xxschsとxxordsの関係やxxxordsとxxxxacts等の関係のリンク作成
	def proc_src_trn_stk_update(src,base)  ###alloc_qty:qty_srcに引当った数 
		return if src["tblname"] == base["tblname"] and src["tblid"].to_f == base["tblid"].to_f  
		###qty_src 引き当て先元リンク数,
		###src 引当もと旧のリンク数,###数量変更はsrcの相手側
		###src["trngantts_id"] 
		###前の状態の在庫更新
		###alloc_qty:qty_srcに引当った数 
		###前の状態の明細在庫	

		case src["tblname"]  
		when	/^prd|^pur/
			strsql = %Q&
					select  sum(qty_sch) qty_sch,sum(qty) qty,sum(qty_stk) qty_stk,trngantts_id from 
						(select (qty_linkto_alloctbl) as qty_sch,0 as qty,0 as qty_stk,trngantts_id 
									from alloctbls where trngantts_id = #{src["trngantts_id"]} 
									and srctblname like '%schs'
						union
							select  0 as qty_sch,(qty_linkto_alloctbl) as qty ,0 as qty_stk,trngantts_id 
									from alloctbls where trngantts_id = #{src["trngantts_id"]} 
									and (srctblname like '%ords' or  srctblname like '%insts' or  srctblname like '%replyinputs')  
						union
							select  0 as qty_sch,0 as qty ,(qty_linkto_alloctbl) as qty_stk,trngantts_id 
									from alloctbls where trngantts_id = #{src["trngantts_id"]} 
									and (srctblname like '%acts' or srctblname like '%dlvs')) alloc
									group by trngantts_id
				&
		when /^cust/  ###custxxxsにはalloctblsは使用しない。数量減しても回復しない。
			strsql = %Q&
					select  sum(qty_sch) qty_sch,sum(qty) qty,sum(qty_stk) qty_stk,trngantts_id from 
						(select (qty_src) as qty_sch,0 as qty,0 as qty_stk,trngantts_id 
									from linkcusts where trngantts_id = #{src["trngantts_id"]} 
									and tblname like '%schs'
						union
							select  0 as qty_sch,(qty_src) as qty ,0 as qty_stk,trngantts_id 
									from linkcusts where trngantts_id = #{src["trngantts_id"]} 
									and (tblname like '%ords' or  srctblname like '%insts' )  
						union
							select  0 as qty_sch,0 as qty ,(qty_src) as qty_stk,trngantts_id 
									from linkcusts where trngantts_id = #{src["trngantts_id"]} 
									and (tblname like '%acts' or tblname like '%dlvs')) alloc
									group by trngantts_id
				&
		end
		alloc = ActiveRecord::Base.connection.select_one(strsql)
		update_schsql = %Q&
			update trngantts set qty_sch =  #{alloc["qty_sch"].to_f},qty = #{alloc["qty"].to_f},qty_stk = #{alloc["qty_stk"].to_f},
									updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
									remark = '#{self} line:#{__LINE__}' || remark
					where id = #{src["trngantts_id"]}
					&
		ActiveRecord::Base.connection.update(update_schsql)
		###
		update_sql = %Q&
		update inoutlotstks set qty_sch = #{alloc["qty_sch"].to_f },
						qty = #{alloc["qty"].to_f },
						qty_stk = #{alloc["qty_stk"].to_f },
						remark = '#{self}   LINE:#{__LINE__} '|| remark
			where   trngantts_id = #{src["trngantts_id"]}		
					and srctblname = '#{base["wh"]}'	and tblname = '#{src["tblname"]}'	
					and tblid = #{src["tblid"]}	 
		& 	
		ActiveRecord::Base.connection.update(update_sql)

		strsql = %Q&
					select * from inoutlotstks 
						where   trngantts_id = #{src["trngantts_id"]}		
						and srctblname = '#{base["wh"]}'	and tblname = '#{src["tblname"]}'	
						and tblid = #{src["tblid"]}	 
		&
		inout = ActiveRecord::Base.connection.select_one(strsql)

		case base["wh"]
		when "lotstkhists" 
			strsql = %Q&
				select  id,starttime,itms_id ,processseq,shelfnos_id,stktaking_proc,
				lotno ,packno,prjnos_id from lotstkhists where id = #{inout["srctblid"]}
			&
			stkinout = ActiveRecord::Base.connection.select_one(strsql)
			stkinout["qty_sch"] = alloc["qty_sch"]
			stkinout["qty"] = alloc["qty"]
			stkinout["qty_stk"] = alloc["qty_stk"]
			base["srctblid"] = stkinout["id"]
			Shipment.proc_lotstkhists_in_out("out",stkinout)
		when "custwhs" 
			update_sql = %Q&
				update custwhs set qty_sch = #{alloc["qty_sch"].to_f },
							qty = #{alloc["qty"].to_f },
							qty_stk = #{alloc["qty_stk"].to_f },
							remark = '#{self}    LINE:#{__LINE__} '|| remark
				where   id = #{inout["srctblid"]}
						& 
			ActiveRecord::Base.connection.update(update_sql)
		when "supplierwhs" 
			update_sql = %Q&
				update supplierwhs set qty_sch = #{alloc["qty_sch"].to_f },
							qty = #{alloc["qty"].to_f },
							qty_stk = #{alloc["qty_stk"].to_f },
							remark = '#{self}    LINE:#{__LINE__} '|| remark
					where   id = #{inout["srctblid"]}
						& 
			ActiveRecord::Base.connection.update(update_sql)
		end

	end
	def proc_base_trn_stk_update(src,base)
		if src["trngantts_id"] != base["trngantts_id"]
			case base["tblname"]  
			when	/^prd|^pur/
				strsql = %Q&
							select  sum(qty_sch) qty_sch,sum(qty) qty,sum(qty_stk) qty_stk,trngantts_id from 
									(select (qty_linkto_alloctbl) as qty_sch,0 as qty,0 as qty_stk,trngantts_id 
											from alloctbls where trngantts_id = #{base["trngantts_id"]} 
															and srctblname like '%schs'
								union
									select  0 as qty_sch,(qty_linkto_alloctbl) as qty ,0 as qty_stk,trngantts_id 
											from alloctbls where trngantts_id = #{base["trngantts_id"]} 
															and (srctblname like '%ords' or  srctblname like '%insts' or  srctblname like '%replyinputs')  
								union
									select  0 as qty_sch,0 as qty ,(qty_linkto_alloctbl) as qty_stk,trngantts_id 
											from alloctbls where trngantts_id = #{base["trngantts_id"]} 
															and (srctblname like '%acts' or srctblname like '%dlvs')) alloc
								group by trngantts_id
				& 
			when /^cust/  ###custxxxsにはalloctblsは使用しない。数量減しても回復しない。
			   strsql = %Q&
					   select  sum(qty_sch) qty_sch,sum(qty) qty,sum(qty_stk) qty_stk,trngantts_id from 
						   (select (qty_src) as qty_sch,0 as qty,0 as qty_stk,trngantts_id 
									   from linkcusts where trngantts_id = #{base["trngantts_id"]} 
									   and tblname like '%schs'
						   union
							   select  0 as qty_sch,(qty_src) as qty ,0 as qty_stk,trngantts_id 
									   from linkcusts where trngantts_id = #{base["trngantts_id"]} 
									   and (tblname like '%ords' or  srctblname like '%insts' )  
						   union
							   select  0 as qty_sch,0 as qty ,(qty_src) as qty_stk,trngantts_id 
									   from linkcusts where trngantts_id = #{base["trngantts_id"]} 
									   and (tblname like '%acts' or tblname like '%dlvs')) alloc
									   group by trngantts_id
				   &
			end
			alloc = ActiveRecord::Base.connection.select_one(strsql)
			update_schsql = %Q&
				update trngantts set qty_sch = #{alloc["qty_sch"].to_f},qty = #{alloc["qty"].to_f},qty_stk = #{alloc["qty_stk"].to_f},
									updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
									remark = '#{self}  line:#{__LINE__}' || remark
					where id = #{base["trngantts_id"]}
					&
			ActiveRecord::Base.connection.update(update_schsql)
		end
		###
		###今の状態の明細在庫の更新
		# strsql = %Q&
		# 			select 'lotstkhists' wh,lot.id lotstkhists_id,lot.id srctblid,inout.id inout_id,
		# 				inout.qty_sch,inout.qty,inout.qty_stk  from lotstkhists lot
		# 				inner join  inoutlotstks inout on lot.id = inout.srctblid
		# 			where lot.itms_id = #{base["itms_id"]} and lot.processseq = #{base["processseq"]}
		# 			and inout.tblid = #{base["tblid"]} and inout.trngantts_id = #{base["trngantts_id"]}
		# &	###lotno,packno毎にtblidは異なる。

		# stk = ActiveRecord::Base.connection.select_one(strsql)
		# if stk.nil?
		# 	Rails.logger.debug "  get lotstkhists error"
		# 	Rails.logger.debug " base: #{base} "
		# 	raise
		# end
		update_sql = %Q&  ---引き当て元の在庫明細変更
				update inoutlotstks set qty_sch = #{alloc["qty_sch"].to_f },
									qty = #{alloc["qty"].to_f },qty_stk = #{alloc["qty_stk"].to_f},
									remark = 'ArelCtl.proc_src_base_link_alloc_update  LINE:#{__LINE__} '
						where  tblid = #{base["tblid"]} and trngantts_id = #{base["trngantts_id"]}
						and srctblid = #{base["srctblid"]} and srctblname = '#{base["wh"]}'   ---base["srctblid"]-->wh tbl id
						---srctblid-->lotstkhists_id,custwhs_id,supplierwhs_id
					& 
		ActiveRecord::Base.connection.update(update_sql)

		### lotstkhists　の在庫は変わらない
		strsql = %Q&
			select * from inoutlotstks
				where  srctblname = '#{base["wh"]}' and srctblid = #{base["srctblid"]}	
				and trngantts_id = #{src["trngantts_id"]}		
				and tblname = '#{base["tblname"]}'	and tblid = #{base["tblid"]}
			&
		inout = ActiveRecord::Base.connection.select_one(strsql)
		if inout 
			update_sql = %Q&
					update inoutlotstks set qty_sch = #{alloc["qty_sch"].to_f },
										qty =  #{alloc["qty"].to_f },
										qty_stk =  #{alloc["qty_stk"].to_f },
										remark = '#{self}   LINE:#{__LINE__} '|| remark
							where id = #{inout["id"]}
						& 
			ActiveRecord::Base.connection.update(update_sql)
		else
			stk = {"wh" => base["wh"],"srctblid" => base["srctblid"],	
					"trngantts_id" => src["trngantts_id"],		
					"tblname" => base["tblname"] ,"tblid" => base["tblid"],
					"qty_sch" => alloc["qty_sch"],"qty" => alloc["qty"],"qty_stk" => alloc["qty_stk"],
					"remark" => "ArelCtl.proc_src_base_link_alloc_update line:#{__LINE__}"}
			Shipment.proc_insert_inoutlotstk_sql(1,stk)
		end
		return 
	end
	
    def proc_nditmSql(opeitms_id)  
        %Q%
            select ope.itms_id,nditm.itms_id_nditm,  ---itms_id = itms_id_nditm
               ope.processseq,nditm.processseq_nditm,
               nditm.consumtype,nditm.parenum,nditm.chilnum,
               nditm.consumunitqty,nditm.consumminqty,nditm.consumchgoverqty,
               ope.id opeitms_id,ope.prdpur,ope.packno_proc,
               ope.packqty,ope.prdpur,ope.units_id_case_shp,itm.units_id,
               ope.locas_id_opeitm,ope.shelfnos_id_opeitm,  ---子部品作業場所
               ope.locas_id_to_opeitm,ope.shelfnos_id_to_opeitm,   ---子部品保管場所
			   ope.consumauto,ope.duration,ope.units_lttime
           from nditms nditm 
               inner join itms itm on itm.id = nditm.itms_id_nditm 
               left join (select o.*,s.locas_id_shelfno locas_id_opeitm,xto.locas_id_shelfno locas_id_to_opeitm
                           from opeitms o 
                           inner join shelfnos s on o.shelfnos_id_opeitm = s.id
                           inner join shelfnos xto on o.shelfnos_id_to_opeitm = xto.id
						   where  o.priority = 999) ope ---完成後の移動場所から親の場所に
                   on  ope.itms_id = nditm.itms_id_nditm  and ope.processseq = nditm.processseq_nditm
                   where nditm.expiredate > current_date and nditm.opeitms_id = #{opeitms_id} 
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
																			and link.tblid = alloc.srctblid 
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
