# -*- coding: utf-8 -*-
module CtlFields
	extend self		
	def  proc_chk_fetch_rec params  
		params[:err] = nil
		fetch_data,keys,findstatus,mainviewflg,missing = get_fetch_rec(params)
		params[:parse_linedata] = fetch_data.dup
	  	if findstatus
			if mainviewflg   ##mainviewflg = true 自分自身の登録
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
			if mainviewflg   ###自身の登録の時 
				###
				### r_tblfieldsの登録でr_blktbsがdetectできなかった時エラーにならない。!!!!!!!!!
				###
			else
				if missing  ###検索に必要な項目まだ未入力
				else
					params[:err] =  "error 3  --->not find code:#{keys},line:#{params[:index]}  "
					keys.split(",").each do |key| ###コードが変更されたとき既に使用されている？
						params[:parse_linedata][key.split(":")[0]+"_gridmessage"] = "error 3 not find code #{key} "
						if params[:parse_linedata][:errPath].nil? 
							params[:parse_linedata][:errPath] = [key.split(":")[0]+"_gridmessage"]
						end
					end  
				end	  
			end  
	  	end 
	  	params[:linedata] = JSON.generate(params[:parse_linedata])
	  	return params 
	end  

	def get_fetch_rec(params)
			strsql = ""
			keys = ""
			xno = ""
			srctblnamechop = ""
			screentblnamechop = params[:screenCode].split("_")[1].chop
			fetchview = params[:fetchview].split(":")[0]  ## YupSchemaでparagrapfをもとに作成済　split(":")拡張子の確認
			viewtblnamechop = fetchview.split("_")[1].chop
			line_data = params[:parse_linedata].dup
			mainviewflg = true  ##自分自身の登録か？
			missing = true
			findstatus = false
			if params[:screenCode].split("_")[1] != fetchview.split("_")[1] 
					mainviewflg = false
			else
				if fetchview.split(":")[1]   ###自身のテーブルを参照しいるとき
					mainviewflg = false
				end	
			end	  
			fetcfieldgetsql = "select pobject_code_sfd from r_screenfields
								 where pobject_code_scr =  '#{params[:screenCode]}' 
								 and screenfield_paragraph = '#{params[:fetchview]}'"
			delm = ""
			missing = false   ###missing:true パラメータが未だ未設定　　false:チェックok
			strsql = " select * from #{fetchview}  where "
			ActiveRecord::Base.connection.select_all(fetcfieldgetsql).each do |fetch|
				valOfField = params[:parse_linedata][fetch["pobject_code_sfd"].to_sym]
				fetchtblnamechop,xno,srctblnamechop = fetch["pobject_code_sfd"].split("_") 
				if valOfField =~ /,/				 ###入力項目に「,」が入っていた時
					params[:err] =  "error   --->not input comma:#{params[:index]} "
					line_data[(fetch["pobject_code_sfd"]+"_gridmessage").to_sym] =  "error   --->not input comma"  ###!!!
					missing = true
					findstatus = false
					break
				else
					if valOfField == "" or valOfField.nil?   ###未入力
						if fetch["pobject_code_sfd"] 	=~ /_sno_.*inst$|_cno_.*inst$/
							if params[:parse_linedata][fetch["pobject_code_sfd"].sub(/inst$/,"ord")]
								missing = false
								mainviewflg = true
							else
								if params[:parse_linedata][fetch["pobject_code_sfd"].sub(/inst$/,"replyinput")]
									missing = false
									mainviewflg = true
								else
									missing = true
								end	
							end
						else
							if fetch["pobject_code_sfd"] 	=~ /_sno_.*replyinput$|_cno_.*replyinput$/
								if params[:parse_linedata][fetch["pobject_code_sfd"].sub(/replyinput$/,"ord")]
									missing = false
									mainviewflg = true
								else
									if params[:parse_linedata][fetch["pobject_code_sfd"].sub(/replyinput$/,"inst")]
										missing = false
										mainviewflg = true
									else
										missing = true
									end	
								end
							else
								if fetch["pobject_code_sfd"] 	=~ /_sno_.*ord$|_cno_.*ord$/
									if params[:parse_linedata][fetch["pobject_code_sfd"].sub(/ord$/,"inst")]
										missing = false
										mainviewflg = true
									else
										if params[:parse_linedata][fetch["pobject_code_sfd"].sub(/ord$/,"replyinput")]
											missing = false
											mainviewflg = true
										else
											missing = true
										end	
									end
								else
									missing = true
								end
							end
						end
						missing = true
						next
					else
							keys <<  "#{fetch["pobject_code_sfd"]}: '#{valOfField}',"
							if fetch["pobject_code_sfd"] 	=~ /_sno_|_cno_/
								 ### 
								strsql << " #{srctblnamechop}_#{xno} = '#{params[:parse_linedata][fetch["pobject_code_sfd"]]}'       and"
							else
								delm = (params[:fetchview].split(":")[1]||="")  ###/_sno_|_cno_|_gno_/の時はdelm意味なし
								if delm == ""
									strsql << "  #{fetch["pobject_code_sfd"]} = '#{params[:parse_linedata][fetch["pobject_code_sfd"]]}'        and"
								else
									strsql << "  #{fetch["pobject_code_sfd"].split(delm)[0]} = '#{params[:parse_linedata][fetch["pobject_code_sfd"]]}'       and"
								end
							end
					end
				end
			end
			if missing == false  ###検索のための入力項目はすべて入力されている。
				strsql = strsql[0..-8] 
				rec =  ActiveRecord::Base.connection.select_one(strsql)
			else
				rec = nil
				findstatus = false
			end
			if rec  ###viewレコードあり
					params[:parse_linedata].each do |key,val|  ###結果をセット
						next if key.to_s == "id" 
						next if key.to_s =~ /person.*upd/  
						###画面の項目を分解　tableName.chop_fieldName(_delm),viewtblnamechop.fieldName(_delm),tableName.chop_viewtblnamechop_id(_dlem)
						items = key.to_s.split("_")
						if delm != ""
							next if key.to_s !~ /#{delm}$/
							field = key.to_s.sub(delm,"")
						else
							field = key.to_s
						end
						if rec[field]  ###id,sno,cnoから求められた同一項目を画面にセットする。
							line_data[(field+delm).to_sym] =  rec[field] ###rec:検索結果
							###自動セット項目 onblurfunc.js 参照(tableをgetしないとき利用)
							case screentblnamechop 
							when /^custsch|^custord/ 
 								case  field 
								when "loca_code_cust"  
									if line_data[:crr_code] == "" and fetchview =~ /custs$/ 
										line_data[:crr_code] = rec["crr_code_bill"]
									end
								when "itm_code"  
							   		if line_data[:shelfno_code_fm] == "" and fetchview =~ /itms$/ 
								   		line_data[:shelfno_code_fm] = rec["shelfno_code_to_opeitm"]  ###opeitm.shelfno_code_to_opeitm 完成後の置き場所゜
								   	###custord.shelfno_code_fm 客先への出荷のための梱包場所
							   		end
								end
							end
						else ### sno,cnoからデータを求めた時は同一項目でなくてもdelmが同じであればセットする。
							### screentblnamechop,xno,srctblnamechop = rec["pobject_code_sfd"].split("_") 
							# if  field =~ /_sno_|_cno_|_go_/  and rec[field.gsub(screentblnamechop,srctblnamechop)]  and field =~ /_id/ 
							#  	fetch_data[field+delm] =  rec[field.gsub(screentblnamechop,srctblnamechop)] ###rec:検索結果
							# end
							if items[0] == screentblnamechop
								if items[2]  == "id"
									if items[1] == viewtblnamechop
										if rec["#{field.sub("#{screentblnamechop}_","")}"]
											line_data[key]  = rec["#{field.sub("#{screentblnamechop}_","")}"]
										end
									else
										if rec["#{field.sub("#{screentblnamechop}","#{viewtblnamechop}")}"]   ###purors_opeitm_id ==>puract_opeitm_id
											line_data[key]  =  rec["#{field.sub("#{screentblnamechop}","#{viewtblnamechop}")}"]
										end
									end
									### オーダ以上を許可するルール未設定
									###  ###既に状態が変化しているかチェック
								else	
									if  val != ""  and field !~ /_gridmessage/ and ((srctblnamechop =~ /^pur|^prd|^cust/ and srctblnamechop !~ /sch$|ord$/ and field =~ /_cno/) or
																					(srctblnamechop =~ /^pur|^prd|^cust/ and field =~ /_sno/))
										###shpはlinktblsテーブルに存在しない。
										###gnoはまとめなので数量チェックは別
										strsql = %Q% select sum(link.qty_src) qty_src 
												from linktbls link
												inner join   #{srctblnamechop}s srctbl on srctbl.id = link.srctblid
												where srctbl.#{key.split("_")[1]} = '#{val}' ---key.split("_")[1] :sno　ok,  cno:未対応
												and link.srctblname = '#{srctblnamechop}s'
												and (link.srctblname != link.tblname or link.srctblid != link.tblid)
												group by srctbl.id
											%  ###次のステータスに移行していないqtyを求める。　
										org =  ActiveRecord::Base.connection.select_one(strsql)
										org ||= {}
										if org["qty_src"]   ###既に状態が変化しているかチェック
											case srctblnamechop
											when /act$/
												case screentblnamechop
												when  /act$/
													if params[:parse_linedata]["#{screentblnamechop}_qty_stk"]
														line_data[("#{screentblnamechop}_qty_stk").to_sym] =  rec["#{srctblnamechop}_qty_stk"].to_f - org["qty_src"].to_f
														if line_data[("#{screentblnamechop}_qty_stk").to_sym] <= 0
															params[:err] =  "error   --->over qty line:#{params[:index]} "
															line_data[(field+delm+"_gridmessage").to_sym] =  "error   --->over qty"
														end
													end
												else
													if params[:parse_linedata]["#{screentblnamechop}_qty"]
														line_data[("#{screentblnamechop}_qty").to_sym] =  rec["#{srctblnamechop}_qty_stk"].to_f - org["qty_src"].to_f
														if line_data[("#{screentblnamechop}_qty").to_sym] <= 0
															params[:err] =  "error   --->over qty line:#{params[:index]} "
															line_data[(field+delm+"_gridmessage").to_sym] =  "error   --->over qty"
														end
													end
												end
											when /sch$/
												if screentblnamechop =~ /schs$/
													if params[:parse_linedata]["#{screentblnamechop}_qty_sch"]
														line_data[("#{screentblnamechop}_qty_sch").to_sym] = rec["#{srctblnamechop}_qt_sch"].to_f  - org["qty_src"].to_f
														if line_data[("#{screentblnamechop}_qty_sch").to_sym] <= 0
															params[:err] =  "error   --->over qty  line:#{params[:index]} "
															line_data[(field+delm+"_gridmessage").to_sym] =  "error   --->over qty"
														end
													end
												else	
													if params[:parse_linedata]["#{screentblnamechop}_qty"]
														line_data[("#{screentblnamechop}_qty").to_sym] = rec["#{srctblnamechop}_qty_sch"].to_f  - org["qty_src"].to_f
														if line_data[("#{screentblnamechop}_qty").to_sym] <= 0
															params[:err] =  "error   --->over qty  line:#{params[:index]} "
															line_data[(field+delm+"_gridmessage").to_sym] =  "error   --->over qty"
														end
													end
												end
											else
												if screentblnamechop =~ /act$/
													if params[:parse_linedata]["#{screentblnamechop}_qty_stk"]
														line_data[("#{screentblnamechop}_qty_stk").to_sym] = rec["#{srctblnamechop}_qty"].to_f  - org["qty_src"].to_f
														if line_data[("#{screentblnamechop}_qty_stk").to_sym] <= 0
															params[:err] =  "error   --->over qty  line:#{params[:index]} "
															line_data[(field+delm+"_gridmessage").to_sym] =  "error   --->over qty"
														end
													end
												else	
													if params[:parse_linedata]["#{screentblnamechop}_qty"]
														line_data[("#{screentblnamechop}_qty").to_sym] = rec["#{srctblnamechop}_qty"].to_f  - org["qty_src"].to_f
														if line_data[("#{screentblnamechop}_qty").to_sym] <= 0
															params[:err] =  "error   --->over qty line:#{params[:index]} "
															line_data[(field+delm+"_gridmessage").to_sym] =  "error   --->over qty"
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
														line_data[("#{screentblnamechop}_qty_stk").to_sym] =  rec["#{srctblnamechop}_qty_stk"].to_f 
													end
												else
													if params[:parse_linedata]["#{screentblnamechop}_qty"]		
														line_data[("#{screentblnamechop}_qty").to_sym] =  rec["#{srctblnamechop}_qty_stk"].to_f 
													end
												end	
											when /sch/	
												case screentblnamechop 
												when	/sch$/
													if params[:parse_linedata]["#{screentblnamechop}_qty_sch"]		
														line_data[("#{screentblnamechop}_qty_sch").to_sym] =  rec["#{srctblnamechop}_qty_sch"].to_f 
													end
												else
													if params[:parse_linedata]["#{screentblnamechop}_qty"]		
														line_data[("#{screentblnamechop}_qty").to_sym] =  rec["#{srctblnamechop}_qty_sch"].to_f 
													end
												end	
											else	
												if screentblnamechop =~ /act$/
													if params[:parse_linedata]["#{screentblnamechop}_qty_stk"]		
														line_data[("#{screentblnamechop}_qty_stk").to_sym] =  rec["#{srctblnamechop}_qty"].to_f 
													end
												else
													if params[:parse_linedata]["#{screentblnamechop}_qty"]		
														line_data[("#{screentblnamechop}_qty").to_sym] =  rec["#{srctblnamechop}_qty"].to_f 
													end
												end	
											end
										end
									end
								end
							end
						end
					end	
					# if screentblnamechop != viewtblnamechop ### omit self table
					# 	field = screentblnamechop+"_"+viewtblnamechop+"_id"+delm
					# 	line_data[field] =  rec["id"]
					# end
					findstatus = true
			else
					##再入力時のNgに対応	
					if missing == false 
						if screentblnamechop != viewtblnamechop and xno !~ /sno|cno/ ### omit self table
							### sno,cnoの時は例えば r_puractsにpurord_idを含んでない。(sno_purord,sno_ourdlv等どちらを使用するか不明。)
							field = (screentblnamechop+"_"+viewtblnamechop+"_id"+delm).to_sym
							line_data[field] =  ""
						end
					else
					end
			end
		return line_data,keys,findstatus,mainviewflg,missing
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
			symkey = (tblchop + "_" + key.gsub("s_id","_id")).to_sym
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

	###未コーディング
	#  screenfields.selection  viewtblchop_tblname_id は必ず選択
	#  nditms 子どものopeitmsへの存在チェック
	### 
	def proc_judge_check_code params,sfd,checkCode  ###item未使用
		params = __send__("check_#{checkCode}",params,sfd)  ###[1]: nil all,add,updateは画面側で判断
		return params 
	end	

	def check_paragraph params,item ### proc_judge_check_codeからcallされる。
		linedata = params[:parse_linedata]
		if linedata[:screenfield_paragraph] == ""
			if linedata[:pobject_code_sfd] =~ /_code/ and params[:screenCode].split("_")[1].chop == linedata["pobject_code_sfd"].split("_"[0])
				params[:err] =  "error1   --->view or field  #{linedata["screenfield_paragraph"]}　not find line:#{params[:index]} "
			else	
				params[:err] =  nil
			end
		else	
			if linedata[:screenfield_paragraph]
				screen,delm = linedata[:screenfield_paragraph].split(":",2)
				if linedata[:pobject_code_sfd] =~ /_sno_|_cno_|_gno_/
					case linedata[:pobject_code_sfd] 
					when /_sno_/
						field = linedata[:pobject_code_sfd].split("_sno_")[1] + "_sno"
					when /_cno_/
						field = linedata[:pobject_code_sfd].split("_cno_")[1] + "_cno"
					when /_gno_/
						field = linedata[:pobject_code_sfd].split("_gno_")[1] + "_gno"
					else
					end
				else
					if delm
						field =  linedata[:pobject_code_sfd].gsub(delm,"")
					else	
						field =  linedata[:pobject_code_sfd]
					end
				end
				strsql = %Q%select 1 from r_screenfields where pobject_code_scr ='#{screen}' and pobject_code_sfd = '#{field}' %
				rec = ActiveRecord::Base.connection.select_one(strsql)
				if rec
					params[:err] = nil
				else
					params[:err] =  "error2   --->view or field  #{linedata[:screenfield_paragraph]}　not find line:#{params[:index]} "
				end
			else
			end
		end
		return params
	end	

	def check_strorder params,item
		linedata = params[:parse_linedata]
		if linedata[:screen_strorder] and linedata[:screen_strorder] != ""
			ary_select_fields = linedata.keys
			sort_info = {}
			sort_info[:default] = linedata[:screen_strorder]
			sort_info = proc_detail_check_strorder sort_info,ary_select_fields
			if sort_info[:err] 
				params[:err] =  sort_info[:err] + "line:#{params[:index]}" 
			else
				params[:err] =  nil
			end
		end
		return params
	end

	
	def check_workplaces params,item
		linedata = params[:parse_linedata]
		if linedata[item.to_sym] 
			strsql = %Q%
				select id from r_workplaces where loca_code_workplace = '#{linedata[item.to_sym]}'
											and workplace_expiredate > current_date
			%
			if  ActiveRecord::Base.connection.select_value(strsql)
			else
				params[:err] =  " #{linedata[item.to_sym]} not workplaces"
			end
		end
		return params
	end

	
	def check_suppliers params,item
		linedata = params[:parse_linedata]
		if linedata[item.to_sym] 
			strsql = %Q%
				select id from r_suppliers where loca_code_supplier = '#{linedata[item.to_sym]}'
											and supplier_expiredate > current_date
			%
			if  ActiveRecord::Base.connection.select_value(strsql)
			else
				params[:err] =  " #{linedata[item.to_sym]} not suppliers"
			end
		end
		return params
	end

	
	def check_workplaces_suppliers params,item
		linedata = params[:parse_linedata]
		case linedata[:opeitm_prdpur]
		when "pur"
			if linedata[item.to_sym] 
				strsql = %Q%
					select id from r_suppliers where loca_code_supplier = '#{linedata[item.to_sym]}'
											and supplier_expiredate > current_date
				%
				if  ActiveRecord::Base.connection.select_value(strsql)
				else
					params[:err] =  " #{linedata[item.to_sym]} not suppliers"
				end
			end
		when "prd"
			if linedata[item.to_sym] 
				strsql = %Q%
					select id from r_workplaces where loca_code_workplace = '#{linedata[item.to_sym]}'
												and workplace_expiredate > current_date
				%
				if  ActiveRecord::Base.connection.select_value(strsql)
				else
					params[:err] =  " #{linedata[item.to_sym]} not workplaces"
				end
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
		###　get_fetch_recで実施済
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
		if linedata[:id] and linedata[:id] != ""  ###変更の時 
			case params[:screenCode]
			when /itms/
			when /locas/
			when /pobjects/
				strsql = %Q%select code from pobjects where id = #{linedata[:id]}						
				%
				pobject_codes = ActiveRecord::Base.connection.select_values(strsql)
				pobject_codes.each do |pobject_code|
					if pobject_code != linedata[:pobject_code]
						strsql = %Q%select tfd.id from tblfields tfd
										inner join fieldcodes fld on tfd.fieldcodes_id  =  fld.id
										where pobjects_id_fld = #{linedata[:id]}  and tfd.expiredate > current_date
								%
						value = ActiveRecord::Base.connection.select_value(strsql)
						if value
							params[:err] =  "error   ---> #{pobject_code} can not change because table:tblfields already used line:#{params[:index]} "
							# if params[:parse_linedata][:errPath].nil? 
							# 	params[:parse_linedata][:errPath] = [key.split(":")[0]+"_gridmessage"]
							# end
						else
							params[:err] = nil
						end
					end
				end
			end
		end		
		if params[:screenCode] =~ /pobjects/   ###将来　履歴専用のtblを作成しこのチェックはなくす。
			if linedata[:objecttype] == "view"
				if linedata[:code] =~ /cust|prd|pur|shp/ and linedata[:code] =~ /schs|ords|oinsts|reply|dlvs|acts|rets/
					if linedata[:code].split("_")[0]  == "r"
					else
						params[:err] =  "error   ---> view:#{code}   must be r_xxxxxxx 参照 Operation.get_last_rec  "
					end
				end
			end
		end

		return params	
	end



	def proc_snolist   ###reqparams["segment"] = ["trn_org"]の対象でもある。
		{"purschs"=>"PS","purords"=>"PE","purinsts"=>"PH","purdlvs"=>"PV","puracts"=>"PA",
			"purreplyinputs"=>"PL","prdreplyinputs"=>"ML",
			"prdschs"=>"MS","prdords"=>"ME","prdinsts"=>"MH","prdacts"=>"MA","prdrets"=>"MR",
			"billschs"=>"BS","billords"=>"BE","billinsts"=>"BH","billacts"=>"BA","billrets"=>"BR",
			"payschs"=>"YS","payords"=>"YE","payinsts"=>"YH","payacts"=>"YA","payrets"=>"YR",
			"custschs"=>"CS","custords"=>"CQ","custinsts"=>"CJ","custacts"=>"CA","custrets"=>"CR",
			"shpschs"=>"SS","shpords"=>"SE","shpinsts"=>"SH","shpacts"=>"SA","shprets"=>"SR"}
	end

	### prd,pur ・・・schs,ords,insts,acts,retsのレコード作成　	
	def proc_schs_fields_making nd,parent,screenCode ,command_c  ###xxxschsの作成のみ
		command_x = command_c.dup
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
		fields.each do |fd|  ###tblfield_seqnoの順に処理される。tblfield_seqno順に処理するためcommand_cは利用できない。
			###lotnoはpur,prd項目ではないのでここにはない。
			next if !command_x[tblnamechop + "_" + fd["pobject_code_fld"]].nil? and command_x[tblnamechop + "_" + fd["pobject_code_fld"]] != ""
			case fd["pobject_code_fld"]
			when "id"  ###追加または更新の判断
				command_x = field_tblid(tblnamechop,command_x,nd,parent)
			# when "confirm"
			# 	command_x = field_confirm(tblnamechop,command_x,nd,parent)
			when "isudate"
				if command_x ["sio_classname"] =~ /_add_/
					command_x = field_isudate(tblnamechop,command_x,nd,parent) 
				end
			when "opeitms_id"
				command_x = field_opeitms_id(tblnamechop,command_x,nd,parent)
			when "shelfnos_id"  ###payments_idを含む
				command_x = field_shelfnos_id(tblnamechop,command_x,nd,parent)
			when "starttime"  ###稼働日計算
				command_x = field_starttime(tblnamechop,command_x,nd,parent)
			when "shelfnos_id_to"
				command_x = field_shelfnos_id_to(tblnamechop,command_x,nd,parent)
			when "chrgs_id"
				command_x = field_chrgs_id(tblnamechop,command_x,nd,parent) 
			when "duedate"  ###稼働日計算
				command_x = field_duedate(tblnamechop,command_x,nd,parent)
			when "toduedate"  ###稼働日計算
				command_x = field_toduedate(tblnamechop,command_x,nd,parent)
			when "qty_sch"   ### 
				command_x,qty_require = field_qty_sch(tblnamechop,command_x,nd,parent)
			when "price"  ###保留 amt tax  itm_code_client crrs_idを含む
				command_x = field_price_amt_tax_contract_price(tblnamechop,command_x,nd,parent) 
			# when "itm_code_client"  ###保留 amt tax  を含む
			# 	command_x = field_itm_code_client(tblnamechop,command_x,nd,parent) 
			when "gno" ###画面の時用にror_blkctl.create_src_tblでもsetしてる
			when "sno"  ###tblfield_seqnoはidの後であること。###画面の時用にror_blkctl.create_src_tblでもsetしてる
				command_x["#{tblnamechop}_sno"]  = proc_field_sno(tblnamechop,command_x["id"])
			when "cno"  ###画面の時用にror_blkctl.crete_src_tblでもsetしてる
			when "prjnos_id"
				command_x = field_prjnos_id(tblnamechop,command_x,nd,parent)
			when "expiredate"
				command_x = field_expiredate(tblnamechop,command_x,nd,parent)
				# when "autocreate"
				# 	command_x = field_autocreate(tblnamechop,command_x,nd,parent)
				# when "consumauto"  ###
				# 	command_x = field_consumauto(tblnamechop,command_x,nd,parent)
				# # when "locas_id_to"
				# # 	command_x = field_locas_id_to(tblnamechop,command_x,nd,parent)
				# when "processseq_pare"
				# 	command_x = field_processseq_pare(tblnamechop,command_x,nd,parent)
				# when "suppliers_id"
				#  	command_x = field_suppliers_id(tblnamechop,command_x,nd,parent)
				# when "workplaces_id"
				#  	command_x = field_workplaces_id(tblnamechop,command_x,nd,parent)
				# ###when "crrs_id"   ### seqはpayments_idより大きいこと
			end	
		end		
		return command_x,qty_require
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

	def field_opeitms_id tblnamechop,command_x,nd,parent
		key = tblnamechop + "_opeitm_id" 
		command_x[key] = nd["opeitms_id"]  ###  変更はないはず
		return command_x
	end

	def field_locas_id_to tblnamechop,command_x,nd,parent
		command_x["#{tblnamechop}_loca_id_to"] = nd["locas_id_to"] ##
		return command_x
	end 

	# def field_suppliers_id tblnamechop,command_x,nd,parent
	# 	strsql = %Q%select  * from suppliers where locas_id_supplier = #{nd["locas_id"]}%
	# 	rec = ActiveRecord::Base.connection.select_one(strsql)
	# 		###supplier_code = dummy は必須 id = 0
	# 	if rec
	# 		command_x["#{tblnamechop}_supplier_id"] = rec["id"] ##
	# 	else
	# 		command_x["#{tblnamechop}_supplier_id"] = 0
	# 	end
	# 	return command_x
	# end 

	# def field_workplaces_id tblnamechop,command_x,nd,parent
	# 	strsql = %Q%select  id from workplaces where locas_id_workplace = #{nd["locas_id_opeitm"]}
	# 	%
	# 	id = ActiveRecord::Base.connection.select_value(strsql)
	# 	###worlplace_code = dummy は必須 id = 0
	# 	id ||= 0
	# 	command_x["#{tblnamechop}_workplace_id"] = id ##
	# 	return command_x
	# end 



	###end 

	def field_shelfnos_id tblnamechop,command_x,nd,parent
		command_x["#{tblnamechop}_shelfno_id"] = nd["shelfnos_id_opeitm"] ##
		shelfno_loca_id_shelfno =  ActiveRecord::Base.connection.select_value(%Q%
			select locas_id_shelfno from shelfnos where id = #{nd["shelfnos_id_opeitm"]} 
			%)
		
		command_x["shelfno_loca_id_shelfno"] = shelfno_loca_id_shelfno ##
		case nd["prdpur"]
		when "pur"
			strsql = %Q%select  * from payments where locas_id_payment = #{command_x["shelfno_loca_id_shelfno"]}%
			rec = ActiveRecord::Base.connection.select_one(strsql)
			###supplier_code = dummy は必須 id = 0
			if rec
				command_x["#{tblnamechop}_payment_id"] = rec["id"] ##
				command_x["#{tblnamechop}_crr_id"] = rec["crrs_id_payment"] ##
			else
				command_x["#{tblnamechop}_payment_id"] = 0
				command_x["#{tblnamechop}_crr_id"] = 0
			end
		end
		return command_x
	end

	def field_shelfnos_id_to tblnamechop,command_x,nd,parent
		command_x["#{tblnamechop}_shelfno_id_to"] = nd["shelfnos_id_to_opeitm"] ##
		return command_x
	end 


	def field_processseq_pare tblnamechop,command_x,nd,parent
		command_x["#{tblnamechop}_processseq_pare"] = parent["processseq"] 
		return command_x
	end	

	def field_isudate tblnamechop,command_x,nd,parent
		command_x["#{tblnamechop}_isudate"] = Time.now.to_s if command_x["#{tblnamechop}_isudate"].nil? or command_x["#{tblnamechop}_isudate"] == ""
		return command_x
	end	 

	def field_duedate tblnamechop,command_x,nd,parent
		if nd["shelfnos_id_to_opeitm"] == parent["shelfnos_id_trn"]
			duedate = parent["starttime"].to_time - 24*3600  ###稼働日
		else
			duedate = parent["starttime"].to_time - 2*24*3600  ###稼働日 出庫作業考慮
		end
		command_x["#{tblnamechop}_duedate"] = command_x["#{tblnamechop}_duedate"] = duedate.strftime("%Y-%m-%d %H:%M:%S")
		return command_x
	end

	
	def field_toduedate tblnamechop,command_x,nd,parent  ###先行納品可能納期
		command_x["#{tblnamechop}_toduedate"] = command_x["#{tblnamechop}_toduedate"] = command_x["#{tblnamechop}_duedate"]
		return command_x
	end


	def field_starttime tblnamechop,command_x,nd,parent
		starttime =  command_x["#{tblnamechop}_duedate"].to_time - nd["duration"].to_f*24*3600
		command_x["#{tblnamechop}_starttime"] = starttime.strftime("%Y-%m-%d %H:%M:%S")
		return command_x
	end

	def field_chrgs_id tblnamechop,command_x,nd,parent ### seq_noは　chrgs_id > custs_id,suppliers_id,workplaces_idであること
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
									where locas_id_supplier = #{nd["locas_id_opeitm"]}
				 	&
				 when /^prd/
				 	strsql = %Q&
				 			select chrgs_id_workplace chrgs_id from workplaces 
							 		where locas_id_workplace = #{nd["locas_id_opeitm"]}
				 	&
				else
					Rails.logger.debug"get chrgs_id error LINE:#{__LINE__} "
					raise
				end
				command_x ["#{tblnamechop}_chrg_id"] = ActiveRecord::Base.connection.select_value(strsql)
			end
		end
		return command_x
	end	

	def field_qty_sch tblnamechop,command_x,nd,parent
		qty_require = proc_cal_qty_sch(parent["qty_handover"],
										nd["chilnum"],nd["parenum"],
										nd["consumunitqty"],nd["consumminqty"],nd["consumchgoverqty"])
		command_x["#{tblnamechop}_qty_sch"]  = parent["qty_sch"].to_f * nd["chilnum"].to_f / nd["parenum"].to_f
		# if nd["packqty"] > 0   ### qty_case xxxschsから削除
		# 	command_x["#{tblnamechop}_qty_case"] = (qty_require /  nd["packqty"]).ceil 
		# else
		# 	command_x["#{tblnamechop}_qty_case"] = 0
		# end	
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

	def field_price_amt_tax_contract_price tblnamechop,command_x ,nd,parent
		command_x = PriceLib.proc_price_amt(tblnamechop,command_x)
		return command_x
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
		command_x["#{tblnamechop}_expiredate"] = "2099/12/31" if command_x["#{tblnamechop}_expiredate"].nil? or command_x["#{tblnamechop}_expiredate"] == ""
		return command_x
	end	
end   ##module