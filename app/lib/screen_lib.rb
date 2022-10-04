
# -*- coding: utf-8 -*-
#ScreenLib 
# 2099/12/31を修正する時は　2100/01/01の修正も
module ScreenLib 
	extend self
	class ScreenClass
		attr_reader :screenCode
		
		def initialize(params)
			@screenCode = params[:screenCode]
			$proc_grp_code =  ActiveRecord::Base.connection.select_value("select usrgrp_code from r_persons where person_email = '#{$email}'")
			if $proc_grp_code.nil?
				p "add person to his or her email "
				raise   ### 別画面に移動する　後で対応
			end
			if params[:screenCode] and (params[:req] != "import" or params[:req] !~ /confirm/)
				proc_create_grid_editable_columns_info(params)
			end
		end
		def grid_columns_info
			@grid_columns_info
		end
		def screenCode
			@screenCode
		end
		
		def proc_create_grid_editable_columns_info(params) 
			req = params[:req]
			@grid_columns_info = Rails.cache.fetch('screenfield'+$proc_grp_code+screenCode+req) do
				@grid_columns_info = {}
				###  ダブルコーティション　「"」は使用できない。 
				sqlstr = "select * from  func_get_screenfield_grpname('#{$email}','#{screenCode}')"
				screenwidth = 0
				select_fields = ""
				select_row_fields = ""
				gridmessages_fields = ""  ### error messages
				init_where_info = {:filtered => ""}
				dropdownlist = {}
				sort_info = {}
				nameToCode = {}
				columns_info = []
				hiddenColumns = []
				if (req=='inlineedit7'|| req=="inlineadd7" )
					columns_info << {:Header=>"confirm",
									:accessor=>"confirm",
									:id=>"",
									:className=>"checkbox",
									:width=>50,
									:filter=>""
									}
					columns_info << {:Header=>"confirm_gridmessage",
									:accessor=>"confirm_gridmessage",
									:id=>"",
									:className=>"gridmessage",
									:filter=>""
									}
					hiddenColumns << "confirm_gridmessage"
				end		
				ActiveRecord::Base.connection.select_all(sqlstr).each_with_index do |i,cnt|			
					select_fields = 	select_fields + 
											case i["screenfield_type"]
											when "timestamp(6)" 
												%Q% to_char(#{i["pobject_code_sfd"]},'yyyy/mm/dd hh24:mi') #{i["pobject_code_sfd"]}% + " ,"
											when "date" 
												%Q% to_char(#{i["pobject_code_sfd"]},'yyyy/mm/dd ') #{i["pobject_code_sfd"]}% + " ,"
											else 												
												i["pobject_code_sfd"] + " ,"
											end		
					select_row_fields = 	select_row_fields + i["pobject_code_sfd"] + " ,"
					if 	nameToCode[i["screenfield_name"].to_sym].nil?   ###nameToCode excelから取り込むときの表示文字からテーブル項目名への変換テーブル
						nameToCode[i["screenfield_name"].to_sym] = i["pobject_code_sfd"]
					else
						if i["pobject_code_sfd"].split("_")[0] == screenCode.split("_")[1].chop
							nameToCode[i["screenfield_name"].to_sym] = i["pobject_code_sfd"]  ###nameがテーブル項目しか登録されてない。
						end
					end
					@grid_columns_info[:nameToCode] = nameToCode
					columns_info << {:Header=>"#{i["screenfield_name"]}",
									:id=>"#{i["screenfield_id"]}",
									:accessor=>"#{i["pobject_code_sfd"]}",
									:filter=>case i["screenfield_type"]
												when "select" 
													"includes"
												when /check/
													""
												else 
													"text"
												end	,
									###widthが120以下だと右の境界線が消える。	
									:width => if i["screenfield_width"].to_i < 80 then 80 else  i["screenfield_width"].to_i end,
									:className=>if  (req==="inlineedit7" or req==="inlineadd7") and 
													(i["screenfield_editable"] === "1" or i["screenfield_editable"] === "2" or i["screenfield_editable"] === "3") 
														if  i["screenfield_indisp"] === "1" or i["screenfield_indisp"] === "2" ###必須はyupでも
															case i["screenfield_type"] 
															when "select"
																	"SelectEditableRequire"
															when "check"
																	"CheckEditableRequire"
															when "numeric"
																	"EditableRequire Numeric "
															else
																	"EditableRequire"
															end
														else
															case i["screenfield_type"] 
															when "select"
																	"SelectEditable"
															when "check"
																	"CheckEditable"
															when "numeric"
																	"Editable Numeric "
															else
																	"Editable"
															end
														end
												else	
														case i["screenfield_type"]
															when "select"
																"SelectNonEditable"
															when "check"
																"CheckNonEditable"
															when "numeric"
																"NonEditable Numeric "
															else
																"NonEditable"
														end
												end	
									}
					if ((req==="inlineedit7" or req==="inlineadd7") and i["screenfield_editable"] === "1") or
						(req==="inlineedit7"  and i["screenfield_editable"] === "2") or
						( req==="inlineadd7" and i["screenfield_editable"] === "3") 
						columns_info << {:Header=>"#{i["screenfield_name"]}_gridmessage",
										:accessor=>"#{i["pobject_code_sfd"]}_gridmessage",
										:id=>"#{i["pobject_code_sfd"]}_gridmessage",
										:className=>"gridmessages",
										:filter=>""
									}
						gridmessages_fields << %Q% '' #{i["pobject_code_sfd"]}_gridmessage,%	
						hiddenColumns << %Q%#{i["pobject_code_sfd"]}_gridmessage%	
					end																
					init_where_info[i["pobject_code_sfd"].to_sym] = i["screenfield_type"]	
					if cnt == 0
								init_where_info[:filtered] = (i["screen_strwhere"]||="")
								@grid_columns_info[:pageSizeList] = []
								i["screen_rowlist"].split(",").each do |list|
									@grid_columns_info[:pageSizeList]  <<  list.to_i
								end
								if i["screen_strorder"] 
									sort_info[:default] = i["screen_strorder"]
								end	
				 	end
					if  i["screenfield_type"] == "select" and i["screenfield_hideflg"] == "0"
						if i["screenfield_edoptvalue"] 
							if i["screenfield_edoptvalue"] =~ /\:/
								dropdownlist[i["pobject_code_sfd"].to_sym] = i["screenfield_edoptvalue"]
							else
								Rails.logger.debug " screenfield_type = selectではedoptvalueにxxx:yyy,aaa:bbbは必須 "
								Rails.logger.debug " screenfield_type = selectではedoptvalueにxxx:yyy,aaa:bbbは必須 "
								p " selectではedoptvalueにxxx:yyy,aaa:bbbは必須  "
								raise
							end
						else
							Rails.logger.debug "  screenfield_type = selectではedoptvalueにxxx:yyy,aaa:bbbは必須 "
							Rails.logger.debug "  screenfield_type = selectではedoptvalueにxxx:yyy,aaa:bbbは必須 "
							p " selectではedoptvalueにxxx:yyy,aaa:bbbは必須  "
							raise
						end
					end	
					if   i["screenfield_hideflg"] == "0" 
						screenwidth = screenwidth +  i["screenfield_width"].to_i
					else
						hiddenColumns << i["pobject_code_sfd"]
					end
				##end
				end
				@grid_columns_info[:columns_info] = columns_info
				@grid_columns_info[:hiddenColumns] = hiddenColumns
				@grid_columns_info[:fetch_check] = {}
				@grid_columns_info[:fetch_check][:fetchCode] = YupSchema.proc_create_fetchCode   screenCode
				@grid_columns_info[:fetch_check][:checkCode] = YupSchema.proc_create_checkCode   screenCode
				@grid_columns_info[:fetch_data] = {}

				dropdownlist.each do |key,val|
					tmpval="["
					val.split(",").each do  |drop|
						tmpval << %Q%{"value":"#{drop.split(":")[0]}","label":"#{drop.split(":")[1]}"},%
					end
					dropdownlist[key] = tmpval.chop + "]"
				end	
				@grid_columns_info[:dropdownlist] = dropdownlist
				if sort_info[:default]
					ary_select_fields = select_fields.split(',')
					sort_info = CtlFields.proc_detail_check_strorder sort_info,ary_select_fields
				end	
				@grid_columns_info[:init_where_info] = init_where_info
				@grid_columns_info[:sort_info] = sort_info	
				@grid_columns_info[:screenwidth] = screenwidth	
				if gridmessages_fields.size > 1
					select_fields << gridmessages_fields
				end
				@grid_columns_info[:select_fields] = select_fields.chop
				@grid_columns_info[:select_row_fields] = select_row_fields.chop
				@grid_columns_info
			end
		end
	
		def create_filteredstr(params) 
			setParams = params.dup
			if params[:filtered] 
				init_where_info = grid_columns_info[:init_where_info]  ###r_screenからの　where
				if (init_where_info[:filtered]).size > 0
					 where_str =   "  where " +	 init_where_info[:filtered] + "    and "			
				else
					 where_str = "  where "	 
				end	
				params[:filtered].each  do |fil|  ##xparams gridの生
					ff = JSON.parse(fil)
					###ff = JSON.parse(strjson)
					next if ff["value"].nil?
					next if ff["value"] == ""
					next if ff["value"] =~ /'/
					next if ff["value"] == "null"
					###init_where_info[i["pobject_code_sfd"].to_sym] 
	      			case init_where_info[ff["id"].to_sym]  ### where_info[i["pobject_code_sfd"].to_sym] = i["screenfield_type"]	
					when nil
						next
		 			when /numeric/
						if ff["value"] =~ /^<=/  or ff["value"] =~ /^>=/ or ff["value"]=~ /^!=/
							next if ff["value"].size == 2 
							next if ff["value"][2..-1] !~ /^[0-9]+$|^\.[0-9]+$|^[0-9]+\.[0-9]+$/
							where_str << " #{ff["id"]} #{ff["value"][0..1]} #{ ff["value"][2..-1]}      AND "   
						else
							if ff["value"] =~ /^</   or  ff["value"] =~ /^>/	or  ff["value"] =~ /^=/
								next if ff["value"].size == 1 
								next if ff["value"][1..-1] !~ /^[0-9]+$|^\.[0-9]+$|^[0-9]+\.[0-9]+$/
								where_str << " #{ff["id"]}  #{ff["value"][0]}  #{ ff["value"][1..-1]}      AND "   
							else	
								next if ff["value"]  !~ /^[0-9]+$|^\.[0-9]+$|^[0-9]+\.[0-9]+$/
								where_str << " #{ff["id"]} = #{ff["value"]}     AND "
							end	
						end	
				  	when /^date|^timestamp/
						ff["value"] = ff["value"].gsub("-","/")
		      			case  ff["value"].size
			         	when 4
					 		where_str << "to_char(#{ff["id"]},'yyyy') = '#{ff["value"]}'      							 AND "
			         	when 5
					 		where_str << "to_char(#{ff["id"]},'yyyy') #{ff["value"][0]} '#{ff["value"][1..-1]}'          AND "  if  ( ff["value"]=~ /^</   or ff["value"] =~ /^>/ )
					 	when 6
					 		where_str << "to_char(#{ff["id"]},'yyyy')  #{ff["value"][0..1]} '#{ff["value"][2..-1]}'      AND "  if   (ff["value"] =~ /^<=/  or ff["value"] =~ /^>=/ )
			         	when 7
					 		where_str << "to_char(#{ff["id"]},'yyyy/mm') = '#{ff["value"]}'                              AND "  if Date.valid_date?(ff["value"].split("/")[0].to_i,ff["value"].split("/")[1].to_i,01)
			         	when 8
					 		where_str << "to_char(#{ff["id"]},'yyyy/mm') #{ff["value"][0]} '#{ff["value"][1..-1]}'       AND "  if Date.valid_date?(ff["value"][1..-1].split("/")[0].to_i,ff["value"].split("/")[1].to_i,01)  and ( ff["value"] =~ /^</   or  ff["value"] =~ /^>/ )
                	 	when 9
					 		where_str << "to_char(#{ff["id"]},'yyyy/mm')  #{ff["value"][0..1]} '#{ff["value"][2..-1]}'   AND "  if Date.valid_date?(ff["value"][1..-1].split("/")[0].to_i,ff["value"].split("/")[1].to_i,01)   and (ff["value"] =~ /^<=/  or ff["value"]=~ /^>=/ )
			         	when 10
					 		where_str << "to_char(#{ff["id"]},'yyyy/mm/dd') = '#{ff["value"]}'                           AND "  if Date.valid_date?(ff["value"].split("/")[0].to_i,ff["value"].split("/")[1].to_i,ff["value"].split("/")[2].to_i)
			         	when 11
					 		where_str << "to_char(#{ff["id"]},'yyyy/mm/dd') #{ff["value"][0]} '#{ff["value"][1..-1]}'   AND "  if Date.valid_date?(ff["value"][1..-1].split("/")[0].to_i,ff["value"].split("/")[1].to_i,ff["value"].split("/")[2].to_i)  and ( ff["value"] =~ /^</   or  ff["value"] =~ /^>/ )
                	 	when 12
					 		where_str << "to_char(#{ff["id"]},'yyyy/mm/dd')  #{ff["value"][0..1]} '#{ff["value"][2..-1]}' AND "  if Date.valid_date?(ff["value"][2..-1].split("/")[0].to_i,ff["value"].split("/")[1].to_i,ff["value"].split("/")[2].to_i)   and (ff["value"] =~ /^<=/  or ff["value"]=~ /^>=/ )
			         	when 16
			            	if Date.valid_date?(ff["value"].split("/")[0].to_i,ff["value"].split("/")[1].to_i,ff["value"].split("/")[2][0..1].to_i)
					 							hh = ff["value"].split(" ")[1][0..1]
					 							mi = ff["value"].split(" ")[1][3..4]
					 							delm = ff["value"].split(" ")[1][2.2]
					 							if  Array(0..24).index(hh.to_i) and Array(0..60).index(mi.to_i) and delm ==":"
					 								where_str << " to_char( #{ff["id"]},'yyyy/mm/dd hh24:mi') = '#{ff["value"]}'       AND "
					 							end
					 		end
			        	when 17
							if Date.valid_date?(ff["value"][1..-1].split("/")[0].to_i,ff["value"].split("/")[1].to_i,ff["value"].split("/")[2][0..1].to_i)  and ( ff["value"] =~ /^</   or ff["value"] =~ /^>/ or  ff["value"] =~ /^=/ )
										hh = ff["value"].split(" ")[1][0..1]
										mi = ff["value"].split(" ")[1][3..4]
										delm = ff["value"].split(" ")[1][2.2]
										if  Array(0..24).index(hh.to_i) and Array(0..60).index(mi.to_i) and delm ==":"
											where_str << " to_char( #{ff["id"]},'yyyy/mm/dd hh24:mi') #{ff["id"][0]} '#{ff["id"][1..-1]}'      AND "
										end
							end
                		when 18
			                if Date.valid_date?(j[2..-1].split("/")[0].to_i,ff["value"].split("/")[1].to_i,ff["value"].split("/")[2][0..1].to_i)   and (ff["value"]=~ /^<=/  or ff["value"]=~ /^>=/ )
												hh = ff["value"].split(" ")[1][0..1]
												mi = ff["value"].split(" ")[1][3..4]
												delm = ff["value"].split(" ")[1][2.2]
												if  Array(0..24).index(hh.to_i) and Array(0..60).index(mi.to_i) and delm ==":"
													where_str << " to_char( #{ff["id"]},'yyyy/mm/dd hh24:mi')  #{ff["id"][0..1]} '#{ff["id"][2..-1]}'      AND "
												end
							end
						else
							next						
                		end ## ff["value"].size
					when /char|text|select/
						if  (ff["value"] =~ /^%/ or ff["value"] =~ /%$/ ) then 
							where_str << " #{ff["id"]} like '#{ff["value"]}'     AND " if  ff["value"] != ""
						elsif ff["value"] =~ /^<=/  or ff["value"] =~ /^>=/ then 
							where_str << " #{ff["id"]} #{ff["value"][0..1]} '#{ff["value"][2..-1]}'     AND " if  ff["value"] != ""
						elsif 	ff["value"] =~ /^</   or  ff["value"] =~ /^>/
							where_str << " #{ff["id"]}   #{ff["value"][0]}  '#{ff["value"][1..-1]}'         AND "  if  ff["value"] != ""
						elsif 	ff["value"] =~ /^!=/   
							where_str << " #{ff["id"]}   #{ff["value"][0..1]}  '#{ff["value"][2..-1]}'         AND "  if  ff["value"] != ""
						else
							where_str << " #{ff["id"]} = '#{ff["value"]}'         AND "
						end
	      			##when "select"
					##	where_str << " #{ff["id"]} = '#{ff["value"]}'         AND "
        			end   ##show_data[:alltypes][i]
        			tmpwhere = " #{ff["id"]} #{ff["value"]}    AND " if  ff["value"] =~/is\s*null/ or ff["value"]=~/is\s*not\s*null/
	      			where_str << (tmpwhere||="")
				end ### command_c.each  do |i,j|###
				setParams[:where_str] = 	where_str[0..-7]
			else
				setParams[:where_str] = ""
				if grid_columns_info[:init_where_info][:filtered]
				  if grid_columns_info[:init_where_info][:filtered].size > 1
					setParams[:where_str] = " where " + grid_columns_info[:init_where_info][:filtered] 
				  end
				end   
				###@where_info["filtered"] screen sort 規定値
				setParams[:filtered]= []
			end
			setParams[:pageIndex] = params[:pageIndex].to_f
			setParams[:pageSize] = params[:pageSize].to_f
			setParams[:disableFilters] = false
			setParams[:sortBy]||= []
			return setParams
		end	

		def proc_search_blk(params) 
			setParams = create_filteredstr(params) 
			where_str = setParams[:where_str]
			strsorting = ""
			if setParams[:sortBy]  and   setParams[:sortBy] != [] ###: {id: "itm_name", desc: false}
				setParams[:sortBy].each do |strSortKey|
					sortKey = JSON.parse(strSortKey)
					strsorting = " order by " if strsorting == ""
					strsorting << %Q% #{sortKey["id"]} #{if sortKey["desc"]  == false then " asc " else "desc" end} ,%
				end	
				if strsorting == ""
					strsorting = " order by id desc "
				else
					strsorting << " id desc "
				end
			else
				strsorting = "  order by id desc "
				setParams[:sortBy] = []
			end
			setParams[:clickIndex] = []
			strsql = "select #{grid_columns_info[:select_fields]} 
						from (SELECT ROW_NUMBER() OVER (#{strsorting}) ,#{grid_columns_info[:select_row_fields]}
													 FROM #{screenCode} #{if where_str == '' then '' else where_str end } ) x
														where ROW_NUMBER > #{(setParams[:pageIndex])*setParams[:pageSize] } 
														and ROW_NUMBER <= #{(setParams[:pageIndex] + 1)*setParams[:pageSize] } 
																  "
			pagedata = ActiveRecord::Base.connection.select_all(strsql)
			if where_str =~ /where/ 
				strsql = "SELECT count(*) FROM #{screenCode} #{where_str}"
			else
				strsql = "SELECT count(*) FROM #{screenCode.split("_")[1]} "
			end  ###fillterがあるので、table名は抽出条件に合わず使用できない。
			totalCount = ActiveRecord::Base.connection.select_value(strsql)
			setParams[:pageCount] = (totalCount.to_f/setParams[:pageSize]).ceil
			setParams[:totalCount] = totalCount.to_f
			if params[:parse_linedata]
				setParams[:parse_linedata] = params[:parse_linedata]
			end
			return pagedata,setParams 
		end	

		def proc_add_empty_data(params) ###新規追加画面の画面の初期値
			num = params[:pageSize].to_f
			setParams = params.dup
			pagedata = []
			until num <= 0 do   ###初期値セット　参考　ctl_fields.get_fetch_rec onblurfunc.js
				temp ={}
				grid_columns_info[:columns_info].each do |cell|
					next if cell[:accessor] == "id" 
					if cell[:accessor] =~ /_id/
						temp[cell[:accessor]] = "0"   ###nullだと端末から該当項目が返らないため
					end
					temp[cell[:accessor]] = ""
					if cell[:className] =~ /^Editable/
						if cell[:className] =~ /Numeric/
							temp[cell[:accessor]] = "0" ###初期表示
						end
						case cell[:accessor]   ###初期表示
						when /_expiredate/
							temp[cell[:accessor]] = "2099-12-31"
						when /_isudate|_rcptdate|_cmpldate/
							temp[cell[:accessor]] = Time.now.strftime("%Y/%m/%d")
						when /pobject_objecttype_tbl/
							temp[cell[:accessor]] = "tbl"
						when /opeitm_processseq|opeitm_priority/	
							temp[cell[:accessor]] = "999"
						when /mkprdpurord_priority|mkprdpurord_processseq/	
							temp[cell[:accessor]] = "0"
						when /person_code_chrg/	
							temp[cell[:accessor]] = $person_code_chrg
						when /prjno_code/	
							temp[cell[:accessor]] = "0"
						else
						end
					end
					case screenCode
					when "r_mkprdpurords"
						case cell[:accessor]
						when /loca_code_|itm_code_|person_code_chrg/	
							temp[cell[:accessor]] = "dummy"
						when /mkprdpurord_duedate_/
							temp[cell[:accessor]] = "2099/12/31"  
						when /mkprdpurord_starttime_/
							temp[cell[:accessor]] = "2000/01/01"  
						end
					when /fieldcodes/
						case cell[:accessor]
						when /pobject_objecttype/	
							temp[cell[:accessor]] = "tbl_field"
						end
					when /screenfields/
						case cell[:accessor]
						when /pobject_objecttype_sfd/	
							temp[cell[:accessor]] = "view_field"
						end
					end
				end	
				pagedata << temp
				num = num - 1
			end
			setParams[:pageCount] = 1
			setParams[:pageIndex] = 0
			setParams[:filtered]= []
			setParams[:sortBy]= []
			return pagedata,setParams		
		end	   ## proc_strwhere

  		def  proc_pdfwhere pdfscript,command_c
	    	reports_id = pdfscript[:id]
	    	viewname = command_c["sio_viewname"]
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

		def create_download_columns_info    ###screenCodeはinitializeでset
			download_columns_info = {}
			###download_columns_info = Rails.cache.fetch('download'+$proc_grp_code+screenCode) do
				###  ダブルコーティション　「"」は使用できない。 
				sqlstr = "select * from  func_get_screenfield_grpname('#{$email}','#{screenCode}')"
				ActiveRecord::Base.connection.select_all(sqlstr).each do |i|
					if i["screenfield_hideflg"] == "0"
						contents = []
						contents << i["pobject_code_sfd"] ###
						contents << i["screenfield_name"] ###
						contents <<  if i["screenfield_indisp"] === "1" or i["screenfield_indisp"] === "2"
							 			"00bfff"  ##rgb(125, 177, 245)
									else
										if i["screenfield_editable"] == "1"	
											"87ceeb"  ## rgb(200, 220, 245);
										else
											"ffffff"
										end
									end	###value: "Blue",  style: {fill: {patternType: "solid", fgColor: {rgb: "FF0000FF"}}}
						contents << 	if i["screenfield_type"] == "nemeric"
										"right"
								else
										"left"
								end
						contents << i["screenfield_type"]   ###未使用
						download_columns_info[i["pobject_code_sfd"].to_sym] = contents
					end	
				end
			###end
			return download_columns_info  ### [{key=>name,color,type},・・・]
		end
	
		def proc_download_data_blk(params)
			download_columns_info = create_download_columns_info 
			setParams = create_filteredstr(params) 
			downloadFields = ""
			download_columns_info.each do |key,val|
					downloadFields << key.to_s + ","
			end
			strsql = "select #{downloadFields.chop} from  #{screenCode}
							 #{if setParams[:where_str] == '' then '' else setParams[:where_str]   end }  limit 10000	  "
			pagedata = []
			ActiveRecord::Base.connection.select_all(strsql).each do |rec|
				pg = {}
				rec.each do |key,val|
					case val.class.to_s
					when "Date"   ### case val.class  when Date　だと拾えない 
						pg[key] = val.to_s
					when "Time"
						pg[key] = val.strftime("%Y-%m-%d %H:%M:%S")
					when "NilClass"
						pg[key] = ""
					else
						pg[key] = val
					end 
				end
				pagedata << pg
			end
			return download_columns_info,pagedata.count, pagedata
		end	

		def proc_create_upload_editable_columns_info req
			upload_columns_info = Rails.cache.fetch('uploadscreenfield'+$proc_grp_code+screenCode) do
				###  ダブルコーティション　「"」は使用できない。 
				sqlstr = "select * from  func_get_screenfield_grpname('#{$email}','#{screenCode}')"
				columns_info = []
				page_info = {}
				init_where_info = {}
				select_fields = ""
				gridmessages_fields = ""  ### error messages
				dropdownlist = {}   ###uploadでは未使用
				sort_info = {}
				screenwidth = 0
				nameToCode = {}
				tblchop = screenCode.split("_")[1].chop
				columns_info << {:Header=>"confirm",
									:accessor=>"confirm",
									:className=>"ffffff",
									}
				columns_info << {:Header=>"#{tblchop}_confirm_gridmessage",
									:accessor=>"#{tblchop}_confirm_gridmessage",
									:className=>"ffffff",
									}
				columns_info << {:Header=>"aud",
							:accessor=>"aud",
							:className=>"ffffff",
							}
				ActiveRecord::Base.connection.select_all(sqlstr).each_with_index do |i,cnt|		
					select_fields = 	select_fields + 	i["pobject_code_sfd"] + ','
					if 	nameToCode[i["screenfield_name"].to_sym].nil?   ###nameToCode excelから取り込むときの表示文字からテーブル項目名への変換テーブル
						nameToCode[i["screenfield_name"].to_sym] = i["pobject_code_sfd"]
					else
						if i["pobject_code_sfd"].split("_")[0] == screenCode.split("_")[1].chop
							nameToCode[i["screenfield_name"].to_sym] = i["pobject_code_sfd"]  ###nameがテーブル項目しか登録されてない。
						end
					end
					columns_info << {:Header=>"#{i["screenfield_name"]}",
									:accessor=>"#{i["pobject_code_sfd"]}",
									:filtered=>true,
									:width => i["screenfield_width"].to_i,
									:id=>"#{i["screenfield_id"]}",
									:style=>{:textAlign=>if i["screenfield_type"] == "numeric" then "right" else "left" end}, 
									:className=>if req == "import"
													if  i["screenfield_type"] == "select" 
															"00bfff"
													else
														if i["screenfield_type"] == "check" 
																		"00bfff"
														else		
															if	(i["screenfield_indisp"] === "1" or i["screenfield_indisp"] === "2")
																		"00bfff"
															else
																if i["screenfield_editable"] == "1"	
																	"87ceeb"  ## rgb(200, 220, 245);
																else
																	"ffffff"
																end
															end
														end
													end				  
												else	
																		"ffffff"
												end	
									}
					if req == "import" 
						columns_info << {:Header=>"#{i["screenfield_name"]}_gridmessage",
										:accessor=>"#{i["pobject_code_sfd"]}_gridmessage",
										:id=>"#{i["screenfield_id"]}_gridmessage",
										:className=>"ffffff"   ###バッチでは色
									}
						gridmessages_fields << %Q% '' #{i["pobject_code_sfd"]}_gridmessage,%	
					end																
					init_where_info[i["pobject_code_sfd"].to_sym] = 	i["screenfield_type"]	
					if cnt == 0
								init_where_info[:filtered] = i["screen_strwhere"]   ### init_where_info[:filtered] === "string", params[:filtered] === "arrey["object"]""
								###page_info[:sizePerPage] = i["screen_rows_per_page"].to_i
								page_info[:pageNo] = 1
								page_info[:sizePerPageList] = []
								i["screen_rowlist"].split(",").each do |list|
									page_info[:sizePerPageList]  <<  list.to_i
								end
								if i["screen_strorder"] 
									sort_info[:default] = i["screen_strorder"]
								end	
				 	end
					if   i["screenfield_hideflg"] == "0" 
						screenwidth = screenwidth +  i["screenfield_width"].to_i
					end
					##end
				end	
				fetch_check = {}
				fetch_check[:fetchCode] = YupSchema.proc_create_fetchCode screenCode   
				fetch_check[:checkCode]  = YupSchema.proc_create_checkCode screenCode   
				if sort_info[:default]
					ary_select_fields = select_fields.split(',')
					sort_info = CtlFields.proc_detail_check_strorder sort_info,ary_select_fields
				end	 
				page_info[:screenwidth] = screenwidth	
				if gridmessages_fields.size > 1
					select_fields << gridmessages_fields
				end
				upload_columns_info = [columns_info,page_info,init_where_info,select_fields.chop,fetch_check,dropdownlist,sort_info,nameToCode]
			end
			return upload_columns_info
		end

		def proc_confirm_screen(params)
			tblnamechop = screenCode.split("_")[1].chop
			yup_fetch_code = grid_columns_info[:fetch_check][:fetchCode]
			yup_check_code = grid_columns_info[:fetch_check][:checkCode]
			parse_linedata = params[:parse_linedata].dup
			addfield = {}
			setParams = params.dup
			setParams[:err] = nil
			parse_linedata.each do |field,val|
			  	if yup_fetch_code[field] 
					##setParams["fetchCode"] = %Q%{"#{field}":"#{val}"}%  ###clientのreq='fetch_request'で利用
					if setParams[:parse_linedata][:id] == ""  ###tableのユニークid
						setParams[:parse_linedata][:aud]= "add" 
					end  
					setParams[:fetchview] = yup_fetch_code[field]
					setParams = CtlFields.proc_chk_fetch_rec setParams  
					if setParams[:err] 
				  		setParams[:parse_linedata][:confirm_gridmessage] = setParams[:err] 
				  		setParams[:parse_linedata][:confirm] = false 
				  		setParams[:parse_linedata][(field+"_gridmessage").to_sym] = setParams[:err] 
						  if setParams[:parse_linedata][:errPath].nil? 
							  setParams[:parse_linedata][:errPath] = [field+"_gridmessage"]
						  end
				  		break
					end
			  	end
			 	if setParams[:err].nil?
					if yup_check_code[field] 
				  		setParams = CtlFields.proc_judge_check_code setParams,field,yup_check_code[field]  
				  		if setParams[:err]
							setParams[:parse_linedata][:confirm_gridmessage] = setParams[:err] 
							setParams[:parse_linedata][:confirm] = false 
							setParams[:parse_linedata][(field+"_gridmessage").to_sym] = setParams[:err] 
							if setParams[:parse_linedata][:errPath].nil? 
								setParams[:parse_linedata][:errPath] = [field+"_gridmessage"]
							end
							break
				  		end
					end
			  	end 
				setParams[:parse_linedata][field] = val    
			end	
			if  setParams[:err].nil?
				blk =  RorBlkCtl::BlkClass.new(screenCode)
				command_c = blk.command_init
			  	parse_linedata = setParams[:parse_linedata].dup
			  	parse_linedata.each do |key,val|
					if key.to_s =~ /_id/ and val == ""   and tblnamechop == key.to_s.split("_")[0] and
						key.to_s !~ /_gridmessage$/ and  key.to_s !~ /_person_id_upd$/ and  key.to_s != "#{tblnamechop}_id"
							setParams[:parse_linedata][:confirm_gridmessage] = " key #{key.to_s} missing"
							setParams[:parse_linedata][:confirm] = false 
							setParams[:err] = "error  key #{key.to_s} missing"
							if setParams[:parse_linedata][:errPath].nil? 
								setParams[:parse_linedata][:errPath] = [key+"_gridmessage"]
							end
							break
				  	else
						command_c[key.to_s] = val
				  	end
			  	end 
			  	### セカンドkeyのユニークチェック
			 	err = CtlFields.proc_blkuky_check(screenCode.split("_")[1],parse_linedata)
			  	err.each do |key,recs|
					recs.each do |rec|
						if command_c["id"] != rec["id"]
							setParams[:err] = " error #{key} already exist line:#{setParams[:index]} "
							setParams[:parse_linedata][:confirm_gridmessage] = setParams[:err] 
							if setParams[:parse_linedata][:errPath].nil? 
								setParams[:parse_linedata][:errPath] = [key+"_gridmessage"]
							end
							setParams[:parse_linedata][:confirm] = false 
						end  
					end	
			  	end	
			end
			if  setParams[:err].nil? and screenCode =~ /tblfields/
					strsql =  %Q%  select screenfield_seqno,pobject_code_sfd from r_screenfields  
						  where screenfield_expiredate > current_date and 
						  id in (select id from r_screenfields where pobject_code_scr = '#{screenCode}') and
						  pobject_code_sfd in('screenfield_starttime','screenfield_duedate','screenfield_qty','screenfield_qty_case')
			  			%
			  	seqchkfields ={}
			  	recs = ActiveRecord::Base.connection.select_all(strsql)
			  	recs.each do |rec|
					seqchkfields[rec["pobject_code_sfd"]] = rec["screenfield_seqno"]
			  	end  
			  	seqchkfields[setParams[:parse_linedata][:pobject_code_sfd]] = setParams[:parse_linedata][:screenfield_seqno]
			  	if (seqchkfields["screenfield_starttime"]||="99999") <  (seqchkfields["screenfield_duedate"]||="0")
					setParams[:err] =  " starttime seqno > duedate seqno  line:#{setParams[:index]} "
					setParams[:parse_linedata][:confirm_gridmessage] = setParams[:err] 
					setParams[:parse_linedata][:confirm] = false 
			  	else
					if (seqchkfields["screenfield_qty_case"]||="99999") <  (seqchkfields["screenfield_qty"]||="0")
						setParams[:err] =  " qty_case seqno > qty seqno  line:#{setParams[:index]} "  ###画面表示順　　包装単位の計算ため
						setParams[:parse_linedata][:confirm_gridmessage] = setParams[:err] 
						setParams[:parse_linedata][:confirm] = false 
					end
			  	end
			end
			if  setParams[:err].nil?
			  	if command_c["id"] == "" or  command_c["id"].nil?   ### add画面で同一lineで二度"enter"を押されたとき errorにしない
				  	###  追加後エラーに気づいたときエラーしないほうが，操作性がよい
					command_c["sio_classname"] = "_add_grid_linedata"
			  	else         
					command_c["sio_classname"] = "_edit_update_grid_linedata"
			  	end
			  	command_c = blk.proc_create_tbldata(command_c) ##
			  	setParams,command_c = blk.proc_add_update_table(setParams,command_c)
			  	if command_c["sio_result_f"]  == "9"
					setParams[:parse_linedata][:confirm] = false  
					err_message = command_c["sio_message_contents"].split(":")[1][0..100] + 
							  command_c["sio_errline"].split(":")[1][0..100]  
					setParams[:parse_linedata][:confirm_gridmessage] = err_message
			  	else
					setParams[:parse_linedata][:id] = command_c["id"]
					setParams[:parse_linedata][(tblnamechop+"_id").to_sym] = command_c[tblnamechop+"_id"]
					setParams[:parse_linedata][:confirm] = true  
					setParams[:parse_linedata][:confirm_gridmessage] = "done"
					ArelCtl.proc_materiallized tblnamechop+"s"
			  	end
			end 
			return setParams
		end
  
		def undefined
		  nil
		end
	end  
end   ##module ScreenLib
