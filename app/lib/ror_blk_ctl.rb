
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
		  @str_qty = case @tblname
			  when /acts$|rets$|purdlvs$|custdlvs$|custinsts$/
				  "qty_stk"
			  when /schs$/
				  "qty_sch"
			  else
				  "qty"
			  end
      
		  @str_duedate = case @tblname
      when /purdlvs|custdlvs/
        "depdate"
      when /^puracts/
        "rcptdate"
      when /^prdacts/
        "cmpldate"
      when /^custacts/
        "saledate"
      when /rets/
        "retdate"
      when /reply/
        "replydate"
      else
        "duedate"
      end  
    @str_starttime = case @tblname
        when /purdlvs|custdlvs/
          "depdate"
        when /^puracts/
          "rcptdate"
        when /^prdacts/
          "cmpldate"
        when /^custacts/
          "saledate"
        when /rets/
          "retdate"
        when /reply/
          "replydate"
        else
          "starttime"
        end  

      @chng_flg = "" ###変更フラグ

      
      case @tblname 
        when /^cust/
          @str_shelfnos_id = "sio.#{@tblname.chop}_shelfno_id_fm shelfnos_id_fm"
          @str_suppliers_id = "'' suppliers_id"
        when /^prd/
          @str_shelfnos_id = "sio.#{@tblname.chop}_shelfno_id_to shelfnos_id_to"
          @str_suppliers_id = "'' suppliers_id"
        when /^pur/ 
          @str_shelfnos_id = "sio.#{@tblname.chop}_shelfno_id_to shelfnos_id_to"
          @str_suppliers_id = "sio.#{@tblname.chop}_supplier_id suppliers_id"
      end

		end
		def screenCode
			@screenCode
		end
		# def proc_grp_code
		# 	@proc_grp_code
		# end
    def command_init
        @command_init
    end
		def tbldata
			  @tbldata
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
								      command_c[@tblname.chop+"_cno"] = @tbldata["cno"] = CtlFields.proc_field_cno(@tblname.chop,command_c["id"])
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
         ###
         # 更新前のrec -->@last_rec
         ###
        # if command_c["sio_classname"] =~ /_delete_|_purge_|_edit_|_update_/
        #     strsql = nil
        #     case @tblname 
        #     when /^prd|^pur|custschs|custords|custinsts|custdlvs|custacts|custrets/
        #       strsql = %Q&
        #               select tbl.*,ope.itms_id,ope.processseq from #{@tblname} tbl
        #                 inner join opeitms ope on ope.id = tbl.opeitms_id
        #                 where tbl.id = #{@tbldata["id"]}
        #       &
        #     when /itms|cust|supp|price/
        #       strsql = %Q&
        #               select * from #{@tblname} where id = #{@tbldata["id"]}
        #       &
        #     end
        #     if strsql
        #       @last_rec = ActiveRecord::Base.connection.select_one(strsql)
        #       @last_rec["tblname"] = @tblname
        #     else
        #       @last_rec= {}
        #     end
        # end
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
          		Rails.logger.debug"  command_c: #{command_c} " 
				raise
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

		def proc_private_aud_rec(params,command_c)   ###commitなし params-->前の状態を引き継ぐ
			tmp_key = {}
      setParams = params.dup
			case command_c["sio_classname"]
			when /_add_|_insert_/
				tbl_add_arel(@tblname,@tbldata) ###sioXXXX,tbldata
			when /_edit_|_update_/
				tbl_edit_arel(@tblname,@tbldata," id = #{@tbldata["id"]}")
			when  /_delete_|_purge_/
				if @tblname =~ /schs$|ords$|insts$|dlvs$|acts$|inputs$/ and   @tblname !~ /^shp|^dvs|^erc/ ##削除なし
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
			last_lotstks = []
			
			setParams["seqno"] ||= []
			setParams["opeitm"] = {}
			setParams["classname"] = command_c["sio_classname"]
      @last_rec= {}
			case  @tblname
			  when "suppliers"
				  ArelCtl.proc_createtable("suppliers","shelfnos",command_c,setParams)
			  when "workplaces"
				  ArelCtl.proc_createtable("workplaces","shelfnos",command_c,setParams)
			  when "facilities"
				  ArelCtl.proc_createtable("facilities","fcoperators",command_c,setParams)
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
				  setParams["mkprdpurords_id"] = @tbldata["id"].to_i
				  setParams["remark"] = " #{self} line #{__LINE__} "
				  processreqs_id ,setParams = ArelCtl.proc_processreqs_add(setParams)		
			  when /mkbillinsts$/
				  setParams["gantt"] = {}
				  setParams["segment"] = "mkbillinsts"
				  setParams["mkbillinsts_id"] = @tbldata["id"]
				  setParams["remark"] = " #{self} line #{__LINE__} "
				  processreqs_id ,setParams = ArelCtl.proc_processreqs_add(setParams)	
			  when /mkpayinsts$/
				  setParams["gantt"] = {}
				  setParams["segment"] = "mkpayinsts"
				  setParams["mkpayinsts_id"] = @tbldata["id"]
				  setParams["remark"] = " #{self} line #{__LINE__} "
				  processreqs_id ,setParams = ArelCtl.proc_processreqs_add(setParams)	
			  when /^dymschs$/
          ###trnganttsの作成
				  setParams = setGantt(setParams)				###作業場所の稼働日考慮要
				  setParams["tbldata"] = @tbldata.dup	###変更されているため再セット
				  ope = Operation::OpeClass.new(setParams)  ###xxxschs,xxxords
          if setParams["classname"] =~ /_insert_|_add_/  ###trngantts 追加
				    last_lotstks = ope.proc_trngantts_insert()  ###xxxschs,xxxordsのtrngannts,linktbls,
          else
            check_shelfnos_duedate_qty(params)
            last_lotstks = ope.proc_trngantts_update(@last_rec,@chng_flg)
          end
          setParams = ope.proc_opeParams.dup
          Rails.logger.debug " calss:#{self},line:#{__LINE__},last_lotstks:#{@last_lotstks}"   
			  when /^shpests$|^dvsschs|^ercschs/
          ###trnganttsの作成
				  setParams = setGantt(setParams)				###作業場所の稼働日考慮要
				  setParams["tbldata"] = @tbldata.dup	###変更されているため再セット
				  ope = Operation::OpeClass.new(setParams)  ###xxxschs,xxxords
          if setParams["classname"] =~ /_insert_|_add_/  ###trngantts 追加
				    last_lotstks = ope.proc_trngantts_insert()  ###xxxschs,xxxordsのtrngannts,linktbls,
            setParams = ope.proc_opeParams.dup
          else
           ###shpests,dvsschs,ercschsの時変更はない　trnganttsへのlinkは削除済
          end
          Rails.logger.debug " calss:#{self},line:#{__LINE__},last_lotstks:#{@last_lotstks}"   
			  when /^purschs$/
				  setParams = setGantt(setParams)				###作業場所の稼働日考慮要
				  setParams["tbldata"] = @tbldata.dup	###変更されているため再セット
				  ope = Operation::OpeClass.new(setParams)  ###xxxschs,xxxords
          if setParams["classname"] =~ /_insert_|_add_/  ###trngantts 追加
				    last_lotstks = ope.proc_trngantts_insert()  ###xxxschs,xxxordsのtrngannts,linktbls,
          else
            check_shelfnos_duedate_qty(params)
            last_lotstks = ope.proc_trngantts_update(@last_rec,@chng_flg)
          end
          setParams = ope.proc_opeParams.dup
			  when /^prdschs$/
				  setParams = setGantt(setParams)				###作業場所の稼働日考慮要
				  setParams["tbldata"] = @tbldata.dup	###変更されているため再セット
				  ope = Operation::OpeClass.new(setParams)  ###xxxschs,xxxords
          if setParams["classname"] =~ /_insert_|_add_/  ###trngantts 追加
				    last_lotstks = ope.proc_trngantts_insert()  ###xxxschs,xxxordsのtrngannts,linktbls,
          else
            check_shelfnos_duedate_qty(params)
            last_lotstks = ope.proc_trngantts_update(@last_rec,@chng_flg)
          end
          ##setParams = ope.proc_opeParams.dup
          # case command_c["sio_classname"]
			    #   when /_add_|_insert_/   #mkschsで作成
          #   # ActiveRecord::Base.connection.select_all(strsql).each do |apparatus|
          #   #     dvs = Operation::OpeClass.new(setParams)  ###prdschs
          #   #     dvs.proc_add_dvs_data(apparatus)
          #   #     dvs.proc_add_erc_data(apparatus)
          #   # end
          #   else
          #     if @tbldata["qty_sch"]  == 0 
          #       ActiveRecord::Base.connection.select_all(ArelCtl.proc_apparatus_sql(@tbldata["opeitms_id"])).each do |apparatus|
          #         dvs = Operation::OpeClass.new(setParams)  
          #         dvs.proc_delete_dvs_data
          #         dvs.proc_delete_erc_data
          #       end
          #     end
          #   end
			  when /^prdords$/
				  setParams = setGantt(setParams)
				  setParams["tbldata"] = @tbldata.dup	###変更されているため再セット
				  ope = Operation::OpeClass.new(setParams)  ###xxxschs,xxxords
          if setParams["classname"] =~ /_insert_|_add_/  ###trngantts 追加
				    last_lotstks = ope.proc_trngantts_insert()  ###xxxschs,xxxordsのtrngannts,linktbls,
          else
            check_shelfnos_duedate_qty(params)
            last_lotstks = ope.proc_trngantts_update(@last_rec,@chng_flg)
          end
          conParams = ope.proc_opeParams.dup
          if setParams["classname"] =~ /_add_|_insert_/
				    conParams["segment"]  = "mkShpschConord"  ### XXXXschs,ordsの時XXXschsを作成
				    conParams["remark"] = " #{self} line #{__LINE__} "
				    processreqs_id,setParams = ArelCtl.proc_processreqs_add(conParams)
          else
            last_lotstks = ope.proc_consume_by_parent()          
          end          
          Rails.logger.debug " calss:#{self},line:#{__LINE__},last_lotstks:#{@last_lotstks}"   
          ###
          # case command_c["sio_classname"]
          #   when /_add_|_insert_/
          #     ActiveRecord::Base.connection.select_all(ArelCtl.proc_apparatus_sql(@tbldata["opeitms_id"])).each do |apparatus|
          #       ope = Operation::OpeClass.new(setParams) 
          #       ope.proc_add_dvs_data(apparatus)
          #       ope.proc_add_erc_data(apparatus)
          #     end
          #   else
          #     if @tbldata["qty"]  == 0 or @tbldata["duedate"] != @last_rec["duedate"]
          #       ActiveRecord::Base.connection.select_all(strsql).each do |apparatus|
          #         ope = Operation::OpeClass.new(setParams)  
          #         ope.proc_delete_dvs_data
          #         ope.proc_delete_erc_data
          #       end
          #     end
          # end
        when /^dvsinst$|^dvsacts$|^ercinsts$|^ercacts$|^dvsords$|^ercords$/
          if @tblname =~ /^dvsords$|ercords$/ and  command_c["sio_classname"] =~ /_add_|_insert/
            ###trnganttsの作成
				    setParams = setGantt(setParams)				###作業場所の稼働日考慮要
			  	  setParams["tbldata"] = @tbldata.dup	###変更されているため再セット
				    ope = Operation::OpeClass.new(setParams)  ###xxxschs,xxxords
            if setParams["classname"] =~ /_insert_|_add_/  ###trngantts 追加
              last_lotstks = ope.proc_trngantts_insert()  ###xxxschs,xxxordsのtrngannts,linktbls,
            else
              check_shelfnos_duedate_qty(params)
              last_lotstks = ope.proc_trngantts_update(@last_rec,@chng_flg)
            end
            setParams = ope.proc_opeParams.dup	
          end
          Rails.logger.debug " calss:#{self},line:#{__LINE__},last_lotstks:#{@last_lotstks}"   
          case command_c["sio_classname"]
			      when /_add_|_insert_/
              strsql = %Q&
                      select link.* from linktbls link
                                where tblname = 'prd#{@tblname[3..-1]}'
                                and tblid = #{@tbldata["prd#{@tblname[3..-1]}_id_#{@tblname.chop}"]}
                                and (srctblname != tblname or srctblid != tblid)
              &
              ActiveRecord::Base.connection.select_all(strsql).each do |prev_prd|
                strsql = %Q&
                        select  '#{@tblname[0,3]+prev_prd["srctblname"][3..-1]}' tblname,* from #{@tblname[0,3]+prev_prd["srctblname"][3..-1]}
                                  where  #{prev_prd["srctblname"]}_id_#{@tblname[0,3]+prev_prd["srctblname"][3..-1].chop} = #{prev_prd["srctblid"]}
                &
                ActiveRecord::Base.connection.select_all(strsql).each do |prev_dvserc|
                  strsql = %Q&
                          select link.* from linktbls link
                                    inner join alloctbls alloc on alloc.srctblname = link.tblname 
                                                  and alloc.srctblid = link.tblid and link.trngantts_id = alloc.trngantts_id 
                                    where tblname = '#{@tblname[0,3]+prev_prd["srctblname"][3..-1]}'
                                    and tblid = #{prev_dvserc["id"]} and alloc.qty_linkto_alloctbl > 0
                          &
                  ActiveRecord::Base.connection.select_all(strsql).each do |link|
                    src = {"tblname" => link["srctblname"],"tblid" => link["srctblid"],"qty_src" => 1,"trngantts_id" => link["trngantts_id"]}
                    base = {"tblname" => @tblname,"tblid" => @tbldata["id"],"qty_src" => 1,"amt_src" => 0,
                            "remark" => "#{self} line #{__LINE__}", 
                            "persons_id_upd" => setParams["person_id_upd"]}
                    alloc = {"srctblname" => @tblname,"srctblid" => @tbldata["id"],"trngantts_id" => link["trngantts_id"],
                            "qty_linkto_alloctbl" => 1,
                            "remark" => "#{self} line #{__LINE__} #{Time.now}","persons_id_upd" => setParams["person_id_upd"],
                            "allocfree" => 	"alloc"}
                    linktbl_id = ArelCtl.proc_insert_linktbls(src,base)
                    alloctbl_id,tmp_last_lotstk = ArelCtl.proc_aud_alloctbls(alloc,"insert")
                    alloc = {"srctblname" => prev_dvserc["tblname"],"srctblid" => prev_dvserc["id"],"trngantts_id" => link["trngantts_id"],
                            "qty_linkto_alloctbl" => 0,
                            "remark" => "#{self} ,line:#{__LINE__} #{Time.now}","persons_id_upd" => setParams["person_id_upd"],
                            "allocfree" => 	"alloc"}
                    alloctbl_id,temp_last_lotstk = ArelCtl.proc_aud_alloctbls(alloc,"update")
                  end
                end
              end
			      when /_delete_|_purge_/  ###prdxxxsでqty=0にしたときdvsxxxs,ercxxxsがdeleteされる
                strsql = %Q&
                            select l.id link_id,a.id alloc_id,l.trngantts_id from linktbls l 
                                      inner join alloctbls a on a.srctblname = l.tblname and a.srctblid = l.tblid
                                                            and a.trngantts_id = l.trngantts_id 
                                      where l.tblname = '#{@tblname}' and l.tblid = #{@tbldata["id"]}
                &
                ActiveRecord::Base.connection.select_all(strsql).each do |link|
                  strdelsql = %Q&
                            delete from linktbls where id =#{link["link_id"]}
                  &
                  ActiveRecord::Base.connection.delete(strdelsql)
                  strdelsql = %Q&
                            delete from alloctbls where id =#{link["alloc_id"]} 
                  &
                  ActiveRecord::Base.connection.delete(strdelsql)
                  strdelsql = %Q&
                            update trngantts set qty = 0,qty_sch =0,
                                              remark = 'class:#{self},line:#{__LINE__} #{@tblname},id=#{@tbldata["id"]} delete'||left(remark,3000)
                            where id =#{link["trngantts_id"]}
                  &
                  ActiveRecord::Base.connection.update(strdelsql)
                end
          end
			  when /^prdinsts$/  ###insts,actsでは trnganttsは作成しない。
				  last_lotstks = prdpurinstact(setParams)
			  when /^prdacts$/
				  last_lotstks = prdpurinstact setParams
			  when /^purords$/
				  setParams = setGantt(setParams)
				  setParams["tbldata"] = @tbldata.dup	###変更されているため再セット
				  ope = Operation::OpeClass.new(setParams)  ###xxxschs,xxxords
          if setParams["classname"] =~ /_insert_|_add_/  ###trngantts 追加
				    last_lotstks = ope.proc_trngantts_insert()  ###xxxschs,xxxordsのtrngannts,linktbls,
          else
            check_shelfnos_duedate_qty(params)
            last_lotstks = ope.proc_trngantts_update(@last_rec,@chng_flg)
          end
          conParams = ope.proc_opeParams.dup
          if setParams["classname"] =~ /_add_|_insert_/
				    conParams["segment"]  = "mkShpschConord"  ### XXXXschs,ordsの時XXXschsを作成
				    conParams["remark"] = " #{self} line #{__LINE__} "
				    processreqs_id,setParams = ArelCtl.proc_processreqs_add(conParams)
          end
				  if command_c["sio_classname"] =~ /_add_|_insert_/
					  addupdate = "mkpayschs"
				  else
					  addupdate = "updatepayschs"
				  end
				  payParams = {"segment" => addupdate,  ###必須項目
									"srctblname" => "purords","srctblid" => @tbldata["id"],
									"amt_src" =>  @tbldata["amt"],
									"tax" =>  @tbldata["tax"],"taxrate" =>  @tbldata["taxrate"],
									"last_tax" =>  @last_rec["tax"],"last_taxrate" =>  @last_rec["taxrate"],
									"suppliers_id" => @tbldata["suppliers_id"],
									"duedate" => @tbldata["duedate"],"isudate" => @tbldata["isudate"],
									"last_amt" => @last_rec["amt"]||= @tbldata["amt"],
									"last_duedate" => @last_rec["duedate"]||= @tbldata["duedate"],
									"remark" => " #{self} line #{__LINE__} ",
									"seqno" => setParams["seqno"],
									"trngantts_id" => setParams["gantt"]["trngantts_id"],"chrgs_id" => @tbldata["chrgs_id"],
									"gantt" => setParams["gantt"],"tbldata" => {},###必須項目
									"person_id_upd" => setParams["person_id_upd"]}
				  processreqs_id ,payParams = ArelCtl.proc_processreqs_add(payParams)	
			  when /^replyinputs$/ ###trnganttsは作成しない。
				  last_lotstks = prdpurinstact setParams
			  when /^purinsts$/  ###trnganttsは作成しない。
				  last_lotstks = prdpurinstact setParams
			  when /^purdlvs$/###trnganttsは作成しない。
				  last_lotstks = prdpurinstact setParams
			  when /^puracts$/ ###trnganttsは作成しない。
				  last_lotstks = prdpurinstact(setParams)
				  payParams = {"segment" => "mkpayords",  ###必須項目
								"srctblname" => "puracts","srctblid" => @tbldata["id"],
								"last_amt" => @last_rec["amt"]||= @tbldata["amt"],
								"last_tax" =>  @last_rec["tax"]||= @tbldata["tax"],
								"last_taxrate" =>  @last_rec["taxrate"]||= @tbldata["taxrate"],
								"last_duedate" => @last_rec["duedate"]||= @tbldata["duedate"],
								"remark" => " class:#{self}, line:#{__LINE__} ",
								"seqno" => setParams["seqno"],
								"trngantts_id" => 0,
                "gantt" => {"tblname" => "payords" ,"tblid" => @tbldata["id"],"paretblname" => "payords" },
								"tbldata" => @tbldata.dup, ###必須項目
                "suppliers_id" => @tbldata["suppliers_id"],
								"person_id_upd" => setParams["person_id_upd"]}
				  processreqs_id ,payParams = ArelCtl.proc_processreqs_add(payParams)	
			  when /^rejections$/ ###trnganttsは作成しない。
				  last_lotstks << {"paretblname" => @tbldata["paretblname"],"paretblid" => @tbldata["paretblid"],
                          "tblname" => "rejections","tblid" => @tbldata["id"],"qty_src" => @tbldata["qty_rejection"]}
			  when /^payacts$/ ###trnganttsは作成しない。
				  ###pay_aud_srctbllinks(setParams)
			  when /^custschs$/  ### setParams["gantt"].nil?==trueのはず
				  setParams = setGantt(setParams)
				  setParams["tbldata"] = @tbldata.dup	###変更されているため再セット
				  ope = Operation::OpeClass.new(setParams)  ###xxxschs,xxxords
          if setParams["classname"] =~ /_insert_|_add_/  ###trngantts 追加
				    last_lotstks = ope.proc_trngantts_insert()  ###xxxschs,xxxordsのtrngannts,linktbls,
          else
            check_shelfnos_duedate_qty(params)
            last_lotstks = ope.proc_trngantts_update(@last_rec,@chng_flg)
          end
          billParams = {"segment" => "mkbillests",  ###必須項目
                "srctblname" => "custschs","srctblid" => @tbldata["id"],
                "amt_src" =>  @tbldata["amt_sch"],
                "tax" =>  @tbldata["tax"],"taxrate" =>  @tbldata["taxrate"],
                "custs_id" => @tbldata["custs_id"],"duedate" => @tbldata["duedate"],
                "last_amt" => @last_rec["amt_sch"]||= @tbldata["amt_sch"],
                "last_duedate" => @last_rec["duedate"]||= @tbldata["duedate"],
                "remark" => "#{self} line #{__LINE__} ",
                "seqno" => setParams["seqno"],
                "trngantts_id" => setParams["gantt"]["trngantts_id"],
                "gantt" => setParams["gantt"],"tbldata" => {},###必須項目
                "person_id_upd" => setParams["person_id_upd"]}
          setParams = ope.proc_opeParams.dup
				  ###schsの時はshpschs
				  processreqs_id ,billParams = ArelCtl.proc_processreqs_add(billParams)	
			  when /^custords$/  ### setParams["gantt"].nil?==trueのはず
				  ###下位部品所要量計算用
				  ###自身のschsからordsへの変換用
				  setParams = setGantt(setParams)
				  setParams["tbldata"] = @tbldata.dup	###変更されているため再セット
				  ope = Operation::OpeClass.new(setParams)  ###xxxschs,xxxords
          if setParams["classname"] =~ /_insert_|_add_/  ###trngantts 追加
				    last_lotstks = ope.proc_trngantts_insert()  
          else
            check_shelfnos_duedate_qty(params)
            last_lotstks = ope.proc_trngantts_update(@last_rec,@chng_flg)
          end
          setParams = ope.proc_opeParams.dup
          billParams = {"segment" => "mkbillschs",  ###必須項目
                "srctblname" => "custords","srctblid" => @tbldata["id"],
                "amt_src" =>  @tbldata["amt"],
                "tax" =>  @tbldata["tax"],"taxrate" =>  @tbldata["taxrate"],
                "custs_id" => @tbldata["custs_id"],"duedate" => @tbldata["duedate"],
                "last_amt" => @last_rec["amt"]||= @tbldata["amt"],
                "last_duedate" => @last_rec["duedate"]||= @tbldata["duedate"],
                "remark" => " #{self} line #{__LINE__} ",
                "seqno" => setParams["seqno"],
                "trngantts_id" => setParams["gantt"]["trngantts_id"],
                "gantt" => {},"tbldata" => {},###必須項目
                "person_id_upd" => setParams["person_id_upd"]}
				  processreqs_id ,billParams = ArelCtl.proc_processreqs_add(billParams)
          Rails.logger.debug " calss:#{self},line:#{__LINE__},last_lotstks:#{last_lotstks}"   
			  when /custinsts|custdlvs/
				  last_lotstk = custinstsdlvsacts(setParams)
			  when /custacts$/ ###trnganttsは作成しない。
					last_lotstks = custinstsdlvsacts(setParams)
          if setParams[:head]
            if setParams[:head]["paretblname"] == "custactheads"
              ###
              #  custactheadsでbillordsを作成
              ###
            else
              billParams = setBillParams()
              processreqs_id ,billParams = ArelCtl.proc_processreqs_add(billParams)
            end
          else
              billParams = setBillParams()
              processreqs_id ,billParams = ArelCtl.proc_processreqs_add(billParams)
          end

			  when /custactheads$/ ###
				  setParams["tbldata"] = @tbldata.dup
				  setParams[:head] = {"paretblname" => "custactheads","paretblid" => @tbldata["id"]}
				  amtTaxRate ,err = add_custact_details_from_head(setParams,command_c)  ###custactsの登録 custactheads:update
				  billParams = setBillParams()
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
        when /movacts/
            if  @tbldata["qty_stk_fm"].to_f  > 0
              @tbldata["qty_stk"] = @tbldata["qty_stk_fm"].to_f * -1 
              @tbldata["shelfnos_id"] = @tbldata["shelfnos_id_fm"]
				      setParams = setGantt(setParams)
				      setParams["tbldata"] = @tbldata.dup	###変更されているため再セット
				      ope = Operation::OpeClass.new(setParams)  ###xxxschs,xxxords
              if setParams["classname"] =~ /_insert_|_add_/  ###trngantts 追加
                last_lotstks = ope.proc_trngantts_insert()  ###xxxschs,xxxordsのtrngannts,linktbls,
              else
                check_shelfnos_duedate_qty(params)
                last_lotstks = ope.proc_trngantts_update(@last_rec,@chng_flg)
              end
            end
            if  @tbldata["qty_stk_to"].to_f  > 0
              @tbldata["qty_stk"] = @tbldata["qty_stk_to"].to_f 
              @tbldata["shelfnos_id"] = @tbldata["shelfnos_id_to"]
				      setParams = setGantt(setParams)
				      setParams["tbldata"] = @tbldata.dup	###変更されているため再セット
				      ope = Operation::OpeClass.new(setParams)  ###xxxschs,xxxords
              if setParams["classname"] =~ /_insert_|_add_/  ###trngantts 追加
                last_lotstks = ope.proc_trngantts_insert()  ###xxxschs,xxxordsのtrngannts,linktbls,
              else
                check_shelfnos_duedate_qty(params)
                last_lotstks = ope.proc_trngantts_update(@last_rec,@chng_flg)
              end
              setParams = ope.proc_opeParams.dup
            end
            last_lotstks << {"tblname" => "movacts","tblid" => @tbldata["id"],"qty_src" => 0 }  ###入り出が同時に発生のためココでは無視
			end

			case @screenCode  
			  when "update_trngantts"        
				  setParams = setGantt(setParams)
				  update_strsql = %Q&
							update #{@tblname}
									set shelfnos_id = #{@tbldata["shelfnos_id_trn"]},shelfnos_id_to = #{@tbldata["shelfnos_id_to_trn"]},
										duedate = #{@tbldata["duedate_trn"]},starttime = #{@tbldata["stsrttime_trn"]},
										qty_sch = #{@tbldata["qty_sch"]},expiredate = #{@tbldata["expiredate"]},
										remark = ' #{self} line:(#{__LINE__}) '||left(remark,3000),
										updated_at = cast('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}' as timestamp)
								where id = #{@tbldata["id"]}
					  &
				  ActiveRecord::Base.connection.update(update_strsql)	
				  alloc = {trngantts_id => @tbldata["trngantts_id"] ,srctblname => @tblname,srctblid => @tbldata["id"],
                "qty_linkto_alloctbl" => @tbldata["qty_sch"],
                "remark" => "#{self} line #{__LINE__} #{Time.now}"}
          alloctbl_id,last_lotstk = ArelCtl.proc_aud_alloctbls(alloc,"update")
          last_lotstks << last_lotstk
			  else
			end	
      if !last_lotstks.empty?
        Rails.logger.debug"class #{self},line:#{__LINE__} , last_lotstks: #{last_lotstks} "
        if (setParams["mkprdpurords_id"]||= 0) == 0 
          stkParams = setParams.dup
          stkParams["segment"]  = "link_lotstkhists_update" 
          stkParams["last_lotstks"] = last_lotstks.dup
          stkParams["gantt"] = {}
          stkParams["child"] = {}
          stkParams["tbldata"] = {}
          stkParams["opeitm"] = {}
          processreqs_id,setParams = ArelCtl.proc_processreqs_add(stkParams)
        else
          setParams["last_lotstks"] = last_lotstks.dup
        end
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
										select link.id link_id,src.*,link.qty_src,link.trngantts_id,link.srctblname,link.srctblid,link.tblname,link.tblid
                              from #{srctblname} src 
															inner join linktbls link on link.srctblid = src.id 
															where src.sno = '#{val}' and link.srctblname = '#{srctblname}'
															and  link.tblid = #{@tbldata["id"]} and link.tblname = '#{@tblname}'
															order by link.trngantts_id
									&
								sql_get_src_alloc = %Q&
										select src.*,alloc.qty_linkto_alloctbl,alloc.trngantts_id,alloc.srctblname tblname,alloc.srctblid tblid,
											alloc.id alloctbls_id	from #{srctblname} src 
												inner join alloctbls alloc on alloc.srctblid = src.id 
											where src.sno = '#{val}' and  alloc.qty_linkto_alloctbl > 0 and alloc.srctblname = '#{srctblname}'
											order by alloc.allocfree,alloc.id  ---引き当て済分から次の状態に移行する。
											for update
									&
							end
						when  /^cno_/
							case srctblname
							when /^prd/
								link_strsql = %Q&
									select link.id link_id,src.*,link.qty_src,link.trngantts_id 
														from #{srctblname} src 
														inner join linktbls link on link.srctblid = src.id
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
											and  alloc.qty_linkto_alloctbl > 0 and alloc.srctblname = '#{srctblname}'
											order by alloc.allocfree,alloc.id
											for update
								& 
							when /^pur/
								link_strsql = %Q&
									select link.id link_id,src.*,link.qty_src,link.trngantts_id,link.srctblname,link.srctblid,link.tblname,link.tblid  from #{srctblname} src 										  
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
											and  alloc.qty_linkto_alloctbl > 0 and alloc.srctblname = '#{srctblname}'
											order by alloc.allocfree,alloc.id
											for update
								& 
							end	
						when  /^gno_/
							case srctblname
							when /^prd/
								link_strsql = %Q&
									select link.id link_id,src.*,link.qty_src,link.trngantts_id,link.srctblname,link.srctblid,link.tblname,link.tblid 
                    from #{srctblname} src 										  
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
											and  alloc.qty_linkto_alloctbl > 0 and alloc.srctblname = '#{srctblname}'
											order by alloc.allocfree,alloc.id
											for update
								& 
							when /^pur/
								link_strsql = %Q&
									select link.id link_id,src.*,link.qty_src,link.trngantts_id,link.srctblname,link.srctblid,link.tblname,link.tblid 
                    from #{srctblname} src 										  
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
											and  alloc.qty_linkto_alloctbl > 0 and alloc.srctblname = '#{srctblname}'
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
			if setParams["gantt"].nil?  ###custschs,custords,prdschs,prdords,purschs,purords top
				gantt = {}
				gantt["orgtblname"] = gantt["paretblname"] = gantt["tblname"] = @tblname
				gantt["orgtblid"] = gantt["paretblid"] =  gantt["tblid"] =  @tbldata["id"]	
				gantt["key"] = "00000"
				gantt["mlevel"] = 0
				gantt["parenum"] = gantt["chilnum"] = 1
				gantt["qty_pare"] = 0
				gantt["qty_sch_pare"] = if  @tblname =~ /schs/ then @tbldata["qty_sch"] else 0 end
				gantt["shelfnos_id_to_trn"] =  gantt["shelfnos_id_to_pare"] =  @tbldata["shelfnos_id_to"]
				gantt["chrgs_id_trn"] =  gantt["chrgs_id_pare"] =  gantt["chrgs_id_org"] =  @tbldata["chrgs_id"]
				gantt["prjnos_id"] = @tbldata["prjnos_id"]
				gantt["shuffle_flg"] = (opeitm["shuffle_flg"]||= "0")
				gantt["itms_id_trn"] = gantt["itms_id_pare"]  = gantt["itms_id_org"]  = opeitm["itms_id"]
				gantt["processseq_trn"] = gantt["processseq_pare"]  = gantt["processseq_org"]  = opeitm["processseq"]
				gantt["stktaking_proc"] =  opeitm["stktaking_proc"]
				gantt["qty_sch"] = gantt["qty"] = gantt["qty_stk"] = 0  ### xxxschs,xxxords,・・・で対応
				if @tblname =~ /^pur/  ###purxxxs 
					suppliers = ActiveRecord::Base.connection.select_one("select * from suppliers where id = #{@tbldata["suppliers_id"]}")
					shelfnos = ActiveRecord::Base.connection.select_one("select s.* from shelfnos s
																				inner join locas l on s.locas_id_shelfno = l.id 
																									and l.id = #{suppliers["locas_id_supplier"]}" )
					gantt["shelfnos_id_trn"] = gantt["shelfnos_id_pare"] = gantt["shelfnos_id_org"] = shelfnos["id"]     
				else
					gantt["shelfnos_id_trn"] = gantt["shelfnos_id_pare"] = gantt["shelfnos_id_org"] = @tbldata["shelfnos_id"]    
				end
				case @tblname
				when "puracts" 
					gantt["duedate_trn"] = gantt["duedate_pare"] = gantt["duedate_org"] = @tbldata["rcptdate"]
					gantt["qty_sch"] = gantt["qty"] = 0
					gantt["qty_stk"] = @tbldata["qty_stk"] 
				  gantt["remark"] = " class:#{self},line:#{__LINE__} "
				when "prdacts" 
					gantt["duedate_trn"] = gantt["duedate_pare"] = gantt["duedate_org"] = @tbldata["cmpldate"]
					gantt["qty_sch"] = gantt["qty"] = 0
					gantt["qty_stk"] = @tbldata["qty_stk"] 
				  gantt["remark"] = " class:#{self},line:#{__LINE__} "
				when /replyinputs/
					gantt["duedate_trn"] = gantt["duedate_pare"] = gantt["duedate_org"] = @tbldata["replydate"]
					gantt["qty_sch"] = gantt["qty_stk"] = 0
					gantt["qty"] = @tbldata["qty"] 
				  gantt["remark"] = " class:#{self},line:#{__LINE__} "
				when "purdlvs"
					gantt["duedate_trn"] = gantt["duedate_pare"] = gantt["duedate_org"] = @tbldata["dlvdate"]
					gantt["qty_sch"] = gantt["qty"] = 0
					gantt["qty_stk"] = @tbldata["qty_stk"] 
				  gantt["remark"] = " class:#{self},line:#{__LINE__} "
				when "custschs"
					gantt["starttime_trn"] = @tbldata["starttime"] = (@tbldata["duedate"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S") 
          gantt["starttime_org"] = gantt["starttime_pare"] = gantt["starttime_trn"]
					gantt["shelfnos_id_trn"] = gantt["shelfnos_id_pare"] =  gantt["shelfnos_id_org"] = 0 ###custschs,custords用dummy id
					gantt["shelfnos_id_to_trn"] =  gantt["shelfnos_id_to_pare"] = 0
					gantt["duedate_trn"] = gantt["duedate_pare"] = gantt["duedate_org"] = @tbldata["depdate"]
					gantt["toduedate_trn"] = gantt["toduedate_pare"] = gantt["toduedate_org"] = @tbldata["toduedate"]
					gantt["qty_sch"] = gantt["qty_stk"] = 0
					gantt["qty_stk"] = gantt["qty"] = 0
					gantt["qty_sch"] = @tbldata["qty_sch"] 
					gantt["qty_handover"] = @tbldata["qty_sch"]
				  gantt["remark"] = " class:#{self},line:#{__LINE__} " 
				when /custords/
					gantt["qty"] =  gantt["qty_handover"] = gantt["qty_require"] = @tbldata["qty"] 
					gantt["duedate_trn"] = gantt["duedate_pare"] = gantt["duedate_org"] = @tbldata["duedate"]
					gantt["toduedate_trn"] = gantt["toduedate_pare"] = gantt["toduedate_org"] = @tbldata["toduedate"]
					gantt["qty_sch"] = gantt["qty_stk"] = 0
					gantt["starttime_org"] = gantt["starttime_pare"] = gantt["starttime_trn"] = @tbldata["starttime"] 
					gantt["shelfnos_id_trn"] = gantt["shelfnos_id_pare"] =  gantt["shelfnos_id_org"] = 0 ###custschs,custords用dummy id
					gantt["shelfnos_id_to_trn"] =  gantt["shelfnos_id_to_pare"] = 0 
				  gantt["remark"] = " class:#{self},line:#{__LINE__} "
				when /schs$/
					gantt["duedate_trn"] = gantt["duedate_pare"] = gantt["duedate_org"] = @tbldata["duedate"]
					gantt["qty_stk"] = gantt["qty"] = 0
					gantt["qty_sch"] = @tbldata["qty_sch"] 
					gantt["qty_handover"] = @tbldata["qty_sch"] 
					gantt["starttime_trn"] = @tbldata["starttime"]
          gantt["starttime_org"] = gantt["starttime_pare"] = gantt["starttime_trn"]
					gantt["toduedate_trn"] = gantt["toduedate_pare"] = gantt["toduedate_org"] = (@tbldata["toduedate"]||= gantt["duedate"])
				  gantt["remark"] = " class:#{self},line:#{__LINE__} "
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
				  gantt["remark"] = " class:#{self},line:#{__LINE__} "
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
				    gantt["remark"] = " class:#{self},line:#{__LINE__} "
					end
        when /movacts/
            gantt["qty_stk"] = @tbldata["qty_stk"]
            gantt["shelfnos_id_to_trn"] =  gantt["shelfnos_id_to_pare"] =  @tbldata["shelfnos_id"]
            gantt["qty_sch"] = gantt["qty"] = gantt["qty_handover"] = 0
            gantt["duedate_trn"] = gantt["duedate_pare"] = gantt["duedate_org"] = @tbldata["cmpldate"]
            gantt["toduedate_trn"] = gantt["toduedate_pare"] = gantt["toduedate_org"] = @tbldata["cmpldate"]
            gantt["starttime_trn"] = gantt["starttime_pare"] = gantt["starttime_org"] = @tbldata["cmpldate"]
						gantt["persons_id_upd"]   =  setParams["person_id_upd"]
				    gantt["remark"] = " class:#{self},line:#{__LINE__} "
				else 
					gantt["duedate_trn"] = gantt["duedate_pare"] = gantt["duedate_org"] = @tbldata["duedate"]
					gantt["qty_sch"] = gantt["qty_stk"] = gantt["qty_handover"] = 0
					gantt["qty"] = @tbldata["qty"] 
					gantt["toduedate_trn"] = gantt["toduedate_pare"] = gantt["toduedate_org"] = (@tbldata["toduedate"]||= gantt["duedate"])
					gantt["starttime_trn"] = gantt["starttime_pare"] = gantt["starttime_org"] = @tbldata["starttime"]
					gantt["qty_require"] = 0
					gantt["qty_handover"] = @tbldata["qty"] ###下位部品所要量計算用
				  gantt["remark"] = " class:#{self},line:#{__LINE__} "
				end
				gantt["consumunitqty"] = (opeitm["consumunitqty"].to_f == 0 ? 1 : opeitm["consumunitqty"].to_f) ###消費単位
				gantt["consumminqty"]  =  (opeitm["consumminqty"]||=0) ###最小消費数
				gantt["consumchgoverqty"] =  (opeitm["consumchgoverqty"]||=0)  ###段取り消費数
				gantt["optfixoterm"] =  (opeitm["optfixoterm"].to_f == 0 ? 365 : opeitm["optfixoterm"].to_f)  ###段取り消費数
				gantt["packqty"] =  (opeitm["packqty"].to_f == 0 ? 1 : opeitm["maxqty"].to_f)
        gantt["duration"] =  (opeitm["duration"].to_f == 0 ? 1 : opeitm["duration"].to_f)
        gantt["unitofduration"] =  (opeitm["unitofduration"].to_s == "" ? "Day " : opeitm["unitofduration"].to_s)
				gantt["qty_require"] = 0
				gantt["persons_id_upd"]   =  setParams["person_id_upd"]
		 	else ### !setParams["gantt"].nil? はxxxschsの時
				gantt = setParams["gantt"].dup
				gantt["tblname"] = @tblname
				gantt["tblid"] = @tbldata["id"]	
				gantt["persons_id_upd"]   =  setParams["person_id_upd"]
				gantt["prjnos_id"] = @tbldata["prjnos_id"]
				gantt["remark"] = " class:#{self},line:#{__LINE__} "
				case @tblname
				when "dymschs"
					gantt["shuffle_flg"] = "0"
					gantt["shelfnos_id_to_trn"] =  "0"
					gantt["shelfnos_id_trn"] =  "0"
					gantt["locas_id_trn"] =  "0"
					gantt["chrgs_id_trn"] =  0
					gantt["itms_id_trn"] = @tbldata["itms_id_dym"]
					gantt["processseq_trn"] = "999"
					gantt["duedate_trn"] = @tbldata["duedate"]
					gantt["toduedate_trn"] = @tbldata["duedate"]
					gantt["starttime_trn"] = @tbldata["duedate"]
				when /^dvsschs|^dvsords/
					gantt["shuffle_flg"] = "0"
					gantt["shelfnos_id_to_trn"] =  "0"
					strsql = %Q&
								select s.id shelfnos_id,l.id locas_id,f.itms_id,f.chrgs_id_facilitie
										from shelfnos s
										inner join locas l on s.locas_id_shelfno = l.id
										inner join facilities f on s.id = f.shelfnos_id
									where  f.id = #{@tbldata["facilities_id"]}
					&
					facilities = ActiveRecord::Base.connection.select_one(strsql)
					gantt["shelfnos_id_trn"] =  facilities["shelfnos_id"]
					gantt["locas_id_trn"] =  facilities["locas_id"]
					gantt["chrgs_id_trn"] =  facilities["chrgs_id_facilitie"]
					gantt["itms_id_trn"] = facilities["itms_id"]
					gantt["processseq_trn"] = "999"
					gantt["duedate_trn"] = @tbldata["duedate"]
					gantt["toduedate_trn"] = @tbldata["duedate"]
					gantt["starttime_trn"] = @tbldata["starttime"]
					gantt["qty_handover"] =  0
          gantt["qty_require"] =  gantt["qty_sch"]  = 1
				when /^ercschs|^ercords/
					gantt["shuffle_flg"] = "0"
					gantt["shelfnos_id_to_trn"] =  "0"
					gantt["shelfnos_id_trn"] =  "0"
					gantt["locas_id_trn"] =  "0"
					strsql = %Q&
								select * from  fcoperators f 
											where   f.id = #{@tbldata["fcoperators_id"]}
								&
					fcoperators = ActiveRecord::Base.connection.select_one(strsql)
					gantt["chrgs_id_trn"] =  fcoperators["chrgs_id_fcoperator"]
					gantt["itms_id_trn"] = fcoperators["itms_id_fcoperator"]
					gantt["processseq_trn"] = "999"
					gantt["duedate_trn"] = @tbldata["duedate"]
					gantt["toduedate_trn"] = @tbldata["duedate"]
					gantt["starttime_trn"] = @tbldata["starttime"]
					gantt["qty_handover"] = 0
          gantt["qty_require"] = gantt["qty_sch"]  = 1
				when "shpests"
					gantt["shuffle_flg"] = "0"
					gantt["shelfnos_id_to_trn"] =  @tbldata["shelfnos_id_to"]
					gantt["shelfnos_id_trn"] =  @tbldata["shelfnos_id_fm"]
					strsql = %Q&
								select l.id locas_id from shelfnos s
													inner join locas l on s.locas_id_shelfno = l.id
									where  s.id = #{@tbldata["shelfnos_id_fm"]}
					&
					locas_id = ActiveRecord::Base.connection.select_value(strsql)
					gantt["locas_id_trn"] =  locas_id
					gantt["chrgs_id_trn"] =  @tbldata["chrgs_id"]
					gantt["itms_id_trn"] = @tbldata["itms_id"]
					gantt["processseq_trn"] = "999"
					gantt["duedate_trn"] = @tbldata["duedate"]
					gantt["toduedate_trn"] = @tbldata["duedate"]
					gantt["starttime_trn"] = @tbldata["duedate"]
					gantt["qty_handover"] = 0
				else
			 		gantt["shuffle_flg"] = (opeitm["shuffle_flg"]||= "0")
					####
			 		gantt["shelfnos_id_to_trn"] =  @tbldata["shelfnos_id_to"]
					 if @tblname =~ /^pur/  ###purxxxs 
						 suppliers = ActiveRecord::Base.connection.select_one("select * from suppliers where id = #{@tbldata["suppliers_id"]}")
						 shelfnos = ActiveRecord::Base.connection.select_one("select s.* from shelfnos s
																					 inner join locas l on s.locas_id_shelfno = l.id 
																										 and l.id = #{suppliers["locas_id_supplier"]}" )
						 gantt["shelfnos_id_trn"]  = shelfnos["id"]     
					 else
						 gantt["shelfnos_id_trn"] =  @tbldata["shelfnos_id"]    
					 end
			 		gantt["chrgs_id_trn"] =  @tbldata["chrgs_id"]
			 		gantt["itms_id_trn"] = opeitm["itms_id"]
			 		gantt["processseq_trn"] = opeitm["processseq"]
			 		gantt["duedate_trn"] = @tbldata["duedate"]
			 		gantt["toduedate_trn"] = @tbldata["toduedate"]
			 		gantt["starttime_trn"] = @tbldata["starttime"]
				end
			end
			setParams["gantt"] = gantt.dup
			return setParams
		end
	
		def update_alloctbls_linktbl(link,src_qty)
      last_lotstks = []
			strsql = %Q&
				update linktbls set qty_src = #{src_qty},remark = ' #{self} line:(#{__LINE__}) '||left(remark,3000),
								updated_at = cast('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}' as timestamp)
								where id = #{link["link_id"]}
			&
			ActiveRecord::Base.connection.update(strsql)
      alloc = {"trngantts_id" => link["trngantts_id"] ,"srctblname" => link["srctblname"],"srctblid" => link["srctblid"],
              "qty_linkto_alloctbl" => -src_qty,
              "remark" => "#{self} line #{__LINE__} #{Time.now}"}
      alloctbl_id,last_lotstk_curr = ArelCtl.proc_aud_alloctbls(alloc,"update+")
      alloc = {"trngantts_id" => link["trngantts_id"] ,"srctblname" => link["tblname"],"srctblid" => link["tblid"],
              "qty_linkto_alloctbl" => src_qty,  "remark" => "#{self} line #{__LINE__} #{Time.now}"}
      alloctbl_id,last_lotstk_prev = ArelCtl.proc_aud_alloctbls(alloc,"update+")
      return last_lotstk_prev,last_lotstk_curr
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
				next if key.to_s =~ /gridmessage/
				next if key.to_s =~ /^_/
				next if key.to_s == "confirm"
				next if key.to_s == "aud"
				next if key.to_s == "errPath"
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
				fields << key.to_s + ","
				skey = if reqTblName.downcase =~ /^sio|^bk/ then key.to_s.split("_",2)[1] else key.to_s end
				ftype = Constants::Ftype[key]
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
							case (val||= "").class.to_s  ### ruby type
							when  /Time|Date/
								case key
								###when "created_at","updated_at"
								###	%Q& cast('#{val.strftime("%Y/%m/%d %H:%M:%S")}' as timestamp),&
								when "expiredate"  ###date type
									%Q& cast('#{val.strftime("%Y/%m/%d")}' as date),&
			 					else
									%Q& '#{val}',&
								end
							when "String"	 
								case key.to_s
			 					when "created_at","updated_at","isudate"
			 						%Q& cast('#{val}' as timestamp),&
								when "expiredate"
									%Q& cast('#{val}' as date),&
			 					else
									%Q& cast('#{val}' as timestamp),&
								end
							else
							   Rails.logger.debug " line #{__LINE__} : error val.class #{val.class}: #{ftype}  key #{key} "
							   Rails.logger.debug" line #{__LINE__} : error val.class  #{val.class}: #{ftype}  key #{key} "
							end	
						else
							if reqTblName.downcase =~ /^sio_|^bk_/
								%Q&'#{val.to_s.gsub("'","''")}',&
							else
								###Rails.logger.debug"line:#{__LINE__} error reqTblName:#{reqTblName},val.class:#{val.class}, ftype:#{ftype},key:#{key},tblarel:#{tblarel}"
                raise  "line:#{__LINE__} error reqTblName:#{reqTblName},val.class:#{val.class}, ftype:#{ftype},key:#{key},tblarel:#{tblarel}"
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
				ftype = Constants::Ftype[key]
				if ftype
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
			   			when  /Time|Date|time/
				   			case key
							when "created_at"
								next
							when "updated_at"
								%Q& #{key} =  cast('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}' as timestamp),&
				   			when "expiredate"
					   			%Q&  #{key} = cast('#{val.strftime("%Y/%m/%d")}' as date),&
							else
								%Q&  #{key} = cast('#{val.strftime("%Y/%m/%d %H:%M:%S")}' as timestamp),&
				   			end
			   			when "String"	 
				   			case key
							when "created_at"
								next
							when "updated_at"
							    %Q& #{key} =  cast('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}' as timestamp),&
				   			when "expiredate"
					   			%Q&  #{key} = cast('#{val.gsub("-","/")}' as date),&
							else
								%Q&  #{key} = cast('#{val.gsub("-","/")}' as timestamp),&
				   			end
			   			else
				  			raise " class:#{self} ,line:#{__LINE__} ,error val.class:#{ftype} ,key:#{key} "
			   			end	
					else
						if tblname.downcase =~ /^sio_|^bk_/
							%Q& #{key} = '#{val.to_s.gsub("'","''")}',&
						else
							Rails.logger.debug " class:#{self} : line #{__LINE__} : error val.class #{ftype} : key #{key} : Ftype #{Constants::Ftype}"
							raise " class:#{self} : line #{__LINE__} : tblname #{tblname} : tbldata:#{tbldata} " 
						end	
					end
				else
					raise 3.times{Rails.logger.debug" error ftype is nil ,class:#{self} ,line:#{__LINE__}, key:#{key} "}
				end
			end
			ActiveRecord::Base.connection.update("update #{tblname}  set #{strset.chop} where #{strwhere} ")
		end

		def tbl_delete_arel  strwhere ##
			ActiveRecord::Base.connection.delete("delete from  #{@tblname}  where #{strwhere} ")
		end

		def prdpurinstact(setParams)  ###prd,pur schs,ordsでは使用しない
			###ordsの変更はoperation
			setParams["tbldata"] = @tbldata.dup	###変更されているため再セット
			setParams = setGantt(setParams)
      case @tblname 
      when /dlvs$|acts$|rets$|custinsts$/
        src_qty = @tbldata["qty_stk"].to_f
        str_qty = "qty_stk"
      else
        src_qty = @tbldata["qty"].to_f
        str_qty = "qty"
      end
			link_strsql,sql_get_src_alloc = get_src_tbl()
      last_lotstks = []
			if link_strsql != "" and setParams["classname"] =~ /_edit_|_update_|_delete_|_purge_/
        check_shelfnos_duedate_qty(params)
        if @chng_flg != ""
          if @chng_flg =~ /due/ or @chng_flg =~ /shelfno/ or src_qty == 0
              #
              ###現在庫の削除
              #
              last_lotstk = {"tblname" => @last_rec["tblname"] ,"tblid" => @last_rec["id"],"set_f" => true}
              case @tblname 
              when /dlvs$|acts$|rects$/
                last_lotstk["qty_src"] = @last_rec["qty_stk"].to_f * -1
              else
                last_lotstk["qty_src"] =  @last_rec["qty"].to_f * -1
              end
              last_lotstk["rec"] = @tbldata.dup
              last_lotstks << last_lotstk
              ###
              # 現在の消費の削除
              ###
              prev_tbldata = @tbldata.dup
              prev_tbldata[str_qty] = 0
              last_lotstks_parts = Shipment.proc_update_consume(@tblname,prev_tbldata,@last_rec,true)  ###  :true 消費の取り消し 
              last_lotstks.concat last_lotstks_parts ###
              if @tblname =~ /^prdinsts$/  and str_qty == 0 ###数量減でも装置は使用する。
                 ###
                 # dvsords src_qty > 0
                 ###
                 ActiveRecord::Base.connection.select_all(ArelCtl.proc_apparatus_sql(@tbldata["opeitms_id"])).each do |apparatus|
                   ope = Operation::OpeClass.new(setParams)  ###prdinsts,prdacts
                   ope.proc_delete_dvs_data
                   ope.proc_delete_erc_data
                 end
              end
              if  src_qty < @last_rec[str_qty].to_f
                ###
                # 引き当て元の在庫復活
                ###
                ActiveRecord::Base.connection.select_all(link_strsql).each do |link|
                  if src_qty > link["qty_src"].to_f
                    src_qty -= link["qty_src"].to_f
                  else
                    last_lotstk_prev,last_lotstk_curr　= update_alloctbls_linktbl(link,src_qty)  ###
                    last_lotstks << last_lotstk_prev  ###現在庫は今回」対象外
                    ###
                    # 前の状態の消費の復活
                    ###
                    prev_rec = ActiveRecord::Base.connection.select_one(%Q&select * from #{last_lotstk["tblname"]} where id = #{last_lotstk["tblid"]}&)
                    case last_lotstk["tblname"] 
                    when /dlvs$|acts$|rects$/
                      prev_str_qty = "qty_stk"
                    else
                      prev_str_qty = "qty"
                    end
                    new_prev_rec = prev_rec.dup
                    new_prev_rec[prev_str_qty] = prev_rec[prev_str_qty].to_f - src_qty 
                    new_prev_rec["persons_id_upd"] = setParams["person_id_upd"]
                    last_lotstks_parts = Shipment.proc_update_consume(last_lotstk["tblname"],new_prev_rec,prev_rec,false)
                    last_lotstks.concat last_lotstks_parts
                    ###
                    src_qty = 0
                  end
                end
              else
                if src_qty == @last_rec[str_qty].to_f
                  #
                  ###現在庫
                  #
                  last_lotstk = {"tblname" => @tblname ,"tblid" => @tbldata["id"],"set_f" => true,"rec" => @tbldata}
                  last_lotstk["qty_src"] = src_qty
                  last_lotstks << last_lotstk
                  ###
                  # 現在の消費
                  ###
                  last_lotstks_parts = Shipment.proc_update_consume(@tblname,@tbldata,@last_rec,false)  ###  :true 消費の取り消し 
                  last_lotstks.concat last_lotstks_parts ###
                  ###
                  # 装置」
                  ###
                  if @tblname =~ /^prd/
                    ActiveRecord::Base.connection.select_all(ArelCtl.proc_apparatus_sql(@tbldata["opeitms_id"])).each do |apparatus|
                        ope = Operation::OpeClass.new(setParams)  ###prdinsts,prdacts
                        ope.proc_add_dvs_data(apparatus)
                        ope.proc_add_erc_data(apparatus)
                    end
                  end
                end
              end
          else  ###old_qty != new_qty and new_qty > 0
            if src_qty > 0
              #
              ###現在庫
              #
              ActiveRecord::Base.connection.select_all(link_strsql).each do |link|
                if src_qty > link["qty_src"].to_f
                  src_qty -= link["qty_src"].to_f
                else
                  last_lotstk_prev,last_lotstk_curr　= update_alloctbls_linktbl(link,src_qty)  ###
                  last_lotstks << last_lotstk_prev  
                  last_lotstks << last_lotstk_curr
                  ###
                  # 前の状態の消費の復活
                  ###
                  prev_rec = ActiveRecord::Base.connection.select_one(%Q&select * from #{lin["srctblname"]} where id = #{link["srctblid"]}&)
                  case link["srctblname"] 
                  when /dlvs$|acts$|rects$|custinsts$/
                    prev_str_qty = "qty_stk"
                  else
                    prev_str_qty = "qty"
                  end
                  new_prev_rec = prev_rec.dup
                  new_prev_rec[prev_str_qty] = prev_rec[prev_str_qty].to_f - src_qty 
                  new_prev_rec["persons_id_upd"] =  setParams["person_id_upd"]
                  last_lotstks_parts = Shipment.proc_update_consume(link["srctblname"],new_prev_rec,prev_rec,false)
                  last_lotstks.concat last_lotstks_parts
                  ###
                  src_qty = 0
                end
              end
              ###
              # 装置」
              ###end
              if @tblname =~ /^prd/
                  ActiveRecord::Base.connection.select_all(ArelCtl.proc_apparatus_sql(@tbldata["opeitms_id"])).each do |apparatus|
                    ope = Operation::OpeClass.new(setParams)  ###prdinsts,prdacts
                    ope.proc_add_dvs_data(apparatus)
                    ope.proc_add_erc_data(apparatus)
                  end
              end
            end
          end
        end
			else 
        ###新規 prd,pur /insts$|replyinputs$|dlvs$|acts$/ 
				###linktbls,alloctblsの更新のみ。在庫とtrnganttsの変更はArelCtl.proc_src_base_trn_stk_update
				if sql_get_src_alloc != "" and setParams["classname"] =~  /_add_|_insert_/
					src_qty =  @tbldata["qty_sch"].to_f + @tbldata["qty"].to_f + @tbldata["qty_stk"].to_f  ### @tbldata["qty"], @tbldata["qty_stk"]どちらかはnil(nil.to_f=>0)
					###ここでは引当済をセットするのみ
					ActiveRecord::Base.connection.select_all(sql_get_src_alloc).each do |src|
            save_alloc_qty = src["qty_linkto_alloctbl"].to_f
            Rails.logger.debug" class:#{self} , line:#{__LINE__} ,src:#{src}" 
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
						ArelCtl.proc_insert_linktbls(src,base)
						alloc = {"id" => src["alloctbls_id"] ,"qty_linkto_alloctbl" => -alloc_qty ,
                  "remark" => " #{self} line:(#{__LINE__}) ","persons_id_upd" => setParams["person_id_upd"]}
            alloctbl_id,last_lotstk  = ArelCtl.proc_aud_alloctbls(alloc,"update+")
            last_lotstks << last_lotstk
            3.times{Rails.logger.debug" class:#{self} , line:#{__LINE__} ,error last_lotstk:#{last_lotstk}"} if  last_lotstk.nil? or last_lotstk["tblname"].nil? or last_lotstk["tblname"] == ""
            
            if link_strsql != ""  ###消費の取り消し
              ActiveRecord::Base.connection.select_all(link_strsql).each do |link|
                case link["srctblname"] 
                when /dlvs$|acts$|rects$|custinsts$/
                  str_qty = "qty_stk"
                else
                  str_qty = "qty"
                end
                prev = {"id" => link["srctblid"],"qty_src" => save_alloc_qty}
                new_prev = {"id" => link["srctblid"],"qty_src" => save_alloc_qty - alloc_qty,"persons_id_upd" => setParams["person_id_upd"]}
                last_lotstks_parts = Shipment.proc_update_consume(link["srctblname"],new_prev,prev,true)  ###:true 消費の取り消し
                last_lotstks.concat last_lotstks_parts
              end
            end
						alloc = {"srctblname" => @tblname ,	"srctblid" => @tbldata["id"],
									"qty_linkto_alloctbl" => alloc_qty ,"trngantts_id" => src["trngantts_id"],
									"persons_id_upd" => setParams["person_id_upd"]}
            alloctbl_id,last_lotstk  = ArelCtl.proc_aud_alloctbls(alloc,nil)
            last_lotstks << last_lotstk
						break if src_qty <= 0
					end
				end
        if @tblname =~ /^prd/
          ActiveRecord::Base.connection.select_all(ArelCtl.proc_apparatus_sql(@tbldata["opeitms_id"])).each do |apparatus|
              ope = Operation::OpeClass.new(setParams)  ###prdinsts,prdacts
              ope.proc_add_dvs_data(apparatus)  ###新規追加
              ope.proc_add_erc_data(apparatus)
          end
        end
			end
      ope = Operation::OpeClass.new(setParams) 	
      last_lotstks_parts = ope.proc_consume_by_parent()	###追加、変更
      last_lotstks.concat last_lotstks_parts
      Rails.logger.debug " calss:#{self},line:#{__LINE__},last_lotstks:#{@last_lotstks}"   
			return last_lotstks
		end

		# def pay_aud_srctbllinks(setParams)
		# 	strsql = %Q&
		# 					select * from  payords	where sno = '#{@tbldata["sno_payord"]}' 
		# 				&
		# 	payord = ActiveRecord::Base.connection.select_one(strsql)
		# 	if setParams["classname"] =~ /_edit_|_update_|_delete_|_purge_/
		# 		strsql = %Q&
		# 						select sio.* from sio.sio_r_payacts sio
		# 								where sio.id = #{@tbldata["id"]} order by sio_id desc limit 1
		# 					&
		# 		last_rec = ActiveRecord::Base.connection.select_one(strsql)
		# 		update_sql = %Q&
		# 						update srctbllinks set amt_src = amt_src - #{last_rec["payact_cash"]} + #{@tbldata["cash"]}
		# 								where srctblname = 'payords' and srctblid = #{payord["id"]}
		# 								and tblname = 'payacts' and tblid = #{@tbldata["id"]}
		# 		&
		# 		payord = ActiveRecord::Base.connection.update(update_sql)
		# 	else
		# 		src = {"tblname" => "payords","tblid" => payord["id"]}
		# 		base = {"tblname" => "payacts","tblid" => @tbldata["id"],"amt_src" => @tbldata["cash"],
		# 				    "remark" => " class:#{self} ,line:#{__LINE__} "}
		# 		ArelCtl.proc_insert_srctbllinks(src,base)
		# 	end
		# 	return setParams
		# end

		def custinstsdlvsacts params
			###ordsの変更はoperation
			setParams = params.dup
			src_qty = @tbldata["qty"].to_f + @tbldata["qty_stk"].to_f
			gantt = {}
			gantt["orgtblname"] = gantt["paretblname"] = gantt["tblname"] = @tblname
			gantt["orgtblid"] = gantt["paretblid"] =  gantt["tblid"] =  @tbldata["id"]
			setParams["gantt"] = gantt.dup
      last_lotstks = []
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
									update linkcusts set qty_src = #{src_qty},remark = ' #{self}, line:(#{__LINE__}) ',
											updated_at = cast('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}' as timestamp)
											where id = #{link["id"]}
							&
						ActiveRecord::Base.connection.update(strsql)
            last_lotstks << {"tblname" => link["tblname"],"tblid" => link["tblid"],
                              "qty_src" =>  src_qty - link["qty_src"].to_f} 
						src_qty = 0
					end
				end
			else   ###新規 
				###linkcustsの更新のみ。在庫の変更はlink_lotstkhists_update
				if setParams["classname"] =~  /_add_|_insert_/
					qty = @tbldata["qty"].to_f + @tbldata["qty_stk"].to_f  ### @tbldata["qty"], @tbldata["qty_stk"]どちらかはnil(nil.to_f=>0)
					link_strsql = ""
					case screenCode
					  when "fmcustord_custinsts","r_custinsts"  ###custinsts作成時は追加が必要
						  link_strsql = %Q&
											select src.*,link.qty_src,link.trngantts_id,link.srctblname ,link.srctblid,link.tblname,link.tblid,link.id link_id,
												ope.itms_id,ope.processseq
												from custords src 
												inner join linkcusts link on link.tblid = src.id 
												inner join opeitms ope on ope.id = src.opeitms_id
												where src.sno = '#{@tbldata["sno_custord"]}' and link.tblname = 'custords'
												order by link.trngantts_id
						  &
					  when "fmcustinst_custdlvs","r_custdlvs" 
						  link_strsql = %Q&
										select src.*,link.qty_src,link.trngantts_id,link.srctblname ,link.srctblid,link.tblname,link.tblid,link.id link_id,
											ope.itms_id,ope.processseq
											from custinsts src 
											inner join linkcusts link on link.tblid = src.id 
											inner join opeitms ope on ope.id = src.opeitms_id
											where src.sno = '#{@tbldata["sno_custinst"]}' and link.tblname = 'custinsts'
											order by link.trngantts_id
						  &
					  when "r_custacts"
						  link_strsql = %Q&
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
					  when /cust.*_custacts/
					 		link_strsql = %Q&
					 					select 'custdlvs' tblname,dlv.id tblid,dlv.price,link.id link_id,link.trngantts_id 
                                from custdlvs  dlv
                                inner join linkcusts link on link.tblid = dlv.id  
                                where dlv.packinglistno = '#{@tbldata["packinglistno_custdlv"]}'
					 													and custs_id = #{@tbldata["custs_id"]}
					 							&
					else
						raise
					end
					###ここでは引当済をセットするのみ
					ActiveRecord::Base.connection.select_all(link_strsql).each do |src|
							# setParams["gantt"] = {"itms_id" => src["itms_id"] ,"processseq" => src["processseq"],"prjnos_id" => src["prjnos_id"],
							# 					"tblname" => src["tblname"],"tblid" => src["tblid"],"persons_id_upd" => src["persons_id_uypd"],
							# 					"trngantts_id" => src["trngantts_id"]}
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
									"qty_src" => @tbldata["qty_stk"] ,"amt_src" => @tbldata["amt"],	"trngantts_id" => src["trngantts_id"],
									"persons_id_upd" => setParams["person_id_upd"],"remark" => " #{self} line:#{__LINE__} "}
              src = {"tblname" => src["tblname"] ,	"tblid" => src["tblid"],"link_id" => src["link_id"],
                      "qty_src" => qty_src ,"amt_src" => qty_src * src["price"].to_f,	"trngantts_id" => src["trngantts_id"],
                      "persons_id_upd" => setParams["person_id_upd"]}
							update_strsql = %Q&
								update  linkcusts link set qty_src = #{src["qty_src"]},amt_src = #{src["qty_src"].to_f} * #{src["price"].to_f}
															,remark = ' #{self} line:#{__LINE__} '||remark
												where id  = '#{src["link_id"]}'
							&
							ActiveRecord::Base.connection.update(update_strsql)
        Rails.logger.debug"class #{self},line:#{__LINE__} , @tbldata: #{@tbldata} "
              ArelCtl.proc_insert_linkcusts(src,base)
              last_lotstks << {"tblname" => src["tblname"],"tblid" => src["tblid"],"qty_src" =>   qty - src["qty_src"].to_f } 
              last_lotstks << {"tblname" => @tblname,"tblid" => @tbldata["id"], "qty_src" =>   qty_src } 
							break if qty <= 0
					end
				end
			end
			return last_lotstks
		end
		def add_custact_details_from_head(params,command_c)
			case command_c["sio_classname"]
			when /_add_|_insert_/       
				reqparams = params.dup
        @tbldata["invoiceno"] = "Inv-" + format('%06d',ArelCtl.proc_get_nextval("invoiceno_seq"))
        reqparams["tbldata"] = @tbldata
 				reqparams[:parse_linedata] = JSON.parse(params[:lineData])
				secondScreen = ScreenLib::ScreenClass.new(reqparams)
				amtTaxRate ,err = secondScreen.proc_add_custact_details reqparams   ### 
				if err.nil?
					command_c["sio_classname"] = "_edit_custacthead_for_amt"
					command_c["custacthead_invoiceno"] = @tbldata["invoiceno"]
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
		#
		###
		# def getcustord_from_linkcusts(tblname,tblid)  ### xxxactsからxxxordsを求める
		# 	ords = []
		# 	notords = [{"tblname" => tblname,"tblid" => tblid}]
		# 	until notords.empty? do
		# 		notord = notords.shift
		# 		strsql = %Q&
		# 				select * from linkcusts where tblname = '#{notord["tblname"]}' and tblid = #{notord["tblid"]}
		# 										and srctblname like 'cust%' and srctblname != tblname
		# 		&
		# 		ActiveRecord::Base.connection.select_all(strsql).each do |rec|
		# 			if rec["srctblname"] == "custords"
		# 				ords << rec
		# 			else
		# 				notords << rec
		# 			end
		# 		end
		# 	end
		# 	return ords
		# end 
    def setBillParams()
        {"segment" => "mkbillords",  ###必須項目
          "srctblname" => "custacts","srctblid" => @tbldata["id"],
          "seqno" => setParams["seqno"],###link_lotstkhists_update　と同時
          "gantt" => {"tblname" => "billords" ,"tblid" => @tbldata["id"],"paretblname" => "billords" },
          "tbldata" => @tbldata,###必須項目
          "last_amt" => @last_rec["amt"]||=@tbldata["amt"],"last_tax" =>  @last_rec["tax"]||=@tbldata["tax"],
          "last_taxrate" =>  @last_rec["taxrate"]||=@tbldata["taxrate"],
          "last_duedate" => @last_rec["rcptdate"]||=@tbldata["rcptdate"],
          "remark" => " class:#{self}, line:#{__LINE__} ",
          "seqno" => setParams["seqno"],###link_lotstkhists_update　と同時
          "trngantts_id" => 0,
          "person_id_upd" =>  setParams["person_id_upd"]}
    end


	  def check_shelfnos_duedate_qty(params)
      if @tblname =~ /^prd|^pur|^cust/ and @tblname =~ /schs$|ords$|insts$|reply|dlvs$|acts$|rets$/ and
        params["aud"] =~ /edit|update|purge|delete/
			  ### viewはr_xxxxxxsのみ
			  strsql = %Q&---最後に登録・修正されたレコード
				    select 	ope.itms_id itms_id,ope.processseq processseq,
					    sio.#{@tblname.chop}_prjno_id prjnos_id,
					    sio.#{@tblname.chop}_#{@str_starttime} starttime,
              sio.#{@tblname.chop}_#{@str_duedate} duedate,
					    sio.#{@tblname.chop}_#{@str_qty} #{@str_qty},
					    sio.#{@tblname.chop}_prjno_id prjnos_id,
					    #{@str_shelfnos_id},
              #{@str_suppliers_id},  ---prd,pur @str_shelfnos_id = shelfnos_id_to;custxxxs=shelfnos_id_fm
              sio.*
					  from sio.sio_r_#{@tblname} sio
					  inner join opeitms ope on ope.id = sio.#{@tblname.chop}_opeitm_id
					  where sio.id = #{@tbldata["id"]} 
					  and sio.#{@tblname.chop}_updated_at < cast('#{@tbldata["updated_at"]}' as timestamp)
					  order by sio_id desc limit 1
			      &
	  	  @last_rec = ActiveRecord::Base.connection.select_one(strsql)
	  	  @last_rec ||= {}
		    @last_rec["tblname"] = @tblname
		    @last_rec["tblid"] = @tbldata["id"]
      else
         strsql = %Q&---最後に登録・修正されたレコード
              select 	sio.*
                  from sio.sio_r_#{@tblname} sio
                  where sio.id = #{@tbldata["id"]} 
                  and sio.#{@tblname.chop}_updated_at < cast('#{@tbldata["updated_at"]}' as timestamp)
                  order by sio_id desc limit 1
                  &
          @last_rec = ActiveRecord::Base.connection.select_one(strsql)
          @last_rec ||= {}
		  end
      return if @last_rec == {}
		  if @tbldata[@str_qty].to_f != @last_rec[@str_qty].to_f  
			 @chng_flg << "qty"
		  end
		  if @tbldata[@str_duedate] != @last_rec["duedate"]
			  @chng_flg << "due"
		  end
		  if @tbldata["prjnos_id"] != @last_rec["prjnos_id"]
			  @chng_flg << "prjnos_id"
		  end
		  return 
	  end
	end  ###class
end   ##module Ror_blk
