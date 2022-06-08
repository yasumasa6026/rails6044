
# -*- coding: utf-8 -*-
# RorBlkCtl
# 2099/12/31を修正する時は　2100/01/01の修正も
module RorBlkCtl
	extend self
	class BlkClass
		def initialize(screenCode)
			@screenCode = screenCode
			@tblname = screenCode.split("_")[1]
		    @sio_user_id = ActiveRecord::Base.connection.select_value("select id from persons where email = '#{$email}'")
		    @command_init = {}
		    strsql = "select pobject_code_view from r_screens where pobject_code_scr = '#{@screenCode}' and screen_expiredate > current_date"
		    @command_init[:sio_viewname] =  ActiveRecord::Base.connection.select_value(strsql)
		    @command_init[:sio_code] =  @screenCode
		    @command_init[:sio_message_contents] = nil
		    @command_init[:sio_recordcount] = 1
		    @command_init[:sio_result_f] =   "0"  
            command_init[:sio_recordcount] = 1
            @tbldata = {}   ###テーブル更新
		end
		def screenCode
			@screenCode
		end
		def proc_grp_code
			@proc_grp_code
		end
        def command_init
            @command_init
        end

		def proc_add_update_table(params,command_c)  
			begin
				ActiveRecord::Base.connection.begin_db_transaction()
				setParams = proc_private_aud_rec(params,command_c) 
			rescue
        		ActiveRecord::Base.connection.rollback_db_transaction()
            	command_c[:sio_result_f] = "9"  ##9:error
            	command_c[:sio_message_contents] =  "class #{self} : LINE #{__LINE__} $!: #{$!} "[0..3999]    ###evar not defined
            	command_c[:sio_errline] =  "class #{self} : LINE #{__LINE__} $@: #{$@} "[0..3999]
            	Rails.logger.debug"error class #{self} : #{Time.now}: #{$@} "
          		Rails.logger.debug"error class #{self} : $!: #{$!} "
          		Rails.logger.debug"  command_c: #{command_c} "
				setParams = params.dup
      		else
				ActiveRecord::Base.connection.commit_db_transaction()
				if setParams["seqno"].size > 0
					if command_c["mkord_runtime"] 
						CreateOtherTableRecordJob.set(wait: command_c["mkord_runtime"].to_f.hours).perform_later(setParams["seqno"][0])
					else	
						CreateOtherTableRecordJob.perform_later(setParams["seqno"][0])
					end
				end
      		ensure
	  		end ##begin
        	return setParams,command_c
		end

		def proc_private_aud_rec(params,command_c)
			tmp_key = {}
        	setParams = params.dup
			case command_c[:sio_classname]
			when /_add_|_insert_/
				tbl_add_arel(@tblname,@tbldata) ###sioXXXX,tbldata
			when /_edit_|_update_/
				tbl_edit_arel(" id = #{@tbldata[:id]}")
			when  /_delete_|_purge_/
				if @tblname =~ /schs$|ords$|insts$|dlvs$|acts$|rets$/  ##削除なし
					@tbldata[:qty_sch] = 0 if @tbldata[:qty_sch]
					@tbldata[:qty] = 0 if @tbldata[:qty]
					@tbldata[:qty_stk] = 0 if @tbldata[:qty_stk]
					@tbldata[:amt] = 0 if @tbldata[:amt]
					@tbldata[:amt_sch] = 0 if @tbldata[:amt_sch]
					@tbldata[:cash] = 0 if @tbldata[:cash]
					@tbldata[:tax] = 0 if @tbldata[:tax]      ##変更分のみ更新
					tbl_edit_arel(" id = #{@tbldata[:id]}")
				else
					tbl_delete_arel(" id = #{@tbldata[:id]}")
				end
			else
				Rails.logger.debug"error class #{self} : #{Time.now}: sio_classname missing \n"
				Rails.logger.debug"error class #{self} : @tbldata: #{@tbldata} \n"
				Rails.logger.debug"error class #{self} : command_c: #{command_c} "
				ActiveRecord::Base.connection.rollback_db_transaction()
				raise
			end	
        	###
        	insert_sio_r(command_c)   ###sioxxxxの追加
        	###
        	command_c.select do |key,val|
				if key.to_s =~ /_autocreate/
					if (JSON.parse(val) rescue nil)
						setParams["segment"] = "createtable"
						setParams["gantt"] = gantt
						setParams["remark"] = " RorBlkCtl.lib line:#{__LINE__}"
						processreqs_id ,setParams = ArelCtl.proc_processreqs_add(setParams)
					end
				end
			end

			setParams["seqno"] ||= []
			setParams["child"] ||= {}
			if @tbldata[:opeitms_id]
				opeitm = ActiveRecord::Base.connection.select_one("select * from opeitms where id = #{@tbldata[:opeitms_id]}")
			else
				opeitm = {}
			end
			setParams["opeitm"] = opeitm.dup
        	case @tblname
        	when /^prd|^pur|^shp|^mk/
				gantt = setGantt(setParams)
            ###次の処理
        	when /^custs$|^custrcvplcs$|^custwh$|^bills$|^paymnets$/
            	return setParams 
        	when /^cust/
            ###次の処理
				gantt = setGantt(setParams)
			when /^bill|^pay/
				account = setAccount(setParams)
        	else 
            	return setParams 
        	end
			setParams["classname"] = command_c[:sio_classname]
			case @tblname
			when /custschs/
				gantt["qty_sch"] = @tbldata[:qty_sch]
				gantt["qty_handover"] = @tbldata[:qty_sch] ###下位部品所要量計算用
				gantt["qty_free"] = gantt["qty_alloc"] = 0
			when /^prdschs|^purschs/
				gantt["qty_sch"] = @tbldata[:qty_sch]
				gantt["qty_handover"] = @tbldata[:qty_sch]  if gantt["key"] == "00000"###下位部品所要量計算用
				gantt["qty_free"] = gantt["qty_alloc"] = 0
			when /schs/
				gantt["qty_sch"] = @tbldata[:qty_sch]
				gantt["qty_free"] = 0
			when /^custords/
				gantt["qty"] =  gantt["qty_handover"] = gantt["qty_require"] = @tbldata[:qty]
				###下位部品所要量計算用
				###自身のschsからordsへの変換用
				gantt["qty_free"] = 0
			when /^prdords|^purords/
				gantt["qty"] =  gantt["qty_free"] =  @tbldata[:qty]
				gantt["qty_require"] = 0
				gantt["qty_handover"] = @tbldata[:qty] ###下位部品所要量計算用
				###gantt["qty_require"] = @tbldata[:qty].to_f  ###自身のschsからordsへの変換用
				gantt["qty_alloc"] = 0 
			when /insts|reply/
				gantt["qty"] =  @tbldata[:qty]
				gantt["qty_free"] = 0
			when /acts|rets|dlvs/
				gantt["qty_stk"] = @tbldata[:qty_stk]
				gantt["qty_free"] = 0
			###
			### bill payの対応
			###
			when /mkprdpurords/
				setParams["segment"] = "mkprdpurords"
				setParams["gantt"] = gantt.dup
				setParams["tbldata"] = @tbldata
				setParams["mkprdpurords_id"] = @tbldata[:id]
				setParams["remark"] = " RorBlkCtl.lib.proc_private_aud_rec"
				processreqs_id ,setParams = ArelCtl.proc_processreqs_add(setParams)		
				return setParams
			when /mkbillinsts/
				setParams["segment"] = "mkbillinsts"
				setParams["tbldata"] = @tbldata
				setParams["gantt"] = gantt.dup
				setParams["mkbillinsts_id"] = @tbldata[:id]
				setParams["remark"] = " RorBlkCtl.lib.proc_private_aud_rec"
				processreqs_id ,setParams = ArelCtl.proc_processreqs_add(setParams)	
				return setParams
			end
		
			### 
			case @tblname  ###time,date,locas_id 
			when /^prdschs/
				gantt["starttime_trn"] = (@tbldata[:duedate].to_time - opeitm["duration"].to_f*60*60*24).strftime("%Y-%m-%d %H:%M:%S") 
				###作業場所の稼働日考慮要
				strsql = "select locas_id_workplace from workplaces where id = #{@tbldata[:workplaces_id]} "
				gantt["locas_id_trn"] = ActiveRecord::Base.connection.select_value(strsql)
			when /^purschs/
				gantt["starttime_trn"] = (@tbldata[:duedate].to_time - opeitm["duration"].to_f*60*60*24).strftime("%Y-%m-%d %H:%M:%S")  
				###作業場所の稼働日考慮要
				debugger if @tbldata[:suppliers_id].nil?
				strsql = "select locas_id_supplier from suppliers where id = #{@tbldata[:suppliers_id]} "
				gantt["locas_id_trn"] = ActiveRecord::Base.connection.select_value(strsql)
			when /^prdords/
				gantt["starttime_trn"] = @tbldata[:starttime] 
				debugger if @tbldata[:workplaces_id].nil?
				strsql = "select locas_id_workplace from workplaces where id = #{@tbldata[:workplaces_id]} "
				gantt["locas_id_trn"] = ActiveRecord::Base.connection.select_value(strsql)
			when /^prdinsts/
				gantt["starttime_trn"] = @tbldata[:commencementdate]  
			when /^replyinputs/
				gantt["duedate_trn"] =  gantt["toduedate_trn"] =  @tbldata[:replydate]
			when /^prdacts/
				gantt["duedate_trn"] = gantt["toduedate_trn"] =  @tbldata[:cmpldate]
			when /^purords/
				gantt["starttime_trn"] = @tbldata[:starttime] 
				strsql = "select locas_id_supplier from suppliers where id = #{@tbldata[:suppliers_id]} "
				gantt["locas_id_trn"] = ActiveRecord::Base.connection.select_value(strsql)
			when /^puracts/
				gantt["duedate_trn"] = gantt["toduedate_trn"] =  @tbldata[:rcptdate]
			when /^custords|^custschs/
				###custschs,custordsはopeitms_idを持っているのでshelfnos_id_fmは画面から持ってくる。
				###@tbldata[:shelfnos_id_fm] = @opeitm["shelfnos_id_to_opeitm"]  ###shelfnos_id_to:親がこの子部品をどこからとってくるか
				gantt["starttime_trn"] = @tbldata[:starttime] = (@tbldata[:duedate].to_date - 1).strftime("%Y-%m-%d %H:%M:%S") ###輸送期間と作業場所の稼働日考慮要
				gantt["locas_id_trn"] = opeitm["locas_id_opeitm"]
				strsql = "select locas_id_cust from custs where id = #{@tbldata[:custs_id]} "
				gantt["locas_id_trn"] = ActiveRecord::Base.connection.select_value(strsql)
			end
		
			if @tblname =~ /^prd|^pur|^cust/ and @tblname =~ /insts|dlvs|acts|rets/
				###前の状態の変更　ordsは対象外（mkordprdpur.proc_mkprdpurords)で実施
				###custordskの在庫の変更はOperation.custords_alloc_to_custschsで
				src_qty = @tbldata[:qty_sch].to_f + @tbldata[:qty].to_f + @tbldata[:qty_stk].to_f
				link_strsql,sql_get_src_alloc = get_src_tbl(@tblname)
				if link_strsql != "" and command_c[:sio_classname] =~ /_edit_|_update_|_delete_|_purge_/
					save_trngantts_id = ""
					ActiveRecord::Base.connection.select_all(link_strsql).each do |link|
						if src_qty > link["qty_src"].to_f
							src_qty -= link["qty_src"].to_f
						else
							update_alloctbls_linktbl(link,src_qty)
							src_qty = 0
							save_trngantts_id = link["trngantts_id"] if save_trngantts_id == ""
						end
					end
					if src_qty > 0  ###注文数以上の数量増　数量増の可否は画面又はバッチ入り口で
						if @tblname =~ /dlvs|acts/   ###返品の数量増はない。
							inc_qty_stk = src_qty
							inc_qty = 0
						else
							inc_qty_stk = 0
							inc_qty = src_qty
						end
						increase_qty_add_free_alloc(save_trngantts_id,inc_qty,inc_qty_stk)
					end
				else
					if sql_get_src_alloc != "" and command_c[:sio_classname] =~  /_add_|_insert_/
						ActiveRecord::Base.connection.select_all(sql_get_src_alloc).each do |src_alloc|
							add_update_alloc_add_link(src_alloc,gantt)
						end
					end
				end
			end

			if @tblname =~ /^prd|^pur|^cust/ 
				setParams["gantt"] = gantt.dup
				setParams["tbldata"] = @tbldata.dup	
				case  @tblname
				when /insts$|acts$|dlvs$|rets$/
					setParams["segment"]  = "link_lotstkhists_update"   ### alloctbl inoutlotstksも作成
					setParams["remark"] = " RorBlkCtl.proc_private_aud_rec line:#{__LINE__}"
					processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
				when /schs$|ords$/
					# setParams["segment"]  = "trngantts"   ### alloctbl inoutlotstksをも作成
					setParams["remark"] = " RorBlkCtl.proc_private_aud_rec line:#{__LINE__}"
					# processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
                    ope = Operation::OpeClass.new(setParams)  ###xxxschs,xxxords
					setParams = ope.proc_trngantts()  ###xxxschs,xxxords
					setParams["segment"]  = "link_lotstkhists_update"   ### alloctbl inoutlotstksも作成
					setParams["remark"] = " RorBlkCtl.proc_private_aud_rec line:#{__LINE__}"
					processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
				# when /schs$/
				# 	setParams["gantt"] = gantt.dup
				# 	# setParams["segment"]  = "trngantts"   ### alloctbl inoutlotstksをも作成
				# 	setParams["remark"] = " RorBlkCtl.proc_private_aud_rec line:#{__LINE__}"
				# 	# processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
                #     ope = Operation::OpeClass.new(setParams)  ###xxxschs,xxxords
				# 	setParams = ope.proc_trngantts()  ###xxxschs,xxxords
				end
				if gantt["key"] == "00000" and gantt["orgtblid"] != gantt["tblid"]
					raise
				end
			end
			return setParams
		end

		def get_src_tbl
			srctblname = link_strsql = sql_get_src_alloc = ""
			@tbldata.each do |key,val|
				if val
					if val.size > 0 and key.to_s =~ /^sno_|^cno_|^gno_/
						srctblname = key.split("_")[1] + "s" 
						case key.to_s
						when  /^sno_/
							link_strsql = %Q&
									select src.*,link.qty_src,link.trngantts_id from #{srctblname} src 
															inner join linktbls link on link.srctblid = src.id 
															where src.sno = '#{val}' and link["srctblname"] = '#{srctblname}'
															and  link.tblid = #{@tbldata[:id]} and link.tblname = '#{@tblname}'
															order by link.trngantts_id
							&
							sql_get_src_alloc = %Q&
									select src.*,alloc.qty_sch alloc_qty_sch,alloc.qty alloc_qty,alloc.qty_stk alloc_qty_stk,
															alloc.qty_linkto_alloctbl,alloc.trngantts_id 
															from #{srctblname} src 
															inner join alloctbls alloc on alloc.srctblid = src.id 
															where src.sno = '#{val}'
															and  alloc.srctblid = #{@tbldata[:id]} and alloc.srctblname = '#{@tblname}'
															and (alloc.qty_sch + alloc.qty + alloc.qty_stk) > alloc.qty_linkto_alloctbl
															--- alloc.qty_sch , alloc.qty , alloc.qty_stk 0以外の数値が入っているのは1つのみ
															order by alloc.allocfree,alloc.id  ---引き当て済分から次の状態に移行する。
							&
						when  /^cno_/
							case srctblname
							when /^prd/
								link_strsql = %Q&
									select src.*,alloc.qty_sch alloc_qty_sch,alloc.qty alloc_qty,alloc.qty_stk alloc_qty_stk,alloc.trngantts_id 
														from #{srctblname} src 
														inner join alloctbls alloc on alloc.srctblid = src.id
											where src.cno = '#{val}' and link["srctblname"] = '#{srctblname}'
											and src.workplaces_id = #{@tbldata[:workplaces_id]}
											and  link.tblid = #{@tbldata[:id]} and link.tblname = '#{@tblname}'
											order by link.trngantts_id
								& 
								sql_get_src_alloc = %Q&
									select src.*,alloc.qty_sch alloc_qty_sch,alloc.qty alloc_qty,alloc.qty_stk alloc_qty_stk,
														alloc.qty_linkto_alloctbl,alloc.trngantts_id  
														from #{srctblname} src 
														inner join alloctbls alloc on alloc.srctblid = src.id 
											where src.cno = '#{val}'
											and src.workplaces_id = #{@tbldata[:workplaces_id]}
											and  alloc.srctblid = #{@tbldata[:id]} and alloc.srctblname = '#{tblname}'
											and (alloc.qty_sch + alloc.qty + alloc.qty_stk) > alloc.qty_linkto_alloctbl
											order by alloc.allocfree,alloc.id
								& 
							when /^pur/
								link_strsql = %Q&
									select src.*,link.qty_src,link.trngantts_id from #{srctblname} src 										  
											inner join linktbls link on link.srctblid = src.id
											where src.cno = '#{val}' and link["srctblname"] = '#{srctblname}'
											and src.suppliers_id = #{@tbldata[:suppliers_id]}
											and  link.tblid = #{@tbldata[:id]} and link.tblname = '#{@tblname}'
											order by link.trngantts_id
								& 
								sql_get_src_alloc = %Q&
									select src.*,alloc.qty_sch alloc_qty_sch,alloc.qty alloc_qty,alloc.qty_stk alloc_qty_stk,
														alloc.qty_linkto_alloctbl,alloc.trngantts_id  
														from #{srctblname} src 
														inner join alloctbls alloc on alloc.srctblid = src.id 
											where src.cno = '#{val}'
											and src.suppliers_id = #{@tbldata[:suppliers_id]}
											and  alloc.srctblid = #{@tbldata[:id]} and alloc.srctblname = '#{@tblname}'
											and (alloc.qty_sch + alloc.qty + alloc.qty_stk) > alloc.qty_linkto_alloctbl
											order by alloc.allocfree,alloc.id
								& 
							when /^cust/
								link_strsql = %Q&
									select src.*,link.qty_src,link.trngantts_id from #{srctblname} src 										  
											inner join linktbls link on link.srctblid = src.id 
											where src.cno = '#{val}' and link["srctblname"] = '#{srctblname}'
											and src.custs_id = #{@tbldata[:custs_id]}
											and  link.tblid = #{@tbldata[:id]} and link.tblname = '#{@tblname}'
											order by link.trngantts_id
								& 
								sql_get_src_alloc = %Q&
									select src.*,alloc.qty_sch alloc_qty_sch,alloc.qty alloc_qty,alloc.qty_stk alloc_qty_stk,
														alloc.qty_linkto_alloctbl,alloc.trngantts_id  
														from #{srctblname} src 
														inner join alloctbls alloc on alloc.srctblid = src.id  
											where src.cno = '#{val}'
											and src.custs_id = #{@tbldata[:custs_id]}
											and  alloc.srctblid = #{@tbldata[:id]} and alloc.srctblname = '#{tblname}'
											and (alloc.qty_sch + alloc.qty + alloc.qty_stk) > alloc.qty_linkto_alloctbl
											order by alloc.allocfree,alloc.id
								& 
							end	
						when  /^gno_/
							case srctblname
							when /^prd/
								link_strsql = %Q&
									select src.*,link.qty_src,link.trngantts_id from #{srctblname} src 										  
											inner join linktbls link on link.srctblid = src.id
											where src.gno = '#{val}' and link["srctblname"] = '#{srctblname}'
											and src.opeitms_id = #{@tbldata[:opeitms_id]}
											and src.shelfnos_id_to = #{@tbldata[:shelfnos_id_to]}
											and src.shelfnos_id_fm = #{@tbldata[:shelfnos_id_fm]}
											and  link.tblid = #{@tbldata[:id]} and link.tblname = '#{@tblname}'
											order by link.trngantts_id
								& 
								sql_get_src_alloc = %Q&
									select src.*,alloc.qty_sch alloc_qty_sch,alloc.qty alloc_qty,alloc.qty_stk alloc_qty_stk,
														alloc.qty_linkto_alloctbl,alloc.trngantts_id  
														from #{srctblname} src 
														inner join alloctbls alloc on alloc.srctblid = src.id 
											where src.gno = '#{val}' and link["srctblname"] = '#{srctblname}'
											and src.opeitms_id = #{@tbldata[:opeitms_id]}
											and src.shelfnos_id_to = #{@tbldata[:shelfnos_id_to]}
											and src.shelfnos_id_fm = #{@tbldata[:shelfnos_id_fm]}
											and  alloc.srctblid = #{@tbldata[:id]} and alloc.srctblname = '#{@tblname}'
											and (alloc.qty_sch + alloc.qty + alloc.qty_stk) > alloc.qty_linkto_alloctbl
											order by alloc.allocfree,alloc.id
								& 
							when /^pur/
								link_strsql = %Q&
									select src.*,link.qty_src,link.trngantts_id from #{srctblname} src 										  
											inner join linktbls link on link.srctblid = src.id
											where src.gno = '#{val}' and link["srctblname"] = '#{srctblname}'
											and src.opeitms_id = #{@tbldata[:opeitms_id]}
											and src.shelfnos_id_to = #{@tbldata[:shelfnos_id_to]}
											and src.shelfnos_id_fm = #{@tbldata[:shelfnos_id_fm]}
											and  link.tblid = #{@tbldata[:id]} and link.tblname = '#{@tblname}'
											order by link.trngantts_id
								& 
								sql_get_src_alloc = %Q&
									select src.*,alloc.qty_sch alloc_qty_sch,alloc.qty alloc_qty,alloc.qty_stk alloc_qty_stk,
														alloc.qty_linkto_alloctbl,alloc.trngantts_id  
														from #{srctblname} src 
														inner join alloctbls alloc on alloc.srctblid = src.id 
											where src.gno = '#{val}'
											and src.opeitms_id = #{@tbldata[:opeitms_id]}
											and src.shelfnos_id_to = #{@tbldata[:shelfnos_id_to]}
											and src.shelfnos_id_fm = #{@tbldata[:shelfnos_id_fm]}
											and  alloc.srctblid = #{@tbldata[:id]} and alloc.srctblname = '#{@tblname}'
											and (alloc.qty_sch + alloc.qty + alloc.qty_stk) > alloc.qty_linkto_alloctbl
											order by alloc.allocfree,alloc.id
								& 
							when /^cust/
								link_strsql = %Q&
									select src.*,link.qty_src,link.trngantts_id from #{srctblname} src 										  
											inner join linktbls link on link.srctblid = src.id
											where src.gno = '#{val}' and link["srctblname"] = '#{srctblname}'
											and src.opeitms_id = #{@tbldata[:opeitms_id]}
											and src.custrcvplcs_id = #{@tbldata[:custrcvplcs_id]}
											and  link.tblid = #{@tbldata[:id]} and link.tblname = '#{@tblname}'
											order by link.trngantts_id
								&
								sql_get_src_alloc = %Q&
									select src.*,alloc.qty_sch alloc_qty_sch,alloc.qty alloc_qty,alloc.qty_stk alloc_qty_stk,
														alloc.qty_linkto_alloctbl,alloc.trngantts_id  
														from #{srctblname} src 
														inner join alloctbls alloc on alloc.srctblid = src.id 
											where src.gno = '#{val}'
											and src.opeitms_id = #{@tbldata[:opeitms_id]}
											and src.custrcvplcs_id = #{@tbldata[:custrcvplcs_id]}
											and  alloc.srctblid = #{@tbldata[:id]} and alloc.srctblname = '#{@tblname}'
											and (alloc.qty_sch + alloc.qty + alloc.qty_stk) > alloc.qty_linkto_alloctbl
											order by alloc.allocfree,alloc.id
								&
							end
						end	
					end
				end
			end
			return link_strsql,sql_get_src_alloc
		end	

		def setGantt(setParams)
			opeitm = setParams["opeitm"]
			if setParams["gantt"].nil?
				gantt = {}
				gantt["orgtblname"] = gantt["paretblname"] = @tblname
				gantt["orgtblid"] = gantt["paretblid"] =  @tbldata[:id]	
				gantt["trngantts_id"] = ArelCtl.proc_get_nextval("trngantts_seq")
				gantt["key"] = "00000"
				gantt["mlevel"] = 0
				gantt["parenum"] = gantt["chilnum"] = 1
				gantt["qty_pare"] = 0
				gantt["qty_stk_pare"] = 0
				gantt["shelfnos_id_to"] =  case @tblname
								   when /^prd|^pur/ 
									@tbldata[:shelfnos_id_to]
								   else
									"0"  ###shelfnos_id=0は必須　dummy
								   end
				gantt["shelfnos_id_to_pare"] = gantt["shelfnos_id_to"]     
				gantt["shelfnos_id_fm"] = gantt["shelfnos_id_to"] 
				gantt["chrgs_id_trn"] =  gantt["chrgs_id_pare"] =  gantt["chrgs_id_org"] =  @tbldata[:chrgs_id]
				gantt["prjnos_id"] = @tbldata[:prjnos_id]
				gantt["shuffle_flg"] = (opeitm["shuffle_flg"]||="0")
				gantt["itms_id_trn"] = gantt["itms_id_pare"]  = gantt["itms_id_org"]  = opeitm["itms_id"]
				gantt["processseq_trn"] = gantt["processseq_pare"]  = gantt["processseq_org"]  = opeitm["processseq"]
				gantt["qty_sch"] = gantt["qty"] = gantt["qty_stk"] = 0  ###下記のコーディングで対応
				gantt["duedate_trn"] = gantt["duedate_pare"] = gantt["duedate_org"] = @tbldata[:duedate]
				gantt["toduedate_trn"] = gantt["toduedate_pare"] = gantt["toduedate_org"] = (@tbldata[:toduedate]||=@tbldata[:duedate])
				gantt["starttime_trn"] = gantt["starttime_pare"] = gantt["starttime_org"] = @tbldata[:starttime]
				gantt["locas_id_trn"] = gantt["locas_id_pare"] = gantt["locas_id_org"] = opeitm["locas_id_opeitm"]
				gantt["consumunitqty"] = 1 ###消費単位
				gantt["consumminqty"]  = 0 ###最小消費数
				gantt["consumchgoverqty"] = 0  ###段取り消費数
				gantt["remark"] = " RorBlkCtl line:#{__LINE__} "
				gantt["qty_require"] = 0
		 	else
				gantt = setParams["gantt"].dup
			 	gantt["shelfnos_id_to"] =  @tbldata[:shelfnos_id_to]
			 	gantt["chrgs_id_trn"] =  @tbldata[:chrgs_id]
			 	gantt["prjnos_id"] = @tbldata[:prjnos_id]
			 	gantt["shuffle_flg"] = (opeitm["shuffle_flg"]||="0")
			 	gantt["itms_id_trn"] = opeitm["itms_id"]
			 	gantt["processseq_trn"] = opeitm["processseq"]
			 	gantt["duedate_trn"] = @tbldata[:duedate]
			 	gantt["toduedate_trn"] = @tbldata[:toduedate]
			 	gantt["starttime_trn"] = @tbldata[:starttime]
			 	gantt["locas_id_trn"] = opeitm["locas_id_opeitm"]
			 	gantt["remark"] = " RorBlkCtl line:#{__LINE__} "
			end
			gantt["tblname"] = @tblname
			gantt["tblid"] = tblid = @tbldata[:id]	
			return gantt
		end
	
		def update_alloctbls_linktbl(link,src_qty)
			strsql = %Q&
				update linktbls set src_qty = #{src_qty},remark = 'ror_blktbl(#{__LINE__})'
								where id = #{link["id"]}
			&
			ActiveRecord::Base.connection.update(strsql)
			strsql = %Q&
				update alloctbls set qty_linkto_alloctbl = #{src_qty},remark = 'ror_blktbl(#{__LINE__})'
								where srctblname = '#{link["srctblname"]}' and srctblid = #{link["srctblid"]}
								and trngantts_id = #{link["trngantts_id"]} 
			&
			ActiveRecord::Base.connection.update(strsql)
			case link["tblname"]
			when /schs/
				qty_sch = src_qty
				qty = qty_stk = 0
			when /dlvs|acts|rets/
				qty_stk = src_qty
				qty = qty_stk = 0
			else
				qty = src_qty
				qty_sch = qty_stk = 0
			end
			strsql = %Q&
				update alloctbls set qty_sch = #{qty_sch},qty = #{qty},qty_stk = #{qty_stk},
								remark = 'ror_blktbl(#{__LINE__})'
								where srctblname = '#{link["tblname"]}' and srctblid = #{link["tblid"]}
								and trngantts_id = #{link["trngantts_id"]} 
				&
			ActiveRecord::Base.connection.update(strsql)
		end

		def add_update_alloc_add_link(src_alloc,gantt)  ###前の状態から現状への変更
			src = {"trngantts_id" => src_alloc["trngantts_id"],"tblname" => src_alloc["srctblname"],
				"tblid" => src_alloc["srctblid"]}
			base = {"tblname" => gantt["tblname"] ,
				"tblid" => gantt["tblid"],
				"qty_src" =>gantt["qty_sch"].to_f + gantt["qty"].to_f + gantt["qty_stk"].to_f + gantt["qty_alloc"].to_f}
			###
			ArelCtl.proc_insert_linktbls(src,base)
			###
			strsql = %Q&
				update alloctbls set qty_linkto_alloctbl = qty_linkto_alloctbl + #{base["qty_src"]},
								remark = 'ror_blktbl(#{__LINE__})'
								where id = #{src_alloc["id"]} 
				&
			ActiveRecord::Base.connection.update(strsql)

			src = {"trngantts_id" => src_alloc["trngantts_id"],"tblname" => gantt["tblname"] ,
				"tblid" => gantt["tblid"],"allocfree" => "alloc",
				"qty_sch" => gantt["qty_sch"],"qty" => gantt["qty"].to_f + gantt["qty_alloc"].to_f ,"qty_stk" => gantt["qty_stk"],
				"qty_linkto_alloctbl" => 0,	"remark" => "ror_blkctl(line #{__LINE__} #{Time.now})"}
			ArelCtl.proc_insert_alloctbls(src)

			###在庫の修正はOperation.proc_trnganttsで実施
		end

		def increase_qty_add_free_alloc(save_trngantts_id,inc_qty,inc_qty_stk)
			strsql = %Q&
				select trn.* from alloctbls alloc 
							inner join trngantts trn on trn.tblname = alloc.srctblname and trn.tblid = alloc.srctblid 
							where alloc.trngantts_id = #{save_trngantts_id} and alloc.srctblname like '%ords' 
							and orgtblname = paretblname and paretblname = tblname 
							and orgtblid = paretblid and paretblid = tblid
							order alloc.id  desc
			&
			trn = ActiveRecord::Base.connection.select_one(strsql)
			update_trngantt = %Q&
					update trngantts set qty = qty + #{inc_qty},qty_stk = qty_stk + #{inc_qty_stk},
											qty_free = qty_free + #{inc_qty + inc_qty_stk },remark = 'ror_blkctl(#{__LINE__})'
							where id = #{trn["id"]}
			&
			ActiveRecord::Base.connection.update(update_trngantt)

			update_alloc = %Q&
					update alloctbls set qty = qty + #{inc_qty},qty_stk = qty_stk + #{inc_qty_stk},remark = 'ror_blktbl(#{__LINE__})'
							where trngantts_id = #{trn["id"]} and srctblname = '#{trn["tblname"]}'  and srctblid = '#{trn["tblid"]}'
			&
			ActiveRecord::Base.connection.update(update_alloc)
		
		end

		def insert_sio_r(command_c)  ####レスポンス
		rec = {}
        rec[:sio_id] =  ArelCtl.proc_get_nextval("sio.SIO_#{command_c[:sio_viewname]}_SEQ")
        rec[:sio_command_response] = "R"
		rec[:sio_add_time] = Time.now
        rec[:sio_result_f] =  "1"   ## 1 normal end
        rec[:sio_message_contents] = nil
          command_init[(@tblname.chop + "_id")] =  command_c["id"] = @tbldata[:id]
		###画面専用項目
		command_c.each do |key,val|
			next if key.to_s =~ /gridmessage/
			next if key.to_s =~ /^_/
			next if key.to_s == "confirm"
			next if key.to_s == "aud"
			next if key.to_s == "errPath"
			rec[key] = val
		end	
		tbl_add_arel  "SIO_#{command_c[:sio_viewname]}",rec
		end   ## 
		
   ## proc_strwhere


		def proc_create_tbldata(command_c) ##
			if command_c[:sio_classname] =~ /_add_/ or command_c["id"] == "" or command_c["id"].nil?
				@tbldata[:created_at] =  command_c["#{@tblname.chop}_created_at"] = Time.now
				if  command_c["id"] == "" or command_c["id"].nil?
					command_c["id"] = @tbldata[:id] = ArelCtl.proc_get_nextval("#{@tblname}_seq")
					command_c[@tblname.chop+"_id"] = command_c["id"] 
				else
					@tbldata[:id] = command_c["id"]  ###fields_updateでセット済
				end
			else
				@tbldata[:id] =	command_c["id"]	
			end	
        	command_c.each do |j,k|
        		j_to_stbl,j_to_sfld = j.to_s.split("_",2)
				if  j_to_stbl == @tblname.chop  and j_to_sfld !~ /_gridmessage/ and j_to_sfld != "id" and
					j_to_sfld != "code_upd" and  j_to_sfld != "name_upd"   and  j_to_sfld != "id_upd"##本体の更新
			    	if  k
	            		@tbldata[j_to_sfld.sub("_id","s_id").to_sym] = k
						@tbldata[j_to_sfld.to_sym] = nil  if k  == "\#{nil}"  ##
						if k == ""
							case 	  j_to_sfld
							when 'sno'
								command_c[@tblname.chop+"_sno"] = @tbldata[:sno] = CtlFields.proc_field_sno(@tblname.chop,command_c["id"])
							when 'cno'
								command_c[@tblname.chop+"_cno"] = @tbldata[:cno] = CtlFields.proc_field_cno(command_c["id"])
							when 'gno'
								command_c[@tblname.chop+"_gno"] = @tbldata[:gno] = CtlFields.proc_field_gno(command_c["id"])
							end
						else
						end
					end
            	end   ## if j_to_s.
			end ## command_c.each
        	@tbldata[:persons_id_upd] = command_c["#{@tblname.chop}_person_id_upd"] = (@sio_user_id||=0) ###performでの処理では@sio_user_ide=nil
			@tbldata[:updated_at] = command_c["#{@tblname.chop}_updated_at"] = Time.now
		end

    	def undefined
    		nil
    	end

		def tbl_add_arel  reqTblName,tblarel ##
			fields = ""
			values = ""  ###insert into(....) value(xxx)のxxx
			tblarel.each do |key,val|
				fields << key.to_s + ","
				# strsql = %Q&select fieldcode_ftype from r_fieldcodes
				# 			where  pobject_code_fld = '#{if tblname.downcase =~ /^sio|^bk/ then key.to_s.split("_",2)[1] else key.to_s end}'&
				# ftype = ActiveRecord::Base.connection.select_value(strsql)
				key = if reqTblName.downcase =~ /^sio|^bk/ then key.to_s.split("_",2)[1] else key.to_s end
				ftype = $ftype[key]
			 		values << 	case ftype
			 			when /char/  ###db type
			 				%Q&'#{(val||="").gsub("'","''")}',&
			 			when "numeric"
			 				"#{val.to_s.gsub(",","")},"   ###入力データはzzz0,zzz,zzz.zz,・・・であること
						when /timestamp|date/  ##db type
							case (val||="").class.to_s  ### ruby type
							when  /Time|Date/
								case key.to_s
								when "expiredate"  ###date type
									%Q& to_date('#{val.strftime("%Y/%m/%d")}','yyyy/mm/dd'),&
			 					else
									%Q& '#{val}',&
								end
							when "String"	 
								case key.to_s
			 					when "created_at","updated_at"
			 						%Q& to_timestamp('#{val.gsub("-","/")}','yyyy/mm/dd hh24:mi:ss'),&
								when "expiredate"
									%Q& to_date('#{val.gsub("-","/")}','yyyy/mm/dd'),&
			 					else
									%Q& to_timestamp('#{val.gsub("-","/")}','yyyy/mm/dd hh24:mi'),&
								end
							else
							   Rails.logger.debug " line #{__LINE__} : error val.class #{ftype}  key #{key.to_s} "
							   p " line #{__LINE__} : error val.class #{ftype}  key #{key.to_s} "
							end	
						else
							if reqTblName.downcase =~ /^sio_|^bk_/
								%Q&'#{val.to_s.gsub("'","''")}',&
							else
								Rails.logger.debug " line #{__LINE__} : error val.class #{ftype}  key #{key.to_s} "
								p " line #{__LINE__} : error val.class #{ftype}  key #{key.to_s} "
							end	
			 			end
			end
			case reqTblName.downcase
			when  /^sio_/
				ActiveRecord::Base.connection.insert("insert into sio.#{reqTblName.downcase}(#{fields.chop}) values(#{values.chop})")
			when  /^bk_/
				ActiveRecord::Base.connection.insert("insert into bk.#{reqTblName.downcase}(#{fields.chop}) values(#{values.chop})")
			else
				ActiveRecord::Base.connection.insert("insert into #{reqTblName.downcase}(#{fields.chop}) values(#{values.chop})")
			end
		end

		def tbl_edit_arel  strwhere ##
			strset = ""
			strset = ""
			@tbldata.each do |key,val|
				# strsql = %Q&select fieldcode_ftype from r_fieldcodes where  pobject_code_fld = '#{key.to_s}'&
				# ftype = ActiveRecord::Base.connection.select_value(strsql)
				ftype = $ftype[key.to_s]
				strset << case ftype
					when /char/  ###db type
						%Q& #{key.to_s} = '#{val.gsub("'","''")}',&
					when "numeric"
						"#{key.to_s} = #{val.to_s.gsub(",","")},"
		   			when /timestamp|date/  ##db type
			   			case val.class.to_s  ### ruby type
			   			when  /Time|Date/
				   			case key.to_s
							when "created_at","updated_at"
								%Q& #{key.to_s} =  to_timestamp('#{val.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),&
				   			when "expiredate"
					   			%Q&  #{key.to_s} = to_date('#{val.strftime("%Y/%m/%d")}','yyyy/mm/dd'),&
							else
								%Q&  #{key.to_s} = to_timestamp('#{val.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi'),&
				   			end
			   			when "String"	 
				   			case key.to_s
							when "created_at","updated_at"
								%Q&  #{key.to_s} = to_timestamp('#{val.gsub("-","/")}','yyyy/mm/dd hh24:mi:ss'),&
				   			when "expiredate"
					   			%Q&  #{key.to_s} = to_date('#{val.gsub("-","/")}','yyyy/mm/dd'),&
							else
								%Q&  #{key.to_s} = to_timestamp('#{val.gsub("-","/")}','yyyy/mm/dd hh24:mi'),&
				   			end
			   			else
				  			Rails.logger.debug " line #{__LINE__} : error val.class #{ftype}  key #{key.to_s} "
				  			p " line #{__LINE__} : error val.class #{ftype}  key #{key.to_s} "
			   			end	
				else
					if @tblname.downcase =~ /^sio_|^bk_/
						%Q& #{key.to_s} = '#{val.to_s.gsub("'","''")}',&
					else
						Rails.logger.debug " line #{__LINE__} : error val.class #{ftype}  key #{key.to_s} "
						p " line #{__LINE__} : error val.class #{ftype}  key #{key.to_s} "
					end	
				end
			end
			ActiveRecord::Base.connection.update("update #{@tblname}  set #{strset.chop} where #{strwhere} ")
		end

		def tbl_delete_arel  strwhere ##
			ActiveRecord::Base.connection.delete("delete from  #{@tblname}  where #{strwhere} ")
		end
	end
end   ##module Ror_blk
