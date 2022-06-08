# -*- coding: utf-8 -*-
#shipment
# 2099/12/31を修正する時は　2100/01/01の修正も
module Shipment
	extend self
	def proc_mkshpinsts screenCode,clickIndex  ###screenCode:r_purords,r_prdords
		pagedata = []
		outcnt = 0
		shortcnt = 0
		err = ""
		shp = {}
		shp["inoutflg"] = "shpinst"
		clickIndex.each do |strselected|  ###-次のフェーズに進んでないこと。
			selected = JSON.parse(strselected)
			### prd,pur ords,instsでshpordsは自動作成されている。
			strsql = %Q&
						select shp.* from shpords shp
							inner join #{screenCode.split("_")[1]}  ord on shp.tblid = ord.id 
							where  shp.tblname = '#{screenCode.split("_")[1]}' and  oid.id = #{selected["id"]}
						&	
			parent = ActiveRecord::Base.connection.select_one("select * from #{screenCode.split("_")[1]} where id = #{selected["id"]} ")
			parent["tblname"] = screenCode.split("_")[1]
			parent["tblid"] = selected["id"]
			gantt = {"tblname" => screenCode.split("_")[1],"tblid" => selected["id"]}
			reqparams = {}
			reqparams["tbldata"] = parent
			reqparams["gantt"] = gantt
			outcnt = shortcnt = 0
			err = ""
			ActiveRecord::Base.connection.select_all(strsql).each do |shp|
				reqparams["opeitm"] = proc_get_opeitms_rec shp["itms_id"],nil,shp["processseq"],999
				shp_qty = 0
				strsql = %Q&
							select sum(inout.qty_sch)  qty_sch,sum(inout.qty) qty,sum(inout.qty_stk) qty_stk,
								lot.itms_id,lot.processseq,lot.shelfnos_id,lot.lotno,lot.packno,max(lot.qty_stk) max_qty_stk
								from inouttks inout 
									inner join (select trn.id from trngantts pare
								 			inner join alloctbls alloc on pare.id = alloc.trngantts_id 
											 				where srctblname = '#{screenCode.split("_")[1]}' 
															and srctblid = #{selected["id"]}
															and qty > qty_linkto_alloctbl
											inner join trngantts trn on pare.orgtblname = trn.orgtblname 
														and pare.orgtblid = trn.orgtblid
														and pare.tblname = trn.paretblname and pare.tblid = trn.paretblid
											where trn.itms_id_trn = #{shp["itms"]} and trn.processseq_trn = #{shp["processseq"]} 
									) trn on trn.id = inout.trngantts_id
								inner join lotstkhists lot on lot.id = inout.srctblid
								where lot.itms_id =  #{shp["itms"]} and lot.processseq = #{shp["processseq"]}
								and lot.shelfnos_id = #{shp["shelfnos_id_fm"]} and inout.srctblname = 'lotstkhists'
								and (inout.qty_sch > 0 or inout.qty > 0  or inout.qty_stk > 0)  
								group by lot.itms_id,lot.processseq,lot.shelfnos_id,lot.lotno,lot.packno  
				&
				ActiveRecord::Base.connection.select_all(strsql).each do |stk|
					shp["lotno"] = stk["lotno"]
					shp["packno"] = stk["packno"]
					shp["qty_stk"] = stk["qty_stk"]
					shp["qty_shp"] = stk["max_qty_stk"]
					shp["qty_shortage"] = (stk["qty_sch"].to_f + stk["qty"].to_f)
					reqparams["child"] = shp
					proc_create_shp reqparams
					outcnt += 1
					shortcnt += 1 if shp["qty_shortage"] > 0
					shp_qty += (stk["qty_stk"].to_f + shp["qty_shortage"] )
				end   ###packnoが虫食い状態になる考慮はされてない。--->対策がわからない。
				if shp["qty"].to_f != shp_qty
					err << "shp_qty != inout_qty itms_id:#{shp["itms_id"]} shp_qty:#{shp["qty"]},inout_qty:#{shp_qty}"
				end
			end
		end  
		return outcnt,shortcnt,err
	end	

	def proc_shpact_confirmall params
		command_all = []
		pagedata = []
		outcnt = 0
		err = ""
		confirm_data = JSON.parse(params["confirm_data"])
		begin
			ActiveRecord::Base.connection.begin_db_transaction()
			confirm_data.each do |selected|  ###-次のフェーズに進んでないこと。
				blk = RorBlkCtl::BlkClass.new("r_shpact")
				command_c = blk.command_init
				strsql = %Q&select * from r_shpinsts where id = #{selected["id"]}
					& 
				rec = ActiveRecord::Base.connection.select_one(strsql)
				strsql = %Q&select pobject_code_sfd from r_screenfields where pobject_code_scr = 'r_shpacts'
						and screenfield_expiredate > current_date and screenfield_selection = '1'
						and pobject_code_sfd like 'shpact_%' 
				& 
				fields = ActiveRecord::Base.connection.select_values(strsql)			
				rec.each do |key,val|
					if key !~ /_id/ and key != "id"
						if selected[key]
							commnad_r[key] =  selected[key]
						end
					end
					new_key = key.gsub("shpinst","shpact")
					if !(fields.select{|k| k == new_key}).empty?
						command_c[new_key] = rec[key]
					end
				end

				strsql  = %Q%select * from r_outstks  where  id = #{rec["shpinst_outstk_id"]} %
				r_outstks  = ActiveRecord::Base.connection.select_one(strsql)  ###更新後のr_instks
				strsql = %Q&select id from shelfnos where locas_id_shelfno = #{rec["shpinst_loca_id_to"]}
												and code = '000'   --- 000=>cosume place
				&
				shelfnos_id = ActiveRecord::Base.connection.select_value(strsql)
				### xxxx stkinout = rinout_to_inout "outstk",r_outstks 
				stkinout["shelfnos_id_in"] = shelfnos_id
				stkinout["inoutflg"] = "shpacts"
				packnos =[{:packno=>r_outstks["outstk_packno"]}]
				command_c["shpact_instk_id"] = instk_ids[0]
				command_c[:sio_code] =  command_c[:sio_viewname] =  "r_shpacts"
				command_c[:sio_message_contents] = nil
				command_c[:sio_recordcount] = 1
				command_c[:sio_result_f] =   "0"  
				command_c[:sio_classname] = "shpacts_add_"
				command_all << command_c
				outcnt += 1
				blk.proc_create_tbldata(command_c) ##
				setParams = blk.proc_private_aud_rec(params,command_c)
			end  
		rescue
			ActiveRecord::Base.connection.rollback_db_transaction()
			command_c[:sio_result_f] = "9"  ##9:error
			command_c[:sio_message_contents] =  "class #{self} : LINE #{__LINE__} $!: #{$!} "[0..3999]    ###evar not defined
			command_c[:sio_errline] =  "class #{self} : LINE #{__LINE__} $@: #{$@} "[0..3999]
			Rails.logger.debug"error class #{self} : #{Time.now}: #{$@} "
			Rails.logger.debug"error class #{self} : $!: #{$!} "
			Rails.logger.debug"  command_c: #{command_c} "
	  	else
			ActiveRecord::Base.connection.commit_db_transaction()
			if setParams.size > 0   ###画面からの時はperform_later(setParams["seqno"][0])　seqnoは一つのみ。次の処理がないときはreqparams=nil
				if setParams["seqno"].size > 0
					if command_c["mkord_runtime"] 
						CreateOtherTableRecordJob.set(wait: command_c["mkord_runtime"].to_f.hours).perform_later(setParams["seqno"][0])
					else	
						CreateOtherTableRecordJob.perform_later(setParams["seqno"][0])
					end
				end
			end	
	  	ensure
	  	end ##begin
		return outcnt,err
	end	

	def proc_mkshpacts params,grid_columns_info
		tmp = []
		outcnt = 0
		err = ""
		strselect = "("
		(params["clickIndex"]).each do |selected|  ###-次のフェーズに進んでないこと。
			selected = JSON.parse(selected)
			strselect << selected["id"]+","
		end
		strselect = strselect.chop + ")"
		strsorting = ""
		if params[:sortBy]  and   params[:sortBy] != "" ###: {id: "itm_name", desc: false}
			sortBy = JSON.parse(params[:sortBy])
			sortBy.each do |sortKey|
				strsorting = " order by " if strsorting == ""
				strsorting << %Q% #{sortKey["id"]} #{if sortKey["desc"]  == false then " asc " else "desc" end} ,%
			end	
			if strsorting == ""
				strsorting = " order by id desc "
			else
				strsorting << " id desc "
			end
		else
			strsorting = "  order by paretblid,id desc "
			params[:sortBy] = "[]"
		end
		strsql = "select   #{grid_columns_info["select_fields"]} 
						from (SELECT ROW_NUMBER() OVER (#{strsorting}) , #{grid_columns_info["select_fields"]} 
												 FROM r_shpinsts inst where
												 shpinst_paretblname = '#{params["pareScreenCode"].split("_")[1]}' and
												 shpinst_paretblid = #{strselect} and 
												 not exists(select 1 from shpacts act where
													 paretblname = '#{params["pareScreenCode"].split("_")[1]}' and
													 paretblid = #{strselect} and 
													 act.itms_id = inst.shpinst_itm_id and
													 act.processseq = inst.shpinst_processseq) ) x
													where ROW_NUMBER > #{(params[:pageIndex].to_f)*params[:pageSize].to_f} 
													and ROW_NUMBER <= #{(params[:pageIndex].to_f + 1)*params[:pageSize].to_f} 
															  "
		pagedata = ActiveRecord::Base.connection.select_all(strsql)
		
		strsql = " select count(*) FROM r_shpinsts inst where
					shpinst_paretblname = '#{params["pareScreenCode"].split("_")[1]}' and
					shpinst_paretblid = #{strselect} and 
					not exists(select 1 from shpacts act where
						paretblname = '#{params["pareScreenCode"].split("_")[1]}' and
						paretblid = #{strselect} and 
						act.itms_id = inst.shpinst_itm_id and
						act.processseq = inst.shpinst_processseq)"
		 ###fillterがあるので、table名は抽出条件に合わず使用できない。
		totalCount = ActiveRecord::Base.connection.select_value(strsql)
		params[:pageCount] = (totalCount.to_f/params[:pageSize].to_f).ceil
		params[:totalCount] = totalCount.to_f
		return pagedata 
	end	
	
	def proc_refshpacts params,grid_columns_info
		tmp = []
		outcnt = 0
		err = ""
		strselect = "("
		(params["clickIndex"]).each do |selected|  ###-次のフェーズに進んでないこと。
			selected = JSON.parse(selected)
			strselect << selected["id"]+","
		end
		strselect = strselect.chop + ")"
		strsorting = ""
		if params[:sortBy]  and   params[:sortBy] != "" ###: {id: "itm_name", desc: false}
			sortBy = JSON.parse(params[:sortBy])
			sortBy.each do |sortKey|
				strsorting = " order by " if strsorting == ""
				strsorting << %Q% #{sortKey["id"]} #{if sortKey["desc"]  == false then " asc " else "desc" end} ,%
			end	
			if strsorting == ""
				strsorting = " order by id desc "
			else
				strsorting << " id desc "
			end
		else
			strsorting = "  order by paretblid,id desc "
			params[:sortBy] = "[]"
		end
		strsql = "select   #{grid_columns_info["select_fields"]} 
						from (SELECT ROW_NUMBER() OVER (#{strsorting}) , #{grid_columns_info["select_fields"]} 
												 FROM r_shpacts inst where
												 shpact_paretblname = '#{params["pareScreenCode"].split("_")[1]}' and
												 shpact_paretblid = #{strselect}  ) x
													where ROW_NUMBER > #{(params[:pageIndex].to_f)*params[:pageSize].to_f} 
													and ROW_NUMBER <= #{(params[:pageIndex].to_f + 1)*params[:pageSize].to_f} 
															  "
		pagedata = ActiveRecord::Base.connection.select_all(strsql)
		
		strsql = " select count(*) FROM r_shpacts act where
					shpact_paretblname = '#{params["pareScreenCode"].split("_")[1]}' and
					shpact_paretblid = #{strselect} "
		 ###fillterがあるので、table名は抽出条件に合わず使用できない。
		totalCount = ActiveRecord::Base.connection.select_value(strsql)
		params[:pageCount] = (totalCount.to_f/params[:pageSize].to_f).ceil
		params[:totalCount] = totalCount.to_f
		return pagedata 
	end	
	
	###shp用
	def proc_create_shp reqparams  ###
			###自分自身のshpschs を作成   shpinstsはmkshpinstsで対応親から子のshpinsts作成
		tbldata = reqparams["tbldata"]  ###親
		child = reqparams["child"]  ###出庫対象
		gantt = reqparams["gantt"]
		child_opeitm = reqparams["opeitm"]
		tblnamechop = yield.chop  
		##begin
			###ActiveRecord::Base.connection.begin_db_transaction()
			blk = RorBlkCtl::BlkClass.new("r_#{tblnamechop}s")
			command_c = blk.command_init
			if child["shelfno_id_to"] != tbldata["shelfnos_id_fm"]  ###子部品の保管場所!=shelfnos_id_fm親の作業場所
				command_c[:sio_classname] = "#{yield}_add_"
				command_c["#{tblnamechop}_id"] = "" 
				command_c["#{tblnamechop}_isudate"] = Time.now
				command_c["#{tblnamechop}_shelfno_id_fm"] = child["shelfnos_id_fm"] ###自身の保管先から出庫
				command_c["#{tblnamechop}_shelfno_id_to"] = tbldata["shelfnos_id_fm"]  ###親の作業場所へ納品
				command_c["#{tblnamechop}_duedate"] = (tbldata["starttime"].to_date - 1).strftime("%Y-%m-%d %H:%M:%S")   ###稼働日考慮
				command_c["#{tblnamechop}_depdate"] = (tbldata["starttime"].to_date - 2).strftime("%Y-%m-%d %H:%M:%S")
				command_c["#{tblnamechop}_gno"] = tbldata["sno"] 
				command_c["#{tblnamechop}_transport_id"] = 0 
				command_c["#{tblnamechop}_paretblname"] = gantt["tblname"] 
				command_c["#{tblnamechop}_paretblid"] = gantt["tblid"]
				command_c["#{tblnamechop}_consumauto"] = child_opeitm["consumauto"] 
				command_c["#{tblnamechop}_itm_id"] = child["itms_id"]   ### from shpords
				command_c["#{tblnamechop}_processseq"] = child["processseq"]
				stkinout = {}

				case tblnamechop
				when /shpsch/
					command_c["#{tblnamechop}_qty_sch"] = stkinout["qty_sch"] = child["qty_sch"].to_f
					stkinout["qty"] = stkinout["qty_stk"] = 0
					command_c["#{tblnamechop}_packno"] = if child_opeitm["packno_proc"] != "0" then "packno" else "" end  
					command_c["#{tblnamechop}_lotno"] = ""
				when /shpord/
					command_c["#{tblnamechop}_qty"] =  stkinout["qty"] = child["qty"].to_f
					command_c["#{tblnamechop}_unit_id_case_shp"] = child_opeitm["units_id_case_shp"]  
					stkinout["qty_stk"] = stkinout["qty_sch"] = 0
					command_c["#{tblnamechop}_packno"] = if child_opeitm["packno_proc"] != "0" then "packno" else "" end  
					command_c["#{tblnamechop}_lotno"] = ""
				when /shpinst|shpact/  ###shpinstsは出の実在庫
					command_c["#{tblnamechop}_unit_id_case_shp"] = child["units_id_case_shp"]  
					command_c["#{tblnamechop}_qty_stk"] =  stkinout["qty_stk"] = child["qty_stk"].to_f 
					stkinout["qty"] = stkinout["qty_sch"] = 0
					command_c["#{tblnamechop}_packno"] = child["packno"]  ###from lotstkhists
					command_c["#{tblnamechop}_lotno"] = child["lotno"]
					if child_opeitm["units_id"] == child["units_id_case_shp"]   ###opeitm.unit_id == shpord.units_id_case_shp
						command_c["#{tblnamechop}_qty_shp"] = command_c["#{tblnamechop}_qty_stk"]
					else
						command_c["#{tblnamechop}_qty_shp"] = child["max_qty_stk"]  ###瓶等で出庫
					end	 
				end
			
				if gantt["tblname"] =~ /^pur/   ###tblname= 'feepayment'--->有償支給
					strsql =%Q&select * from pricemsts where tblname= 'feepayment' and expiredate >= current_date
									and itms_id = #{command_c["#{tblnamechop}_itm_id"]} 
									and processseq = #{command_c["#{tblnamechop}_processseq"]}
									and (locas_id = (select locas_id_shelfno from shelfnos  where id = #{tbldata["shelfnos_id_fm"]}) or 
										locas_id = (select id from locas where code = 'dummy' ))
									order by expiredate limit 1
					& 
					rec = ActiveRecord::Base.connection.select_one(strsql)
					if rec
						###日付、数量による再設定
					else
						command_c["#{tblnamechop}_price"] = 0 	
						command_c["#{tblnamechop}_amt_sch"] = 0
						command_c["#{tblnamechop}_tax"] = 0 	
					end
				else
					command_c["#{tblnamechop}_price"] = 0 	 
					command_c["#{tblnamechop}_amt_sch"] = 0
					command_c["#{tblnamechop}_tax"] = 0 		
				end		

				blk.proc_create_tbldata(command_c) ##
				setParams = blk.proc_private_aud_rec(reqparams,command_c)

				stkinout["tblname"] = yield
				stkinout["tblid"] = command_c["id"]
				stkinout["trngantts_id"] = gantt["trngantts_id"]
				stkinout["expiredate"] = command_c[tblnamechop+"_expiredate"]
				stkinout["lotno"] =   command_c["#{tblnamechop}_lotno"] 
				stkinout["packno"] =  command_c["#{tblnamechop}_packno"] 
				stkinout["prjnos_id"] = command_c[tblnamechop+"_prjno_id"]
				stkinout["itms_id"] = command_c[tblnamechop+"_itm_id"]
				stkinout["processseq"] = command_c[tblnamechop+"_processseq"]
				stkinout["starttime"] = command_c[tblnamechop+"_depdate"]
				case tblnamechop
				when "shpsch"
					stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = command_c[tblnamechop+"_shelfno_id_fm"]   ###出
					stkinout = proc_lotstkhists_in_out("out",stkinout)
					stkinout["starttime"] = command_c[tblnamechop+"_duedate"]
					stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = command_c[tblnamechop+"_shelfno_id_to"]   ###入り
					stkinout = proc_lotstkhists_in_out("in",stkinout)
				when "shpord"
					stkinout["qty_sch"] = -stkinout["qty"]
					stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = command_c[tblnamechop+"_shelfno_id_fm"]
					stkinout = proc_lotstkhists_in_out("out",stkinout)
					stkinout["starttime"] = command_c[tblnamechop+"_duedate"]
					stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = command_c[tblnamechop+"_shelfno_id_to"]
					stkinout = proc_lotstkhists_in_out("in",stkinout)
				when "shpinst"
					if stkinout["units_id"] == stkinout["units_id_case_shp"]
						stkinout["shelfnos_id_real"] = command_c[tblnamechop+"_shelfno_id_fm"]  
					else   ###瓶毎、リール毎移動
						stkinout["shelfnos_id_real"] = command_c[tblnamechop+"_shelfno_id_to"]
					end
					stkinout["qty"] = -stkinout["qty_stk"]
					stkinout["shelfnos_id"] = command_c[tblnamechop+"_shelfno_id_fm"]
					stkinout = proc_lotstkhists_in_out("out",stkinout)
				when "shpact"
					stkinout["units_id_case_shp"] = command_c[tblnamechop+"_unit_id_case_shp"]
					stkinout["qty"] = -stkinout["qty_stk"]
					stkinout["starttime"] = command_c[tblnamechop+"_duedate"]
					stkinout["shelfnos_id"] = command_c[tblnamechop+"_shelfno_id_to"]
					if stkinout["units_id"] == stkinout["units_id_case_shp"]
						stkinout["shelfnos_id_real"] = command_c[tblnamechop+"_shelfno_id_fm"]  
					else   ###瓶毎、リール毎移動
						stkinout["shelfnos_id_real"] = command_c[tblnamechop+"_shelfno_id_to"]
					end
					stkinout = proc_lotstkhists_in_out("in",stkinout)
				end	

				###shpxxxの在庫明細作成
				strsql = %Q&
					select child_gantt.id child_trngantts_id,
							pare_gantt.qty_sch qty_sch,pare_gantt.qty qty,pare_gantt.qty qty_stk from trngantts child_gantt
						inner join (select * from trngantts gantt
										inner join alloctbls alloc on alloc.trngantts_id = gantt.id
										where alloc.srctblname = '#{gantt["tblname"]}' and srctblid = #{gantt["tblid"]}
										and (qty_sch + qty + qty_stk) > qty_linkto_alloctbl) pare_gantt
							on pare_gantt.orgtblname = child_gantt.orgtblname and pare_gantt.orgtblid = child_gantt.orgtblid
							and pare_gantt.tblname = child_gantt.paretblname and pare_gantt.tblid = child_gantt.paretblid
						where child_gantt.itms_id_trn = #{stkinout["itms_id"]} and child_gantt.processseq_trn = #{stkinout["processseq"]}
				&
				ActiveRecord::Base.connection.select_all(strsql).each do |detail|
					stkinout["trngantts_id"] = detail["child_trngantts_id"]
					bqty = detail["qty_sch"].to_f + detail["qty"].to_f  ###親の必要数
					case tblnamechop
					when "shpsch"
						stkinout["qty_sch"] = tbldata["qty_sch"].to_f / bqty * stkinout["qty_sch"] 
						stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = command_c[tblnamechop+"_shelfnos_id_fm"]
						proc_check_inoutlotstk("out",stkinout)	
						stkinout["starttime"] = command_c[tblnamechop+"_duedate"]
						stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = command_c[tblnamechop+"_shelfnos_id_to"]
						proc_check_inoutlotstk("in",stkinout)
					when "shpord"
						stkinout["qty"] = tbldata["qty"].to_f / bqty * stkinout["qty"]
						stkinout["qty_sch"] = -stkinout["qty"]
						stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = command_c[tblnamechop+"_shelfnos_id_fm"]
						proc_check_inoutlotstk("out",stkinout)
						stkinout["starttime"] = command_c[tblnamechop+"_duedate"]
						stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = command_c[tblnamechop+"_shelfnos_id_to"]
						proc_check_inoutlotstk("in",stkinout)
					when "shpinst"
						stkinout["qty_stk"] = tbldata["qty_stk"].to_f / bqty * stkinout["qty_stk"]
						stkinout["qty"] = -stkinout["qty_stk"]
						stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = command_c[tblnamechop+"_shelfnos_id_fm"]
						proc_check_inoutlotstk("out",stkinout)
					when "shpact"
						stkinout["qty_stk"] = tbldata["qty_stk"].to_f / bqty * stkinout["qty_stk"]
						stkinout["qty"] = -stkinout["qty_stk"]
						stkinout["starttime"] = command_c[tblnamechop+"_duedate"]
						stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = command_c[tblnamechop+"_shelfnos_id_to"]
						proc_check_inoutlotstk("in",stkinout)
					end	
				end
			end ###出庫処理
		# rescue
		# 	ActiveRecord::Base.connection.rollback_db_transaction()
		# 	command_c[:sio_result_f] = "9"  ##9:error
		# 	command_c[:sio_message_contents] =  "class #{self} : LINE #{__LINE__} $!: #{$!} "[0..3999]    ###evar not defined
		# 	command_c[:sio_errline] =  "class #{self} : LINE #{__LINE__} $@: #{$@} "[0..3999]
		# 	Rails.logger.debug"error class #{self} : #{Time.now}: #{$@} "
		# 	Rails.logger.debug"error class #{self} : $!: #{$!} "
		# 	Rails.logger.debug"  command_c: #{command_c} "
	  	# else
		# 	ActiveRecord::Base.connection.commit_db_transaction()
			if setParams.size > 0   ###画面からの時はperform_later(setParams["seqno"][0])　seqnoは一つのみ。次の処理がないときはreqparams=nil
				if setParams["seqno"].size > 0
					if command_c["mkord_runtime"] 
						CreateOtherTableRecordJob.set(wait: command_c["mkord_runtime"].to_f.hours).perform_later(setParams["seqno"][0])
					else	
						CreateOtherTableRecordJob.perform_later(setParams["seqno"][0])
					end
				end
			end	
	  	# ensure
	  	# end ##begin
	end

	def proc_create_consume reqparams ##
		###自分自身のconschs を作成   
		command_c = {}
		tbldata = reqparams["tbldata"]  ###親
		child = reqparams["child"]  ###対象
		gantt = reqparams["gantt"]
		tblnamechop = yield.chop  
		begin
			###ActiveRecord::Base.connection.begin_db_transaction()
			blk = RorBlkCtl::BlkClass.new("r_#{tblnamechop}s")
			command_c = blk.command_init
			command_c[:sio_code] =  command_c[:sio_viewname] =  "r_#{yield}"
			command_c[:sio_message_contents] = nil
			command_c[:sio_recordcount] = 1
			command_c[:sio_result_f] =   "0"  
			command_c[:sio_classname] = "#{yield}_add_"
			command_c["#{tblnamechop}_id"] = "" 
			if tblnamechop =~ /consch|conord/  ### nditmsから作成
				command_c["#{tblnamechop}_itm_id"] = child["itms_id_nditm"]
				command_c["#{tblnamechop}_processseq"] = child["processseq_nditm"]
			else  ###conactsはconordsから作成
				command_c["#{tblnamechop}_itm_id"] = child["itms_id"]
				command_c["#{tblnamechop}_processseq"] = child["processseq"]
			end
			command_c["#{tblnamechop}_consumtype"] = child["consumtype"]
			command_c["#{tblnamechop}_isudate"] = Time.now 
			command_c["#{tblnamechop}_packno"] =  ""  
			command_c["#{tblnamechop}_lotno"] = "" 
			command_c["#{tblnamechop}_shelfno_id_fm"] =  tbldata["shelfnos_id_fm"]  ###親の作業場所
			command_c["#{tblnamechop}_duedate"] = tbldata["duedate"]
			command_c["#{tblnamechop}_gno"] = tbldata["sno"] 
			command_c["#{tblnamechop}_transport_id"] = 0 
			command_c["#{tblnamechop}_paretblname"] = gantt["tblname"] 
			command_c["#{tblnamechop}_paretblid"] = gantt["tblid"]

			blk.proc_create_tbldata(command_c) ##
			setParams = blk.proc_private_aud_rec(reqparams,command_c)

			stkinout = {}
			case tblnamechop
			when /consch/
				command_c["#{tblnamechop}_qty_sch"] = stkinout["qty_sch"] = child["qty_sch"].to_f
				stkinout["qty"] = stkinout["qty_stk"] = 0
			when /conord/
				command_c["#{tblnamechop}_qty"] =  stkinout["qty"] = child["qty"].to_f
				stkinout["qty_stk"] = stkinout["qty_sch"] = 0
			when /conact/
				command_c["#{tblnamechop}_qty_stk"] =  stkinout["qty_stk"] = child["qty_stk"].to_f 
				stkinout["qty"] = stkinout["qty_sch"] = 0
			end
		

			stkinout["tblname"] = yield
			stkinout["tblid"] = command_c["id"]
			stkinout["trngantts_id"] = gantt["trngantts_id"]
			stkinout["expiredate"] = command_c[tblnamechop+"_expiredate"]
			stkinout["lotno"] =   command_c["#{tblnamechop}_lotno"] 
			stkinout["packno"] =  command_c["#{tblnamechop}_packno"] 
			stkinout["prjnos_id"] = command_c[tblnamechop+"_prjno_id"]
			stkinout["itms_id"] = command_c[tblnamechop+"_itm_id"]
			stkinout["processseq"] = command_c[tblnamechop+"_processseq"]
			stkinout["starttime"] = command_c[tblnamechop+"_duedate"]
			stkinout["consumtype"] = command_c[tblnamechop+"_consumtype"]

			stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = command_c[tblnamechop+"_shelfnos_id_fm"]   ###消費場所
			stkinout = proc_lotstkhists_in_out("out",stkinout)

			###conxxxの明細作成
			strsql = %Q&
					select child_gantt.id child_trngantts_id,
							pare_gantt.qty_sch qty_sch,pare_gantt.qty qty,pare_gantt.qty qty_stk from trngantts child_gantt
						inner join (select * from trngantts gantt
										inner join alloctbls alloc on alloc.trngantts_id = gantt.id
										where alloc.srctblname = '#{gantt["tblname"]}' and srctblid = #{gantt["tblid"]}
										and (qty_sch + qty + qty_stk) > qty_linkto_alloctbl) pare_gantt
							on pare_gantt.orgtblname = child_gantt.orgtblname and pare_gantt.orgtblid = child_gantt.orgtblid
							and pare_gantt.tblname = child_gantt.paretblname and pare_gantt.tblid = child_gantt.paretblid
						where child_gantt.itms_id_trn = #{stkinout["itms_id"]} and child_gantt.processseq_trn = #{stkinout["processseq"]}
			&
			ActiveRecord::Base.connection.select_all(strsql).each do |detail|
				stkinout["trngantts_id"] = detail["child_trngantts_id"]
				bqty = detail["qty_sch"].to_f + detail["qty"].to_f  ###親の必要数
				case tblnamechop
				when /schs/
					stkinout["qty_sch"] = tbldata["qty_sch"].to_f / bqty * stkinout["qty_sch"] 
					stkinout["qty"] = stkinout["qty_stk"] = 0 
				when /ords/
					stkinout["qty"] = tbldata["qty_stk"].to_f / bqty * stkinout["qty"]
					stkinout["qty_sch"] = stkinout["qty"] * -1 
					stkinout["qty_stk"] = 0
				when /acts/
					stkinout["qty_stk"] = tbldata["qty_stk"].to_f / bqty * stkinout["qty_stk"]
					stkinout["qty"] = stkinout["qty_stk"] * -1 
					stkinout["qty_sch"] = 0
				end

				stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = command_c[tblnamechop+"_shelfnos_id_to"]
				proc_check_inoutlotstk("out",stkinout)
			end
		rescue
			ActiveRecord::Base.connection.rollback_db_transaction()
			command_c[:sio_result_f] = "9"  ##9:error
			command_c[:sio_message_contents] =  "class #{self} : LINE #{__LINE__} $!: #{$!} "[0..3999]    ###evar not defined
			command_c[:sio_errline] =  "class #{self} : LINE #{__LINE__} $@: #{$@} "[0..3999]
			Rails.logger.debug"error class #{self} : #{Time.now}: #{$@} "
			Rails.logger.debug"error class #{self} : $!: #{$!} "
			Rails.logger.debug"  command_c: #{command_c} "
	  	else
			ActiveRecord::Base.connection.commit_db_transaction()
			if setParams.size > 0   ###画面からの時はperform_later(setParams["seqno"][0])　seqnoは一つのみ。次の処理がないときはreqparams=nil
				if setParams["seqno"].size > 0
					if command_c["mkord_runtime"] 
						CreateOtherTableRecordJob.set(wait: command_c["mkord_runtime"].to_f.hours).perform_later(setParams["seqno"][0])
					else	
						CreateOtherTableRecordJob.perform_later(setParams["seqno"][0])
					end
				end
			end	
	  	ensure
	  	end ##begin
	end	

	def proc_update_conschs_ords reqparams,last_pare_qty ##
		###自分自身のconschs を作成   
		tbldata = reqparams["tbldata"]  ###親
		child = reqparams["child"]  ###対象
		gantt = reqparams["gantt"]
		tblnamechop = yield.chop  
		###begin
			###ActiveRecord::Base.connection.begin_db_transaction()
			blk = RorBlkCtl::BlkClass.new("r_#{tblnamechop}s")
			command_c = blk.command_init
			command_c[:sio_classname] = "#{yield}_update_"
			command_c["#{tblnamechop}_id"] = child["id"]
			command_c["#{tblnamechop}_itm_id"] = child["itms_id"]
			command_c["#{tblnamechop}_processseq"] = child["processseq"]
			command_c["#{tblnamechop}_consumtype"] = child["consumtype"]
			command_c["#{tblnamechop}_isudate"] = Time.now 
			command_c["#{tblnamechop}_packno"] =  ""  
			command_c["#{tblnamechop}_lotno"] = "" 
			command_c["#{tblnamechop}_shelfno_id_fm"] =  tbldata["shelfnos_id_fm"]  ###親の作業場所
			command_c["#{tblnamechop}_duedate"] = tbldata["duedate"]
			command_c["#{tblnamechop}_gno"] = tbldata["sno"] 
			command_c["#{tblnamechop}_transport_id"] = 0 
			command_c["#{tblnamechop}_paretblname"] = gantt["tblname"] 
			command_c["#{tblnamechop}_paretblid"] = gantt["tblid"]

			stkinout = {}
			case tblnamechop
			when /consch/
				qty_sch = child["qty_sch"].to_f / last_pare_qty * tbldata["qty_sch"].to_f
				command_c["#{tblnamechop}_qty_sch"] = qty_sch
				stkinout["qty_sch"] = child["qty_sch"].to_f - qty_sch
				stkinout["qty"] = stkinout["qty_stk"] = 0
			when /conord/
				qty = child["qty"].to_f / last_pare_qty * tbldata["qty"].to_f
				command_c["#{tblnamechop}_qty"] =  qty
				stkinout["qty"] = child["qty"].to_f - qty
				stkinout["qty_stk"] = stkinout["qty_sch"] = 0
			end

			blk.proc_create_tbldata(command_c) ##
			setParams = blk.proc_private_aud_rec(reqparams,command_c)

			stkinout["tblname"] = yield
			stkinout["tblid"] = command_c["id"]
			stkinout["trngantts_id"] = gantt["trngantts_id"]
			stkinout["expiredate"] = command_c[tblnamechop+"_expiredate"]
			stkinout["lotno"] =   command_c["#{tblnamechop}_lotno"] 
			stkinout["packno"] =  command_c["#{tblnamechop}_packno"] 
			stkinout["prjnos_id"] = command_c[tblnamechop+"_prjno_id"]
			stkinout["itms_id"] = command_c[tblnamechop+"_itm_id"]
			stkinout["processseq"] = command_c[tblnamechop+"_processseq"]
			stkinout["starttime"] = command_c[tblnamechop+"_duedate"]
			stkinout["consumtype"] = command_c[tblnamechop+"_consumtype"]

			stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = command_c[tblnamechop+"_shelfnos_id_fm"]   ###消費場所
			stkinout = proc_lotstkhists_in_out("out",stkinout)

			###conxxxの明細作成
			strsql = %Q&
					select child_gantt.id child_trngantts_id,
							pare_gantt.qty_sch qty_sch,pare_gantt.qty qty,pare_gantt.qty qty_stk from trngantts child_gantt
						inner join (select * from trngantts gantt
										inner join alloctbls alloc on alloc.trngantts_id = gantt.id
										where alloc.srctblname = '#{gantt["tblname"]}' and srctblid = #{gantt["tblid"]}
										and (qty_sch + qty + qty_stk) > qty_linkto_alloctbl) pare_gantt
							on pare_gantt.orgtblname = child_gantt.orgtblname and pare_gantt.orgtblid = child_gantt.orgtblid
							and pare_gantt.tblname = child_gantt.paretblname and pare_gantt.tblid = child_gantt.paretblid
						where child_gantt.itms_id_trn = #{stkinout["itms_id"]} and child_gantt.processseq_trn = #{stkinout["processseq"]}
			&
			ActiveRecord::Base.connection.select_all(strsql).each do |detail|
				stkinout["trngantts_id"] = detail["child_trngantts_id"]
				bqty = detail["qty_sch"].to_f + detail["qty"].to_f  ###親の必要数
				case tblnamechop
				when /schs/
					stkinout["qty_sch"] = tbldata["qty_sch"].to_f / bqty * stkinout["qty_sch"] 
					stkinout["qty"] = stkinout["qty_stk"] = 0 
				when /ords/
					stkinout["qty"] = tbldata["qty_stk"].to_f / bqty * stkinout["qty"]
					stkinout["qty_sch"] = stkinout["qty"] * -1 
					stkinout["qty_stk"] = 0
				end

				stkinout["shelfnos_id"] = command_c[tblnamechop+"_shelfnos_id_to"]
				proc_check_inoutlotstk("out",stkinout)
			end
		###rescue
		###	ActiveRecord::Base.connection.rollback_db_transaction()
		###	command_c[:sio_result_f] = "9"  ##9:error
		###	command_c[:sio_message_contents] =  "class #{self} : LINE #{__LINE__} $!: #{$!} "[0..3999]    ###evar not defined
		###	command_c[:sio_errline] =  "class #{self} : LINE #{__LINE__} $@: #{$@} "[0..3999]
		###	Rails.logger.debug"error class #{self} : #{Time.now}: #{$@} "
		###	Rails.logger.debug"error class #{self} : $!: #{$!} "
		###	Rails.logger.debug"  command_c: #{command_c} "
	  	###else
		###	ActiveRecord::Base.connection.commit_db_transaction()
			if setParams.size > 0   ###画面からの時はperform_later(setParams["seqno"][0])　seqnoは一つのみ。次の処理がないときはreqparams=nil
				if setParams["seqno"].size > 0
					if command_c["mkord_runtime"] 
						CreateOtherTableRecordJob.set(wait: command_c["mkord_runtime"].to_f.hours).perform_later(setParams["seqno"][0])
					else	
						CreateOtherTableRecordJob.perform_later(setParams["seqno"][0])
					end
				end
			end	
	  	###ensure
	  	###end ##begin
	end	

	def proc_mk_conacts reqparams
		tblname = reqparams["gantt"]["tblname"]
		tblid = reqparams["gantt"]["tblid"]
		child = reqparams["child"]

		strsql = %Q&
				select * from conords con
						inner join  linktbls link											
						on con.paretblname = link.srctblname and con.paretblid = link.srctblid
						where link.tblname = '#{tblname}' and link.tblid = #{tblid}
						and (link.qty_sch + link.qty + link.qty_stk) > link.qty_linkto_alloctbl 
				&
		ActiveRecord::Base.connection.select_all(strsql).each do |link|
			ord = ActiveRecord::Base.connection.select_one("select * from #{link["srctblname"]} where id =  #{linlk["srctblid"]}")
			ord["qty"] = link["qty"].to_f * ord["qty"].to_f  / tbldata["qty_stk"].to_f
			reqparams["child"] = ord
			proc_create_consume reqparams do
				"conacts"
			end
		end

		###金型、瓶等の自動返却

		strsql = %Q&
		select inst.* from shpinsts inst ---shpinstsが作成されるとlinktblsの変更はしない。
				inner join (select * from linktbls
									where tblname = '#{tblname}' and tblid = #{tblid}
									and (qty_sch + qty + qty_stk) > qty_linkto_alloctbl) link
				on inst.paretblname = link.srctblname and inst.paretblid = link.srctblid
				on itms itm on inst.itms_id = itm.id and inst.processseq = itm.processseq
				where inst.consumauto = 'A'
				and (itm.consumtype = 'MET' or inst.units_id != inst.units_id_case_shp)
		&
		ActiveRecord::Base.connection.select_all(strsql).each do |inst|
				child = inst.dup
				child["shelfno_id_fm"] = inst["shelfnos_id_to"] ###自身の保管先から出庫
				child["shelfno_id_to"] = inst["shelfnos_id_fm"]  ###親の作業場所へ納品
				if inst["units_id"] != inst["units_id_case_shp"]  ###瓶毎出庫
					 child["qty_stk"] = child["qty_shp"] = inst["qty_shp"].to_f - inst["qty_stk"].to_f
				end
				reqparams["child"] = child
				proc_create_consume reqparams do
					"shpinsts"
				end
				proc_create_consume reqparams do
					"shpacts"
				end
		end
	end
	
	###shpschs用
	def proc_update_shpschs_ords reqparams,last_pare_qty  
		###自分自身のshpschs を作成   shpinstsはmkshpinstsで対応親から子のshpinsts作成
		command_c = {}
		tbldata = reqparams["tbldata"]  ###親
		child = reqparams["child"]  ###出庫対象
		gantt = reqparams["gantt"]

		tblnamechop = yield.chop
		stkinout = {}

		begin
			###ActiveRecord::Base.connection.begin_db_transaction()
			blk = RorBlkCtl::BlkClass.new("r_#{tblnamechop}s")
			command_c = blk.command_init
			command_c[:sio_classname] = "#{yield}_update_"
			command_c["#{tblnamechop}_id"] = child["id"] 
			command_c["#{tblnamechop}_isudate"] = Time.now
			###自身の保管先から出庫
			stkinout["shelfnos_id_real"] = stkinout["shelfnos_id"] = command_c["#{tblnamechop}_shelfno_id_fm"] = child["shelfnos_id_fm"] 
			command_c["#{tblnamechop}_shelfno_id_to"] = tbldata["shelfnos_id_fm"]  ###親の作業場所へ納品
			command_c["#{tblnamechop}_duedate"] = tbldata["starttime"] - 1   ###稼働日考慮
			stkinout["starttime"] = command_c["#{tblnamechop}_depdate"] = (tbldata["starttime"] - 2).strftime("%Y-%m-%d %H:%M:%S")
			command_c["#{tblnamechop}_gno"] = tbldata["sno"] 
			command_c["#{tblnamechop}_transport_id"] = 0 
			command_c["#{tblnamechop}_paretblname"] = gantt["tblname"] 
			command_c["#{tblnamechop}_paretblid"] = gantt["tblid"]
			command_c["#{tblnamechop}_consumauto"] = child["consumauto"] 
			stkinout["expiredate"] = command_c[tblnamechop+"_expiredate"] = "2099/12/31"
			
			stkinout["itms_id"] = command_c["#{tblnamechop}_itm_id"] = child["itms_id"]   ### from shpords
			stkinout["processseq"] = command_c["#{tblnamechop}_processseq"] = child["processseq"]
			stkinout["packno"] =  command_c["#{tblnamechop}_packno"] = child["packno"]   
			stkinout["lotno"] = command_c["#{tblnamechop}_lotno"] = child["lotno"]
			stkinout["prjnos_id"] = command_c[tblnamechop+"_prjno_id"] = tbldata["prjnos_id"]
			case tblnamechop
			when /shpsch/
				qty_sch = child["qty_sch"].to_f / last_pare_qty * tbldata["qty_sch"].to_f 
				command_c["#{tblnamechop}_qty_sch"] = qty_sch
				stkinout["qty"] = stkinout["qty_stk"] = 0
			when /shpord/
				qty = child["qty"].to_f / last_pare_qty * tbldata["qty"].to_f
				command_c["#{tblnamechop}_qty"] =  qty
				stkinout["qty_stk"] = stkinout["qty_sch"] = 0
			end
			
			if gantt["tblname"] =~ /^pur/   ###tblname= 'feepayment'--->有償支給
				strsql =%Q&select * from pricemsts where tblname= 'feepayment' and expiredate >= current_date
									and itms_id = #{command_c["#{tblnamechop}_itm_id"]} 
									and processseq = #{command_c["#{tblnamechop}_processseq"]}
									and (locas_id = (select locas_id_shelfno from shelfnos  where id = #{tbldata["shelfnos_id_fm"]}) or 
										locas_id = (select id from locas where code = 'dummy' ))
									order by expiredate limit 1
				& 
				rec = ActiveRecord::Base.connection.select_one(strsql)
				if rec
					###日付、数量による再設定
				else
					command_c["#{tblnamechop}_price"] = 0 	
					command_c["#{tblnamechop}_amt_sch"] = 0
					command_c["#{tblnamechop}_tax"] = 0 	
				end
			else
				command_c["#{tblnamechop}_price"] = 0 	 
				command_c["#{tblnamechop}_amt_sch"] = 0
				command_c["#{tblnamechop}_tax"] = 0 		
			end		

			blk.proc_create_tbldata(command_c) ##
			setParams = blk.proc_private_aud_rec(reqparams,command_c)

			stkinout["tblname"] = yield
			stkinout["tblid"] = command_c["id"]
			stkinout["trngantts_id"] = gantt["trngantts_id"]
			case tblnamechop
			when "shpsch"
				stkinout["qty_sch"] = qty_sch - child["qty_sch"].to_f
				stkinout = proc_lotstkhists_in_out("out",stkinout)
				stkinout["starttime"] = command_c[tblnamechop+"_duedate"]
				stkinout["shelfnos_id"] = command_c[tblnamechop+"_shelfnos_id_to"]   ###入り
				stkinout = proc_lotstkhists_in_out("in",stkinout)
			when "shpord"
				stkinout["qty"] = qty_sch - child["qty"].to_f
				stkinout["qty_sch"] = -stkinout["qty"]  
				stkinout = proc_lotstkhists_in_out("out",stkinout)
				stkinout["starttime"] = command_c[tblnamechop+"_duedate"]
				stkinout["shelfnos_id"] = command_c[tblnamechop+"_shelfnos_id_to"]
				stkinout = proc_lotstkhists_in_out("in",stkinout)
			end	

			###shpxxxの在庫明細作成
			strsql = %Q&
					select child_gantt.id child_trngantts_id,
							pare_gantt.qty_sch qty_sch,pare_gantt.qty qty,pare_gantt.qty qty_stk from trngantts child_gantt
						inner join (select * from trngantts gantt
										inner join alloctbls alloc on alloc.trngantts_id = gantt.id
										where alloc.srctblname = '#{gantt["tblname"]}' and srctblid = #{gantt["tblid"]}
										and (qty_sch + qty + qty_stk) > qty_linkto_alloctbl) pare_gantt
							on pare_gantt.orgtblname = child_gantt.orgtblname and pare_gantt.orgtblid = child_gantt.orgtblid
							and pare_gantt.tblname = child_gantt.paretblname and pare_gantt.tblid = child_gantt.paretblid
						where child_gantt.itms_id_trn = #{stkinout["itms_id"]} and child_gantt.processseq_trn = #{stkinout["processseq"]}
			&
			ActiveRecord::Base.connection.select_all(strsql).each do |detail|
				stkinout["trngantts_id"] = detail["child_trngantts_id"]
				bqty = detail["qty_sch"].to_f + detail["qty"].to_f  ###親の必要数
				case tblnamechop
				when "shpsch"
					stkinout["qty_sch"] = tbldata["qty_sch"].to_f / bqty * stkinout["qty_sch"] 
					stkinout["shelfnos_id"] = command_c[tblnamechop+"_shelfnos_id_fm"]
					proc_check_inoutlotstk("out",stkinout)
					stkinout["starttime"] = command_c[tblnamechop+"_duedate"]
					stkinout["shelfnos_id"] = command_c[tblnamechop+"_shelfnos_id_to"]
					proc_check_inoutlotstk("in",stkinout)
				when "shpord"
					stkinout["qty"] = tbldata["qt"].to_f / bqty * stkinout["qty"]
					stkinout["qty_sch"] = -stkinout["qty"]
					stkinout["shelfnos_id"] = command_c[tblnamechop+"_shelfnos_id_fm"]
					proc_check_inoutlotstk("out",stkinout)
					stkinout["starttime"] = command_c[tblnamechop+"_duedate"]
					stkinout["shelfnos_id"] = command_c[tblnamechop+"_shelfnos_id_to"]
					proc_check_inoutlotstk("in",stkinout)
				end	
			end
		rescue
			ActiveRecord::Base.connection.rollback_db_transaction()
			command_c[:sio_result_f] = "9"  ##9:error
			command_c[:sio_message_contents] =  "class #{self} : LINE #{__LINE__} $!: #{$!} "[0..3999]    ###evar not defined
			command_c[:sio_errline] =  "class #{self} : LINE #{__LINE__} $@: #{$@} "[0..3999]
			Rails.logger.debug"error class #{self} : #{Time.now}: #{$@} "
			Rails.logger.debug"error class #{self} : $!: #{$!} "
			Rails.logger.debug"  command_c: #{command_c} "
	  	else
			ActiveRecord::Base.connection.commit_db_transaction()
			if setParams.size > 0   ###画面からの時はperform_later(setParams["seqno"][0])　seqnoは一つのみ。次の処理がないときはreqparams=nil
				if setParams["seqno"].size > 0
					if command_c["mkord_runtime"] 
						CreateOtherTableRecordJob.set(wait: command_c["mkord_runtime"].to_f.hours).perform_later(setParams["seqno"][0])
					else	
						CreateOtherTableRecordJob.perform_later(setParams["seqno"][0])
					end
				end
			end	
	  	ensure
	  	end ##begin
	end		

	###
	def proc_lotstkhists_in_out(kubun,stkinout)   ###,old_alloc,srctblname
		case kubun
		when "out" 
			inout = -1
		else  ### in update
			inout = 1
		end	
		new_stk = stkinout.dup
		ActiveRecord::Base.connection.execute("lock table lotstkhists in  SHARE ROW EXCLUSIVE mode")
		###ActiveRecord::Base.connection.select_one("select * from itms where id = #{stkinout["itms_id"]} for update")
		strsql = %Q% select *
								from lotstkhists
								where   itms_id = #{stkinout["itms_id"]} and  
										shelfnos_id = #{stkinout["shelfnos_id"]} and 
										shelfnos_id_real = #{stkinout["shelfnos_id_real"]} and
										processseq = #{stkinout["processseq"]} and
										prjnos_id = #{stkinout["prjnos_id"]} and
										starttime = to_date('#{stkinout["starttime"]}','yyyy-mm-dd hh24:mi:ss') and 
										packno = '#{stkinout["packno"]}' and  lotno = '#{stkinout["lotno"]}'
										---　一件のみ
				%
		lotstkhists =  ActiveRecord::Base.connection.select_one(strsql)
		if lotstkhists.nil?
			last_strsql = %Q% select *
									from lotstkhists
									where   itms_id = #{stkinout["itms_id"]} and  											  
										shelfnos_id = #{stkinout["shelfnos_id"]} and 
										shelfnos_id_real = #{stkinout["shelfnos_id_real"]} and
											processseq = #{stkinout["processseq"]} and
											prjnos_id = #{stkinout["prjnos_id"]} and
											starttime < to_date('#{stkinout["starttime"]}','yyyy-mm-dd hh24:mi:ss') and 
											packno = '#{stkinout["packno"]}' and  lotno = '#{stkinout["lotno"]}'
									order by starttime desc limit 1
					%
			last_lot =  ActiveRecord::Base.connection.select_one(last_strsql)
			if last_lot.nil?
				last_lot = {"qty_sch" =>0,"qty" => 0,"qty_stk" => 0,"packno" => "","lotno" => ""}
			end	
			new_stk["qty_sch"] = stkinout["qty_sch"].to_f * inout + last_lot["qty_sch"].to_f 
			new_stk["qty"]     = stkinout["qty"].to_f * inout  + last_lot["qty"].to_f
			new_stk["qty_stk"] = stkinout["qty_stk"].to_f * inout +  last_lot["qty_stk"].to_f
			new_stk["lotstkhists_id"] = stkinout["lotstkhists_id"] = stkinout["srctblid"] =ArelCtl.proc_get_nextval("lotstkhists_seq") 
			ActiveRecord::Base.connection.insert(insert_lotstkhists_sql(new_stk)) 
			###
			src = {"tblname" => "","tblid" => -1,"trngantts_id" => stkinout["trngantts_id"]}
			base = {"tblname" =>stkinout["tblname"],"tblid" =>stkinout["tblid"],"qty_src" => 0,"amt_src" => 0}
			ArelCtl.proc_insert_linktbls(src,base)
		else
			stkinout["lotstkhists_id"] = stkinout["srctblid"] = lotstkhists["id"]
			###
			new_stk["qty_sch"] = stkinout["qty_sch"].to_f * inout  + lotstkhists["qty_sch"].to_f
			new_stk["qty"]     = stkinout["qty"].to_f * inout  + lotstkhists["qty"].to_f
			new_stk["qty_stk"] = stkinout["qty_stk"].to_f * inout  +  lotstkhists["qty_stk"].to_f
			strsql = %Q& update lotstkhists set  
									updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
									persons_id_upd = #{$person_code_chrg||=0},
									qty_stk = #{new_stk["qty_stk"]},
									qty = #{new_stk["qty"]} ,
									qty_sch = #{new_stk["qty_sch"].to_f}  
									where id = #{stkinout["lotstkhists_id"]}					
						&
			ActiveRecord::Base.connection.update(strsql) 

		end
		stkinout["wh"] = "lotstkhists" 
		strsql = %Q& select *
								from lotstkhists
								where   itms_id = #{stkinout["itms_id"]} and  
										shelfnos_id = #{stkinout["shelfnos_id"]} and 
										shelfnos_id_real = #{stkinout["shelfnos_id_real"]} and
										processseq = #{stkinout["processseq"]} and
										prjnos_id = #{stkinout["prjnos_id"]} and
										starttime > to_date('#{stkinout["starttime"]}','yyyy-mm-dd hh24:mi:ss') and 
										packno = '#{stkinout["packno"]}' and  lotno = '#{stkinout["lotno"]}'
										order by starttime 
				&
		ActiveRecord::Base.connection.select_all(strsql).each do |futrec|
			strsql = %Q& update lotstkhists set  
									updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
									persons_id_upd = #{$person_code_chrg||=0},
									qty_stk = #{stkinout["qty_stk"].to_f * inout + futrec["qty_stk"].to_f},
									qty = #{stkinout["qty"].to_f * inout + futrec["qty"].to_f},
									qty_sch = #{stkinout["qty_sch"].to_f  * inout + futrec["qty_sch"].to_f} 
									where id = #{futrec["id"]}					
						&
			ActiveRecord::Base.connection.update(strsql) 
		end
		return stkinout
	end

	def proc_check_inoutlotstk(inout,stkinout)
		if inout == "out"
			plusminus = -1
		else
			plusminus = 1
		end
		strsql = %Q&
			select * from inoutlotstks where trngantts_id = #{stkinout["trngantts_id"]}
										and srctblid = #{stkinout["srctblid"]} and srctblname = '#{stkinout["wh"]}'
										and tblid = #{stkinout["tblid"]} and tblname = '#{stkinout["tblname"]}'
										for update
		&
		inoutlotstk = ActiveRecord::Base.connection.select_one(strsql)
		if inoutlotstk
			update_sql = %Q&
				update inoutlotstks set qty_sch = qty_sch + #{stkinout["qty_sch"].to_f * plusminus},
										qty = qty + #{stkinout["qty"].to_f * plusminus},
										qty_stk = qty_stk + #{stkinout["qty_stk"].to_f * plusminus},
										remark = '#{stkinout["remark"]}'
						where id = #{inoutlotstk["id"]}				 
			& 
			ActiveRecord::Base.connection.update(update_sql)
		else
			ActiveRecord::Base.connection.insert(proc_insert_inoutlotstk_sql(plusminus,stkinout))
		end	
	end
	
	def proc_sch_inoutlotstk(kubun,sch)
		if kubun == "out"
			plusminus = -1
		else
			plusminus = 1
		end
		strsql = %Q&
			select id from inoutlotstks where trngantts_id = #{sch["trngantts_id"]}
									and srctblid = #{sch["lotstkhists_id"]} and srctblname = '#{sch["wh"]}'
									and tblid = #{sch["tblid"]} and tblname = '#{sch["tblname"]}'
									for update
		&
		inoutlotstk_id = ActiveRecord::Base.connection.select_value(strsql)
		if inoutlotstk_id
			update_sql = %Q&
				update inoutlotstks set qty_sch = qty_sch + #{sch["qty_sch"].to_f *plusminus},
										remark = '#{sch["remark"]}'
						where id = #{inoutlotstk_id}				 
			& 
			ActiveRecord::Base.connection.update(update_sql)
		else
			sch["qty"] = sch["qty_stk"] = 0
			ActiveRecord::Base.connection.insert(proc_insert_inoutlotstk_sql(plusminus,stkinout))
		end	
	end

	def insert_lotstkhists_sql stkinout
		 %Q&insert into lotstkhists(id,
								starttime,
								itms_id,processseq,
								shelfnos_id,shelfnos_id_real,stktaking_proc,
								qty_sch,qty_stk,qty,
								lotno,packno,
								prjnos_id,
								created_at,
								updated_at,
								update_ip,persons_id_upd,expiredate,remark)
						values(#{stkinout["lotstkhists_id"]},
								'#{stkinout["starttime"]}',
								#{stkinout["itms_id"]} ,#{stkinout["processseq"]},
								#{stkinout["shelfnos_id"]},#{stkinout["shelfnos_id_real"]},'#{stkinout["stktaking_proc"]}',
								#{stkinout["qty_sch"]} ,#{stkinout["qty_stk"]},#{stkinout["qty"]},
								'#{stkinout["lotno"]}' ,'#{stkinout["packno"]}',
								#{stkinout["prjnos_id"]},
								to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
								to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
								' ',#{$person_code_chrg||=0},'2099/12/31','#{stkinout["remark"]}')
		&
	 end

	def proc_insert_inoutlotstk_sql(plusminus,stkinout)
		  %Q&insert into inoutlotstks(id,
								 trngantts_id,
								 tblname,tblid,
								 srctblname,srctblid,
								 qty_sch,   
								 qty_stk,
								 qty,
								 created_at,
								 updated_at,
								 update_ip,persons_id_upd,expiredate,remark)
						 values(#{ArelCtl.proc_get_nextval("inoutlotstks_seq")},
								 #{stkinout["trngantts_id"]},
								 '#{stkinout["tblname"]}',#{stkinout["tblid"]},
								 '#{stkinout["srctblname"]}',#{stkinout["srctblid"]},
								 #{stkinout["qty_sch"].to_f * plusminus} ,
								 #{stkinout["qty_stk"].to_f * plusminus},
								 #{stkinout["qty"].to_f * plusminus},
								 to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
								 to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
								 ' ',#{$person_code_chrg||=0},'2099/12/31','#{stkinout["remark"]}')
		 &
	end
	
	def proc_mk_custwhs_rec kubun,stkinout  ###lotstkhistsは棚のみ
		if kubun == "in"
			inout = 1
		else
			inout = -1
		end
		strsql = %Q&
				select * from custwhs where itms_id = #{stkinout["itms_id"]} and processseq = #{stkinout["processseq"]}
					and custrcvplcs_id = #{stkinout["custrcvplcs_id"]} and lotno = '#{stkinout["lotno"]}'
					and duedate = '#{stkinout["duedate"]}'
		&
		rec = ActiveRecord::Base.connection.select_one(strsql)
		if rec.nil?
			custwhs_id = ArelCtl.proc_get_nextval("custwhs_seq")
			strsql = %Q&insert into custwhs(id,custrcvplcs_id,
								duedate,
								qty_sch,qty,qty_stk,
								lotno,itms_id,processseq,
								created_at,
								updated_at,
								update_ip,persons_id_upd,expiredate,remark)
						values(#{custwhs_id},#{stkinout["custrcvplcs_id"]},
								'#{stkinout["duedate"]}',
								#{stkinout["qty_sch"]},#{stkinout["qty"]},#{stkinout["qty_stk"]},
								'#{stkinout["lotno"]}',#{stkinout["itms_id"]},#{stkinout["processseq"]},
								to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
								to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
								' ','#{$person_code_chrg||=0}','2099/12/31','#{stkinout["remark"]}')
				&
			ActiveRecord::Base.connection.insert(strsql)
		else
			custwhs_id = rec["id"]
			update_sql = %Q% update custwhs set 
									qty_sch = qty_sch + #{stkinout["qty_sch"]},
									qty = qty + #{stkinout["qty"]},
									qty_stk = qty_stk + #{stkinout["qty_stk"]},
									remark = '#{stkinout["remark"]}'
									where id = #{custwhs_id} 
				%
			ActiveRecord::Base.connection.update(update_sql) 
		end
		stkinout["srctblid"] =  custwhs_id
		return stkinout
	end

	def proc_mk_supplierwhs_rec kubun,stkinout  ###lotstkhistsは棚のみ

		if kubun == "in"
			inout = 1
		else
			inout = -1
		end
		depdate = "#{stkinout["depdate"].year}/#{stkinout["depdate"].month}/#{stkinout["depdate"].day}"
		strsql = %Q&
				select * from supplierwhs where itms_id = #{stkinout["itms_id"]} and processseq = #{stkinout["processseq"]}
										and suppliers_id = #{stkinout["suppliers_id"]} and lotno = '#{stkinout["lotno"]}'
										and depdate = to_date(#{depdate},'yyyy/mm/dd')
		&
		rec = ActiveRecord::Base.connection.select_one(strsql)
		if rec.nil?
			supplierwhs_id = ArelCtl.proc_get_nextval("supplierwhs_seq")
			strsql = %Q&insert into supplierwhs(id,suppliers_id,
								depdate,
								qty_sch,qty,qty_stk,
								lotno,itms_id,processseq,
								created_at,
								updated_at,
								update_ip,persons_id_upd,expiredate,remark)
						values(#{supplierwhs_id},#{stkinout["suppliers_id"]},
								'#{depdate}',
								#{stkinout["qty_sch"]},#{stkinout["qty"]},#{stkinout["qty_stk"]},
								'#{stkinout["lotno"]}',#{stkinout["itms_id"]},#{stkinout["processseq"]},
								to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
								to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
								' ','#{$person_code_chrg||=0}','2099/12/31','')
				&
			ActiveRecord::Base.connection.insert(strsql)
		else
			update_sql = %Q% update supplierwhs set 
									qty_sch = qty_sch + #{stkinout["qty_sch"]},
									qty = qty + #{stkinout["qty"]},
									qty_stk = qty_stk + #{stkinout["qty_stk"]}
									where id = #{rec["id"]} 
				%
			ActiveRecord::Base.connection.update(update_sql) 
			supplierwhs_id = rec["id"]
		end
		stkinout["srctblname"] = "supplierwhs"
		stkinout["srctblid"] = supplierwhs_id
		return stkinout
	end

	def proc_re_create_shpords reqparams,srctblname,qty,rec
		strsql = %Q&
					select 1 from shpinsts where paretblname = '#{srctblname}' and paretblid = #{rec["id"]}
											and qty > 0
						union
					select 1 from shpacts where paretblname = '#{srctblname}' and paretblid = #{rec["id"]}
											and qty_stk > 0 
			&
		if ActiveRecord::Base.connection.select_value(strsql)
				###既に出庫指示済の時は何もしない
		else
			if scgno =~ /sno|cno/  ###出庫オーダの作り直し
				### ords　を分割したinstsのみ対象　　　既に出庫指示されているときは対象外。
				def_qty = rec["qty"].to_f - qty
				strsql = %Q&
						select * from shpords where paretblname = '#{srctblname}' and paretblid = #{rec["id"]}
								and qty > 0
					&
				ActiveRecord::Base.connection.select_all(strsql).each do |prev_shpord|
					new_shp_qty = qty / rec["qty"].to_f * prev_shpord["qty"].to_f
					if rec["qty_case"].to_f != 0
						new_shp_qty = (new_shp_qty / prev_shpord["qty_case"].to_f).ceil * prev_shpord["qty_case"].to_f
					end
					prev_shpord["qty"] = new_shp_qty
					prev_shpord["amt"] =prev_shpord["qty"] * prev_shpord["price"].to_f
					proc_create_shp reqparams,prev_shpord do
						"shpords"
					end
					new_shp_qty =  (rec["qty"].to_f - qty) * prev_shpord["qty"].to_f
					if new_shp_qty > 0
						if rec["qty_case"].to_f != 0
							new_shp_qty = (new_shp_qty / rec["qty_case"].to_f).ceil * rec["qty_case"].to_f
						end
					else
						new_shp_qty = 0
					end
					prev_shpord["qty"] = new_shp_qty
					prev_shpord["amt"] = prev_shpord["qty"] * prev_shpord["price"].to_f
					prev_shpord["tblname"] = "shpords"
					prev_shpord["paretblname"] = srctbldata["srctblname"]
					prev_shpord["paretblid"] = srctbldata["srctblid"]
					proc_update_shpschs_ords reqparams,last_pare_qty
				end
			else   
				if scgno =~ /gno/  ###まとめの出庫オーダの作り直し
					new_shp_qty = 0
					save_itms_id = save_processseq = ""
					prev = {}
					strsql = %Q&
						select qty,processsseq,crrs_id_shpord,chrgs_id,packno,qty_case,lotno,prjnos_id,price,
								depdate,trnsports_id,locas_id_to,shelfnos_id_fm,itms_id,current_date isudate
										 from shpords shp
										inner join #{srctblname} ord on ord.id = shp.paretblid
										where shp.paretblname = '#{srctblname}'
										and ord.gno = '#{gno_val}'
										order by shp.itms_id,shp.processseq
					&
					ActiveRecord::Base.connection.select_all(strsql).each do |prev_shpord|
						prev_shpord["qty"] = 0
						prev_shpord["amt"] = 0
						prev_shpord["tblname"] = "shpords"
						proc_update_shpschs_ords reqparams,last_pare_qty
						prev = prev_shpord.dup
						if save_itms_id != ""
							if (save_itms_id != prev_shpord["itms_id"] or save_processseq != prev_shpord["processseq"])
								prev_shpord["qty"] = new_shp_qty
								prev_shpord["amt"] = prev_shpord["qty"] * prev_shpord["price"].to_f
								prev_shpord["itms_id"] = save_itms_id
								prev_shpord["processseq"] = save_processseq
								proc_create_shp reqparams,prev_shpord do
									"shpords"
								end
								new_shp_qty = prev["qty"].to_f
								save_itms_id = prev["itms_id"]
								save_processseq = prev["processseq"]
							else
								new_shp_qty += prev_shpord["qty"].to_f
							end
						else
							new_shp_qty = prev["qty"].to_f
							save_itms_id = prev["itms_id"]
							save_processseq = prev["processseq"]
						end
					end
					prev_shpord["qty"] = new_shp_qty
					prev_shpord["amt"] = prev_shpord["qty"] * prev_shpord["price"].to_f
					proc_create_shp reqparams,prev_shpord do
						"shpords"
					end
				end
			end
		end
	end	

	def proc_re_create_conords reqparams,srctblname,qty,rec
		if scgno =~ /sno|cno/  ###出庫オーダの作り直し
			### ords　を分割したinstsのみ対象　　　既に出庫指示されているときは対象外。
			def_qty = rec["qty"].to_f - qty
			strsql = %Q&
						select * from conords where paretblname = '#{srctblname}' and paretblid = #{rec["id"]}
								and qty > 0
					&
			ActiveRecord::Base.connection.select_all(strsql).each do |prev_conord|
				new_con_qty = qty / rec["qty"].to_f * prev_conord["qty"].to_f
				if rec["qty_case"].to_f != 0
					new_con_qty = (new_con_qty / prev_conord["qty_case"].to_f).ceil * prev_conord["qty_case"].to_f
					prev_conord["qty"] = new_con_qty
					prev_conord["amt"] =prev_conord["qty"] * prev_conord["price"].to_f
					proc_create_consume reqparams,prev_conord do
						"conords"
					end
					new_con_qty =  (rec["qty"].to_f - qty) * prev_conord["qty"].to_f
					if new_con_qty > 0
						if rec["qty_case"].to_f != 0
							new_con_qty = (new_con_qty / rec["qty_case"].to_f).ceil * rec["qty_case"].to_f
						end
					else
						new_con_qty = 0
					end
					prev_conord["qty"] = new_con_qty
					prev_conord["amt"] = prev_conord["qty"] * prev_conord["price"].to_f
					prev_conord["tblname"] = "conords"
					prev_conord["paretblname"] = srctbldata["srctblname"]
					prev_conord["paretblid"] = srctbldata["srctblid"]
					proc_update_conschs_ords reqparams,last_pare_qty
				end
			end	
		else   
			if scgno =~ /gno/  ###まとめの出庫オーダの作り直し
				new_con_qty = 0
				save_itms_id = save_processseq = ""
				prev = {}
				strsql = %Q&
						select qty,processsseq,crrs_id_conord,chrgs_id,packno,qty_case,lotno,prjnos_id,price,
								depdate,trnsports_id,locas_id_to,shelfnos_id_fm,itms_id,current_date isudate
										 from conords con
										inner join #{srctblname} ord on ord.id = con.paretblid
										where con.paretblname = '#{srctblname}'
										and ord.gno = '#{gno_val}'
										order by con.itms_id,con.processseq
					&
				ActiveRecord::Base.connection.select_all(strsql).each do |prev_conord|
					prev_conord["qty"] = 0
					prev_conord["amt"] = 0
					prev_conord["tblname"] = "conords"
					proc_update_conschs_ords reqparams,last_pare_qty
					prev = prev_conord.dup
					if save_itms_id != ""
						if (save_itms_id != prev_conord["itms_id"] or save_processseq != prev_conord["processseq"])
							prev_conord["qty"] = new_con_qty
							prev_conord["amt"] = prev_conord["qty"] * prev_conord["price"].to_f
							prev_conord["itms_id"] = save_itms_id
							prev_conord["processseq"] = save_processseq
							proc_create_consume reqparams,prev_conord do
									"conords"
							end
							new_con_qty = prev["qty"].to_f
							save_itms_id = prev["itms_id"]
							save_processseq = prev["processseq"]
						else
							new_con_qty += prev_conord["qty"].to_f
						end
					else
						new_con_qty = prev["qty"].to_f
						save_itms_id = prev["itms_id"]
						save_processseq = prev["processseq"]
					end
				end
				prev_conord["qty"] = new_con_qty
				prev_conord["amt"] = prev_conord["qty"] * prev_conord["price"].to_f
				proc_create_con reqparams,prev_conord do
						"conords"
				end
			end
		end
	end	
end    
