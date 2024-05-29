
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
			@tbldata["id"] = command_c["id"]
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
			command_c[@tblname.chop+"_id"] = command_c["id"] 
        	@tbldata["persons_id_upd"] = command_c["#{@tblname.chop}_person_id_upd"]
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
				params[:err] = "state 500"
				params[:parse_linedata][:confirm] = false if params[:parse_linedata]  
            	command_c["sio_message_contents"] =  "class #{self} : LINE #{__LINE__} $!: #{$!} "[0..3999]    ###evar not defined
            	command_c["sio_errline"] =  "class #{self} : LINE #{__LINE__} $@: #{$@} "[0..3999]
				err_message = command_c["sio_message_contents"].split(":")[1][0..100] + 
				 							command_c["sio_errline"].split(":")[1][0..100]  
				params[:parse_linedata][:confirm_gridmessage] = err_message if params[:parse_linedata]
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
				tbl_edit_arel(@tblname,@tbldata," id = #{@tbldata["id"]}")
			when  /_delete_|_purge_/
				if @tblname =~ /schs$|ords$|insts$|dlvs$|acts$|inputs$/ and   @tblname !~ /^shp/ ##削除なし
					@tbldata["qty_sch"] = 0 if @tbldata["qty_sch"]
					@tbldata["qty"] = 0 if @tbldata["qty"]
					@tbldata["qty_stk"] = 0 if @tbldata["qty_stk"]
					@tbldata["amt"] = 0 if @tbldata["amt"]
					@tbldata["amt_sch"] = 0 if @tbldata["amt_sch"]
					@tbldata["cash"] = 0 if @tbldata["cash"]
					@tbldata["tax"] = 0 if @tbldata["tax"]      ##変更分のみ更新
					tbl_edit_arel(@tblname,@tbldata," id = #{@tbldata["id"]}")
				else
					tbl_delete_arel(" id = #{@tbldata["id"]}")
				end
			else
				Rails.logger.debug"error  class:#{self},line:#{__LINE__}"
				Rails.logger.debug"error command_c['sio_classname']: #{command_c["sio_classname"]} "
				ActiveRecord::Base.connection.rollback_db_transaction()
				raise
			end	
        	###
        	proc_insert_sio_r(command_c)   ###sioxxxxの追加
        	###
			setParams["tbldata"] = @tbldata.dup
        	# command_c.select do |key,val|
			# 	if key.to_s =~ /_autocreate/
			# 		if (JSON.parse(val) rescue nil)
			# 			setParams["segment"] = "createtable"
			# 			setParams["remark"] = " RorBlkCtl.lib line:#{__LINE__}"
			# 			processreqs_id ,setParams = ArelCtl.proc_processreqs_add(setParams)
			# 		end
			# 	end
			# end

			
			setParams["seqno"] ||= []
			setParams["opeitm"] = {}
			setParams["classname"] = command_c["sio_classname"]
			case  @tblname
			when "suppliers"
				ArelCtl.proc_createtable("suppliers","shelfnos",command_c,setParams)
			when "workplaces"
				ArelCtl.proc_createtable("workplaces","shelfnos",command_c,setParams)
			when /mkprdpurords$/
				setParams["segment"] = "mkprdpurords"
				gantt = {}
				gantt["tblname"] = @tblname
				gantt["tblid"] = @tbldata["id"]
				gantt["paretblname"] = "dummy"
				gantt["paretblid"]  = "0"
				setParams["gantt"] = gantt.dup
				@tbldata["persons_id_upd"] = setParams["person_id_upd"]
				setParams["tbldata"] = @tbldata.dup
				setParams["mkprdpurords_id"] = @tbldata["id"]
				setParams["remark"] = " #{self} line #{__LINE__} "
				processreqs_id ,setParams = ArelCtl.proc_processreqs_add(setParams)		
				return setParams
			when /mkbillinsts$/
				setParams["segment"] = "mkbillinsts"
				setParams["mkbillinsts_id"] = @tbldata["id"]
				setParams["remark"] = " #{self} line #{__LINE__} "
				processreqs_id ,setParams = ArelCtl.proc_processreqs_add(setParams)	
				return setParams
			when /mkpayinsts$/
				setParams["segment"] = "mkpayinsts"
				setParams["mkpayinsts_id"] = @tbldata["id"]
				setParams["remark"] = " #{self} line #{__LINE__} "
				processreqs_id ,setParams = ArelCtl.proc_processreqs_add(setParams)	
				return setParams
			when /^dymschs$/
				setParams = setGantt(setParams)				###作業場所の稼働日考慮要
				setParams["tbldata"] = @tbldata.dup	###変更されているため再セット
				ope = Operation::OpeClass.new(setParams)  ###xxxschs,xxxords
				setParams = ope.proc_trngantts()  ###xxxschs,xxxordsのtrngannts,linktbls,
			when /^prdschs$|^purschs$/
				setParams = setGantt(setParams)				###作業場所の稼働日考慮要
				setParams["tbldata"] = @tbldata.dup	###変更されているため再セット
				ope = Operation::OpeClass.new(setParams)  ###xxxschs,xxxords
				setParams = ope.proc_trngantts()  ###xxxschs,xxxordsのtrngannts,linktbls,alloctblsを作成
				setParams["segment"]  = "link_lotstkhists_update"   ### alloctbl inoutlotstksも作成
				processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
			when /^prdords$/
				setParams = setGantt(setParams)
				setParams["tbldata"] = @tbldata.dup	###変更されているため再セット
				ope = Operation::OpeClass.new(setParams)  ###xxxschs,xxxords
				setParams = ope.proc_trngantts()  ###xxxschs,xxxordsのtrngannts,linktbls,alloctblsを作成
				if (setParams["mkprdpurords_id"]||=0) == 0
					setParams["segment"]  = "link_lotstkhists_update"   ### alloctbl inoutlotstksも作成
					processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
				else
					###mkordinstの時はproc_mkprdpurordsで在庫管理
					### lotstkhists_idをxxxschsとxxxxordsのinoutotstksに引き継ぐため。
				end
				setParams["segment"]  = "mkShpschConord"  ### XXXXschs,ordsの時XXXschsを作成
				setParams["remark"] = " #{self} line #{__LINE__} "
				processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
			when /^prdinsts$/  ###insts,actsでは trnganttsは作成しない。
				prdpurinstact setParams
			when /^prdacts$/
				prdpurinstact setParams
			when /^purords$/
				setParams = setGantt(setParams)
				setParams["tbldata"] = @tbldata.dup	###変更されているため再セット
				ope = Operation::OpeClass.new(setParams)  ###xxxschs,xxxords
				setParams = ope.proc_trngantts()  ###xxxschs,xxxordsのtrngannts,linktbls,alloctblsを作成
				if (setParams["mkprdpurords_id"]||=0)  == 0
					setParams["segment"]  = "link_lotstkhists_update"   ### alloctbl inoutlotstksも作成
					processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
				else
					###mkordinstの時はproc_mkprdpurordsで在庫管理
					### lotstkhists_idをxxxschsとxxxxordsのinoutotstksに引き継ぐため。
				end
				setParams["segment"]  = "mkShpschConord"  ### XXXXschs,ordsの時XXXschsを作成
				processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
				if command_c["sio_classname"] =~ /add/
					addupdate = "mkpayschs"
				else
					addupdate = "updatepayschs"
				end
				payParams = {"segment" => addupdate,  ###必須項目
									"srctblname" => "purords","srctblid" => @tbldata["id"],
									"amt_src" =>  @tbldata["amt"],
									"tax" =>  @tbldata["tax"],"taxrate" =>  @tbldata["taxrate"],
									"last_tax" =>  ope.last_rec["purord_tax"],"last_taxrate" =>  ope.last_rec["purord_taxrate"],
									"suppliers_id" => @tbldata["suppliers_id"],
									"duedate" => @tbldata["duedate"],"isudate" => @tbldata["isudate"],
									"last_amt" => ope.last_rec["purord_amt"],
									"last_duedate" => ope.last_rec["purrord_duedate"],
									"remark" => " #{self} line #{__LINE__} ",
									"seqno" => setParams["seqno"],###link_lotstkhists_update　と同時
									"trngantts_id" => setParams["gantt"]["trngantts_id"],"chrgs_id" => @tbldata["chrgs_id"],
									"gantt" => setParams["gantt"],"tbldata" => {},###必須項目
									"person_id_upd" => setParams["person_id_upd"]}
				processreqs_id ,payParams = ArelCtl.proc_processreqs_add(payParams)	
			when /^replyinputs$/ ###trnganttsは作成しない。
				setParams = prdpurinstact setParams
			when /^purinsts$/  ###trnganttsは作成しない。
				setParams = prdpurinstact setParams
			when /^purdlvs$/###trnganttsは作成しない。
				setParams = prdpurinstact setParams
			when /^puracts$/ ###trnganttsは作成しない。
				setParams = prdpurinstact(setParams)
				ope = Operation::OpeClass.new(setParams)  ###last_rec
				payParams = {"segment" => "mkpayords",  ###必須項目
								"srctblname" => "puracts","srctblid" => @tbldata["id"],
								"amt_src" =>  @tbldata["amt"],
								"tax" =>  @tbldata["tax"],"taxrate" =>  @tbldata["taxrate"],
								"suppliers_id" => @tbldata["suppliers_id"],"duedate" => @tbldata["rcptdate"],
								"last_amt" => ope.last_rec["puract_amt"],
								"last_tax" =>  ope.last_rec["purord_tax"],"last_taxrate" =>  ope.last_rec["purord_taxrate"],
								"last_duedate" => ope.last_rec["puract_rcptdate"],"crrs_id" => @tbldata["crrs_id"],
								"remark" => " class:#{self}, line:#{__LINE__} ",
								"seqno" => setParams["seqno"],###link_lotstkhists_update　と同時
								"trngantts_id" => 0,"chrgs_id" => @tbldata["chrgs_id"],
								"gantt" => setParams["gantt"],
								"tbldata" => @tbldata.dup, ###必須項目
								"person_id_upd" => setParams["person_id_upd"]}
				processreqs_id ,payParams = ArelCtl.proc_processreqs_add(payParams)	
			when /^payacts$/ ###trnganttsは作成しない。
				aud_srctbllinks(setParams)
			when /^custschs$/  ### setParams["gantt"].nil?==trueのはず
				setParams = setGantt(setParams)
				setParams["tbldata"] = @tbldata.dup	###変更されているため再セット
				ope = Operation::OpeClass.new(setParams)  ###xxxschs,xxxords
				setParams = ope.proc_trngantts()  ###xxxschs,xxxordsのtrngannts,linktbls,alloctblsを作成 
				# setParams["segment"]  = "link_lotstkhists_update"   ### alloctbl inoutlotstksも作成
				# processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
				###schsの時はshpschs,conschsは作成しない
            	Rails.logger.debug" class #{self} : line #{__LINE__} "
				Rails.logger.debug" @tbldata #{@tbldata} "
				billParams = {"segment" => "mkbillests",  ###必須項目
								"srctblname" => "custschs","srctblid" => @tbldata["id"],
								"amt_src" =>  @tbldata["amt_sch"],
								"tax" =>  @tbldata["tax"],"taxrate" =>  @tbldata["taxrate"],
								"custs_id" => @tbldata["custs_id"],"duedate" => @tbldata["duedate"],
								"last_amt" => ope.last_rec["custsch_amt"],
								"last_duedate" => ope.last_rec["custsch_duedate"],
								"remark" => "#{self} line #{__LINE__} ",
								"seqno" => setParams["seqno"],###link_lotstkhists_update　と同時
								"trngantts_id" => setParams["gantt"]["trngantts_id"],
								"gantt" => setParams["gantt"],"tbldata" => {},###必須項目
								"person_id_upd" => setParams["person_id_upd"]}
				processreqs_id ,billParams = ArelCtl.proc_processreqs_add(billParams)	
			when /^custords$/  ### setParams["gantt"].nil?==trueのはず
				###下位部品所要量計算用
				###自身のschsからordsへの変換用
				setParams = setGantt(setParams)
				setParams["tbldata"] = @tbldata.dup	###変更されているため再セット
				ope = Operation::OpeClass.new(setParams)  ###xxxschs,xxxords
				setParams = ope.proc_trngantts()  ###xxxschs,xxxordsのtrngannts,linktbls,
				# setParams["segment"]  = "link_lotstkhists_update"   ### alloctbl inoutlotstksも作成
				# processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
				###schsの時はshpschs,conschsは作成しない
				billParams = {"segment" => "mkbillschs",  ###必須項目
								"srctblname" => "custords","srctblid" => @tbldata["id"],
								"amt_src" =>  @tbldata["amt"],
								"tax" =>  @tbldata["tax"],"taxrate" =>  @tbldata["taxrate"],
								"custs_id" => @tbldata["custs_id"],"duedate" => @tbldata["duedate"],
								"last_amt" => ope.last_rec["custord_amt"],
								"last_duedate" => ope.last_rec["custord_duedate"],
								"remark" => " #{self} line #{__LINE__} ",
								"seqno" => setParams["seqno"],###link_lotstkhists_update　と同時
								"trngantts_id" => setParams["gantt"]["trngantts_id"],
								"gantt" => {},"tbldata" => {},###必須項目
								"person_id_upd" => setParams["person_id_upd"]}
				processreqs_id ,billParams = ArelCtl.proc_processreqs_add(billParams)
			when /custinsts|custdlvs/
				custinstsdlvsacts(setParams)
			when /custacts$/ ###trnganttsは作成しない。
				if  @screenCode =~ /^cust.*_custacts/
					###custactheadsを利用する時は除く
				else
					custinstsdlvsacts(setParams)
					#  billschsの減
					###
					### custordsを求める
					ords = getcustord_from_linkcusts(@tblname,@tbldata["id"])  ###ords-->acts
					ords.each do |ord|
						updatebillschs(ord["srctblid"],ord["amt_src"])
					end
				end
			when /custactheads$/ ###
				setParams[:head] = {"paretblname" => "custactheads","paretblid" => @tbldata["id"]}
				amtTaxRate ,err = add_custact_details_from_head(setParams,command_c)  ###custactsの登録 custactheads:update
				billParams = {"segment" => "mkbillords",  ###必須項目
							"srctblname" => "custacts","srctblid" => @tbldata["id"],
							"seqno" => setParams["seqno"],###link_lotstkhists_update　と同時
							"gantt" => {"tblname" => "billords" ,"tblid" => @tbldata["id"],"paretblname" => "billords" ,"tblid" => @tbldata["id"]},
							"tbldata" => {"custs_id" => @tbldata["custs_id"],"bills_id" => @tbldata["bills_id"],
											"duedate" => @tbldata["saledate"],"last_duedate" => @tbldata["saledate"],
											"amt" => 0,"tax" => 0,"qty" => 0,"count" => 0,"taxrate" => amtTaxRate.to_json,
											"remark" => " #{self} line #{__LINE__} ","persons_id_upd" => setParams["person_id_upd"]},###必須項目
							"person_id_upd" => setParams["person_id_upd"]}
				amtTaxRate.each do |rate,val|
					billParams["tbldata"]["amt"] +=  val["amt"].to_f
					billParams["tbldata"]["qty"] +=  val["qty"].to_f
					billParams["tbldata"]["count"] +=  val["count"].to_f
					billParams["tbldata"]["tax"] +=  val["amt"].to_f * rate.to_f / 100
				end
				processreqs_id ,billParams = ArelCtl.proc_processreqs_add(billParams)
				setParams[:amt] = billParams["tbldata"]["amt"]
				setParams[:qty] = billParams["tbldata"]["qty"]
				setParams[:count] = billParams["tbldata"]["count"]
				setParams[:buttonflg] = "MkInvoiceNo"
				command_c["sio_classname"] = "_edit_for_detail_custacts"
				@tbldata["amt"]  = command_c["custacthead_amt"] =  setParams[:amt]
				@tbldata["tax"] = command_c["custacthead_tax"] = billParams["tbldata"]["tax"]
				@tbldata["taxjson"]  = command_c["custacthead_taxjson"] =  amtTaxRate.to_json
				tbl_edit_arel("custactheads",@tbldata," id = #{@tbldata["id"]}")
				###
				proc_insert_sio_r(command_c)   ###sioxxxxの追加
				###
			end

			
			case @screenCode  
			when "update_trngantts"
				setParams = setGantt(setParams)
				ope = Operation::OpeClass.new(setParams) 	
				ope.proc_link_lotstkhists_update()	
				update_strsql = %Q&
							update #{@tblname}
									set shelfnos_id = #{@tbldata["shelfnos_id_trn"]},shelfnos_id_to = #{@tbldata["shelfnos_id_to_trn"]},
										duedate = #{@tbldata["duedate_trn"]},starttime = #{@tbldata["stsrttime_trn"]},
										qty_sch = #{@tbldata["qty_sch"]},expiredate = #{@tbldata["expiredate"]},
										remark = ' #{self} line:(#{__LINE__}) '||remark,
										updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss')
								where id = #{@tbldata["id"]}
					&
				ActiveRecord::Base.connection.update(update_strsql)	
				update_strsql = %Q&
							update alloctbls
									set qty_linkto_alloctbl = #{@tbldata["qty_sch"]},remark = ' #{self} line:(#{__LINE__}) '||remark,
										updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss')
								where trngantts_id = #{@tbldata["id"]} and srctblname = '#{@tblname}' and srctblid = #{@tbldata["id"]} 
					&
				ActiveRecord::Base.connection.update(update_strsql)	
			# when /cust.*_custords$|cust.*_custacts$/
			# 	case setParams["classname"]
			# 	when /_add_|_insert_/
			# 		head = {"paretblname" => params[:head][:tblname],"paretblid" => params[:head][:id]}
			# 		detail = {"tblname"=>@tblname,"tblid"=> @tbldata["id"],"persons_id_upd"=>setParams["person_id_upd"]}
			# 		ArelCtl.proc_insert_linkheads(head,detail)
			# 	when /_edit_|_update_/
			# 		tbl_edit_arel(@tblname,@tbldata," id = #{@tbldata["id"]}")
			# 	when  /_delete_|_purge_/
			# 	end	
			else
			end	
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
											alloc.id alloctbls_id	from #{srctblname} src 
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
			if @tbldata["opeitms_id"]
				opeitm = ActiveRecord::Base.connection.select_one("select * from opeitms where id = #{@tbldata["opeitms_id"]}")
				opeitm["locas_id_shelfno"] = ActiveRecord::Base.connection.select_value(%Q%
													select locas_id_shelfno from shelfnos where id = #{opeitm["shelfnos_id_opeitm"]} %)
				opeitm["locas_id_shelfno_to"] = ActiveRecord::Base.connection.select_value(%Q%
													 select locas_id_shelfno from shelfnos where id = #{opeitm["shelfnos_id_to_opeitm"]} %)
			else
				opeitm = {}
			end
			setParams["opeitm"] = opeitm.dup
			if setParams["gantt"].nil?
				gantt = {}
				gantt["orgtblname"] = gantt["paretblname"] = gantt["tblname"] = @tblname
				gantt["orgtblid"] = gantt["paretblid"] =  gantt["tblid"] =  @tbldata["id"]	
				gantt["key"] = "00000"
				gantt["mlevel"] = 0
				gantt["parenum"] = gantt["chilnum"] = 1
				gantt["qty_pare"] = 0
				gantt["qty_sch_pare"] = if  @tblname =~ /schs/ then @tbldata["qty_sch"] else 0 end
				gantt["shelfnos_id_to_trn"] =  gantt["shelfnos_id_to_pare"] =  @tbldata["shelfnos_id_to"]
				gantt["shelfnos_id_trn"] = gantt["shelfnos_id_pare"] = gantt["shelfnos_id_org"] = @tbldata["shelfnos_id"]     
				gantt["chrgs_id_trn"] =  gantt["chrgs_id_pare"] =  gantt["chrgs_id_org"] =  @tbldata["chrgs_id"]
				gantt["prjnos_id"] = @tbldata["prjnos_id"]
				gantt["shuffle_flg"] = (opeitm["shuffle_flg"]||="0")
				gantt["itms_id_trn"] = gantt["itms_id_pare"]  = gantt["itms_id_org"]  = opeitm["itms_id"]
				gantt["processseq_trn"] = gantt["processseq_pare"]  = gantt["processseq_org"]  = opeitm["processseq"]
				gantt["stktaking_proc"] =  opeitm["stktaking_proc"]
				gantt["qty_sch"] = gantt["qty"] = gantt["qty_stk"] = 0  ### xxxschs,xxxords,・・・で対応
				case @tblname
				when "puracts" 
					gantt["duedate_trn"] = gantt["duedate_pare"] = gantt["duedate_org"] = @tbldata["rcptdate"]
					gantt["qty_sch"] = gantt["qty"] = 0
					gantt["qty_stk"] = @tbldata["qty_stk"] 
				when "prdacts" 
					gantt["duedate_trn"] = gantt["duedate_pare"] = gantt["duedate_org"] = @tbldata["cmpldate"]
					gantt["qty_sch"] = gantt["qty"] = 0
					gantt["qty_stk"] = @tbldata["qty_stk"] 
				when /replyinputs/
					gantt["duedate_trn"] = gantt["duedate_pare"] = gantt["duedate_org"] = @tbldata["replydate"]
					gantt["qty_sch"] = gantt["qty_stk"] = 0
					gantt["qty"] = @tbldata["qty"] 
				when "purdlvs"
					gantt["duedate_trn"] = gantt["duedate_pare"] = gantt["duedate_org"] = @tbldata["dlvdate"]
					gantt["qty_sch"] = gantt["qty"] = 0
					gantt["qty_stk"] = @tbldata["qty_stk"] 
				when "custschs"
					gantt["starttime_trn"] = @tbldata["starttime"] = (@tbldata["duedate"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S") 
					gantt["shelfnos_id_trn"] = gantt["shelfnos_id_pare"] =  gantt["shelfnos_id_org"] = 0 ###custschs,custords用dummy id
					gantt["shelfnos_id_to_trn"] =  gantt["shelfnos_id_to_pare"] = 0
					gantt["duedate_trn"] = gantt["duedate_pare"] = gantt["duedate_org"] = @tbldata["depdate"]
					gantt["qty_stk"] = gantt["qty"] = 0
					gantt["qty_sch"] = @tbldata["qty_sch"] 
					gantt["qty_handover"] = @tbldata["qty_sch"] 
				when /custords/
					gantt["qty"] =  gantt["qty_handover"] = gantt["qty_require"] = @tbldata["qty"] 
					gantt["duedate_trn"] = gantt["duedate_pare"] = gantt["duedate_org"] = @tbldata["duedate"]
					gantt["qty_sch"] = gantt["qty_stk"] = 0
					gantt["starttime_trn"] = @tbldata["starttime"] = (@tbldata["duedate"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S")
					gantt["shelfnos_id_trn"] = gantt["shelfnos_id_pare"] =  gantt["shelfnos_id_org"] = 0 ###custschs,custords用dummy id
					gantt["shelfnos_id_to_trn"] =  gantt["shelfnos_id_to_pare"] = 0 
				when /schs$/
					gantt["duedate_trn"] = gantt["duedate_pare"] = gantt["duedate_org"] = @tbldata["depdate"]
					gantt["qty_stk"] = gantt["qty"] = 0
					gantt["qty_sch"] = @tbldata["qty_sch"] 
					gantt["qty_handover"] = @tbldata["qty_sch"] 
					gantt["starttime_trn"] = (@tbldata["duedate"].to_time - setParams["opeitm"]["duration"].to_f*60*60*24).strftime("%Y-%m-%d %H:%M:%S") 
					gantt["toduedate_trn"] = gantt["toduedate_pare"] = gantt["toduedate_org"] = (@tbldata["toduedate"]||= gantt["duedate"])
				when /ords$/ ### custordsを除くS
					if setParams["classname"] =~ /_add_|_insert_/
						 gantt["trngantts_id"] = ArelCtl.proc_get_nextval("trngantts_seq")
					else
						strsql = %Q&
							select id from trngantts where tblname = '#{@tblname}' and tblid = #{@tbldata["id"]}
						&
						 gantt["trngantts_id"] = ActiveRecord::Base.connection.select_value(strsql)
					end
					gantt["duedate_trn"] = gantt["duedate_pare"] = gantt["duedate_org"] = @tbldata["duedate"]
					gantt["qty_sch"] = gantt["qty_stk"] = 0
					gantt["qty"] = @tbldata["qty"] 
					gantt["toduedate_trn"] = gantt["toduedate_pare"] = gantt["toduedate_org"] = (@tbldata["toduedate"]||= gantt["duedate"])
					gantt["starttime_trn"] = gantt["starttime_pare"] = gantt["starttime_org"] = @tbldata["starttime"]
					gantt["qty_require"] = 0
					gantt["qty_handover"] = @tbldata["qty"] ###下位部品所要量計算用
				when /trngantts$/
					if @screenCode == "update_trngantts"
						gantt["tblname"] = @tblname
						gantt["tblid"] = @tbldata["id"]
						gantt["paretblname"] = @tbldata["paretblname"]
						gantt["paretblid"] = @tbldata["paretblid"]
						gantt["orgtblname"] = @tbldata["orgtblname"]
						gantt["orgtblid"] = @tbldata["orgtblid"]
						gantt["trngantts_id"] = @tbldata["id"]
						gantt["itms_id_trn"] = @tbldata["itms_id_trn"] 
						gantt["processseq_trn"]  =   @tbldata["processseq_trn"]
						gantt["itms_id_pare"] = @tbldata["itms_id_pare"] 
						gantt["processseq_pare"]  =   @tbldata["processseq_pare"]
						gantt["itms_id_org"] = @tbldata["itms_id_org"] 
						gantt["processseq_org"]  =   @tbldata["processseq_org"]
						gantt["starttime_trn"] =  @tbldata["starttime_trn"]   
						gantt["duedate_trn"]   =  @tbldata["duedate_trn"]     
						gantt["toduedate_trn"]   =  @tbldata["toduedate_trn"]
						gantt["persons_id_upd"]   =  setParams["person_id_upd"]
					end
				else 
					gantt["duedate_trn"] = gantt["duedate_pare"] = gantt["duedate_org"] = @tbldata["duedate"]
					gantt["qty_sch"] = gantt["qty_stk"] = 0
					gantt["qty"] = @tbldata["qty"] 
					gantt["toduedate_trn"] = gantt["toduedate_pare"] = gantt["toduedate_org"] = (@tbldata["toduedate"]||= gantt["duedate"])
					gantt["starttime_trn"] = gantt["starttime_pare"] = gantt["starttime_org"] = @tbldata["starttime"]
					gantt["qty_require"] = 0
					gantt["qty_handover"] = @tbldata["qty"] ###下位部品所要量計算用
				end
				gantt["consumunitqty"] = 1 ###消費単位
				gantt["consumminqty"]  = 0 ###最小消費数
				gantt["consumchgoverqty"] = 0  ###段取り消費数
				gantt["remark"] = " class:#{self},line:#{__LINE__} "
				gantt["qty_require"] = 0
				gantt["persons_id_upd"]   =  setParams["person_id_upd"]
		 	else ### !setParams["gantt"].nil? はxxxschsの時
				gantt = setParams["gantt"].dup
				gantt["tblname"] = @tblname
				gantt["tblid"] =  @tbldata["id"]	
				gantt["persons_id_upd"]   =  setParams["person_id_upd"]
				if  @tblname == "dymschs" and @tbldata["opeitms_id"] == "0"  ###opeitms 未登録
					gantt["shuffle_flg"] = "0"
				   ####
					gantt["shelfnos_id_to_trn"] =  "0"
					gantt["shelfnos_id_trn"] =  "0"
					gantt["locas_id_trn"] =  "0"
					gantt["prjnos_id"] = @tbldata["prjnos_id"]
					gantt["chrgs_id_trn"] =  0
					gantt["itms_id_trn"] = @tbldata["itms_id_dym"]
					gantt["processseq_trn"] = "999"
					gantt["duedate_trn"] = @tbldata["duedate"]
					gantt["toduedate_trn"] = @tbldata["duedate"]
					gantt["starttime_trn"] = @tbldata["duedate"]
				else
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
				end
			end
			gantt["remark"] = " #{self}  line:#{__LINE__} "
			setParams["gantt"] = gantt.dup
			return setParams
		end
	
		def update_alloctbls_linktbl(link,src_qty)
			strsql = %Q&
				update linktbls set qty_src = #{src_qty},remark = ' #{self} line:(#{__LINE__}) '||remark,
								updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss')
								where id = #{link["id"]}
			&
			ActiveRecord::Base.connection.update(strsql)
			strsql = %Q&
				update alloctbls set qty_linkto_alloctbl = #{src_qty},remark = ' #{self}.update_alloctbls_linktbl line:(#{__LINE__}) ',
								updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss')
								where srctblname = '#{link["srctblname"]}' and srctblid = #{link["srctblid"]}
								and trngantts_id = #{link["trngantts_id"]} 
			&
			ActiveRecord::Base.connection.update(strsql)
			strsql = %Q&
				update alloctbls set qty_linkto_alloctbl = qty_linkto_alloctbl  - #{src_qty},
								remark = ' #{self} line:(#{__LINE__}) '||remark,
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
          	command_c[(@tblname.chop + "_id")] =  command_c["id"] = @tbldata["id"]
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
							case val.class.to_s
							when "String"
								%Q& '#{val.gsub("'","''")}',&
							when "NilClass"
								%Q& '',&
							else
								%Q&  '#{val}',&
							end
			 			when "numeric"
			 					"#{val.to_s.gsub(",","")},"   ###入力データはzzz0,zzz,zzz.zz,
						when /timestamp|date/  ##db type
							case (val||="").class.to_s  ### ruby type
							when  /Time|Date/
								case key
								when "created_at","updated_at"
									%Q& to_timestamp('#{val.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),&
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

		def tbl_edit_arel  tblname,tbldata,strwhere ##
			strset = ""
			strset = ""
			tbldata.each do |key,val|
				next if key.to_s == "id"
				# strsql = %Q&select fieldcode_ftype from r_fieldcodes where  pobject_code_fld = '#{key.to_s}'&
				# ftype = ActiveRecord::Base.connection.select_value(strsql)
				ftype = $ftype[key]
				strset << case ftype
					when /char/  ###db type
						case val.class.to_s
						when "String"
							%Q& #{key} = '#{val.gsub("'","''")}',&
						when "NilClass"
							%Q& #{key} = '',&
						else
							%Q& #{key} = '#{val}',&
						end
					when "numeric"
						"#{key.to_s} = #{val.to_s.gsub(",","")},"
		   			when /timestamp|date/  ##db type
			   			case val.class.to_s  ### ruby type
			   			when  /Time|Date/
				   			case key
							when "created_at"
								next
							when "updated_at"
								%Q& #{key} =  to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),&
				   			when "expiredate"
					   			%Q&  #{key} = to_date('#{val.strftime("%Y/%m/%d")}','yyyy/mm/dd'),&
							else
								%Q&  #{key} = to_timestamp('#{val.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi'),&
				   			end
			   			when "String"	 
				   			case key
							when "created_at"
								next
							when "updated_at"
							    %Q& #{key} =  to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),&
				   			when "expiredate"
					   			%Q&  #{key} = to_date('#{val.gsub("-","/")}','yyyy/mm/dd'),&
							else
								%Q&  #{key} = to_timestamp('#{val.gsub("-","/")}','yyyy/mm/dd hh24:mi'),&
				   			end
			   			else
				  			Rails.logger.debug " line #{__LINE__} : error val.class #{ftype}  key #{key} "
			   			end	
					else
						if tblname.downcase =~ /^sio_|^bk_/
							%Q& #{key} = '#{val.to_s.gsub("'","''")}',&
						else
							Rails.logger.debug " class:#{self} : line #{__LINE__} : error val.class #{ftype} : key #{key} : $ftype #{ $ftype}"
							Rails.logger.debug " class:#{self} : line #{__LINE__} : tblname #{tblname} : tbldata:#{tbldata} " 
							debugger if key == "sno"
						end	
					end
			end
			ActiveRecord::Base.connection.update("update #{tblname}  set #{strset.chop} where #{strwhere} ")
		end

		def tbl_delete_arel  strwhere ##
			ActiveRecord::Base.connection.delete("delete from  #{@tblname}  where #{strwhere} ")
		end

		def prdpurinstact(setParams)
			###ordsの変更はoperation
			setParams["tbldata"] = @tbldata.dup	###変更されているため再セット
			setParams = setGantt(setParams)
			src_qty = (@tbldata["qty"].to_f||=@tbldata["qty_stk"].to_f)
			link_strsql,sql_get_src_alloc = get_src_tbl()
			linktbl_ids = []
			if link_strsql != "" and setParams["classname"] =~ /_edit_|_update_|_delete_|_purge_/
				ActiveRecord::Base.connection.select_all(link_strsql).each do |link|
					if src_qty > link["qty_src"].to_f
						src_qty -= link["qty_src"].to_f
					else
						###linktbls,alloctblsの更新のみ。在庫とtrnganttsの変更はArelCtl.proc_src_base_trn_stk_update
						update_alloctbls_linktbl(link,src_qty)  
						src_qty = 0
						linktbl_ids  << link["id"]
					end
				end
				setParams["linktbl_ids"] = linktbl_ids.dup
				setParams["segment"]  = "link_lotstkhists_update"   ### alloctbl inoutlotstksも作成
				processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
			else   ###新規 prd,pur /insts$|replyinputs$|dlvs$|acts$/ 
				###linktbls,alloctblsの更新のみ。在庫とtrnganttsの変更はArelCtl.proc_src_base_trn_stk_update
				if sql_get_src_alloc != "" and setParams["classname"] =~  /_add_|_insert_/
					src_qty = @tbldata["qty"].to_f + @tbldata["qty_stk"].to_f  ### @tbldata["qty"], @tbldata["qty_stk"]どちらかはnil(nil.to_f=>0)
					###ここでは引当済をセットするのみ
					ActiveRecord::Base.connection.select_all(sql_get_src_alloc).each do |src|
						if src_qty >= src["qty_linkto_alloctbl"].to_f
							alloc_qty = src["qty_linkto_alloctbl"].to_f
							src_qty -= src["qty_linkto_alloctbl"].to_f
						else
							alloc_qty = src_qty
							src_qty = 0
						end
						base = {"tblname" => @tblname ,	"tblid" => @tbldata["id"],
									"qty_src" => alloc_qty ,"amt_src" => 0,	"trngantts_id" => src["trngantts_id"],
									"persons_id_upd" => setParams["person_id_upd"]}
						linktbl_ids  << ArelCtl.proc_insert_linktbls(src,base)
						strsql = %Q&
							update alloctbls set qty_linkto_alloctbl = qty_linkto_alloctbl - #{alloc_qty},
							updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
							remark = ' #{self} line:(#{__LINE__}) '|| remark
								where id = #{src["alloctbls_id"]} 
							&
						ActiveRecord::Base.connection.update(strsql)

						alloc = {"srctblname" => @tblname ,	"srctblid" => @tbldata["id"],
									"qty_linkto_alloctbl" => alloc_qty ,"trngantts_id" => src["trngantts_id"],
									"persons_id_upd" => setParams["person_id_upd"]}
						ArelCtl.proc_insert_alloctbls(alloc)
						break if src_qty <= 0
					end
					setParams["linktbl_ids"] = linktbl_ids.dup
					setParams["segment"]  = "link_lotstkhists_update"   ### alloctbl inoutlotstksも作成
					processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
				end
			end
			return setParams
		end

		def aud_srctbllinks(setParams)
			strsql = %Q&
							select * from  payords	where sno = '#{@tbldata["sno_payord"]}' 
						&
			payord = ActiveRecord::Base.connection.select_one(strsql)
			if setParams["classname"] =~ /_edit_|_update_|_delete_|_purge_/
				strsql = %Q&
								select sio.* from sio.sio_r_payacts sio
										where sio.id = #{@tbldata["id"]} order by sio_id desc limit 1
							&
				last_rec = ActiveRecord::Base.connection.select_one(strsql)
				update_sql = %Q&
								update srctbllinks set amt_src = amt_src - #{last_rec["payact_cash"]} + #{@tbldata["cash"]}
										where srctblname = 'payords' and srctblid = #{payord["id"]}
										and tblname = 'payacts' and tblid = #{@tbldata["id"]}
				&
				payord = ActiveRecord::Base.connection.update(update_sql)
			else
				src = {"tblname" => "payords","tblid" => payord["id"]}
				base = {"tblname" => "payacts","tblid" => @tbldata["id"],"amt_src" => @tbldata["cash"],
						"remark" => " class:#{self} ,line:#{__LINE__} "}
				ArelCtl.proc_insert_srctbllinks(src,base)
			end
			return setParams
		end

		def custinstsdlvsacts params
			###ordsの変更はoperation
			setParams = params.dup
			src_qty = @tbldata["qty"].to_f + @tbldata["qty_stk"].to_f
			gantt = {}
			gantt["orgtblname"] = gantt["paretblname"] = gantt["tblname"] = @tblname
			gantt["orgtblid"] = gantt["paretblid"] =  gantt["tblid"] =  @tbldata["id"]
			setParams["gantt"] = gantt.dup
			if setParams["classname"] =~ /_edit_|_update_|_delete_|_purge_/
				link_strsql = %Q&
							select * from linkcusts where tblname = '#{@tblname}' and tblid = #{@tbldata["id"]}
				&
				ActiveRecord::Base.connection.select_all(link_strsql).each do |link|
					if src_qty > link["qty_src"].to_f
						src_qty -= link["qty_src"].to_f
					else
						###linkcusts,の更新のみ。在庫とtrnganttsの変更はArelCtl.proc_src_base_trn_stk_update
						strsql = %Q&
									update linkcusts set qty_src = #{src_qty},remark = ' #{self}.update_alloctbls_linktbl line:(#{__LINE__}) ',
											updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss')
											where id = #{link["id"]}
							&
						ActiveRecord::Base.connection.update(strsql)
						src_qty = 0
					end
				end
			else   ###新規 prd,pur /insts$|replyinputs$|dlvs$|acts$/ 
				###linkcustsの更新のみ。在庫の変更はlink_lotstkhists_update
				if setParams["classname"] =~  /_add_|_insert_/
					qty = @tbldata["qty"].to_f + @tbldata["qty_stk"].to_f  ### @tbldata["qty"], @tbldata["qty_stk"]どちらかはnil(nil.to_f=>0)
					link_strsql = []
					case screenCode
					when "fmcustord_custinsts","r_custinsts"  ###custinsts作成時は追加が必要
						link_strsql[0] = %Q&
											select src.*,link.qty_src,link.trngantts_id,link.srctblname ,link.srctblid,link.tblname,link.tblid,link.id link_id,
												ope.itms_id,ope.processseq
												from custords src 
												inner join linkcusts link on link.tblid = src.id 
												inner join opeitms ope on ope.id = src.opeitms_id
												where src.sno = '#{@tbldata["sno_custord"]}' and link.tblname = 'custords'
												order by link.trngantts_id
						&
					when "fmcustinst_custdlvs","r_custdlvs" 
						link_strsql[0] = %Q&
										select src.*,link.qty_src,link.trngantts_id,link.srctblname ,link.srctblid,link.tblname,link.tblid,link.id link_id,
											ope.itms_id,ope.processseq
											from custinsts src 
											inner join linkcusts link on link.tblid = src.id 
											inner join opeitms ope on ope.id = src.opeitms_id
											where src.sno = '#{@tbldata["sno_custinst"]}' and link.tblname = 'custinsts'
											order by link.trngantts_id
						&
					when "r_custacts"
						link_strsql[0] = %Q&
										select src.*,link.qty_src,link.trngantts_id,link.srctblname ,link.srctblid,link.tblname,link.tblid,link.id link_id,
											ope.itms_id,ope.processseq
											from custords src 
											inner join linkcusts link on link.tblid = src.id 
											inner join opeitms ope on ope.id = src.opeitms_id
											where src.sno = '#{@tbldata["sno_custords"]}' and link.srctblname = 'custords'
									union
										select src.*,link.qty_src,link.trngantts_id,link.srctblname ,link.srctblid,link.tblname,link.tblid,link.id link_id,
													ope.itms_id,ope.processseq
													from custords src 
													inner join linkcusts link on link.tblid = src.id 
													inner join opeitms ope on ope.id = src.opeitms_id
													where src.cno = '#{@tbldata["cno_custords"]}' and link.srctblname = 'custords'
											order by link.trngantts_id
									&
					# when /cust.*_custacts/
					# 		recs = ActiveRecord::Base.connection.select_all(%Q&
					# 					select 'custdlvs' tblname,* from custdlvs  dlv where dlv.packinglistno in ('#{@tbldata["packinglistnos"].split(",").join("','")}')
					# 													and custs_id = #{@tbldata["custs_id"]}
					# 							&)
					#  		recs.each do |rec|
					# 			link_strsql <<	%Q&
					#  								select src.*,link.qty_src,link.trngantts_id,link.srctblname ,link.srctblid,link.tblname,link.tblid,link.id link_id,
					#  									ope.itms_id,ope.processseq
					#  									from #{rec["srctblname"]} src 
					#  									inner join opeitms ope on ope.id = src.opeitms_id
					#  									where src.id = #{rec["id"]}
					#  									order by link.trngantts_id
					#  								&
					# 		end
					else
						raise
					end
					###ここでは引当済をセットするのみ
					linktbl_ids = []
					link_strsql.each do |sql|
						ActiveRecord::Base.connection.select_all(sql).each do |src|
							setParams["gantt"] = {"itms_id" => src["itms_id"] ,"processseq" => src["processseq"],"prjnos_id" => src["prjnos_id"],
												"tblname" => src["tblname"],"tblid" => src["tblid"],"persons_id_upd" => src["persons_id_uypd"],
												"trngantts_id" => src["trngantts_id"]}
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
									"qty_src" => qty_src ,"amt_src" => qty_src * src["price"].to_f,	"trngantts_id" => src["trngantts_id"],
									"persons_id_upd" => setParams["person_id_upd"]}
							linktbl_ids  << ArelCtl.proc_insert_linkcusts(src,base)
							update_strsql = %Q&
								update  linkcusts link set qty_src = #{src["qty_src"]},amt_src = #{src["qty_src"].to_f} * #{src["price"].to_f}
															,remark = ' #{self} line:#{__LINE__} '||remark
												where id  = '#{src["link_id"]}'
							&
							ActiveRecord::Base.connection.update(update_strsql)
							break if qty <= 0
							setParams["linktbl_ids"] = linktbl_ids.dup
							setParams["segment"]  = "link_lotstkhists_update"   ### alloctbl inoutlotstksも作成
							processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
						end
					end
				end
			end
			return setParams
		end
		def add_custact_details_from_head(params,command_c)
			case command_c["sio_classname"]
			when /_add_|_insert_/       
				reqparams = params.dup
				reqparams[:parse_linedata] = JSON.parse(params[:lineData])
				secondScreen = ScreenLib::ScreenClass.new(reqparams)
				amtTaxRate ,err = secondScreen.proc_add_custact_details reqparams   ### 
				if err.nil?
					command_c["sio_classname"] = "_edit_custacthead_for_amt"
					command_c["custacthead_invoiceno"] = @tbldata["invoiceno"] = "Inv-" + format('%06d',ArelCtl.proc_get_nextval("invoiceno_seq"))
					command_c["custacthead_taxjson"] = @tbldata["taxjson"] = amtTaxRate.to_json
					tbl_edit_arel("custactheads",@tbldata," id = #{@tbldata["id"]}")
					proc_insert_sio_r(command_c)   ###sioxxxxの追加
				end
			when /_edit_|_update_/
			when  /_delete_|_purge_/
			end	    
            #         strInvoiceNo = "custacthead_invoiceno"
            #         ActiveRecord::Base.connection.begin_db_transaction()
            #         params["clickIndex"].each_with_index do |strselected,idx|
            #             next if strselected == "undefined"
            #             selected = JSON.parse(strselected)
            #             if params[:screenCode] == selected["screenCode"]
            #                 screen = ScreenLib::ScreenClass.new(params)
            #                 grid_columns_info = screen.proc_create_grid_editable_columns_info(reqparams)
            #                 if selected["id"] == "" or selected["id"].nil? 
            #                     render json:{:err=>"please  select after add custacts "}   ###mesaage    
            #                     return
            #                 else
            #                     fields =  ActiveRecord::Base.connection.select_values(%Q&
            #                                     select pobject_code_sfd from func_get_screenfield_grpname('#{params["email"]}','r_#{params[:screenCode].split("_")[1]}')&)
            #                     strsql = %Q& select #{fields.join(",")} from r_#{params[:screenCode].split("_")[1]} 
            #                                         where id = #{strselected["id"]} & 
            #                 end
            #                 reqparams[:parse_linedata] = ActiveRecord::Base.connection.select_one(strsql)
            #                 if params[:changeData]
            #                     JSON.parse(params[:changeData][idx]).each do |k,v|
            #                         if reqparams[:parse_linedata][k]
            #                             if k != strInvoiceNo 
            #                                 reqparams[:parse_linedata][k] = v
            #                             else
            #                                 if val != "" and val
            #                                     if CtlFields.proc_billord_exists(reqparams[:parse_linedata])
            #                                         render json:{:err=>" already issue billords "}   ###mesaage
            #                                         return    
            #                                     end
            #                                 else ###新しいInvoiceNoに変更される。
            #                                     ###ここでは何もしない。
            #                                 end
            #                             end
            #                         end
            #                     end
            #                 end
            #                 reqparams[:parse_linedata][strInvoiceNo] =  invoiceNo
            #                 reqparams["custactheads"] = []  ###amtの計算用
            #                 reqparams = screen.proc_confirm_screen(reqparams)
            #                 if reqparams[:err].nil?
            #                     outcnt += 1
            #                 else
            #                     ActiveRecord::Base.connection.rollback_db_transaction()
            #                     command_c["sio_result_f"] = "9"  ##9:error
            #                     command_c["sio_message_contents"] =  "class #{self} : LINE #{__LINE__} $!: #{$!} "[0..3999]    ###evar not defined
            #                     command_c["sio_errline"] =  "class #{self} : LINE #{__LINE__} $@: #{$@} "[0..3999]
            #                     Rails.logger.debug"error class #{self} : #{Time.now}: #{$@} "
            #                     Rails.logger.debug"error class #{self} : $!: #{$!} "
            #                     Rails.logger.debug"  command_c: #{command_c} "
            #                     render json:{:err=>reqparams[:err]}
            #                     raise    
            #                 end
            #             else
            #                 Rails.logger.debug%Q&#{Time.now} #{self} line:#{__LINE__} screnCode ummatch  params[:screenCode]:#{params[:screenCode]}  selected[screenCode]:#{selected["screenCode"]} &
            #                 raise
            #             end
            #         end
            #         amtTaxRate = {}
            #         reqparams["custactheads"].each do |head|
            #             totalAmt += head["amt"]
            #             totalTax += totalAmt * head["taxrate"]  / 100 ###変更要
            #             if amtTaxRate[head["taxrate"]]
            #                 amtTaxRate[head["taxrate"]]["amt"] += head["amt"]
            #                 amtTaxRate[head["taxrate"]]["count"] += 1
            #             else
            #                 amtTaxRate[head["taxrate"]] ={"amt" => head["amt"],"count" => 1}
            #             end
            #         end
            #         custactHead =  RorBlkCtl::BlkClass.new("r_custactheads")
            #         custactHeadCommand_c = custactHead.command_init
            #         reqparams["custactheads"].each do |head|
            #             custactHeadCommand_c["id"] = head["custacthead_id"]   ###修正のみ
            #             custactHeadCommand_c["custacthead_amt"] = totalAmt
            #             custactHeadCommand_c["custacthead_tax"] = totaltax
            #             custactHeadCommand_c["custacthead_taxjson"] = amtTaxRate.to_json 
            #             custactHeadCommand_c["custacthead_created_at"] = Time.now
            #             custactHeadCommand_c = custactHead.proc_create_tbldata(custactHeadCommand_c)
            #             custactHead.proc_private_aud_rec({},custactHeadCommand_c)
            #         end
            #         ActiveRecord::Base.connection.commit_db_transaction()
            #         render json:{:outcnt => outcnt,:err => "",:outqty => 0,:outamt => totalAmt,
            #                         :params => {:buttonflg => params[:buttonflg]}}
            #     else
            #         render json:{:err=>"please  select Order"}    
            #     end
			return amtTaxRate ,err
		end
		###
		#
		###
		def updatebillschs(tblid,amt)  ###billschsの減
			strsql = %Q&
						select * from srctbllinks where tblname = 'billschs' 
												and srctblname = 'custords' and srctblid = #{tblid}
			&
			rec = ActiveRecord::Base.connection.select_one(strsql)
			updatelinktblsql = %Q& 
								update srctbllinks set amt_src = amt_src - #{amt},
									updated_at = current_timestamp,remark = '#{self} line:#{__LINE__}'||remark
									where id = #{rec["id"]}
			&
			ActiveRecord::Base.connection.update(updatelinktblsql)
			updatebilllsql = %Q& 
								update billschs set amt_sch = amt_sch - #{amt},
									updated_at = current_timestamp,remark = ' #{self} line:#{__LINE__} '||remark
									where id = #{rec["tblid"]}
			&
			ActiveRecord::Base.connection.update(updatebilllsql)
		end   
		###
		#
		###
		def getcustord_from_linkcusts(tblname,tblid)  ### xxxactsからxxxordsを求める
			ords = []
			notords = [{"tblname" => tblname,"tblid" => tblid}]
			until notords.empty? do
				notord = notords.shift
				strsql = %Q&
						select * from linkcusts where tblname = '#{notord["tblname"]}' and tblid = #{notord["tblid"]}
												and srctblname like 'cust%' and srctblname != tblname
				&
				ActiveRecord::Base.connection.select_all(strsql).each do |rec|
					if rec["srctblname"] == "custords"
						ords << rec
					else
						notords << rec
					end
				end
			end
			return ords
		end  
	end
end   ##module Ror_blk
