# -*- coding: utf-8 -*-
# 2099/12/31を修正する時は　2100/01/01の修正も
module GanttChart
    extend self
    def  proc_mst_gantt  mst_code,id,gantt_reverse   ###opeims_idはある。
        ngantts = []  ### viewの内容なので　itm_id loca_id
        time_now =  Time.now
		case mst_code
		    when "itms"
		     ###itm = ActiveRecord::Base.connection.select_one("select * from itms where id = '#{id}'  ")
             rec = ActiveRecord::Base.connection.select_one("select * from r_opeitms where opeitm_itm_id = #{id} and opeitm_Expiredate > current_date
																order by opeitm_priority desc, opeitm_processseq desc,opeitm_Expiredate ")
		end
        if rec then
            ngantts << {:seq=>"001",:mlevel=>1,:itms_id=>rec["opeitm_itm_id"],:locas_id=>rec["opeitm_loca_id_opeitm"],:opeitms_id=>rec["id"],
								:itm_code=>rec["itm_code"],:itm_name=>rec["itm_name"],
								:loca_code=>rec["loca_code"],:loca_name=>rec["loca_name"],
								:parenum=>1,:chilnum=>1,:duration=>rec["opeitm_duration"],:prdpur=>rec["opeitm_prdpur"],
								:processseq=>"#{if params[:screen_code] =~ /_itms/ then '999' else  rec["opeitm_processseq"] end}",
								:priority=>"#{if params[:screen_code] =~ /_itms/ then '999' else rec["opeitm_priority"] end}",
								:starttime=>time_now,:duedate=>time_now,:id=>"opeitms_"+rec["id"].to_s}
            cnt = 0
            @bgantts = {}
			@bgantts["000"] = {:mlevel=>0,:itm_code=>"",:itm_name=>"全行程",:loca_code=>"",:loca_name=>"",:duration=>"",:assigs=>"",
								:duedate=>time_now,:starttime=>time_now,:depends=>"",:id=>"000"}
            until ngantts.size == 0
				cnt += 1
				ngantts = get_tree_pare_itms_locas ngantts,gantt_reverse  ###trngantt 作成時も利用
				break if cnt >= 1000
            end
          else
            return ""
        end
        prv_resch  	if params[:screen_code] =~ /^gantt/  ####再計算
        @bgantts["000"][:duedate] = @max_time
        @bgantts["000"][:duration] = " #{(@bgantts["000"][:duedate]  - @bgantts["000"][:starttime] ).divmod(24*60*60)[0]}"
        strgantt = '{"tasks":['
		i = 0
		dep ={}
        @bgantts.sort.each  do|key,value|
			dep[key] = i
			##opeitm = ActiveRecord::Base.connection.select_all("select * from r_opeitms where id = #{value[:opeitms_id]} ")
            strgantt << %Q&{"id":"#{value[:id]}","itm_code":"#{value[:itm_code]}","itm_name":"#{value[:itm_name]}",
			"loca_code":"#{value[:loca_code]}","loca_name":"#{value[:loca_name]}",
			"locas_id":"#{value[:loca_id]}","itms_id":"#{value[:itm_id]}",
            "parenum":"#{value[:parenum]}","chilnum":"#{value[:chilnum]}","start":#{value[:starttime].to_i.*1000},"duration":"#{value[:duration]}",
            "end":#{value[:duedate].to_i.*1000},"assigs":[],"depends":"#{if params[:screen_code] =~ /^reverse/ then dep[key[0..-4]]  else value[:depends] end}",
			"processseq":"#{value[:processseq]}","priority":"#{value[:priority]}","prdpur":"#{value[:prdpur]}",
			"level":#{if value[:mlevel] == 0 then 0 else 1 end},"mlevel":#{value[:mlevel]},"subtblid":"#{value[:subtblid]}","paretblcode":""},&
			i += 1
        end
        ## opeitmのsubtblidのopeitmは子のinsert用
        @ganttdata = strgantt.chop + %Q|],"selectedRow":0,"deletedTaskIds":[],"canWrite":true,"canWriteOnParent":true }|
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

    def  proc_trn_gantt  orgtblname,orgtblid,gantt,gkey,idx
		ActiveRecord::Base.connection.select_all(sql_trn_gantt_alloctbl(orgtblname,orgtblid)).each do |trn|
			break if idx > 1000
			gantt[gkey+trn["key"]] = trn
			tblname,tblid = get_ordtbl_ordid(trn["srctblname"],trn["srctblid"])
			gantt,idx = proc_trn_gantt(tblname,tblid,gkey+trn["key"],idx)
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
       
	###
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
		strsql = "select id from opeitms where itms_id = #{params[:tasks][@tree[key]][:itm_id]} and 
					locas_id_opeitm = #{params[:tasks][@tree[key]][:loca_id]} and
					processseq = #{params[:tasks][@tree[key]][:processseq]} and priority = #{params[:tasks][@tree[key]][:priority]}"
		pare_opeitm_id = ActiveRecord::Base.connection.select_value(strsql)
		if pare_opeitm_id
			###削除されてないか、再度確認
			##pare_opeitm_id = ActiveRecord::Base.connection.select_value("select id from opeitms where id = #{pare_opeitm_id} ")
			##if pare_opeitm_id
			yield
			update_nditm_rec(pare_opeitm_id,value ,command_r)
			##else
			##	@ganttdata[key]  = {:itm_name=>"opeitm not exists line #{__LINE__} ,opeitm_id = #{pare_opeitm_id} "}
			##end
		else
			@ganttdata[key][:itm_name] = @err = "opeitm is null line #{__LINE__} ,opeitm_id = #{pare_opeitm_id} "
		end
	end
	def chk_alreadt_exists_nditm(command_r)
		strsql = "select 1 from nditms where  opeitms_id = #{command_r["nditm_opeitm_id"]} and  itm_id_nditm = #{command_r["nditm_itm_id_nditm"]} and
					processseq_nditm = #{command_r["nditm_processseq_nditm"]} and   locas_id_nditm  = #{command_r["nditm_loca_id_nditm"]} "
		if ActiveRecord::Base.connection.select_one (strsql)
			@ganttdata[key][:itm_name] = @err = " ??? !!! already exists !!!"
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
				proc_simple_sio_insert command_r  if @err == "no"
			else
				@ganttdata[key][:loca_code] =  @err = "???"
			end
		else
			@ganttdata[key][:itm_code] = @err = "???"
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
				@ganttdata[key][:itm_name] = @err = "logic error LINE : #{__LINE__}"
			end
		else
			if copy_opeitm
				update_opeitm_from_gantt(copy_opeitm,value ,command_r)do
					command_r["sio_classname"] = "_add_opeitm_rec"
					command_r["opeitm_id"] = command_r["id"] = ArelCtl.proc_get_nextval("opeitms_seq")
				end
				params[:tasks][key][:opeitms_id] = command_r["opeitm_id"]
			else
				@ganttdata[key][:copy_itemcode] = @err = "???"
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
				@ganttdata[key][:itm_name] = @err = "logic error  line #{__LINE__} "
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
							@ganttdata[key][:prdpur] = @err = "???"
						end
					else ###作業の一貫性
						@ganttdata[key][:priority] = @err = "???"
					end
				else  ###seq error
					@ganttdata[key][:processseq] = @err = "???"
				end
			else   ###nditms追加
				if  value[:processseq] =~ /999|1000/  ###品目違いの時はprocessseq == 999
					value[:processseq] = "999"
					if (params[:tasks][@tree[key]][:priority] > value[:priority] and params[:tasks][@tree[key]][:priority] == 999) or params[:tasks][@tree[key]][:priority] == value[:priority]
						if value[:itm_id] != "" and value[:loca_id] != ""
							strsql = "select id from opeitms where itms_id = #{value[:itm_id]} and 
																locas_id_opeitm = #{value[:loca_id]} and processseq = #{value[:processseq]} and priority = #{value[:priority]} "
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
										command_r = {}
										command_r["sio_user_code"] = $person_code_chrg
										command_r["sio_session_counter"] =   @sio_session_counter
										exits_nditm_from_gantt(key,value ,command_r)
									else
										@ganttdata[key][:copy_itemcode] = @err = "???"
									end
								else
									exits_nditm_from_gantt(key,value ,command_r)
								end
							else
								@ganttdata[key][:prdpur] = @err = "???"
							end
						else
							@ganttdata[key][:itm_code] = @ganttdata[key][:loca_code] = @err = "???"
						end
					else ###作業の一貫性
						@ganttdata[key][:priority] = @err = "???"
					end
				else  ###seq error
					@ganttdata[key][:processseq] = @err = "???"
				end
			end
		else
			### topの時
			if value[:processseq]  == "999"
				if  value[:priority]
					if value[:prdpur] =~ /^prd|^pur/  ### prd,pur,shp以外に増えたときの対応
						exits_opeitm_from_gantt(key,value ,command_r)
					else
						@ganttdata[key][:prdpur] = @err = "???"
					end
				else ###作業の一貫性
					@ganttdata[key][:priority] = @err = "???"
				end
			else  ###seq error
				@ganttdata[key][:processseq] = @err = "???"
			end
		end
	end
	def uploadgantt   ### trnは別
		ActiveRecord::Base.connection.begin_db_transaction()
        $person_code_chrg =  ActiveRecord::Base.connection.select_value("select id from persons where email = '#{$email}'")   ###########   LOGIN USER
		@sio_session_counter = user_seq_nextval
		@ganttdata = params[:tasks]
		@err = "no"
		@tree = {}   ###親のid
		err = false
        params[:tasks].each do |key,value|
			value[:depends].split(",").each do |i|  ###子の親は必ず1つ　副産物も子として扱う
				@tree[i] = key
			end
			command_r = {}
			command_r["sio_user_code"] = $person_code_chrg
			command_r["sio_session_counter"] =   @sio_session_counter
			case value[:id]
                when  "000" then
                ##top record
                   next
                when /gantttmp/  then ### レコード追加
					if value[:itm_id] and  value[:processseq] =~ /[000-1000]/ and value[:priority] =~ /[000-999]/
						chk_opeitm_nditm_from_gantt(key,value ,command_r)
					else
						if value[:itm_id].nil? then @ganttdata[key][:itm_code] = @err= "???" end
						if value[:processseq] !~ /[000-1000]/  then @ganttdata[key][:processseq] = @err = "???"  end
						if value[:priority] !~ /[000-999]/ then @ganttdata[key][:priority] = @err = "???" end
					end
                when /opeitms/   ###追加更新もある?\
					params[:tasks][key][:opeitms_id] = value[:id].split("_")[1].to_i
					chk_opeitm_nditm_from_gantt(key,value ,command_r)
				when /nditms/
					params[:tasks][key][:nditms_id] = value[:id].split("_")[1].to_i
					chk_opeitm_nditm_from_gantt(key,value ,command_r)  ### 子品目から前工程に変更されることもある。
				else
				    logger.debug "#{Time.now} #{__LINE__} new option????? not support   value #{value}"
            end
        end
		###画面のラインを削除された時
		if params[:deletedTaskIds] and @err == "no"
			params[:deletedTaskIds].each do |del_rec|
				tbl,id = del_rec.split("_")
				command_r = {}
				command_r["sio_user_code"] = $person_code_chrg
				command_r["sio_session_counter"] =   @sio_session_counter
				case tbl
					when "nditms"
						command_r["sio_classname"] = "_delete_nditm_rec"
						command_r["nditm_id"] = command_r["id"] = id.to_i
						command_r["sio_viewname"]  = command_r["sio_code"] = @screen_code = "r_nditms"
					when "opeitms"
						command_r["sio_classname"] = "_delete_opeitm_rec"
						command_r["opeitm_id"] = command_r["id"] = id.to_i
						command_r["sio_viewname"]  = command_r["sio_code"] = @screen_code = "r_opeitms"
				end
				proc_simple_sio_insert command_r
			end
		end
		if @err == "no"
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
				"end":#{value[:end]},"assigs":[],"depends":"#{value[:depends]}",
				"processseq":"#{value[:processseq]}","priority":"#{value[:priority]}","prdpur":"#{value[:prdpur]}",
				"level":#{if value[:mlevel] == 0 then 0 else 1 end},"mlevel":#{value[:mlevel]},"subtblid":"#{value[:subtblid]}","paretblcode":""},&
			end
        ## opeitmのsubtblidのopeitmは子のinsert用
			@ganttdata = strgantt.chop + %Q|],"selectedRow":11,"deletedTaskIds":[],"canWrite":true,"canWriteOnParent":true }|
			####@ganttdata= %Q%["aaa":"bbb"}%
			render :json=>@ganttdata
		end
	end
	def prv_resch   ##本日を起点に再計算
        dp_id = 0
        @bgantts.sort.each  do|key,value|    ###set depends
           if key.size > 3 then
             @bgantts[key[0..-4]][:depends] << dp_id.to_s + ","
			 @bgantts[key[0..-4]][:duration] = 0  if @bgantts[key[0..-4]][:itm_id] != @bgantts[key][:itm_id]
           end
           dp_id += 1
        end

			today = Time.now
			@bgantts.sort.reverse.each  do|key,value|  ###計算
				if key.size > 3  ###master は分割はない
					if  value[:depends] == ""
						if @bgantts[key][:starttime]  <  today
							@bgantts[key][:starttime]  =  today
							@bgantts[key][:duedate]  =   @bgantts[key][:starttime] + value[:duration]*24*60*60    ###稼働日考慮今なし
						end
					end
					debugger if @bgantts[key][:duedate].nil? or @bgantts[key[0..-4]][:starttime].nil?
					if  (@bgantts[key[0..-4]][:starttime] ) < @bgantts[key][:duedate]
						@bgantts[key[0..-4]][:starttime]  =   @bgantts[key][:duedate]   ###稼働日考慮今なし
						@bgantts[key[0..-4]][:duedate] =  @bgantts[key[0..-4]][:starttime]  + @bgantts[key[0..-4]][:duration] *24*60*60
					end
				end
			end

			@bgantts.sort.each  do|key,value|  ###topから再計算
				if key.size > 3
					if  (@bgantts[key[0..-4]][:starttime]  ) > @bgantts[key][:duedate]
						@bgantts[key][:duedate]  =   @bgantts[key[0..-4]][:starttime]    ###稼働日考慮今なし
						@bgantts[key][:starttime] =  @bgantts[key][:duedate]  - value[:duration] *24*60*60
					end
				end
			end
      return
    end   

    def get_tree_pare_itms_locas ngantts,gantt_reverse ### bgantt 表示内容　ngantt treeスタック  itms_idは必須
      n0 = ngantts.shift
	    if n0.size > 0  ###子部品がいなかったとき{}になる。
				case gantt_reverse
				when /gantt/
					starttime,duedate = get_item_loca_contents(n0,gantt_reverse)
					tmp = proc_get_ganttchart_data(opeitms_id)
					ngantts.concat(tmp) if tmp[0].size > 0
					tmpx = vproc_get_prev_process(n0,starttime)
					if tmpx[0].size > 0
							ngantts.concat(tmpx)
					else
							if tmp[0].size == 0 and n0[:processseq] == 999 and n0[:consumtype] == "CON"
								tmp = vproc_set_dummy_process(n0,starttime)
								ngantts.concat(tmp)
							end
					end
				when /reverse/
					starttime,duedate = get_item_loca_contents(n0,gantt_reverse)
					tmp = vproc_get_pare_itms(n0,duedate)
					ngantts.concat(tmp) if tmp[0].size > 0
					tmp = vproc_get_after_process(n0,duedate)
					ngantts.concat(tmp) if tmp[0].size > 0
				end
	    end
        return ngantts
    end  ##


    def prv_resch_trn   ##本日を起点に再計算
        dp_id = 0
        @bgantts.sort.each  do|key,value|    ###set depends
            if key.to_s.size > 3 then
                @bgantts[key[0..-4]][:depends] << dp_id.to_s + ","
				@bgantts[key[0..-4]][:duration] = 0  if @bgantts[key[0..-4]][:itm_id] != @bgantts[key][:itm_id]
            end
            dp_id += 1
        end

        today = Time.now
        @bgantts.sort.reverse.each  do|key,value|  ###計算
		    if key.size > 3
                if  value[:depends] == ""
		    	    if @bgantts[key][:starttime_est]  <  today
                       @bgantts[key][:starttime_est]  =  today
                       @bgantts[key][:duedate_est]  =   proc_get_starttime(@bgantts[key][:starttime_est], (value[:duration]||=1)*-1,"day",nil)    ###稼働日考慮今なし
                    end
			    end
                if  (@bgantts[key[0..-4]][:starttime_est] ) < @bgantts[key][:duedate_est]
                    @bgantts[key[0..-4]][:starttime_est]  =   @bgantts[key][:duedate_est]   ###稼働日考慮今なし
                    @bgantts[key[0..-4]][:duedate_est] =  proc_get_starttime(@bgantts[key[0..-4]][:starttime_est],@bgantts[key[0..-4]][:duration]*-1,"day",nil)
				    ##p key
				    ##p @bgantts[key]
			    end
            end
        end
        @bgantts.sort.each  do|key,value|  ###topから再計算
		    if key.size > 3
                if  (@bgantts[key[0..-4]][:starttime_est]  ) > @bgantts[key][:duedate_est]
                      @bgantts[key][:duedate_est]  =   @bgantts[key[0..-4]][:starttime_est]    ###稼働日考慮今なし
                      @bgantts[key][:starttime_est] =  proc_get_starttime(@bgantts[key][:duedate_est],(value[:duration]||=1) ,"day",nil)
                end
            end
        end
        return
    end
    def proc_get_starttime duedate,duration,period,type
        case type
            when nil
                case period
                    when "day"
                    duedate - duration * 24 * 60* 60
                end
        end
    end
    def get_duration_by_loca(loca_id_fm,loca_id_to,priority)
        {:duration=>1,:transport_id =>ActiveRecord::Base.connection.select_value("select id from transports where code = 'dummy' ")}
    end
    def get_opeitms_id_from_itm itms_id ###
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
	
    def get_opeitms_id_from_itm_by_processseq itms_id,processseq  ###
			strsql = %Q& select max(priority) from opeitms where itms_id = #{itms_id} 
					 and processseq =#{processseq} and expiredate > current_date group by itms_id &
			max_priority = ActiveRecord::Base.connection.select_value(strsql)
			if max_priority
				strsql = %Q& select id from opeitms where itms_id = #{itms_id} 
						 and processseq =#{processseq} and priority =#{max_priority} and expiredate > current_date &
				opeitms_id = ActiveRecord::Base.connection.select_value(strsql)
			else 
				opeitms_id = nil	
			end		
		return opeitms_id
	end
	
	def get_item_loca_contents(n0,gantt_reverse)   ##n0[:itms_id] r0[:itms_id]
	    qty = if n0[:seq].size > 4 then (@bgantts[n0[:seq][0..-4]][:qty] ||= 1) else  (@bgantts["000"][:qty] ||= 1) end
	    new_qty = qty.to_f / (n0[:parenum]||=1) * (n0[:chilnum]||=1)
		###:autocreate_instは画面にはセットしない。
		if gantt_reverse =~ /mst$/
			itm = ActiveRecord::Base.connection.select_one("select * from itms where id = #{n0[:itms_id]}  ")
			loca = ActiveRecord::Base.connection.select_one("select * from locas where id = #{n0[:locas_id]}  ")
			bgantt = {:mlevel=>n0[:mlevel],:itm_code=>itm["code"], :itm_name=>itm["name"],
								:loca_code=>loca["code"],:loca_name=>loca["name"],
								:duration=>(n0[:duration]||=1),:depends=>"",:shelfnos_id=>n0[:shelfnos_id],:shuffleflg=>n0[:shuffleflg],
								 :parenum=>n0[:parenum]||=1,:chilnum=>n0[:chilnum]||=1,:prdpur=>n0[:prdpur],
								 :consumtype=>n0[:consumtype],
                                 :id=>n0[:id],:itms_id=>n0[:itms_id],:locas_id=>n0[:locas_id],
								:autocreate_inst=>n0[:autocreate_inst],
								:processseq=>n0[:processseq],:priority=>n0[:priority],:qty=>new_qty,:qty_src=>new_qty,:qty_stk=>0,
								:opeitms_id => n0[:opeitms_id]}
		else  ###trngantts insert 用
			bgantt = {:mlevel=>n0[:mlevel],###:itm_code=>itm["code"], :itm_name=>itm["name"],:loca_code=>loca["code"],:loca_name=>loca["name"],
								:duration=>(n0[:duration]||=1),:depends=>"",
								:parenum=>n0[:parenum]||=1,:chilnum=>n0[:chilnum]||=1,:prdpur=>n0[:prdpur],
								:consumtype=>n0[:consumtype],
								:shelfnos_id=>n0[:shelfnos_id],:shuffleflg=>n0[:shuffleflg],
                                :id=>n0[:id],:itms_id=>n0[:itms_id],:locas_id=>n0[:locas_id],
								:autocreate_inst=>n0[:autocreate_inst],
								:processseq=>n0[:processseq],:priority=>n0[:priority],:qty=>new_qty,:qty_src=>new_qty,:qty_stk=>0}
		end
		case gantt_reverse
			when /gantt/
				cgantt = {:duedate=>n0[:duedate],:duedate_est=>n0[:duedate],
									:starttime=>proc_get_starttime(n0[:duedate],(n0[:duration]||=1),"day",nil),
									:starttime_est=>proc_get_starttime(n0[:duedate],(n0[:duration]||=1),"day",nil)}
			when /reverse/
				cgantt = {:starttime=>n0[:starttime],:starttime_est=>n0[:starttime],
									:duedate=>proc_get_starttime(n0[:starttime],(n0[:duration]||=1)*-1,"day",nil),
									:duedate_est=>proc_get_starttime(n0[:starttime],(n0[:duration]||=1)*-1,"day",nil)}
		end
        bgantt.merge! cgantt
		@bgantts[n0[:seq]] = bgantt
	    @min_time = cgantt[:starttime] if (@min_time||="2099/12/31".to_time) > cgantt[:starttime]
		@max_time = cgantt[:duedate] if (@max_time||=Time.now)  < cgantt[:duedate]
        return cgantt[:starttime],cgantt[:duedate]
	end
	
	def proc_get_ganttchart_data(id)  ###工程の始まり=前工程の終わり
		@ganttchartData = {}
		@stacklevel = []
		@stacklevel << [id,"0"]  
		until @stacklevel == []
			opeitms_id,level = @stacklevel.shift
			start = Time.now - 1* 24 * 60 * 60 
			strsql = "select  * from r_opeitms where id = #{opeitms_id}"
			rec = ActiveRecord::Base.connection.select_one(strsql)
			if level == "0"
				@ganttchartData[level] = {"opeitm_id"=>opeitms_id,"duration"=>1,"start"=>start,
									"end"=>Time.now,
									"parenum"=>1,"chilnum"=>1,"itms_id"=>nil,
									"itm_code"=>rec["itm_code"],"itm_name"=>rec["itm_name"]}
			end
			new_end = @ganttchartData[level]["start"] -  24 * 60 * 60 
			strsql = "select * from r_nditms where nditm_opeitm_id = #{opeitms_id} 
						and nditm_Expiredate > current_date order by itm_code_nditm  "
			rnditms = ActiveRecord::Base.connection.select_all(strsql)
			depend = []
			rnditms.each_with_index  do |rec,idx|
				nopeitms_id = get_opeitms_id_from_itm_by_processseq(rec["nditm_itm_id_nditm"],
																rec["nditm_processseq_nditm"])
				duration = rec["nditm_duration"].to_i
				new_start = new_end - (rec["opeitm_duration"].to_i) * 24 * 60 * 60 
				contents = {"opeitm_id"=>nopeitms_id,
						"start"=>new_start,
						"end"=>new_end,
						"parenum"=>rec["nditm_parenum"],"chilnum"=>rec["nditm_chilnum"],
						"itms_id"=>rec["itm_id_nditm"],"itm_code"=>rec["itm_code_nditm"],
						"itm_name"=>rec["itm_name_nditm"]}
				nlevel = level + "_" + format('%04d', idx)
				@ganttchartData[nlevel] = contents
				@stacklevel << [nopeitms_id,nlevel]
				depend << nlevel
			end
			@ganttchartData[level]["depend"] = depend.join(",")   ###親の依存を調べる。
		end	
		return @ganttchartData
	end
	
	def vproc_get_prev_process(n0,starttime)  ###工程の始まり=前程の終わり
		strsql = "select ope.* from opeitms ope
						inner join itms itm on itm.id = ope.itms_id and itm.processseq.ope.processseq 
						where ope.itms_id = #{n0[:itms_id]} and ope.Expiredate > current_date
						and ope.Priority = #{n0[:priority]} and ope.processseq < #{n0[:processseq]}  order by   ope.processseq desc"
        rec = ActiveRecord::Base.connection.select_one(strsql)
        if rec
             ngantts = []
				  ngantts << {:seq=>(n0[:seq] + "000"),:mlevel=>n0[:mlevel]+1,:itms_id=>rec["itms_id"],
							:locas_id=>rec["locas_id"],:opeitms_id=>rec["id"],
                            :locas_id_to=>n0[:locas_id],:shelfnos_id=>rec["shelfnos_id"],:shuffleflg=>rec["shuffleflg"],
                            :duedate=>starttime,:prdpur=>rec["prdpur"],:duration=>(rec["duration"]||=1),
                            :parenum=>rec["parenum"],:chilnum=>rec["chilnum"],
                            :autocreate_inst=>rec["autocreate_inst"],
                            :consumtype=>rec["consumtype"],
							:safestkqty=>rec["safestkqty"],:id=>"opeitms_"+rec["id"].to_s,
							:priority=>rec["priority"],:processseq=>rec["processseq"],
                            :starttime => proc_get_starttime(starttime ,(rec["duration"]||=1),"day",nil)}  ###基準日　期間　タイプ　休日考慮
          else
            ngantts = [{}]
        end
        return ngantts
	end
	
    def vproc_get_pare_itms(n0,duedate)  ###
          strsql = "select nditm.* from nditms nditm 
							where itms_id_nditm = #{n0[:itms_id]} and locas_id_nditm = #{n0[:locas_id]} 
							and processseq_nditm = #{n0[:processseq]} and Expiredate > current_date  "
          nditms = ActiveRecord::Base.connection.select_all(strsql)
          if nditms.size > 0 then
              ngantts = []  ###viewの内容なので　itm_id  loca_id
              mlevel = n0[:mlevel] + 1
              nditms.each.with_index(1)  do |i,cnt|
                  ope = ActiveRecord::Base.connection.select_one("select * from opeitms where id = #{i["opeitms_id"]} ")
                  if ope
                      np= {:parenum => i["chilnum"],:chilnum => i["parenum"],:prdpur => ope["prdpur"],:consumtype => i["consumtype"],
                              :opeitms_id => i["opeitms_id"],
                              :itms_id => ope["itms_id"],:locas_id => ope["locas_id"],:processseq=>ope["processseq"],:priority=>ope["priority"],
                              :seq=>n0[:seq] + sprintf("%03d", cnt),:mlevel=>mlevel,:level=>1,
                              :starttime=>duedate,:duration=>(i["duration"]||=1),:duedate=> proc_get_starttime(n0[:duedate] ,(i["duration"]||=1)*-1,"day",nil),
                              :id=>"nditms_"+i["id"].to_s}  ###
                      ngantts << np
                 else
                      3.times{Rails.logger.debug "logic error opeitms missing  line :#{__LINE_} select * from opeitms where id = #{i["opeitms_id"]} "}
                      @errmsg =  "logic error opeitms missing  line :#{__LINE_} select * from opeitms where id = #{i["opeitms_id"]} "
                      raise
                 end
              end
          else
              ngantts  = [{}]
          end
          return ngantts
    end

    def vproc_get_after_process(n0,duedate)  ###工程の始まり=前程の終わり
        rec = ActiveRecord::Base.connection.select_one("select * from opeitms where itms_id = #{n0[:itms_id]} and Expiredate > current_date
                                                                              and Priority = #{n0[:priority]} and processseq > #{n0[:processseq]}  order by   processseq ")
        if rec
             ngantts = []
             ngantts << {:seq=>(n0[:seq] + "000"),:mlevel=>n0[:mlevel]+1,:itms_id=>rec["itms_id"],:locas_id=>rec["locas_id"],:opeitms_id=>rec["id"],
             :locas_id_to=>n0[:locas_id],:prdpur=>rec["prdpur"],:duedate=>proc_get_starttime(duedate,(rec["duration"]||=1)*-1,"day",nil),
             :duration=>(rec["duration"]||=1),:parenum=>rec["parenum"],:chilnum=>rec["chilnum"],:shelfnos_id=>rec["shelfnos_id"],:shuffleflg=>rec["shuffleflg"],
             :autocreate_inst=>rec["autocreate_inst"],
             :safestkqty=>rec["safestkqty"],:id=>"opeitms_"+rec["id"].to_s,:priority=>rec["priority"],:processseq=>rec["processseq"],
              :starttime => duedate } ##基準日　期間　タイプ　休日考慮
          else
            ngantts = [{}]
        end
        return ngantts
      end

	####################################
	##################################
	
	def aaa orgtblname,orgtblid
		gantt = {}
		idx = 0
		gkey = ""
		gantt,idx = proc_trn_gantt(orgtblname,orgtblid,gantt,gkey,idx)
		@bgantts = {}
		save_pare_key = {}
		gantt.each do |key,value|    ### value=>trngantts   rec=>alloctblkの該当テーブルのview 
			strsql = %Q&
						select * from r_#{value["alloc_tblname"]} where id = #{value["alloc_tblid"]}
			&
			rec =  ActiveRecord::Base.connection.select_one(strsql)
			@bgantts[key] = {:id=>key,
					:itm_id=>value["itms_id"],:itm_code=>rec["itm_code"],:itm_name=>rec["itm_name"],
			        :loca_code=>case value["alloc_tblname"] 
								when /^pur/
									rec["loca_code_supplier"]
								when /^prd/
									rec["loca_code_workplace"]
								end,
					:loca_name=>case value["alloc_tblname"] 
								when /^pur/
									rec["loca_name_supplier"]
								when /^prd/
									rec["loca_name_workplace"]
								end,
					:loca_id=>value["locas_id"],
					:parenum=>value["parenum"],:chilnum=>value["chilnum"],
                    :duration=>value["duration"],
					:sno=>rec["#{value["alloc_tblname"].chop}_sno"],
					:qty=>(rec["#{value["alloc_tblname"].chop}_qty"]||=0),
					:qty_sch=>(rec["#{value["alloc_tblname"].chop}_qty_sch"]||=0),
					:qty_stk=>(rec["#{value["alloc_tblname"].chop}_qty_stk"]||=0),
					:starttime=> value["starttime"],
					:processseq=>value["processseq"],
                    :org_duedate=>value["duedate"],
					:duedate=>case value["alloc_tblname"] 
								when /^purschs|^purords|^purinsts|^prdschs|^prdords|^prdinsts/
									rec["#{value["alloc_tblname"].chop}_duedate"]
								when /^puracts/
									rec["puract_rcptdate"]
								when /^prdacts/
									rec["prdact_cmpldate"]
								end,
					:assigs=>[],
					:mlevel=>value["mlevel"],:subtblid=>"",:paretblcode=>"",:depends=>""}
			case value["srctblname"]
				when /^cust/
					@bgantts[sprintf("%04d",idx)][:loca_code] = alloc["loca_code_cust"]
					@bgantts[sprintf("%04d",idx)][:loca_name] = alloc["loca_name_cust"]
					@bgantts[sprintf("%04d",idx)][:loca_id] = alloc["#{value["alloctbl_destblname"].chop}_loca_id_cust"]
					@bgantts[sprintf("%04d",idx)][:starttime] = alloc["#{value["alloctbl_destblname"].chop}_isudate"]
					@bgantts[sprintf("%04d",idx)][:duedate] = alloc["#{value["alloctbl_destblname"].chop}_duedate"]
				when /^dlv/
					@bgantts[sprintf("%04d",idx)][:loca_code] = alloc["loca_code_to"]
					@bgantts[sprintf("%04d",idx)][:loca_name] = alloc["loca_name_to"]
					@bgantts[sprintf("%04d",idx)][:loca_id] = alloc["#{value["alloctbl_destblname"].chop}_loca_id_to"]
					@bgantts[sprintf("%04d",idx)][:starttime] = alloc["#{value["alloctbl_destblname"].chop}_depdate"]
					@bgantts[sprintf("%04d",idx)][:duedate] = alloc["#{value["alloctbl_destblname"].chop}_duedate"]
				when /^prd|^pur/
					@bgantts[sprintf("%04d",idx)][:loca_code] = alloc["loca_code"]
					@bgantts[sprintf("%04d",idx)][:loca_name] = alloc["loca_name"]
					@bgantts[sprintf("%04d",idx)][:loca_id] = alloc["#{value["alloctbl_destblname"].chop}_loca_id"]
					@bgantts[sprintf("%04d",idx)][:starttime] = alloc["#{value["alloctbl_destblname"].chop}_starttime"]
					@bgantts[sprintf("%04d",idx)][:duedate] = alloc["#{value["alloctbl_destblname"].chop}_duedate"]
					case value["alloctbl_destblname"]
						when /^prdacts/
							@bgantts[sprintf("%04d",idx)][:duedate] = alloc["prdact_cmpldate"]
						when /^puracts|^ipracts/
							@bgantts[sprintf("%04d",idx)][:duedate] = alloc["puract_rcptdate"]
					end
				else
					##logger.debug"error class #{self}   #{Time.now}  alloctbl_destblname: #{value["alloctbl_destblname"]} "
					##raise
					@bgantts[sprintf("%04d",idx)][:loca_code] = ""
					@bgantts[sprintf("%04d",idx)][:loca_name] = ""
					@bgantts[sprintf("%04d",idx)][:loca_id] = 0
					@bgantts[sprintf("%04d",idx)][:starttime] = Time.now
					@bgantts[sprintf("%04d",idx)][:duedate] =  Time.now
			end
			save_pare_key[value["trngantt_key"]] = sprintf("%04d",idx)
			pare_key = if save_pare_key[value["trngantt_key"][0..-4]] then  save_pare_key[value["trngantt_key"][0..-4]] else nil end
			@bgantts[pare_key][:depends] << idx.to_s + "," if pare_key
			strgantt = '{"tasks":['
			@bgantts.sort.each  do|key,gantt|
				strgantt << %Q&{"id":"#{gantt[:id]}","itm_code":"#{gantt[:itm_code]}","itm_name":"#{gantt[:itm_name]}",
				"loca_code":"#{gantt[:loca_code]}","loca_name":"#{gantt[:loca_name]}",
				"loca_id":"#{gantt[:loca_id]}","itm_id":"#{gantt[:itm_id]}",
				"start":#{gantt[:starttime].to_i*1000},"org_start":#{gantt[:org_start]},"end":#{gantt[:duedate].to_i*1000},"org_end":#{gantt[:org_end]},
				"prdpur":"#{gantt[:prdpur]}","sno":"#{gantt[:sno]}",
				"qty":#{gantt[:qty]},"qty_sch":#{gantt[:qty_sch]},"qty_ord":#{gantt[:qty_ord]},"qty_inst":#{gantt[:qty_inst]},"qty_stk":#{gantt[:qty_stk]},
				"processseq":#{gantt[:processseq]},"priority":#{gantt[:priority]},"parenum":"#{gantt[:parenum]}","chilnum":"#{gantt[:chilnum]}","duration":"#{gantt[:duration]}",
				"assigs":[],"level":#{gantt[:level]},"mlevel":#{gantt[:mlevel]},"subtblid":"#{gantt[:subtblid]}","paretblcode":"","depends":"#{(gantt[:depends]||="").chop}"},&
			end
			@ganttdata = strgantt.chop + %Q&],"selectedRow":0,"deletedTaskIds":[],"canWrite":true,"canWriteOnParent":true }&
		end
	end
end    