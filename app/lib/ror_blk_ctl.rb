
# -*- coding: utf-8 -*-
# RorBlkCtl
# 2099/12/31を修正する時は　2100/01/01の修正も
module RorBlkCtl
	extend self
	class BlkClass
		def initialize(screenCode)
			@screenCode = screenCode
		    @sio_user_id = ActiveRecord::Base.connection.select_value("select id from persons where email = '#{$email}'")
		    @command_init = {}
		    strsql = "select pobject_code_view from r_screens where pobject_code_scr = '#{@screenCode}' and screen_expiredate > current_date"
		    @command_init[:sio_viewname] =  ActiveRecord::Base.connection.select_value(strsql)
		    @command_init[:sio_code] =  @screenCode
		    @command_init[:sio_message_contents] = nil
		    @command_init[:sio_recordcount] = 1
		    @command_init[:sio_result_f] =   "0"  
            command_init[:sio_recordcount] = 1
            @src_tbl = {}   ###テーブル更新
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
        return setParams,command_c
	end

	def proc_private_aud_rec(params,command_c)
		tmp_key = {}
        setParams = params.dup
		tblname = command_c[:sio_viewname].split("_")[1]
		case command_c[:sio_classname]
		when /_add_|_insert_/
			tbl_add_arel(tblname,@src_tbl) ###@
		when /_edit_|_update_/
			tbl_edit_arel(tblname,@src_tbl," id = #{@src_tbl[:id]}")
		when  /_delete_|_purge_/
			if tblname =~ /schs$|ords$|insts$|dlvs$|acts$|rets$/  ##削除なし
					@src_tbl[:qty_sch] = 0 if @src_tbl[:qty_sch]
					@src_tbl[:qty] = 0 if @src_tbl[:qty]
					@src_tbl[:qty_stk] = 0 if @src_tbl[:qty_stk]
					@src_tbl[:amt] = 0 if @src_tbl[:amt]
					@src_tbl[:tax] = 0 if @src_tbl[:tax]      ##変更分のみ更新
					tbl_edit_arel(tblname,@src_tbl," id = #{@src_tbl[:id]}")
			else
					tbl_delete_arel(tblname," id = #{@src_tbl[:id]}")
			end
		else
			Rails.logger.debug"error class #{self} : #{Time.now}: sio_classname missing "
			Rails.logger.debug"error class #{self} : @src_tbl: #{@src_tbl} "
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
        case tblname
        when /^prd|^pur|^shp|^mk/
            ###次の処理
        when /^custs$/
            return setParams 
        else 
            return setParams 
        end

		if @src_tbl[:opeitms_id]
			opeitm = ActiveRecord::Base.connection.select_one("select * from opeitms where id = #{@src_tbl[:opeitms_id]}")
		else
			opeitm = {}
		end
		if setParams["gantt"].nil?
			gantt = {}
			gantt["orgtblname"] = gantt["paretblname"] = tblname
			gantt["orgtblid"] = gantt["paretblid"] =  @src_tbl[:id]	
			setParams["seqno"] = []
			setParams["child"] = {}
			gantt["trngantts_id"] = ArelCtl.proc_get_nextval("trngantts_seq")
			gantt["key"] = "00000"
			gantt["mlevel"] = 0
			gantt["parenum"] = gantt["chilnum"] = 1
			gantt["qty_pare"] = 0
			gantt["qty_stk_pare"] = 0
			gantt["shelfnos_id_to"] =  case tblname
			                           when /^prd|^pur/ 
										@src_tbl[:shelfnos_id_to]
									   else
										"0"  ###shelfnos_id=0は必須　dummy
									   end
			gantt["shelfnos_id_to_pare"] = gantt["shelfnos_id_to"]     
			gantt["shelfnos_id_real"] = gantt["shelfnos_id"] 
			gantt["chrgs_id_trn"] =  gantt["chrgs_id_pare"] =  gantt["chrgs_id_org"] =  @src_tbl[:chrgs_id]
			gantt["prjnos_id"] = @src_tbl[:prjnos_id]
			gantt["shuffle_flg"] = (opeitm["shuffle_flg"]||="0")
			gantt["itms_id_trn"] = gantt["itms_id_pare"]  = gantt["itms_id_org"]  = opeitm["itms_id"]
			gantt["processseq_trn"] = gantt["processseq_pare"]  = gantt["processseq_org"]  = opeitm["processseq"]
			gantt["qty_sch"] = gantt["qty"] = gantt["qty_stk"] = 0  ###下記のコーディングで対応
			gantt["duedate_trn"] = gantt["duedate_pare"] = gantt["duedate_org"] = @src_tbl[:duedate]
			gantt["starttime_trn"] = gantt["starttime_pare"] = gantt["starttime_org"] = @src_tbl[:starttime]
			gantt["locas_id_trn"] = gantt["locas_id_pare"] = gantt["locas_id_org"] = opeitm["locas_id_opeitm"]
			gantt["consumunitqty"] = 1 ###消費単位
			gantt["consumminqty"]  = 0 ###最小消費数
			gantt["consumchgoverqty"] = 0  ###段取り消費数
			gantt["remark"] = " RorBlkCtl line:#{__LINE__} "
			gantt["qty_require"] = 0
		 else
		 	gantt = setParams["gantt"].dup
		 	gantt["shelfnos_id_to"] =  @src_tbl[:shelfnos_id_to]
		 	gantt["chrgs_id_trn"] =  @src_tbl[:chrgs_id]
		 	gantt["prjnos_id"] = @src_tbl[:prjnos_id]
		 	gantt["shuffle_flg"] = (opeitm["shuffle_flg"]||="0")
		 	gantt["itms_id_trn"] = opeitm["itms_id"]
		 	gantt["processseq_trn"] = opeitm["processseq"]
		 	gantt["duedate_trn"] = @src_tbl[:duedate]
		 	gantt["starttime_trn"] = @src_tbl[:starttime]
		 	gantt["locas_id_trn"] = opeitm["locas_id_opeitm"]
		 	gantt["remark"] = " RorBlkCtl line:#{__LINE__} "
		end
		gantt["tblname"] = tblname
		gantt["tblid"] = tblid = @src_tbl[:id]		
		setParams["classname"] = command_c[:sio_classname]
		setParams["tbldata"] = @src_tbl.stringify_keys  
		setParams["opeitm"] = opeitm.dup

		###qty_sch qty qty_stk 
		case tblname
		when /^prdschs|^purschs|^custschs/
			gantt["qty_sch"] = @src_tbl[:qty_sch]
			gantt["qty_handover"] = @src_tbl[:qty_sch] ###下位部品所要量計算用
			##gantt["qty_require"] = @src_tbl[:qty_sch].to_f  ###自身のschsからordsへの変換用
			gantt["qty_free"] = 0
		when /schs/
			gantt["qty_sch"] = @src_tbl[:qty_sch]
			gantt["qty_free"] = 0
		when /^custords/
			gantt["qty"] =  gantt["qty_handover"] = gantt["qty_require"] = @src_tbl[:qty]
			###下位部品所要量計算用
			###自身のschsからordsへの変換用
			gantt["qty_free"] = 0
		when /^prdords|^purords/
			gantt["qty"] =  gantt["qty_free"] =  @src_tbl[:qty]
			gantt["qty_handover"] = @src_tbl[:qty] ###下位部品所要量計算用
			###gantt["qty_require"] = @src_tbl[:qty].to_f  ###自身のschsからordsへの変換用
			gantt["qty_free"] = @src_tbl[:qty]
		when /insts|reply/
			gantt["qty"] =  @src_tbl[:qty]
			gantt["qty_free"] = 0
		when /acts|rets|dlvs/
			gantt["qty_stk"] = @src_tbl[:qty_stk]
			gantt["qty_free"] = 0
		end
		
		case  tblname
		when /mkprdpurords/
			setParams["segment"] = "mkprdpurords"
			setParams["gantt"] = gantt.dup
			setParams["mkprdpurords_id"] = @src_tbl[:id]
			setParams["remark"] = " RorBlkCtl.lib line:#{__LINE__}"
			processreqs_id ,setParams = ArelCtl.proc_processreqs_add(setParams)		
		when /mkbillinsts/
			setParams["segment"] = "mkbillinsts"
			setParams["gantt"] = gantt.dup
			setParams["mkbillinsts_id"] = @src_tbl[:id]
			setParams["remark"] = " RorBlkCtl.lib line:#{__LINE__}"
			processreqs_id ,setParams = ArelCtl.proc_processreqs_add(setParams)	
		end
		
		### 
		case tblname  ###time,date,locas_id 
		when /^prdschs/
			gantt["starttime_trn"] = @src_tbl[:duedate].to_time - opeitm["duration"].to_f*60*60*24 ###作業場所の稼働日考慮要
			strsql = "select locas_id_workplace from workplaces where id = #{@src_tbl[:workplaces_id]} "
			gantt["locas_id_trn"] = ActiveRecord::Base.connection.select_value(strsql)
		when /^purschs/
			gantt["starttime_trn"] = @src_tbl[:duedate].to_time - opeitm["duration"].to_f*60*60*24  ###作業場所の稼働日考慮要
			debugger if @src_tbl[:suppliers_id].nil?
			strsql = "select locas_id_supplier from suppliers where id = #{@src_tbl[:suppliers_id]} "
			gantt["locas_id_trn"] = ActiveRecord::Base.connection.select_value(strsql)
		when /^prdords/
			gantt["starttime_trn"] = @src_tbl[:starttime] 
			debugger if @src_tbl[:workplaces_id].nil?
			strsql = "select locas_id_workplace from workplaces where id = #{@src_tbl[:workplaces_id]} "
			gantt["locas_id_trn"] = ActiveRecord::Base.connection.select_value(strsql)
		when /^prdinsts/
			gantt["starttime_trn"] = @src_tbl[:commencementdate]  
		when /^replyinputs/
			gantt["duedate_trn"] =  @src_tbl[:replydate]
		when /^prdacts/
			gantt["duedate_trn"] = @src_tbl[:cmpldate]
		when /^purords/
			gantt["starttime_trn"] = @src_tbl[:starttime] 
			strsql = "select locas_id_supplier from suppliers where id = #{@src_tbl[:suppliers_id]} "
			gantt["locas_id_trn"] = ActiveRecord::Base.connection.select_value(strsql)
		when /^puracts/
			gantt["duedate_trn"] = @src_tbl[:rcptdate]
		when /^custords|^custschs/
			###custschs,custordsはopeitms_idを持っているのでshelfnos_id_fmは画面から持ってくる。
			###@src_tbl[:shelfnos_id_fm] = @opeitm["shelfnos_id_to_opeitm"]  ###shelfnos_id_to:親がこの子部品をどこからとってくるか
			gantt["starttime_trn"] = @src_tbl[:starttime] = (@src_tbl[:duedate].to_date - 1).strftime("%Y-%m-%d %H:%M:%S") ###輸送期間と作業場所の稼働日考慮要
			gantt["locas_id_trn"] = opeitm["locas_id_opeitm"]
			strsql = "select locas_id_cust from custs where id = #{@src_tbl[:custs_id]} "
			gantt["locas_id_trn"] = ActiveRecord::Base.connection.select_value(strsql)
		end
		
		if tblname =~ /^prd|^pur|^cust/ and tblname =~ /insts|dlvs|acts|rets/
			###前の状態の変更　ordsは対象外（Operation)で実施
			###prdord,purordsとprdschs,purschsの引き当てはOperarion.free_ordtbl_alloc_to_sch
			###custordskの在庫の変更はOperation.custords_alloc_to_custschsで
			src_qty = @src_tbl[:qty_sch].to_f + @src_tbl[:qty].to_f + @src_tbl[:qty_stk].to_f
			link_strsql,sql_get_prev_alloc = get_prev_tbl(tblname)
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
				if src_qty > 0  ###数量増　数量増の可否は画面又はバッチ入り口で
					if tblname =~ /dlvs|acts/   ###返品の数量増はない。
						inc_qty_stk = src_qty
						inc_qty = 0
					else
						inc_qty_stk = 0
						inc_qty = src_qty
					end
					increase_qty_add_free_alloc(save_trngantts_id,inc_qty,inc_qty_stk)
				end
			else
				if alloc_strsql != "" and command_c[:sio_classname] =~  /_add_|_insert_/
					ActiveRecord::Base.connection.select_all(sql_get_prev_alloc).each do |prev_alloc|
						add_update_alloc_add_link(prev_alloc,gantt)
					end
				end
			end
		end

		###mkordinstの時はtrngantts等の作成はmkordinstで行う
		if tblname =~ /^prd|^pur|^cust/ 
			case  tblname
			when /schs$/
				setParams["gantt"] = gantt.dup
				setParams["segment"]  = "trngantts"   ### alloctbl inoutlotstksをも作成
				setParams["remark"] = " RorBlkCtl.lib line:#{__LINE__}"
				processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
			when /ords$/
				setParams["gantt"] = gantt.dup
				if setParams["mkprdpurords_id"].to_f == 0
					setParams["segment"]  = "trngantts"   ### alloctbl inoutlotstksをも作成
					setParams["remark"] = " RorBlkCtl.lib line:#{__LINE__}"
					processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
				end
			when /insts$|acts$|dlvs$|rets$/
				setParams["gantt"] = gantt.dup
				setParams["segment"]  = "add_update_lotstkhists"   ### alloctbl inoutlotstksも作成
				setParams["remark"] = " RorBlkCtl.lib line:#{__LINE__}"
				processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
			end
			if gantt["key"] == "00000" and gantt["orgtblid"] != gantt["tblid"]
				debugger
			end
		end
		return setParams
	end

	def get_prev_tbl tblname
		srctblname = link_strsql = sql_get_prev_alloc = ""
		@src_tbl.each do |key,val|
			if val
				if val.size > 0 and key.to_s =~ /^sno_|^cno_|^gno_/
					srctblname = key.split("_")[1] + "s" 
					case key.to_s
					when  /^sno_/
							link_strsql = %Q&
									select src.*,link.qty_src,link.trngantts_id from #{srctblname} src 
															inner join linktbls link on link.srctblid = src.id 
															where src.sno = '#{val}' and link["srctblname"] = '#{srctblname}'
															and  link.tblid = #{@src_tbl[:id]} and link.tblname = '#{tblname}'
															order by link.trngantts_id
							&
							sql_get_prev_alloc = %Q&
									select src.*,alloc.qty_sch alloc_qty_sch,alloc.qty alloc_qty,alloc.qty_stk alloc_qty_stk,
															alloc.qty_linkto_alloctbl,alloc.trngantts_id 
															from #{srctblname} src 
															inner join alloctbls alloc on alloc.srctblid = src.id 
															where src.sno = '#{val}'
															and  alloc.srctblid = #{@src_tbl[:id]} and alloc.srctblname = '#{tblname}'
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
											and src.workplaces_id = #{@src_tbl[:workplaces_id]}
											and  link.tblid = #{@src_tbl[:id]} and link.tblname = '#{tblname}'
											order by link.trngantts_id
								& 
								sql_get_prev_alloc = %Q&
									select src.*,alloc.qty_sch alloc_qty_sch,alloc.qty alloc_qty,alloc.qty_stk alloc_qty_stk,
														alloc.qty_linkto_alloctbl,alloc.trngantts_id  
														from #{srctblname} src 
														inner join alloctbls alloc on alloc.srctblid = src.id 
											where src.cno = '#{val}'
											and src.workplaces_id = #{@src_tbl[:workplaces_id]}
											and  alloc.srctblid = #{@src_tbl[:id]} and alloc.srctblname = '#{tblname}'
											and (alloc.qty_sch + alloc.qty + alloc.qty_stk) > alloc.qty_linkto_alloctbl
											order by alloc.allocfree,alloc.id
								& 
							when /^pur/
								link_strsql = %Q&
									select src.*,link.qty_src,link.trngantts_id from #{srctblname} src 										  
											inner join linktbls link on link.srctblid = src.id
											where src.cno = '#{val}' and link["srctblname"] = '#{srctblname}'
											and src.suppliers_id = #{@src_tbl[:suppliers_id]}
											and  link.tblid = #{@src_tbl[:id]} and link.tblname = '#{tblname}'
											order by link.trngantts_id
								& 
								sql_get_prev_alloc = %Q&
									select src.*,alloc.qty_sch alloc_qty_sch,alloc.qty alloc_qty,alloc.qty_stk alloc_qty_stk,
														alloc.qty_linkto_alloctbl,alloc.trngantts_id  
														from #{srctblname} src 
														inner join alloctbls alloc on alloc.srctblid = src.id 
											where src.cno = '#{val}'
											and src.suppliers_id = #{@src_tbl[:suppliers_id]}
											and  alloc.srctblid = #{@src_tbl[:id]} and alloc.srctblname = '#{tblname}'
											and (alloc.qty_sch + alloc.qty + alloc.qty_stk) > alloc.qty_linkto_alloctbl
											order by alloc.allocfree,alloc.id
								& 
							when /^cust/
								link_strsql = %Q&
									select src.*,link.qty_src,link.trngantts_id from #{srctblname} src 										  
											inner join linktbls link on link.srctblid = src.id 
											where src.cno = '#{val}' and link["srctblname"] = '#{srctblname}'
											and src.custs_id = #{@src_tbl[:custs_id]}
											and  link.tblid = #{@src_tbl[:id]} and link.tblname = '#{tblname}'
											order by link.trngantts_id
								& 
								sql_get_prev_alloc = %Q&
									select src.*,alloc.qty_sch alloc_qty_sch,alloc.qty alloc_qty,alloc.qty_stk alloc_qty_stk,
														alloc.qty_linkto_alloctbl,alloc.trngantts_id  
														from #{srctblname} src 
														inner join alloctbls alloc on alloc.srctblid = src.id  
											where src.cno = '#{val}'
											and src.custs_id = #{@src_tbl[:custs_id]}
											and  alloc.srctblid = #{@src_tbl[:id]} and alloc.srctblname = '#{tblname}'
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
											and src.opeitms_id = #{@src_tbl[:opeitms_id]}
											and src.shelfnos_id_to = #{@src_tbl[:shelfnos_id_to]}
											and src.shelfnos_id_fm = #{@src_tbl[:shelfnos_id_fm]}
											and  link.tblid = #{@src_tbl[:id]} and link.tblname = '#{tblname}'
											order by link.trngantts_id
								& 
								sql_get_prev_alloc = %Q&
									select src.*,alloc.qty_sch alloc_qty_sch,alloc.qty alloc_qty,alloc.qty_stk alloc_qty_stk,
														alloc.qty_linkto_alloctbl,alloc.trngantts_id  
														from #{srctblname} src 
														inner join alloctbls alloc on alloc.srctblid = src.id 
											where src.gno = '#{val}' and link["srctblname"] = '#{srctblname}'
											and src.opeitms_id = #{@src_tbl[:opeitms_id]}
											and src.shelfnos_id_to = #{@src_tbl[:shelfnos_id_to]}
											and src.shelfnos_id_fm = #{@src_tbl[:shelfnos_id_fm]}
											and  alloc.srctblid = #{@src_tbl[:id]} and alloc.srctblname = '#{tblname}'
											and (alloc.qty_sch + alloc.qty + alloc.qty_stk) > alloc.qty_linkto_alloctbl
											order by alloc.allocfree,alloc.id
								& 
							when /^pur/
								link_strsql = %Q&
									select src.*,link.qty_src,link.trngantts_id from #{srctblname} src 										  
											inner join linktbls link on link.srctblid = src.id
											where src.gno = '#{val}' and link["srctblname"] = '#{srctblname}'
											and src.opeitms_id = #{@src_tbl[:opeitms_id]}
											and src.shelfnos_id_to = #{@src_tbl[:shelfnos_id_to]}
											and src.shelfnos_id_fm = #{@src_tbl[:shelfnos_id_fm]}
											and  link.tblid = #{@src_tbl[:id]} and link.tblname = '#{tblname}'
											order by link.trngantts_id
								& 
								sql_get_prev_alloc = %Q&
									select src.*,alloc.qty_sch alloc_qty_sch,alloc.qty alloc_qty,alloc.qty_stk alloc_qty_stk,
														alloc.qty_linkto_alloctbl,alloc.trngantts_id  
														from #{srctblname} src 
														inner join alloctbls alloc on alloc.srctblid = src.id 
											where src.gno = '#{val}'
											and src.opeitms_id = #{@src_tbl[:opeitms_id]}
											and src.shelfnos_id_to = #{@src_tbl[:shelfnos_id_to]}
											and src.shelfnos_id_fm = #{@src_tbl[:shelfnos_id_fm]}
											and  alloc.srctblid = #{@src_tbl[:id]} and alloc.srctblname = '#{tblname}'
											and (alloc.qty_sch + alloc.qty + alloc.qty_stk) > alloc.qty_linkto_alloctbl
											order by alloc.allocfree,alloc.id
								& 
							when /^cust/
								link_strsql = %Q&
									select src.*,link.qty_src,link.trngantts_id from #{srctblname} src 										  
											inner join linktbls link on link.srctblid = src.id
											where src.gno = '#{val}' and link["srctblname"] = '#{srctblname}'
											and src.opeitms_id = #{@src_tbl[:opeitms_id]}
											and src.custrcvplcs_id = #{@src_tbl[:custrcvplcs_id]}
											and  link.tblid = #{@src_tbl[:id]} and link.tblname = '#{tblname}'
											order by link.trngantts_id
								&
								sql_get_prev_alloc = %Q&
									select src.*,alloc.qty_sch alloc_qty_sch,alloc.qty alloc_qty,alloc.qty_stk alloc_qty_stk,
														alloc.qty_linkto_alloctbl,alloc.trngantts_id  
														from #{srctblname} src 
														inner join alloctbls alloc on alloc.srctblid = src.id 
											where src.gno = '#{val}'
											and src.opeitms_id = #{@src_tbl[:opeitms_id]}
											and src.custrcvplcs_id = #{@src_tbl[:custrcvplcs_id]}
											and  alloc.srctblid = #{@src_tbl[:id]} and alloc.srctblname = '#{tblname}'
											and (alloc.qty_sch + alloc.qty + alloc.qty_stk) > alloc.qty_linkto_alloctbl
											order by alloc.allocfree,alloc.id
								&
							end
					end	
				end
			end
		end
		return link_strsql,sql_get_prev_alloc
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

	def add_update_alloc_add_link(prev_alloc,gantt)  ###前の状態から現状への変更
		src = {"trngantts_id" => prev_alloc["trngantts_id"],"tblname" => prev_alloc["srctblname"],
				"tblid" => prev_alloc["srctblid"]}
		base = {"tblname" => gantt["tblname"] ,
				"tblid" => gantt["tblid"],
				"qty_src" =>gantt["qty_sch"].to_f + gantt["qty"].to_f + gantt["qty_stk"].to_f }
		###
		ArelCtl.proc_insert_linktbls(src,base)
		###
		strsql = %Q&
				update alloctbls set qty_linkto_alloctbl = qty_linkto_alloctbl + #{base["qty_src"]},
								remark = 'ror_blktbl(#{__LINE__})'
								where id = #{prev_alloc["id"]} 
		&
		ActiveRecord::Base.connection.update(strsql)

		src = {"trngantts_id" => prev_alloc["trngantts_id"],"tblname" => gantt["tblname"] ,
				"tblid" => gantt["tblid"],"allocfree" => "alloc",
				"qty_sch" => gantt["qty_sch"],"qty" => gantt["qty"] ,"qty_stk" => gantt["qty_stk"],
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
        tblname = command_c[:sio_viewname].split("_")[1]
          command_init[(tblname.chop + "_id")] =  command_c["id"] = @src_tbl[:id]
		###画面専用項目
		command_c.each do |key,val|
			next if key.to_s =~ /gridmessage/
			next if key.to_s =~ /^_/
			next if key.to_s == "confirm"
			next if key.to_s == "aud"
			rec[key] = val
		end	
		tbl_add_arel  "SIO_#{command_c[:sio_viewname]}",rec
	end   ## 
		
   ## proc_strwhere


	def proc_create_src_tbl(command_c) ##
		tblnamechop = command_c[:sio_viewname].split("_",2)[1].chop
		if command_c[:sio_classname] =~ /_add_/ or command_c["id"] == "" or command_c["id"].nil?
			@src_tbl[:created_at] =  command_c["#{tblnamechop}_created_at"] = Time.now
			if  command_c["id"] == "" or command_c["id"].nil?
				command_c["id"] = @src_tbl[:id] = ArelCtl.proc_get_nextval("#{tblnamechop}s_seq")
				command_c[tblnamechop+"_id"] = command_c["id"] 
			else
				@src_tbl[:id] = command_c["id"]  ###fields_updateでセット済
			end
		else
			@src_tbl[:id] =	command_c["id"]	
		end	
        command_c.each do |j,k|
        	j_to_stbl,j_to_sfld = j.to_s.split("_",2)
			if  j_to_stbl == tblnamechop  and j_to_sfld !~ /_gridmessage/ and j_to_sfld != "id" and
					j_to_sfld != "code_upd" and  j_to_sfld != "name_upd"   and  j_to_sfld != "id_upd"##本体の更新
			    if  k
	            	@src_tbl[j_to_sfld.sub("_id","s_id").to_sym] = k
					@src_tbl[j_to_sfld.to_sym] = nil  if k  == "\#{nil}"  ##
					if k == ""
						case 	  j_to_sfld
						when 'sno'
							command_c[tblnamechop+"_sno"] = @src_tbl[:sno] = ControlFields.proc_field_sno(tblnamechop,command_c["id"])
						when 'cno'
							command_c[tblnamechop+"_cno"] = @src_tbl[:cno] = ControlFields.proc_field_cno(command_c["id"])
						when 'gno'
							command_c[tblnamechop+"_gno"] = @src_tbl[:gno] = ControlFields.proc_field_gno(command_c["id"])
						end
					else
					end
				end
            end   ## if j_to_s.
		end ## command_c.each
        @src_tbl[:persons_id_upd] = command_c["#{tblnamechop}_person_id_upd"] = (@sio_user_id||=0) ###performでの処理では@sio_user_ide=nil
		@src_tbl[:updated_at] = command_c["#{tblnamechop}_updated_at"] = Time.now
	end

    def undefined
    	nil
    end

	def tbl_add_arel  tblname,tblarel ##
		fields = ""
		values = ""  ###insert into(....) value(xxx)のxxx
		tblarel.each do |key,val|
			fields << key.to_s + ","
			# strsql = %Q&select fieldcode_ftype from r_fieldcodes
			# 			where  pobject_code_fld = '#{if tblname.downcase =~ /^sio|^bk/ then key.to_s.split("_",2)[1] else key.to_s end}'&
			# ftype = ActiveRecord::Base.connection.select_value(strsql)
			key = if tblname.downcase =~ /^sio|^bk/ then key.to_s.split("_",2)[1] else key.to_s end
			ftype = $ftype[key]
			 	values << 	case ftype
			 			when /char/  ###db type
			 				%Q&'#{(val||="").gsub("'","''")}',&
			 			when "numeric"
			 				"#{(val||="").to_s.gsub(",","")},"
						when /timestamp|date/  ##db type
							case (val||="").class.to_s  ### ruby type
							when  /Time|Data/
								case key.to_s
			 					when "created_at","updated_at"
			 						%Q& to_timestamp('#{val.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),&
								when "expiredate"
									%Q& to_date('#{val.strftime("%Y/%m/%d")}','yyyy/mm/dd'),&
			 					else
									%Q& to_timestamp('#{val.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),&
								end
							when "String"	 
								case key.to_s
			 					when "created_at","updated_at"
			 						%Q& to_timestamp('#{val.gsub("-","/")}','yyyy/mm/dd hh24:mi:ss'),&
								when "expiredate"
									%Q& to_date('#{val.gsub("-","/")}','yyyy/mm/dd'),&
			 					else
									%Q& to_timestamp('#{val.gsub("-","/")}','yyyy/mm/dd hh24:mi:ss'),&
								end
							else
							   Rails.logger.debug " line #{__LINE__} : error val.class #{ftype}  key #{key.to_s} "
							   p " line #{__LINE__} : error val.class #{ftype}  key #{key.to_s} "
							end	
						else
							if tblname.downcase =~ /^sio_|^bk_/
								%Q&'#{val.to_s.gsub("'","''")}',&
							else
								Rails.logger.debug " line #{__LINE__} : error val.class #{ftype}  key #{key.to_s} "
								p " line #{__LINE__} : error val.class #{ftype}  key #{key.to_s} "
							end	
			 			end
		end
		case tblname.downcase
		when  /^sio_/
			ActiveRecord::Base.connection.insert("insert into sio.#{tblname.downcase}(#{fields.chop}) values(#{values.chop})")
		when  /^bk_/
			ActiveRecord::Base.connection.insert("insert into bk.#{tblname.downcase}(#{fields.chop}) values(#{values.chop})")
		else
			ActiveRecord::Base.connection.insert("insert into #{tblname.downcase}(#{fields.chop}) values(#{values.chop})")
		end
	end

	def tbl_edit_arel  tblname,hash,strwhere ##
		strset = ""
		strset = ""
		hash.each do |key,val|
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
			   when  /Time|Data/
				   case key.to_s
					when "created_at","updated_at"
						%Q& #{key.to_s} =  to_timestamp('#{val.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),&
				   when "expiredate"
					   %Q&  #{key.to_s} = to_date('#{val.strftime("%Y/%m/%d")}','yyyy/mm/dd'),&
					else
						%Q&  #{key.to_s} = to_timestamp('#{val.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),&
				   end
			   when "String"	 
				   case key.to_s
					when "created_at","updated_at"
						%Q&  #{key.to_s} = to_timestamp('#{val.gsub("-","/")}','yyyy/mm/dd hh24:mi:ss'),&
				   	when "expiredate"
					   %Q&  #{key.to_s} = to_date('#{val.gsub("-","/")}','yyyy/mm/dd'),&
					else
						%Q&  #{key.to_s} = to_timestamp('#{val.gsub("-","/")}','yyyy/mm/dd hh24:mi:ss'),&
				   end
			   else
				  Rails.logger.debug " line #{__LINE__} : error val.class #{ftype}  key #{key.to_s} "
				  p " line #{__LINE__} : error val.class #{ftype}  key #{key.to_s} "
			   end	
			else
				if tblname.downcase =~ /^sio_|^bk_/
					%Q& #{key.to_s} = '#{val.to_s.gsub("'","''")}',&
				else
					Rails.logger.debug " line #{__LINE__} : error val.class #{ftype}  key #{key.to_s} "
					p " line #{__LINE__} : error val.class #{ftype}  key #{key.to_s} "
				end	
			end
		end
		ActiveRecord::Base.connection.update("update #{tblname}  set #{strset.chop} where #{strwhere} ")
	end

	def tbl_delete_arel  tblname,strwhere ##
		ActiveRecord::Base.connection.delete("delete from  #{tblname}  where #{strwhere} ")
	end
	    end
end   ##module Ror_blk
