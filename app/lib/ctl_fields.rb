# -*- coding: utf-8 -*-
module CtlFields
class CtlFieldsClass
### 個別項目　チェック
	def initialize()
		@findstatus = nil
		@mainviewflg = nil
		@missing = nil
		@command_x = {}
		@tbldata = {}
		@tblnamechop = ""
		@qty_require = 0  ###親のpackqtyを考慮
	end
		
	def  proc_chk_fetch_rec params  
		params[:err] = nil
		fetch_data,keys = get_fetch_rec params
		params[:parse_linedata] = fetch_data.dup
	  	if @findstatus
			if @mainviewflg   ##@mainviewflg = true 自分自身の登録
				if 	params[:parse_linedata]["aud"] == "add" or params["buttonflg"] =~ /add/
					params[:err] = "error duplicate code:#{keys},line:#{params[:index]} "
					params[:keys] = []
					keys.split(",").each do |key| 
				  		params[:keys] =  [key.split(":")[0].gsub(" ","")] 
						params[:parse_linedata][key+"_gridmessage"] = "error duplicate code #{key} "
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
			if @mainviewflg   ###自身の登録の時 
				###
				### r_tblfieldsの登録でr_blktbsがdetectできなかった時エラーにならない。!!!!!!!!!
				###
			else
				if @missing  ###検索に必要な項目まだ未入力
				else
					params[:err] =  "error   --->not find code:#{keys},line:#{params[:index]}  "
					keys.split(",").each do |key| ###コードが変更されたとき既に使用されている？
						params[:parse_linedata][key.split(":")[0]+"_gridmessage"] = "error not find code #{key} "
						if params[:parse_linedata][:errPath].nil? 
							params[:parse_linedata][:errPath] = [key.split(":")[0]+"_gridmessage"]
						end
					end  
				end	  
			end  
	  	end 
	  	params["linedata"] = JSON.generate(params[:parse_linedata])
	  	return params 
	end  

	def get_fetch_rec params
			strsql = ""
			keys = ""
			xno = ""
			srctblnamechop = ""
			screentblnamechop = params[:screenCode].split("_")[1].chop
			fetchview = params[:fetchview].split(":")[0]  ##拡張子の確認
			viewtblnamechop = fetchview.split("_")[1].chop
			fetch_data = params[:parse_linedata].dup
			@mainviewflg = true  ##自分自身の登録か？
			if params[:screenCode].split("_")[1] != fetchview.split("_")[1] 
					@mainviewflg = false
			else
				if fetchview.split(":")[1]   ###自身のテーブルを参照しいるとき
					@mainviewflg = false
				end	
			end	  
			fetcfieldgetsql = "select pobject_code_sfd from r_screenfields
								 where pobject_code_scr =  '#{params[:screenCode]}' 
								 and screenfield_paragraph = '#{params[:fetchview]}'"	
			delm = ""
			@missing = false   ###missing:true パラメータが未だ未設定　　false:チェックok
			strsql = " select * from #{fetchview}  where "
			ActiveRecord::Base.connection.select_all(fetcfieldgetsql).each do |rec|
				xfield = params[:parse_linedata][rec["pobject_code_sfd"]].to_s.gsub(",","_") ###入力項目に「,」が入っていた時
				keys <<  "#{rec["pobject_code_sfd"]}: '#{xfield}',"  ###入力項目に「,」が入っていた時
				if params[:parse_linedata][rec["pobject_code_sfd"]] == "" or params[:parse_linedata][rec["pobject_code_sfd"]].nil?   ###未入力
					@missing = true
				else
					if rec["pobject_code_sfd"] 	=~ /_sno_|_cno_/
						screentblnamechop,xno,srctblnamechop = rec["pobject_code_sfd"].split("_")  ### 
						strsql << " #{srctblnamechop}_#{xno} = '#{params[:parse_linedata][rec["pobject_code_sfd"]]}'       and"
					else
						delm = (params[:fetchview].split(":")[1]||="")  ###/_sno_|_cno_|_gno_/の時はdelm意味なし
						if delm == ""
							strsql << "  #{rec["pobject_code_sfd"]} = '#{params[:parse_linedata][rec["pobject_code_sfd"]]}'        and"
						else
							strsql << "  #{rec["pobject_code_sfd"].split(delm)[0]} = '#{params[:parse_linedata][rec["pobject_code_sfd"]]}'       and"
						end
					end
				end
			end
			if @missing == false  ###検索のための入力項目はすべて入力されている。
				rec =  ActiveRecord::Base.connection.select_one(strsql[0..-8] + " limit 1")
			else
				rec = nil
			end
			if rec  ###viewレコードあり
				params[:parse_linedata].each do |key,val|  ###結果をセット
					items = key.split("_")   ###画面の項目を分解　tableName.chop_fieldName(_delm)
					if items[-1] == delm[1..-1]   ### (params[:fetchview].split(":")[1]||="") 
						field = items[0..-2].join("_")   ##delm(:)が在った時
					else	
						field = key
					end	
					if rec[field] and key !="id" and key !~ /person.*upd/   ###id,sno,cnoから求められた同一項目を画面にセットする。
						fetch_data[field+delm] =  rec[field] ###rec:検索結果
						###自動セット項目 onblurfunc.js 参照(tableをgetしないとき利用)
						case screentblnamechop 
						when /^custsch|^custord/ 
 							case  field 
							when "loca_code_cust"  
								if fetch_data["crr_code"] == "" and fetchview =~ /custs$/ 
									fetch_data["crr_code"] = rec["crr_code_bill"]
								end
							when "itm_code"  
							   if fetch_data["shelfno_code_fm"] == "" and fetchview =~ /itms$/ 
								   fetch_data["shelfno_code_fm"] = rec["shelfno_code_to_opeitm"]  ###opeitm.shelfno_code_to_opeitm 完成後の置き場所゜
								   ###custord.shelfno_code_fm 客先への出荷のための梱包場所
							   end
							end
						end
					else ### sno,cnoからデータを求めた時は同一項目でなくてもdelmが同じであればセットする。
						if srctblnamechop =~ /^pur|^prd|^cust/ and rec[field] and key !~ /person.*upd/  and field !=  "id"
							fetch_data[field+delm] =  rec[field] ###rec:検索結果
						end
						if srctblnamechop =~ /^pur|^prd|^cust/ and rec[field.gsub(screentblnamechop,srctblnamechop)] and 
								key !~ /person.*upd/ and field =~ /_id/   and field != "#{screentblnamechop}_id"  and field != "id"
							fetch_data[field+delm] =  rec[field.gsub(screentblnamechop,srctblnamechop)] ###rec:検索結果
						end
						###  ###既に状態が変化しているかチェック
						if  field =~ /_sno_|_cno_/ and field =~ /^#{screentblnamechop}/ and val != ""  and field !~ /_gridmessage/ and 
							srctblnamechop =~ /^pur|^prd|^cust/
								strsql = %Q% select sum(link.qty_src) qty_src 
												from linktbls link
												inner join   #{srctblnamechop}s srctbl on srctbl.id = link.srctblid
												where srctbl.#{key.split("_")[1]} = '#{val}' ---key.split("_")[1] :sno　ok,  cno:未対応
												and link.srctblname = '#{srctblnamechop}s'
												group by srctbl.id
								%  ###次のステータスに移行していないqtyを求める。　
								org =  ActiveRecord::Base.connection.select_one(strsql)
								if org["qty_src"]   ###既に状態が変化しているかチェック
									case srctblnamechop
									when /act$/
										case screentblnamechop
										when  /act$/
											if params[:parse_linedata]["#{screentblnamechop}_qty_stk"]
												fetch_data["#{screentblnamechop}_qty_stk"] =  rec["#{srctblnamechop}_qty_stk"].to_f - org["qty_src"].to_f
												if fetch_data["#{screentblnamechop}_qty_stk"] <= 0
													params[:err] =  "error   --->over qty line:#{params[:index]} "
													fetch_data[field+delm+"_gridmessage"] =  "error   --->over qty"
												end
											end
										else
											if params[:parse_linedata]["#{screentblnamechop}_qty"]
												fetch_data["#{screentblnamechop}_qty"] =  rec["#{srctblnamechop}_qty_stk"].to_f - org["qty_src"].to_f
												if fetch_data["#{screentblnamechop}_qty"] <= 0
													params[:err] =  "error   --->over qty line:#{params[:index]} "
													fetch_data[field+delm+"_gridmessage"] =  "error   --->over qty"
												end
											end
										end
									when /sch$/
										if screentblnamechop =~ /schs$/
											if params[:parse_linedata]["#{screentblnamechop}_qty_sch"]
												fetch_data["#{screentblnamechop}_qty_sch"] = rec["#{srctblnamechop}_qt_sch"].to_f  - org["qty_src"].to_f
												if fetch_data["#{screentblnamechop}_qty_sch"] <= 0
													params[:err] =  "error   --->over qty  line:#{params[:index]} "
													fetch_data[field+delm+"_gridmessage"] =  "error   --->over qty"
												end
											end
										else	
											if params[:parse_linedata]["#{screentblnamechop}_qty"]
												fetch_data["#{screentblnamechop}_qty"] = rec["#{srctblnamechop}_qty_sch"].to_f  - org["qty_src"].to_f
												if fetch_data["#{screentblnamechop}_qty"] <= 0
													params[:err] =  "error   --->over qty  line:#{params[:index]} "
													fetch_data[field+delm+"_gridmessage"] =  "error   --->over qty"
												end
											end
										end
									else
										if screentblnamechop =~ /act$/
											if params[:parse_linedata]["#{screentblnamechop}_qty_stk"]
												fetch_data["#{screentblnamechop}_qty_stk"] = rec["#{srctblnamechop}_qty"].to_f  - org["qty_src"].to_f
												if fetch_data["#{screentblnamechop}_qty_stk"] <= 0
													params[:err] =  "error   --->over qty  line:#{params[:index]} "
													fetch_data[field+delm+"_gridmessage"] =  "error   --->over qty"
												end
											end
										else	
											if params[:parse_linedata]["#{screentblnamechop}_qty"]
												fetch_data["#{screentblnamechop}_qty"] = rec["#{srctblnamechop}_qty"].to_f  - org["qty_src"].to_f
												if fetch_data["#{screentblnamechop}_qty"] <= 0
													params[:err] =  "error   --->over qty line:#{params[:index]} "
													fetch_data[field+delm+"_gridmessage"] =  "error   --->over qty"
												end
											end
										end
									end
								else
									case srctblnamechop 
									when	/act$/
										case screentblnamechop 
										when	/act$/
											if params[:parse_linedata]["#{screentblnamechop}_qty_stk"]		
												fetch_data["#{screentblnamechop}_qty_stk"] =  rec["#{srctblnamechop}_qty_stk"].to_f 
											end
										else
											if params[:parse_linedata]["#{screentblnamechop}_qty"]		
												fetch_data["#{screentblnamechop}_qty"] =  rec["#{srctblnamechop}_qty_stk"].to_f 
											end
										end	
									when /sch/	
										case screentblnamechop 
										when	/sch$/
											if params[:parse_linedata]["#{screentblnamechop}_qty_sch"]		
												fetch_data["#{screentblnamechop}_qty_sch"] =  rec["#{srctblnamechop}_qty_sch"].to_f 
											end
										else
											if params[:parse_linedata]["#{screentblnamechop}_qty"]		
												fetch_data["#{screentblnamechop}_qty"] =  rec["#{srctblnamechop}_qty_sch"].to_f 
											end
										end	
									else	
										if screentblnamechop =~ /act$/
											if params[:parse_linedata]["#{screentblnamechop}_qty_stk"]		
												fetch_data["#{screentblnamechop}_qty_stk"] =  rec["#{srctblnamechop}_qty"].to_f 
											end
										else
											if params[:parse_linedata]["#{screentblnamechop}_qty"]		
												fetch_data["#{screentblnamechop}_qty"] =  rec["#{srctblnamechop}_qty"].to_f 
											end
										end	
									end
								end
						else
						end
					end
				end	
				if screentblnamechop != viewtblnamechop ### omit self table
					field = screentblnamechop+"_"+viewtblnamechop+"_id"+delm
					fetch_data[field] =  rec["id"]
				end
				@findstatus = true
			else
				##再入力時のNgに対応	
				if screentblnamechop != viewtblnamechop ### omit self table
					field = screentblnamechop+"_"+viewtblnamechop+"_id"+delm
					fetch_data[field] =  ""
				end
				@findstatus = false
			end	
		return fetch_data,keys
	end		

	def proc_blkuky_check tbl,linedata   ###重複チェック
		save_blkuky_grp = nil
		keys = []
		err = {}
		strsql = %Q% select blkuky_grp,pobject_code_fld from r_blkukys where pobject_code_tbl = '#{tbl}' 
						and blkuky_expiredate > current_date order by blkuky_grp,blkuky_seqno%
						
		ActiveRecord::Base.connection.select_all(strsql).each do |rec|
			if save_blkuky_grp != rec["blkuky_grp"] 
				if  !save_blkuky_grp.nil? and keys.exclude?("id")
					err = blkuky_check_detail tbl,keys,linedata,err
					keys = []
				end
				save_blkuky_grp = rec["blkuky_grp"]
			end
			keys << rec["pobject_code_fld"]
		end
		if !keys.empty? and keys.exclude?("id")  ### id付きの検索keysはたんなるindexのためskip
			err = blkuky_check_detail tbl,keys,linedata,err
		end
		return err
	end	

	def blkuky_check_detail tbl,keys,linedata,err
		strwhere = " where "
		tblchop = tbl.chop
		keys.each do |key|
			symkey = tblchop + "_" + key.gsub("s_id","_id")
			if linedata[symkey].nil? or linedata[symkey]  == ""
				strwhere = "       #{symkey} must be select      "
				break
			else
				strwhere << "  #{key} = '#{linedata[symkey]}'     and "
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

	def proc_judge_check_code params,sfd,checkCode  ###item未使用
		params = __send__("check_#{checkCode}",params,sfd)  ###[1]: nil all,add,updateは画面側で判断
		return params 
	end	

	def check_paragraph params,item ### proc_judge_check_codeからcallされる。
		linedata = params[:parse_linedata]
		if linedata["screenfield_paragraph"] == ""
			if linedata["pobject_code_sfd"] =~ /_code/ and params[:screenCode].split("_")[1].chop == linedata["pobject_code_sfd"].split("_"[0])
				params[:err] =  "error   --->view or field  #{linedata["screenfield_paragraph"]}　not find line:#{params[:index]} "
			else	
				params[:err] =  nil
			end
		else	
			if linedata["screenfield_paragraph"]
				screen,delm = linedata["screenfield_paragraph"].split(":",2)
				if linedata["pobject_code_sfd"] =~ /_sno_|_cno_|_gno_/
					case linedata["pobject_code_sfd"] 
					when /_sno_/
						field = linedata["pobject_code_sfd"].split("_sno_")[1] + "_sno"
					when /_cno_/
						field = linedata["pobject_code_sfd"].split("_cno_")[1] + "_cno"
					when /_gno_/
						field = linedata["pobject_code_sfd"].split("_gno_")[1] + "_gno"
					else
					end
				else
					if delm
						field =  linedata["pobject_code_sfd"].gsub(delm,"")
					else	
						field =  linedata["pobject_code_sfd"]
					end
				end
				strsql = %Q%select 1 from r_screenfields where pobject_code_scr ='#{screen}' and pobject_code_sfd = '#{field}' %
				rec = ActiveRecord::Base.connection.select_one(strsql)
				if rec
					params[:err] = nil
				else
					params[:err] =  "error   --->view or field  #{linedata["screenfield_paragraph"]}　not find line:#{params[:index]} "
				end
			end
		end
		return params
	end	

	def check_strorder params,item
		linedata = params[:parse_linedata]
		if linedata["screen_strorder"] and linedata["screen_strorder"] != ""
			ary_select_fields = linedata.keys
			sort_info = {}
			sort_info[:default] = linedata["screen_strorder"]
			sort_info = proc_detail_check_strorder sort_info,ary_select_fields
			if sort_info[:err] 
				params[:err] =  sort_info[:err] + "line:#{params[:index]}" 
			else
				params[:err] =  nil
			end
		end
		return params
	end

	def  proc_detail_check_strorder sort_info,ary_select_fields
		##fields = sort_info[:default].split(/\s*,\s*/)
		sort_info[:default].split(/\s*,\s*/).each do |sort_field|
			ok = false
			sort_field.split(" ").each do |chk|
				if(ary_select_fields.include?(chk.gsub(" ","").downcase))
					ok = true
				else
					if ok==true and (chk.gsub(" ","").downcase=="asc" or chk.gsub(" ","").downcase=="desc")
					else
						sort_info[:default] = nil
						sort_info[:err] = "sort option error"
						break
					end		
				end		
			end	
		end	
		return sort_info
	end	

	def check_qty params,item
	 	linedata = params[:parse_linedata]
		tblname =  params[:screenCode].split("_")[1]
	 	if linedata[tblname.chop + "_qty"]
	 		symqty = tblname.chop + "_qty"
	 	else
	 		symqty = tblname.chop + "_qty_stk"
	 	end

	 	if linedata[symqty] == ""
	 		params[:err] =  "error   --->#{symqty} missing line:#{params[:index]} "
	 	else
	 		currtblnamechop = ""
	 		tblnamechop = "" 
	 		strsql = ""
	 		linedata.each do |key,val|
	 			case key.to_s
	 				when  /_sno_/ ### ordからいきなり　actでの入力を認めている。
	 					if (tblnamechop == "" or  tblnamechop =~ /ord$/ or key.to_s =~ /dlv$/) and val != ""
	 						currtblnamechop,tblnamechop = key.to_s.split("_sno_")
	 						strsql = %Q%select id from #{tblnamechop}s  where sno = '#{val}' %
	 						break
	 					end
	 				when  /_cno_/  
	 					if (tblnamechop == "" or  tblnamechop =~ /ord$/ or key.to_s =~ /dlv$/) and val != ""
	 						currtblnamechop,tblnamechop = key.to_s.split("_cno_")
	 						strsql = %Q%select id from #{tblnamechop}s  where cno = '#{val}' %
	 						break
	 					end
	 				when  /_gno_/  
	 					if (tblnamechop == "" or  tblnamechop =~ /ord$/ or key.to_s =~ /dlv$/) and val != ""
	 						currtblnamechop,tblnamechop = key.to_s.split("_gno_")
	 						strsql = %Q%select id from #{tblnamechop}s  where gno = '#{val}' %
	 						break
	 					end
	 			end
	 		end
	 		if 	strsql.size > 0
	 				tblids = ActiveRecord::Base.connection.select_values(strsql)	
					strsql = %Q%select sum(qty_pare) qty from trngantts where paretblname = '#{tblnamechop}s'
	 							and paretblid in(#{tblids.join(",")})
	 							and orgtblid = paretblid and paretblid = tblid
	 				%
	 				prev_qty = ActiveRecord::Base.connection.select_value(strsql)	
	 				if linedata[symqty].to_f  <= prev_qty.to_f   ### オーダ以上を許可するルール未設定
	 				else
	 					params[:err] =  "error ---> #{prev_qty} <　input qty:#{linedata[symqty]} line:#{params[:index]} "
	 				end
	 		end
	 		if linedata["id"] != "" and params[:err].nil? ###更新の時のみ　ords-->insts  insts -->actsに既にどれだけ変化しているか？
	 			strsql = %Q%select sum(qty) qty from trngantts where tblname = '#{currtblnamechop}s'
	 							and tblid = #{linedata["id"]} group by  tblname,tblid
	 			%
	 			chng_qty = ActiveRecord::Base.connection.select_value(strsql)	
	 			chng_qty ||= 0.0  ###すでに次の状態に変化した数値
	 			if chng_qty.to_f <= linedata[symqty].to_f
	 				params[:err] =  nil
	 			else
	 				params[:err] =  "error   ---> qty must be >= #{chng_qty} line:#{params[:index]}  "
	 			end	
	 		end
	 	end
	 	return params
	end	

	 def check_loca_code_to params,item
	 	linedata = params[:parse_linedata]
	 	tblname =  params[:screenCode].split("_")[1]
	 	id = linedata["#{tblname.chop}_id"]
	 	if id != ""  ###更新の時のみ　ords-->insts  insts -->actsに既にどれだけ変化しているか？
	 		sym = "loca_code_to"
	 		if linedata[sym] == ""
	 			params[:err] =  "error   --->#{sym} missing line:#{params[:index]} "
	 		else
	 			strsql = %Q%select sum(qty) from trngantts where orgtblname ='#{tblname}' and orgtblid = #{id} 
	 					 and  tblid = #{id} and tblname = '#{tblname}' group by orgtblname,orgtblid,tblname,tblid %
	 			trn_qty = ActiveRecord::Base.connection.select_value(strsql)
	 			chng_qty ||= 0.0  ###すでに次の状態に変化した数値
	 			strsql = %Q%select loca_code_to,#{tblname.chop}_qty from r_#{tblname} where id = #{id} %
	 			rec = ActiveRecord::Base.connection.select_one(strsql)
	 			if (chng_qty != rec["#{tblname.chop}_qty"] or rec["#{tblname.chop}_qty"]  != trn_qty) and 
	 					linedata[sym] != rec["loca_code_to"]
	 				checkstatus = false
	 				params[:err] =  "error   ---> loca_code_to must be >= #{rec["loca_code_to"]} line:#{params[:index]} "
				 else
					params[:err] =  nil
	 			end 
	 		end
	 	end
	 	return params
	 end	

	def check_already_used params,item  ###あるidで登録されたcodeが別のテーブルに既に登録されているとき、codeの変更は不可
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
		linedata = params[:parse_linedata]
		if linedata["id"] and linedata["id"] != ""  ###変更の時 
			case params[:screenCode]
			when /itms/
			when /locas/
			when /pobjects/
				strsql = %Q%select code from pobjects where id = #{linedata["id"]}						
				%
				pobject_code = ActiveRecord::Base.connection.select_value(strsql)
				if pobject_code
					if pobject_code != linedata["pobject_code"]
						strsql = %Q%select id from tblfields tfd
										inner join flieldcodes fld on tfd.fieldcodes_id fld.id
										where pobjects_id_fld = #{linedata["id"]}  
								%
						value = ActiveRecord::Base.connection.select_value(strsql)
						if value
							params[:err] =  "error   ---> #{field} can not change because table:tblfields already used line:#{params[:index]} "
							if params[:parse_linedata][:errPath].nil? 
								params[:parse_linedata][:errPath] = [key.split(":")[0]+"_gridmessage"]
							end
						else
							params[:err] = nil
						end
					end
				end
			end
		end		
		return params	
	end



	def proc_snolist   ###reqparams["segment"] = ["trn_org"]の対象でもある。
		{"purschs"=>"PS","purords"=>"PE","purinsts"=>"PH","purdlvs"=>"PV","puracts"=>"PA","purrets"=>"PR",
			"purreplyinputs"=>"PL","prdreplyinputs"=>"ML",
			"prdschs"=>"MS","prdords"=>"ME","prdinsts"=>"MH","prdacts"=>"MA","prdrets"=>"MR",
			"billschs"=>"BS","billords"=>"BE","billinsts"=>"BH","billacts"=>"BA","billrets"=>"BR",
			"payschs"=>"YS","payords"=>"YE","payinsts"=>"YH","payacts"=>"YA","payrets"=>"YR",
			"custschs"=>"CS","custords"=>"CQ","custinsts"=>"CJ","custacts"=>"CA","custrets"=>"CR",
			"shpschs"=>"SS","shpords"=>"SE","shpinsts"=>"SH","shpacts"=>"SA","shprets"=>"SR"}
	end

	### prd,pur ・・・schs,ords,insts,acts,retsのレコード作成　	
	def proc_fields_update nd,parent,screenCode ,command_c  ###xxxschsの作成のみ
		@command_x = command_c.dup
		yield @command_x   ###@tbldata 子供自身の員数等
		@tbldata["opeitms_id"] = nd["opeitms_id"]
		@tbldata["duration"] =  nd["duration"].to_f
		@tbldata["packqty"] =  if nd["packqty"].to_f == 0
									1
								else
									nd["packqty"].to_f
								end
		@tbldata["shelfnos_id_to"] = nd["shelfnos_id_to_opeitm"]
		@tbldata["shelfnos_id_fm"] = nd["shelfnos_id_fm_opeitm"]
		@tbldata["locas_id"] = nd["locas_id_opeitm"]  ###発注の時の作業場所
		@tbldata["parenum"] = nd["parenum"].to_f
		@tbldata["chilnum"] = nd["chilnum"].to_f
		@tbldata["locas_id_fm"] = nd["locas_id_fm"]
		@tbldata["consumunitqty"] = nd["consumunitqty"].to_f
		@tbldata["consumminqty"] = nd["consumminqty"].to_f
		@tbldata["consumchgoverqty"] = nd["consumchgoverqty"].to_f
		###@tbldata["parent_processseq"] = val
		@tbldata["parent_starttime"] = parent["starttime"]
		@tbldata["parent_duedate"] = parent["duedate"]
		@tbldata["parent_toduedate"] = parent["toduedate"]
		@tbldata["parent_duration"] = parent["duration"]
		@tbldata["chrgs_id"] = parent["chrgs_id"]
		@tbldata["parent_qty"] = parent["qty"].to_f
		@tbldata["parent_qty_sch"] = parent["qty_sch"].to_f
		@tbldata["parent_qty_handover"] = parent["qty_handover"].to_f
		@tbldata["parent_qty_stk"] = parent["qty_stk"].to_f
		@tbldata["parent_qty_bal"] = parent["qty_bal"].to_f
		@tbldata["parent_prjno_id"] = parent["prjnos_id"]

		@tblnamechop = @command_x[:sio_viewname].split("_")[1].chop
		@command_x[:sio_code] =  @command_x[:sio_viewname] 

		strsql =  %Q%select pobject_code_fld from r_tblfields where tblfield_expiredate > current_date and 
						id in (select id from r_tblfields 
									where pobject_code_tbl = '#{@command_x[:sio_code].split("_")[1]}')
						order by tblfield_seqno
		%
		fields = ActiveRecord::Base.connection.select_all(strsql)
		fields.each do |fd|  ###tblfield_seqnoの順に処理される。
			###lotnoはpur,prd項目ではないのでここにはない。
			case fd["pobject_code_fld"]
				when "autocreate"
						field_autocreate 
				when "chrgs_id"
						field_chrgs_id 
				when "cno"  ###画面の時用にror_blkctl.crete_src_tblでもsetしてる
				when "confirm"
						field_confirm
				when "consumauto"  ###
						field_consumauto
				when "duedate"  ###稼働日計算
						field_duedate
				when "toduedate"  ###稼働日計算
						field_toduedate
				when "expiredate"
						field_expiredate
				when "gno" ###画面の時用にror_blkctl.create_src_tblでもsetしてる
				when "id"  ###追加または更新の判断
						field_tblid
				when "isudate"
						if @command_x[:sio_classname] =~ /_add_/
							field_isudate 
						end
				when "locas_id_to"
						field_locas_id_to
				when "opeitms_id"
						field_opeitms_id
				when "price"  ###保留
						field_price_amt_tax_contract_price 
				when "processseq_pare"
						field_processseq_pare
				when "prjnos_id"
						field_prjnos_id
				when "qty_sch"
						field_qty_sch   ### @qty_require
				###when "qty"   ###xxxschsではqtyは存在しない
				###		field_qty 
				when "qty_case"
						field_qty_case 
				when "starttime"  ###稼働日計算
						field_starttime
				when "shelfnos_id_to"
						field_shelfnos_id_to
				when "sno"  ###tblfield_seqnoはidの後であること。###画面の時用にror_blkctl.create_src_tblでもsetしてる
						@command_x["#{@tblnamechop}_sno"]  = proc_field_sno(@tblnamechop,@command_x["id"])
				when "suppliers_id"
						field_suppliers_id
				when "workplaces_id"
						field_workplaces_id
				when "payments_id"  ### seqnoはsuppliers_idより大きいこと
						field_payments_id
				###when "crrs_id"   ### seqはpayments_idより大きいこと
				###		field_crrs_id
			end	
		end		
		return @command_x,@qty_require
	end	 

	def	field_tblid
		if @command_x["id"] == "" or  @command_x["id"].nil?
			@command_x[:sio_classname] = "_add_grid_linedata"
			@command_x["id"] =  ArelCtl.proc_get_nextval("#{@tblnamechop}s_seq")
	 	else         
			@command_x[:sio_classname] = "_edit_update_grid_linedata"
	 	end   
		@command_x["#{@tblnamechop}_id"] = @command_x["id"]
	end	

	def field_confirm
		@command_x["#{@tblnamechop}_confirm"] = false if @command_x["#{@tblnamechop}_confirm"].nil? or  @command_x["#{@tblnamechop}_confirm"] == ""
	end	

	def field_opeitms_id
		key = @tblnamechop + "_opeitm_id" 
		@command_x[key] = @tbldata["opeitms_id"]  ###  変更はないはず
	end

	def field_locas_id_to 
		@command_x["#{@tblnamechop}_loca_id_to"] = @tbldata["locas_id_fm"] ##
	end 

	def field_suppliers_id
		strsql = %Q%select  * from suppliers where locas_id_supplier = #{@tbldata["locas_id"]}%
		rec = ActiveRecord::Base.connection.select_one(strsql)
			###supplier_code = dummy は必須 id = 0
		if rec
			@command_x["#{@tblnamechop}_supplier_id"] = rec["id"] ##
		else
			@command_x["#{@tblnamechop}_supplier_id"] = 0
		end
	end 

	def field_workplaces_id 
		strsql = %Q%select  id from workplaces where locas_id_workplace = #{@tbldata["locas_id"]}
		%
		id = ActiveRecord::Base.connection.select_value(strsql)
		###worlplace_code = dummy は必須 id = 0
		id ||= 0
		@command_x["#{@tblnamechop}_workplace_id"] = id ##
	end 

	def field_payments_id 
		strsql = %Q%select  * from payments where locas_id_payment = #{@tbldata["locas_id"]}%
		rec = ActiveRecord::Base.connection.select_one(strsql)
		###supplier_code = dummy は必須 id = 0
		if rec
			@command_x["#{@tblnamechop}_payment_id"] = rec["id"] ##
			@command_x["#{@tblnamechop}_crr_id"] = rec["crrs_id_payment"] ##
		else
			@command_x["#{@tblnamechop}_payment_id"] = 0
			@command_x["#{@tblnamechop}_crr_id"] = 0
		end
	end 

	###def field_crrs_id ###seq_noは suppliersのあと
	###end 

	def field_shelfnos_id_to 
		@command_x["#{@tblnamechop}_shelfno_id_to"] = @tbldata["shelfnos_id_to"] ##
	end 

	def field_processseq_pare 
		@command_x["#{@tblnamechop}_processseq_pare"] = @tbldata["parent_processseq"] 
	end	

	def field_isudate
		@command_x["#{@tblnamechop}_isudate"] = Time.now.to_s if @command_x["#{@tblnamechop}_isudate"].nil? or @command_x["#{@tblnamechop}_isudate"] == ""
	end	 

	def field_duedate 
		duedate = @tbldata["parent_starttime"].to_date - 1
		@command_x["#{@tblnamechop}_duedate"] = @command_x["#{@tblnamechop}_duedate"] = duedate.strftime("%Y-%m-%d %H:%M:%S")
	end

	
	def field_toduedate 
		toduedate = @tbldata["parent_toduedate"].to_date - @tbldata["parent_duration"].to_i  - 1
		@command_x["#{@tblnamechop}_toduedate"] = @command_x["#{@tblnamechop}_toduedate"] = toduedate.strftime("%Y-%m-%d %H:%M:%S")
	end


	def field_starttime
		starttime =  @command_x["#{@tblnamechop}_duedate"].to_date - @tbldata["duration"]
		@command_x["#{@tblnamechop}_starttime"] = starttime.strftime("%Y-%m-%d %H:%M:%S")
	end

	def field_chrgs_id ### seq_noは　chrgs_id > custs_id,suppliers_id,workplaces_idであること
		if @command_x["#{@tblnamechop}_chrg_id"].nil? or  @command_x["#{@tblnamechop}_chrg_id"] == ""
			if @tbldata["chrgs_id"]
				@command_x["#{@tblnamechop}_chrg_id"] = @tbldata["chrgs_id"]
			else
				case @tblnamechop
				when /^cust/
					strsql = %Q&
							select chrgs_id_cust chrgs_id from custs where id = #{@command_x["#{@tblnamechop}_cust_id"] }
					&
				when /^pud/
					strsql = %Q&
							select chrgs_id_supplier chrgs_id from suppliers where id = #{@command_x["#{@tblnamechop}_supplier_id"] }
					&
				when /^prd/
					strsql = %Q&
							select chrgs_id_workplace chrgs_id from workplaces where id = #{@command_x["#{@tblnamechop}_workplace_id"] }
					&
				else
					p "get chrgs_id error LINE:#{__LINE__} "
					raise
				end
				@command_x["#{@tblnamechop}_chrg_id"] = ActiveRecord::Base.connection.select_value(strsql)
			end
		end
	end	

	def field_qty_sch 
		@qty_require = @tbldata["parent_qty_handover"] * @tbldata["chilnum"] / @tbldata["parenum"]
		#consumunitqty等については親に合わせて計算する。
		if @tbldata["consumunitqty"] > 0
			@qty_require = (@qty_require /  @tbldata["consumunitqty"]).ceil *  @tbldata["consumunitqty"]
		# #	@command_x["#{tblnamechop}_qty"] = @tbldata["consumunitqty"] * rlst   ###消費単位
		end	
		if @tbldata["consumminqty"] > @qty_require
			@qty_require = @tbldata["consumminqty"]  ###最小消費数
		end	
		@qty_require += @tbldata["consumchgoverqty"]
		###@qty_require = (@qty_require / @tbldata["packqty"]).ceil * @tbldata["packqty"]  
		@command_x["#{@tblnamechop}_qty_sch"]  = @tbldata["parent_qty_sch"] * @tbldata["chilnum"] / @tbldata["parenum"]
	end	

	def field_qty_case 
		if @tbldata["packqty"] > 0
			@command_x["#{@tblnamechop}_qty_case"] = (@qty /  @tbldata["packqty"]).ceil 
		else
			@command_x["#{@tblnamechop}_qty_case"] = 0
		end	
	end	

	def field_price_amt_tax_contract_price 
		@command_x["#{@tblnamechop}_price"] = 0 if @command_x["#{@tblnamechop}_price"].nil?
		@command_x["#{@tblnamechop}_amt_sch"] = 0 if @command_x["#{@tblnamechop}_amt_sch"].nil?
		@command_x["#{@tblnamechop}_tax"] = 0 if @command_x["#{@tblnamechop}_tax"].nil?
	end

	def proc_field_sno(tblnamechop,id)
		proc_snolist["#{tblnamechop}s"] + format('%05d', id) 
	end

	def proc_field_cno id 
		 format('%07d', id)
	end

	def proc_field_gno id
		 format('%07d', id) 
	end	

	def field_prjnos_id 
		@command_x["#{@tblnamechop}_prjno_id"] = @tbldata["parent_prjno_id"] 
	end	

	def field_consumauto
		@command_x["#{@tblnamechop}_consumauto"] = @tbldata["consumauto"] if @command_x["#{@tblnamechop}_consumauto"].nil? or  @command_x["#{@tblnamechop}_consumauto"] == ""
	end

	def field_autocreate 
		@command_x["#{@tblnamechop}_autocreate"] = @tbldata["autocreate"] if @command_x["#{@tblnamechop}_autocreate"].nil? or  @command_x["#{@tblnamechop}"] == ""
	end		
	
	def field_expiredate
		@command_x["#{@tblnamechop}_expiredate"] = "2099/12/31" if @command_x["#{@tblnamechop}_expiredate"].nil? or @command_x["#{@tblnamechop}_expiredate"] == ""
	end	
end  ###class
end   ##module