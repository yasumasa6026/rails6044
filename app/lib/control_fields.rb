# -*- coding: utf-8 -*-
module ControlFields
### 個別項目　チェック
	extend self	
		
	def  proc_chk_fetch_rec params  
		params[:err] = nil
		fetch_data,keys,screendata = get_fetch_rec params
	  	if @findstatus
			if @mainviewflg   ##@mainviewflg = true 自分自身の登録
				if 	params[:parse_linedata]["aud"] == "add" or params["buttonflg"] =~ /add/
					params[:err] = "error duplicate code #{keys} "
					params[:keys] = []
					keys.split(",").each do |key| 
				  		params[:keys] =  [key.split(":")[0].gsub(" ","")] 
					end  
					params[:fetch_data] = {}
				else
					fetch_data.each do |key,val|
						params[:fetch_data] = {"id" => val}
					end
				end		
			else
				params[:fetch_data] = fetch_data
				keys.split(",").each do |key| ###コードが変更されたとき既に使用されている？
					if key =~/_code/
				  ###作成中
					end  
				end  
			end  
	  	else
			if @mainviewflg   ###自身の登録の時 
				params[:fetch_data] = {}
				###
				### r_tblfieldsの登録でr_blktbsがdetectできなかった時エラーにならない。!!!!!!!!!
				###
			else
				if @missing  ###検索に必要な項目まだ未入力
					params[:fetch_data] = fetch_data
				else
					params[:err] =  "error   --->not find #{keys} "
					params[:fetch_data] = {}
				end	  
			end  
	  	end 
	  	params["linedata"] = JSON.generate(fetch_data)
	  	return params 
	end  

	def get_fetch_rec params
			strsql = ""
			keys = ""
			fetch_data = {}
			viewtblnamechop = ""
			xno = ""
			srctblnamechop = ""
			screentblnamechop = params[:screenCode].split("_")[1].chop
			fetchview = params[:fetchview].split(":")[0]  ##拡張子の確認
			viewtblnamechop = fetchview.split("_")[1].chop
			screendata = params[:parse_linedata]
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
				xfield = screendata[rec["pobject_code_sfd"]].to_s.gsub(",","_") ###入力項目に「,」が入っていた時
				keys <<  "  #{rec["pobject_code_sfd"]} : '#{xfield}',"  ###入力項目に「,」が入っていた時
				if screendata[rec["pobject_code_sfd"]] == "" or screendata[rec["pobject_code_sfd"]].nil?   ###未入力
					@missing = true
				else
					if rec["pobject_code_sfd"] 	=~ /_sno_|_cno_/
						screentblnamechop,xno,srctblnamechop = rec["pobject_code_sfd"].split("_")  ### 
						strsql << " #{srctblnamechop}_#{xno} = '#{screendata[rec["pobject_code_sfd"]]}'       and"
					else
						delm = (params[:fetchview].split(":")[1]||="")  ###/_sno_|_cno_|_gno_/の時はdelm意味なし
						if delm == ""
							strsql << "  #{rec["pobject_code_sfd"]} = '#{screendata[rec["pobject_code_sfd"]]}'        and"
						else
							strsql << "  #{rec["pobject_code_sfd"].split(delm)[0]} = '#{screendata[rec["pobject_code_sfd"]]}'       and"
						end
					end
				end
				##fetch_data[rec["pobject_code_sfd"]+delm] = screendata[rec["pobject_code_sfd"]]	  ###rec 画面のフィード名レコード
			end
			if @missing == false  ###検索のための入力項目はすべて入力されている。
				rec =  ActiveRecord::Base.connection.select_one(strsql[0..-8] + " limit 1")
			else
				rec = nil
			end
			if rec  ###viewレコードあり
				screendata.each do |key,val|  ###結果をセット
					items = key.split("_")
					if items[-1] == delm[1..-1]   ##delmは_(アンダーバー付き)
						field = items[0..-2].join("_")   ##delm(:)が3在った時
					else	
						field = key
					end	
					if rec[field] and key !="id" and key !~ /person.*upd/ 
						fetch_data[field+delm] =  rec[field] ###rec:検索結果
					else 
						if srctblnamechop =~ /^pur|^prd|^cust/ and rec[field] and key !~ /person.*upd/  and field !=  "id"
							fetch_data[field+delm] =  rec[field] ###rec:検索結果
						end
						if srctblnamechop =~ /^pur|^prd|^cust/ and rec[field.gsub(screentblnamechop,srctblnamechop)] and 
								key !~ /person.*upd/ and field =~ /_id/   and field != "#{screentblnamechop}_id"  and field != "id"
							fetch_data[field+delm] =  rec[field.gsub(screentblnamechop,srctblnamechop)] ###rec:検索結果
						end
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
								if org["qty_src"]
									case srctblnamechop
									when /act$/
										case screentblnamechop
										when  /act$/
											if screendata["#{screentblnamechop}_qty_stk"]
												fetch_data["#{screentblnamechop}_qty_stk"] =  rec["#{srctblnamechop}_qty_stk"].to_f - org["qty_src"].to_f
												if fetch_data["#{screentblnamechop}_qty_stk"] <= 0
													params[:err] =  "error   --->over qty"
												end
											end
										else
											if screendata["#{screentblnamechop}_qty"]
												fetch_data["#{screentblnamechop}_qty"] =  rec["#{srctblnamechop}_qty_stk"].to_f - org["qty_src"].to_f
												if fetch_data["#{screentblnamechop}_qty"] <= 0
													params[:err] =  "error   --->over qty"
												end
											end
										end
									when /sch$/
										if screentblnamechop =~ /schs$/
											if screendata["#{screentblnamechop}_qty_sch"]
												fetch_data["#{screentblnamechop}_qty_sch"] = rec["#{srctblnamechop}_qt_sch"].to_f  - org["qty_src"].to_f
												if fetch_data["#{screentblnamechop}_qty_sch"] <= 0
													params[:err] =  "error   --->over qty"
												end
											end
										else	
											if screendata["#{screentblnamechop}_qty"]
												fetch_data["#{screentblnamechop}_qty"] = rec["#{srctblnamechop}_qty_sch"].to_f  - org["qty_src"].to_f
												if fetch_data["#{screentblnamechop}_qty"] <= 0
													params[:err] =  "error   --->over qty"
												end
											end
										end
									else
										if screentblnamechop =~ /act$/
											if screendata["#{screentblnamechop}_qty_stk"]
												fetch_data["#{screentblnamechop}_qty_stk"] = rec["#{srctblnamechop}_qty"].to_f  - org["qty_src"].to_f
												if fetch_data["#{screentblnamechop}_qty_stk"] <= 0
													params[:err] =  "error   --->over qty"
												end
											end
										else	
											if screendata["#{screentblnamechop}_qty"]
												fetch_data["#{screentblnamechop}_qty"] = rec["#{srctblnamechop}_qty"].to_f  - org["qty_src"].to_f
												if fetch_data["#{screentblnamechop}_qty"] <= 0
													params[:err] =  "error   --->over qty"
												end
											end
										end
									end
								else
									case srctblnamechop 
									when	/act$/
										case screentblnamechop 
										when	/act$/
											if screendata["#{screentblnamechop}_qty_stk"]		
												fetch_data["#{screentblnamechop}_qty_stk"] =  rec["#{srctblnamechop}_qty_stk"].to_f 
											end
										else
											if screendata["#{screentblnamechop}_qty"]		
												fetch_data["#{screentblnamechop}_qty"] =  rec["#{srctblnamechop}_qty_stk"].to_f 
											end
										end	
									when /sch/	
										case screentblnamechop 
										when	/sch$/
											if screendata["#{screentblnamechop}_qty_sch"]		
												fetch_data["#{screentblnamechop}_qty_sch"] =  rec["#{srctblnamechop}_qty_sch"].to_f 
											end
										else
											if screendata["#{screentblnamechop}_qty"]		
												fetch_data["#{screentblnamechop}_qty"] =  rec["#{srctblnamechop}_qty_sch"].to_f 
											end
										end	
									else	
										if screentblnamechop =~ /act$/
											if screendata["#{screentblnamechop}_qty_stk"]		
												fetch_data["#{screentblnamechop}_qty_stk"] =  rec["#{srctblnamechop}_qty"].to_f 
											end
										else
											if screendata["#{screentblnamechop}_qty"]		
												fetch_data["#{screentblnamechop}_qty"] =  rec["#{srctblnamechop}_qty"].to_f 
											end
										end	
									end
								end
							else
							end
					end
				end	
				field = screentblnamechop+"_"+viewtblnamechop+"_id"+delm
				###if screendata[field]
				fetch_data[field] =  rec["id"]
				###end
				@findstatus = true
			else
				fetch_data[screentblnamechop+"_"+viewtblnamechop+"_id"+delm] =  ""  ##再入力時のNgに対応
				@findstatus = false
			end	
		return fetch_data,keys,screendata
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

	def proc_judge_check_code params,sfd,yupcheckcode  ###item未使用
			checkstatus = true
			check_proc = yupcheckcode.split(",")[0]
			params = __send__("check_#{check_proc}",params,sfd,yupcheckcode)  ###[1]: nil all,add,updateは画面側で判断
		return params 
	end	

	def check_paragraph params,item,yupcheckcode ### proc_judge_check_codeからcallされる。
		linedata = params[:parse_linedata]
		if linedata["screenfield_paragraph"] == ""
			if linedata["pobject_code_sfd"] =~ /_code/ and params[:screenCode].split("_")[1].chop == linedata["pobject_code_sfd"].split("_"[0])
				checkstatus = false
				params[:err] =  "error   --->view or field  #{linedata["screenfield_paragraph"]}　not find "
			else	
				checkstatus = true
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
					checkstatus = true
					params[:err] = nil
				else
					checkstatus = false
					params[:err] =  "error   --->view or field  #{linedata["screenfield_paragraph"]}　not find "
				end
			end
		end
		return params
	end	

	def check_strorder params,item,yupcheckcode
		linedata = params[:parse_linedata]
		if linedata["screen_strorder"] and linedata["screen_strorder"] != ""
			ary_select_fields = linedata.keys
			sort_info = {}
			sort_info[:default] = linedata["screen_strorder"]
			sort_info = proc_detail_check_strorder sort_info,ary_select_fields
			if sort_info[:err] 
				params[:err] =  sort_info[:err] 
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

	def check_qty params,item,yupcheckcode
	 	linedata = params[:parse_linedata]
		tblname =  params[:screenCode].split("_")[1]
	 	if linedata[tblname.chop + "_qty"]
	 		symqty = tblname.chop + "_qty"
	 	else
	 		symqty = tblname.chop + "_qty_stk"
	 	end

	 	if linedata[symqty] == ""
	 		checkstatus = false
	 		params[:err] =  "error   --->#{symqty} missing "
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
	 					checkstatus = true
	 				else
	 					checkstatus = false
	 					params[:err] =  "error ---> #{prev_qty} <　input qty:#{linedata[symqty]} "
	 				end
	 		end
	 		if linedata["id"] != "" and checkstatus == true ###更新の時のみ　ords-->insts  insts -->actsに既にどれだけ変化しているか？
	 			strsql = %Q%select sum(qty) qty from trngantts where tblname = '#{currtblnamechop}s'
	 							and tblid = #{linedata["id"]} group by  tblname,tblid
	 			%
	 			chng_qty = ActiveRecord::Base.connection.select_value(strsql)	
	 			chng_qty ||= 0.0  ###すでに次の状態に変化した数値
	 			if chng_qty.to_f <= linedata[symqty].to_f
	 				checkstatus = true
	 				params[:err] =  nil
	 			else
	 				checkstatus = false
	 				params[:err] =  "error   ---> qty must be >= #{chng_qty} "
	 			end	
	 		end
	 	end
	 	return params
	end	

	 def check_loca_code_to params,item,yupcheckcode
	 	linedata = params[:parse_linedata]
	 	tblname =  params[:screenCode].split("_")[1]
	 	id = linedata["#{tblname.chop}_id"]
	 	if id != ""  ###更新の時のみ　ords-->insts  insts -->actsに既にどれだけ変化しているか？
	 		sym = "loca_code_to"
	 		if linedata[sym] == ""
	 			checkstatus = false
	 			params[:err] =  "error   --->#{sym} missing "
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
	 				params[:err] =  "error   ---> loca_code_to must be >= #{rec["loca_code_to"]} "
				 else
					params[:err] =  nil
	 			end 
	 		end
	 	end
	 	return params
	 end	

	def check_already_used params,item,yupcheckcode   ###あるidで登録されたcodeが別のテーブルに既に登録されているとき、codeの変更は不可
		###外部keyでチェックすべき???
		check_code,view,field = yupcheckcode.split(",")
		strsql = %Q&select #{field} from #{view} where #{field} = '#{params[:parse_linedata][item.to_sym]}'
				&
		old_value = ActiveRecord::Base.connection.select_value(strsql)
		old_value ||= ""
		if params[:parse_linedata][item.to_sym].nil? or old_value == ""
					new_value = ""
		else
					strsql = %Q&select #{field} from #{view} where #{field.sub("_code","_id")} = #{params[:parse_linedata]["id"]}
					&
					new_value = ActiveRecord::Base.connection.select_value(strsql)
			end
		if old_value == new_value
					params[:err] = nil
			else	
					params[:err] =  "error   ---> #{field} can not change because #{view} already used "
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
	def proc_fields_update parent,screenCode ,command_c  ###xxxschsの作成のみ
		@command_x = command_c
		@para = {}
		yield @command_x,@para   ###@para 子供自身の員数等
		parent.each do |key,val|
			case key
				when /processseq$/
					@para["parent_processseq"] = val
				when /starttime/
					@para["parent_starttime"] = val.to_date
				when  /chrgs_id/
					@para["chrgs_id"] = val
				when /qty$/
					@para["parent_qty"] = val.to_f
				when /qty_sch$/
					@para["parent_qty_sch"] = val.to_f
				when /qty_handover$/
					@para["parent_qty_handover"] = val.to_f
				when /qty_stk$/
					@para["parent_qty_stk"] = val.to_f
				when /qty_bal$/
					@para["parent_qty_bal"] = val.to_f
				when  /prjnos_id/
					@para["parent_prjno_id"] = val
			end
		end	 

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
						field_opeitms_id fd
				when "price"  ###保留
						field_price_amt_tax_contract_price 
				when "processseq_pare"
						field_processseq_pare
				when "prjnos_id"
						field_prjnos_id
				when "qty_sch"
						field_qty_sch 
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
				when "crrs_id"
						field_crrs_id
			end	
		end		
		return @command_x,@qty_require
	end	 

	def	field_tblid
		if @command_x["id"] == "" or  @command_x["id"].nil?
			@command_x[:sio_classname] = "_add_grid_line_data"
			@command_x["id"] =  ArelCtl.proc_get_nextval("#{@tblnamechop}s_seq")
	 	else         
			@command_x[:sio_classname] = "_edit_update_grid_line_data"
	 	end   
		@command_x["#{@tblnamechop}_id"] = @command_x["id"]
	end	

	def field_confirm
		@command_x["#{@tblnamechop}_confirm"] = false if @command_x["#{@tblnamechop}_confirm"].nil? or  @command_x["#{@tblnamechop}_confirm"] == ""
	end	

	def field_opeitms_id fd
		key = @tblnamechop + "_opeitm_id" 
		@command_x[key] = @para["opeitms_id"]  ###  変更はないはず
	end

	def field_locas_id_to 
		@command_x["#{@tblnamechop}_loca_id_to"] = @para["locas_id_fm"] ##
	end 

	def field_suppliers_id 
		strsql = %Q%select  id from suppliers where locas_id_supplier = #{@para["locas_id"]}
		%
		id = ActiveRecord::Base.connection.select_value(strsql)
		###supplier_code = dummy は必須 id = 0
		id ||= 0
		@command_x["#{@tblnamechop}_supplier_id"] = id ##
	end 

	def field_workplaces_id 
		strsql = %Q%select  id from workplaces where locas_id_workplace = #{@para["locas_id"]}
		%
		id = ActiveRecord::Base.connection.select_value(strsql)
		###worlplace_code = dummy は必須 id = 0
		id ||= 0
		@command_x["#{@tblnamechop}_workplace_id"] = id ##
	end 

	def field_crrs_id ###seq_noは suppliersのあと
	end 

	def field_shelfnos_id_to 
		@command_x["#{@tblnamechop}_shelfno_id_to"] = @para["shelfnos_id_to"] ##
	end 

	def field_processseq_pare 
		@command_x["#{@tblnamechop}_processseq_pare"] = @para["parent_processseq"] 
	end	

	def field_isudate
		@command_x["#{@tblnamechop}_isudate"] = Time.now.to_s if @command_x["#{@tblnamechop}_isudate"].nil? or @command_x["#{@tblnamechop}_isudate"] == ""
	end	 

	def field_duedate 
		duedate = @para["parent_starttime"] - 1
		@command_x["#{@tblnamechop}_toduedate"] = @command_x["#{@tblnamechop}_duedate"] = duedate.to_s
	end

	def field_starttime
		starttime =  @command_x["#{@tblnamechop}_duedate"].to_date - @para["duration"]
		@command_x["#{@tblnamechop}_starttime"] = starttime.to_s
	end

	def field_chrgs_id ### seq_noは　chrgs_id > custs_id,suppliers_id,workplaces_idであること
		if @command_x["#{@tblnamechop}_chrg_id"].nil? or  @command_x["#{@tblnamechop}_chrg_id"] == ""
			if @para["chrgs_id"]
				@command_x["#{@tblnamechop}_chrg_id"] = @para["chrgs_id"]
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
		@qty_require = @para["parent_qty_handover"] * @para["chilnum"] / @para["parenum"]
		#consumunitqty等については親に合わせて計算する。
		if @para["consumunitqty"] > 0
			@qty_require = (@qty_require /  @para["consumunitqty"]).ceil *  @para["consumunitqty"]
		# #	@command_x["#{tblnamechop}_qty"] = @para["consumunitqty"] * rlst   ###消費単位
		end	
		if @para["consumminqty"] > @qty_require
			@qty_require = @para["consumminqty"]  ###最小消費数
		end	
		@qty_require += @para["consumchgoverqty"]
		@command_x["#{@tblnamechop}_qty_sch"] = (@qty_require / @para["packqty"]).ceil * @para["packqty"]  

	end	

	def field_qty_case 
		if @para["packqty"] > 0
			@command_x["#{@tblnamechop}_qty_case"] = (@qty /  @para["packqty"]).ceil 
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
		ControlFields.proc_snolist["#{tblnamechop}s"] + format('%05d', id) 
	end

	def proc_field_cno id 
		 format('%07d', id)
	end

	def proc_field_gno id
		 format('%07d', id) 
	end	

	def field_prjnos_id 
		@command_x["#{@tblnamechop}_prjno_id"] = @para["parent_prjno_id"] 
	end	

	def field_consumauto
		@command_x["#{@tblnamechop}_consumauto"] = @para["consumauto"] if @command_x["#{@tblnamechop}_consumauto"].nil? or  @command_x["#{@tblnamechop}_consumauto"] == ""
	end

	def field_autocreate 
		@command_x["#{@tblnamechop}_autocreate"] = @para["autocreate"] if @command_x["#{@tblnamechop}_autocreate"].nil? or  @command_x["#{@tblnamechop}"] == ""
	end		
	
	def field_expiredate
		@command_x["#{@tblnamechop}_expiredate"] = "2099/12/31" if @command_x["#{@tblnamechop}_expiredate"].nil? or @command_x["#{@tblnamechop}_expiredate"] == ""
	end	

end   ##module