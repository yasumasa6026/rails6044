# -*- coding: utf-8 -*-
module CtlFields
	extend self
	def proc_fetch_rec params,parse_linedata
		fetchview = save_fetchview = ""  ### save_fetchview:複数項目でkeyを構成するする時の重複処理を避ける
		params[:fetchview].split(",").each do |fetch|
			fetchview,delm = fetch.split(":")   ## YupSchemaでparagrapfをもとに作成済　split(":")拡張子の確認
			next if fetch == save_fetchview 
			delm ||= ""
			params = detail_fetch_rec(params,fetchview,delm,parse_linedata)
			save_fetchview = fetch	
		end
		return params
	end
	def  detail_fetch_rec(params,fetchview,delm,parse_linedata)
		params[:err] = nil 
		parseLineData,keys,findstatus,mainviewflg,missing = get_fetch_rec(params,fetchview,delm,parse_linedata)
		params[:parse_linedata] = parseLineData.dup
	  if findstatus
			if mainviewflg   ##mainviewflg = true 自分自身の登録
				if 	params[:parse_linedata]["aud"] == "add" or params[:aud] =~ /add/
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
          viewCode = "#{params[:screenCode].split("_")[1].chop}_code"
				  params[:parse_linedata].each do |key,val| ###コードが変更されたとき既に使用されている？
					  if key == viewCode
              strsql = %Q&
                          select code from #{params[:screenCode].split("_")[1]}
                                      where id = #{params[:parse_linedata][:id]}
              &
              last_code =ActiveRecord::Base.connection.select_value(strsql)
              if params[:parse_linedata][viewCode] ==  last_code  ###変更されていない。
                next
              else
                strsql = %Q&
                          select pobject_code_tbl tblname,pobject_code_fld fld from r_tblfields
                                  where  pobject_code_fld like '#{params[:screenCode].split("_")[1]}_id%'
                                  and tblfield_expiredate > current_date
                  &
                  ActiveRecord::Base.connection.select_all(strsql).each do |tbl|
                    strsql = %Q&
                            select 1 from #{tbl["tblname"]} where #{tbl["fld"]} = #{JSON.parse(params[:lineData])["id"]} 
                    &  ###params[:lineData] 修正前のデータ
                    if ActiveRecord::Base.connection.select_value(strsql)  ###既に別tblに登録されている。
										    params[:err] = params[:parse_linedata][("#{key}_gridmessage")] =  "error 3 2 cannot change ---> code:#{params[:parse_linedata][viewCode]}"
                        break
                    end
                  end
              end
					  end
				  end
        end		
			else
					keys.split(",").each do |key| 
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

	def get_fetch_rec(params,fetchview,delm,parse_linedata)
			keys = ""
			xno = ""
			srctblnamechop = ""
			screentblnamechop = params[:screenCode].split("_")[1].chop
			viewtblnamechop = fetchview.split("_")[1].chop
			parseLineData = parse_linedata.dup
			mainviewflg = true  ##自分自身の登録か？
			findstatus = true
			if params[:screenCode].split("_")[1] != fetchview.split("_")[1] 
					mainviewflg = false
			else
				if delm != ""   ###自身のテーブルを参照しいるとき
					mainviewflg = false
        else
          if 	params[:aud] =~ /update|edit/ or params[:aud] =~ /update|edit/
			        return parseLineData,keys,findstatus,mainviewflg,missing=true  ###未入力項目在り
          end
				end	
			end
			flgfetchview = fetchview + if delm == "" then "" else ":#{delm}" end	  
	    #fetcfieldgetsql = "select pobject_code_sfd,screenfield_paragraph from r_screenfields
			# 					 where pobject_code_scr =  '#{params[:screenCode]}' 
			# 					 and screenfield_paragraph like '%#{flgfetchview}%'"
        fetcfieldgetsql = "select p.code  pobject_code_sfd,s.paragraph screenfield_paragraph  from screenfields s
		                           inner join pobjects p on p.id = s.pobjects_id_sfd -- and p.objecttype = 'view_field' 
	                             where s.screens_id  = (select scr.id from screens scr 
	 		 						                                      inner join pobjects p2   on p2.id = scr.pobjects_id_scr 
	 		 									                              and p2.objecttype  = 'screen'
	 		 									                              and p2.code = '#{params[:screenCode]}') 
			  					              and s.paragraph like '%#{flgfetchview}%' ---先頭の“%”は複数のviewに対応ため"
			missing = false   ###missing:true パラメータが未だ未設定　　false:チェックok
			where_strsql = ""
			fetchs = ActiveRecord::Base.connection.select_all(fetcfieldgetsql)
			cnt = 0
      paragraphs = []
			fetchs.each do |prefetch|
				prefetch["screenfield_paragraph"].split(",").each do |paragraph|
					if paragraph == flgfetchview   
						paragraphs << prefetch["pobject_code_sfd"]
					else
						next
					end
				end
			end	
          Rails.logger.debug("class:#{self},line:#{__LINE__},\n parse_linedata:#{parse_linedata}")
			paragraphs.each do |fetch|  ###viewの複数keyの入力確認
					cnt += 1 
					valOfField = parse_linedata[fetch]
					prefix,xno,srctblnamechop = fetch.split("_") ###xxx_sno_yyyy,xxx_cno_yyy用
					if valOfField =~ /,/				 ###入力項目に「,」が入っていた時
						params[:err] =  "error 3  --->not input comma:#{params[:index]} "
						parseLineData[(fetch+"_gridmessage")] =  "error 3 --->not input comma"  ###!!!
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
								where_strsql << " #{viewtblnamechop}_#{xno} = '#{parse_linedata[fetch]}'       and"
							else
								if delm == ""
									where_strsql << "  #{fetch} = '#{parse_linedata[fetch]}'        and"
								else
									where_strsql << "  #{fetch.split(delm)[0]} = '#{parse_linedata[fetch]}'       and"
								end
							end
							missing = false 
						end
					end
          Rails.logger.debug("class:#{self},line:#{__LINE__},\n missing:#{missing},\n fetch:#{fetch}")
					if missing == false  ###検索のための入力項目はすべて入力されている。
						if cnt >= paragraphs.to_a.size
							case fetch
							when  /_sno_|_cno_|_packinglistno_/ ###duedate,starttime,expiredateの引継ぎがあるとき
								viewstrsql = "select * from  func_get_screenfield_grpname('#{params[:email]}','#{fetchview}')"
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
					if rec  ###viewレコードあり
						### parseLineData = parse_linedata.dup loop 中に内容の変更はできない。 
            fields = rec.keys
						parse_linedata.each do |key,val|  ###結果をセット
							# if key.to_s == "id"
							# 	parseLineData["id"] = parseLineData[(screentblnamechop+"_id")] = "" if params[:parse_linedata][:aud] =~ /add|insert/
							# 	next
							# end 
							# next if key.to_s =~ /person.*upd/  
							# ###画面の項目を分解　tableName.chop_fieldName(_delm),viewtblnamechop.fieldName(_delm),tableName.chop_viewtblnamechop_id(_dlem)
							# items = key.to_s.split("_")
							# if delm != ""
							# 	next if key.to_s !~ /#{delm}$/  ###同一viewでkeyが異なる。
							# 	field = key.to_s.sub(delm,"")
							# else
							# 	field = key.to_s
							# end
							# if key.to_s =~ /_id/
							# 	if delm == ""
							# 		other_tbl_key = (screentblnamechop+"_"+viewtblnamechop+"_id")
							# 		other_tbl_key_grid = (screentblnamechop+"_"+viewtblnamechop+"_id_gridmessage")
							# 	else
							# 		other_tbl_key = (screentblnamechop+"_"+viewtblnamechop+"_id_"+delm)
							# 		other_tbl_key_grid = (screentblnamechop+"_"+viewtblnamechop+"_id_"+delm+"_gridmessage")
							# 	end
							# 	if parseLineData[other_tbl_key]
							# 		if rec[viewtblnamechop+"_id"]
							# 			parseLineData[other_tbl_key] = rec[viewtblnamechop+"_id"]
							# 			parseLineData[other_tbl_key_grid] = "deteted"
							# 		end
							# 	end
							# end
							# if rec[field]  ###id,sno,cnoから求められた同一項目を画面にセットする。
							# 	field_gridmessage = (key.to_s + "_gridmessage")
							# 	next if parseLineData[field_gridmessage] == "ok"  or parseLineData[field_gridmessage] == "deteted"    ###手入力あり
							# 	parseLineData[key] =  rec[field]  
							# 	###end
							# 	###自動セット項目 onblurfunc.js 参照(tableをgetしないとき利用)
							# 	### qty,qty_stkの修正のため	nextしない。
							# else
							#  	### sno,cnoからデータを求めた時は同一項目でなくてもdelmが同じであればセットする。
							# 	if items[0] == screentblnamechop
							# 		if items[1] == viewtblnamechop 
							# 			if items[2]  == "id"
							#  				if rec["#{field.sub("#{screentblnamechop}_","")}"]  ###r_opeitms ==>opeitm_id
							#  					parseLineData[key]  = rec["#{field.sub("#{screentblnamechop}_","")}"]	
							# 				end
							# 			end
							# 		else ###項目の引継ぎ  purord_opeitm_xxx => puract_opeitm_xxx
							# 			if (val == ""  or val.nil? or val.to_s == "0" ) 
							# 				next if field =~ /_sno$|_cno$|_gno$|_isudate|_created_at|_updated_at|_remark|_contents|_seqno/
							# 				if rec["#{field.sub(/^#{screentblnamechop}/,"#{viewtblnamechop}")}"]  
							# 					parseLineData[key]  = rec["#{field.sub(/^#{screentblnamechop}/,"#{viewtblnamechop}")}"]  
							# 				end
							# 			end
							# 		end
							# 	end
							# end
							if delm != ""
							 	next if key.to_s !~ /#{delm}$/  and key.to_s =~ /#{viewtblnamechop}/  ###同一viewでkeyが異なる。shelfnos_id_fm shelfnos_id_to
							 	field = key.to_s.sub(delm,"")
							else
                next if key.to_s.split("_id_")[1] and key.to_s =~ /#{viewtblnamechop}/
							 	field = key.to_s
							end
              case key.to_s
                when /person.*upd|_gridmessage/ 
                    next
                when "id" 
                   	parseLineData["id"] = parseLineData[(screentblnamechop+"_id")] = "" if params[:aud] =~ /add|insert/
                   	next
                when /^#{screentblnamechop}_#{viewtblnamechop}_id/
							 	 	  other_tbl_key_grid = (key.to_s+"_gridmessage")
                    parseLineData[key] = rec[viewtblnamechop+"_id"] ###主キイの取得
                    parseLineData[other_tbl_key_grid] = "deteted"
                    next
                when /^#{screentblnamechop}.*_id/  ####screentblnamechop_xxxx_id == viewtblnamechop_xxxx_id
                    midltbl = key.to_s.split("_")[1] 
                    viewdlm = key.to_s.split("_id_")[1]  
                    if viewdlm and viewdlm != "" 
                      viewdlm = "_" + viewdlm ###viewtblnamechopのidが複数あるとき 
                    else
                      viewdlm = ""
                    end
                    if rec["#{viewtblnamechop}_#{midltbl}_id#{viewdlm}"] 
                      parseLineData[key] = rec["#{viewtblnamechop}_#{midltbl}_id#{viewdlm}"] 
                      next
                    end
                    case key.to_s
                      when /^custord_|^custsch_/
                        case viewtblnamechop
                          when "cust"
                            case key.to_s
                              when /^#{screentblnamechop}_crr_id$/
                                parseLineData[key] = rec["bill_crr_id_bill_cust"]
                            end
                        end
                    end  
                       ###r_opeitms ==>opeitm_id
                #       next if key.to_s.split("_")[0] == key.to_s.split("_")[-1]   ###cust_loca_id_cust と bill_loca_id_billを区別
							 	# 			if rec[field.sub(screentblnamechop,viewtblnamechop)]  ###r_opeitms ==>opeitm_id
							  # 					parseLineData[key]  = rec[field.sub(screentblnamechop,viewtblnamechop)] 
                #           next
							 	# 			end
                #       tar_tblchop = field.split("_")[1]   ###field[0]:screentblnamechop,field[1]:target_tblchop,field[2]:id
                #       fieldkey = fields.find{|i|  i =~ /#{tar_tblchop}_id/} ###fields(recのkey配列）の中にtarget_tblchop_idがあるか？
                #       if fieldkey
                #           parseLineData[key] =  rec[fieldkey]  ### r_custords の　r_custrcvplcsのtransport_code対応
                #           next
                #       end
                #       next
                # when /^#{viewtblnamechop}.*_id/
                #       tar_tblchop = field.split("_")[1]   ###field[0]:screentblnamechop,field[1]:target_tblchop,field[2]:id
                #       fieldkey = fields.find{|i|  i =~ /^#{viewtblnamechop}_#{tar_tblchop}_id/} ###fields(recのkey配列）の中にtarget_tblchop_idがあるか？
                #       if fieldkey 
                #         tar_tblchop_sym = (screentblnamechop + "_" + tar_tblchop + "_id")
                #         viewfkey = fields.find{|i|  i =~ /#{tar_tblchop_sym}/}
                #         if viewfkey 
                #           if key.to_s =~ /#{delm}$/
                #               parseLineData[key] =  rec[fieldkey]
                #           else
                #             next
                #           end
                #         else
                #           parseLineData[key] =  rec[fieldkey]
                #         end
                #         next
                #       end
                when  /_id/
                   if rec[field]  ###id,sno,cnoから求められた同一項目を画面にセットする。
                     parseLineData[key] =  rec[field] 
                   end
                when  /_sno$|_cno$|_gno$|_isudate|_created_at|_updated_at|_remark|_contents|_seqno/
                  next
                else
                  if rec[field]  ###id,sno,cnoから求められた同一項目を画面にセットする。
                    parseLineData[key] =  rec[field]  
                  else ###項目の引継ぎ  purord_opeitm_xxx => puract_opeitm_xxx
                    	if (val == ""  or val.nil? or val.to_s == "0" ) 
                        if (screentblnamechop =~ /cust/ and viewtblnamechop =~ /cust/ and screentblnamechop !~ /cust$/)  or
                            (screentblnamechop =~ /pur/ and viewtblnamechop =~ /pur/)   or
                             (screentblnamechop =~ /prd/ and viewtblnamechop =~ /prd/)  or
                              (screentblnamechop =~ /itm/ and viewtblnamechop =~ /itm/)      
                          if rec["#{field.sub(/^#{screentblnamechop}/,"#{viewtblnamechop}")}"]  
                     					parseLineData[key]  = rec["#{field.sub(/^#{screentblnamechop}/,"#{viewtblnamechop}")}"]  
                              next
                          end
                    		end
                        fieldkey = fields.find{|i|  i =~ /^#{field}/} 
                        if fieldkey and (delm == "" or key.to_s =~ /#{delm}$/)
                          parseLineData[key] =  rec[fieldkey]  ### r_custords の　r_custrcvplcsのtransport_code対応
                          next
                        end
                      end
                  end
              end
						end
            
            # if field =~ /#{viewtblnamechop}/
            #     ### r_custrcvplcsのtransports_id対応
            #       parseLineData[key]  = rec["#{field}"]  
            # end
						if fetch 	=~ /_sno_/ and params[:aud] == "add" 
							org = nil
							case screentblnamechop
							  when /prd|pur/
								  str_srctbl_qty = "" ###次のステータスに移行していないqtyを求める。　
								  ### qtyのセット
								  if  (viewtblnamechop =~ /sch$/ and screentblnamechop =~ /ord$/) 
									  if parse_linedata[(screentblnamechop+"_qty")].to_s == "0"   ###初期値でzeroがセットされていること
										  str_srctbl_qty = "max(srctbl.qty_sch) srctbl_qty"
									  end
								  end
								  if	(viewtblnamechop =~ /ord$/ and screentblnamechop =~ /inst$/) or 
									  (viewtblnamechop =~ /ord$/ and screentblnamechop =~ /replyinput/) or
										(viewtblnamechop =~ /inst$/ and screentblnamechop =~ /replyinput/)   
									  if parse_linedata[(screentblnamechop+"_qty")].to_s == "0"   ###初期値でzeroがセットされていること
										  str_srctbl_qty = "max(srctbl.qty) srctbl_qty"
									  end
								  end
								  if 	(viewtblnamechop =~ /ord$/ and screentblnamechop =~ /dlv$|act$/) or 
									    (viewtblnamechop =~ /inst$/ and screentblnamechop =~ /dlv$|act$/) or
										  (viewtblnamechop =~ /replyinput$/ and screentblnamechop =~ /dlv$|act$/)   
									    if parse_linedata[(screentblnamechop+"_qty_stk")].to_s == "0"   ###初期値でzeroがセットされていること
										    str_srctbl_qty = "max(srctbl.qty) srctbl_qty"
									    end
								  end
								  if str_srctbl_qty != ""
									  strsql = %Q% select sum(link.qty_src) qty_src ,#{str_srctbl_qty}
											from #{viewtblnamechop}s srctbl 
											left join  linktbls link  on srctbl.id = link.srctblid	and link.srctblname = '#{viewtblnamechop}s'
																		and (link.srctblname != link.tblname or link.srctblid != link.tblid)
																		and link.tblid != '#{parse_linedata[(screentblnamechop+"_id")]}' 
											where srctbl.sno = '#{parse_linedata[(screentblnamechop+"_sno_"+viewtblnamechop)]}' ---key.split("_")[1] :sno
											group by srctbl.id
										  %  
									    org =  ActiveRecord::Base.connection.select_one(strsql)
								  end
								  next if str_srctbl_qty == ""
							  when /pay|bill/
								  str_srctbl_amt = ""
								  if 	(viewtblnamechop =~ /ord$/ and screentblnamechop =~ /act$/) or 
									  	(viewtblnamechop =~ /inst$/ and screentblnamechop =~ /act$/) 
									    if parse_linedata[(screentblnamechop+"_cash")].to_s == "0"   ###初期値でzeroがセットされていること
										    str_srctbl_amt = "max(srctbl.amt) srctbl_amt"
									    end
								  end
								  if str_srctbl_amt != ""
									  strsql = %Q% select sum(link.amt_src) amt_src ,#{str_srctbl_amt}
											from #{viewtblnamechop}s srctbl 
											left join  srctbllinks link  on srctbl.id = link.srctblid	and link.srctblname = '#{viewtblnamechop}s'
																		and (link.srctblname != link.tblname or link.srctblid != link.tblid)
											where srctbl.sno = '#{parse_linedata[(screentblnamechop+"_sno_"+viewtblnamechop)]}' ---key.split("_")[1] :sno
											group by srctbl.id
										  %  
									  org =  ActiveRecord::Base.connection.select_one(strsql)
								  end
							end
						end
						if fetch 	=~ /_cno_/ and (parse_linedata["aud"] == "add" or params[:aud] =~ /add/)
							org = nil					
							str_loca_code = ""
							str_srctbl_qty = ""
							if  parseLineData[(screentblnamechop+"_shelfno_id")] != ""  and  !parseLineData[(screentblnamechop+"_shelfno_id")].nil? and
								screentblnamechop =~ /pur/
								str_loca_code = "and shelfnos_id = #{parseLineData[(screentblnamechop+"_shelfno_id")]}"
							end
							if  parse_linedata[(screentblnamechop+"_shelfno_id")] != ""  and  !parseLineData[(screentblnamechop+"_shelfno_id")].nil? and
								screentblnamechop =~ /cust/
								str_loca_code = " and locas_id_cust = #{parseLineData[(screentblnamechop+"_loca_id")]}"
							end ###次のステータスに移行していないqtyを求める。　
							if parseLineData[(screentblnamechop+"_qty")].to_s == "0"   ###初期値でzeroがセットされていること
								if  (viewtblnamechop =~ /sch$/ and screentblnamechop =~ /ord$/) 
									str_srctbl_qty = "max(srctbl.qty_sch) srctbl_qty"
								end
								if	(viewtblnamechop =~ /ord$/ and screentblnamechop =~ /inst$/) or 
									(viewtblnamechop =~ /ord$/ and screentblnamechop =~ /replyinput/) or
										(viewtblnamechop =~ /inst$/ and screentblnamechop =~ /replyinput/)   
											str_srctbl_qty = "max(srctbl.qty) srctbl_qty"
								end
							end
							if parse_linedata[(screentblnamechop+"_qty_stk")].to_s == "0"   ###初期値でzeroがセットされていること
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
																		and link.tblid != '#{parse_linedata[(screentblnamechop+"_id")]}' 
											where srctbl.cno = '#{parse_linedata[(screentblnamechop+"_cno_"+viewtblnamechop)]}'  #{str_loca_code}  
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
										    parseLineData[(screentblnamechop+"_qty_gridmessage")] =  "error 4 2--->over qty"
									    when /dlv$|act$/
										  parseLineData[(screentblnamechop+"_qty_stk_gridmessage")] =  "error 4 3 --->over qty"
									  end
								  else
									  params[:err] =  nil
									  case screentblnamechop
									    when /ord$|inst$|replyinput/
										    parseLineData[(screentblnamechop+"_qty")] = org["srctbl_qty"].to_f   - org["qty_src"].to_f  
									    when /dlv$|act$/
										    parseLineData[(screentblnamechop+"_qty_stk")] =  org["srctbl_qty"].to_f   - org["qty_src"].to_f
									  end
								  end
							  when /pay|bill/
                  if screentblnamechop !~ /payment|bill$/
								    if org["amt_src"].to_f >= org["srctbl_amt"].to_f 
									    params[:err] =  "error 4 1--->over cash  line:#{params[:index]} "
									    case screentblnamechop
									      when /inst$/
										      parseLineData[(screentblnamechop+"_amt_gridmessage")] =  "error 4 3 --->over cash"
									      when /act$/
										      parseLineData[(screentblnamechop+"_cash_gridmessage")] =  "error 4 3 --->over cash"
									    end
                    end
                  end
              end
						else
							params[:err] =  nil
							case screentblnamechop
								when /inst$/
										  parseLineData[(screentblnamechop+"_amt")] = org["srctbl_amt"].to_f   - org["amt_src"].to_f  
								when /act$/
										  parseLineData[(screentblnamechop+"_cash")] =  org["srctbl_amt"].to_f   - org["amt_src"].to_f
							end
						end	
						# if screentblnamechop != viewtblnamechop ### omit self table
						# 	field = screentblnamechop+"_"+viewtblnamechop+"_id"+delm
						# 	parseLineData[field] =  rec["id"]
						# end
						case screentblnamechop ###masterの規定値をset
						when /^custsch|^custord/
							case  fetchview
							# when /custs$/
							# 	if parseLineData["crr_code"].nil? or parseLineData["crr_code"] == ""
							# 		parseLineData["crr_code"] = rec["crr_code_bill_cust"]
							# 		parseLineData["crr_name"] = rec["crr_name_bill_cust"]
							# 		parseLineData["custord_crr_id"] = rec["bill_crr_id_bill_cust"]
							# 	end
							# 	if parseLineData["custord_contractprice"].nil? or parseLineData["custord_contractprice"] == ""
							# 		 parseLineData["custord_contractprice"] = rec["cust_contractprice"]
							# 	end
							when  /opeitms$/ 
								if parseLineData["shelfno_code_fm"] == "" or parseLineData["shelfno_code_fm"].nil? 
								   parseLineData["loca_code_shelfno_fm"] = rec["loca_code_shelfno_to_opeitm"]  ###opeitm.shelfno_code_to_opeitm 完成後の置き場所゜
								   parseLineData["shelfno_code_fm"] = rec["shelfno_code_to_opeitm"]  ###opeitm.shelfno_code_to_opeitm 完成後の置き場所゜
								   parseLineData["loca_name_shelfno_fm"] = rec["loca_name_shelfno_to_opeitm"]  ###opeitm.shelfno_code_to_opeitm 完成後の置き場所゜
								   parseLineData["shelfno_name_fm"] = rec["shelfno_name_to_opeitm"]  ###opeitm.shelfno_code_to_opeitm 完成後の置き場所゜
								   parseLineData["#{screentblnamechop}_shelfno_id_fm"] = rec["opeitm_shelfno_id_to_opeitm"]  ###opeitm.shelfno_code_to_opeitm 完成後の置き場所゜
									###custord.shelfno_code_fm 客先への出荷のための梱包場所
								end
              end
            end
						# when /^custacthead/
						# 	case  fetchview
						# 	  when /custs$/
						# 		  if parseLineData["loca_code_bill"].nil? or parseLineData["loca_code_bill"] == ""
						# 			  parseLineData["loca_code_bill"] = rec["loca_code_bill_cust"]
						# 			  parseLineData["loca_name_bill"] = rec["loca_name_bill_cust"]
						# 			  parseLineData["custacthead_bill_id"] = rec["cust_bill_id_cust"]
						# 		  end
						# 		  if parseLineData["crr_code_bill"].nil? or parseLineData["crr_code_bill"] == ""
						# 			  parseLineData["crr_code_bill"] = rec["crr_code_bill_cust"]
						# 			  parseLineData["crr_name_bill"] = rec["crr_name_bill_cust"]
						# 		  end
						# 	  when /bills$/
						# 			parseLineData["loca_code_bill"] = rec["loca_code_bill"]
						# 			parseLineData["loca_name_bill"] = rec["loca_name_bill"]
						# 			parseLineData["custacthead_bill_id"] = rec["bill_id"]
                  
						# 			parseLineData["crr_code_bill"] = rec["crr_code_bill"]
						# 			parseLineData["crr_name_bill"] = rec["crr_name_bill"]
            #   end
					else
						findstatus = false
						##再入力時のNgに対応	
						if missing == false and mainviewflg == false
							if screentblnamechop != viewtblnamechop and xno !~ /_sno|_cno|_packinglistno/ ### omit self table
								### sno,cnoの時は例えば r_puractsにpurord_idを含んでない。(sno_purord,sno_ourdlv等どちらを使用するか不明。)
								field = (screentblnamechop+"_"+viewtblnamechop+"_id"+delm)
								parseLineData[field] =  ""
							end
							parseLineData[(fetch+"_gridmessage")] =  "error not detected" 
						else
						end
					end
      end
			return parseLineData,keys,findstatus,mainviewflg,missing
	end		

	def proc_blkuky_check tbl,parseLineData   ###重複チェック
		save_blkuky_grp = nil
		keys = []
		err = {}
		strsql = %Q% select blkuky_grp,pobject_code_fld from r_blkukys where pobject_code_tbl = '#{tbl}' 
						and blkuky_expiredate > current_date order by blkuky_grp,blkuky_seqno%
						
		ActiveRecord::Base.connection.select_all(strsql).each do |rec|
			if save_blkuky_grp != rec["blkuky_grp"] 
				if  !save_blkuky_grp.nil? and keys.exclude?("id")
					err = blkuky_check_detail tbl,keys,parseLineData,err
					keys = []
				end
				save_blkuky_grp = rec["blkuky_grp"]
			end
			keys << rec["pobject_code_fld"]
		end
		if !keys.empty? and keys.exclude?("id")  ### id付きの検索keysはたんなるindexのためskip
			err = blkuky_check_detail tbl,keys,parseLineData,err
		end
		return err
	end	

	def blkuky_check_detail tbl,keys,parseLineData,err
		strwhere = " where "
		tblchop = tbl.chop
		keys.each do |key|
			symkey = (tblchop + "_" + key.gsub("s_id","_id"))
			if parseLineData[symkey].nil? or parseLineData[symkey]  == ""
				strwhere = "       #{symkey} must be select      "
				break
			else
				strwhere << "  #{key} = '#{parseLineData[symkey]}'     and "
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
	def proc_judge_check_code params,sfd,checkCode,parse_linedata  ###
		err = nil
		checkCode.split(",").each do |chk|
			parse_linedata,err = __send__("proc_judge_check_#{chk}",parse_linedata,sfd,params[:index],params[:screenCode])  ###[1]: nil all,add,updateは画面側で判断
      params[:err] << err if err
		end
		params[:parse_linedata] = parse_linedata.dup
		return params 
	end	

	# def proc_judge_check_opeitm_loca parseLineData,sfd,index,screenCode
	# 	case parseLineData["opeitm_prdpur"]
	# 	when "pur"
	# 		strsql = %Q&
	# 					select 1 from r_suppliers where loca_code_supplier = '#{parseLineData["loca_code_shelfno_opeitm"]}'
	# 		&
	# 	when "prd","dvs"
	# 		strsql = %Q&
	# 					select 1 from r_custs where loca_code_cust = '#{parseLineData["loca_code_shelfno_opeitm"]}'
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
	# 		err =  "error5 1   --->view or field  #{parseLineData["loca_code_shelfno_opeitm"]}　not find line:#{index} "
	# 	end
	# 	return parseLineData,err
	# end

	def proc_judge_check_paragraph parseLineData,item,index,screenCode ### proc_judge_check_codeからcallされる。
		if parseLineData["screenfield_paragraph"] == ""
			if parseLineData["pobject_code_sfd"] =~ /_code/ and screenCode.split("_")[1].chop == parseLineData["pobject_code_sfd"].split("_")[0]
				err =  "error 5 2   --->view or field  #{parseLineData["screenfield_paragraph"]}　not find line:#{index} "
			else	
				err =  nil
			end
		else	
			if parseLineData["screenfield_paragraph"]
				parseLineData["screenfield_paragraph"].split(",").each do |paragraph|
					screen,delm = paragraph.split(":",2)
					if parseLineData["pobject_code_sfd"] =~ /_sno_|_cno_|_gno_|_packinglistno_/
						case parseLineData["pobject_code_sfd"] 
						when /_tblname/
							field =  parseLineData["pobject_code_sfd"]
						when /_sno_/
							field = parseLineData["pobject_code_sfd"].split("_sno_")[1] + "_sno"
						when /_cno_/
							field = parseLineData["pobject_code_sfd"].split("_cno_")[1] + "_cno"
						when /_gno_/
							field = parseLineData["pobject_code_sfd"].split("_gno_")[1] + "_gno"
						when /_packinglistno_/  ###invoiceに梱包と保守が含まれるときgnoは使用できない。
							field = parseLineData["pobject_code_sfd"].split("_packinglistno_")[1] + "_packinglistno"
						else
						end
					else
						if delm
							field =  parseLineData["pobject_code_sfd"].gsub(delm,"")
						else	
							field =  parseLineData["pobject_code_sfd"]
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
						err =  "error 5 3   --->view or field  #{parseLineData["screenfield_paragraph"]}　not find line:#{index} "
					end
				end
			end
		end
		return parseLineData,err
	end	

	def proc_judge_check_strorder parseLineData,item,index,screenCode   ###　r_screens(screens)のみで有効
		if parseLineData["screen_strorder"] and parseLineData["screen_strorder"] != ""
			ary_select_fields = parseLineData.keys
			sort_info = {}
			sort_info[:default] = parseLineData["screen_strorder"]
			sort_info[:default].split(/\s*,\s*/).each do |sort_field|
				ok = false
				sort_field.split(" ").each do |chk|
					strsql = "select 1 from r_screenfields where pobject_code_scr =  '#{parseLineData["pobject_code_scr"]}'
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
		return parseLineData,err
	end

	###社内用　loca_codeは社外で使用できない。
	def proc_judge_check_workplace_loca_code_not_used_suppliers_custwhs parseLineData,item,index,screenCode
		if parseLineData[item] 
			case screenCode
			when /workplaces/
				strsql = %Q%
					select id from r_suppliers where loca_code_supplier = '#{parseLineData[item]}'
												and supplier_expiredate > current_date
						union
					select id from r_custrcvplcs where loca_code_custrcvplc = '#{parseLineData[item]}'
													and custrcvplc_expiredate > current_date
				%
			when /suppliers|custwhs|custrcvplcs/
				strsql = %Q%
					select id from r_workplaces where loca_code_workplace = '#{parseLineData[item]}'
											and workplace_expiredate > current_date%
			end
			if  ActiveRecord::Base.connection.select_value(strsql)
				err =  " #{parseLineData[item]}  cant not use  loca_code_workplace same time (suppliers or custwhs) "
			else
				err =  nil
			end
		end
		return parseLineData,err
	end

	
	def proc_judge_check_workplaces parseLineData,item,index,screenCode
		if parseLineData["loca_code_workplace"] 
			strsql = %Q%
				select id from r_workplaces where loca_code_workplace = '#{parseLineData[item]}'
											and workplace_expiredate > current_date
			%
			if  ActiveRecord::Base.connection.select_value(strsql)
				err = nil
			else
				err =  " #{parseLineData["loca_code_workplace"]} not workplaces"
			end
		end
		return parseLineData,err
	end
	
	def proc_judge_check_suppliers parseLineData,item,index,screenCode
    err = nil
		if parseLineData["loca_code_supplier"] 
			strsql = %Q%
				select id from r_suppliers where loca_code_supplier = '#{parseLineData["loca_code_supplier"]}'
											and supplier_expiredate > current_date
			%
			if  ActiveRecord::Base.connection.select_value(strsql)
				err = nil
			else
				err =  " #{parseLineData["loca_code_supplier"]} not suppliers"
			end
		end
		return parseLineData,err
	end

	
	def proc_judge_check_prdpur parseLineData,item,index,screenCode
    ### shelfnos_idの妥当性チェック prd:workingplaces pur:suppliers その他:制限なし
		case parseLineData["loca_code_supplier"]
		when "pur"
			if parseLineData[item] 
				strsql = %Q%
					select id from r_suppliers where loca_code_supplier = '#{parseLineData["loca_code_supplier"]}'
											and supplier_expiredate > current_date
				%
				if  ActiveRecord::Base.connection.select_value(strsql)
					err = nil
				else
					err =  " #{parseLineData["loca_code_supplier"]} not suppliers"
				end
			end
		when "prd"
			if parseLineData["loca_code_workplace"] 
				strsql = %Q%
					select id from r_workplaces where loca_code_workplace = '#{parseLineData["loca_code_workplace"]}'
												and workplace_expiredate > current_date
				%
				if  ActiveRecord::Base.connection.select_value(strsql)
					err = nil
				else
					err =  " #{parseLineData["loca_code_workplace"]} not workplaces"
				end
			end
    else
      err = nil
		end
    ###
    # classlist_code == "ITool","installationCharge","mold","apparatus" のときは opeitmsは作成できない
    ###
    if parseLineData["classlist_code"] =~ /ITool|installationCharge|mold|apparatus/ and err.nil?
      err =  " #{parseLineData["classlist_code"]} not allow to create opeitms"
    else
      err = nil
    end
		return parseLineData,err
	end

	def proc_judge_check_qty parseLineData,item,index,screenCode
		###　pur,prd schs,ords,insts,dlvs 数量増 ng
    ###pur,prdacts 条件による
	 	return parseLineData,nil   ###err= nil
	end	
	
	def proc_judge_check_consumtype parseLineData,item,index,screenCode
		classlist = ""
    err = nil
		case screenCode
		when /nditms/
			strsql = %Q&
						select c.code from itms i
									inner join classlists c	on i.classlists_id = c.id		
									where i.id = #{parseLineData["nditm_itm_id_nditm"]}
				&
			classlist = ActiveRecord::Base.connection.select_value(strsql)
		  case classlist
		    when "ITool","installationCharge","mold","apparatus"
			    parseLineData["nditm_consumtype"] = classlist
        else
          if parseLineData["opeitm_prdpur"] != "prd" and parseLineData["nditm_consumtype"] == "run"
            err =  "error 6   ---> prdpur must be 'prd' when consumtype = 'run' "
          end 
		  end
    end 
	 	return parseLineData,err   ###err= nil
	end	

	 def proc_judge_check_loca_code_to parseLineData,item,index,screenCode
	 	tblname =  screenCode.split("_")[1]
	 	id = parseLineData["#{tblname.chop}_id"]
    err = nil
	 	if id != ""  ###更新の時のみ　ords-->insts  insts -->actsに既にどれだけ変化しているか？
	 		sym = "loca_code_to"
	 		if parseLineData[sym] == ""
	 			err =  "error 7   --->#{sym} missing line:#{index} "
	 		else
	 			strsql = %Q%select sum(qty) from trngantts where orgtblname ='#{tblname}' and orgtblid = #{id} 
	 					 and  tblid = #{id} and tblname = '#{tblname}' group by orgtblname,orgtblid,tblname,tblid %
	 			trn_qty = ActiveRecord::Base.connection.select_value(strsql)
	 			chng_qty ||= 0.0  ###すでに次の状態に変化した数値
	 			strsql = %Q%select loca_code_to,#{tblname.chop}_qty from r_#{tblname} where id = #{id} %
	 			rec = ActiveRecord::Base.connection.select_one(strsql)
	 			if (chng_qty != rec["#{tblname.chop}_qty"] or rec["#{tblname.chop}_qty"]  != trn_qty) and 
	 					parseLineData[sym] != rec["loca_code_to"]
	 				checkstatus = false
	 				err =  "error 8   ---> loca_code_to must be >= #{rec["loca_code_to"]} line:#{index} "
				 else
					err =  nil
	 			end 
	 		end
	 	end
	 	return parseLineData,err
	 end	

	def proc_judge_check_already_used parseLineData,item,index,screenCode  ###あるidで登録されたcodeが別のテーブルに既に登録されているとき、codeの変更は不可
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
		if parseLineData["id"] and parseLineData["id"] != ""  ###変更の時 
      err = nil
			case screenCode
			when /itms/
			when /locas/
			when /pobjects/
				strsql = %Q%select code from pobjects where id = #{parseLineData["id"]}						
				%
				pobject_codes = ActiveRecord::Base.connection.select_values(strsql)
				pobject_codes.each do |pobject_code|
					if pobject_code != parseLineData["pobject_code"]
						strsql = %Q%select tfd.id from tblfields tfd
										inner join fieldcodes fld on tfd.fieldcodes_id  =  fld.id
										where pobjects_id_fld = #{parseLineData["id"]}  and tfd.expiredate > current_date
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
			if parseLineData["objecttype"] == "view"
				if parseLineData["code"] =~ /cust|prd|pur|shp/ and parseLineData["code"] =~ /schs$|ords$|oinsts$|replyinputs$|dlvs$|acts$|rets$/
					if parseLineData["code"].split("_")[0]  == "r"
					else
						err =  "error A  ---> view:#{code}   must be r_xxxxxxx 参照  "
					end
				end
			end
		end

		return parseLineData,err	
	end

	def proc_judge_check_same_loca_code_bill parseLineData,item,index,screenCode  ###MkInvoiveNoの時のみ
		err = nil
		return parseLineData,err
	end

	def proc_judge_check_duedate parseLineData,item,index,screenCode  ###
    err = nil
		tblnamechop = screenCode.split("_")[1].chop
		parent = {"starttime" => parseLineData[(tblnamechop+"_starttime")],"duedate" => parseLineData[(tblnamechop+"_duedate")]}
		nd = {"duration" => parseLineData["opeitm_duration"],"unitofduration" => parseLineData["opeitm_unitofduration"],"locas_id_shelfno" => 0 }
		parseLineData,err =  proc_field_starttime(tblnamechop,parseLineData,parent,nd)
		###return parseLineData.symbolize_keys,err
		return parseLineData,err
	end
	
	def proc_judge_check_supplierprice parseLineData,item,index,screenCode  ###M
		err = nil
		# if parseLineData["purord_contractprice"] =~ /[A-Z]|[a-z]/  ###数字の時マスター単価
		# 	return parseLineData,err
		# end
		ex_date = nil
		case screenCode
		when /pursch/
			strpur = "pursch"
			stramtsym = "pursch_amt_sch"
			strqtysym = "pursch_qty_sch"
			strtaxsym = "pursch_tax"
		when /purord/
			strpur = "purord"
			stramtsym = "purord_amt"
			strqtysym = "purord_qty"
			strtaxsym = "purord_tax"
		when /purinst/
			strpur = "purinst"
			stramtsym = "purinst_amt"
			strqtysym = "purinst_qty"
			strtaxsym = "purinst_tax"
		when /purdlv/
			strpur = "purdlv"
			stramtsym = "purdlv_amt"
			strqtysym = "purdlv_qty_stk"
			strtaxsym = "purdlv_tax"
		when /puract/
			strpur = "puract"
			stramtsym = "puract_amt"
			strqtysym = "puract_qty_stk"
			strtaxsym = "puract_tax"
		end	
		strcontractpricesym = "#{strpur}_contractprice"
		strmasterpricesym = "#{strpur}_masterprice"
		stropeitmsym = "#{strpur}_opeitm_id"
		strisudatesym = "#{strpur}_isuedate"
		strduedatesym = "#{strpur}_duedate"
		strpricesym = "#{strpur}_price"
		strtaxratesym = "#{strpur}_taxrate"
		strcrrsym = "#{strpur}_crr_id"
		strsuppliersym = "#{strpur}_supplier_id"
		case screenCode
		when /pursch|purord/
			case parseLineData[strcontractpricesym]
			when "1"
				ex_date = "expiredate >= to_date('#{parseLineData[strisudatesym]}','yyyy/mm/dd')" 
			when "2","3"
				ex_date = "expiredate >= to_date('#{parseLineData[strduedatesym]}','yyyy/mm/dd')"
			else
				ex_date = nil
				parseLineData[strcontractpricesym] = "C"
				parseLineData[strmasterpricesym] = parseLineData[strpricesym]  = parseLineData[stramtsym]  = 0
			end
		when /purdlv/ 
			ex_date = case parseLineData[strcontractpricesym] 
						when "1"
							"expiredate >= to_date('#{parseLineData["purdlv_depdate"]}','yyyy/mm/dd')"
						else
							nil
						end
		when /puract/ 
			ex_date = case parseLineData[strcontractpricesym] 
						when "1"
							"expiredate >= to_date('#{parseLineData["puract_rcptdate"]}','yyyy/mm/dd')"
						else
							nil
						end
						
		end 
			
		if ex_date
			strsql = %Q&
						select * from supplierprices 
									where suppliers_id = #{parseLineData[strsuppliersym]} and opeitms_id = #{parseLineData[stropeitmsym]}
									and maxqty >= #{parseLineData[strqtysym]}
									and minqty < #{parseLineData[strqtysym]}
									and #{ex_date}
									order by maxqty,expiredate limit 1
				&								
			price = ActiveRecord::Base.connection.select_one(strsql)	
			if price
				parseLineData[strpricesym] = parseLineData[strmasterpricesym] = price["price"].to_f
				###parseLineData["pursch_contractprice"] = supplier["contractprice"]
				parseLineData[stramtsym] = parseLineData[strqtysym].to_f * price["price"].to_f
				case parseLineData["itm_taxflg"]
				when "0","1","9"
					base_date =  parseLineData[strduedatesym]
				when "A"
					base_date =   parseLineData[strisudatesym]
				else
					base_date =  parseLineData[strduedatesym]
				end
				strsql = %Q&
							select taxrate from taxtbls where taxflg = '#{parseLineData["itm_taxflg"]}' 
														and expiredate >= to_date('#{base_date}','yyyy/mm/dd')
														order by expiredate limit 1
				&
				parseLineData[strtaxratesym] = ActiveRecord::Base.connection.select_value(strsql)
				parseLineData[strtaxratesym] ||= 0
				parseLineData[strtaxsym] = (parseLineData[stramtsym] * parseLineData[strtaxratesym].to_f / 100)
				if parseLineData[strcrrsym]
					strsql = %Q&
							select decimal from crrs where id = #{parseLineData[strcrrsym]}
					&
					decimal = ActiveRecord::Base.connection.select_value(strsql)
					case parseLineData["supplier_amtround"]  ###1:切り捨て　2:四捨五入 3:切り上げ
					when "1"
						parseLineData[stramtsym] = parseLineData[stramtsym].floor(decimal.to_i )
						parseLineData[strtaxsym] = (parseLineData[stramtsym] * parseLineData[strtaxratesym].to_f / 100).floor(decimal.to_i )
					when "2"
						parseLineData[stramtsym] = parseLineData[stramtsym].round(decimal.to_i + 1)
						parseLineData[strtaxsym] = (parseLineData[stramtsym] * parseLineData[strtaxratesym].to_f / 100).round(decimal.to_i )
					when "3"
						parseLineData[stramtsym] = parseLineData[stramtsym].ceil(decimal.to_i )
						parseLineData[strtaxsym] = (parseLineData[stramtsym] * parseLineData[strtaxratesym].to_f / 100).ceil(decimal.to_i )
					end
				else
					###
				end
			else
				parseLineData[strcontractpricesym] = "C"
				parseLineData[strmasterpricesym] = parseLineData[strpricesym]  = parseLineData[stramtsym]  = 0
				parseLineData[strtaxsym] = parseLineData[strtaxratesym]  = 0
			end
		else
			###parseLineData[strmasterpricesym] =  parseLineData[strpricesym]  = 0
			parseLineData[stramtsym] = parseLineData[strqtysym].to_f * parseLineData[strpricesym].to_f 
			case parseLineData["itm_taxflg"]
			when "0","1","9"
				base_date =  parseLineData[strduedatesym]
			when "A"
				base_date =   parseLineData[strisudatesym]
			else
				base_date =  parseLineData[strduedatesym]
			end
			strsql = %Q&
						select taxrate from taxtbls where taxflg = '#{parseLineData["itm_taxflg"]}' 
													and expiredate >= to_date('#{base_date}','yyyy/mm/dd')
													order by expiredate limit 1
			&
			parseLineData[strtaxratesym] = ActiveRecord::Base.connection.select_value(strsql)
			parseLineData[strtaxratesym] ||= 0
			parseLineData[strtaxsym] = (parseLineData[stramtsym] * parseLineData[strtaxratesym].to_f / 100)
			if parseLineData[strcrrsym]
				strsql = %Q&
						select decimal from crrs where id = #{parseLineData[strcrrsym]}
				&
				decimal = ActiveRecord::Base.connection.select_value(strsql)
				case parseLineData["supplier_amtround"]  ###1:切り捨て　2:四捨五入 3:切り上げ
				when "1"
					parseLineData[stramtsym] = parseLineData[stramtsym].floor(decimal.to_i )
					parseLineData[strtaxsym] = (parseLineData[stramtsym] * parseLineData[strtaxratesym].to_f / 100).floor(decimal.to_i )
				when "2"
					parseLineData[stramtsym] = parseLineData[stramtsym].round(decimal.to_i + 1)
					parseLineData[strtaxsym] = (parseLineData[stramtsym] * parseLineData[strtaxratesym].to_f / 100).round(decimal.to_i )
				when "3"
					parseLineData[stramtsym] = parseLineData[stramtsym].ceil(decimal.to_i )
					parseLineData[strtaxsym] = (parseLineData[stramtsym] * parseLineData[strtaxratesym].to_f / 100).ceil(decimal.to_i )
				end
			else
				###
			end
		end
		return parseLineData,err
	end

	def proc_judge_check_custprice parseLineData,item,index,screenCode  ###M
		err = nil
		case screenCode
		when /custschs/
			if parseLineData["custsch_contractprice"] =~ /[A-Z]|[a-z]/ and parseLineData["custsch_price"] != "" ###数字の時マスター単価
				return parseLineData,err
			end
			strsql = %Q&
						select * from custprices 
									where custs_id = #{parseLineData[":custsch_cust_id"]} and opeitms_id = #{parseLineData["custsch_opeitm_id"]}
									and crrs_id_custprice = #{parseLineData["custsch_crr_id"]}
									and maxqty >= #{parseLineData["custsch_qty_sch"]}
									and minqty < #{parseLineData["custsch_qty_sch"]}
									and #{case parseLineData["custsch_contractprice"]
											when "1"
												"expiredate >= to_date('#{parseLineData["custsch_isudate"]}','yyyy/mm/dd')" 
											when "2"
												"expiredate >= to_date('#{parseLineData["custsch_duedate"]}','yyyy/mm/dd')"
											when "3"
												"expiredate >= to_date('#{parseLineData["custsch_duedate"]}','yyyy/mm/dd')"
											else
												"expiredate >= to_date('#{parseLineData["custsch_isudate"]}','yyyy/mm/dd')"
											end											
											}
									order by maxqty,expiredate limit 1
			&
			price = ActiveRecord::Base.connection.select_one(strsql)
			if price
				parseLineData["custsch_price"] =  parseLineData["custsch_masterprice"] = price["price"].to_f
				parseLineData["custsch_amt_sch"] = parseLineData["custsch_qty_sch"].to_f * price["price"].to_f
				if parseLineData["custsch_crr_id"]
          ###税率の取得
          case parseLineData["itm_taxflg"]
          when "0","1","9"
            base_date =  parseLineData["custsch_duedate"]
          when "A"
            base_date =   parseLineData["custsch_isudate"]
          else
            base_date =  parseLineData["custsch_duedate"]
          end
          strsql = %Q&
              select taxrate from taxtbls where taxflg = '#{parseLineData["itm_taxflg"]}' 
                            and expiredate >= to_date('#{base_date}','yyyy/mm/dd')
                            order by expiredate limit 1
          &
          parseLineData["custsch_taxrate"] = ActiveRecord::Base.connection.select_value(strsql)
          parseLineData["custsch_taxrate"] ||= 0
          parseLineData["custsch_tax"] = (parseLineData["custsch_amt_sch"] * parseLineData["custsch_taxrate"].to_f / 100)
          ###通貨の小数点以下の桁数を取得
					strsql = %Q&
							select decimal from crrs where id = #{parseLineData["custsch_crr_id"]}
					&
					decimal = ActiveRecord::Base.connection.select_value(strsql)
					case parseLineData["cust_amtround"]  ###1:切り捨て　2:四捨五入 3:切り上げ
					when "1"
						parseLineData["custsch_amt_sch"] = parseLineData["custsch_amt_sch"].floor(decimal.to_i )
						parseLineData["custsch_tax"] = (parseLineData["custsch_amt_sch"] * parseLineData["custsch_taxrate"].to_f / 100).floor(decimal.to_i )
					when "2"
						parseLineData["custsch_amt_sch"] = parseLineData["custsch_amt_sch"].round(decimal.to_i )
						parseLineData["custsch_tax"] = (parseLineData["custsch_amt_sch"] * parseLineData["custsch_taxrate"].to_f / 100).round(decimal.to_i )
					when "3"
						parseLineData["custsch_amt_sch"] = parseLineData["custsch_amt_sch"].ceil(decimal.to_i )
						parseLineData["custsch_tax"] = (parseLineData["custsch_amt_sch"] * parseLineData["custsch_taxrate"].to_f / 100).ceil(decimal.to_i )
					else
						parseLineData["custsch_tax"] = (parseLineData["custsch_amt_sch"] * parseLineData["custsch_taxrate"].to_f / 100)
					end
				else
				end
			else
				parseLineData["custsch_price"] = parseLineData["custsch_masterprice"] = 0
				parseLineData["custsch_amt_sch"] = 0
				parseLineData["custsch_contractprice"] = "C"  ###C:マスター単価無
			end
		when /custords/
			if parseLineData["custord_contractprice"] =~ /[A-Z]|[a-z]/ and parseLineData["custord_price"] != "" ###数字の時マスター単価
				return parseLineData,err
			end
			strsql = %Q&
						select * from custprices 
									where custs_id = #{parseLineData["custord_cust_id"]} and opeitms_id = #{parseLineData["custord_opeitm_id"]}
									and crrs_id_custprice = #{parseLineData["custord_crr_id"]}
									and maxqty >= #{parseLineData["custord_qty"]}
									#{if parseLineData["custord_qty"].to_f == 0 then  "" else " and minqty < #{parseLineData["custord_qty"]}" end}
									and #{case parseLineData["custord_contractprice"]
											when "1"
												"expiredate >= to_date('#{parseLineData["custord_isudate"]}','yyyy/mm/dd')" 
											when "2"
												"expiredate >= to_date('#{parseLineData["custord_duedate"]}','yyyy/mm/dd')"
											when "3"
												"expiredate >= to_date('#{parseLineData["custord_duedate"]}','yyyy/mm/dd')"
											else
												"expiredate >= to_date('#{parseLineData["custord_isudate"]}','yyyy/mm/dd')"
											end											
											}
									order by maxqty,expiredate limit 1
			&
			price = ActiveRecord::Base.connection.select_one(strsql)
			if price
				parseLineData["custord_price"] =  parseLineData["custord_masterprice"] = price["price"].to_f
				parseLineData["custord_amt"] = parseLineData["custord_qty"].to_f * price["price"].to_f
				if parseLineData["custord_crr_id"]
					strsql = %Q&
							select decimal from crrs where id = #{parseLineData["custord_crr_id"]}
					&
					decimal = ActiveRecord::Base.connection.select_value(strsql)
					case parseLineData["cust_amtround"]  ###1:切り捨て　2:四捨五入 3:切り上げ
					when "1"
						parseLineData["custord_amt"] = parseLineData["custord_amt"].floor(decimal.to_i )
						parseLineData["custord_tax"] = (parseLineData["custord_amt"] * parseLineData["custord_taxrate"].to_f / 100).floor(decimal.to_i )
					when "2"
						parseLineData["custord_amt"] = parseLineData["custord_amt"].round(decimal.to_i )
						parseLineData["custord_tax"] = (parseLineData["custord_amt"] * parseLineData["custord_taxrate"].to_f / 100).round(decimal.to_i )
					when "3"
						parseLineData["custord_amt"] = parseLineData["custord_amt"].ceil(decimal.to_i )
						parseLineData["custord_tax"] = (parseLineData["custord_amt"] * parseLineData["custord_taxrate"].to_f / 100).ceil(decimal.to_i )
					end
				else
				end
			else
				parseLineData["custord_price"] = parseLineData["custord_masterprice"] = 0.0
				parseLineData["custord_amt"] = parseLineData["custord_tax"] = 0.0
				parseLineData["custord_contractprice"] = "C"  ###C:マスター単価無
			end
		when /custdlvs/  ###1:発注日ベース　2:仕入れ先きの出荷日ベース　3:検収ベース
			if params[:custdlv_contractprice]  == "2"  ###出荷日ベース　
				strsql = %Q&
							select * from custprices 
										where custs_id = #{parseLineData["custdlv_cust_id"]} and opeitms_id = #{parseLineData["custdlv_opeitm_id"]}
										and crrs_id_custprice = #{parseLineData["custdlv_crr_id"]}
										and maxqty >= #{parseLineData["custdlv_qty"]}
										and minqty < #{parseLineData["custdlv_qty"]}
										and  expiredate >= to_date('#{parseLineData["custdlv_depdate"]}','yyyy/mm/dd')
										order by maxqty,expiredate limit 1
				&
				price = ActiveRecord::Base.connection.select_one(strsql)
				if price
					decimal = parseLineData["crr_decimal"].to_i
					parseLineData["custdlv_amt"] = parseLineData["custdlv_qty"].to_f * price["price"].to_f
					case parseLineData["cust_amtround"]  ###1:切り捨て　2:四捨五入 3:切り上げ
					when "1"
						parseLineData["custdlv_amt"] = parseLineData["custdlv_amt"].floor(decimal + 1)
						parseLineData["custdlv_tax"] = (parseLineData["custdlv_amt"] * parseLineData["custdlv_taxrate"].to_f  / 100).floor(decimal)
					when "2"
						parseLineData["custdlv_amt"] = parseLineData["custdlv_amt"].round(decimal + 1)
						parseLineData["custdlv_tax"] = (parseLineData["custdlv_amt"] * parseLineData["custdlv_taxrate"].to_f  / 100).round(decimal + 1)
					when "3"
						parseLineData["custdlv_amt"] = parseLineData["custdlv_amt"].ceil(decimal + 1)
						parseLineData["custdlv_tax"] = (parseLineData["custdlv_amt"] * parseLineData["custdlv_taxrate"].to_f / 100).ceil(decimal + 1)
					end
				else
					parseLineData["custdlv_contractprice"] = "C"  ###C:マスター単価無
				end
			end
		when /custacts/  ###1:発注日ベース　2:仕入れ先きの出荷日ベース　3:検収ベース
			if parseLineData["custact_contractprice"]  == "3"
				strsql = %Q&
					select * from custprices 
							where custs_id = #{parseLineData["custact_cust_id"]} and opeitms_id = #{parseLineData["custact_opeitm_id"]}
							and crrs_id_custprice = #{parseLineData["custact_crr_id"]}
							and maxqty >= #{parseLineData["custact_qty"]}
							and minqty < #{parseLineData["custact_qty"]}
							and  expiredate >= to_date('#{parseLineData["custact_depdate"]}','yyyy/mm/dd')
							order by maxqty,expiredate limit 1
					&
				price = ActiveRecord::Base.connection.select_one(strsql)
				if price
			    decimal = parseLineData["crr_decimal"].to_i
				  parseLineData["custact_amt"] = parseLineData["custact_qty"].to_f * price["price"].to_f
				 	case parseLineData["cust_amtround"]  ###1:切り捨て　2:四捨五入 3:切り上げ
				 	when "1"
				  	parseLineData["custact_amt"] = parseLineData["custact_amt"].floor(decimal + 1)
						parseLineData["custact_tax"] = (parseLineData["custact_amt"] * parseLineData["custact_taxrate"].to_f / 100).floor(decimal )
			   	when "2"
						parseLineData["custact_amt"] = parseLineData["custact_amt"].round(decimal + 1)
						parseLineData["custact_tax"] = (parseLineData["custact_amt"] * parseLineData["custact_taxrate"].to_f / 100).round(decimal + 1)
			   	when "3"
						parseLineData["custact_amt"] = parseLineData["custact_amt"].ceil(decimal + 1)
						parseLineData["custact_tax"] = (parseLineData["custact_amt"] * parseLineData["custact_taxrate"].to_f / 100).ceil(decimal + 1)
			   	end
				else
				  parseLineData["custord_price"] = parseLineData["custord_masterprice"] = 0
				  parseLineData["custord_amt"] = 0
				  parseLineData["custact_contractprice"] = "C"  ###C:マスター単価無
				end
		  end
		end
		return parseLineData,err
	end

	def proc_judge_check_amt parseLineData,item,index,screenCode  ###M
		decimal = parseLineData["crr_decimal"].to_i 
		tblchop = screenCode.split("_")[1].chop
		err = nil
		case  screenCode 
		when /acts$|dlvs$/
			symqty = (tblchop + "_qty_stk")
			symamt = (tblchop + "_amt")
		when /schs$/ 
			symqty = (tblchop + "_qty_sch")
			symamt = (tblchop + "_amt_sch")
		else 
			symqty = (tblchop + "_qty")
			symamt = (tblchop + "_amt")
		end
		symprice = (tblchop + "_price")
		symtax = (tblchop + "_tax")
		symtaxrate = (tblchop + "_taxrate")
	 	parseLineData[symamt] = parseLineData[symqty].to_f * parseLineData[symprice].to_f
		case parseLineData["cust_amtround"]  ###1:切り捨て　2:四捨五入 3:切り上げ
		when "1"
		 parseLineData[symamt] = parseLineData[symamt].floor(decimal.to_i )
		 parseLineData[symtax] = (parseLineData[symamt] * parseLineData[symtaxrate].to_i / 100).floor(decimal.to_i )
		when "2"
		 parseLineData[symamt] = parseLineData[symamt].round(decimal.to_i )
		 parseLineData[symtax] = (parseLineData[symamt] * parseLineData[symtaxrate].to_i / 100).round(decimal.to_i )
		when "3"
		 parseLineData[symamt] = parseLineData[symamt].ceil(decimal.to_i )
		 parseLineData[symtax] = (parseLineData[symamt] * parseLineData[symtaxrate].to_i / 100).ceil(decimal.to_i )
		else
			parseLineData[symamt] = parseLineData[symamt].ceil(decimal.to_i )
			parseLineData[symtax] = (parseLineData[symamt] * parseLineData[symtaxrate].to_i / 100).ceil(decimal.to_i )
		end
		return parseLineData,err
	end

	def proc_judge_check_contractprice parseLineData,item,index,screenCode  ###M       
    err = nil
    case screenCode
    when /purords/
      if parseLineData["purord_confirm"] == "1"
        if parseLineData["purprd_contractprice"]  == "C"  ###単価未決
						err =  "error price  --->  price not decide"
        end
      end
    when /custords/
      if parseLineData["purprd_contractprice"]  == "C"  ###単価未決
						err =  "error price  --->  price not decide"
      end
    when /puracts/
      if parseLineData["puract_contractprice"]  == "C" or parseLineData["puract_contractprice"]  == "Z"  ###仮単価
						err =  "error price  --->  price not decide"
      end
    when /custacts/
      if parseLineData["custact_contractprice"]  == "C" or parseLineData["custact_contractprice"]  == "Z"  ###仮単価
          err =  "error price  --->  price not decide"
      end
    end 
		return parseLineData,err
  end

	def proc_judge_check_taxrate parseLineData,item,index,screenCode  ###MkInvoiveNoの時のみ
		err = nil
		case screenCode
		when /puracts/  ###再度求める
			case parseLineData["itm_taxflg"]
			when "A"
				if parseLineData["puract_sno_purord"] != "" and !parseLineData["puract_sno_purord"].nil?
					strsql = %Q&
						select isudate from purords where sno = #{parseLineData["puract_sno_purord"]}
					&
					base_date =  ActiveRecord::Base.connection.select_value(strsql)
				else  ###purordsを纏めるとき同一taxrateであること
					strsql = %Q&
						select * from linktbls where tblid = #{parseLineData["puract_id"]} and tblname = 'puracts'
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
								where link.srctblname = 'purords' and link.tblname = 'purinsts' and tblid = #{src["tblid"]}
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
									where link.srctblname = 'purords' and link.tblname = 'purinsts' and tblid = #{reply["tblid"]}
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
									where link.srctblname = 'purords' and link.tblname = 'purinsts' and tblid = #{dlv["tblid"]}
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
										where link.srctblname = 'purords' and link.tblname = 'purinsts' and tblid = #{reply["tblid"]}
								&
								base_date =  ActiveRecord::Base.connection.select_value(strsql)
							end
						end
					end
				end
			when "0","1","9"
				base_date =  parseLineData["puract_rcptdate"]
			else
				raise"taxflg error B paymants_id : #{parseLineData["paymets_id"]} LINE:#{__LINE__} "
			end
			strsql = %Q&
						select taxrate from taxtbls where taxflg = '#{parseLineData["itm_taxflg"]}' 
													and expiredate >= cast('#{base_date}' as date)
													order by expiredate limit 1
			&
			parseLineData["puract_taxrate"] = ActiveRecord::Base.connection.select_value(strsql)
		when /purrets/
			strsql = %Q&
				select taxrate from puracts where sno_puract = #{parseLineData["purret_sno_puract"]}
			&
			parseLineData["puract_taxrate"] = ActiveRecord::Base.connection.select_value(strsql)
		when /shpschs/  ###shpacts以外は求めて表示するだけ
			base_date =   parseLineData["shpsch_isudate"]
			strsql = %Q&
						select taxrate from taxtbls where taxflg = '#{parseLineData["itm_taxflg"]}' 
													and expiredate >= cast('#{base_date}' as date)
													order by expiredate limit 1
			&
			parseLineData["shpsch_taxrate"] = ActiveRecord::Base.connection.select_value(strsql)
		when /shpacts/  ###shpacts以外は求めて表示するだけ
			base_date =   parseLineData["shpact_rcptdate"]
			strsql = %Q&
						select taxrate from taxtbls where taxflg = '#{parseLineData["itm_taxflg"]}' 
													and expiredate >= cast('#{base_date}' as date)
													order by expiredate limit 1
			&
			parseLineData["shpsch_taxrate"] = ActiveRecord::Base.connection.select_value(strsql)
		when /custacts/ ###再度求める
			case parseLineData["itm_taxflg"]
			when "A"
				if parseLineData["custact_sno_custord"] != "" and !parseLineData["custact_sno_custord"].nil?
					strsql = %Q&
						select isudate from custords where sno = #{parseLineData["custact_sno_custord"]}
					&
					base_date =  ActiveRecord::Base.connection.select_value(strsql)
				else  ###purordsを纏めるとき同一taxrateであること
					strsql = %Q&
						select * from linkcusts where tblid = #{parseLineData["custact_id"]} and tblname = 'custacts'
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
										inner join linkcusts link on link.srctblid = ord.id
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
									where link.srctblname = 'purords' and link.tblname = 'purinsts' and tblid = #{dlv["tblid"]}
							&
							base_date =  ActiveRecord::Base.connection.select_value(strsql)
						end
					end
				end
			when "0","1","9"
				strsql = %Q&
					select saledate from custacts where  id = #{parseLineData["custact_id"]}
				&
				base_date =  ActiveRecord::Base.connection.select_value(strsql)
			else
				raise"taxflg error C 1 paymants_id : #{parseLineData["paymets_id"]} LINE:#{__LINE__} "
			end
			strsql = %Q&
						select taxrate from taxtbls where taxflg = '#{parseLineData["itm_taxflg"]}' 
													and expiredate >= cast('#{base_date}' as date)
													order by expiredate limit 1
			&
			parseLineData["custact_taxrate"] = ActiveRecord::Base.connection.select_value(strsql)

		when /custrets/
			strsql = %Q&
				select taxrate from custacts where sno_puract = #{parseLineData["custret_sno_custact"]}
			&
			parseLineData["custact_taxrate"] = ActiveRecord::Base.connection.select_value(strsql)
		when /custords/
			case parseLineData["itm_taxflg"]
			when "A"
				base_date =  parseLineData["custord_duedate"]
      when "0","1","9"
        base_date =  parseLineData["custord_isudate"]
			else
				base_date =  parseLineData["custord_isudate"]
			end
			strsql = %Q&
						select taxrate from taxtbls where taxflg = '#{parseLineData["itm_taxflg"]}' 
													and expiredate >= cast('#{base_date}' as date)
													order by expiredate limit 1
			&
			parseLineData["custord_taxrate"] = ActiveRecord::Base.connection.select_value(strsql)
		when /custschs/
			case parseLineData["itm_taxflg"]
			when "A"
				base_date =  parseLineData["custsch_duedate"]
			else
				base_date =  parseLineData["custsch_isudate"]
			end
			strsql = %Q&
						select taxrate from taxtbls where taxflg = '#{parseLineData["itm_taxflg"]}' 
													and expiredate >= cast('#{base_date}' as date)
													order by expiredate limit 1
			&
			parseLineData["custsch_taxrate"] = ActiveRecord::Base.connection.select_value(strsql)
		end
		return parseLineData,err
	end

	def proc_judge_check_mkprdpurord_code(parseLineData,item,index,screenCode)
    err = nil
		if parseLineData[item] == "dummy" or parseLineData[item] == ""
			return parseLineData, nil
		end
		###
		case item
		when /_org$/
			if parseLineData["mkprdpurord_orgtblname"] !~ /prd|pur/
				parseLineData[item.sub("code","name")] = " not select orgtblname "
				err = "#{parseLineData[item]}  not select org table "
				return parseLineData,err
			end
		when /_pare$/
			if parseLineData["mkprdpurord_paretblname"] !~ /prd|pur/
				parseLineData[item.sub("code","name")]  = " not select paretblname"
				err = "#{parseLineData[item]}  not select parent table "
				return parseLineData,err
			end
		end
		case item
		when /loca/
			strsql = %Q&
						select loca_name from r_locas where loca_code = '#{parseLineData[item]}'
						&
		when /itm/
			strsql = %Q&
						select itm_name from r_itms where itm_code = '#{parseLineData[item]}'
						&
		when /shelfno/
			strsql = %Q&
						select shelfno_name from r_chrgs where shelfno_code = '#{parseLineData[item]}'
						&
		when /chrg/
			strsql = %Q&
						select person_code_chrg from r_chrgs where persomn_code_chrg = '#{parseLineData[item]}'
						&
		when /sno/
			strsql = %Q&
						select sno from #{parseLineData["mkprdpurord_paretblname"]} where sno = '#{parseLineData[item]}'
						&
		end
		codeToName = ActiveRecord::Base.connection.select_value(strsql)
		if codeToName
			parseLineData[item.sub("code","name")] = codeToName
			err = nil
		else
			parseLineData[item.sub("code","name")] = "#{parseLineData[item]}  not found"
			err = " #{item}:#{parseLineData[item]}  not found"
		end
				
		return parseLineData,err
	end
	def proc_judge_check_seqnoOfTblfields(parseLineData,item,index,screenCode)
    err = nil
		case screenCode 
		when /tblfields/
			case parseLineData["pobject_code_tbl"]
			when /ords$|schs$/   ###tranganntsからxxxschs,mkprdpurordsからxxxords作成時利用
				case parseLineData["pobject_code_fld"]
				  when /starttime/ 
					  strsql = %Q&
							select tblfield_seqno from r_tblfields where pobject_code_tbl = '#{parseLineData["pobject_code_tbl"]}'
														and pobject_code_fld = 'duedate' 
					  &
					  duedate_seqno = ActiveRecord::Base.connection.select_value(strsql)
					  if duedate_seqno
						  if duedate_seqno < parseLineData["tblfield_seqno"]
							  return parseLineData, nil
						  else
							  err = "  seqno of starttime > seqno of duedate "
							  return parseLineData, nil
						  end
					  end
				  when /duedate/ 
					  strsql = %Q&
							select tblfield_seqno from r_tblfields where pobject_code_tbl = '#{parseLineData["pobject_code_tbl"]}'
														and pobject_code_fld = 'starttime' 
					    &
					  starttime_seqno = ActiveRecord::Base.connection.select_value(strsql)
					  if starttime_seqno
						  if starttime_seqno < parseLineData["tblfield_seqno"]
							  err = "  seqno of starttime > seqno of duedate "
							  return parseLineData,err 
						  else
							  return parseLineData, nil						
						  end
					  end
				    ###when /qty/
					  ###
					  ##  coding missing
					  ###
		    else
			    return parseLineData, nil 
				end
      else
        return parseLineData, nil
			end
		else
			return parseLineData, nil
		end
    return parseLineData, nil
	end
	###
	#
	### prd,pur ・・・schs,ords,insts,acts,retsのレコード作成　	
	def proc_schs_fields_making nd,parent,command_x  ###xxxschsの作成のみ
		err = false
		qty_require = 0
    message = ""
		nd["packqty"] =  if nd["packqty"].to_f == 0
									1
								else
									nd["packqty"].to_f
								end
		nd["consumunitqty"] = 1

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
			when "starttime"  ###稼働日計算  seqno.starttime > seqno.duedate > seqno.opeitms_id
				command_x = proc_field_starttime(tblnamechop,command_x,parent,nd)  ###qty_schで計算でする為
			when "depdate"  ###稼働日計算  seqno.starttime > seqno.duedate   ##shpxxxはmold,ITool以外は作成しない
				case tblnamechop
				when "shpest"
					command_x = proc_field_starttime(tblnamechop,command_x,parent,nd)  ###qty_schで計算でする為
				else
				end
			when "shelfnos_id" 
				command_x = field_shelfnos_id(tblnamechop,command_x,nd)
			when "shelfnos_id_to"
				command_x = field_shelfnos_id_to(tblnamechop,command_x,nd)
			when "chrgs_id"
				command_x = field_chrgs_id(tblnamechop,command_x,nd) 
			when "fcoperators_id"
				command_x = proc_field_fcoperators_id(tblnamechop,command_x,parent,nd) 
			when "duedate"  ###稼働日計算
        Rails.logger.debug " class:#{self} ,line:#{__LINE__},command_x:#{command_x}\n parent:#{parent} " if (nd["opeitms_id"]||="0") == "10007"
				command_x = proc_field_duedate(tblnamechop,command_x,parent,nd)
        Rails.logger.debug " class:#{self} ,line:#{__LINE__},command_x:#{command_x}\n parent:#{parent}  " if (nd["opeitms_id"]||="0") == "10007"
			when "endtime"  
				###command_x = field_endtime(tblnamechop,command_x,nd,parent)
			when "toduedate"  ###稼働日計算
				command_x = field_toduedate(tblnamechop,command_x,parent,nd)
			when "facilities_id"  
				command_x = proc_field_facilities_id(tblnamechop,command_x,parent,nd)
			when "qty_sch"   ### 
				command_x,qty_require = field_qty_sch(tblnamechop,command_x,parent,nd)
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
				command_x = field_prjnos_id(tblnamechop,command_x,parent,nd)
			when "expiredate"
				command_x = field_expiredate(tblnamechop,command_x,parent,nd)
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
    
		command_x["opeitm_processseq"] = nd["processseq"]
    command_x["opeitm_priority"] = nd["priority"]   
    command_x["opeitm_itm_id"] = nd["itms_id"]
    command_x["opeitm_unitofduration"] = nd["unitofduration"]

		case  tblnamechop 
		 		when /^pur/
		 			command_x["itm_taxflg"] = nd["taxflg"]
          strsql = %Q&select id from suppliers where  locas_id_supplier = #{nd["locas_id"]}&
		 			command_x["pursch_supplier_id"] =  ActiveRecord::Base.connection.select_value(strsql)
        when /^prd/
          ### prdschsにはworkplaces_idはない
		end
		return command_x
	end

	def field_locas_id_to tblnamechop,command_x,nd,parent
		command_x["#{tblnamechop}_loca_id_to"] = nd["locas_id_to"] ##
		return command_x
	end 

	def field_shelfnos_id tblnamechop,command_x,nd
	 	command_x["#{tblnamechop}_shelfno_id"] = nd["shelfnos_id"] ##
    command_x["shelfno_loca_id_shelfno"] = nd["locas_id"] ##
    return command_x
	end

	def field_shelfnos_id_to tblnamechop,command_x,nd
		command_x["#{tblnamechop}_shelfno_id_to"] = nd["shelfnos_id_to"] ##
		command_x["shelfno_loca_id_shelfno_to"] = nd["locas_id_to"] ##
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

	def proc_field_duedate tblnamechop,command_x,parent,nd
    message = ""
		case tblnamechop
		  when /^pur|^prd|^dymsch|^cust/
        if parent["shelfnos_id"]  == command_x["#{tblnamechop}_shelfno_id_to"]
          if parent["unitofduration"] == nd["unitofduration"]
            if parent["unitofduration"] == "Day "
              pstarttime = parent["starttime"].to_date
              case tblnamechop
                when /^prd|^shp|^dym|^run/
                    duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["shelfno_loca_id_shelfno_to"])
                when /^cust/
                    duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["#{tblnamechop}_cust_id"])
                when /^pur/
                    duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["#{tblnamechop}_supplier_id"])
              end
            else
              pstarttime = parent["starttime"].to_time  ###3600:1時間
              case tblnamechop
                when /^prd|^shp|^dym|^run/
                  duedate,message = calculate_working_time(tblnamechop,pstarttime,3600,"-",command_x["shelfno_loca_id_shelfno_to"])
                when /^cust/
                  duedate,message = calculate_working_time(tblnamechop,pstarttime,3600,"-",command_x["#{tblnamechop}_cust_id"])
                when /^pur/
                  duedate,message = calculate_working_time(tblnamechop,pstarttime,3600,"-",command_x["#{tblnamechop}_supplier_id"])
              end
            end
          else
            pstarttime = parent["starttime"].to_date
            case tblnamechop
              when /^prd|^shp|^dym|^run/
                  duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["shelfno_loca_id_shelfno_to"])
              when /^cust/
                    duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["#{tblnamechop}_cust_id"])
              when /^pur/
                  duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["#{tblnamechop}_supplier_id"])
            end
            if  nd["unitofduration"] == "Hour"
                case tblnamechop
                  when /^dym|^shp|^run/
                    strsql = %Q&select effectivetime from hcalendars where locas_id = #{command_x["shelfno_loca_id_shelfno_to"]}&
                    effectivetime = ActiveRecord::Base.connection.select_value(strsql)
                  when /^prd/
                    strsql = %Q&select effectivetime from hcalendars where locas_id =(
                                        select locas_id_calendar from workplaces where locas_id_workplace = #{command_x["shelfno_loca_id_shelfno"]})&
                    effectivetime = ActiveRecord::Base.connection.select_value(strsql)
                  when /^cust/
                    strsql = %Q&select effectivetime from hcalendars where locas_id = (
                                        select locas_id_cust from custs where id = #{command_x["#{tblnamechop}_cust_id"]})&
                    effectivetime = ActiveRecord::Base.connection.select_value(strsql)
                  when /^pur/
                    strsql = %Q&select effectivetime from hcalendars where locas_id = (
                                        select locas_id_calendar from suppliers where id = #{command_x["#{tblnamechop}_supplier_id"]})&
                    effectivetime = ActiveRecord::Base.connection.select_value(strsql)
                end
                if effectivetime.nil?
                   effectivetime = ActiveRecord::Base.connection.select_value(%Q&select effectivetime from hcalendars where locas_id = 0&)
                end
                hhmm = effectivetime.split(",")[-1].split(/-|~/)[0] + ":" + effectivetime.split(",")[-1].split(/-|~/)[1]
                duedate = (duedate.strftime("%Y-%m-%d") + " " + hhmm).to_time
            end
          end
        else
          if nd["locas_id_pare"] == command_x["shelfno_loca_id_shelfno_to"]
            if parent["unitofduration"] == nd["unitofduration"]
              if parent["unitofduration"] == "Day "
                pstarttime = parent["starttime"].to_date
                case tblnamechop
                  when /^prd|^shp|^dym|^run/
                    duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["shelfno_loca_id_shelfno_to"])
                  when /^cust/
                    duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["#{tblnamechop}_cust_id"])
                  when /^pur/
                    duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["#{tblnamechop}_supplier_id"])
                end
              else
                pstarttime = parent["starttime"].to_time
                case tblnamechop
                  when /^prd|^shp|^dym/
                    duedate,message = calculate_working_time(tblnamechop,pstarttime,3600,"-",command_x["shelfno_loca_id_shelfno_to"])
                  when /^cust/
                    duedate,message = calculate_working_time(tblnamechop,pstarttime,3600,"-",command_x["#{tblnamechop}_cust_id"])
                  when /^pur/
                    duedate,message = calculate_working_time(tblnamechop,pstarttime,3600,"-",command_x["#{tblnamechop}_supplier_id"])
                end     
              end
            else
              pstarttime = parent["starttime"].to_date
              if  nd["unitofduration"] == "Hour"
                  case tblnamechop
                  when /^shp|^dym|^run/
                    strsql = %Q&select effectivetime from hcalendars where locas_id = #{command_x["shelfno_loca_id_shelfno_to"]}&
                    effectivetime = ActiveRecord::Base.connection.select_value(strsql)
                  when /^prd/
                    strsql = %Q&select effectivetime from hcalendars where locas_id =(
                                        select locas_id_calendar from workplaces where locas_id_workplace = #{command_x["shelfno_loca_id_shelfno"]})&
                    effectivetime = ActiveRecord::Base.connection.select_value(strsql)
                  when /^cust/
                    strsql = %Q&select effectivetime from hcalendars where locas_id = (
                                        select locas_id_cust from custs where id = #{command_x["#{tblnamechop}_cust_id"]})&
                    effectivetime = ActiveRecord::Base.connection.select_value(strsql)
                  when /^pur/
                    strsql = %Q&select effectivetime from hcalendars where locas_id = (
                                        select locas_id_calendar from suppliers where id = #{command_x["#{tblnamechop}_supplier_id"]})&
                    effectivetime = ActiveRecord::Base.connection.select_value(strsql)
                  end
                  if effectivetime.nil?
                     effectivetime = ActiveRecord::Base.connection.select_value(%Q&select effectivetime from hcalendars where locas_id = 0&)
                  end
                  hhmm = effectivetime.split(",")[-1].split(/-|~/)[0] + ":" + effectivetime.split(",")[-1].split(/~|-/)[1]
                  duedate = (pstarttime.strftime("%Y-%m-%d") + " " + hhmm).to_time
               end
            end
          else
            strsql = %Q&select * from transports where locas_id_fm_transport = #{command_x["shelfno_loca_id_shelfno_to"]} 
                                            and  locas_id_to_transport = #{nd["locas_id_pare"]}  
                                            and expiredate > current_date
                                            order by priority desc &
            duration = ActiveRecord::Base.connection.select_one(strsql)
            if duration
              if duration["unitofduration"] == "Day " and duration["duration"].to_f == duration["duration"].to_i
                pstarttime = parent["starttime"].to_date
                case tblnamechop
                  when /^prd|^shp|^dym|^run/
                    duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,duration["duration"].to_i,"-",command_x["shelfno_loca_id_shelfno"])
                  when /^cust/
                    duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,duration["duration"].to_i,"-",command_x["#{tblnamechop}_cust_id"])
                  when /^pur/
                    duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,duration["duration"].to_i,"-",command_x["#{tblnamechop}_supplier_id"])
                end
              else
                pstarttime = parent["starttime"].to_time
                duration = duration["duration"].to_f * Constants::Whr * 3600
                case tblnamechop
                  when /^prd|^shp|^dym/
                    duedate,message = calculate_working_time(tblnamechop,pstarttime,duration,"-",command_x["shelfno_loca_id_shelfno"])
                  when /^cust/
                    duedate,message = calculate_working_time(tblnamechop,pstarttime,duration,"-",command_x["#{tblnamechop}_cust_id"])
                  when /^pur/
                    duedate,message = calculate_working_time(tblnamechop,pstarttime,duration,"-",command_x["#{tblnamechop}_supplier_id"]) 
                end
              end
            else  ###場所違いでtransportsが設定されていない時
              pstarttime = parent["starttime"].to_date
              case tblnamechop
                when /^prd|^shp|^dym|^run/
                    duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["shelfno_loca_id_shelfno"])
                when /^cust/
                      duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["#{tblnamechop}_cust_id"])
                when /^pur/
                    duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["#{tblnamechop}_supplier_id"])
              end
            end
          end
        end
		  when /^dvs|^shp/
        if nd["postprocessinglt"].to_f  > 0
          if nd["unitofduration"] == "Day " and nd["postprocessinglt"].to_f == nd["postprocessinglt"].to_i
              pduedate = parent["duedate"].to_date
              case tblnamechop
                when /^shp/
                  duedate,message = proc_calculate_working_day(tblnamechop,pduedate,tduration,"+",command_x["shelfno_loca_id_shelfno_to"])
                when /^dvs/
                  duedate,message = proc_calculate_working_day(tblnamechop,pduedate,tduration,"+",command_x["#{tblnamechop}_facilitie_id"]) 
              end
          else
            pduedate = parent["duedate"].to_time
            if nd["unitofduration"] == "Day "
              tduration = (nd["postprocessinglt"]).to_f * Constants::Whr * 3600
            else  
              tduration = (nd["postprocessinglt"]).to_f * 3600
            end
            case tblnamechop
              when /^shp/
                duedate,message = calculate_working_time(tblnamechop,pduedate,tduration,"+",command_x["shelfno_loca_id_shelfno_to"])
              when /^dvs/
                duedate,message = calculate_working_time(tblnamechop,pduedate,tduration,"+",command_x["#{tblnamechop}_facilitie_id"]) 
            end
          end
        else 
          if nd["unitofduration"] == "Day "
            duedate = parent["duedate"].to_date
          else
            duedate = parent["duedate"].to_time
          end
        end
		  when /^erc/
			  case command_x["#{tblnamechop}_processname"]   ###
			    when "postprocess"
            if nd["unitofduration"] == "Day " and nd["postprocessinglt"].to_f == nd["postprocessinglt"].to_i
              pstarttime = parent["duedate"].to_date
              duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,(nd["postprocessinglt"]).to_i,"+",command_x["#{tblnamechop}_fcoperators_id"])
            else
              pstarttime = parent["duedate"].to_time
              if nd["unitofduration"] == "Day "
                tduration = (nd["postprocessinglt"]).to_f * Constants::Whr * 3600
              else  
                tduration = (nd["postprocessinglt"]).to_f * 3600
              end
              duedate,message = calculate_working_time(tblnamechop,pstarttime,tduration,"+",command_x["#{tblnamechop}_fcoperator_id"])
            end
			    when "require"
            if nd["unitofduration"] == "Day " and nd["postprocessinglt"].to_f == nd["postprocessinglt"].to_i
              duedate = parent["duedate"].to_date
            else
              duedate = parent["duedate"].to_time
            end
			    when "changeover"
            if nd["unitofduration"] == "Day " and nd["postprocessinglt"].to_f == nd["postprocessinglt"].to_i
              duedate = parent["starttime"].to_date
            else
              duedate = parent["starttime"].to_time
            end
        end
    else
			  raise" class:#{self} ,line:#{__LINE__},tblname error:#{tblnamechop}s,command_x:#{command_x},nd:#{nd} "
		end
		command_x[(tblnamechop+"_duedate")]  = duedate.strftime("%Y-%m-%d %H:%M:%S")
		command_x[(tblnamechop+"_remark")]  = message
		return command_x
	end

	def field_endtime tblnamechop,command_x,nd,parent
		# endtime = parent["starttime"].to_time - 24*3600  ###稼働日
		# command_x["#{tblnamechop}_endtime"] = endtime.strftime("%Y-%m-%d %H:%M:%S")
		# return command_x
	end

	
	def field_toduedate tblnamechop,command_x,parent,nd  ###先行納品可能納期
		command_x["#{tblnamechop}_toduedate"] = command_x["#{tblnamechop}_toduedate"] = command_x["#{tblnamechop}_duedate"]
		return command_x
	end

	def proc_field_facilities_id tblnamechop,command_x,parent,nd
		strsql = %Q& select id,chrgs_id_facilitie from facilities  where itms_id = #{nd["itms_id"]}&
		facilitie = ActiveRecord::Base.connection.select_one(strsql)
		if facilitie
			command_x["#{tblnamechop}_facilitie_id"] = facilitie["id"]
			command_x["#{tblnamechop}_chrg_id"] = facilitie["chrgs_id_facilitie"]
		else
			raise " class:#{self} ,line:#{__LINE__} \n command_x:#{command_x} \n nd:#{nd} "
		end
		return command_x
	end

	def proc_field_starttime tblnamechop,command_x,parent,nd  ###parentはdvsschs,ercschsで使用
		message = ""
    if nd["unitofduration"] ==  "Hour"
      duration = (nd["duration"]||=1).to_i * 3600
      hourFlg = true 
    else
      if (nd["duration"]||=1).to_i != (nd["duration"]||=1).to_f  ###小数点がある場合は時間である。
        hourFlg = true 
        duration = (nd["duration"]||=1).to_f * Constants::Whr * 3600  ###Whr 壱日の労働時間
      else
        hourFlg = false
        duration = ((nd["duration"]||=1).to_i)   ###Whr 壱日の労働時間
      end
    end 
    if nd["unitofduration"] ==  "Hour" or hourFlg 
		    pstarttime =  parent["starttime"].to_time  ###dvsxxxs,ercxxxs,shpxxxsで使用。ercschsの親はdvsschs
		    pduedate =  parent["duedate"].to_time  ###dvsxxxs,ercxxxs,shpxxxsで使用。
		    cduedate = command_x["#{tblnamechop}_duedate"].to_time
		    case tblnamechop   ###insts ,reply,dlvs,actsではstarttimeはない
	    	  when /pur/
            starttime,message = calculate_working_time(tblnamechop,cduedate,duration,"-",command_x["#{tblnamechop}_supplier_id"])
	    	  when /dym/
            starttime,message = calculate_working_time(tblnamechop,cduedate,duration,"-",command_x["shelfno_loca_id_shelfno"])
		      when /cust/  ###前日準備
            starttime,message  = calculate_working_time("shpsch",cduedate,duration,"-",command_x["#{tblnamechop}_shelfno_id_fm"])
		      when /prd/
            if tblnamechop== "prdsch"
		 	        str_qty = command_x["prdsch_qty_sch"].to_f
            else
              str_qty = command_x["#{tblnamechop}_qty"].to_f
            end
			      strsql = %Q&
				              select nd.packqtyfacility,nd.durationfacility,itm.classlist_code,op.duration 
					                  from nditms nd
					                  inner join (select i.id itms_id,c.code classlist_code from itms i
										                        inner join classlists c	on i.classlists_id = c.id
													                  where c.code in('apparatus') )								
					                        itm on itm.itms_id = nd.itms_id_nditm
					                  inner join opeitms op on op.id = nd.opeitms_id
					                  where op.itms_id = #{nd["itms_id"]} and op.processseq = #{nd["processseq"]} 
					                  and  op.priority = 999 ---nd["itms_id"],nd["processseq"] = child itms
					              &
			      appas = ActiveRecord::Base.connection.select_all(strsql)
			      appas.each do |appa|	###複数の装置のLTがある時
				      if  (appa["durationfacility"].to_f) > 0   ###装置のlt
					      if (appa["packqtyfacility"].to_f) > 0  ###nd["duration"].nil? --> tbl=dymschs&opeitms無
                  tduration = appa["durationfacility"].to_f*qty_sch/appa["packqtyfacility"].to_f    
					      else
                  tduration = appa["durationfacility"].to_f
					      end
				      end
              if nd["unitofduration"] ==  "Hour"
                tduration = tduration * 3600
              else
                tduration = tduration * Constants::Whr * 3600
              end
              
              if tduration > duration
                duration = tduration
              end
            end  
            starttime,message = calculate_working_time(tblnamechop,cduedate,duration,"-",command_x["shelfno_loca_id_shelfno"])
		      when /^dvs/  ###親はprdschs
            # strsql = %Q&
				    #           select f.shelfnos_id from facilities f 
            #                 inner join #{tblnamechop}s d on d.facilities_id = f.id
            #                 where d.id = #{command_x["id"]} &
			      # shelfnos_id = ActiveRecord::Base.connection.select_value(strsql)
            if nd["unitofduration"] ==  "Hour"
              duration = (nd["changeoverlt"]||=0).to_f * 3600
            else
              duration = (nd["changeoverlt"]||=0).to_f * Constants::Whr * 3600
            end
            if (nd["changeoverlt"]||=0).to_f == 0
              starttime = pstarttime
            else
              starttime,message = calculate_working_time(tblnamechop,pstarttime,duration,"-",command_x["#{tblnamechop}_facilitie_id"])
            end
		      when /^shp/ ###親はprdschs 工具・金型
            if nd["unitofduration"] ==  "Hour"
              duration = (nd["changeoverlt"]||=0).to_f * 3600
            else
              duration = (nd["changeoverlt"]||=0).to_f * Constants::Whr * 3600
            end
            starttime,message = calculate_working_time(tblnamechop,pstarttime,duration,"-",command_x["shelfno_loca_id_shelfno_fm"])
		      when /^run/ ###親はprdschs 工具・金型
            if nd["unitofduration"] ==  "Hour"
              duration = (nd["changeoverlt"]||=0).to_f * 3600
            else
              duration = (nd["changeoverlt"]||=0).to_f * Constants::Whr * 3600
            end
            starttime,message = calculate_working_time(tblnamechop,pstarttime,duration,"-",command_x["shelfno_loca_id_shelfno"])
		      when "ercsch","ercord" ###親はdvsschs
			      case command_x["#{tblnamechop}_processname"]   ###親はdvsschs
			        when "changeover"
                starttime,message = calculate_working_time(tblnamechop,pstarttime,(nd["changeoverlt"]||=0).to_f*3600,"-",command_x["#{tblnamechop}_fcoperator_id"])
			        when "require"
				        starttime =  pstarttime 
			        when "postprocess"
				        starttime = pduedate 
              else
                raise" class:#{self} ,line:#{__LINE__},processname error command_x:#{command_x} "
			      end
        else
            raise" class:#{self} ,line:#{__LINE__},  tblnamechop error command_x:#{command_x} "
        end
    else
		    pstarttime =  parent["starttime"].to_date  ###ercschsの親はdvsschs
		    pduedate =  parent["duedate"].to_date
		    cduedate = command_x["#{tblnamechop}_duedate"].to_date
		    case tblnamechop   ###insts ,reply,dlvs,actsではstarttimeはない
	    	  when /^pur/
            starttime,message = proc_calculate_working_day(tblnamechop,cduedate,duration,"-",command_x["#{tblnamechop}_supplier_id"])
		      when /^mnf/
            starttime,message = proc_calculate_working_day(tblnamechop,cduedate,duration,"-",command_x["shelfno_loca_id_shelfno"])
		      when /^cust/
            starttime,message = proc_calculate_working_day(tblnamechop,cduedate,duration,"-",command_x["#{tblnamechop}_cust_id"])
		      when /^prd/
            if tblnamechop== "prdsch"
		 	        str_qty = command_x["prdsch_qty_sch"].to_f
            else
              str_qty = command_x["#{tblnamechop}_qty"].to_f
            end
			      strsql = %Q&  ---装置のLTがある時
				              select nd.packqtyfacility,nd.durationfacility,itm.classlist_code,op.duration,op.shelfnos_id_opeitm shelfnos_id 
					                  from nditms nd
					                  inner join (select i.id itms_id,c.code classlist_code from itms i
										                        inner join classlists c	on i.classlists_id = c.id
													                  where c.code in('apparatus') )								
					                        itm on itm.itms_id = nd.itms_id_nditm
					                  inner join opeitms op on op.id = nd.opeitms_id
					                  where op.itms_id = #{nd["itms_id"]} and op.processseq = #{nd["processseq"]} 
					                  and  op.priority = 999 ---nd["itms_id"],nd["processseq"] = child itms
					              &
			      appas = ActiveRecord::Base.connection.select_all(strsql)
			      appas.each do |appa| 		
				      if  (appa["durationfacility"].to_f) > 0   ###装置のlt
					      if (appa["packqtyfacility"].to_f) > 0  ###nd["duration"].nil? --> tbl=dymschs&opeitms無
                  tduration = (appa["durationfacility"].to_f)*qty_sch/(appa["packqtyfacility"].to_f).ceil    
					      else
                  tduration = (appa["durationfacility"].to_f).ceil  
					      end
				      else
                tduration = (appa["duration"]||=1).to_f.ceil  ###prdschs.opeitms_id.duration
				      end
			        if tduration > duration
				        duration = tduration
			        end
			      end
            starttime,message = proc_calculate_working_day(tblnamechop,cduedate,duration,"-",command_x["shelfno_loca_id_shelfno"])
		      when /^dvs/  ###親はprdschs
            starttime,message = proc_calculate_working_day(tblnamechop,pstarttime,(nd["changeoverlt"]).to_f.ceil,"-",command_x["#{tblnamechop}_facilitie_id"])
		      when /^shp/ ###親はprdschs 工具・金型
            starttime,message = proc_calculate_working_day(tblnamechop,pstarttime,(nd["changeoverlt"]).to_f.ceil,"-",command_x["shelfno_loca_id_shelfno_fm"])
		      when /^dym|^run/ ###親はprdschs 工具・金型
            starttime,message = proc_calculate_working_day(tblnamechop,pstarttime,(nd["changeoverlt"]).to_f.ceil,"-",command_x["shelfno_loca_id_shelfno"])
		      when "ercsch","ercord" ###親はdvsschs
			      case command_x["#{tblnamechop}_processname"]   ###親はdvsschs
			        when "changeover"
                starttime,message = proc_calculate_working_day(tblnamechop,pstarttime,(nd["changeoverlt"]).to_f.ceil,"-",command_x["#{tblnamechop}_fcoperator_id"])
			        when "require"
				        starttime =  pstarttime 
			        when "postprocess"
				        starttime = pduedate 
              else
                raise "class:#{self} ,line:#{__LINE__},processname error:#{command_x["#{tblnamechop}_processname"]},command_x:#{command_x} "
			      end
          else
              raise" class:#{self} ,line:#{__LINE__},  tblnamechop error:#{tblnamechop} command_x:#{command_x} "
		    end
    end
		case tblnamechop
		 	when /^shp/
		  		command_x["#{tblnamechop}_depdate"] = starttime.strftime("%Y-%m-%d") + " " + parent["starttime"].to_time.strftime("%H:%M:%S")		
		 	else
		  		command_x[(tblnamechop+"_starttime")] =  (starttime.strftime("%Y-%m-%d %H:%M:%S") )
		end
		# end
    command_x[(tblnamechop+"_remark")] = message 
		return command_x
	end

	def field_chrgs_id tblnamechop,command_x,nd ### seq_noは　chrgs_id > custs_id,suppliers_id,workplaces_idであること
		if command_x["#{tblnamechop}_chrg_id"].nil? or  command_x["#{tblnamechop}_chrg_id"] == ""
				case tblnamechop
				when /^cust/
					strsql = %Q&
							select chrgs_id_cust chrgs_id from custs where id = #{command_x["#{tblnamechop}_cust_id"] }
					&
				when /^pur/
				 	strsql = %Q&
				 			select chrgs_id_supplier chrgs_id ,locas_id_calendar from suppliers 
									where locas_id_supplier = #{nd["locas_id"]}
				 	&
				 when /^prd|^dvs/
				 	strsql = %Q&
				 			select chrgs_id_workplace chrgs_id from workplaces 
							 		where locas_id_workplace = #{nd["locas_id"]}
				 	&
				when /^erc/
				 	strsql = %Q&
				 			select chrgs_id_fcoperator  chrgs_id from fcoperators
									where itms_id_fcoperator = #{nd["itms_id"]} order by priority desc
				 	&
				when /^dymsch/
					strsql = %Q&
							select 0 chrgs_id 
					&
				else
					raise"get chrgs_id error  class:#{self}, line:#{__LINE__} ,tblnamechop:#{tblnamechop}"
				end
        chrg = ActiveRecord::Base.connection.select_one(strsql)
				command_x["#{tblnamechop}_chrg_id"] = chrg["chrgs_id"]
		end
		return command_x
	end	

	def proc_field_fcoperators_id(tblnamechop,command_x,parent,nd) 
    case tblnamechop
    when "ercsch"
		  strsql = %Q&  ---予定されている担当者
				select fc.id ,fc.itms_id_fcoperator  ,fc.chrgs_id_fcoperator from fcoperators fc
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
						where fc.itms_id_fcoperator = #{nd["itms_id"]} and fc.expiredate > current_date
		    &
		  ids = ActiveRecord::Base.connection.select_all(strsql)
		  if ids.to_ary.size > 0
			  str = ""
			  ids.each do |id|
				str << "'" + id["id"] + "',"
			  end
			  strsql = %Q&
				  select fc.id  ,fc.chrgs_id_fcoperator from fcoperators fc
						where fc.id not in (#{str.chop}) and fc.itms_id_fcoperator = #{ids[0]["itms_id_fcoperator"]} 
            and expiredate > current_date                     order by fc.priority desc&
			  fcoperator = ActiveRecord::Base.connection.select_one(strsql)
        ###　空きがなければ主担当を採用
			  if fcoperator.nil?
          strsql = %Q&
            select fc.id ,fc.chrgs_id_fcoperator from fcoperators fc
						where fc.itms_id_fcoperator = #{nd["itms_id"] } and fc.expiredate > current_date
              order by fc.priority desc&
          fcoperator = ActiveRecord::Base.connection.select_one(strsql)
			  end
		  else
			  strsql = %Q&
				  select fc.id ,fc.chrgs_id_fcoperator from fcoperators fc
						where f.itms_id_fcoperator = #{nd["itms_id"] } and fc.expiredate > current_date
            order by fc.priority desc&
			  fcoperator = ActiveRecord::Base.connection.select_one(strsql)
		  end
		  if fcoperator
			  command_x["#{tblnamechop}_fcoperator_id"] = fcoperator["id"]
		  else
			  raise " class:#{self} ,line:#{__LINE__}, can not get fcoperators_id \n nd:#{nd} \n command_x:#{command_x} "
		  end
    when "ercord"
			strsql = %Q&
				  select fc.id  ,fc.chrgs_id_fcoperator from fcoperators fc
						where fc.itms_id_fcoperator = #{nd["itms_id"] } and fc.expiredate > current_date 
            order by fc.priority desc&
			fcoperator = ActiveRecord::Base.connection.select_one(strsql)
		  if fcoperator
			  command_x["#{tblnamechop}_fcoperator_id"] = fcoperator["id"]
		  else
        raise " class:#{self} ,line:#{__LINE__},tblnamechop:#{tblnamechop},\n command_x:#{command_x},\n nd:#{nd} "
		  end
    else
      raise " class:#{self} ,line:#{__LINE__},tblnamechop:#{tblnamechop} error\n command_x:#{command_x},\n nd:#{nd} "
    end
		return command_x
	end

	def field_qty_sch tblnamechop,command_x,parent,nd
		qty_require = proc_cal_qty_sch(parent["qty_handover"].to_f,
										nd["chilnum"].to_f,nd["parenum"].to_f,
										nd["packqty"].to_f,nd["consumminqty"].to_f,nd["consumchgoverqty"].to_f)
		command_x["#{tblnamechop}_qty_sch"]  = qty_require
		return command_x,qty_require
	end	

	def proc_cal_qty_sch(parent_qty,chilnum,parenum,packqty,consumminqty,consumchgoverqty)
    parenum == 0 ? parenum = 1 : parenum = parenum
    packqty == 0 ? packqty = 1 : packqty = packqty
		qty_require = parent_qty * chilnum / parenum
		#consumunitqty等については親に合わせて計算する。
		qty_require = (qty_require /  packqty).ceil *  packqty
		if consumminqty > qty_require
			qty_require = consumminqty  ###最小消費数
		end	
		qty_require += consumchgoverqty   ###段取り時に余分に使用(消費)される数量
	end

	def field_price_amt_tax_contractprice tblnamechop,command_x
		case tblnamechop
		when /pur/  ###supplierprices
			command_x,err = proc_judge_check_supplierprice(command_x,"",0,"r_#{tblnamechop}s")
		when  /shp/  ###shpprices
		end
		###  command_x = PriceLib.proc_price_amt(tblnamechop,command_x)
		return command_x
	end

	def proc_field_sno(tblnamechop,isudate,id)  ###id=tbl.id
		(proc_snolist["#{tblnamechop}s"]||="") + (isudate||=Time.now).to_time.strftime("%y")[1] + 
					["0","1","2","3","4","5","6","7","8","9","A","B","C"][(isudate||=Time.now).to_time.strftime("%m").to_i]  + format('%04d', id) 
	end

	def proc_field_cno tblnamechop,id 
		 format('%07d', id)
	end

	def proc_field_gno(tblnamechop,id)
		(proc_gnolist["#{tblnamechop}s"]||="") + format('%07d', id) 
	end	

	def field_prjnos_id tblnamechop,command_x,parent,nd
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
	
	def field_expiredate tblnamechop,command_x,parent,nd
		if command_x["#{tblnamechop}_expiredate"].nil? or command_x["#{tblnamechop}_expiredate"] == ""
			command_x["#{tblnamechop}_expiredate"] =  Constants::EndDate  
		end
		return command_x
	end
	
	def proc_billord_exists(lineData)  ###既に請求書発行済?
		false
	end

  def proc_calculate_working_day(tblnamechop,base_date,calculate_day,plusminus,calendars_id)
    ###base_date (型:Date からcalculate_day日後の稼働日を考慮して計算する  
    ###dayofweek = "0":日曜日,"1":月曜日,"2":火曜日,"3":水曜日,"4":木曜日,"5":金曜日,"6":土曜日　休日がarrayで渡される
    ###holidays = "mmdd"でarray 型で休日を渡す
    ###workingday = "yyyymmdd"でarray 型で稼働日を渡す
    ###calendars_id prd,shp:locas_id, pur:suppliers_id, cust: 客先:custs_id , 出荷:shelfnos_id_fm
    message = ""
    case tblnamechop
      when /^pur/
            strsql = %Q&
                    select dayofweek,holidays,workingday from hcalendars 
                        where locas_id = (select locas_id_calendar from suppliers 
                                                where id = #{calendars_id}    ---calendars_id = suppliers_id
                                                and expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date))
                        order by expiredate limit 1
              &
            calendar = ActiveRecord::Base.connection.select_one(strsql)
            if calendar.nil?
              message = "suppliers_id:#{calendars_id}  calendar missing"
              strsql = %Q&
                      select dayofweek,holidays,workingday from hcalendars 
                          where locas_id = 0
                          order by expiredate limit 1
                &
              calendar = ActiveRecord::Base.connection.select_one(strsql)
              if calendar.nil?
                raise"error calendar missing \n supplier:#{calendars_id}  calendar missing"
              end
            end
      when /^prd/
            strsql = %Q&
                select h.dayofweek,h.holidays,workingday from hcalendars h
                    where h.locas_id = (select locas_id_calendar from workplaces w
                                         --- inner join shelfnos s on w.locas_id_workplace = s.locas_id_shelfno
                                       ---   where s.id = #{calendars_id})   --- calendars_id = shelfnos_id
                                          where w.locas_id_workplace = #{calendars_id})   --- calendars_id = shelfnos_id
                                          and h.expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date)
                        order by h.expiredate limit 1
            &
            calendar = ActiveRecord::Base.connection.select_one(strsql)
            if calendar.nil?
              message = "workplaces shelfnos_id:#{calendars_id}  calendar missing"
              strsql = %Q&
                      select dayofweek,holidays,workingday from hcalendars 
                          where locas_id = 0
                          order by expiredate limit 1
                &
              calendar = ActiveRecord::Base.connection.select_one(strsql)
              if calendar.nil?
                raise"error calendar missing \n workplaces locas_id:#{calendars_id}  calendar missing"
              end
            end
      when /^cust/
                strsql = %Q&
                        select dayofweek,holidays,workingday from hcalendars 
                            where locas_id = (select locas_id_cust from custs s 
                                               where s.id = #{calendars_id})  
                            and expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date)
                            order by expiredate limit 1
                &
                calendar = ActiveRecord::Base.connection.select_one(strsql)
                if calendar.nil?
                  message = "shipping shelfnos_id:#{calendars_id}  calendar missing"
                  strsql = %Q&
                          select dayofweek,holidays,workingday from hcalendars 
                              where locas_id = 0
                              order by expiredate limit 1
                    &
                  calendar = ActiveRecord::Base.connection.select_one(strsql)
                  if calendar.nil?
                    raise"error calendar missing \n locas_id = 0  calendar missing"
                  end
                end
      when /^dvs/
            strsql = %Q&  ---休日を求める　facilitycalendars:日別カレンダーから年次カレンダーを求める
                    select * from facilitycalendars f 
                          where f.facilities_id = #{calendars_id}
                           and f.targetdate > current_date
										        and f.expiredate > current_date and f.effectivestarttime = ''
										        and not exists(select 1 from facilitycalendars f2  where f.facilities_id = f2.facilities_id 
														                and f.targetdate  = f2.targetdate  and f2.effectivestarttime != '')										
									          order by f.targetdate 
            &
            timeCalendars = ActiveRecord::Base.connection.select_all(strsql)
            if timeCalendars.length == 0
              message = "facilities_id:#{calendars_id}  facilities calendar missing"
              strsql = %Q&
                      select dayofweek,holidays,workingday from hcalendars 
                          where locas_id = 0
                          order by expiredate limit 1
                &
              calendar = ActiveRecord::Base.connection.select_one(strsql)
            else
              calendar = {"workingday" => [],"dayofweek" => [],"holidays" => []}
              timeCalendars.each do |clndr|
                calendar["holidays"] << clndr["targetdate"].to_date.strftime("%m%d")
              end              
            end
      when /^erc/
            strsql = %Q&
                    select p.* from chrgs c 
			                  inner join personcalendars p  on p.persons_id = c.persons_id_chrg
			                  where p.persons_id = #{calendars_id} 		and p.expiredate > current_date 
            &
            calendar = ActiveRecord::Base.connection.select_one(strsql)
            if calendar.nil?
              message = "persons_id:#{calendars_id}  persons calendar missing"
              strsql = %Q&
                      select dayofweek,holidays,workingday from hcalendars 
                          where locas_id = 0
                          order by expiredate limit 1
                &
              calendar = ActiveRecord::Base.connection.select_one(strsql)
            end
      when /^shp|^run/ 
        strsql = %Q&
            select h.dayofweek,h.holidays,workingday from hcalendars h
                ---where h.locas_id = (select locas_id_shelfno from shelfnos s
                ---                     where s.id = #{calendars_id})   --- calendars_id = shelfnos_id
                where h.locas_id =  #{calendars_id}
                and h.expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date)
                    order by h.expiredate limit 1
        &
        calendar = ActiveRecord::Base.connection.select_one(strsql)
        if calendar.nil?
            strsql = %Q&
             select dayofweek,holidays,workingday from hcalendars 
               where locas_id = 0
               and expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date)
               order by expiredate limit 1
              &
            calendar = ActiveRecord::Base.connection.select_one(strsql)
              if calendar.nil?
                raise"error calendar missing "
              end
        end
      else
        strsql = %Q&
         select dayofweek,holidays,workingday from hcalendars 
           where locas_id = 0
           and expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date)
           order by expiredate limit 1
          &
        calendar = ActiveRecord::Base.connection.select_one(strsql)
          if calendar.nil?
            raise"error calendar missing "
          end
    end
    workingday = calendar["workingday"]
    dayofweek = calendar["dayofweek"]
    holidays = calendar["holidays"]
    degcnt = 0
    if calculate_day < 0
      if plusminus == "+"
        plusminus = "-"
      else
        plusminus = "+"
      end
      calculate_day = calculate_day * -1
    end  
    until calculate_day < 0
        if !workingday.include?(base_date.strftime("%Y%m%d"))&&(dayofweek.include?(base_date.wday.to_s)||holidays.include?(base_date.strftime("%m%d")))
          degcnt += 1
          raise"LINE:#{__LINE__},degcnt:#{degcnt},base_date:#{base_date},workingday:#{workingday},dayofweek:#{dayofweek},holidays:#{holidays}"  if degcnt > 1000
        else
          calculate_day -= 1
          return base_date,message if calculate_day < 0
        end
        if  plusminus == "-"
          base_date = base_date - 1
        else
          base_date = base_date + 1
        end
    end
    return base_date,message
  end

  def calculate_working_time(tblnamechop,base_date,calculate_time,plusminus,calendars_id)  ###custsには対応しない
    ###base_date (型:Time)からcalculate_time時間後の稼働時間を考慮して計算する 
    ###calculate_time (型:numeric) 移動時間 秒数
    ###plusminus "+" or "-" で加算または減算する
    ###dayofweek = "0":日曜日,"1":月曜日,"2":火曜日,"3":水曜日,"4":木曜日,"5":金曜日,"6":土曜日　休日がarrayで渡される
    ###holidays = "mmdd"でarray 型で休日を渡す
    ###workingday = "yyyymmdd"でarray 型で稼働日を渡す
    ## return base_date(型TTime)
    message = ""
    calendars = []
    calendar = {}
    ###
    # 日別カレンダーか年次カレンダーの判断
    case tblnamechop
      when /^pur/
        strsql = %Q&
                 select * from calendars 
                        where locas_id = (select locas_id_calendar from suppliers 
                                                where id = #{calendars_id}    ---calendars_id = suppliers_id
                                                and expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date)
                        and targetdate  #{if plusminus == "-" then "<=" else ">=" end} cast('#{base_date.strftime("%Y-%m-%d")}' as date))
                        order by targetdate #{if plusminus == "-" then "desc" else "asc" end},
                                  effectivestarttime #{if plusminus == "-" then "desc" else "asc" end}  
                    &
          calendars = ActiveRecord::Base.connection.select_all(strsql)
          if calendars.length == 0          
              strsql = %Q&
                    select dayofweek,holidays,workingday,effectivetime  from hcalendars 
                        where locas_id = (select locas_id_calendar from suppliers 
                                      where id = #{calendars_id}    ---calendars_id = suppliers_is
                        and expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date))
                        order by expiredate limit 1
              &
              calendar = ActiveRecord::Base.connection.select_one(strsql)
              if calendar.nil?
                message = "suppliers_id:#{calendars_id}  calendar missing"
                strsql = %Q&
                      select dayofweek,holidays,workingday,effectivetime  from hcalendars 
                          where locas_id = 0
                          order by expiredate limit 1
                &
                calendar = ActiveRecord::Base.connection.select_one(strsql)
                if calendar.nil?
                  raise"error calendar missing \n supplier:#{calendars_id}  calendar missing"
                end
              end
          end
      when /^prd/
        strsql = %Q&
                 select * from calendars c
                        where c.locas_id = (select locas_id_calendar from workplaces w
                                                ---  inner join shelfnos s on w.locas_id_workplace = s.locas_id_shelfno
                                                 --- where s.id = #{calendars_id}    --- calendars_id = shelfnos_id
                                                  where w.locas_id_workplace = #{calendars_id}    --- 
                                                  and w.expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date))
                        and c.targetdate #{if plusminus == "-" then "<=" else ">=" end} cast('#{base_date.strftime("%Y-%m-%d")}' as date)
                        order by c.targetdate #{if plusminus == "-" then "desc" else "asc" end},
                                  c.effectivestarttime #{if plusminus == "-" then "desc" else "asc" end}  
                    &
          calendars = ActiveRecord::Base.connection.select_all(strsql)
          if calendars.length == 0          
              strsql = %Q&
                    select dayofweek,holidays,workingday,effectivetime  from hcalendars 
                        where locas_id = (select locas_id_calendar from workplaces w
                                           --- inner join shelfnos s on w.locas_id_workplace = s.locas_id_shelfno
                                            where w.locas_id_workplace = #{calendars_id})   ---
                        and hcalendars.expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date)
                        order by hcalendars.expiredate limit 1
            &
            calendar = ActiveRecord::Base.connection.select_one(strsql)
            if calendar.nil?
              message = "workplaces locas_id:#{calendars_id}  calendar missing"
              strsql = %Q&
                      select dayofweek,holidays,workingday,effectivetime  from hcalendars 
                          where locas_id = 0
                          order by expiredate limit 1
                &
              calendar = ActiveRecord::Base.connection.select_one(strsql)
              if calendar.nil?
                raise"error calendar missing \n workplaces shelfnos_id:#{calendars_id}  calendar missing"
              end
            end
          end
      when /^dvs/
            strsql = %Q&  
                    select * from facilitycalendars f 
                          where f.facilities_id = #{calendars_id}
                           and f.targetdate #{if plusminus == "-" then "<=" else ">=" end} cast('#{base_date.strftime("%Y-%m-%d")}' as date)
                           and f.expiredate > current_date 								
									         order by targetdate #{if plusminus == "-" then "desc" else "asc" end},
                                    effectivestarttime #{if plusminus == "-" then "desc" else "asc" end}
            &
            calendars = ActiveRecord::Base.connection.select_all(strsql)
            if calendars.length == 0
              message = "facilities_id:#{calendars_id}  facilities calendar missing"
              strsql = %Q&
                      select dayofweek,holidays,workingday,effectivetime  from hcalendars 
                          where locas_id = 0
                          order by expiredate limit 1
                &
              calendar = ActiveRecord::Base.connection.select_one(strsql)
            end
      when /^erc/
            strsql = %Q&
                    select p.* from chrgs c 
			                  inner join personcalendars p  on p.persons_id = c.persons_id_chrg
			                  where p.persons_id = #{calendars_id} 		and p.expiredate > current_date 
                        order by targetdate,effectivestarttime #{if plusminus == "-" then "desc" else "asc" end}  
            &
            calendars = ActiveRecord::Base.connection.select_all(strsql)
            if calendars.length == 0
              message = "persons_id:#{calendars_id}  persons calendar missing"
              strsql = %Q&
                      select dayofweek,holidays,workingday,effectivetime from hcalendars 
                          where locas_id = 0
                          order by expiredate limit 1
                &
              calendar = ActiveRecord::Base.connection.select_one(strsql)
            end
      when /^shp/
              strsql = %Q&
                     select * from calendars c
                            where c.locas_id = #{calendars_id}  
                                ---(select locas_id_shelfno from shelfnod s
                                ---                      where s.id = #{calendars_id}    --- calendars_id = shelfnos_id
                                ---                      and w.expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date))
                            and c.targetdate #{if plusminus == "-" then "<=" else ">=" end} cast('#{base_date.strftime("%Y-%m-%d")}' as date)
                            order by targetdate #{if plusminus == "-" then "desc" else "asc" end},
                                      effectivestarttime #{if plusminus == "-" then "desc" else "asc" end}  
                        &
              calendars = ActiveRecord::Base.connection.select_all(strsql)
              if calendars.length == 0          
                  strsql = %Q&
                        select dayofweek,holidays,workingday,effectivetime  from hcalendars 
                            where locas_id = (select locas_id_shelfno from shelfnod s
                                                      where s.id = #{calendars_id}    --- calendars_id = shelfnos_id
                                                      and w.expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date))
                            and c.targetdate = cast('#{base_date.strftime("%Y-%m-%d")}' as date)
                            order by expiredate limit 1
                &
                calendar = ActiveRecord::Base.connection.select_one(strsql)
                if calendar.nil?
                  message = "workplaces locas_id:#{calendars_id}  calendar missing"
                  strsql = %Q&
                          select dayofweek,holidays,workingday,effectivetime  from hcalendars 
                              where locas_id = 0
                              order by expiredate limit 1
                    &
                  calendar = ActiveRecord::Base.connection.select_one(strsql)
                  if calendar.nil?
                    raise"error calendar missing \n workplaces shelfnos_id:#{calendars_id}  calendar missing"
                  end
                end
              end
      else
            strsql = %Q&
             select dayofweek,holidays,workingday,effectivetime  from hcalendars 
               where locas_id = 0
               and expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date)
               order by expiredate limit 1
              &
            calendar = ActiveRecord::Base.connection.select_one(strsql)
              if calendar.nil?
                raise"error calendar missing "
              end
    end
    degcnt = 0
    if calendars.length == 0  ###日別カレンダーがない場合は年次カレンダーを使用する
      workingday = calendar["workingday"]
      dayofweek = calendar["dayofweek"]
      holidays = calendar["holidays"]
      wkHour = 0
      calendar["effectivetime"].split(",").each do |effectivetime|  ###effectivetime = "09:00-17:00"又は"09:00-12:00","13:00-17:00"
        wkHour = effectivetime.split(/-|~/)[1].to_time - effectivetime.split(/-|~/)[0].to_time 
      end
      until calculate_time < 0
        if !workingday.include?(base_date.strftime("%Y%m%d"))&&(dayofweek.include?(base_date.wday.to_s)||holidays.include?(base_date.strftime("%m%d")))
          degcnt += 1
          raise"LINE:#{__LINE__},degcnt:#{degcnt},base_date:#{base_date},workingday:#{workingday},dayofweek:#{dayofweek},holidays:#{holidays}"  if degcnt > 1000
        else
          if  calculate_time < wkHour
            if  plusminus == "-"
              base_date = base_date - 86400 ###1日分の秒数を引く
              calendar["effectivetime"].split(",").reverse_each do |eff|  ###effectivetime = "09:00-17:00"又は"09:00-12:00","13:00-17:00"
                if  calculate_time  > (eff.split(/-|~/)[1].to_time - eff.split(/-|~/)[0].to_time) 
                    calculate_time -=  (eff.split(/-|~/)[1].to_time - eff.split(/-|~/)[0].to_time)
                    next
                else
                  base_date = (base_date.strftime("%Y-%m-%d") + " " + eff.split(/-|~/)[1] + ":00").to_time.ago(calculate_time) 
                end
              end
            else
              base_date = base_date + 86400  ###1日分の秒数を足す
              calendar["effectivetime"].split(",").each do |eff|  ###effectivetime = "09:00-17:00"又は"09:00-12:00","13:00-17:00"
                if  calculate_time  > (eff.split(/-|~/)[1].to_time - eff.split(/-|~/)[0].to_time) 
                    calculate_time -=  (eff.split(/-|~/)[1].to_time - eff.split(/-|~/)[0].to_time) 
                    next
                else
                    base_date = (base_date.strftime("%Y-%m-%d") + " " + eff.split(/-|~/)[0] + ":00").to_time.since(calculate_time) 
                end
              end
            end
            return base_date,message 
          else
            calculate_time -= wkHour
          end
        end
        if  plusminus == "-"
          base_date = base_date - 86400  ###1日分の秒数を引く
        else
          base_date = base_date + 86400
        end
      end
    else ###日別カレンダーがある場合は日別カレンダーを使用する
      if plusminus == "-"
        calendars.each do |calendar|
          if calendar["effectivestarttime"].to_time.nil? or calendar["effectivestarttime"].to_time.nil?
            degcnt += 1
            raise"LINE:#{__LINE__},degcnt:#{degcnt},base_date:#{base_date},calendar:#{calendar}"  if degcnt > 1000
            next
          else
            if  base_date.to_date == calendar["targetdate"].to_date
                if base_date.strftime("%H:%M") < calendar["effectivestarttime"] or base_date.strftime("%H:%M") > calendar["effectiveendtime"]
                  next
                else
                  wkHour =  calendar["effectivestarttime"].to_time - base_date.strftime("%H:%M").to_time
                  if calculate_time < wkHour
                    base_date = (calendar["targetdate"].to_time.strftime("%Y-%m-%d") + " " + calendar["effectivestarttime"] + ":00").to_time.since(calculate_time) 
                    break
                  else
                    calculate_time -= wkHour
                    next
                  end
                end
            else
              wkHour = calendar["effectiveendtime"].to_time - calendar["effectivestarttime"].to_time
              if calculate_time < wkHour
                base_date = (calendar["targetdate"].to_time.strftime("%Y-%m-%d") + " " + calendar["effectivestarttime"] + ":00").to_time.since(calculate_time) 
                break
              else
                calculate_time -= wkHour
                next
              end
            end
          end
        end
      else
        calendars.each do |calendar|
          Rails.logger.debug " class:#{self} ,line:#{__LINE__},base_date:#{base_date},calculate_time:#{calculate_time}\n calendar:#{calendar}"  
          if calendar["effectivestarttime"].to_time.nil? or calendar["effectivestarttime"].to_time.nil?
            degcnt += 1
            raise"LINE:#{__LINE__},degcnt:#{degcnt},base_date:#{base_date},calendar:#{calendar}"  if degcnt > 1000
            next
          else
            if  base_date.to_date == calendar["targetdate"].to_date
                if base_date.strftime("%H:%M") < calendar["effectivestarttime"] or base_date.strftime("%H:%M") > calendar["effectiveendtime"]
                  next
                else
                  wkHour = base_date.strftime("%H:%M").to_time - calendar["effectivestarttime"].to_time
                  if calculate_time < wkHour
                    base_date = (calendar["targetdate"].to_time.strftime("%Y-%m-%d") + " " + calendar["effectivestarttime"] + ":00").to_time.since(calculate_time) 
                    break
                  else
                    calculate_time -= wkHour
                    next
                  end
                end
            else
              wkHour = calendar["effectiveendtime"].to_time - calendar["effectivestarttime"].to_time
              if calculate_time < wkHour
                base_date = (calendar["targetdate"].to_time.strftime("%Y-%m-%d") + " " + calendar["effectivestarttime"] + ":00").to_time.since(calculate_time) 
                break
              else
                calculate_time -= wkHour
                next
              end
            end
          end
        end
      end
    end
    return base_date,message
  end
    
	def proc_snolist   ###reqparams[:segment] = ["trn_org"]の対象でもある。
		{"purschs"=>"PS","purords"=>"PO","purinsts"=>"PH","purdlvs"=>"PV","puracts"=>"PA","dymschs"=>"DY",
			"purreplyinputs"=>"PL","prdreplyinputs"=>"ML",
			"prdschs"=>"MS","prdords"=>"MO","prdinsts"=>"MH","prdacts"=>"MA","prdrets"=>"MR",
			"dvsschs"=>"DS","dvsords"=>"DO","dvsacts"=>"DA",
			"billschs"=>"BS","billords"=>"BO","billinsts"=>"BH","billacts"=>"BA","billrets"=>"BR",
			"payschs"=>"YS","payords"=>"YO","payinsts"=>"YH","payacts"=>"YA","payrets"=>"YR",
			"custschs"=>"CS","custords"=>"CO","custinsts"=>"CJ","custdlvs"=>"CV","custacts"=>"CA","custrets"=>"CR",
			"ercschs"=>"ES","ercords"=>"EO","ercinsts"=>"EJ","ercacts"=>"CA",
			"custordheads"=>"CH","custactheads"=>"CB",
			"shpests"=>"ST","shpschs"=>"SS","shpords"=>"SO","shpinsts"=>"SH","shpacts"=>"SA","shprets"=>"SR",
      "rejections" =>"RJ","movacts" => "MV"}
	end

	
	def proc_gnolist   ###reqparams[:segment] = ["trn_org"]の対象でもある。
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

  def proc_judge_check_opeitms? parseLineData,item,index,screenCode
    err = nil
    if screenCode =~ /nditms/
      if parseLineData["itm_code_nditm"] and parseLineData["itm_code_nditm"] != ""
        strsql = %Q%
          SELECT * FROM itms WHERE code = '#{parseLineData["itm_code_nditm"]}' and expiredate > current_date
        %
        itm = ActiveRecord::Base.connection.select_one(strsql)
        if itm.nil?
            err = " itms #{parseLineData["itm_code_nditm"]} not found"
		        return parseLineData,err
        else
          strsql = %Q%
                      SELECT code FROM classlists WHERE id = #{itm["classlists_id"]}  and expiredate > current_date
                    %
          classlist = ActiveRecord::Base.connection.select_value(strsql)
          case classlist
            when /ITool|installationCharge|ship|outsourcing|mold/  ###道具、設置費、出荷、外注、金型opeitms必要ない
		          return parseLineData,err
            when /apparatus/  ###装置はopeitms必要ないがfacilitiesは必要
                  strsql = %Q%
                      SELECT id FROM facilities WHERE itms_id = #{itm["id"]}  and expiredate > current_date
                    %
                facilitie = ActiveRecord::Base.connection.select_value(strsql)
                if facilitie.nil?
                  err = " facilities for apparatus #{parseLineData["itm_code_nditm"]} not found"
                end
                return parseLineData,err
          else
            if parseLineData["processseq_nditm"] or parseLineData["processseq_nditm"] == ""
              if parseLineData["processseq_nditm"] == "999"
		            return parseLineData,err  ###dymschs とする
              else
                strsql = %Q%
                            SELECT 1 FROM opeitms WHERE itms_id = #{itm["id"]} and processseq = #{parseLineData["processseq_nditm"]} and expiredate > current_date
                      %
                opeitm = ActiveRecord::Base.connection.select_value(strsql)
                if opeitm.nil?
                  err = " opeitms #{parseLineData["itm_code_nditm"]} not found"
		              return parseLineData,err
                else
		              return parseLineData,err  ###ok
                end
              end
            else
		            return parseLineData,err  ###未入力
            end
          end
        end
      else
		    return parseLineData,err  ###未入力
      end
    else
      err = "logic error: proc_judge_check_opeitms?  screenCode:#{screenCode} not nditms"
		  return parseLineData,err  
    end
  end  ###proc_judge_check_opeitms?
end   ##module
