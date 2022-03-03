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

  	def  proc_pdfwhere pdfscript,command_c
	    reports_id = pdfscript[:id]
	    viewname = command_c[:sio_viewname]
        tmpwhere = proc_strwhere command_c
        case  params[:initprnt]
            when  "1"  then
	            tmpwhere <<  if tmpwhere.size > 1 then " and " else " where " end
	            tmpwhere << "   not exists (select 1 from HisOfRprts x
                                   where lower(tblname) = '#{viewname}' and #{viewname.split('_')[1].chop}_id = recordid
				                and reports_id = #{reports_id}) "
		end
        case  params[:afterprnt]
            when  "1"  then
	            tmpwhere <<  if tmpwhere.size > 1 then " and " else " where " end
	            tmpwhere << " exists (select 1 from  (select max(updated_at) updated_at ,recordid
     							       from HisOfRprts x where reports_id = #{reports_id}
     								   group by reports_id,recordid )
								   where id = recordid and  #{viewname.split("_")[1].chop}_updated_at > updated_at )"
		end
        if params[:whoupdate] == '1' then
	        	tmpwhere <<  if tmpwhere.size > 1 then " and " else " where " end
	        	tmpwhere << " person_code_upd = '#{$person_code_chrg}'"
        end
        if pdfscript[:pobject_code_rep] =~ /order_list/ then
	        	tmpwhere <<  if tmpwhere.size > 1 then " and " else " where " end
	        	tmpwhere << "  #{pdfscript[:pobject_code_view].split('_')[1].chop}_confirm  in('1','5')  "   ##order_listの時は確定又は確認済しか印刷しない
        end
        	##if params[:
        return tmpwhere
    end

    
	def proc_get_nextval tbl_seq
		ActiveRecord::Base.uncached() do
			case ActiveRecord::Base.configurations[Rails.env]['adapter']
				when /post/
					ActiveRecord::Base.connection.select_value("SELECT nextval('#{tbl_seq}')")  ##post
				when /oracle/
					ActiveRecord::Base.connection.select_value("select #{tbl_seq}.nextval from dual")  ##oracle
			end
		end
	end
	
	def proc_processreqs_add reqparams
		processreqs_id = ArelCtl.proc_get_nextval("processreqs_seq")
		if reqparams["seqno"].nil?
			reqparams["seqno"] = []
		end	
		strsql = %Q%select id from persons where email = '#{$email}'
		%
		person_id = ActiveRecord::Base.connection.select_value(strsql)
		reqparams["seqno"] << processreqs_id  ###
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
						'',#{person_id},'#{reqparams.to_json}',
						#{reqparams["seqno"][0]},#{processreqs_id},'0')
		&
		ActiveRecord::Base.connection.insert(strsql) 
		return processreqs_id,reqparams
	end

	def proc_createtable fmtbl,totbl,fmview,add_or_update  ###fmtbl:元のテーブル totbl:fmtblから自動作成するテーブル
		strsql = %Q% select pobject_code_sfd from  func_get_screenfield_grpname('#{$email}','r_#{totbl}')
		%
		torecs = ActiveRecord::Base.connection.select_values(strsql) 
		blk = RorBlkCtl::RorClass.new("r_#{totbl}")
		command_c = blk.command_init
		torecs.each do |key|
			prevkey = key.to_s.gsub(totbl.chop,fmtbl.chop)
			case key.to_s
			when /^id$/ 
				if add_or_update =~ /_add_|_insert_/
					command_c["id"] = ""
				else
					command_c["id"] = fmview["id"]
				end
			when /_sno$|_cno$|_gno$/ 
				if add_or_update =~ /_add_|_insert_/
					command_c[key] = ""
				else
					command_c[key] = fmview[prevkey]
				end
			when /_amt|_qty/   ###例：qty_schとqtyは同一項目とみなす
				if fmview[prevkey]
					if key.to_s.split(/_amt|_qty/)[0] == prevkey.to_s.split(/_amt|_qty/)[0]
						command_c[key] = fmview[prevkey]
					end
				end
			else
				if torecs.index(prevkey)
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
				when /^pay/
					###支払日の計算　要
				when /^prdords/
					command_c["prdord_sno_puract"] =  fmview["prdact_sno"]
					command_c["prdord_duedate"] =  fmview["puract_rcptdate"].to_date + 1  ###!!!稼働日考慮要
				end
			when /^prdacts/
				case totbl
				when /pay/
					strsql = %Q&
							select * from r_putacts where puract_sno = '#{fmview["prdact_sno_puract"]}'
						&
					puract = ActiveRecord::Base.connection.select_one(strsql)
					torecs.each do |key|
						prevkey = key.to_s.gsub("payord","prdact")
						case key.to_s
						when /^id$/ 
							if add_or_update =~ /_add_|_insert_/
								command_c["id"] = ""
							else
								command_c["id"] = fmview["id"]
							end
						when /_sno$|_cno$|_gno$/ 
							if add_or_update =~ /_add_|_insert_/
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
							if torecs.index(prevkey)
								command_c[key] = puract[prevkey]
							end	
						end
					end
					###支払日の計算　要
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
		command_c[:sio_classname] =
			if add_or_update =~ /_add_|_insert_/
				"_add_proc_createtable_data"
			else
				"_update_proc_createtable_data"
			end
		blk.proc_create_src_tbl(command_c)
		blk.proc_private_aud_rec({},command_c)
		##payschs,billschsの修正
		case fmtbl
		when /^custdlvs|^custacts/
			case totbl
			when /^billords/
				consume_amt_sch_by_act fmtbl,fmview["id"],"billschs"
			end
		when /^puracts/
			case totbl
			when /^payords/
				consume_amt_sch_by_act fmtbl,fmview["id"],"payschs"
			end
		when /^prdacts/  ###opeitms.operation=prdinspの時
			case totbl
			when /^payords/
				consume_amt_sch_by_act fmtbl,fmview["id"],"payschs"
			end
		end
		blk.proc_create_src_tbl(command_c)
		blk.proc_private_aud_rec({},command_c)
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
					linl_sql = %Q&select sum(qty_linkto_alloctbl) from linktbls 
									where  srctblname = #{link["srctblname"]} and srctblid = #{link["srctblid"]} 
									group by srctblname,srctblid
									&
					link_rec = ActiveRecord::Base.connection.select_one(link_sql)
					prev_sql = %Q&select * from #{link["srctblname"]} 	where  srctblid = #{link["srctblid"]} 
									&
					prev_rec = ActiveRecord::Base.connection.select_one(link_sql)
					amt_sch = prev_rec["amt"].to_f - link_rec["qty_linkto_alloctbl"].to_f * prev_rec["price"]
					tax = amt_sch * taxrate
					amt_sch_sql = %Q& select * from  r_#{prev_totbl} 
										where  #{prev_totbl.chop}_sno_#{link["srctblname"].chop} = #{ord["sno"]}&
					command_c = ActiveRecord::Base.connection.select_one(amt_sch_sql)
					command_c["#{prev_totbl.chop}_amt_sch"] = amt_sch
					command_c["#{prev_totbl.chop}_tax"] = tax
					command_c[:sio_code] = command_c[:sio_viewname] =  "r_" + prev_totbl
					command_c[:sio_classname] = "_update_consume_amt_sch_by_act"
				when /insts|dlvs|acts|replyinputs/
					srctbl = link["srctblname"]
					srctblid = link["srctblid"]
					flg = false
				end
			end
		end
	end

	def proc_insert_linktbls(src,base)
		linktbls_seq = ArelCtl.proc_get_nextval("linktbls_seq")
		strsql = %Q&
				insert into linktbls(id,trngantts_id,
					srctblname,srctblid,
					tblname,tblid,qty_src,amt_src,
					created_at,
					updated_at,
					update_ip,persons_id_upd,expiredate,remark)
				values(#{linktbls_seq},#{src["trngantts_id"]},
					'#{src["tblname"]}',#{src["tblid"]}, 
					'#{base["tblname"]}',#{base["tblid"]},#{base["qty_src"]} ,#{base["amt_src"]} , 
					to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
					to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
					' ',#{$person_code_chrg||=0},'2099/12/31','')
				&
		ActiveRecord::Base.connection.insert(strsql)
	end

	def proc_insert_alloctbls(rec_alloc)
		rec_alloc["alloctbls_id"] = ArelCtl.proc_get_nextval("alloctbls_seq")
		strsql = %Q&
		insert into alloctbls(id,
							srctblname,srctblid,
							trngantts_id,
							qty_sch,qty,qty_stk,
							qty_linkto_alloctbl,
							created_at,
							updated_at,
							update_ip,persons_id_upd,expiredate,remark,allocfree)
					values(#{rec_alloc["alloctbls_id"]},
							'#{rec_alloc["tblname"]}',#{rec_alloc["tblid"]},
							#{rec_alloc["trngantts_id"]},
							#{rec_alloc["qty_sch"]},#{rec_alloc["qty"]},#{rec_alloc["qty_stk"]},
							#{rec_alloc["qty_linkto_alloctbl"]},
							to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
							to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
							' ','0','2099/12/31','#{rec_alloc["remark"]}','#{rec_alloc["allocfree"]}')
		&
		ActiveRecord::Base.connection.insert(strsql)
		return rec_alloc
	end
end