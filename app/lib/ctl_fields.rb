# -*- coding: utf-8 -*-
module CtlFields
	extend self
	def proc_chk_fetch_rec params
		fetchview = save_fetchview = ""  ### save_fetchview:複数項目でkeyを構成するする時の重複処理を避ける
		params[:fetchview].split(",").each do |fetch|
			fetchview,delm = fetch.split(":")   ## YupSchemaでparagrapfをもとに作成済　split(":")拡張子の確認
			next if fetch == save_fetchview 
			delm ||= ""
			params = detail_chk_fetch_rec(params,fetchview,delm)
			save_fetchview = fetch	
		end
		return params
	end
	def  detail_chk_fetch_rec(params,fetchview,delm)
		params[:err] = nil 
		line_data,keys,findstatus,mainviewflg,missing = get_fetch_rec(params,fetchview,delm)
		params[:parse_linedata] = line_data.dup
	  	if findstatus
			if mainviewflg   ##mainviewflg = true 自分自身の登録
				if 	params[:parse_linedata]["aud"] == "add" or params["aud"] =~ /add/
					params[:err] = "error 1 duplicate code:#{keys},line:#{params[:index]} "
					params[:keys] = []
					keys.split(",").each do |key| 
				  		params[:keys] =  [key.split(":")[0].gsub(" ","")] 
						params[:parse_linedata][key+"_gridmessage"] = "error 1 duplicate code #{key} "
						if params[:parse_linedata][:errPath].nil? 
							params[:parse_linedata][:errPath] = [key.split(":")[0]+"_gridmessage"]
						end
					end  
				else
				end		
			else
				keys.split(",").each do |key| ###コードが変更されたとき既に使用されている？
					if key =~/_code/
				  ###作成中
					end 
					params[:parse_linedata][key.split(":")[0]+"_gridmessage"] = "deteted" 
				end  
			end  
	  	else
			if mainviewflg   ###自身の登録の時 
				###
				### r_tblfieldsの登録でr_blktbsがdetectできなかった時エラーにならない。!!!!!!!!!
				###
				params[:keys] = []
				keys.split(",").each do |key| 
				 	params[:keys] =  [key.split(":")[0].gsub(" ","")] 
				 	params[:parse_linedata][key+"_gridmessage"] = nil
				 	if params[:parse_linedata][:errPath] 
				 		params[:parse_linedata][:errPath] = nil
				 	end
				end  
			else
				if missing  ###検索に必要な項目まだ未入力
				else
					params[:err] =  "error 2  --->not find code:#{keys},line:#{params[:index]}  "
					params[:parse_linedata]["confirm"] = false
					keys.split(",").each do |key| ###コードが変更されたとき既に使用されている？
						params[:parse_linedata][key.split(":")[0]+"_gridmessage"] = "error 2 not find code #{key} "
						if params[:parse_linedata][:errPath].nil? 
							params[:parse_linedata][:errPath] = [key.split(":")[0]+"_gridmessage"]
						end
					end  
				end	  
			end  
	  	end 
	  	return params 
	end  

	def get_fetch_rec(params,fetchview,delm)
			keys = ""
			xno = ""
			srctblnamechop = ""
			screentblnamechop = params[:screenCode].split("_")[1].chop
			viewtblnamechop = fetchview.split("_")[1].chop
			line_data = params[:parse_linedata].dup
			mainviewflg = true  ##自分自身の登録か？
			findstatus = true
			if params[:screenCode].split("_")[1] != fetchview.split("_")[1] 
					mainviewflg = false
			else
				if delm != ""   ###自身のテーブルを参照しいるとき
					mainviewflg = false
				end	
			end
			flgfetchview = fetchview + if delm == "" then "" else ":#{delm}" end	  
			fetcfieldgetsql = "select pobject_code_sfd,screenfield_paragraph from r_screenfields
								 where pobject_code_scr =  '#{params[:screenCode]}' 
								 and screenfield_paragraph like '%#{flgfetchview}%'"
			missing = false   ###missing:true パラメータが未だ未設定　　false:チェックok
			where_strsql = ""
			fetchs = ActiveRecord::Base.connection.select_all(fetcfieldgetsql)
			cnt = 0
			fetchs.each do |prefetch|
				paragraphs = []
				prefetch["screenfield_paragraph"].split(",").each do |paragraph|
					if paragraph == flgfetchview   
						paragraphs << prefetch["pobject_code_sfd"]
					else
						next
					end
				end
				paragraphs.each do |fetch|
					cnt += 1 
					valOfField = params[:parse_linedata][fetch.to_sym]
					prefix,xno,srctblnamechop = fetch.split("_") ###xxx_sno_yyyy,xxx_cno_yyy用
					if valOfField =~ /,/				 ###入力項目に「,」が入っていた時
						params[:err] =  "error 3  --->not input comma:#{params[:index]} "
						line_data[(fetch+"_gridmessage").to_sym] =  "error 3 --->not input comma"  ###!!!
						missing = true
						findstatus = false
						break
					else
						if valOfField == "" or valOfField.nil?   ###未入力
							missing = true
						else
							keys <<  "#{fetch}: '#{valOfField}',"
							case fetch 
							when /_sno_|_cno_|_packinglistno_/
							 ### 
								where_strsql << " #{viewtblnamechop}_#{xno} = '#{params[:parse_linedata][fetch.to_sym]}'       and"
							else
								if delm == ""
									where_strsql << "  #{fetch} = '#{params[:parse_linedata][fetch.to_sym]}'        and"
								else
									where_strsql << "  #{fetch.split(delm)[0]} = '#{params[:parse_linedata][fetch.to_sym]}'       and"
								end
							end
							missing = false
						end
					end
					if missing == false  ###検索のための入力項目はすべて入力されている。
						if cnt >= paragraphs.to_a.size
							case fetch
							when  /_sno_|_cno_|_packinglistno_/ ###duedate,starttime,expiredateの引継ぎがあるとき
								viewstrsql = "select * from  func_get_screenfield_grpname('#{params["email"]}','#{fetchview}')"
								select_fields = ""
								ActiveRecord::Base.connection.select_all(viewstrsql).each_with_index do |i|			
									select_fields = 	select_fields + 
														case i["screenfield_type"]
														when "timestamp(6)" 
															%Q% to_char(#{i["pobject_code_sfd"]},'yyyy/mm/dd hh24:mi') #{i["pobject_code_sfd"]}% + " ,"
														when "date" 
															%Q% to_char(#{i["pobject_code_sfd"]},'yyyy/mm/dd ') #{i["pobject_code_sfd"]}% + " ,"
														else 												
															i["pobject_code_sfd"] + " ,"
														end		
								end
								strsql = " select #{select_fields.chop} from #{fetchview}  where " + where_strsql[0..-8] 						
							else
								strsql = " select * from #{fetchview}  where " + where_strsql[0..-8] 
							end
							rec =  ActiveRecord::Base.connection.select_one(strsql)
						else
							next
						end
					else
						rec = nil
						findstatus = false
					end
					if !rec.nil?  ###viewレコードあり
						### line_data = params[:parse_linedata].dup loop 中に内容の変更はできない。 
						params[:parse_linedata].each do |key,val|  ###結果をセット
							if key.to_s == "id"
								line_data[:id] = line_data[(screentblnamechop+"_id").to_sym] = "" if params[:parse_linedata][:aud] =~ /add|insert/
								next
							end 
							next if key.to_s =~ /person.*upd/  
							###画面の項目を分解　tableName.chop_fieldName(_delm),viewtblnamechop.fieldName(_delm),tableName.chop_viewtblnamechop_id(_dlem)
							items = key.to_s.split("_")
							if delm != ""
								next if key.to_s !~ /#{delm}$/  ###同一viewでkeyが異なる。
								field = key.to_s.sub(delm,"")
							else
								field = key.to_s
							end
							if key.to_s =~ /_id/
								if delm == ""
									other_tbl_key = (screentblnamechop+"_"+viewtblnamechop+"_id").to_sym
									other_tbl_key_grid = (screentblnamechop+"_"+viewtblnamechop+"_id_gridmessage").to_sym
								else
									other_tbl_key = (screentblnamechop+"_"+viewtblnamechop+"_id_"+delm).to_sym
									other_tbl_key_grid = (screentblnamechop+"_"+viewtblnamechop+"_id_"+delm+"_gridmessage").to_sym
								end
								if line_data[other_tbl_key]
									if rec[viewtblnamechop+"_id"]
										line_data[other_tbl_key] = rec[viewtblnamechop+"_id"]
										line_data[other_tbl_key_grid] = "deteted"
									end
								end
							end
							if rec[field]  ###id,sno,cnoから求められた同一項目を画面にセットする。
								field_gridmessage = (key.to_s + "_gridmessage").to_sym
								next if line_data[field_gridmessage] == "ok"  or line_data[field_gridmessage] == "deteted"    ###手入力あり
								###if line_data[key].nil? or line_data[key] == "" or line_data[key].to_s == "0"   ###rec:検索結果
								line_data[key] =  rec[field]  
								###end
								###自動セット項目 onblurfunc.js 参照(tableをgetしないとき利用)
								### qty,qty_stkの修正のため	nextしない。
							else
							 	### sno,cnoからデータを求めた時は同一項目でなくてもdelmが同じであればセットする。
								if items[0] == screentblnamechop
									if items[1] == viewtblnamechop 
										if items[2]  == "id"
							 				if rec["#{field.sub("#{screentblnamechop}_","")}"]  ###r_opeitms ==>opeitm_id
							 					line_data[key]  = rec["#{field.sub("#{screentblnamechop}_","")}"]	
											end
										end
									else ###項目の引継ぎ  purord_opeitm_xxx => puract_opeitm_xxx
										if (val == ""  or val.nil? or val.to_s == "0" ) 
											next if field =~ /_sno$|_cno$|_gno$|_isudate|_created_at|_updated_at|_remark|_contents|_seqno/
											if rec["#{field.sub(/^#{screentblnamechop}/,"#{viewtblnamechop}")}"]  
												line_data[key]  = rec["#{field.sub(/^#{screentblnamechop}/,"#{viewtblnamechop}")}"]  
											end
										end
									end
								end
							end
						end
						if fetch 	=~ /_sno_/
							org = nil
							case screentblnamechop
							when /prd|pur/
								str_srctbl_qty = "" ###次のステータスに移行していないqtyを求める。　
								### qtyのセット
								if  (viewtblnamechop =~ /sch$/ and screentblnamechop =~ /ord$/) 
									if params[:parse_linedata][(screentblnamechop+"_qty").to_sym].to_s == "0"   ###初期値でzeroがセットされていること
										str_srctbl_qty = "max(srctbl.qty_sch) srctbl_qty"
									end
								end
								if	(viewtblnamechop =~ /ord$/ and screentblnamechop =~ /inst$/) or 
									(viewtblnamechop =~ /ord$/ and screentblnamechop =~ /replyinput/) or
										(viewtblnamechop =~ /inst$/ and screentblnamechop =~ /replyinput/)   
									if params[:parse_linedata][(screentblnamechop+"_qty").to_sym].to_s == "0"   ###初期値でzeroがセットされていること
										str_srctbl_qty = "max(srctbl.qty) srctbl_qty"
									end
								end
								if 	(viewtblnamechop =~ /ord$/ and screentblnamechop =~ /dlv$|act$/) or 
									(viewtblnamechop =~ /inst$/ and screentblnamechop =~ /dlv$|act$/) or
										(viewtblnamechop =~ /replyinput$/ and screentblnamechop =~ /dlv$|act$/)   
									if params[:parse_linedata][(screentblnamechop+"_qty_stk").to_sym].to_s == "0"   ###初期値でzeroがセットされていること
										str_srctbl_qty = "max(srctbl.qty) srctbl_qty"
									end
								end
								if str_srctbl_qty != ""
									strsql = %Q% select sum(link.qty_src) qty_src ,#{str_srctbl_qty}
											from #{viewtblnamechop}s srctbl 
											left join  linktbls link  on srctbl.id = link.srctblid	and link.srctblname = '#{viewtblnamechop}s'
																		and (link.srctblname != link.tblname or link.srctblid != link.tblid)
																		and link.tblid != '#{params[:parse_linedata][(screentblnamechop+"_id").to_sym]}' 
											where srctbl.sno = '#{params[:parse_linedata][(screentblnamechop+"_sno_"+viewtblnamechop).to_sym]}' ---key.split("_")[1] :sno
											group by srctbl.id
										%  
									org =  ActiveRecord::Base.connection.select_one(strsql)
								end
								next if str_srctbl_qty == ""
							when /pay|bill/
								str_srctbl_amt = ""
								if 	(viewtblnamechop =~ /ord$/ and screentblnamechop =~ /act$/) or 
										(viewtblnamechop =~ /inst$/ and screentblnamechop =~ /act$/) 
									if params[:parse_linedata][(screentblnamechop+"_cash").to_sym].to_s == "0"   ###初期値でzeroがセットされていること
										str_srctbl_amt = "max(srctbl.amt) srctbl_amt"
									end
								end
								if str_srctbl_amt != ""
									strsql = %Q% select sum(link.amt_src) amt_src ,#{str_srctbl_amt}
											from #{viewtblnamechop}s srctbl 
											left join  srctbllinks link  on srctbl.id = link.srctblid	and link.srctblname = '#{viewtblnamechop}s'
																		and (link.srctblname != link.tblname or link.srctblid != link.tblid)
											where srctbl.sno = '#{params[:parse_linedata][(screentblnamechop+"_sno_"+viewtblnamechop).to_sym]}' ---key.split("_")[1] :sno
											group by srctbl.id
										%  
									org =  ActiveRecord::Base.connection.select_one(strsql)
								end
							end
						end
						if fetch 	=~ /_cno_/
							org = nil					
							str_loca_code = ""
							str_srctbl_qty = ""
							if  line_data[(screentblnamechop+"_shelfno_id").to_sym] != ""  and  !line_data[(screentblnamechop+"_shelfno_id").to_sym].nil? and
								screentblnamechop =~ /pur/
								str_loca_code = "and shelfnos_id = #{line_data[(screentblnamechop+"_shelfno_id").to_sym]}"
							end
							if  params[:parse_linedata][(screentblnamechop+"_shelfno_id").to_sym] != ""  and  !line_data[(screentblnamechop+"_shelfno_id").to_sym].nil? and
								screentblnamechop =~ /cust/
								str_loca_code = " and locas_id_cust = #{line_data[(screentblnamechop+"_loca_id").to_sym]}"
							end ###次のステータスに移行していないqtyを求める。　
							if line_data[(screentblnamechop+"_qty").to_sym].to_s == "0"   ###初期値でzeroがセットされていること
								if  (viewtblnamechop =~ /sch$/ and screentblnamechop =~ /ord$/) 
									str_srctbl_qty = "max(srctbl.qty_sch) srctbl_qty"
								end
								if	(viewtblnamechop =~ /ord$/ and screentblnamechop =~ /inst$/) or 
									(viewtblnamechop =~ /ord$/ and screentblnamechop =~ /replyinput/) or
										(viewtblnamechop =~ /inst$/ and screentblnamechop =~ /replyinput/)   
											str_srctbl_qty = "max(srctbl.qty) srctbl_qty"
								end
							end
							if params[:parse_linedata][(screentblnamechop+"_qty_stk").to_sym].to_s == "0"   ###初期値でzeroがセットされていること
								if 	(viewtblnamechop =~ /ord$/ and screentblnamechop =~ /dlv$|act$/) or 
									(viewtblnamechop =~ /inst$/ and screentblnamechop =~ /dlv$|act$/) or
										(viewtblnamechop =~ /replyinput$/ and screentblnamechop =~ /dlv$|act$/)   
											str_srctbl_qty = "max(srctbl._stk) srctbl_qty"
								end
							end
							if str_srctbl_qty != ""
								strsql = %Q% select sum(link.qty_src) qty_src, #{str_srctbl_qty}
											from #{viewtblnamechop}s srctbl 
											left join linktbls link  on srctbl.id = link.srctblid	and link.srctblname = '#{viewtblnamechop}s'
																		and (link.srctblname != link.tblname or link.srctblid != link.tblid)
																		and link.tblid != '#{params[:parse_linedata][(screentblnamechop+"_id").to_sym]}' 
											where srctbl.cno = '#{params[:parse_linedata][(screentblnamechop+"_cno_"+viewtblnamechop).to_sym]}'  #{str_loca_code}  
											group by srctbl.id
										% 
								org =  ActiveRecord::Base.connection.select_one(strsql)
							end
							next if str_srctbl_qty == ""
						end
						if org	
							case screentblnamechop
							when /prd|pur/
								###既に状態が変化しているかチェック
								if org["qty_src"].to_f >= org["srctbl_qty"].to_f 
									params[:err] =  "error 4 1--->over qty  line:#{params[:index]} "
									case screentblnamechop
									when /ord$|inst$|replyinput/
										line_data[(screentblnamechop+"_qty_gridmessage").to_sym] =  "error 4 2--->over qty"
									when /dlv$|act$/
										line_data[(screentblnamechop+"_qty_stk_gridmessage").to_sym] =  "error 4 3 --->over qty"
									end
								else
									params[:err] =  nil
									case screentblnamechop
									when /ord$|inst$|replyinput/
										line_data[(screentblnamechop+"_qty").to_sym] = org["srctbl_qty"].to_f   - org["qty_src"].to_f  
									when /dlv$|act$/
										line_data[(screentblnamechop+"_qty_stk").to_sym] =  org["srctbl_qty"].to_f   - org["qty_src"].to_f
									end
								end
							when /pay|bill/
								if org["amt_src"].to_f >= org["srctbl_amt"].to_f 
									params[:err] =  "error 4 1--->over cash  line:#{params[:index]} "
									case screentblnamechop
									when /inst$/
										line_data[(screentblnamechop+"_amt_gridmessage").to_sym] =  "error 4 3 --->over cash"
									when /act$/
										line_data[(screentblnamechop+"_cash_gridmessage").to_sym] =  "error 4 3 --->over cash"
									end
								else
									params[:err] =  nil
									case screentblnamechop
									when /inst$/
										line_data[(screentblnamechop+"_amt").to_sym] = org["srctbl_amt"].to_f   - org["amt_src"].to_f  
									when /act$/
										line_data[(screentblnamechop+"_cash").to_sym] =  org["srctbl_amt"].to_f   - org["amt_src"].to_f
									end
								end
							end
						end	
						# if screentblnamechop != viewtblnamechop ### omit self table
						# 	field = screentblnamechop+"_"+viewtblnamechop+"_id"+delm
						# 	line_data[field] =  rec["id"]
						# end
						case screentblnamechop ###masterの規定値をset
						when /^custsch|^custord/
							case  fetchview
							when /custs$/
								if line_data[:crr_code].nil? or line_data[:crr_code] == ""
									line_data[:crr_code] = rec["crr_code_bill_cust"]
									line_data[:crr_name] = rec["crr_name_bill_cust"]
									line_data[:custord_crr_id] = rec["bill_crr_id_bill_cust"]
								end
								if line_data[:custord_contractprice].nil? or line_data[:custord_contractprice] == ""
									line_data[:custord_contractprice] = rec["cust_contractprice"]
								end 
							when  /opeitms$/ 
								if line_data[:shelfno_code_fm] == "" or line_data[:shelfno_code_fm].nil? 
								   line_data[:loca_code_shelfno_fm] = rec["loca_code_shelfno_to_opeitm"]  ###opeitm.shelfno_code_to_opeitm 完成後の置き場所゜
								   line_data[:shelfno_code_fm] = rec["shelfno_code_to_opeitm"]  ###opeitm.shelfno_code_to_opeitm 完成後の置き場所゜
								   line_data[:loca_name_shelfno_fm] = rec["loca_name_shelfno_to_opeitm"]  ###opeitm.shelfno_code_to_opeitm 完成後の置き場所゜
								   line_data[:shelfno_name_fm] = rec["shelfno_name_to_opeitm"]  ###opeitm.shelfno_code_to_opeitm 完成後の置き場所゜
								   line_data["#{screentblnamechop}_shelfno_id_fm".to_sym] = rec["opeitm_shelfno_id_to_opeitm"]  ###opeitm.shelfno_code_to_opeitm 完成後の置き場所゜
									###custord.shelfno_code_fm 客先への出荷のための梱包場所
								end
							end
						end
					else
						findstatus = false
						##再入力時のNgに対応	
						if missing == false and mainviewflg == false
							if screentblnamechop != viewtblnamechop and xno !~ /_sno|_cno|_packinglistno/ ### omit self table
								### sno,cnoの時は例えば r_puractsにpurord_idを含んでない。(sno_purord,sno_ourdlv等どちらを使用するか不明。)
								field = (screentblnamechop+"_"+viewtblnamechop+"_id"+delm).to_sym
								line_data[field] =  ""
							end
							line_data[(fetch+"_gridmessage").to_sym] =  "error not detected" 
						else
						end
					end
				end
			end	
			return line_data,keys,findstatus,mainviewflg,missing
	end		

	def proc_blkuky_check tbl,line_data   ###重複チェック
		save_blkuky_grp = nil
		keys = []
		err = {}
		strsql = %Q% select blkuky_grp,pobject_code_fld from r_blkukys where pobject_code_tbl = '#{tbl}' 
						and blkuky_expiredate > current_date order by blkuky_grp,blkuky_seqno%
						
		ActiveRecord::Base.connection.select_all(strsql).each do |rec|
			if save_blkuky_grp != rec["blkuky_grp"] 
				if  !save_blkuky_grp.nil? and keys.exclude?("id")
					err = blkuky_check_detail tbl,keys,line_data,err
					keys = []
				end
				save_blkuky_grp = rec["blkuky_grp"]
			end
			keys << rec["pobject_code_fld"]
		end
		if !keys.empty? and keys.exclude?("id")  ### id付きの検索keysはたんなるindexのためskip
			err = blkuky_check_detail tbl,keys,line_data,err
		end
		return err
	end	

	def blkuky_check_detail tbl,keys,line_data,err
		strwhere = " where "
		tblchop = tbl.chop
		keys.each do |key|
			symkey = (tblchop + "_" + key.gsub("s_id","_id")).to_sym
			if line_data[symkey].nil? or line_data[symkey]  == ""
				strwhere = "       #{symkey} must be select      "
				break
			else
				strwhere << "  #{key} = '#{line_data[symkey]}'     and "
			end
		end
		if strwhere =~ /where/ 
			strsql = "select id from #{tbl} " + strwhere[0..-5]
			recs = ActiveRecord::Base.connection.select_all(strsql)
			err[strwhere[6..-5]] = recs
		else
			err[strwhere[6..-5]] = []
		end
		return err
	end

	###未コーディング
	#  screenfields.selection  viewtblchop_tblname_id は必ず選択
	#  nditms 子どものopeitmsへの存在チェック
	### 
	def proc_judge_check_code params,sfd,checkCode  ###
		line_data = params[:parse_linedata]
		err = nil
		checkCode.split(",").each do |chk|
			line_data,err = __send__("proc_judge_check_#{chk}",line_data,sfd,params[:index],params[:screenCode])  ###[1]: nil all,add,updateは画面側で判断
		end
		params[:err] = err
		return params 
	end	

	# def proc_judge_check_opeitm_loca line_data,sfd,index,screenCode
	# 	case line_data[:opeitm_prdpur]
	# 	when "pur"
	# 		strsql = %Q&
	# 					select 1 from r_suppliers where loca_code_supplier = '#{line_data[:loca_code_shelfno_opeitm]}'
	# 		&
	# 	when "prd","dvs"
	# 		strsql = %Q&
	# 					select 1 from r_custs where loca_code_cust = '#{line_data[:loca_code_shelfno_opeitm]}'
	# 		&
	# 	else
	# 		strsql = %Q&
	# 					select 1
	# 		&
	# 	end
	# 	rec = ActiveRecord::Base.connection.select_value(strsql)
	# 	if rec
	# 		err = nil
	# 	else
	# 		err =  "error5 1   --->view or field  #{line_data[:loca_code_shelfno_opeitm]}　not find line:#{index} "
	# 	end
	# 	return line_data,err
	# end

	def proc_judge_check_paragraph line_data,item,index,screenCode ### proc_judge_check_codeからcallされる。
		if line_data[:screenfield_paragraph] == ""
			if line_data[:pobject_code_sfd] =~ /_code/ and screenCode.split("_")[1].chop == line_data["pobject_code_sfd"].split("_")[0]
				err =  "error 5 2   --->view or field  #{line_data["screenfield_paragraph"]}　not find line:#{index} "
			else	
				err =  nil
			end
		else	
			if line_data[:screenfield_paragraph]
				line_data[:screenfield_paragraph].split(",").each do |paragraph|
					screen,delm = paragraph.split(":",2)
					if line_data[:pobject_code_sfd] =~ /_sno_|_cno_|_gno_|_packinglistno_/
						case line_data[:pobject_code_sfd] 
						when /_tblname/
							field =  line_data[:pobject_code_sfd]
						when /_sno_/
							field = line_data[:pobject_code_sfd].split("_sno_")[1] + "_sno"
						when /_cno_/
							field = line_data[:pobject_code_sfd].split("_cno_")[1] + "_cno"
						when /_gno_/
							field = line_data[:pobject_code_sfd].split("_gno_")[1] + "_gno"
						when /_packinglistno_/  ###invoiceに梱包と保守が含まれるときgnoは使用できない。
							field = line_data[:pobject_code_sfd].split("_packinglistno_")[1] + "_packinglistno"
						else
						end
					else
						if delm
							field =  line_data[:pobject_code_sfd].gsub(delm,"")
						else	
							field =  line_data[:pobject_code_sfd]
						end
					end
					strsql = %Q%
							SELECT	pg_views.viewname AS view_name,column_name
		   						FROM   pg_views
			   					inner join information_schema.columns on table_name = pg_views.viewname 
		   						WHERE	   schemaname = current_schema() 
			   					and pg_views.viewname = '#{screen}' 
			   					and column_name = '#{field}'
						union --- MATERIALIZED VIEW columns
							SELECT 
							  	mv.relname as view_name  , ---matview_name
										  att.attname as column_name
								from pg_catalog.pg_attribute att
								join pg_catalog.pg_class mv ON mv.oid = att.attrelid
								join pg_catalog.pg_namespace nsp ON nsp.oid = mv.relnamespace
								where mv.relkind = 'm' 
								AND not att.attisdropped 
								and att.attnum > 0
								and mv.relname = '#{screen}'
								and nsp.nspname =  current_schema()
								and att.attname = '#{field}'			   				
						%
					rec = ActiveRecord::Base.connection.select_one(strsql)
					if rec
						err = nil
					else
						err =  "error 5 3   --->view or field  #{line_data[:screenfield_paragraph]}　not find line:#{index} "
					end
				end
			end
		end
		return line_data,err
	end	

	def proc_judge_check_strorder line_data,item,index,screenCode   ###　r_screens(screens)のみで有効
		if line_data[:screen_strorder] and line_data[:screen_strorder] != ""
			ary_select_fields = line_data.keys
			sort_info = {}
			sort_info[:default] = line_data[:screen_strorder]
			sort_info[:default].split(/\s*,\s*/).each do |sort_field|
				ok = false
				sort_field.split(" ").each do |chk|
					strsql = "select 1 from r_screenfields where pobject_code_scr =  '#{line_data[:pobject_code_scr]}'
															and screenfield_selection  = '1' and pobject_code_sfd = '#{chk}' "
					rec = ActiveRecord::Base.connection.select_one(strsql)
					if !rec.nil?
						ok = true
					else
						if ok==true and (chk.gsub(" ","").downcase=="asc" or chk.gsub(" ","").downcase=="desc")
						else
							sort_info[:default] = nil
							sort_info[:err] = "sort fields  error 6 "
							break
						end		
					end		
				end	
			end	
			if sort_info[:err] 
				err =  sort_info[:err] + "line:#{index}" 
			else
				err =  nil
			end
		end
		return line_data,err
	end

	###社内用　loca_codeは社外で使用できない。
	def proc_judge_check_workplace_loca_code_not_used_suppliers_custwhs line_data,item,index,screenCode
		if line_data[item.to_sym] 
			case params[:screenCode]
			when /workplaces/
				strsql = %Q%
					select id from r_suppliers where loca_code_supplier = '#{line_data[item.to_sym]}'
												and supplier_expiredate > current_date
						union
					select id from r_custrcvplcs where loca_code_custrcvplc = '#{line_data[item.to_sym]}'
													and custwh_expiredate > current_date
				%
			when /suppliers|custwhs|custrcvplcs/
				strsql = %Q%
					select id from r_workplaces where loca_code_workplace = '#{line_data[item.to_sym]}'
											and workplace_expiredate > current_date%
			end
			if  ActiveRecord::Base.connection.select_value(strsql)
				err =  " #{line_data[item.to_sym]}  cant not use  loca_code_workplace same time (suppliers or custwhs) "
			else
				err =  nil
			end
		end
		return line_data,err
	end

	
	def proc_judge_check_workplaces line_data,item,index,screenCode
		if line_data[item.to_sym] 
			strsql = %Q%
				select id from r_workplaces where loca_code_workplace = '#{line_data[item.to_sym]}'
											and workplace_expiredate > current_date
			%
			if  ActiveRecord::Base.connection.select_value(strsql)
				err = nil
			else
				err =  " #{line_data[item.to_sym]} not workplaces"
			end
		end
		return line_data,err
	end
	
	def proc_judge_check_suppliers line_data,item,index,screenCode
		if line_data[item.to_sym] 
			strsql = %Q%
				select id from r_suppliers where loca_code_supplier = '#{line_data[item.to_sym]}'
											and supplier_expiredate > current_date
			%
			if  ActiveRecord::Base.connection.select_value(strsql)
				err = nil
			else
				err =  " #{line_data[item.to_sym]} not suppliers"
			end
		end
		return line_data,err
	end

	
	def proc_judge_check_workplaces_suppliers line_data,item,index,screenCode
		case line_data[:opeitm_prdpur]
		when "pur"
			if line_data[item.to_sym] 
				strsql = %Q%
					select id from r_suppliers where loca_code_supplier = '#{line_data[item.to_sym]}'
											and supplier_expiredate > current_date
				%
				if  ActiveRecord::Base.connection.select_value(strsql)
					err = nil
				else
					err =  " #{line_data[item.to_sym]} not suppliers"
				end
			end
		when "prd"
			if line_data[item.to_sym] 
				strsql = %Q%
					select id from r_workplaces where loca_code_workplace = '#{line_data[item.to_sym]}'
												and workplace_expiredate > current_date
				%
				if  ActiveRecord::Base.connection.select_value(strsql)
					err = nil
				else
					err =  " #{line_data[item.to_sym]} not workplaces"
				end
			end
		end
		return line_data,err
	end

	def proc_judge_check_qty line_data,item,index,screenCode
		###　get_fetch_recで実施済
	 	return line_data,nil   ###err= nil
	end	
	
	def proc_judge_check_consumtype line_data,item,index,screenCode
		classlist = ""
		case screenCode
		when /nditms/
			strsql = %Q&
						select c.code from itms i
									inner join classlists c	on i.classlists_id = c.id		
									where i.id = #{line_data[:nditm_itm_id_nditm]}
				&
			classlist = ActiveRecord::Base.connection.select_value(strsql)
		end
		case classlist
		when "ITool","installationCharge","mold","apparatus"
			line_data[:nditm_consumtype] = classlist
		end 
	 	return line_data,nil   ###err= nil
	end	

	 def proc_judge_check_loca_code_to line_data,item,index,screenCode
	 	tblname =  screenCode.split("_")[1]
	 	id = line_data["#{tblname.chop}_id"]
	 	if id != ""  ###更新の時のみ　ords-->insts  insts -->actsに既にどれだけ変化しているか？
	 		sym = "loca_code_to"
	 		if line_data[sym] == ""
	 			err =  "error 7   --->#{sym} missing line:#{index} "
	 		else
	 			strsql = %Q%select sum(qty) from trngantts where orgtblname ='#{tblname}' and orgtblid = #{id} 
	 					 and  tblid = #{id} and tblname = '#{tblname}' group by orgtblname,orgtblid,tblname,tblid %
	 			trn_qty = ActiveRecord::Base.connection.select_value(strsql)
	 			chng_qty ||= 0.0  ###すでに次の状態に変化した数値
	 			strsql = %Q%select loca_code_to,#{tblname.chop}_qty from r_#{tblname} where id = #{id} %
	 			rec = ActiveRecord::Base.connection.select_one(strsql)
	 			if (chng_qty != rec["#{tblname.chop}_qty"] or rec["#{tblname.chop}_qty"]  != trn_qty) and 
	 					line_data[sym] != rec["loca_code_to"]
	 				checkstatus = false
	 				err =  "error 8   ---> loca_code_to must be >= #{rec["loca_code_to"]} line:#{index} "
				 else
					err =  nil
	 			end 
	 		end
	 	end
	 	return line_data,err
	 end	

	def proc_judge_check_already_used line_data,item,index,screenCode  ###あるidで登録されたcodeが別のテーブルに既に登録されているとき、codeの変更は不可
		###外部keyでチェックすべき???
		# check_code,views = checkCode.split(",")
		# strsql = %Q&select #{field} from #{view} where #{field} = '#{params[:parse_linedata][item]}'
		# 		&
		# old_value = ActiveRecord::Base.connection.select_value(strsql)
		# old_value ||= ""
		# if params[:parse_linedata][item] == "" or old_value.nil?
		# 			new_value = ""
		# else
		# 			strsql = %Q&select #{field} from #{view} where #{field.sub("_code","_id")} = #{params[:parse_linedata]["id"]}
		# 			&
		# 			new_value = ActiveRecord::Base.connection.select_value(strsql)
		# end
		# if old_value == new_value
		# 			params[:err] = nil
		# else	
		# 			params[:err] =  "error   ---> #{field} can not change because #{view} already used "
		# end
		if line_data[:id] and line_data[:id] != ""  ###変更の時 
			case screenCode
			when /itms/
			when /locas/
			when /pobjects/
				strsql = %Q%select code from pobjects where id = #{line_data[:id]}						
				%
				pobject_codes = ActiveRecord::Base.connection.select_values(strsql)
				pobject_codes.each do |pobject_code|
					if pobject_code != line_data[:pobject_code]
						strsql = %Q%select tfd.id from tblfields tfd
										inner join fieldcodes fld on tfd.fieldcodes_id  =  fld.id
										where pobjects_id_fld = #{line_data[:id]}  and tfd.expiredate > current_date
								%
						value = ActiveRecord::Base.connection.select_value(strsql)
						if value
							err =  "error 9   ---> #{pobject_code} can not change because table:tblfields already used line:#{index} "
						else
							err = nil
						end
					end
				end
			end
		end		
		if screenCode =~ /pobjects/   ###将来　履歴専用のtblを作成しこのチェックはなくす。
			if line_data[:objecttype] == "view"
				if line_data[:code] =~ /cust|prd|pur|shp/ and line_data[:code] =~ /schs$|ords$|oinsts$|replyinputs$|dlvs$|acts$|rets$/
					if line_data[:code].split("_")[0]  == "r"
					else
						err =  "error A  ---> view:#{code}   must be r_xxxxxxx 参照 Operation.get_last_rec  "
					end
				end
			end
		end

		return line_data,err	
	end

	def proc_judge_check_same_loca_code_bill line_data,item,index,screenCode  ###MkInvoiveNoの時のみ
		err = nil
		return line_data,err
	end

	def proc_judge_check_duedate line_data,item,index,screenCode  ###
		tblnamechop = screenCode.split("_")[1].chop
		parent = {"starttime"  => line_data[(tblnamechop+"_duedate").to_sym]}
		nd = {"duration" => line_data["opeitm_duration".to_sym],"units_lttime" => line_data[:opeitm_units_lttime] }
		line_data = proc_field_starttime(parent,nd,tblnamechop,line_data.stringify_keys)
		err = nil
		return line_data.symbolize_keys,err
	end
	
	def proc_judge_check_supplierprice line_data,item,index,screenCode  ###M
		err = nil
		# if line_data[:purord_contractprice] =~ /[A-Z]|[a-z]/  ###数字の時マスター単価
		# 	return line_data,err
		# end
		ex_date = nil
		case screenCode
		when /pursch/
			strpur = "pursch"
			stramtsym = "pursch_amt_sch".to_sym
			strqtysym = "pursch_qty_sch".to_sym
			strtaxsym = "pursch_tax".to_sym
		when /purord/
			strpur = "purord"
			stramtsym = "purord_amt".to_sym
			strqtysym = "purord_qty".to_sym
			strtaxsym = "purord_tax".to_sym
		when /purinst/
			strpur = "purinst"
			stramtsym = "purinst_amt".to_sym
			strqtysym = "purinst_qty".to_sym
			strtaxsym = "purinst_tax".to_sym
		when /purdlv/
			strpur = "purdlv"
			stramtsym = "purdlv_amt".to_sym
			strqtysym = "purdlv_qty_stk".to_sym
			strtaxsym = "purdlv_tax".to_sym
		when /puract/
			strpur = "puract"
			stramtsym = "puract_amt".to_sym
			strqtysym = "puract_qty_stk".to_sym
			strtaxsym = "puract_tax".to_sym
		end	
		strcontractpricesym = "#{strpur}_contractprice".to_sym
		strmasterpricesym = "#{strpur}_masterprice".to_sym
		stropeitmsym = "#{strpur}_opeitm_id".to_sym
		strisudatesym = "#{strpur}_isuedate".to_sym
		strduedatesym = "#{strpur}_duedate".to_sym
		strpricesym = "#{strpur}_price".to_sym
		strtaxratesym = "#{strpur}_taxrate".to_sym
		strcrrsym = "#{strpur}_crr_id".to_sym
		strsuppliersym = "#{strpur}_supplier_id".to_sym
		case screenCode
		when /pursch|purord/
			case line_data[strcontractpricesym]
			when "1"
				ex_date = "expiredate >= to_date('#{line_data[strisudatesym]}','yyyy/mm/dd')" 
			when "2","3"
				ex_date = "expiredate >= to_date('#{line_data[strduedatesym]}','yyyy/mm/dd')"
			else
				ex_date = nil
				line_data[strcontractpricesym] = "C"
				line_data[strmasterpricesym] = line_data[strpricesym]  = line_data[stramtsym]  = 0
			end
		when /purdlv/ 
			ex_date = case line_data[strcontractpricesym] 
						when "1"
							"expiredate >= to_date('#{line_data[:purdlv_depdate]}','yyyy/mm/dd')"
						else
							nil
						end
		when /puract/ 
			ex_date = case line_data[strcontractpricesym] 
						when "1"
							"expiredate >= to_date('#{line_data[:puract_rcptdate]}','yyyy/mm/dd')"
						else
							nil
						end
						
		end 
			
		if ex_date
			strsql = %Q&
						select * from supplierprices 
									where suppliers_id = #{line_data[strsuppliersym]} and opeitms_id = #{line_data[stropeitmsym]}
									and maxqty >= #{line_data[strqtysym]}
									and minqty < #{line_data[strqtysym]}
									and #{ex_date}
									order by maxqty,expiredate limit 1
				&								
			price = ActiveRecord::Base.connection.select_one(strsql)	
			if price
				line_data[strpricesym] = line_data[strmasterpricesym] = price["price"].to_f
				###line_data[:pursch_contractprice] = supplier["contractprice"]
				line_data[stramtsym] = line_data[strqtysym].to_f * price["price"].to_f
				case line_data[:itm_taxflg]
				when "0","1","9"
					base_date =  line_data[strduedatesym]
				when "A"
					base_date =   line_data[strisudatesym]
				else
					base_date =  line_data[strduedatesym]
				end
				strsql = %Q&
							select taxrate from taxtbls where taxflg = '#{line_data[:itm_taxflg]}' 
														and expiredate >= to_date('#{base_date}','yyyy/mm/dd')
														order by expiredate limit 1
				&
				line_data[strtaxratesym] = ActiveRecord::Base.connection.select_value(strsql)
				line_data[strtaxratesym] ||= 0
				line_data[strtaxsym] = (line_data[stramtsym] * line_data[strtaxratesym].to_f / 100)
				if line_data[strcrrsym]
					strsql = %Q&
							select decimal from crrs where id = #{line_data[strcrrsym]}
					&
					decimal = ActiveRecord::Base.connection.select_value(strsql)
					case line_data[:supplier_amtround]  ###1:切り捨て　2:四捨五入 3:切り上げ
					when "1"
						line_data[stramtsym] = line_data[stramtsym].floor(decimal.to_i )
						line_data[strtaxsym] = (line_data[stramtsym] * line_data[strtaxratesym].to_f / 100).floor(decimal.to_i )
					when "2"
						line_data[stramtsym] = line_data[stramtsym].round(decimal.to_i + 1)
						line_data[strtaxsym] = (line_data[stramtsym] * line_data[strtaxratesym].to_f / 100).round(decimal.to_i )
					when "3"
						line_data[stramtsym] = line_data[stramtsym].ceil(decimal.to_i )
						line_data[strtaxsym] = (line_data[stramtsym] * line_data[strtaxratesym].to_f / 100).ceil(decimal.to_i )
					end
				else
					###
				end
			else
				line_data[strcontractpricesym] = "C"
				line_data[strmasterpricesym] = line_data[strpricesym]  = line_data[stramtsym]  = 0
				line_data[strtaxsym] = line_data[strtaxratesym]  = 0
			end
		else
			###line_data[strmasterpricesym] =  line_data[strpricesym]  = 0
			line_data[stramtsym] = line_data[strqtysym].to_f * line_data[strpricesym].to_f 
			case line_data[:itm_taxflg]
			when "0","1","9"
				base_date =  line_data[strduedatesym]
			when "A"
				base_date =   line_data[strisudatesym]
			else
				base_date =  line_data[strduedatesym]
			end
			strsql = %Q&
						select taxrate from taxtbls where taxflg = '#{line_data[:itm_taxflg]}' 
													and expiredate >= to_date('#{base_date}','yyyy/mm/dd')
													order by expiredate limit 1
			&
			line_data[strtaxratesym] = ActiveRecord::Base.connection.select_value(strsql)
			line_data[strtaxratesym] ||= 0
			line_data[strtaxsym] = (line_data[stramtsym] * line_data[strtaxratesym].to_f / 100)
			if line_data[strcrrsym]
				strsql = %Q&
						select decimal from crrs where id = #{line_data[strcrrsym]}
				&
				decimal = ActiveRecord::Base.connection.select_value(strsql)
				case line_data[:supplier_amtround]  ###1:切り捨て　2:四捨五入 3:切り上げ
				when "1"
					line_data[stramtsym] = line_data[stramtsym].floor(decimal.to_i )
					line_data[strtaxsym] = (line_data[stramtsym] * line_data[strtaxratesym].to_f / 100).floor(decimal.to_i )
				when "2"
					line_data[stramtsym] = line_data[stramtsym].round(decimal.to_i + 1)
					line_data[strtaxsym] = (line_data[stramtsym] * line_data[strtaxratesym].to_f / 100).round(decimal.to_i )
				when "3"
					line_data[stramtsym] = line_data[stramtsym].ceil(decimal.to_i )
					line_data[strtaxsym] = (line_data[stramtsym] * line_data[strtaxratesym].to_f / 100).ceil(decimal.to_i )
				end
			else
				###
			end
		end
		return line_data,err
	end

	def proc_judge_check_custprice line_data,item,index,screenCode  ###M
		err = nil
		case screenCode
		when /custschs/
			if line_data[:custsch_contractprice] =~ /[A-Z]|[a-z]/ and line_data[:custsch_price] != "" ###数字の時マスター単価
				return line_data,err
			end
			strsql = %Q&
						select * from custprices 
									where custs_id = #{line_data[:custsch_cust_id]} and opeitms_id = #{line_data[:custsch_opeitm_id]}
									and crrs_id_custprice = #{line_data[:custsch_crr_id]}
									and maxqty >= #{line_data[:custsch_qty_sch]}
									and minqty < #{line_data[:custsch_qty_sch]}
									and #{case line_data[:custsch_contractprice]
											when "1"
												"expiredate >= to_date('#{line_data[:custsch_isudate]}','yyyy/mm/dd')" 
											when "2"
												"expiredate >= to_date('#{line_data[:custsch_duedate]}','yyyy/mm/dd')"
											when "3"
												"expiredate >= to_date('#{line_data[:custsch_duedate]}','yyyy/mm/dd')"
											else
												"expiredate >= to_date('#{line_data[:custsch_isudate]}','yyyy/mm/dd')"
											end											
											}
									order by maxqty,expiredate limit 1
			&
			price = ActiveRecord::Base.connection.select_one(strsql)
			if price
				line_data[:custsch_price] =  line_data[:custsch_masterprice] = price["price"].to_f
				line_data[:custsch_amt_sch] = line_data[:custsch_qty_sch].to_f * price["price"].to_f
				if line_data[:custsch_crr_id]
					strsql = %Q&
							select decimal from crrs where id = #{line_data[:custsch_crr_id]}
					&
					decimal = ActiveRecord::Base.connection.select_value(strsql)
					case line_data[:cust_amtround]  ###1:切り捨て　2:四捨五入 3:切り上げ
					when "1"
						line_data[:custsch_amt_sch] = line_data[:custsch_amt_sch].floor(decimal.to_i )
						line_data[:custsch_tax] = (line_data[:custsch_amt_sch] * line_data[:custsch_taxrate].to_f / 100).floor(decimal.to_i )
					when "2"
						line_data[:custsch_amt_sch] = line_data[:custsch_amt_sch].round(decimal.to_i )
						line_data[:custsch_tax] = (line_data[:custsch_amt_sch] * line_data[:custsch_taxrate].to_f / 100).round(decimal.to_i )
					when "3"
						line_data[:custsch_amt_sch] = line_data[:custsch_amt_sch].ceil(decimal.to_i )
						line_data[:custsch_tax] = (line_data[:custsch_amt_sch] * line_data[:custsch_taxrate].to_f / 100).ceil(decimal.to_i )
					else
						line_data[:custsch_tax] = (line_data[:custsch_amt_sch] * line_data[:custsch_taxrate].to_f / 100)
					end
				else
				end
			else
				line_data[:custsch_price] = line_data[:custsch_masterprice] = 0
				line_data[:custsch_amt_sch] = 0
				line_data[:custsch_contractprice] = "C"  ###C:マスター単価無
			end
		when /custords/
			if line_data[:custord_contractprice] =~ /[A-Z]|[a-z]/ and line_data[:custord_price] != "" ###数字の時マスター単価
				return line_data,err
			end
			strsql = %Q&
						select * from custprices 
									where custs_id = #{line_data[:custord_cust_id]} and opeitms_id = #{line_data[:custord_opeitm_id]}
									and crrs_id_custprice = #{line_data[:custord_crr_id]}
									and maxqty >= #{line_data[:custord_qty]}
									#{if line_data[:custord_qty].to_f == 0 then  "" else " and minqty < #{line_data[:custord_qty]}" end}
									and #{case line_data[:custord_contractprice]
											when "1"
												"expiredate >= to_date('#{line_data[:custord_isudate]}','yyyy/mm/dd')" 
											when "2"
												"expiredate >= to_date('#{line_data[:custord_duedate]}','yyyy/mm/dd')"
											when "3"
												"expiredate >= to_date('#{line_data[:custord_duedate]}','yyyy/mm/dd')"
											else
												"expiredate >= to_date('#{line_data[:custord_isudate]}','yyyy/mm/dd')"
											end											
											}
									order by maxqty,expiredate limit 1
			&
			price = ActiveRecord::Base.connection.select_one(strsql)
			if price
				line_data[:custord_price] =  line_data[:custord_masterprice] = price["price"].to_f
				line_data[:custord_amt] = line_data[:custord_qty].to_f * price["price"].to_f
				if line_data[:custord_crr_id]
					strsql = %Q&
							select decimal from crrs where id = #{line_data[:custord_crr_id]}
					&
					decimal = ActiveRecord::Base.connection.select_value(strsql)
					case line_data[:cust_amtround]  ###1:切り捨て　2:四捨五入 3:切り上げ
					when "1"
						line_data[:custord_amt] = line_data[:custord_amt].floor(decimal.to_i )
						line_data[:custord_tax] = (line_data[:custord_amt] * line_data[:custord_taxrate].to_f / 100).floor(decimal.to_i )
					when "2"
						line_data[:custord_amt] = line_data[:custord_amt].round(decimal.to_i )
						line_data[:custord_tax] = (line_data[:custord_amt] * line_data[:custord_taxrate].to_f / 100).round(decimal.to_i )
					when "3"
						line_data[:custord_amt] = line_data[:custord_amt].ceil(decimal.to_i )
						line_data[:custord_tax] = (line_data[:custord_amt] * line_data[:custord_taxrate].to_f / 100).ceil(decimal.to_i )
					end
				else
				end
			else
				line_data[:custord_price] = line_data[:custord_masterprice] = 0.0
				line_data[:custord_amt] = line_data[:custord_tax] = 0.0
				line_data[:custord_contractprice] = "C"  ###C:マスター単価無
			end
		when /custdlvs/  ###1:発注日ベース　2:仕入れ先きの出荷日ベース　3:検収ベース
			if params[:custdlv_contractprice]  == "2"  ###出荷日ベース　
				strsql = %Q&
							select * from custprices 
										where custs_id = #{line_data[:custdlv_cust_id]} and opeitms_id = #{line_data[:custdlv_opeitm_id]}
										and crrs_id_custprice = #{line_data[:custdlv_crr_id]}
										and maxqty >= #{line_data[:custdlv_qty]}
										and minqty < #{line_data[:custdlv_qty]}
										and  expiredate >= to_date('#{line_data[:custdlv_depdate]}','yyyy/mm/dd')
										order by maxqty,expiredate limit 1
				&
				price = ActiveRecord::Base.connection.select_one(strsql)
				if price
					decimal = line_data[:crr_decimal].to_i
					line_data[:custdlv_amt] = line_data[:custdlv_qty].to_f * price["price"].to_f
					case line_data[:cust_amtround]  ###1:切り捨て　2:四捨五入 3:切り上げ
					when "1"
						line_data[:custdlv_amt] = line_data[:custdlv_amt].floor(decimal + 1)
						line_data[:custdlv_tax] = (line_data[:custdlv_amt] * line_data[:custdlv_taxrate].to_f  / 100).floor(decimal)
					when "2"
						line_data[:custdlv_amt] = line_data[:custdlv_amt].round(decimal + 1)
						line_data[:custdlv_tax] = (line_data[:custdlv_amt] * line_data[:custdlv_taxrate].to_f  / 100).round(decimal )
					when "3"
						line_data[:custdlv_amt] = line_data[:custdlv_amt].ceil(decimal + 1)
						line_data[:custdlv_tax] = (line_data[:custdlv_amt] * line_data[:custdlv_taxrate].to_f / 100).ceil(decimal )
					end
				else
					line_data[:custdlv_contractprice] = "C"  ###C:マスター単価無
				end
			end
		when /custacts/  ###1:発注日ベース　2:仕入れ先きの出荷日ベース　3:検収ベース
			if params[:custact_contractprice]  == "3"
				strsql = %Q&
					select * from custprices 
							where custs_id = #{line_data[:custact_cust_id]} and opeitms_id = #{line_data[:custact_opeitm_id]}
							and crrs_id_custprice = #{line_data[:custact_crr_id]}
							and maxqty >= #{line_data[:custact_qty]}
							and minqty < #{line_data[:custact_qty]}
							and  expiredate >= to_date('#{line_data[:custact_depdate]}','yyyy/mm/dd')
							order by maxqty,expiredate limit 1
					&
				price = ActiveRecord::Base.connection.select_one(strsql)
				if price
			   	decimal = line_data[:crr_decimal].to_i
					line_data[:custact_amt] = line_data[:custact_qty].to_f * price["price"].to_f
				   	case line_data[:cust_amtround]  ###1:切り捨て　2:四捨五入 3:切り上げ
				   	when "1"
						line_data[:custact_amt] = line_data[:custact_amt].floor(decimal + 1)
						line_data[:custact_tax] = (line_data[:custact_amt] * line_data[:custact_taxrate].to_f / 100).floor(decimal )
			   		when "2"
						line_data[:custact_amt] = line_data[:custact_amt].round(decimal + 1)
						line_data[:custact_tax] = (line_data[:custact_amt] * line_data[:custact_taxrate].to_f / 100).round(decimal )
			   		when "3"
						line_data[:custact_amt] = line_data[:custact_amt].ceil(decimal + 1)
						line_data[:custact_tax] = (line_data[:custact_amt] * line_data[:custact_taxrate].to_f / 100).ceil(decimal)
			   		end
				else
					line_data[:custord_price] = line_data[:custord_masterprice] = 0
					line_data[:custord_amt] = 0
					line_data[:custact_contractprice] = "C"  ###C:マスター単価無
				end
		   	end
		end
		return line_data,err
	end

	def proc_judge_check_amt line_data,item,index,screenCode  ###M
		decimal = line_data[:crr_decimal].to_i
		tblchop = screenCode.split("_")[1].chop
		err = nil
		case  screenCode 
		when /acts$|dlvs$/
			symqty = (tblchop + "_qty_stk").to_sym
			symamt = (tblchop + "_amt").to_sym
		when /schs$/ 
			symqty = (tblchop + "_qty_sch").to_sym
			symamt = (tblchop + "_amt_sch").to_sym
		else 
			symqty = (tblchop + "_qty").to_sym
			symamt = (tblchop + "_amt").to_sym
		end
		symprice = (tblchop + "_price").to_sym
		symtax = (tblchop + "_tax").to_sym
		symtaxrate = (tblchop + "_taxrate").to_sym
	 	line_data[symamt] = line_data[symqty].to_f * line_data[symprice].to_f
		case line_data[:cust_amtround]  ###1:切り捨て　2:四捨五入 3:切り上げ
		when "1"
		 line_data[symamt] = line_data[symamt].floor(decimal.to_i )
		 line_data[symtax] = (line_data[symamt] * line_data[symtaxrate].to_i / 100).floor(decimal.to_i )
		when "2"
		 line_data[symamt] = line_data[symamt].round(decimal.to_i )
		 line_data[symtax] = (line_data[symamt] * line_data[symtaxrate].to_i / 100).round(decimal.to_i )
		when "3"
		 line_data[symamt] = line_data[symamt].ceil(decimal.to_i )
		 line_data[symtax] = (line_data[symamt] * line_data[symtaxrate].to_i / 100).ceil(decimal.to_i )
		else
			line_data[symamt] = line_data[symamt].ceil(decimal.to_i )
			line_data[symtax] = (line_data[symamt] * line_data[symtaxrate].to_i / 100).ceil(decimal.to_i )
		end
		return line_data,err
	end


	def proc_judge_check_taxrate line_data,item,index,screenCode  ###MkInvoiveNoの時のみ
		err = nil
		case screenCode
		when /puracts/  ###再度求める
			case line_data[:itm_taxflg]
			when "A"
				if line_data[:puract_sno_purord] != "" and !line_data[:puract_sno_purord].nil?
					strsql = %Q&
						select isudate from purords where sno = #{line_data[:puract_sno_purord]}
					&
					base_date =  ActiveRecord::Base.connection.select_value(strsql)
				else  ###purordsを纏めるとき同一taxrateであること
					strsql = %Q&
						select * from linktbls where tblid = #{line_data[:puract_id]} and tblname = 'puracts'
					&
					src =  ActiveRecord::Base.connection.select_one(strsql)
					case src["srctblname"]
					when "purords"
						strsql = %Q&
							select isudate from purords where id = #{src["srctblid"]}
						&
						base_date =  ActiveRecord::Base.connection.select_value(strsql)
					when "purinsts"  ### taxflが異なるものを纏めないこと
						strsql = %Q&
							select isudate from purords ord
										inner join linktbls link on link.srctblid = ord.idc
								where link.srctblname = 'purords' and link.tblname = 'puroinsts' and tblid = #{src["tblid"]}
						&
						base_date =  ActiveRecord::Base.connection.select_value(strsql)
					when "purreplyinputs"
						strsql = %Q&
							select * from linktbls where tblid = #{src["srctblid"]} and tblname = 'purreplyinputs'
						&
						reply =  ActiveRecord::Base.connection.select_one(strsql)
						case reply["srctblname"]
						when "purords"
							strsql = %Q&
								select isudate from purords where id = #{reply["srctblid"]}
							&
							base_date =  ActiveRecord::Base.connection.select_value(strsql)
						when "purinsts"
							strsql = %Q&
								select isudate from purords ord
											inner join linktbls link on link.srctblid = ord.id
									where link.srctblname = 'purords' and link.tblname = 'puroinsts' and tblid = #{reply["tblid"]}
							&
							base_date =  ActiveRecord::Base.connection.select_value(strsql)
						end
					when "purdlvs"  ###業者出荷。業者からの出荷情報。data受信を想定。
						strsql = %Q&
							select * from linktbls where tblid = #{src["srctblid"]} and tblname = 'purdlvs'
						&
						dlv =  ActiveRecord::Base.connection.select_one(strsql)
						case dlv["srctblname"]
						when "purords"
							strsql = %Q&
								select isudate from purords where id = #{dlv["srctblid"]}
							&
							base_date =  ActiveRecord::Base.connection.select_value(strsql)
						when "purinsts"
							strsql = %Q&
								select isudate from purords ord
											inner join linktbls link on link.srctblid = ord.id
									where link.srctblname = 'purords' and link.tblname = 'puroinsts' and tblid = #{dlv["tblid"]}
							&
							base_date =  ActiveRecord::Base.connection.select_value(strsql)
						when "purreplyinputs"
							strsql = %Q&
								select * from linktbls where tblid = #{dlv["srctblid"]} and tblname = 'purreplyinputs'
							&
							reply =  ActiveRecord::Base.connection.select_one(strsql)
							case reply["srctblname"]
							when "purords"
								strsql = %Q&
									select isudate from purords where id = #{reply["srctblid"]}
								&
								base_date =  ActiveRecord::Base.connection.select_value(strsql)
							when "purinsts"
								strsql = %Q&
									select isudate from purords ord
												inner join linktbls link on link.srctblid = ord.id
										where link.srctblname = 'purords' and link.tblname = 'puroinsts' and tblid = #{reply["tblid"]}
								&
								base_date =  ActiveRecord::Base.connection.select_value(strsql)
							end
						end
					end
				end
			when "0","1","9"
				base_date =  line_data[:puract_rcptdate]
			else
				Rails.logger.debug"taxflg error B paymants_id : #{line_data[:paymets_id]} LINE:#{__LINE__} "
				raise
			end
			strsql = %Q&
						select taxrate from taxtbls where taxflg = '#{line_data[:itm_taxflg]}' 
													and expiredate >= to_date('#{base_date}','yyyy/mm/dd')
													order by expiredate limit 1
			&
			line_data[:puract_taxrate] = ActiveRecord::Base.connection.select_value(strsql)
		when /purrets/
			strsql = %Q&
				select taxrate from puracts where sno_puract = #{line_data[:purret_sno_puract]}
			&
			line_data[:puract_taxrate] = ActiveRecord::Base.connection.select_value(strsql)
		when /shpschs/  ###shpacts以外は求めて表示するだけ
			base_date =   line_data[:shpsch_isudate]
			strsql = %Q&
						select taxrate from taxtbls where taxflg = '#{line_data[:itm_taxflg]}' 
													and expiredate >= to_date('#{base_date}','yyyy/mm/dd')
													order by expiredate limit 1
			&
			line_data[:shpsch_taxrate] = ActiveRecord::Base.connection.select_value(strsql)
		when /shpacts/  ###shpacts以外は求めて表示するだけ
			base_date =   line_data[:shpact_rcptdate]
			strsql = %Q&
						select taxrate from taxtbls where taxflg = '#{line_data[:itm_taxflg]}' 
													and expiredate >= to_date('#{base_date}','yyyy/mm/dd')
													order by expiredate limit 1
			&
			line_data[:shpsch_taxrate] = ActiveRecord::Base.connection.select_value(strsql)
		when /custacts/ ###再度求める
			case line_data[:itm_taxflg]
			when "A"
				if line_data[:custact_sno_custord] != "" and !line_data[:custact_sno_custord].nil?
					strsql = %Q&
						select isudate from custords where sno = #{line_data[:custact_sno_custord]}
					&
					base_date =  ActiveRecord::Base.connection.select_value(strsql)
				else  ###purordsを纏めるとき同一taxrateであること
					strsql = %Q&
						select * from linkcusts where tblid = #{line_data[:custact_id]} and tblname = 'custacts'
					&
					src =  ActiveRecord::Base.connection.select_one(strsql)
					case src["srctblname"]
					when "custords"
						strsql = %Q&
							select isudate from custords where id = #{src["srctblid"]}
						&
						base_date =  ActiveRecord::Base.connection.select_value(strsql)
					when "custinsts"  ### taxflが異なるものを纏めないこと
						strsql = %Q&
							select isudate from custords ord
										inner join linkcusts link on link.srctblid = ord.idc
								where link.srctblname = 'custords' and link.tblname = 'custinsts' and tblid = #{src["tblid"]}
						&
						base_date =  ActiveRecord::Base.connection.select_value(strsql)
					when "custdlvs"
						strsql = %Q&
							select * from linkcusts where tblid = #{src["srctblid"]} and tblname = 'custdlvs'
						&
						dlv =  ActiveRecord::Base.connection.select_one(strsql)
						case dlv["srctblname"]
						when "custords"
							strsql = %Q&
								select isudate from custords where id = #{dlv["srctblid"]}
							&
							base_date =  ActiveRecord::Base.connection.select_value(strsql)
						when "custinsts"
							strsql = %Q&
								select isudate from custords ord
											inner join linktbls link on link.srctblid = ord.id
									where link.srctblname = 'purords' and link.tblname = 'puroinsts' and tblid = #{dlv["tblid"]}
							&
							base_date =  ActiveRecord::Base.connection.select_value(strsql)
						end
					end
				end
			when "0","1","9"
				strsql = %Q&
					select saledate from custacts where  id = #{line_data[:custact_id]}
				&
				base_date =  ActiveRecord::Base.connection.select_value(strsql)
			else
				Rails.logger.debug"taxflg error C 1 paymants_id : #{line_data[:paymets_id]} LINE:#{__LINE__} "
				raise
			end
			strsql = %Q&
						select taxrate from taxtbls where taxflg = '#{line_data[:itm_taxflg]}' 
													and expiredate >= to_date('#{base_date}','yyyy/mm/dd')
													order by expiredate limit 1
			&
			line_data[:custact_taxrate] = ActiveRecord::Base.connection.select_value(strsql)
		
		when /custrets/
			strsql = %Q&
				select taxrate from custacts where sno_puract = #{line_data[:custret_sno_custact]}
			&
			line_data[:custact_taxrate] = ActiveRecord::Base.connection.select_value(strsql)
		when /custords/
			case line_data[:itm_taxflg]
			when "A"
				base_date =  line_data[:custord_duedate]
			else
				base_date =  line_data[:custord_isudate]
			end
			strsql = %Q&
						select taxrate from taxtbls where taxflg = '#{line_data[:itm_taxflg]}' 
													and expiredate >= to_date('#{base_date}','yyyy/mm/dd')
													order by expiredate limit 1
			&
			line_data[:custord_taxrate] = ActiveRecord::Base.connection.select_value(strsql)
		when /custschs/
			case line_data[:itm_taxflg]
			when "A"
				base_date =  line_data[:custsch_duedate]
			else
				base_date =  line_data[:custsch_isudate]
			end
			strsql = %Q&
						select taxrate from taxtbls where taxflg = '#{line_data[:itm_taxflg]}' 
													and expiredate >= to_date('#{base_date}','yyyy/mm/dd')
													order by expiredate limit 1
			&
			line_data[:custsch_taxrate] = ActiveRecord::Base.connection.select_value(strsql)
		end
		return line_data,err
	end

	def proc_judge_check_mkprdpurord_code(line_data,item,index,screenCode)
		if line_data[item.to_sym] == "dummy" or line_data[item.to_sym] == ""
			return line_data, nil
		end
		###
		case item
		when /_org$/
			if line_data["mkprdpurord_orgtblname"] !~ /prd|pur/
				line_data[item.sub("code","name").to_sym] = " not select orgtblname "
				err = "#{line_data[item.to_sym]}  not select org table "
				return line_data,err
			end
		when /_pare$/
			if line_data["mkprdpurord_paretblname"] !~ /prd|pur/
				line_data[item.sub("code","name").to_sym]  = " not select paretblname"
				err = "#{line_data[item.to_sym]}  not select parent table "
				return line_data,err
			end
		end
		case item
		when /loca/
			strsql = %Q&
						select loca_name from r_locas where loca_code = '#{line_data[item.to_sym]}'
						&
		when /itm/
			strsql = %Q&
						select itm_name from r_itms where itm_code = '#{line_data[item.to_sym]}'
						&
		when /shelfno/
			strsql = %Q&
						select shelfno_name from r_chrgs where shelfno_code = '#{line_data[item.to_sym]}'
						&
		when /chrg/
			strsql = %Q&
						select person_code_chrg from r_chrgs where persomn_code_chrg = '#{line_data[item.to_sym]}'
						&
		when /sno/
			strsql = %Q&
						select sno from #{line_data["mkprdpurord_paretblname"]} where sno = '#{line_data[item.to_sym]}'
						&
		end
		codeToName = ActiveRecord::Base.connection.select_value(strsql)
		if codeToName
			line_data[item.sub("code","name").to_sym] = codeToName
			err = nil
		else
			line_data[item.sub("code","name").to_sym] = "#{line_data[item.to_sym]}  not found"
			err = " #{item}:#{line_data[item.to_sym]}  not found"
		end
				
		return line_data,err
	end
	def proc_judge_check_seqnoOfTblfields(line_data,item,index,screenCode)
		case screenCode 
		when /tblfields/
			case line_data[:pobject_code_tbl]
			when /ords$|schs$/   ###tranganntsからxxxschs,mkprdpurordsからxxxords作成時利用
				case line_data[:pobject_code_fld]
				when /starttime/ 
					strsql = %Q&
							select tblfield_seqno from r_tblfields where pobject_code_tbl = '#{line_data[:pobject_code_tbl]}'
														and pobject_code_fld = 'duedate' 
					&
					duedate_seqno = ActiveRecord::Base.connection.select_value(strsql)
					if duedate_seqno
						if duedate_seqno < line_data[:tblfield_seqno]
							return line_data, nil
						else
							err = "  seqno of starttime > seqno of duedate "
							return line_data, nil
						end
					end
				when /duedate/ 
					strsql = %Q&
							select tblfield_seqno from r_tblfields where pobject_code_tbl = '#{line_data[:pobject_code_tbl]}'
														and pobject_code_fld = 'starttime' 
					&
					starttime_seqno = ActiveRecord::Base.connection.select_value(strsql)
					if starttime_seqno
						if starttime_seqno < line_data[:tblfield_seqno]
							err = "  seqno of starttime > seqno of duedate "
							return line_data,err 
						else
							return line_data, nil						
						end
					end
				when /qty/
					###
					##  coding missing
					###
				end
			end
		else
			return line_data, nil
		end
	end
	###
	#
	### prd,pur ・・・schs,ords,insts,acts,retsのレコード作成　	
	def proc_schs_fields_making nd,parent,screenCode ,command_x  ###xxxschsの作成のみ
		err = false
		qty_require = 0
		nd["packqty"] =  if nd["packqty"].to_f == 0
									1
								else
									nd["packqty"].to_f
								end
		nd["consumunitqty"] = case nd["consumunitqty"].to_f when 0 then 1 else nd["consumunitqty"].to_f end

		tblnamechop = command_x["sio_viewname"].split("_")[1].chop
		command_x["sio_code"] =  command_x["sio_viewname"] 

		strsql =  %Q%select pobject_code_fld from r_tblfields where tblfield_expiredate > current_date and 
						pobject_code_tbl = '#{command_x["sio_code"].split("_")[1]}'
						order by tblfield_seqno
		%
		fields = ActiveRecord::Base.connection.select_all(strsql)
		fields.each do |fd|  ###tblfield_seqnoの順に処理される。tblfield_seqno順に処理するためcommand_xは利用できない。
			###lotnoはpur,prd項目ではないのでここにはない。
			next if !command_x[tblnamechop + "_" + fd["pobject_code_fld"]].nil? and command_x[tblnamechop + "_" + fd["pobject_code_fld"]] != ""
			case fd["pobject_code_fld"]
			when "id"  ###追加または更新の判断
				command_x = field_tblid(tblnamechop,command_x,nd,parent)
			# when "confirm"
			# 	command_x = field_confirm(tblnamechop,command_x,nd,parent)
			when "isudate"
				if command_x ["sio_classname"] =~ /_add_/
					command_x = field_isudate(tblnamechop,command_x,nd) 
				end
			when "opeitms_id"
				command_x = field_opeitms_id(tblnamechop,command_x,nd)
			# when "shelfnos_id"  ###payments_idを含む
			# 	command_x = field_shelfnos_id(tblnamechop,command_x,nd)
			when "starttime"  ###稼働日計算  seqno.starttime > seqno.duedate
				command_x = proc_field_starttime(parent,nd,tblnamechop,command_x)  ###qty_schで計算でする為
			when "depdate"  ###稼働日計算  seqno.starttime > seqno.duedate   ##shpxxxはmold,ITool以外は作成しない
				case tblnamechop
				when "shpest"
					command_x = proc_field_starttime(parent,nd,tblnamechop,command_x)  ###qty_schで計算でする為
				else
				end
			when "shelfnos_id_to"
				command_x = field_shelfnos_id_to(tblnamechop,command_x,nd)
			when "chrgs_id"
				command_x = field_chrgs_id(tblnamechop,command_x,nd) 
			when "fcoperators_id"
				command_x = field_fcoperators_id(tblnamechop,command_x,parent) 
			when "duedate"  ###稼働日計算
				command_x = field_duedate(tblnamechop,command_x,nd,parent)
			when "endtime"  
				###command_x = field_endtime(tblnamechop,command_x,nd,parent)
			when "toduedate"  ###稼働日計算
				command_x = field_toduedate(tblnamechop,command_x,nd,parent)
			when "facilities_id"  
				command_x,err = proc_field_facilities_id(tblnamechop,command_x,nd)
			when "qty_sch"   ### 
				command_x,qty_require = field_qty_sch(tblnamechop,command_x,nd,parent)
			### tblfield_seqnoは qty,duedateより大きいと	
			when "price"  ###保留 amt tax  itm_code_client crrs_idを含む
				command_x = field_price_amt_tax_contractprice(tblnamechop,command_x) 
			# when "itm_code_client"  ###保留 amt tax  を含む
			# 	command_x = field_itm_code_client(tblnamechop,command_x,nd,parent) 
			when "gno" ###画面の時用にror_blkctl.create_src_tblでもsetしてる
				command_x["#{tblnamechop}_gno"]  = proc_field_gno(tblnamechop,command_x["id"])
			when "sno"  ###tblfield_seqnoはidの後であること。###画面の時用にror_blkctl.create_src_tblでもsetしてる
				command_x["#{tblnamechop}_sno"]  = proc_field_sno(tblnamechop,command_x["#{tblnamechop}_isudate"] ,command_x["id"])
			when "cno"  ###画面の時用にror_blkctl.crete_src_tblでもsetしてる
			when "prjnos_id"
				command_x = field_prjnos_id(tblnamechop,command_x,nd,parent)
			when "expiredate"
				command_x = field_expiredate(tblnamechop,command_x,nd,parent)
			when "tax"
				### field_price_amt_tax_contractprice
			end	
		end		
		return command_x,qty_require,err
	end	 

	def field_tblid tblnamechop,command_x,nd,parent
		if command_x["id"] == "" or  command_x["id"].nil?
			command_x["sio_classname"] = "_add_grid_linedata"
			command_x["id"] =  ArelCtl.proc_get_nextval("#{tblnamechop}s_seq")
	 	else         
			command_x["sio_classname"] = "_edit_update_grid_linedata"
	 	end   
		command_x["#{tblnamechop}_id"] = command_x["id"]
		return command_x
	end	

	# def field_confirm tblnamechop,command_x,nd,parent
	# 	command_x["#{tblnamechop}_confirm"] = false if command_x["#{tblnamechop}_confirm"].nil? or  command_x["#{tblnamechop}_confirm"] == ""
	# 	return command_x
	# end	

	def field_opeitms_id tblnamechop,command_x,nd
		key = tblnamechop + "_opeitm_id" 
		command_x[key] = nd["opeitms_id"]  ###  
		nd.each do |fld,val|
			case fld
			when /processseq/
				command_x["opeitm_processseq"] = val
			when /priority/
				command_x["opeitm_priority"] = val
			when /shelfnos_id_opeitm/
				locas_id = ActiveRecord::Base.connection.select_value(%Q&select locas_id_shelfno from shelfnos where id = #{val}&)				
				case  tblnamechop 
				when /^pur/
					supplier = ActiveRecord::Base.connection.select_one(%Q&select * from suppliers where locas_id_supplier = #{locas_id}&)
					command_x["#{tblnamechop}_supplier_id"] = supplier["id"]
					command_x["#{tblnamechop}_contractprice"] = supplier["contractprice"]
					command_x["supplier_amtround"] = supplier["amtround"]
					command_x["#{tblnamechop}_crr_id"] = supplier["crrs_id_supplier"]
				when /^prd/
					command_x["shelfno_loca_id_shelfno"] = locas_id
					command_x["#{tblnamechop}_shelfno_id"] = nd["shelfnos_id_opeitm"] ##
				else
					command_x["#{tblnamechop}_shelfno_id"] = nd["shelfnos_id_opeitm"] ##
				end
			when /itms_id/
				command_x["opeitm_itm_id"] = val
			when /taxflg/		
				case  tblnamechop 
				when /^pur/
					command_x["itm_taxflg"] = nd["taxflg"]
				end
			end
		end
		return command_x
	end

	def field_locas_id_to tblnamechop,command_x,nd,parent
		command_x["#{tblnamechop}_loca_id_to"] = nd["locas_id_to"] ##
		return command_x
	end 

	# def field_shelfnos_id tblnamechop,command_x,nd
	# 	command_x["#{tblnamechop}_shelfno_id"] = nd["shelfnos_id_opeitm"] ##
	# 	shelfno_loca_id_shelfno =  ActiveRecord::Base.connection.select_value(%Q%
	# 		select locas_id_shelfno from shelfnos where id = #{nd["shelfnos_id_opeitm"]} 
	# 		%)
		
	# 	command_x["shelfno_loca_id_shelfno"] = shelfno_loca_id_shelfno ##
	# 	# case nd["prdpur"]
	# 	# when "pur"
	# 	# 	strsql = %Q%select  * from payments where locas_id_payment = #{command_x["shelfno_loca_id_shelfno"]}%
	# 	# 	rec = ActiveRecord::Base.connection.select_one(strsql)
	# 	# 	###supplier_code = dummy は必須 id = 0
	# 	# 	if rec
	# 	# 		command_x["#{tblnamechop}_payment_id"] = rec["id"] ##
	# 	# 		command_x["#{tblnamechop}_crr_id"] = rec["crrs_id_payment"] ##
	# 	# 	else
	# 	# 		command_x["#{tblnamechop}_payment_id"] = 0
	# 	# 		command_x["#{tblnamechop}_crr_id"] = 0
	# 	# 	end
	# 	# end
	# 	return command_x
	# end

	def field_shelfnos_id_to tblnamechop,command_x,nd
		command_x["#{tblnamechop}_shelfno_id_to"] = nd["shelfnos_id_to_opeitm"] ##
		return command_x
	end 


	def field_processseq_pare tblnamechop,command_x,nd,parent
		command_x["#{tblnamechop}_processseq_pare"] = parent["processseq"] 
		return command_x
	end	

	def field_isudate tblnamechop,command_x,nd
		if command_x["#{tblnamechop}_isudate"].nil? or command_x["#{tblnamechop}_isudate"] == ""
			command_x["#{tblnamechop}_isudate"] = Time.now.to_s 
		end
		return command_x
	end	 

	def field_duedate tblnamechop,command_x,nd,parent
		if tblnamechop =~ /dvs|erc/
			Rails.logger.debug " class:#{self} ,line:#{__LINE__},command_x:#{command_x} "
			Rails.logger.debug " class:#{self} ,line:#{__LINE__},parent:#{parent} "
			Rails.logger.debug " class:#{self} ,line:#{__LINE__},nd:#{nd} "
		end
		pstarttime =  parent["starttime"].to_time  ###ercschsの親はdvsschs
		pduedate =  parent["duedate"].to_time
		case nd["units_lttime"]  ###char(4)
		when "Day "
			dayHour = 24*3600   ###  duedate 16:00   starttime 10:00
		when "Hour"
			dayHour = 3600
		else 
			dayHour = 1
			starttime = Time.now
		end
		case tblnamechop
		when /prd|pur|dym/
			if nd["shelfnos_id_to_opeitm"] == parent["shelfnos_id_trn"]
				duedate = pstarttime - 1*3600  ###稼働日
			else
				if nd["locas_id_to_shelfno"] == parent["shelfnos_id_trn"]
					duedate = pstarttime - 4*3600  ###稼働日
				else
					duedate = pstarttime - 24*3600  ###稼働日 出庫作業考慮
				end
			end
		when /dvssch/
			duedate =  pduedate + ((nd["postprocessinglt"]||=0).to_f)*dayHour ###後処理
		when /shpest/  ###duedate 工具返還日
			duedate =  pduedate + ((nd["postprocessinglt"]||=0).to_f)*dayHour ###後処理
		when /ercsch/
			case command_x["ercsch_processname"]   ###親はdvsschs
			when "changeover"
				duedate =  pstarttime  + (nd["changeoverlt"]||=0).to_f*dayHour 
			when "require"
				duedate =  	pduedate  - ((nd["postprocessinglt"]||=0).to_f)*dayHour  
			when "postprocess"
				duedate = pduedate 
			end
		end
		if nd["units_lttime"] == "Day "
			if duedate.strftime("%H") < "08"
				duedate = duedate - 24*3600   ###前日
				command_x[(tblnamechop+"_duedate")]  = (duedate.strftime("%Y-%m-%d") + " 16:00:00")
			else
				if duedate.strftime("%H") < "13"
					command_x[(tblnamechop+"_duedate")]  = (duedate.strftime("%Y-%m-%d") + " 08:00:00")
				else	
					if duedate.strftime("%H") < "16"
						command_x[(tblnamechop+"_duedate")]  = (duedate.strftime("%Y-%m-%d") + " 13:00:00")
					else	
						command_x[(tblnamechop+"_duedate")]  = (duedate.strftime("%Y-%m-%d") + " 16:00:00")
					end
				end
			end
		else
			command_x[(tblnamechop+"_duedate")]  = (duedate.strftime("%Y-%m-%d %H:%M:%S"))
		end
		return command_x
	end

	def field_endtime tblnamechop,command_x,nd,parent
		# endtime = parent["starttime"].to_time - 24*3600  ###稼働日
		# command_x["#{tblnamechop}_endtime"] = endtime.strftime("%Y-%m-%d %H:%M:%S")
		# return command_x
	end

	
	def field_toduedate tblnamechop,command_x,nd,parent  ###先行納品可能納期
		command_x["#{tblnamechop}_toduedate"] = command_x["#{tblnamechop}_toduedate"] = command_x["#{tblnamechop}_duedate"]
		return command_x
	end

	def proc_field_facilities_id tblnamechop,command_x,nd
		strsql = %Q& select id from facilities  where itms_id = #{nd["itms_id"]}&
		facilitie_id = ActiveRecord::Base.connection.select_value(strsql)
		if facilitie_id
			command_x["#{tblnamechop}_facilitie_id"] = facilitie_id
			err = false
		else
			err = true
		end
		return command_x,err
	end

	def proc_field_starttime parent,nd,tblnamechop,command_x
		###if tblnamechop =~ /dvs|erc/
			Rails.logger.debug " class:#{self} ,line:#{__LINE__},command_x:#{command_x} "
			Rails.logger.debug " class:#{self} ,line:#{__LINE__},parent:#{parent} "
			Rails.logger.debug " class:#{self} ,line:#{__LINE__},nd:#{nd} "
		###end
		case nd["units_lttime"]  ###char(4)
		when "Day "
			dayHour = 24*3600   ###  duedate 16:00   starttime 10:00
		when "Hour"
			dayHour = 3600
		else 
			dayHour = 1
			starttime = Time.now
		end
		pstarttime =  parent["starttime"].to_time  ###ercschsの親はdvsschs
		pduedate =  parent["duedate"].to_time
		cduedate = command_x["#{tblnamechop}_duedate"].to_time
		
		case tblnamechop   ###insts ,reply,dlvs,actsではstarttimeはない
		when /prdord|purord|pursch|dym/
			starttime = cduedate - (nd["duration"]||=1).to_f*dayHour
		when /prdsch/
		 	qty_sch = command_x["prdsch_qty_sch"].to_f
			strsql = %Q&
				select nd.packqtyfacility,nd.duration_facility,itm.classlist_code,op.duration 
					from nditms nd
					inner join (select i.id itms_id,c.code classlist_code from itms i
										inner join classlists c	on i.classlists_id = c.id
													where c.code in('apparatus') )								
					itm on itm.itms_id = nd.itms_id_nditm
					inner join opeitms op on op.id = nd.opeitms_id
					where op.itms_id = #{nd["itms_id"]} and op.processseq = #{nd["processseq"]} 
					and  op.priority = 999 ---nd["itms_id"],nd["processseq"] = child itms
					 &
			appa = ActiveRecord::Base.connection.select_one(strsql)
			if appa 		
				if  (appa["duration_facility"].to_f) > 0   ###装置のltなし
					if (appa["packqtyfacility"].to_f) > 0  ###nd["duration"].nil? --> tbl=dymschs&opeitms無
						 starttime =  cduedate - (appa["duration_facility"].to_f)*qty_sch/(appa["packqtyfacility"].to_f).ceil*dayHour    
					else
						 starttime =  cduedate - (appa["duration_facility"].to_f)*dayHour
					end
				else
					 starttime =  cduedate - (appa["duration"]||=1).to_f*dayHour  ###prdschs.opeitms_id.duration
				 end
			else
					 starttime =  cduedate - (nd["duration"]||=1).to_f*dayHour  ###nd["duration"].nil? --> tbl=dymschs&opeitms無,cal=-1 --> reverse
			end
		when "dvssch"  ###親はprdschs
			starttime =  pstarttime - (nd["changeoverlt"]||=0).to_f*dayHour 
		when "shpest" ###親はprdschs 工具・金型
			starttime =  pstarttime - (nd["changeoverlt"]||=0).to_f*dayHour 
		when "ercsch" ###親はdvsschs
			case command_x["ercsch_processname"]   ###親はdvsschs
			when "changeover"
				starttime = pstarttime
			when "require"
				starttime =  pstarttime + (nd["changeoverlt"]||=0).to_f*dayHour 
			when "postprocess"
				starttime = pduedate - ((nd["postprocessinglt"]||=0).to_f)*dayHour 
			end
		end
		
		if nd["units_lttime"] == "Day "
			if starttime.strftime("%M") < "13"
				case tblnamechop
				when /prdord/
		 			command_x["prdsch_starttime"] = command_x["prdsch_commencementdate"] =  (starttime.strftime("%Y-%m-%d") + " 08:00:00" )
				when /shpest/
		 			command_x["shpest_depdate"] =  (starttime.strftime("%Y-%m-%d") + " 08:00:00" )
				else
		 			command_x[(tblnamechop+"_starttime")] =  (starttime.strftime("%Y-%m-%d") + " 08:00:00" )
				end
			else
				if starttime.strftime("%M") < "16"
					case tblnamechop
					when /prdord/
						command_x["prdsch_starttime"] = command_x["prdsch_commencementdate"] =  (starttime.strftime("%Y-%m-%d") + " 13:00:00" )
					when /shpest/
						command_x["shpest_depdate"] =  (starttime.strftime("%Y-%m-%d") + " 13:00:00" )
					else
						command_x[(tblnamechop+"_starttime")] =  (starttime.strftime("%Y-%m-%d") + " 13:00:00" )
					end
				else
					###前日
					starttime = starttime - 24*3600
					case tblnamechop
					when /prdord/
		 				command_x["prdord_starttime"] = command_x["prdord_commencementdate"] =  (starttime.strftime("%Y-%m-%d") + " 08:00:00" )
					when /shpest/
		 				command_x["shpest_depdate"] =  (starttime.strftime("%Y-%m-%d") + " 08:00:00" )
					else
		 				command_x[(tblnamechop+"_starttime")] =  (starttime.strftime("%Y-%m-%d") + " 0800:00" )
					end
				end
			end
				
		else
			case tblnamechop
			when /prdord/
		 		command_x["prdsch_starttime"] = command_x["prdsch_commencementdate"] =  (starttime.strftime("%Y-%m-%d %H:%M:%S") )
			when /shpest/
		 		command_x["shpest_depdate"] =  (starttime.strftime("%Y-%m-%d %H:%M:%S") )
			else
		 		command_x[(tblnamechop+"_starttime")] =  (starttime.strftime("%Y-%m-%d %H:%M:%S") )
			end
		end
		return command_x
	end

	def field_chrgs_id tblnamechop,command_x,nd ### seq_noは　chrgs_id > custs_id,suppliers_id,workplaces_idであること
		if command_x["#{tblnamechop}_chrg_id"].nil? or  command_x["#{tblnamechop}_chrg_id"] == ""
			if nd["chrgs_id"]
				command_x["#{tblnamechop}_chrg_id"] = nd["chrgs_id"]
			else
				case tblnamechop
				when /^cust/
					strsql = %Q&
							select chrgs_id_cust chrgs_id from custs where id = #{command_x["#{tblnamechop}_cust_id"] }
					&
				when /^pur/
				 	strsql = %Q&
				 			select chrgs_id_supplier chrgs_id from suppliers 
									where locas_id_supplier = #{nd["locas_id_shelfno"]}
				 	&
				 when /^prd/
				 	strsql = %Q&
				 			select chrgs_id_workplace chrgs_id from workplaces 
							 		where locas_id_workplace = #{nd["locas_id_shelfno"]}
				 	&
				when /dymsch/
					strsql = %Q&
							select 0 chrgs_id 
					&
				else
					Rails.logger.debug"get chrgs_id error D LINE:#{__LINE__} "
					raise
				end
				command_x["#{tblnamechop}_chrg_id"] = ActiveRecord::Base.connection.select_value(strsql)
			end
		end
		return command_x
	end	

	def field_fcoperators_id(tblnamechop,command_x,parent) 
		strsql = %Q&
				select fc.id ,fc.itms_id_fcoperator from fcoperators fc
						inner join facilities fa on fa.itms_id = fc.itms_id_fcoperator
						left join ercschs es1 on fc.id = es1.fcoperators_id and es1.starttime  < to_timestamp('#{command_x["ercsch_starttime"]}','yyyy-mm-dd hh24:mi:ss') 
																			and es1.duedate  > to_timestamp('#{command_x["ercsch_starttime"]}','yyyy-mm-dd hh24:mi:ss')
						left join ercschs es2 on fc.id = es2.fcoperators_id and es2.starttime  < to_timestamp('#{command_x["ercsch_duedate"]}','yyyy-mm-dd hh24:mi:ss')
																			and es2.duedate > to_timestamp('#{command_x["ercsch_duedate"]}','yyyy-mm-dd hh24:mi:ss')
						left join ercords eo1 on fc.id = eo1.fcoperators_id and eo1.starttime  < to_timestamp('#{command_x["ercsch_starttime"]}','yyyy-mm-dd hh24:mi:ss') 
																			and eo1.duedate  > to_timestamp('#{command_x["ercsch_starttime"]}','yyyy-mm-dd hh24:mi:ss')
						left join ercords eo2 on fc.id = eo2.fcoperators_id and eo2.starttime  < to_timestamp('#{command_x["ercsch_duedate"]}','yyyy-mm-dd hh24:mi:ss')
																			and eo2.duedate > to_timestamp('#{command_x["ercsch_duedate"]}','yyyy-mm-dd hh24:mi:ss')
						left join ercinsts ei1 on fc.id = ei1.fcoperators_id and ei1.starttime  < to_timestamp('#{command_x["ercsch_starttime"]}','yyyy-mm-dd hh24:mi:ss') 
																			and ei1.duedate  > to_timestamp('#{command_x["ercsch_starttime"]}','yyyy-mm-dd hh24:mi:ss')
						left join ercinsts ei2 on fc.id = ei2.fcoperators_id and ei2.starttime  < to_timestamp('#{command_x["ercsch_duedate"]}','yyyy-mm-dd hh24:mi:ss')
																			and ei2.duedate > to_timestamp('#{command_x["ercsch_duedate"]}','yyyy-mm-dd hh24:mi:ss')
						where fa.id = #{parent["facilities_id"]}
		&
		ids = ActiveRecord::Base.connection.select_all(strsql)
		if ids.to_ary.size > 0
			str = ""
			ids.each do |id|
				str << "'" + id["id"] + "',"
			end
			strsql = %Q&
				select fc.id from fcoperators fc
						where fc.id not in (#{str.chop}) and fc.itms_id_fcoperator = #{ids[0]["itms_id_fcoperator"]} order by fc.priority desc&
			fcoperators_id = ActiveRecord::Base.connection.select_value(strsql)
			if fcoperators_id.nil?
				strsql = %Q&
					select fc.id from fcoperators fc
							inner join facilities fa on fa.itms_id = fc.itms_id_fcoperator
							where fa.id = #{parent["facilities_id"] } order by fc.priority desc&
				fcoperators_id = ActiveRecord::Base.connection.select_value(strsql)
			end
		else
			strsql = %Q&
				select fc.id from fcoperators fc
						inner join facilities fa on fa.itms_id = fc.itms_id_fcoperator
						where fa.id = #{parent["facilities_id"] } order by fc.priority desc&
			fcoperators_id = ActiveRecord::Base.connection.select_value(strsql)
		end
		if fcoperators_id
			command_x["#{tblnamechop}_fcoperator_id"] = fcoperators_id
		else
			Rails.logger.debug " class:#{self} ,line:#{__LINE__},parent:#{parent} "
			Rails.logger.debug " class:#{self} ,line:#{__LINE__},command_x:#{command_x} "
			Rails.logger.debug " class:#{self} ,line:#{__LINE__}, can not get fcoperators_id"
			raise
		end
		return command_x
	end

	def field_qty_sch tblnamechop,command_x,nd,parent
		qty_require = proc_cal_qty_sch(parent["qty_handover"],
										nd["chilnum"],nd["parenum"],
										nd["consumunitqty"],nd["consumminqty"],nd["consumchgoverqty"])
		command_x["#{tblnamechop}_qty_sch"]  = proc_cal_qty_sch(parent["qty_sch"].to_f+ parent["qty"].to_f,
												nd["chilnum"],nd["parenum"],
												nd["consumunitqty"],nd["consumminqty"],nd["consumchgoverqty"])
		return command_x,qty_require
	end	

	def proc_cal_qty_sch(parent_qty,chilnum,parenum,consumunitqty,consumminqty,consumchgoverqty)
		qty_require = parent_qty.to_f * chilnum.to_f / parenum.to_f
		#consumunitqty等については親に合わせて計算する。
		if consumunitqty.to_f > 0
			qty_require = (qty_require /  consumunitqty.to_f).ceil *  consumunitqty.to_f
		end
		if consumminqty.to_f > qty_require
			qty_require = consumminqty.to_f  ###最小消費数
		end	
		qty_require += consumchgoverqty.to_f   ###段取り時に余分に使用(消費)される数量
	end

	def field_price_amt_tax_contractprice tblnamechop,command_x
		case tblnamechop
		when /pur/  ###supplierprices
			command_x,err = proc_judge_check_supplierprice(command_x.symbolize_keys,"",0,"r_#{tblnamechop}s")
		when  /shp/  ###shpprices
		end
		###  command_x = PriceLib.proc_price_amt(tblnamechop,command_x)
		return command_x.stringify_keys
	end

	def proc_field_sno(tblnamechop,isudate,id)  ###id=tbl.id
		(proc_snolist["#{tblnamechop}s"]||="") + (isudate||=Time.now).to_time.strftime("%y")[1] + 
					["0","1","2","3","4","5","6","7","8","9","A","B","C"][(isudate||=Time.now).to_time.strftime("%m").to_i]  + format('%04d', id) 
	end

	def proc_field_cno id 
		 format('%07d', id)
	end

	def proc_field_gno(tblnamechop,id)
		(proc_gnolist["#{tblnamechop}s"]||="") + format('%07d', id) 
	end	

	def field_prjnos_id tblnamechop,command_x,nd,parent
		command_x["#{tblnamechop}_prjno_id"] = parent["prjnos_id"] 
		return command_x
	end	

	def field_consumauto tblnamechop,command_x,nd,parent
		command_x["#{tblnamechop}_consumauto"] = (nd["consumauto"]||="")
		return command_x
	end

	def field_autocreate tblnamechop,command_x,nd,parent
		command_x["#{tblnamechop}_autocreate"] = (nd["autocreate"] ||="")
		return command_x
	end		
	
	def field_expiredate tblnamechop,command_x,nd,parent
		if command_x["#{tblnamechop}_expiredate"].nil? or command_x["#{tblnamechop}_expiredate"] == ""
			command_x["#{tblnamechop}_expiredate"] = "2099/12/31" 
		end
		return command_x
	end
	
	def proc_billord_exists(lineData)  ###既に請求書発行済?
		false
	end

	def proc_snolist   ###reqparams["segment"] = ["trn_org"]の対象でもある。
		{"purschs"=>"PS","purords"=>"PO","purinsts"=>"PH","purdlvs"=>"PV","puracts"=>"PA","dymschs"=>"DY",
			"purreplyinputs"=>"PL","prdreplyinputs"=>"ML",
			"prdschs"=>"MS","prdords"=>"MO","prdinsts"=>"MH","prdacts"=>"MA","prdrets"=>"MR",
			"dvsschs"=>"DS","dvsords"=>"DO","dvsacts"=>"DA",
			"billschs"=>"BS","billords"=>"BO","billinsts"=>"BH","billacts"=>"BA","billrets"=>"BR",
			"payschs"=>"YS","payords"=>"YO","payinsts"=>"YH","payacts"=>"YA","payrets"=>"YR",
			"custschs"=>"CS","custords"=>"CO","custinsts"=>"CJ","custdlvs"=>"CV","custacts"=>"CA","custrets"=>"CR",
			"ercschs"=>"ES","ercords"=>"EO","ercinsts"=>"EJ","ercacts"=>"CA",
			"custordheads"=>"CH","custactheads"=>"CB",
			"shpests"=>"ST","shpschs"=>"SS","shpords"=>"SO","shpinsts"=>"SH","shpacts"=>"SA","shprets"=>"SR"}
	end

	
	def proc_gnolist   ###reqparams["segment"] = ["trn_org"]の対象でもある。
		{"purschs"=>"GPS","purords"=>"GPE","purinsts"=>"GPH","purdlvs"=>"GPV","puracts"=>"GPA",
			"purreplyinputs"=>"GPL","prdreplyinputs"=>"GML",
			"prdschs"=>"GMS","prdords"=>"GME","prdinsts"=>"GMH","prdacts"=>"GMA","prdrets"=>"GMR",
			"billschs"=>"GBS","billords"=>"GBE","billinsts"=>"GBH","billacts"=>"GBA","billrets"=>"GBR",
			"payschs"=>"GYS","payords"=>"GYE","payinsts"=>"GYH","payacts"=>"GYA","payrets"=>"GYR",
			"custschs"=>"GCS","custords"=>"GCQ","custinsts"=>"GCJ","custdlvs"=>"GCV","custacts"=>"GCA","custrets"=>"GCR",
			"shpschs"=>"GSS","shpords"=>"GSE","shpinsts"=>"GSH","shpacts"=>"GSA","shprets"=>"GSR"}
	end

	def proc_get_endtime tblname,tbldata
	 	case tblname		
	 	when /dlvs/
	 		tbldata["depdate"]
	 	when /^puracts/
	 		tbldata["rcptdate"]
	 	when /^prdacts/
	 		tbldata["cmpldate"]
	 	when /rets/
	 		tbldata["retdate"]
	 	when /reply/
	 		tbldata["replydate"]
	 	when /^dvs/
	 		tbldata["duedate"]
	 	else
	 		tbldata["duedate"]
	 	end	
	end

end   ##module