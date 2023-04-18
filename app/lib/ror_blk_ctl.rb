
# -*- coding: utf-8 -*-
# RorBlkCtl
# 2099/12/31を修正する時は　2100/01/01の修正も
module RorBlkCtl
	extend self
	class BlkClass
		def initialize(screenCode)
			@screenCode = screenCode
			@tblname = screenCode.split("_")[1]
		    @command_init = {}
		    strsql = "select pobject_code_view from r_screens where pobject_code_scr = '#{@screenCode}' and screen_expiredate > current_date"
		    @command_init["sio_viewname"] =  ActiveRecord::Base.connection.select_value(strsql)
		    @command_init["sio_code"] =  @screenCode
		    @command_init["sio_message_contents"] = nil
		    @command_init["sio_recordcount"] = 1
		    @command_init["sio_result_f"] =   "0"  
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

		def proc_create_tbldata(command_c) ##
			if command_c["sio_classname"] =~ /_add_|_insert_/ or command_c["id"] == "" or command_c["id"].nil?
				@tbldata["created_at"] =  command_c["#{@tblname.chop}_created_at"] = Time.now
				if  command_c["id"] == "" or command_c["id"].nil?
					command_c["id"] = ArelCtl.proc_get_nextval("#{@tblname}_seq")
					command_c[@tblname.chop+"_id"] = @tbldata["id"] = command_c["id"] 
				else
					@tbldata["id"] = command_c["id"]  ###fields_updateでセット済
				end
			else
				@tbldata["id"] = command_c["id"]	
			end	
        	command_c.each do |j,k|
        		j_to_stbl,j_to_sfld = j.to_s.split("_",2)
				if  j_to_stbl == @tblname.chop  and j_to_sfld !~ /_gridmessage/ and j_to_sfld != "id" and
					j_to_sfld != "code_upd" and  j_to_sfld != "name_upd"   and  j_to_sfld != "id_upd"##本体の更新
			    	if  k
	            		@tbldata[j_to_sfld.sub("_id","s_id")] = k
						@tbldata[j_to_sfld] = nil  if k  == "\#{nil}"  ##
						if k == ""  or k.nil?
							case 	  j_to_sfld
							when 'sno'
								isudate = command_c["#{@tblname.chop}_isudate"]
								command_c[@tblname.chop+"_sno"] = @tbldata["sno"] = CtlFields.proc_field_sno(@tblname.chop,isudate,command_c["id"])
							when 'cno'
								command_c[@tblname.chop+"_cno"] = @tbldata["cno"] = CtlFields.proc_field_cno(command_c["id"])
							when 'gno'
								command_c[@tblname.chop+"_gno"] = @tbldata["gno"] = CtlFields.proc_field_gno(@tblname.chop,command_c["id"])
							end
						else
						end
					else
					end
            	end   ## if j_to_s.
			end ## command_c.each
        	@tbldata["persons_id_upd"] = command_c["#{@tblname.chop}_person_id_upd"] = $person_id_upd ###
			@tbldata["updated_at"] = command_c["#{@tblname.chop}_updated_at"] = Time.now
			return command_c
		end

		def proc_add_update_table(params,command_c)  
			begin
				ActiveRecord::Base.connection.begin_db_transaction()
				params["status"] = 200
				params = proc_private_aud_rec(params,command_c) 
			rescue
        		ActiveRecord::Base.connection.rollback_db_transaction()
				params["status"] = 500
            	command_c["sio_result_f"] = "9"  ##9:error
            	command_c["sio_message_contents"] =  "class #{self} : LINE #{__LINE__} $!: #{$!} "[0..3999]    ###evar not defined
            	command_c["sio_errline"] =  "class #{self} : LINE #{__LINE__} $@: #{$@} "[0..3999]
            	Rails.logger.debug"error class #{self} : #{Time.now}: #{$@} "
          		Rails.logger.debug"error class #{self} : $!: #{$!} "
          		Rails.logger.debug"  command_c: #{command_c} " 
      		else
				ActiveRecord::Base.connection.commit_db_transaction()
				if params["seqno"].size > 0
					if command_c["mkord_runtime"] 
						CreateOtherTableRecordJob.set(wait: command_c["mkord_runtime"].to_f.hours).perform_later(params["seqno"][0])
					else	
						CreateOtherTableRecordJob.perform_later(params["seqno"][0])
					end
				end
      		ensure
	  		end ##begin
        	return params,command_c
		end

		def proc_private_aud_rec(params,command_c)   ###commitなし
			tmp_key = {}
        	setParams = params.dup
			case command_c["sio_classname"]
			when /_add_|_insert_/
				tbl_add_arel(@tblname,@tbldata) ###sioXXXX,tbldata
			when /_edit_|_update_/
				tbl_edit_arel(" id = #{@tbldata["id"]}")
			when  /_delete_|_purge_/
				if @tblname =~ /schs$|ords$|insts$|dlvs$|acts$|inputs$/ and   @tblname !~ /^shp/ ##削除なし
					@tbldata["qty_sch"] = 0 if @tbldata["qty_sch"]
					@tbldata["qty"] = 0 if @tbldata["qty"]
					@tbldata["qty_stk"] = 0 if @tbldata["qty_stk"]
					@tbldata["amt"] = 0 if @tbldata["amt"]
					@tbldata["amt_sch"] = 0 if @tbldata["amt_sch"]
					@tbldata["cash"] = 0 if @tbldata["cash"]
					@tbldata["tax"] = 0 if @tbldata["tax"]      ##変更分のみ更新
					tbl_edit_arel(" id = #{@tbldata["id"]}")
				else
					tbl_delete_arel(" id = #{@tbldata["id"]}")
				end
			else
				Rails.logger.debug"error "
				Rails.logger.debug"error RorBlkCtl.proc_private_aud_rec /n"
				Rails.logger.debug"error command_c: #{command_c} "
				ActiveRecord::Base.connection.rollback_db_transaction()
				raise
			end	
        	###
        	proc_insert_sio_r(command_c)   ###sioxxxxの追加
        	###
			setParams["tbldata"] = @tbldata.dup
        	command_c.select do |key,val|
				if key.to_s =~ /_autocreate/
					if (JSON.parse(val) rescue nil)
						setParams["segment"] = "createtable"
						setParams["remark"] = " RorBlkCtl.lib line:#{__LINE__}"
						if setParams["where_str"]
							setParams["where_str"] = setParams["where_str"].gsub("'","#!")
						end
						processreqs_id ,setParams = ArelCtl.proc_processreqs_add(setParams)
					end
				end
			end

			setParams["seqno"] ||= []
			setParams["child"] ||= {}
			if @tbldata["opeitms_id"]
				opeitm = ActiveRecord::Base.connection.select_one("select * from opeitms where id = #{@tbldata["opeitms_id"]}")
				opeitm["locas_id_opeitm"] = ActiveRecord::Base.connection.select_value(%Q%
														select locas_id_shelfno from shelfnos where id = #{opeitm["shelfnos_id_opeitm"]} %)
				opeitm["locas_id_to_opeitm"] = ActiveRecord::Base.connection.select_value(%Q%
														select locas_id_shelfno from shelfnos where id = #{opeitm["shelfnos_id_to_opeitm"]} %)
			else
				opeitm = {}
			end
			setParams["opeitm"] = opeitm.dup
			setParams["classname"] = command_c["sio_classname"]
			mkprdpurords_id = setParams["mkprdpurords_id"] 
			gantt = setGantt(setParams)

			case  @tblname
			when /^bill|^pay/
				account = setAccount(setParams)
				setParams["account"] = account
				return setParams
			when /mkprdpurords/
				setParams["segment"] = "mkprdpurords"
				setParams["gantt"] = gantt.dup
				setParams["mkprdpurords_id"] = @tbldata["id"]
				setParams["remark"] = " RorBlkCtl.lib.proc_private_aud_rec"
				processreqs_id ,setParams = ArelCtl.proc_processreqs_add(setParams)		
				return setParams
			when /mkbillinsts/
				setParams["segment"] = "mkbillinsts"
				setParams["mkbillinsts_id"] = @tbldata["id"]
				setParams["remark"] = " RorBlkCtl.lib.proc_private_aud_rec"
				processreqs_id ,setParams = ArelCtl.proc_processreqs_add(setParams)	
				return setParams
			when /^prdschs|^purschs/
				if setParams["gantt"]
				else
					gantt["qty_sch"] = @tbldata["qty_sch"]
					gantt["qty_handover"] = @tbldata["qty_sch"] 
					gantt["starttime_trn"] = (@tbldata["duedate"].to_time - opeitm["duration"].to_f*60*60*24).strftime("%Y-%m-%d %H:%M:%S") 
					###作業場所の稼働日考慮要
					gantt["locas_id_trn"] = gantt["locas_id_pare"] = gantt["locas_id_org"]  = command_c["shelfno_loca_id_shelfno"]
					gantt["shelfnos_id_trn"] = gantt["shelfnos_id_pare"] = @tbldata["shelfnos_id"]
					gantt["shelfnos_id_to_trn"] = gantt["shelfnos_id_to_pare"] = @tbldata["shelfnos_id_to"]
				end
			when /^prdords/
				gantt["qty"] =  @tbldata["qty"]  ###free
				gantt["qty_require"] = 0
				gantt["qty_handover"] = @tbldata["qty"] ###下位部品所要量計算用
				gantt["starttime_trn"] = @tbldata["starttime"] 
				gantt["locas_id_trn"] = gantt["locas_id_pare"] = gantt["locas_id_org"] = command_c["shelfno_loca_id_shelfno"]
				gantt["shelfnos_id_trn"] = gantt["shelfnos_id_pare"] = @tbldata["shelfnos_id"]
				gantt["shelfnos_id_to_trn"] = gantt["shelfnos_id_to_pare"] = @tbldata["shelfnos_id_to"]
			when /^prdinsts/  ###insts,actsでは trnganttsは作成しない。
			when /^prdacts/
			when /^purords/
				gantt["qty"] =  @tbldata["qty"]   ###free
				gantt["qty_require"] = 0
				gantt["qty_handover"] = @tbldata["qty"] ###下位部品所要量計算用
				gantt["starttime_trn"] = @tbldata["starttime"] 
				gantt["locas_id_trn"] = gantt["locas_id_pare"] = gantt["locas_id_org"] =  command_c["shelfno_loca_id_shelfno"]
				gantt["shelfnos_id_trn"] = gantt["shelfnos_id_pare"] = @tbldata["shelfnos_id"]
				gantt["shelfnos_id_to_trn"] = gantt["shelfnos_id_to_pare"] = @tbldata["shelfnos_id_to"]
			when /^replyinputs/
			when /^purinsts/
				# gantt = setGantt(setParams)
				# gantt["qty"] =  @tbldata["qty"]
			when /^purdlvs/
				# gantt = setGantt(setParams)
				# gantt["qty_stk"] = @tbldata["qty_stk"]
			when /^puracts/
			when /^custschs/  ### setParams["gantt"].nil?==trueのはず
				gantt["qty_sch"] = @tbldata["qty_sch"]
				gantt["qty_handover"] = @tbldata["qty_sch"] ###下位部品所要量計算用
				gantt["qty"] = 0
				gantt["starttime_trn"] = @tbldata["starttime"] = (@tbldata["duedate"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S") 
				gantt["locas_id_trn"] = gantt["locas_id_pare"] = gantt["locas_id_org"] = command_c["cust_loca_id_cust"]
				gantt["shelfnos_id_trn"] = gantt["shelfnos_id_pare"] = 0 ###custschs,custords用dummy id
				gantt["shelfnos_id_to_trn"] =  gantt["shelfnos_id_to_pare"] = 0 
			when /^custords/  ### setParams["gantt"].nil?==trueのはず
				###下位部品所要量計算用
				###自身のschsからordsへの変換用
				gantt["qty"] =  gantt["qty_handover"] = gantt["qty_require"] = @tbldata["qty"]
				gantt["qty_sch"] = 0
				gantt["starttime_trn"] = @tbldata["starttime"] = (@tbldata["duedate"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S")
				gantt["locas_id_trn"] = gantt["locas_id_pare"] = gantt["locas_id_org"] =  command_c["cust_loca_id_cust"] ###
				gantt["shelfnos_id_trn"] = gantt["shelfnos_id_pare"] = 0 ###custschs,custords用dummy id
				gantt["shelfnos_id_to_trn"] =  gantt["shelfnos_id_to_pare"] = 0 
			when /acts$/
				# gantt = setGantt(setParams)
				# gantt["qty_stk"] = @tbldata["qty_stk"]
			when /^cust/ ###custschs,custords以外
				# gantt = setGantt(setParams)
			end
		
			setParams["gantt"] = gantt.dup
			if @tblname =~ /^prd|^pur/ and @tblname =~ /insts$|replyinputs$|dlvs$|acts$/  ##schsとordsは除く  
				###ordsの変更はoperation
				src_qty = @tbldata["qty"].to_f + @tbldata["qty_stk"].to_f
				link_strsql,sql_get_src_alloc = get_src_tbl()
				if link_strsql != "" and command_c["sio_classname"] =~ /_edit_|_update_|_delete_|_purge_/
					save_trngantts_id = ""
					ActiveRecord::Base.connection.select_all(link_strsql).each do |link|
						if src_qty > link["qty_src"].to_f
							src_qty -= link["qty_src"].to_f
						else
							###linktbls,alloctblsの更新のみ。在庫とtrnganttsの変更はArelCtl.proc_src_base_trn_stk_update
							update_alloctbls_linktbl(link,src_qty)  
							src_qty = 0
							save_trngantts_id = link["trngantts_id"] if save_trngantts_id == ""
						end
					end
				else   ###新規 prd,pur /insts$|replyinputs$|dlvs$|acts$/ 
					###linktbls,alloctblsの更新のみ。在庫とtrnganttsの変更はArelCtl.proc_src_base_trn_stk_update
					if sql_get_src_alloc != "" and command_c["sio_classname"] =~  /_add_|_insert_/
						src_qty = @tbldata["qty"].to_f + @tbldata["qty_stk"].to_f  ### @tbldata["qty"], @tbldata["qty_stk"]どちらかはnil(nil.to_f=>0)
						###ここでは引当済をセットするのみ
						linktbl_ids = []
						ActiveRecord::Base.connection.select_all(sql_get_src_alloc).each do |src|
							if src_qty >= src["qty_linkto_alloctbl"].to_f
								alloc_qty = src["qty_linkto_alloctbl"].to_f
								src_qty -= src["qty_linkto_alloctbl"].to_f
							else
								alloc_qty = src_qty
								src_qty = 0
							end
							base = {"tblname" => @tblname ,	"tblid" => @tbldata["id"],
										"qty_src" => alloc_qty ,"amt_src" => 0,	"trngantts_id" => src["trngantts_id"]}
							linktbl_ids  << ArelCtl.proc_insert_linktbls(src,base)
							strsql = %Q&
								update alloctbls set qty_linkto_alloctbl = qty_linkto_alloctbl - #{alloc_qty},
										remark = '#{self}.add_update_alloc_add_link line:(#{__LINE__})'
									where id = #{src["alloc_id"]} 
								&
							ActiveRecord::Base.connection.update(strsql)

							alloc = {"srctblname" => @tblname ,	"srctblid" => @tbldata["id"],
										"qty_linkto_alloctbl" => alloc_qty ,"trngantts_id" => src["trngantts_id"]}
							ArelCtl.proc_insert_alloctbls(alloc)
							break if src_qty <= 0
						end
						setParams["linktbl_ids"] = linktbl_ids.dup
						setParams["segment"]  = "link_lotstkhists_update"   ### alloctbl inoutlotstksも作成
						processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
					end
				end
			end

			
			if @tblname =~ /^cust/ and @tblname =~ /insts$|dlvs$|acts$/  ##schsとordsは除く  
				###ordsの変更はoperation
				src_qty = @tbldata["qty"].to_f + @tbldata["qty_stk"].to_f
				if command_c["sio_classname"] =~ /_edit_|_update_|_delete_|_purge_/
					save_trngantts_id = ""
					link_strsql = %Q&
								select * from linkcusts where tblname = '#{@tblname}' and tblid = #{@tblid}
					&
					ActiveRecord::Base.connection.select_all(link_strsql).each do |link|
						if src_qty > link["qty_src"].to_f
							src_qty -= link["qty_src"].to_f
						else
							###linkcusts,の更新のみ。在庫とtrnganttsの変更はArelCtl.proc_src_base_trn_stk_update
							strsql = %Q&
										update linkcusrs set qty_src = #{src_qty},remark = '#{self}.update_alloctbls_linktbl line:(#{__LINE__})',
												updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss')
												where id = #{link["id"]}
								&
							ActiveRecord::Base.connection.update(strsql)
							src_qty = 0
							save_trngantts_id = link["trngantts_id"] if save_trngantts_id == ""
						end
					end
				else   ###新規 prd,pur /insts$|replyinputs$|dlvs$|acts$/ 
					###linkcustsの更新のみ。在庫の変更はlink_lotstkhists_update
					if command_c["sio_classname"] =~  /_add_|_insert_/
						qty = @tbldata["qty"].to_f + @tbldata["qty_stk"].to_f  ### @tbldata["qty"], @tbldata["qty_stk"]どちらかはnil(nil.to_f=>0)
						case screenCode
						when "fmcustord_custinsts","r_custinsts"  ###custinsts作成時は追加が必要
							link_strsql = %Q&
									select src.*,link.qty_src,link.trngantts_id,link.srctblname ,link.srctblid,link.tblname,link.tblid,link.id link_id  from custords src 
													inner join linkcusts link on link.tblid = src.id 
													where src.sno = '#{@tbldata["sno_custord"]}' and link.tblname = 'custords'
													order by link.trngantts_id
							&
						when "fmcustinst_custdlvs","r_custdlvs" 
							link_strsql = %Q&
									select src.*,link.qty_src,link.trngantts_id,link.srctblname ,link.srctblid,link.tblname,link.tblid,link.id link_id  from custinsts src 
													inner join linkcusts link on link.tblid = src.id 
													where src.sno = '#{@tbldata["sno_custinst"]}' and link.tblname = 'custinsts'
													order by link.trngantts_id
							&
						when "r_custacts" 
							if @tbldata["sno_custord"] and @tbldata["sno_custord"] != ""
								link_strsql = %Q&
									select src.*,link.qty_src,link.trngantts_id,link.srctblname ,link.srctblid,link.tblname,link.tblid,link.id link_id  
													from custords src 
													inner join linkcusts link on link.tblid = src.id 
													where src.sno = '#{@tbldata["sno_custord"]}' and link.tblname = 'custords'
													order by link.trngantts_id
								&
							else
								if @tbldata["cno_custord"] and @tbldata["cno_custord"] != ""
									link_strsql = %Q&
										select src.*,link.qty_src,link.trngantts_id,link.srctblname ,link.srctblid,link.tblname,link.tblid,link.id link_id  
														from custords src 
														inner join linkcusts link on link.tblid = src.id 
														where src.sno = '#{@tbldata["cno_custord"]}' and link.tblname = 'custords'
														and src.custs_id = #{@tbldata["custs_id"]}
														order by link.trngantts_id
									&
								else
									if @tbldata["sno_custdlv"] and @tbldata["cno_custdlv"] != ""
										link_strsql = %Q&
											select src.*,link.qty_src,link.trngantts_id,link.srctblname ,link.srctblid,link.tblname,link.tblid,link.id link_id  
															from custdlvs src 
															inner join linkcusts link on link.tblid = src.id 
															where src.sno = '#{@tbldata["sno_custdlv"]}' and link.tblname = 'custdlvs'
															order by link.trngantts_id
										&
									end
								end
							end
						end
							###ここでは引当済をセットするのみ
						linktbl_ids = []
						ActiveRecord::Base.connection.select_all(link_strsql).each do |src|
							if qty >= src["qty_src"].to_f
								qty -= src["qty_src"].to_f
								qty_src = src["qty_src"].to_f
								src["qty_src"] = 0
							else
								qty_src = qty
								src["qty_src"] = src["qty_src"].to_f - qty
								qty = 0
							end
							base = {"tblname" => @tblname ,	"tblid" => @tbldata["id"],
										"qty_src" => qty_src ,"amt_src" => 0,	"trngantts_id" => src["trngantts_id"]}
							linktbl_ids  << ArelCtl.proc_insert_linkcusts(src,base)
							update_strsql = %Q&
									update  linkcusts link set qty_src = #{src["qty_src"]},	remark = '#{self} line:#{__LINE__}'
													where id  = '#{src["link_id"]}'
							&
							ActiveRecord::Base.connection.update(update_strsql)
							break if qty <= 0
						end
						###if @tblname =~ /dlvs$|acts$/  
							setParams["linktbl_ids"] = linktbl_ids.dup
							setParams["segment"]  = "link_lotstkhists_update"   ### alloctbl inoutlotstksも作成
							processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
						###end
					end
				end
			end

			if @tblname =~ /^prd|^pur|^cust/ 
				setParams["tbldata"] = @tbldata.dup	###変更されているため再セット
				case  @tblname
				when /schs$|^custords/
					# processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
                    ope = Operation::OpeClass.new(setParams)  ###xxxschs,xxxords
					setParams = ope.proc_trngantts()  ###xxxschs,xxxordsのtrngannts,linktbls,alloctblsを作成
					setParams["segment"]  = "link_lotstkhists_update"   ### alloctbl inoutlotstksも作成
					processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
				when /^prdords|^purords/
                    ope = Operation::OpeClass.new(setParams)  ###xxxschs,xxxords
					setParams = ope.proc_trngantts()  ###xxxschs,xxxordsのtrngannts,linktbls,alloctblsを作成
					if mkprdpurords_id == 0
						setParams["segment"]  = "link_lotstkhists_update"   ### alloctbl inoutlotstksも作成
						processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
					else
						###mkordinstの時はproc_mkprdpurordsで在庫管理
						### lotstkhists_idをxxxschsとxxxxordsのinoutotstksに引き継ぐため。
					end
					setParams["segment"]  = "mkShpschConord"  ### XXXXschs,ordsの時XXXschsを作成
					processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
				end
			end
			return setParams
		end

		def  setAccount(setParams)
			return setParams
		end

		def get_src_tbl
			srctblname = link_strsql = sql_get_src_alloc = ""
			@tbldata.each do |key,val|
				if val and key.to_s =~ /^sno_|^cno_|^gno_/
					if val.size > 0 
						srctblname = key.to_s.split("_")[1] + "s" 
						case key.to_s
						when  /^sno_/
							case srctblname
							when /^prd|^pur/
								link_strsql = %Q&
										select src.*,link.qty_src,link.trngantts_id,link.srctblname,link.srctblid,link.tblname,link.tblid  from #{srctblname} src 
															inner join linktbls link on link.srctblid = src.id 
															where src.sno = '#{val}' and link.srctblname = '#{srctblname}'
															and  link.tblid = #{@tbldata["id"]} and link.tblname = '#{@tblname}'
															order by link.trngantts_id
									&
								sql_get_src_alloc = %Q&
										select src.*,alloc.qty_linkto_alloctbl,alloc.trngantts_id,alloc.srctblname tblname,alloc.srctblid tblid,
											alloc.id alloc_id	from #{srctblname} src 
												inner join alloctbls alloc on alloc.srctblid = src.id 
											where src.sno = '#{val}' and  alloc.qty_linkto_alloctbl > 0
											order by alloc.allocfree,alloc.id  ---引き当て済分から次の状態に移行する。
											for update
									&
							end
						when  /^cno_/
							case srctblname
							when /^prd/
								link_strsql = %Q&
									select src.*,alloc.qty_linkto_alloctbl,alloc.trngantts_id 
														from #{srctblname} src 
														inner join alloctbls alloc on alloc.srctblid = src.id
											where src.cno = '#{val}' and link.srctblname = '#{srctblname}'
											and src.workplaces_id = #{@tbldata["workplaces_id"]}
											and  link.tblid = #{@tbldata["id"]} and link.tblname = '#{@tblname}'
											order by link.trngantts_id
								& 
								sql_get_src_alloc = %Q&
									select src.*,alloc.qty_linkto_alloctbl,alloc.trngantts_id,alloc.srctblname tblname,alloc.srctblid tblid  
														from #{srctblname} src 
														inner join alloctbls alloc on alloc.srctblid = src.id 
											where src.cno = '#{val}'
											and src.workplaces_id = #{@tbldata["workplaces_id"]}
											and  alloc.qty_linkto_alloctbl > 0
											order by alloc.allocfree,alloc.id
											for update
								& 
							when /^pur/
								link_strsql = %Q&
									select src.*,link.qty_src,link.trngantts_id,link.srctblname,link.srctblid,link.tblname,link.tblid  from #{srctblname} src 										  
											inner join linktbls link on link.srctblid = src.id
											where src.cno = '#{val}' and link.srctblname = '#{srctblname}'
											and src.suppliers_id = #{@tbldata["suppliers_id"]}
											and  link.tblid = #{@tbldata["id"]} and link.tblname = '#{@tblname}'
											order by link.trngantts_id
								& 
								sql_get_src_alloc = %Q&
									select src.*,alloc.qty_linkto_alloctbl,alloc.trngantts_id,alloc.srctblname tblname,alloc.srctblid tblid  
														from #{srctblname} src 
														inner join alloctbls alloc on alloc.srctblid = src.id 
											where src.cno = '#{val}'
											and src.suppliers_id = #{@tbldata["suppliers_id"]}
											and  alloc.qty_linkto_alloctbl > 0
											order by alloc.allocfree,alloc.id
											for update
								& 
							end	
						when  /^gno_/
							case srctblname
							when /^prd/
								link_strsql = %Q&
									select src.*,link.qty_src,link.trngantts_id,link.srctblname,link.srctblid,link.tblname,link.tblid from #{srctblname} src 										  
											inner join linktbls link on link.srctblid = src.id
											where src.gno = '#{val}' and link.srctblname = '#{srctblname}'
											and src.opeitms_id = #{@tbldata["opeitms_id"]}
											and src.shelfnos_id_to = #{@tbldata["shelfnos_id_to"]}
											and src.shelfnos_id = #{@tbldata["shelfnos_id"]}
											and  link.tblid = #{@tbldata["id"]} and link.tblname = '#{@tblname}'
											order by link.trngantts_id
								& 
								sql_get_src_alloc = %Q&
									select src.*,alloc.qty_linkto_alloctbl,alloc.trngantts_id,alloc.srctblname tblname,alloc.srctblid tblid  
														from #{srctblname} src 
														inner join alloctbls alloc on alloc.srctblid = src.id 
											where src.gno = '#{val}' and link.srctblname = '#{srctblname}'
											and src.opeitms_id = #{@tbldata["opeitms_id"]}
											and src.shelfnos_id_to = #{@tbldata["shelfnos_id_to"]}
											and src.shelfnos_id = #{@tbldata["shelfnos_id"]}
											and  alloc.qty_linkto_alloctbl > 0
											order by alloc.allocfree,alloc.id
											for update
								& 
							when /^pur/
								link_strsql = %Q&
									select src.*,link.qty_src,link.trngantts_id,link.srctblname,link.srctblid,link.tblname,link.tblid from #{srctblname} src 										  
											inner join linktbls link on link.srctblid = src.id
											where src.gno = '#{val}' and link.srctblname = '#{srctblname}'
											and src.opeitms_id = #{@tbldata["opeitms_id"]}
											and src.shelfnos_id_to = #{@tbldata["shelfnos_id_to"]}
											and src.shelfnos_id = #{@tbldata["shelfnos_id"]}
											and  link.tblid = #{@tbldata["id"]} and link.tblname = '#{@tblname}'
											order by link.trngantts_id
								& 
								sql_get_src_alloc = %Q&
									select src.*,alloc.qty_linkto_alloctbl,alloc.trngantts_id,alloc.srctblname tblname,alloc.srctblid tblid  
														from #{srctblname} src 
														inner join alloctbls alloc on alloc.srctblid = src.id 
											where src.gno = '#{val}'
											and src.opeitms_id = #{@tbldata["opeitms_id"]}
											and src.shelfnos_id_to = #{@tbldata["shelfnos_id_to"]}
											and src.shelfnos_id = #{@tbldata["shelfnos_id"]}
											and  alloc.qty_linkto_alloctbl > 0
											order by alloc.allocfree,alloc.id
											for update
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
				gantt["orgtblid"] = gantt["paretblid"] =  @tbldata["id"]	
				if @tblname =~ /schs$|ords$|lotstkhists/
					gantt["trngantts_id"] = ArelCtl.proc_get_nextval("trngantts_seq")
				else
					gantt["trngantts_id"] = 0
				end
				gantt["key"] = "00000"
				gantt["mlevel"] = 0
				gantt["parenum"] = gantt["chilnum"] = 1
				gantt["qty_pare"] = 0
				gantt["qty_stk_pare"] = 0
				gantt["shelfnos_id_to_trn"] =  @tbldata["shelfnos_id_to"]
				gantt["shelfnos_id_trn"] = @tbldata["shelfnos_id"]     
				gantt["chrgs_id_trn"] =  gantt["chrgs_id_pare"] =  gantt["chrgs_id_org"] =  @tbldata["chrgs_id"]
				gantt["prjnos_id"] = @tbldata["prjnos_id"]
				gantt["shuffle_flg"] = (opeitm["shuffle_flg"]||="0")
				gantt["itms_id_trn"] = gantt["itms_id_pare"]  = gantt["itms_id_org"]  = opeitm["itms_id"]
				gantt["processseq_trn"] = gantt["processseq_pare"]  = gantt["processseq_org"]  = opeitm["processseq"]
				gantt["qty_sch"] = gantt["qty"] = gantt["qty_stk"] = 0  ###下記のコーディングで対応
				gantt["duedate_trn"] = gantt["duedate_pare"] = gantt["duedate_org"] = @tbldata["duedate"]
				gantt["toduedate_trn"] = gantt["toduedate_pare"] = gantt["toduedate_org"] = (@tbldata["toduedate"]||=@tbldata["duedate"])
				gantt["starttime_trn"] = gantt["starttime_pare"] = gantt["starttime_org"] = @tbldata["starttime"]
				gantt["locas_id_pare"] = gantt["locas_id_org"] = gantt["locas_id_trn"] ###tbldataにlocas_idがない。
				gantt["consumunitqty"] = 1 ###消費単位
				gantt["consumminqty"]  = 0 ###最小消費数
				gantt["consumchgoverqty"] = 0  ###段取り消費数
				gantt["remark"] = " RorBlkCtl line:#{__LINE__} "
				gantt["qty_require"] = 0
		 	else
				gantt = setParams["gantt"].dup
			 	gantt["shuffle_flg"] = (opeitm["shuffle_flg"]||="0")
				####
			 	gantt["shelfnos_id_to_trn"] =  @tbldata["shelfnos_id_to"]
			 	gantt["shelfnos_id_trn"] =  @tbldata["shelfnos_id"]
			 	gantt["prjnos_id"] = @tbldata["prjnos_id"]
			 	gantt["chrgs_id_trn"] =  @tbldata["chrgs_id"]
			 	gantt["itms_id_trn"] = opeitm["itms_id"]
			 	gantt["processseq_trn"] = opeitm["processseq"]
			 	gantt["duedate_trn"] = @tbldata["duedate"]
			 	gantt["toduedate_trn"] = @tbldata["toduedate"]
			 	gantt["starttime_trn"] = @tbldata["starttime"]
			 	gantt["remark"] = " RorBlkCtl.setGantt line:#{__LINE__} "
			end
			gantt["tblname"] = @tblname
			gantt["tblid"] = tblid = @tbldata["id"]	
			return gantt
		end
	
		def update_alloctbls_linktbl(link,src_qty)
			strsql = %Q&
				update linktbls set qty_src = #{src_qty},remark = '#{self}.update_alloctbls_linktbl line:(#{__LINE__})',
								updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss')
								where id = #{link["id"]}
			&
			ActiveRecord::Base.connection.update(strsql)
			strsql = %Q&
				update alloctbls set qty_linkto_alloctbl = #{src_qty},remark = '#{self}.update_alloctbls_linktbl line:(#{__LINE__})',
								updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss')
								where srctblname = '#{link["srctblname"]}' and srctblid = #{link["srctblid"]}
								and trngantts_id = #{link["trngantts_id"]} 
			&
			ActiveRecord::Base.connection.update(strsql)
			strsql = %Q&
				update alloctbls set qty_linkto_alloctbl = qty_linkto_alloctbl  - #{src_qty},
								remark = '#{self}.update_alloctbls_linktbl line:(#{__LINE__})',
								updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss')
								where srctblname = '#{link["tblname"]}' and srctblid = #{link["tblid"]}
								and trngantts_id = #{link["trngantts_id"]} 
				&
			ActiveRecord::Base.connection.update(strsql)
		end

		def proc_insert_sio_r(command_c)  ####レスポンス
			rec = {}
        	rec["sio_id"] =  ArelCtl.proc_get_nextval("sio.SIO_#{command_c["sio_viewname"]}_SEQ")
        	rec["sio_command_response"] = "R"
			rec["sio_add_time"] = Time.now
        	rec["sio_result_f"] =  "1"   ## 1 normal end
        	rec["sio_message_contents"] = nil
          	command_init[(@tblname.chop + "_id")] =  command_c["id"] = @tbldata["id"]
			###画面専用項目は除く
			command_c.each do |key,val|
			next if key =~ /gridmessage/
			next if key =~ /^_/
			next if key == "confirm"
			next if key == "aud"
			next if key == "errPath"
			rec[key] = val
			end	
			tbl_add_arel  "SIO_#{command_c["sio_viewname"]}",rec
		end   ## 
		
   ## proc_strwhere

	   	def undefined
    		nil
    	end

		def tbl_add_arel  reqTblName,tblarel ##
			fields = ""
			values = ""  ###insert into(....) value(xxx)のxxx
			tblarel.each do |key,val|
				fields << key + ","
				# strsql = %Q&select fieldcode_ftype from r_fieldcodes
				# 			where  pobject_code_fld = '#{if tblname.downcase =~ /^sio|^bk/ then key.to_s.split("_",2)[1] else key.to_s end}'&
				# ftype = ActiveRecord::Base.connection.select_value(strsql)
				key = if reqTblName.downcase =~ /^sio|^bk/ then key.split("_",2)[1] else key end
				ftype = $ftype[key]
			 		values << 	case ftype
			 			when /char/  ###db type
			 				%Q&'#{(val||="").gsub("'","''")}',&
			 			when "numeric"
			 				"#{val.to_s.gsub(",","")},"   ###入力データはzzz0,zzz,zzz.zz,・・・であること
						when /timestamp|date/  ##db type
							case (val||="").class.to_s  ### ruby type
							when  /Time|Date/
								case key
								when "expiredate"  ###date type
									%Q& to_date('#{val.strftime("%Y/%m/%d")}','yyyy/mm/dd'),&
			 					else
									%Q& '#{val}',&
								end
							when "String"	 
								case key
			 					when "created_at","updated_at"
			 						%Q& to_timestamp('#{val.gsub("-","/")}','yyyy/mm/dd hh24:mi:ss'),&
								when "expiredate"
									%Q& to_date('#{val.gsub("-","/")}','yyyy/mm/dd'),&
			 					else
									%Q& to_timestamp('#{val.gsub("-","/")}','yyyy/mm/dd hh24:mi'),&
								end
							else
							   Rails.logger.debug " line #{__LINE__} : error val.class #{val.class}: #{ftype}  key #{key} "
							   Rails.logger.debug" line #{__LINE__} : error val.class  #{val.class}: #{ftype}  key #{key} "
							end	
						else
							if reqTblName.downcase =~ /^sio_|^bk_/
								%Q&'#{val.to_s.gsub("'","''")}',&
							else
								Rails.logger.debug " line #{__LINE__} : error val.class  #{val.class}: #{ftype}  key #{key} "
								Rails.logger.debug" line #{__LINE__} : error val.class  #{val.class}: #{ftype}  key #{key} "
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
				next if key.to_s == "id"
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
							when "created_at"
								next
							when "updated_at"
								%Q& #{key.to_s} =  to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),&
				   			when "expiredate"
					   			%Q&  #{key.to_s} = to_date('#{val.strftime("%Y/%m/%d")}','yyyy/mm/dd'),&
							else
								%Q&  #{key.to_s} = to_timestamp('#{val.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi'),&
				   			end
			   			when "String"	 
				   			case key.to_s
							when "created_at"
								next
							when "updated_at"
							    %Q& #{key.to_s} =  to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),&
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
