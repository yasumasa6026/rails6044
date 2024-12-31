
# -*- coding: utf-8 -*-
#ScreenLib 
# 2099/12/31を修正する時は　2100/01/01の修正も
module ScreenLib 
	extend self
	class ScreenClass
		attr_reader :screenCode
		
		def initialize(params)
			@screenCode = params[:screenCode]
			@proc_grp_code =  ActiveRecord::Base.connection.select_value("select usrgrp_code from r_persons where person_email = '#{params["email"]}'")
			if @proc_grp_code.nil?
				p "add person to his or her email "
				raise   ### 別画面に移動する　後で対応
			end
			@sort_info = {}
			if params[:groupBy]
				proc_create_grid_groupBy_columns_info(params)
			else
				if params[:screenCode] and (params[:buttonflg] != "import" or params[:buttonflg] !~ /confirm/)
					proc_create_grid_editable_columns_info(params)
				end
			end
			
			params[:view] =  ActiveRecord::Base.connection.select_value("select pobject_code_view from r_screens where pobject_code_scr = '#{@screenCode}'")
		end
		def grid_columns_info
			@grid_columns_info
		end
		def screenCode
			@screenCode
		end
		
		def proc_create_grid_editable_columns_info(params) 
			buttonflg = params[:buttonflg]
			aud = params[:aud] ### buttonflg = inlineedit7,aud = add --> 明細追加　
			@grid_columns_info = Rails.cache.fetch('screenfield'+@proc_grp_code+screenCode+buttonflg) do
				@grid_columns_info = {}
				###  ダブルコーティション　「"」は使用できない。 ####groupBy
				strsql = "select * from  func_get_screenfield_grpname('#{params["email"]}','#{screenCode}')"
				screenwidth = 0
				select_fields = ""
				select_row_fields = ""
				gridmessages_fields = ""  ### error messages
				init_where_info = {:filtered => ""}
				dropDownList = {}
				nameToCode = {}
				columns_info = []
				subform_info = []
				line_subform = []
				columncnt = 1
				hiddenColumns = []
				if (buttonflg=='inlineedit7'|| buttonflg=="inlineadd7" )
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
				ActiveRecord::Base.connection.select_all(strsql).each_with_index do |i,cnt|		
						select_fields = 	select_fields + 
											case i["screenfield_type"]
											when "timestamp(6)" 
												%Q% to_char(#{i["pobject_code_sfd"]},'yyyy/mm/dd hh24:mi') #{i["pobject_code_sfd"]}% + " ,"
											when "date" 
												%Q% to_char(#{i["pobject_code_sfd"]},'yyyy/mm/dd ') #{i["pobject_code_sfd"]}% + " ,"
											when "numeric"
                        if i["pobject_code_sfd"] != "id" and i["pobject_code_sfd"] !~ /_id/
												  if i["screenfield_datascale"].to_i > 0
													  %Q% to_char(#{i["pobject_code_sfd"]}, 'FM999999999999.#{i["screenfield_datascale"]}') #{i["pobject_code_sfd"]}% + ","
												  else
													  %Q% to_char(#{i["pobject_code_sfd"]}, 'FM999999999999') #{i["pobject_code_sfd"]}% + ","
												  end
                        else								
												  i["pobject_code_sfd"] + " ,"
                        end
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
									:className=>classNameset(buttonflg,i,aud)
									}
						if ((buttonflg =="inlineedit7" or buttonflg =="inlineadd7") and i["screenfield_editable"] == "1") or
							(buttonflg =="inlineedit7"  and i["screenfield_editable"] == "2") or
							( buttonflg =="inlineadd7" and i["screenfield_editable"] == "3") or
							(buttonflg =="inlineedit7"  and i["screenfield_editable"] == "3" and aud == "add") 
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
							if i["screen_strorder"] and i["screen_strorder"]  != "" 
								@sort_info[:default] = i["screen_strorder"]
							end	
						else	
				 		end
					if  i["screenfield_type"] == "select" and i["screenfield_hideflg"] == "0"
						if i["screenfield_edoptvalue"] 
							if i["screenfield_edoptvalue"] =~ /\:/
								dropDownList[i["pobject_code_sfd"].to_sym] = i["screenfield_edoptvalue"]
							else
								Rails.logger.debug " class:#{self} ,line:#{__LINE__},screenfield_type = selectではedoptvalueにxxx:yyy,aaa:bbbは必須 "
								raise
							end
						else
							Rails.logger.debug " class:#{self} ,line:#{__LINE__}, screenfield_type = selectではedoptvalueにxxx:yyy,aaa:bbbは必須 "
							raise
						end
					end	
					tmp_subform = {label:i["screenfield_name"]}
					if   i["screenfield_hideflg"] == "0" 
						screenwidth = screenwidth +  i["screenfield_width"].to_i
						if 	i["screenfield_rowpos"] == "1" or (columncnt + i["screenfield_edoptcols"].to_i > 10)
							if line_subform != []
								subform_info << line_subform  ### line_subform-->formの横１行分
							end
							line_subform = []
							columncnt =  1 
						else
							columncnt +=  (1 + i["screenfield_edoptcols"].to_i)	
						end
						tmp_subform[:edoptcols]	= i["screenfield_edoptcols"]	
						tmp_subform[:edoptrows]	= i["screenfield_edoptrow"]	
						tmp_subform[:className] = classNameset(buttonflg,i,aud)
						tmp_subform[:edoptrows]	= i["screenfield_edoptrow"]	
						tmp_subform[:hideflg]	= "visible"  ###subForm
					else
						hiddenColumns << i["pobject_code_sfd"]  ###react-table initialState.hiddenColumns
						tmp_subform[:hideflg]	= "hidden"  ###subForm
						columncnt =  1 
					end
					tmp_subform[:id] = i["pobject_code_sfd"]
					line_subform << tmp_subform
				end
				subform_info << line_subform
				@grid_columns_info[:columns_info] = columns_info
				@grid_columns_info[:hiddenColumns] = hiddenColumns
				@grid_columns_info[:fetch_check] = {}
				@grid_columns_info[:fetch_check][:fetchCode] = YupSchema.proc_create_fetchCode   screenCode
				@grid_columns_info[:fetch_check][:checkCode] = YupSchema.proc_create_checkCode   screenCode
				@grid_columns_info[:fetch_data] = {}
				@grid_columns_info[:subform_info] = subform_info

				dropDownList.each do |key,val|
					tmpval="["
					val.split(",").each do  |drop|
						tmpval << %Q%{"value":"#{drop.split(":")[0]}","label":"#{drop.split(":")[1]}"},%
					end
					dropDownList[key] = tmpval.chop + "]"
				end	
				@grid_columns_info[:dropDownList] = dropDownList
				@grid_columns_info[:init_where_info] = init_where_info
				@grid_columns_info[:sort_info] = @sort_info	
				@grid_columns_info[:screenwidth] = screenwidth	
				if gridmessages_fields.size > 1
					select_fields << gridmessages_fields
				end
				@grid_columns_info[:select_fields] = select_fields.chop
				@grid_columns_info[:select_row_fields] = select_row_fields.chop
				@grid_columns_info[:strGroupBy] = ""
				@grid_columns_info
			end
		end
		
		def proc_create_grid_groupBy_columns_info(params) 
			buttonflg = params[:buttonflg]
			aud = params[:aud] ### buttonflg = inlineedit7,aud = add --> 明細追加　
			@grid_columns_info = {}
			###  ダブルコーティション　「"」は使用できない。
			screenwidth = 0
			select_fields = ""
			select_row_fields = ""
			gridmessages_fields = ""  ### error messages
			init_where_info = {:filtered => ""}
			dropDownList = {}
			nameToCode = {}
			columns_info = []
			subform_info = []
			line_subform = []
			columncnt = 1
			hiddenColumns = []
			strGroupBy = ""
			# if params[:groupBy].size > 0
			# 	strGroupBy = " group by " + params[:groupBy].join(",")
			# 	params[:groupBy].each do |gr|
			# 		strGroupBy << "," + gr.sub(/_code/,'_name') if gr =~ /_code/
			# 	end
			# else
			# 	strGroupBy = ""
			# end	
			aggregations = {}
			if params[:aggregations].size > 0
				aggregations = JSON.parse(params[:aggregations])
			end
			strsql = "select * from  func_get_screenfield_grpname('#{params["email"]}','#{screenCode}')	"
			ActiveRecord::Base.connection.select_all(strsql).each_with_index do |i,cnt|	
				if params[:groupBy].include?(i["pobject_code_sfd"])
					if 	strGroupBy == ""
						strGroupBy = " group by "
					else
						strGroupBy << ","
					end		
					if aggregations[i["pobject_code_sfd"]]		
						case aggregations[i["pobject_code_sfd"]]
						when "YY:"
							select_row_fields << %Q% to_char(#{i["pobject_code_sfd"]},'yyyy') #{i["pobject_code_sfd"]} ,% 
							strGroupBy << %Q% to_char(#{i["pobject_code_sfd"]},'yyyy') %
						when "MM:"
							select_row_fields << %Q% to_char(#{i["pobject_code_sfd"]},'yyyy/mm') #{i["pobject_code_sfd"]} ,%  
							strGroupBy << %Q% to_char(#{i["pobject_code_sfd"]},'yyyy/mm') %
						when "WW:"
							select_row_fields << %Q% to_char(#{i["pobject_code_sfd"]},'yyyy/ww') #{i["pobject_code_sfd"]} ,% 
							strGroupBy << %Q% to_char(#{i["pobject_code_sfd"]},'yyyy/ww') % 
						when "DD:"
							select_row_fields << %Q% to_char(#{i["pobject_code_sfd"]},'yyyy/mm/dd') #{i["pobject_code_sfd"]} ,% 
							strGroupBy << %Q% to_char(#{i["pobject_code_sfd"]},'yyyy/mm/dd') % 
						when "",nil
							select_row_fields << %Q%  #{i["pobject_code_sfd"]} ,% 
							strGroupBy << %Q% #{i["pobject_code_sfd"]} % 
						else
							Rails.logger.debug " class:#{self} ,line:#{__LINE__}, aggregations:#{aggregations[i["pobject_code_sfd"]]} not support"
							Rails.logger.debug " class:#{self} ,line:#{__LINE__}, field:#{i["pobject_code_sfd"]} "
							Rails.logger.debug " class:#{self} ,line:#{__LINE__},  support by  YY:,MM:,WW:.DD:"
							raise
						end
					else											
						select_row_fields << i["pobject_code_sfd"]  + " ,"
						strGroupBy << %Q% #{i["pobject_code_sfd"]} % 
					end
				else
					if aggregations[i["pobject_code_sfd"]]
						case aggregations[i["pobject_code_sfd"]]
						when "SUM:"
							select_row_fields << %Q% sum(#{i["pobject_code_sfd"]}) #{i["pobject_code_sfd"]} ,%  
						when "MAX:"
							select_row_fields << %Q% max(#{i["pobject_code_sfd"]}) #{i["pobject_code_sfd"]} ,% 
						when "MIN:"
							select_row_fields << %Q% min(#{i["pobject_code_sfd"]}) #{i["pobject_code_sfd"]} ,% 
						when "",nil
							select_row_fields << %Q% null  #{i["pobject_code_sfd"]}  ,%
						else
							Rails.logger.debug " class:#{self} ,line:#{__LINE__}, aggregations:#{aggregations[i["pobject_code_sfd"]]} not support"
							Rails.logger.debug " class:#{self} ,line:#{__LINE__}, field:#{i["pobject_code_sfd"]} "
							Rails.logger.debug " class:#{self} ,line:#{__LINE__},  support by  SUM:,MIN:,MAX:"
							raise
						end
					else
						if i["pobject_code_sfd"] =~ /_qty|_amt|_cash/
							case i["screenfield_type"]
							when "numeric"
								if i["screenfield_datascale"].to_i > 0
									select_row_fields << %Q% to_char(sum(#{i["pobject_code_sfd"]}), 'FM999,999,999,999.#{i["screenfield_datascale"]}') #{i["pobject_code_sfd"]}% + ","
								else
									select_row_fields << %Q% to_char(sum(#{i["pobject_code_sfd"]}), 'FM999,999,999,999') #{i["pobject_code_sfd"]}% + ","
								end
							else
								select_row_fields << %Q% sum(#{i["pobject_code_sfd"]})  #{i["pobject_code_sfd"]}  ,%   ###fm9999select_fields = 	select_fields + 
							end
						else
							if i["pobject_code_sfd"] =~ /_name/
								if params[:groupBy].include?(i["pobject_code_sfd"].sub("_name","_code"))
									select_row_fields << %Q% max(#{i["pobject_code_sfd"]})  #{i["pobject_code_sfd"]}  ,%
								else
									select_row_fields << %Q% null  #{i["pobject_code_sfd"]}  ,%
								end
							else
								select_row_fields << %Q% null  #{i["pobject_code_sfd"]}  ,%
							end
						end
					end
				end	
				select_fields = 	select_fields + i["pobject_code_sfd"] + " ,"
				if 	nameToCode[i["screenfield_name"].to_sym].nil?   ###nameToCode excelから取り込むときの表示文字からテーブル項目名への変換テーブル
							nameToCode[i["screenfield_name"].to_sym] = i["pobject_code_sfd"]
				else
					if i["pobject_code_sfd"].split("_")[0] == screenCode.split("_")[1].chop
							nameToCode[i["screenfield_name"].to_sym] = i["pobject_code_sfd"]  ###nameがテーブル項目しか登録されてない。
					end
				end
				@grid_columns_info[:nameToCode] = nameToCode
				columns_info << {:Header=>%Q%#{i["screenfield_name"]}%,
									:id=>"#{i["screenfield_id"]}",
									:accessor=>"#{i["pobject_code_sfd"]}",
									:filter=>"text",
									:width => if i["screenfield_width"].to_i < 80 then 80 else  i["screenfield_width"].to_i end,
									:className=>classNameset(buttonflg,i,aud)
									}
																
				init_where_info[i["pobject_code_sfd"].to_sym] = i["screenfield_type"]	
				if cnt == 0
							init_where_info[:filtered] = (i["screen_strwhere"]||="")
							@grid_columns_info[:pageSizeList] = []
							i["screen_rowlist"].split(",").each do |list|
								@grid_columns_info[:pageSizeList]  <<  list.to_i
							end
							if i["screen_strorder"] and i["screen_strorder"]  != ""
								@sort_info[:default] = i["screen_strorder"]
							end	
				else	
				end
				if  i["screenfield_type"] == "select" and i["screenfield_hideflg"] == "0"
						dropDownList[i["pobject_code_sfd"].to_sym] = i["screenfield_edoptvalue"]
				end	
				tmp_subform = {label:i["screenfield_name"]}
				if   i["screenfield_hideflg"] == "0" 
						screenwidth = screenwidth +  i["screenfield_width"].to_i
						if 	i["screenfield_rowpos"] == "1" or (columncnt + i["screenfield_edoptcols"].to_i > 10)
							if line_subform != []
								subform_info << line_subform  ### line_subform-->formの横１行分
							end
							line_subform = []
							columncnt =  1 
						else
							columncnt +=  (1 + i["screenfield_edoptcols"].to_i)	
						end
						tmp_subform[:edoptcols]	= i["screenfield_edoptcols"]	
						tmp_subform[:edoptrows]	= i["screenfield_edoptrow"]	
						tmp_subform[:className] = classNameset(buttonflg,i,aud)
						tmp_subform[:edoptrows]	= i["screenfield_edoptrow"]	
						tmp_subform[:hideflg]	= "visible"  ###subForm
				else
				end
				tmp_subform[:id] = i["pobject_code_sfd"]
				line_subform << tmp_subform
			end
			subform_info << line_subform
			@grid_columns_info[:columns_info] = columns_info
			@grid_columns_info[:hiddenColumns] = hiddenColumns
			@grid_columns_info[:fetch_check] = {}
			@grid_columns_info[:fetch_check][:fetchCode] = {} ###YupSchema.proc_create_fetchCode   screenCode
			@grid_columns_info[:fetch_check][:checkCode] = {} ###YupSchema.proc_create_checkCode   screenCode
			@grid_columns_info[:fetch_data] = {}
			@grid_columns_info[:subform_info] = subform_info

			dropDownList.each do |key,val|
				tmpval="["
				val.split(",").each do  |drop|
						tmpval << %Q%{"value":"#{drop.split(":")[0]}","label":"#{drop.split(":")[1]}"},%
				end
				dropDownList[key] = tmpval.chop + "]"
			end	
			@grid_columns_info[:dropDownList] = dropDownList.dup
			@grid_columns_info[:init_where_info] = init_where_info
			@grid_columns_info[:sort_info] = @sort_info	
			@grid_columns_info[:screenwidth] = screenwidth	
			if gridmessages_fields.size > 1
				select_fields << gridmessages_fields
			end
			@grid_columns_info[:select_fields] = select_fields.chop
			@grid_columns_info[:select_row_fields] = select_row_fields.chop
			@grid_columns_info[:strGroupBy] = strGroupBy
			@grid_columns_info
		end

		def classNameset buttonflg,i,aud ###i : screenfields
			if  ((buttonflg=="inlineedit7" or buttonflg==="inlineadd7") and i["screenfield_editable"] ==  "1") or
				(buttonflg=="inlineedit7"  and i["screenfield_editable"] ==  "2") or
				(buttonflg=="inlineadd7"  and i["screenfield_editable"] ==  "3")  or
				(aud=="add"   and i["screenfield_editable"] ==  "3")  ###子テーブル・レコード追加
					if  i["screenfield_indisp"] =~ /1|2/ ###必須はyupでも
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
					next if ff["value"].nil?
					next if ff["value"] == ""
					next if ff["value"] == " "
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
			setParams[:groupBy]||= []
			setParams[:aggregations]||= {}
			return setParams
		end	

		def proc_search_blk(params) 
			setParams = create_filteredstr(params) 
			str_func = %Q&select * from func_get_name('screen','#{params[:screenCode]}','#{params["email"]}')&
			setParams[:screenName] = ActiveRecord::Base.connection.select_value(str_func)
			if setParams[:screenName].nil?
				setParams[:screenName] = params[:screenCode]
			end
			where_str = setParams[:where_str]
			strsorting = ""
			if params[:groupBy] and params[:groupBy].size > 0
				if  params[:aggregations] and params[:aggregations].size > 0
					strsorting = "order by "
					hagg = JSON.parse(params[:aggregations])
			 		hagg.each do |agg,val|		 	####groupBy
			 				case  val 
			 				when "YY:"
			 					strsorting <<   %Q% to_char(#{agg.to_s},'yyyy') ,% 
			 				when "MM:"
			 					strsorting <<   %Q% to_char(#{agg.to_s},'yyyy/mm') ,% 
			 				when "WW:"
			 					strsorting <<   %Q% to_char(#{agg.to_s},'yyyy/ww') ,%
			 				when "DD:"
			 					strsorting <<   %Q% to_char(#{agg}.to_s,'yyyy/mm/dd') ,%
			 				when "sum","min","max"
			 					next
			 				else
								strsorting <<   " #{agg.to_s} ,"
			 				end
					end
					if strsorting == "order by "
						strsorting = ""
					else
						strsorting = strsorting.chop
					end
				else
					strsorting = "order by " + params[:groupBy].join(",")
			 	end
			# 	if params[:sortBy]  ###: {id: "itm_name", desc: false}
			# 		strsorting << " order by "
			# 		params[:sortBy].each do |strSortKey|
			# 			sortKey = JSON.parse(strSortKey)
			# 			aggregationsFlg = 0
			# 			params[:aggregations].each do |straggregationsKey|
			# 				next if aggregationsFlg == 1
			# 				aggregationsKey = JSON.parse(straggregationsKey)
			# 				if aggregationsKey["columnId"] == sortKey["id"] and aggregationsKey["value"] != "" and !aggregationsKey["value"].nil? 
			# 					strsorting << %Q% #{aggregationsKey["value"].chop}(#{sortKey["id"]}) #{if sortKey["desc"]  == false then " asc " else "desc" end} ,%
			# 					aggregationsFlg = 1
			# 					next
			# 				end
			# 			end
			# 			strsorting << %Q% #{sortKey["id"]} #{if sortKey["desc"]  == false then " asc " else "desc" end} ,%
			# 		end	
			# 	end
			else
				if params[:sortBy] ###: {id: "itm_name", desc: false}
					params[:sortBy].each do |strSortKey|
						strsorting = " order by " 
						sortKey = JSON.parse(strSortKey)
						strsorting << %Q% #{sortKey["id"]} #{if sortKey["desc"]  == false then " asc " else "desc" end} ,%
					end	
					strsorting << " id desc " if params[:groupBy].nil?
					strsorting = strsorting.chop 
				else ###r_screensに登録している規定値
					if grid_columns_info[:sort_info][:default] and grid_columns_info[:sort_info][:default] != ""
						strsorting = " order by " + grid_columns_info[:sort_info][:default]
					else
						strsorting = "  order by id desc "
					end
					setParams[:sortBy] = []
				end
			end
			setParams[:clickIndex] = []
			strsql = "select #{grid_columns_info[:select_fields]} 
							from (SELECT ROW_NUMBER() OVER (#{strsorting}) ,#{grid_columns_info[:select_row_fields]}
									 FROM #{params[:view]} #{if where_str == '' then '' else where_str end }  #{grid_columns_info[:strGroupBy]}) x
														where ROW_NUMBER > #{(setParams[:pageIndex])*setParams[:pageSize] } 
														and ROW_NUMBER <= #{(setParams[:pageIndex] + 1)*setParams[:pageSize] } 
																  "
			pagedata = ActiveRecord::Base.connection.select_all(strsql)
			if params[:groupBy] and params[:groupBy].size > 0
				strsql = "select sum(cnt) from (select 1 cnt 
								from  #{params[:view]} #{if where_str == '' then '' else where_str end }  #{grid_columns_info[:strGroupBy]}) as aa
																	  "
			else
				if where_str =~ /where/ or params[:screenCode] !~ /^r_/
					strsql = "SELECT count(*) FROM #{params[:view]} #{where_str}"
				else
					strsql = "SELECT count(*) FROM #{params[:view].split("_")[1]} "
				end  ###fillterがあるので、table名は抽出条件に合わず使用できない。
			end
			totalCount = ActiveRecord::Base.connection.select_value(strsql)
			setParams[:pageCount] = (totalCount.to_f/setParams[:pageSize]).ceil
			setParams[:totalCount] = totalCount.to_f
			if params[:parse_linedata]
				setParams[:parse_linedata] = params[:parse_linedata].dup
			end
			return pagedata,setParams 
		end	


		def proc_add_empty_data(params) ###新規追加画面の画面の初期値
			num = params[:pageSize].to_f
			setParams = params.dup
			pagedata = []
			case screenCode
			when /cust1_custords/  ###custordsのheadがあるとき
				pare = JSON.parse(params[:head])  ### char --> 連想配列
				strsql = %Q&
						select * from r_custordheads where id = #{pare["id"]}
				&
				custhead = ActiveRecord::Base.connection.select_one(strsql)
			end
			until num <= 0 do   ###初期値セット　参考　ctl_fields.get_fetch_rec onblurfunc.js
				temp ={}
				grid_columns_info[:columns_info].each do |cell|
					temp[cell[:accessor]] = ""
					next if cell[:accessor] == "id" 
					case cell[:accessor]
					when /_id/
						temp[cell[:accessor]] = "0"   ###nullだと端末から該当項目が返らないため
					when /prjno_name/	  ### prjnosはid=0,code=0,name="common"で初期設定済
						temp[cell[:accessor]] = "common"
					when /prjno_priority/	  ### prjnosはid=0,code=0,name="common"で初期設定済
						temp[cell[:accessor]] = "0"
					when /person_name_chrg/	
						temp[cell[:accessor]] = params["person_name_upd"]
					end
					if cell[:className] =~ /^Editable/
						if cell[:className] =~ /Numeric/
							temp[cell[:accessor]] = "0" ###初期表示
						end
						case cell[:accessor]   ###初期表示
						when /_expiredate/
							temp[cell[:accessor]] = "2099-12-31"
						when /_isudate|_rcptdate|_cmpldate|payact_paymentdate/
							temp[cell[:accessor]] = Time.now.strftime("%Y/%m/%d")
						when /pobject_objecttype_tbl/
							temp[cell[:accessor]] = "tbl"
						when /opeitm_processseq|opeitm_priority|nditm_processseq_nditm|lotstkhist_processseq/	
							temp[cell[:accessor]] = "999"
						when /mkprdpurord_priority|mkprdpurord_processseq/	
							temp[cell[:accessor]] = "0"
						when /person_code_chrg/	
							temp[cell[:accessor]] = params["person_code_upd"]
						when /prjno_code/	### prjnosはid=0,code=0,name="common"で初期設定済
							temp[cell[:accessor]] = "0"
						when /custinst_starttime/
							temp[cell[:accessor]] = Time.now.strftime("%Y/%m/%d")
						when /price_maxqty|opeitm_maxqty/
							temp[cell[:accessor]] = "999999999"
						else
						end
					end
					case screenCode
					when "r_mkprdpurords"  ###オーダー作成時の抽出条件初期値
						case cell[:accessor]
						when /loca_code_|shelfno_code_|itm_code_|person_code_chrg/	
							temp[cell[:accessor]] = "dummy"
						when /mkprdpurord_duedate_/
							temp[cell[:accessor]] = "2099/12/31"  
						when /mkprdpurord_starttime_/
							temp[cell[:accessor]] = "2000/01/01"  
						end
						if cell[:className] =~ /Numeric/
							temp[cell[:accessor]] = "0" ###初期表示
						end
					when /mkpayinsts|mkbillinsts/  ###オーダー作成時の抽出条件初期値
						case cell[:accessor]
						when /loca_code_|person_code_chrg/	
							temp[cell[:accessor]] = "dummy"
						when /_incnt|_inqty|_inamt|_outcnt|_outqty|_outamt|_skipcnt|_skipqty|skipamt/	
							temp[cell[:accessor]] = "0"
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
					when /opeitms/
						case cell[:accessor]
						when /opeitm_stktaking_proc_/	
							temp[cell[:accessor]] = "1"  ###棚卸有 opeitmsの規定値
						end
					when /gantt_nditms/
						case cell[:accessor]
						when /itm_code$|itm_name$|processseq$|priority$/	
                            temp[cell[:accessor]] = params[:parse_linedata][cell[:accessor].to_sym]
						end
					when /insert_trngantts/
						case cell[:accessor]
						when /_org$|prjno|trngantt_qty_sch/	
                            temp[cell[:accessor]] = params[:trngantt][cell[:accessor].to_sym]
						when /_pare$/
                            temp[cell[:accessor]] = params[:trngantt][cell[:accessor].to_sym] 
						end
					when /purords|purschs/
						case cell[:accessor]
						when /shelfno_code$/	
                            temp[cell[:accessor]] = "000" 
						when /itm_taxflg/	
                            temp[cell[:accessor]] = "1" 
						end
					when /cust1_custords/   ###custordheadsからの引継ぎ
						case cell[:accessor]
						when  /custord_sno$|custord_cno$|custord_amt$|custord_tax$|custord_created_at|custord_updated_at/  ###親からの引継ぎなし
							next
						when /custord_gno/
							temp[cell[:accessor]] = custhead["custordhead_cno"]
						when /itm_taxflg/	
                            temp[cell[:accessor]] = "1" 
						else
							if custhead[cell[:accessor].sub("custord_","custordhead_")]
								case cell[:accessor]   ###初期表示
								when /_isudate/
									temp[cell[:accessor]] = custhead[cell[:accessor].sub("custord_","custordhead_")].strftime("%Y/%m/%d")
								when /_duedate/
									temp[cell[:accessor]] = custhead[cell[:accessor].sub("custord_","custordhead_")].strftime("%Y/%m/%d %H:%M")
								else
									temp[cell[:accessor]] = custhead[cell[:accessor].sub("custord_","custordhead_")]
								end
							end
						end
					when /^bal/   ###
						case cell[:accessor]
						when  /qty.*bal/  ###
							temp[cell[:accessor]] = 0
						end
					else
						case cell[:accessor]
						when /itm_taxflg/	
							temp[cell[:accessor]] = "1"
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
			setParams[:groupBy]= []
			setParams[:aggregations] = {}
			return pagedata,setParams		
		end	   ## proc_strwhere

		def create_download_columns_info(params)    ###screenCodeはinitializeでset
			download_columns_info = {}
			###download_columns_info = Rails.cache.fetch('download'+@proc_grp_code+screenCode) do
				###  ダブルコーティション　「"」は使用できない。 
				strsql = "select * from  func_get_screenfield_grpname('#{params["email"]}','#{screenCode}')"
				ActiveRecord::Base.connection.select_all(strsql).each do |i|
					contents = []  ###[field_id,color,position,type]
					if i["screenfield_hideflg"] == "0"
						contents << i["pobject_code_sfd"] ###
						contents << i["screenfield_name"] ###
						contents <<  if i["screenfield_indisp"] === "1" or i["screenfield_indisp"] === "2"
							 			"00bfff"  ##rgb(125, 177, 245)
									else
										if i["screenfield_editable"] =~ /1|2|3/	
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
					else
						# if i["pobject_code_sfd"] == "id" ###レコードの更新の時必要
						# 	contents << "id" ###
						# 	contents << "ffffff" ###
						# 	contents <<  "right"
						# 	contents << i["screenfield_type"]   ###未使用
						# 	download_columns_info[i["pobject_code_sfd"].to_sym] = contents
						# end
					end	
				end
			###end
			return download_columns_info  ### [{key=>name,color,type},・・・]
		end
	
		def proc_download_data_blk(params)
			download_columns_info = create_download_columns_info(params) 
			setParams = create_filteredstr(params) 
			downloadFields = ""
			download_columns_info.each do |key,val|
					downloadFields << (key.to_s + ",") if key.to_s != "id"
			end
			downloadFields << "id"
			strsql = "select #{downloadFields} from  #{screenCode}
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

		def proc_create_upload_editable_columns_info params,buttonflg
			upload_columns_info = Rails.cache.fetch('uploadscreenfield'+@proc_grp_code+screenCode) do
				###  ダブルコーティション　「"」は使用できない。 
				strsql = "select * from  func_get_screenfield_grpname('#{params["email"]}','#{screenCode}')"
				columns_info = []
				page_info = {}
				init_where_info = {}
				select_fields = ""
				gridmessages_fields = ""  ### error messages
				dropDownList = {}   ###uploadでは未使用
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
				ActiveRecord::Base.connection.select_all(strsql).each_with_index do |i,cnt|		
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
									:className=>if buttonflg == "import"
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
					if buttonflg == "import" 
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
								page_info[:pageNo] = 1
								page_info[:sizePerPageList] = []
								i["screen_rowlist"].split(",").each do |list|
									page_info[:sizePerPageList]  <<  list.to_i
								end
								if i["screen_strorder"] and i["screen_strorder"] != "" 
									@sort_info[:default] = i["screen_strorder"]
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
				page_info[:screenwidth] = screenwidth	
				if gridmessages_fields.size > 1
					select_fields << gridmessages_fields
				end
				upload_columns_info = [columns_info,page_info,init_where_info,select_fields.chop,fetch_check,dropDownList,@sort_info,nameToCode]
			end
			return upload_columns_info
		end

		def proc_confirm_screen(params)
			tblnamechop = screenCode.split("_")[1].chop
			yup_fetch_code = grid_columns_info[:fetch_check][:fetchCode]
			yup_check_code = grid_columns_info[:fetch_check][:checkCode]
			addfield = {}
			setParams = params.dup
			setParams[:err] = nil
      setParams[:outqty] = 0
      setParams[:outamt] = 0
			parse_linedata = params[:parse_linedata].dup  ###(can't add a new key into hash during iteration)	
			blk =  RorBlkCtl::BlkClass.new(screenCode)
			command_c = blk.command_init
			parse_linedata.each do |field,val|
			  if yup_fetch_code[field] 
				 	##setParams["fetchCode"] = %Q%{"#{field}":"#{val}"}%  ###clientのreq='fetch_request'で利用
				 	if setParams[:parse_linedata][:id] == "" or setParams[:parse_linedata][:id].nil? ###tableのユニークid
				 		setParams[:parse_linedata][:aud]= "add" ###
				 	end  
				 	setParams[:fetchview] = yup_fetch_code[field]
				 	setParams = CtlFields.proc_chk_fetch_rec setParams  
				 	if setParams[:err] 
						command_c[:confirm_gridmessage] = setParams[:err] 
						command_c[:confirm] = false 
						command_c[(field+"_gridmessage").to_sym] = setParams[:err] 
				 		if command_c[:errPath].nil? 
							command_c[:errPath] = [field+"_gridmessage"]
				 		end
				   		break
				 	end
				end
			 	if setParams[:err].nil?
					if yup_check_code[field] 
				  		setParams = CtlFields.proc_judge_check_code setParams,field,yup_check_code[field]  
				  		if setParams[:err]
							  command_c[:confirm_gridmessage] = setParams[:err] 
							  command_c[:confirm] = false 
							  command_c[(field+"_gridmessage").to_sym] = setParams[:err] 
							  if command_c[:errPath].nil? 
								  command_c[:errPath] = command_c[(field+"_gridmessage").to_sym]
						  	end
							  break
				  		end
					end
			  end 
				###setParams[:parse_linedata][field] = val    
			end	
			### cannot use parse_linedata
			if  setParams[:err].nil?
				setParams[:parse_linedata].each do |key,val|
				 	if key.to_s =~ /_id/ and val == ""   and tblnamechop == key.to_s.split("_")[0] and
					  key.to_s !~ /_gridmessage$/ and  key.to_s !~ /_person_id_upd$/ and  key.to_s != "#{tblnamechop}_id"
					  		command_c[:confirm_gridmessage] = " error key #{key.to_s} missing"
							command_c[:confirm] = false 
							setParams[:err] = "error  key #{key.to_s} missing"
							if command_c[:errPath].nil? 
								command_c[:errPath] = [key+"_gridmessage"]
							end
							break
					else
				  		command_c[key.to_s] = val  
              case key.to_s
              when /_amt$|amt_sch$|_cash$/
                setParams[:outamt] += val.to_f 
              when /_qty_sch$|_qty$|_qty_stk$/
                setParams[:outqty] = val.to_f
              end
					end
				end
				### セカンドkeyのユニークチェック
				err = CtlFields.proc_blkuky_check(screenCode.split("_")[1],parse_linedata)
				err.each do |key,recs|
				  	recs.each do |rec|
					   if command_c["id"] != rec["id"]
							setParams[:err] = " error  field:#{key} already exist line:#{setParams[:index]} "
							command_c[:confirm_gridmessage] = setParams[:err] 
							if command_c[:errPath].nil? 
								command_c[:errPath] = [key+"_gridmessage"]
							end
							command_c[:confirm] = false 
						end  
					end	
				end
			end	
			if  setParams[:err].nil?
				if command_c["id"] == "" or  command_c["id"].nil?   ### add画面で同一lineで二度"enter"を押されたとき errorにしない
					###  追加後エラーに気づいたときエラーしないほうが，操作性がよい
				  command_c["sio_classname"] = "_add_grid_linedata"
				  command_c["#{tblnamechop}_created_at"] = Time.now
				  command_c["id"] = ArelCtl.proc_get_nextval("#{tblnamechop}s_seq")
				else         
				  command_c["sio_classname"] = "_edit_update_grid_linedata"
				end
				command_c["#{tblnamechop}_person_id_upd"] = setParams["person_id_upd"]
				command_c = blk.proc_create_tbldata(command_c) ##:
				case screenCode 
				when /tblfields/  ###前処理 　 　
					if  setParams[:err].nil?  
						strsql =  %Q%  select screenfield_seqno,pobject_code_sfd from r_screenfields  
							where screenfield_expiredate > current_date and 
						  			id in (select id from r_screenfields where pobject_code_scr = '#{screenCode}') and
						  			pobject_code_sfd in('screenfield_starttime','screenfield_duedate','screenfield_qty','screenfield_qty_case')
			  					%
			  			seqchkfields ={}
			  			ActiveRecord::Base.connection.select_all(strsql).each do |rec|
							seqchkfields[rec["pobject_code_sfd"]] = rec["screenfield_seqno"]
			  			end  
			  			seqchkfields[setParams[:parse_linedata][:pobject_code_sfd]] = setParams[:parse_linedata][:screenfield_seqno]
			  			if (seqchkfields["screenfield_starttime"]||="99999") <  (seqchkfields["screenfield_duedate"]||="0")
							setParams[:err] =  " error starttime seqno > duedate seqno  line:#{setParams[:index]} "
							command_c[:confirm_gridmessage] = setParams[:err] 
							command_c[:confirm] = false 
			  			else
							if (seqchkfields["screenfield_qty_case"]||="99999") <  (seqchkfields["screenfield_qty"]||="0")
								setParams[:err] =  " error qty_case seqno > qty seqno  line:#{setParams[:index]} "  ###画面表示順　　包装単位の計算ため
								command_c[:confirm_gridmessage] = setParams[:err] 
								command_c[:confirm] = false 
							end
			  			end
					end
					if setParams[:err].nil?  ###一画面分纏めてcommit
						setParams,command_c = blk.proc_add_update_table(setParams,command_c)
						setParams = ok_confirm(setParams,command_c,tblnamechop)
						ArelCtl.proc_materiallized tblnamechop+"s"
					else
			  		end 
				when /trngantts|alloctbls/  ### blk.proc_private_aud_rec　使用せず
						base = {"srctblname" => "lotstkhists"}
						case screenCode
						when /update_trngantts/
							command_c["sio_classname"] = "_edit_update_grid_linedata"
							setParams,command_c = blk.proc_add_update_table(setParams,command_c) 
							if command_c["sio_result_f"]  == "9"
								command_c[:confirm] = false  
							else
								setParams = ok_confirm(setParams,command_c,tblnamechop)
							end
						when  /freetoalloc_alloctbls/
							begin
								ActiveRecord::Base.connection.begin_db_transaction()
								src["trngantts_id"] = params[:parse_linedata][:alloctbl_trngantt_id_src]
								src["srctblname"] = "lotstkhists"
								src["tblname"] = params[:parse_linedata][:alloctbl_srctblname_src]
								src["tblid"]  = params[:parse_linedata][:alloctbl_srctblid_src]
								src["alloctbls_id"]  = params[:parse_linedata][:alloctbl_id_src]
								####src["qty_linkto_alloctbl"]  = parse_linedata[:trngantt_qty_sch]
								base["trngantts_id"] = params[:parse_linedata][:alloctbl_trngantt_id_free]
								base["tblname"] = params[:parse_linedata][:alloctbl_srctblname_free]
								base["tblid"] = params[:parse_linedata][:alloctbl_srctblid_free]
								base["qty_src"] = params[:parse_linedata][:dummy_qty_alloc]
								base["amt_src"] = 0
								base["alloctbls_id"]  = params[:parse_linedata][:alloctbl_id_free]
								strsql = %Q&select srctblid from inoutlotstks 
											where tblname = '#{base["tblname"]}' and tblid = #{base["tblid"]}
											and trngantts_id = #{base["trngantts_id"]} and srctblname = 'lotstkhists'  &
								base["srctblid"] = ActiveRecord::Base.connection.select_value(strsql)
								last_lotstks = ArelCtl.proc_add_linktbls_update_alloctbls(src,base)
								# Shipment.proc_alloc_change_inoutlotstk(base)
								###ArelCtl.proc_src_trn_stk_update(src,base)
								###ArelCtl.proc_src_base_trn_stk_update(src,base)
							rescue
								command_c[:confirm] = false
								command_c["sio_result_f"] = "9"  ##9:error
								params[:err] = " state 500"
								params[:parse_linedata][:confirm] = false  
								ActiveRecord::Base.connection.rollback_db_transaction()
							else
								setParams = ok_confirm(setParams,command_c,tblnamechop)
								ActiveRecord::Base.connection.commit_db_transaction()
							end
						when  /insert_trngantts/
							begin
								ActiveRecord::Base.connection.begin_db_transaction()
								gantt = {}
								params[:parse_linedata].each do |symkey,v|
									strkey = symkey.to_s
									ganttkey = strkey.sub("trngantt_","")
									if strkey =~ /^trngantt_/
										gantt[strkey] = v
									end
								end
								gantt["trngantts_id"] = ArelCtl.proc_get_nextval("trngantts_seq")
								strsql = %Q&
											select count(key) from trngantts t 	
												where t.key like '%#{params[:parse_linedata][:trngantt_key]}'
														and orgtblid = #{params[:parse_linedata][:trngantt_orgtblid]} 
														and orgtblname = '#{params[:parse_linedata][:trngantt_orgtblname]}' 
								&
								trnganttkey = ActiveRecord::Base.connection.select_value(strsql)
								gantt["key"] = params[:parse_linedata][:trngantt_key] + format('%05d', trnganttkey.to_i + 1)
								gantt["mlevel"] = params[:parse_linedata][:trngantt_mlevel].to_i + 1
								###gantt["qty_sch"] = params[:parse_linedata][:trngantt_qty_sch]
								gantt["qty"] = 0
								gantt["qty_stk"] = 0
								gantt["qty_require"] = 0
								gantt["qty_handover"] = 0
								gantt["consumunitqty"]	=	case  params[:parse_linedata][:trngantt_consumunitqty].to_i 
															when 0 then 1 
															else gantt["consumunitqty"].to_i 
															end
								gantt["qty_sch"] = CtlFields.proc_cal_qty_sch(gantt["qty_sch_pare"].to_f,gantt["chilnum"].to_f,gantt["parenum"].to_f,
															gantt["consumunitqty"],gantt["consumminqty"].to_f,gantt["consumchgoverqty"].to_f)
								gantt["persons_id_upd"] = params["person_id_upd"]
								last_lotstks = ArelCtl.proc_insert_trngantts(gantt,{})   ###子。孫への展開はない
							rescue
								command_c[:confirm] = false
								command_c["sio_result_f"] = "9"  ##9:error
								params[:err] = " state 500"
								params[:parse_linedata][:confirm] = false  
								ActiveRecord::Base.connection.rollback_db_transaction()
							else
								setParams = ok_confirm(setParams,command_c,tblnamechop)
								ActiveRecord::Base.connection.commit_db_transaction()
                setParams["last_lotstks"] = last_lotstks.dup
							end
						end			
            if setParams["last_lotstks"] 
              setParams["segment"]  = "link_lotstkhists_update"
              setParams["tbldata"] = {}
              setParams["gantt"] = {}
              processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
            end
					return setParams
				#when /custactheads/
					# case setParams[:buttonflg]
					# when /confirmAll|MkInvoiceNo/   ###一画面分纏めてcommit
					# 	setParams = blk.proc_private_aud_rec(params,command_c)
					# 	if setParams[:buttonflg] =~ /confirmAll/  
					# 		strsql = nil
					# 		setParams[:parse_linedata].each do |field,val|
					# 			if val and val != ""
					# 				case field
					# 				when /_sno_/
					# 					tblnamechop = val.split("_sno_")[1] 
					# 					strsql = %Q&select * from r_#{tblnamechop}s where #{tblnamechop}_sno = '#{val}'& 
					# 				when /_cno_/
					# 					tblnamechop = val.split("_cno_")[1]
					# 					strsql = %Q&select * from r_#{tblnamechop}s where #{tblnamechop}_cno = '#{val}'
					# 							and #{tblnamechop}_cust_id  = #{setParams[:parse_linedata]["custacthead_cust_id"]} &
					# 				when /_packinglistnos/
					# 					tblnamechop = "custdlv" 
					# 					strsql = %Q&select * from r_#{tblnamechop}s where #{tblnamechop}_packinglistno = '#{val}'
					# 							and #{tblnamechop}_cust_id  = #{setParams[:parse_linedata]["custacthead_cust_id"]} &
					# 				else
					# 					next
					# 				end
					# 				if strsql
					# 					ActiveRecord::Base.connection.select_all(strsql).each do |fmView|  ###rec:custords custdlvs
					# 						linksql = %Q&
					# 							select id from linkcusts where srctblname = '#{tblnamechop}s' and srctblid = #{rec["id"]}
					# 							&
					# 						link = ActiveRecord::Base.connection.select_one(linksql)
					# 						if link
					# 							if link["tblname"] == "custacts"  ###修正できるのはpclinglistnoとinvoicenoのみ
					# 								setParams[:classname] = "_update_"
					# 								custacthead = ArelCtl.proc_createDetailTableFmHead "custactheads",tblnamechop+"s",command_c,fmView,setParams = [:classname] 
					# 							else
					# 								setParams[:err] = " error #{key} logic error line:#{setParams[:index]} "
					# 								break
					# 							end
					# 						else
					# 							setParams[:classname] =  "_add_"
					# 							custacthead = ArelCtl.proc_createDetailTableFmHead  "custactheads",tblnamechop+"s",command_c,fmView,setParams = [:classname] 
					# 						end
					# 					end
					# 					setParams["custactheads"] << custacthead
					# 					break
					# 				end
					# 			end
					# 		end
					# 	end
					# else
					# 	setParams,command_c = blk.proc_add_update_table(setParams,command_c) 
					# 	if command_c["sio_result_f"]  == "9"
					# 		command_c[:confirm] = false  
					# 	else
					# 		setParams = ok_confirm(setParams,command_c,tblnamechop)
					# 	end
					# end
				#when /cust1_custords/
					# setParams,command_c = blk.proc_add_update_table(setParams,command_c) 
					# if command_c["sio_result_f"]  == "9"
					# 	command_c[:confirm] = false  
					# else
					# 	setParams = ok_confirm(setParams,command_c,tblnamechop)
					# end

				#when /dlvs$/
					# case setParams[:buttonflg]
					# when /MkPackingListNo/  
					# 	setParams = blk.proc_private_aud_rec(params,command_c) 
					# else
					# 	setParams,command_c = blk.proc_add_update_table(setParams,command_c) 
					# 	if command_c["sio_result_f"]  == "9"
					# 		command_c[:confirm] = false  
					# 	else
					# 		setParams = ok_confirm(setParams,command_c,tblnamechop)
					# 	end
					# end
				else
					setParams,command_c = blk.proc_add_update_table(setParams,command_c) 
					if command_c["sio_result_f"]  == "9"
						command_c[:confirm] = false  
					else
						setParams = ok_confirm(setParams,command_c,tblnamechop)
					  	ArelCtl.proc_materiallized tblnamechop+"s"
					end
				end
			else
				command_c[:confirm] = false
        command_c["sio_result_f"] = "9"  ##9:error
				setParams[:parse_linedata][:confirm] = false  
			end
			return setParams
		end

		def ok_confirm(setParams,command_c,tblnamechop)
			setParams[:parse_linedata][:id] = command_c["id"]
			setParams[:parse_linedata][(tblnamechop+"_id").to_sym] = command_c[tblnamechop+"_id"]
			setParams[:parse_linedata][:confirm] = true  
			setParams[:parse_linedata][:confirm_gridmessage] = "done"
			return setParams
		end

		def proc_second_shpview params
			tmp = []
			err = ""
			innerjoinTblName = ""
			strselects = "("
			mainTblName = params["screenCode"].split("_",2)[1] 

			(params["clickIndex"]).each_with_index  do |selected,idx|  ###-次のフェーズに進んでないこと。
				selected = JSON.parse(selected)
				if idx == 0
					innerjoinTblName = selected["screenCode"].split("_",2)[1]
				end
				strselects << selected["id"]+ ","
			end
			strselects = strselects.chop + ")"
			str_innerjoin = %Q&
							inner join (select id second_id from  #{innerjoinTblName} 
									where id in #{strselects}
									) second on main.#{mainTblName.chop}_paretblid = second.second_id
							where main.#{mainTblName.chop}_paretblname = '#{innerjoinTblName}'
					& 
			str_orderby = %Q&order by #{mainTblName.chop}_paretblid,id desc &
      params[:sortBy] = params[:groupBy] = []
      params[:aggregations] = {}
			
			strsql = %Q&select   #{grid_columns_info[:select_fields]} 
						from (SELECT ROW_NUMBER() OVER (#{str_orderby}) ,#{grid_columns_info[:select_row_fields]} 
								FROM #{screenCode} main
						#{str_innerjoin}) x
							where ROW_NUMBER > #{(params[:pageIndex].to_f)*params[:pageSize].to_f} 
							and ROW_NUMBER <= #{(params[:pageIndex].to_f + 1)*params[:pageSize].to_f} 
					&
			pagedata = ActiveRecord::Base.connection.select_all(strsql)
		
			strsql = %Q& select count(*) FROM #{screenCode} main 
								#{str_innerjoin}
				&
		 	###fillterがあるので、table名は抽出条件に合わず使用できない。
			totalCount = ActiveRecord::Base.connection.select_value(strsql)
			params[:pageCount] = (totalCount.to_f/params[:pageSize].to_f).ceil
			params[:totalCount] = totalCount.to_f
			params[:parse_linedata] = {}
			return pagedata,params 
		end
    ###
    #   dvs erc
    ###
		def proc_second_dvserc params
			tmp = []
			err = ""
			innerjoinTblName = ""
      mainTblName = screenCode.split("_")[1]
			strselects = "("

			(params["clickIndex"]).each_with_index  do |selected,idx|  ###-次のフェーズに進んでないこと。
				selected = JSON.parse(selected)
				if idx == 0
					innerjoinTblName = selected["screenCode"].split("_",2)[1]
				end
				strselects << selected["id"]+ ","
			end
			strselects = strselects.chop
      strselects << ")"
			str_innerjoin = %Q&
							inner join (select id second_id from  #{innerjoinTblName} 
									where id in #{strselects}
									) second on main.#{mainTblName.chop}_#{innerjoinTblName.chop}_id_#{mainTblName.chop} = second.second_id
					& 
			str_orderby = ""
      params[:sortBy] = params[:groupBy] = []
      params[:aggregations] = {}
			
			strsql = %Q&select   #{grid_columns_info[:select_fields]} 
						from (SELECT ROW_NUMBER() OVER (#{str_orderby}) ,#{grid_columns_info[:select_row_fields]} 
								FROM #{params[:view]} main
						#{str_innerjoin}) x
							where ROW_NUMBER > #{(params[:pageIndex].to_f)*params[:pageSize].to_f} 
							and ROW_NUMBER <= #{(params[:pageIndex].to_f + 1)*params[:pageSize].to_f} 
					&
			pagedata = ActiveRecord::Base.connection.select_all(strsql)
		
			strsql = %Q& select count(*) FROM #{params[:view]} main 
								#{str_innerjoin}
				&
		 	###fillterがあるので、table名は抽出条件に合わず使用できない。
			totalCount = ActiveRecord::Base.connection.select_value(strsql)
			params[:pageCount] = (totalCount.to_f/params[:pageSize].to_f).ceil
			params[:totalCount] = totalCount.to_f
			params[:parse_linedata] = {}
			return pagedata,params 
		end	
		
		def proc_showdetail params
			setParams = params.dup
			mainTblName = screenCode.split("_",2)[1]   ###detail table name
			innerjoinPareTbl = paretblid = ""
			params[:clickIndex].each do |selectLine|  ###画面で一行のみselectされている。
				jsonSelectLine = JSON.parse(selectLine)
				if jsonSelectLine["lineId"]
					innerjoinPareTbl = jsonSelectLine["screenCode"].split("_",2)[1]
					paretblid = jsonSelectLine["id"]
					break
				end
			end
	
			str_innerjoin = %Q&
							inner join (select tblid from  linkheads 
									where paretblid = #{paretblid} and paretblname ='#{innerjoinPareTbl}'
									and tblname = '#{mainTblName}'
									) link on detail.id = link.tblid
					& 
			str_orderby = %Q&order by id desc &
			setParams[:sortBy] = setParams[:groupBy] = [] 
			setParams[:aggregations] = {}
			
			strsql = %Q&select   #{grid_columns_info[:select_fields]} 
						from (SELECT ROW_NUMBER() OVER (#{str_orderby}) ,#{grid_columns_info[:select_row_fields]} 
								FROM r_#{mainTblName} detail
						#{str_innerjoin}) x
							where ROW_NUMBER > #{(params[:pageIndex].to_f)*params[:pageSize].to_f} 
							and ROW_NUMBER <= #{(params[:pageIndex].to_f + 1)*params[:pageSize].to_f} 
					&
			pagedata = ActiveRecord::Base.connection.select_all(strsql)
		
			strsql = %Q& select count(*) FROM #{mainTblName} detail
								#{str_innerjoin}
				&
		 	###fillterがあるので、table名は抽出条件に合わず使用できない。
			totalCount = ActiveRecord::Base.connection.select_value(strsql)
			setParams[:pageCount] = (totalCount.to_f/params[:pageSize].to_f).ceil
			setParams[:totalCount] = totalCount.to_f
			setParams[:parse_linedata] = {}
			return pagedata,setParams 
		end	

		def proc_add_custact_details(params)  ###  from custactheads to custacts
			setParams = params.dup
			prevs = []
			outqty = totalAmt = 0
			err = nil
			pareview,paretblname = screenCode.split("_")
			parse_linedata = params[:parse_linedata].dup
			tbldata = params["tbldata"].dup
			if parse_linedata[:custacthead_packinglistnos].size > 0
				strsql = %Q&
						select 'custdlvs' tblname,dlv.*,link.id link_id,link.trngantts_id,dlv.id tblid from r_custdlvs dlv
												inner join linkcusts link on link.tblname = 'custdlvs' and link.tblid = dlv.id and link.qty_src > 0
												where dlv.custdlv_packinglistno in('#{parse_linedata[:custacthead_packinglistnos].split(",").join("','")}')
												and dlv.custdlv_cust_id = #{parse_linedata[:custacthead_cust_id]}
					&
				prevs = 	ActiveRecord::Base.connection.select_all(strsql)
			else
				if tbldata["sno_custordhead"].size > 0
					strsql = %Q&
								select act.*,alloc.id link_id,alloc.trngantts_id from linkcusts alloc
									inner join (select * from custordheads head 
													inner join linkheads link link.paretblid = head.id 
														where head.sno = '#{parse_linedata[:custacthead_sno_custordhead]}' and link.paretblname = 'custordheads' 
															and custs_id = #{parse_linedata[:custacthead_cust_id]}) head
									on head.tblid = alloc.tblid and alloc.srctblname = 'custords'
									inner join inoutlotstks act on alloc.trngantts_id = act.trngantts_id 
									where	alloc.qty_src > 0 		 		
					&
					ActiveRecord::Base.connection.select_all(strsql).each do |rec|
						detailsql = %Q&
										select '#{rec["tblname"]}' tblname,'#{rec["link_id"]}' link_id,'#{rec["trngantts_id"]}' trngantts_id,* 
													from r_#{rec["tblname"]} where id = #{rec["tblid"]}
						&
						prevs << ActiveRecord::Base.connection.select_one(detailsql) 
					end
				else
					if tbldata["cno_custordhead"].size > 0
						strsql = %Q&
							select act.*,alloc.id link_id,alloc.trngantts_id  from linkcusts alloc
								inner join (select * from custordheads head 
												inner join linkheads link link.paretblid = head.id 
												where head.cno = '#{parse_linedata[:custacthead_cno_custordhead]}' and link.paretblname = 'custordheads' 
												and custs_id = #{parse_linedata[:custacthead_cust_id]}) head
									on head.tblid = alloc.tblid and alloc.srctblname = 'custords'
								inner join inoutlotstks act on alloc.trngantts_id = act.trngantts_id 
								where	alloc.qty_src > 0 		
							&
						ActiveRecord::Base.connection.select_all(strsql).each do |rec|
							detailsql = %Q&
									select  '#{rec["tblname"]}' tblname,'#{rec["link_id"]}' link_id,'#{rec["trngantts_id"]}' trngantts_id,* 
																from r_#{rec["tblname"]} where id = #{rec["tblid"]}
									&
							prevs << ActiveRecord::Base.connection.select_one(detailsql) 
						end
					end
				end
			end
			fields =  ActiveRecord::Base.connection.select_values(%Q&
							select pobject_code_sfd from func_get_screenfield_grpname('#{params["email"]}','#{pareview}_custacts')&)
			custact =  RorBlkCtl::BlkClass.new("#{pareview}_custacts")
			linktbl_ids = []
			amtTaxRate = {}
			prevs.each do |prev|
				command_custact = custact.command_init
				command_custact["sio_classname"] = "detail_add_custacts"
				command_custact["custact_created_at"] = Time.now
				command_custact["id"] = ArelCtl.proc_get_nextval("custacts_seq")
			  command_custact["custact_person_id_upd"] = params["person_id_upd"]
			  command_custact["custact_saledate"] = tbldata["saledate"]
				prev.each do |key,val|
					next if key == "id"
					next if key == "tblname"
					next if key =~ /#{prev["tblname"]}_id$|#{prev["tblname"]}_sno$|#{prev["tblname"]}_cno$|#{prev["tblname"]}_gno$/
					if fields.grep(key.sub("#{prev["tblname"].chop}","custact")).empty?
            case key
            when /#{prev["tblname"].chop}_duedate_custord/
					    command_custact["custact_duedate_custord"] = val  ##custact_duedate_custord
            end
          else
					  command_custact[key.sub("#{prev["tblname"].chop}","custact")] = val
          end
					outqty += val.to_f if key =~ /qty$|qty_stk$/
					totalAmt += val.to_f if key =~ /amt$/
				end
				command_custact = custact.proc_create_tbldata(command_custact) ###
				if amtTaxRate[command_custact["custact_taxrate"].to_s]
				    amtTaxRate[command_custact["custact_taxrate"].to_s]["amt"] += command_custact["custact_amt"].to_f
				    amtTaxRate[command_custact["custact_taxrate"].to_s]["qty"] += command_custact["custact_qty_stk"].to_f
				    amtTaxRate[command_custact["custact_taxrate"].to_s]["count"] += 1
				else
				    amtTaxRate[command_custact["custact_taxrate"].to_s] = {"amt" => command_custact["custact_amt"].to_f,
															"qty" => command_custact["custact_qty_stk"].to_f,"count" => 1}
				end
				custact.proc_private_aud_rec({},command_custact)  ### add custacts
				###
				#
				###
				base = {"tblname" => "custacts" ,	"tblid" => command_custact["id"],
									"qty_src" => command_custact["custact_qty_stk"] ,
									"amt_src" => command_custact["custact_amt"]  ,
									"trngantts_id" => prev["trngantts_id"],"persons_id_upd" => setParams["person_id_upd"]}
				linktbl_ids  << ArelCtl.proc_insert_linkcusts(prev,base)
							update_strsql = %Q&
								update  linkcusts link set qty_src = qty_src - #{command_custact["custact_qty_stk"]}
															,amt_src = amt_src - #{command_custact["custact_amt"]} 
															,remark = ' #{self} line:#{__LINE__} '||remark
												where id  = '#{prev["link_id"]}'
							&
				ActiveRecord::Base.connection.update(update_strsql)
				###
				# 親子関係作成
				###
					ArelCtl.proc_insert_linkheads(params[:head],{"tblname" => "custacts","tblid" => command_custact["id"],"persons_id_upd" => setParams["person_id_upd"]})
				###
				#
				###
			end
			return amtTaxRate ,err
		end
  
		def undefined
		  nil
		end
	end  
end   ##module ScreenLib
