# -*- coding: utf-8 -*-
module TblField   ###developmentのみで起動
extend self
	def proc_blktbs params  ### r_blktbs又はr_tblfieldsから呼ばれることを想定
		@checktbls = {}   ### 対象となるテーブル群
		@tblsfields = {}   ### テーブルのfields
		@messages =[]
		@modifysql = ""
		@add_id_to_tbl = {}   ### FIELD・・・s_idが追加された for foreign_key
		@delete_id_to_tbl = {}  # ### FIELD・・・s_idが削除された
		@screenfields = {}
		skip_tblnames = ["persons","prjnos","scrlvs","locas","usrgrps","chrgs","pobjgrps","reports","pobjects"]
		if params["data"]   ###画面でのチェックができなかった。
			@params = params.dup
		else
			@messages << " no data"
			@modifysql = ""
			return @messages,@modifysql
		end	
		noerror = true
		begin
			ActiveRecord::Base.connection.begin_db_transaction()
			params["data"].each do |lineData|
				linedata = JSON.parse(lineData)
				if @checktbls[linedata["pobject_code_tbl"]] ###該当テーブル処理済
					next
				else
			    	@checktbls[linedata["pobject_code_tbl"]]="done"
					if skip_tblnames.find {|n| n== linedata["pobject_code_tbl"]}  ###自己参照のため使用できない。
						@messages << " #{linedata["pobject_code_tbl"]} can not use create view program "
						return 	@messages,@modifysql
					end
					strsql = %Q&
							select 	fld.ftype fieldcode_ftype,fld.dataprecision fieldcode_dataprecision,fld.datascale fieldcode_datascale,
									fld.fieldlength fieldcode_fieldlength,
									fld.pobject_code_fld pobject_code_fld,
									tbl.code pobject_code_tbl,t.id,t.id fieldcode_tblfield_id,
									t.created_at,t.updated_at,t.update_ip,persons_id_upd,t.expiredate tblfield_expiredate
			 					from tblfields t
			 						inner join (select f.id,p.code,p.objecttype, 
							  							f.ftype ,f.dataprecision ,f.datascale ,
														f.fieldlength ,p.code pobject_code_fld 
													from fieldcodes f inner join  pobjects p  
						 							on f.pobjects_id_fld = p.id and p.objecttype = 'tbl_field' ) fld 
				 						on t.fieldcodes_id  = fld.id
			 						inner join (select b.id,p.code from blktbs b inner join  pobjects p  
																	on b.pobjects_id_tbl = p.id and p.objecttype = 'tbl' ) tbl								
										on t.blktbs_id = tbl.id 
			 				where  tbl.code = '#{linedata["pobject_code_tbl"]}'	and t.expiredate > current_date  
					&
					recs = ActiveRecord::Base.connection.select_all(strsql)  ###画面から依頼されたテーブル、項目の登録変更依頼データ	

					strsql = "select 	* from 	information_schema.columns 
									where 	table_catalog='#{ActiveRecord::Base.configurations["development"]["database"]}' 
									and table_name='#{linedata["pobject_code_tbl"]}' "
					columns = {}
					ActiveRecord::Base.connection.select_all(strsql).each do |column|  ###postgresqlに登録分
						columns[column["column_name"]] = column
					end

					if recs.empty?
						@messages << "table #{linedata["pobject_code_tbl"]} has not field "	
						ActiveRecord::Base.connection.rollback_db_transaction()
						return @messages,@modifysql
					else
						@tblsfields[linedata["pobject_code_tbl"]] = {}  ###@tblsfields = {tblname =>{field =>tblrecOfField}}
						recs.each do |rec|
							@tblsfields[linedata["pobject_code_tbl"]][rec["pobject_code_fld"]] = rec
						end
						if columns.empty?
							###create_tbl_view_screenfields linedata["pobject_code_tbl"]
							create_tbl_and_add_view_screenfields_id @tblsfields[linedata["pobject_code_tbl"]]
						else
							###modify_tblfield_and_view_screenfields linedata["pobject_code_tbl"]
							modify_tblfield_and_for_view_screenfields @tblsfields[linedata["pobject_code_tbl"]],columns
							delete_tblfields @tblsfields[linedata["pobject_code_tbl"]],columns  ###テーブルの削除はない。
						end
					end

					if @tblsfields[linedata["pobject_code_tbl"]].nil?
						@messages << "table #{linedata["pobject_code_tbl"]} not exists "
						ActiveRecord::Base.connection.rollback_db_transaction()
						return @messages,@modifysql
					else
						if @tblsfields[linedata["pobject_code_tbl"]]["id"].nil?
							@messages << "table #{linedata["pobject_code_tbl"]} has not id "
							ActiveRecord::Base.connection.rollback_db_transaction()
							return @messages,@modifysql
						end
					end
				end
			end	
			###テーブルの追加修正が完了したので、画面項目とviewの作成
			###set_fields
			@checktbls.each do |tbl,flg|
				if flg == "done"
					##@add_delete_recs = []
					add_default_screenfield tbl,@tblsfields[tbl]
					###sioの作成
					create_sio_table "r_#{tbl}"
					chk_viewfields_exists tbl
				else
					noerror = false
				end	
			end	
			@checktbls.each do |tbl,flg|  ###sql　を分けるため別にした。 
				if flg == "done"
					if @add_id_to_tbl[tbl]
						create_foreign_key_constraint tbl
					end
					if @delete_id_to_tbl[tbl]
						delete_foreign_key_constraint tbl
					end
					###seq の作成
					strsql = "SELECT c.relname FROM pg_class c LEFT join pg_user u ON c.relowner = u.usesysid 
							WHERE c.relkind = 'S' and c.relname='#{tbl}_seq'"
					chk = ActiveRecord::Base.connection.select_one(strsql)
					if chk
					else		
						###@modifysql <<  "\n drop sequence  if exists  #{tbl}_seq ;"
						@modifysql <<  "\n create sequence #{tbl}_seq ;"
					end
				else
					noerror = false
				end
			end
		rescue
        		ActiveRecord::Base.connection.rollback_db_transaction()
            	Rails.logger.debug"error class #{self} : #{Time.now}: #{$@} "
          		Rails.logger.debug"error class #{self} : $!: #{$!} "
          		Rails.logger.debug"  params: #{params} "
				status = 500
				errmsg = $!
      	else
			if noerror
				status = 200
				ergmsg = ""
				ActiveRecord::Base.connection.commit_db_transaction()
			end
      	ensure
	  	end ##begin
		return 	@messages,@modifysql,status,errmsg
	end

	def delete_tblfields fields,columns  ###{ fields={field =>tblrecOfField}}  tblrecOfField ={fieldcode_ftype=>xx,fieldcode_dataprecision..}
		del_columns = columns.dup
		fields.each do |pobject_code_fld,field|
			del_columns.delete(pobject_code_fld)   ###未使用のfieldを残す
		end	

		del_columns.each do |del_column,col|
			create_drop_field_sql col["table_name"],del_column
		end
	end	

	def modify_tblfield_and_for_view_screenfields fields,columns ### pobject_code_tbl
		fields.each do |pobject_code_fld,rec|	
			if columns[pobject_code_fld]
				modify_field rec,columns[pobject_code_fld]
			else 
				create_add_field_sql rec  ###該当テーブルの項目作成
			end		
			if pobject_code_fld =~ /s_id/
				if  @add_id_to_tbl[rec["pobject_code_tbl"]] 
					@add_id_to_tbl[rec["pobject_code_tbl"]]  << pobject_code_fld 
				else
					@add_id_to_tbl[rec["pobject_code_tbl"]] =[] 
					@add_id_to_tbl[rec["pobject_code_tbl"]]  << pobject_code_fld 
				end	
			end		
		end	
	end	

	def modify_field rec,field
		if field["column_name"] == rec["pobject_code_fld"]
			if (field["udt_name"] == rec["fieldcode_ftype"] or (field["udt_name"] == 'bpchar' and  rec["fieldcode_ftype"] == 'char'))
				case field["udt_name"] 
				when "varchar","char"
					if field["character_maximum_length"] > rec["fieldcode_fieldlength"].to_i
					   	rslt = check_exists_fieldid rec["pobject_code_tbl"],rec["pobject_code_fld"]
					  	if rslt
							@messages << rslt
							@checktbls[rec["pobject_code_tbl"]]= "NG"
					   	else	 
							create_modify_field_sql rec
						end
					else  
						if field["character_maximum_length"] < rec["fieldcode_fieldlength"].to_i
							create_modify_field_sql rec
						end
					end
				when "numeric"
						if  (field["numeric_precision"]||=22)  <= rec["fieldcode_dataprecision"].to_i  and 
							(field["numeric_scale"]||=0)  <= rec["fieldcode_datascale"].to_i 
							if  field["numeric_precision"] == rec["fieldcode_dataprecision"].to_i  and 
								field["numeric_scale"]  == rec["fieldcode_datascale"].to_i 
								###修正なし
							else
								create_modify_field_sql rec
							end		
						else
							rslt = check_exists_fieldid rec["pobject_code_tbl"],rec["pobject_code_fld"]
						   	if rslt
								@messages << rslt
								@checktbls[rec["pobject_code_tbl"]]= "NG"
							else	 
								create_modify_field_sql rec
							end
						end
				else	
					###修正なし
				end			
			else
				if field["udt_name"] =~ /timestamp/ and  rec["fieldcode_ftype"] =~ /timestamp/
					###何もしない。
				else
					rslt = check_exists_fieldid rec["pobject_code_tbl"],rec["pobject_code_fld"]
			    	if rslt
						@messages << rslt
						@checktbls[rec["pobject_code_tbl"]]= "NG"
					else		 
						create_drop_field_sql rec["pobject_code_tbl"], rec["pobject_code_fld"]
						create_add_field_sql  rec ###該当テーブルの項目作成	
					end
				end		
			end
		else
			p" err	modify field 001"
			raise
		end	
	end 

	def check_exists_fieldid table_name,column_name
		strsql = "select id,#{column_name} from #{table_name} where #{column_name} is not null"
		rec = ActiveRecord::Base.connection.select_one(strsql)
		if rec
			rslt = "modify COLUMN but already used table:#{table_name},field:#{column_name},value:#{rec[column_name]} "
		else
			rslt = nil	
		end
		return rslt
	end		

	def create_drop_field_sql table_name,column_name
		@modifysql << "\n alter table #{ table_name} DROP COLUMN #{column_name} CASCADE;\n"
		@modifysql << "\n --- 使用しているview "
		@modifysql << "\n --- select * from pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end select,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields "
		@modifysql << "\n ---- where  pobject_code_sfd = '#{column_name}'"
		@modifysql << "\n  update screenfields set expiredate = '2000/1/1',remark = 'auto delete because of DROP COLUMN #{column_name}' " 
		@modifysql << "\n         ,updated_at = current_date " 
		@modifysql << "\n         where id in  (select id from r_screenfields where  pobject_code_sfd = 'screenfield_#{column_name}' "
		@modifysql << "\n         											and  pobject_code_scr = 'r_#{table_name}' );"
	end	

	def create_modify_field_sql rec
		case rec["fieldcode_ftype"]
		when /char/
			@modifysql << "\n alter table #{rec["pobject_code_tbl"]} ALTER COLUMN #{rec["pobject_code_fld"]}  TYPE #{rec["fieldcode_ftype"]}(#{rec["fieldcode_fieldlength"] })"
			case rec["pobject_code_fld"]
			when  "sno"
				create_uniq_constraint rec["pobject_code_tbl"],"_sno",["sno"]
			when "cno" 
				case  rec["pobject_code_tbl"]
				when /^custschs|^custords|^custinsts|^custdlvs|^custacts/
					create_uniq_constraint rec["pobject_code_tbl"],"_cno",["custs_id","cno"]
				when /^purschs|^purords|^purinsts|^purdlvs|^puracts/
					create_uniq_constraint rec["pobject_code_tbl"],"_cno",["suppliers_id","cno"]
				when /^prdschs|^prdords|^prdinsts|^prdacts/
					create_uniq_constraint rec["pobject_code_tbl"],"_cno",["workplaces_id","cno"]
				end
			when "gno"
				##@modifysql << ";\n alter table #{rec["pobject_code_tbl"]} ALTER COLUMN #{rec["pobject_code_fld"]}  set not null;\n"
				###手動で設定
				create_uniq_constraint rec["pobject_code_tbl"],"_gno",["gno","id"]
			else
				@modifysql << " ;\n"
			end	
		when "numeric"
			@modifysql << "\n alter table  #{rec["pobject_code_tbl"]} ALTER COLUMN #{rec["pobject_code_fld"]}  TYPE #{rec["fieldcode_ftype"]}(#{rec["fieldcode_dataprecision"]},#{rec["fieldcode_datascale"]})"
			if rec["pobject_code_fld"] =~ /_id$|_id_/
				@modifysql << " not null;\n"
			else
				@modifysql << " ;\n"
			end	
        end
	end

	def create_add_field_sql rec  ###該当テーブルの項目作成
		case rec["fieldcode_ftype"]
		when /char/
			@modifysql << "\n alter table #{rec["pobject_code_tbl"]}  ADD COLUMN #{rec["pobject_code_fld"]} #{rec["fieldcode_ftype"]}(#{rec["fieldcode_fieldlength"] });\n"
		when "numeric"
			@modifysql << "\n alter table  #{rec["pobject_code_tbl"]}  ADD COLUMN #{rec["pobject_code_fld"]} #{rec["fieldcode_ftype"]}(#{rec["fieldcode_dataprecision"]},#{rec["fieldcode_datascale"]})"
			if rec["pobject_code_fld"] =~ /_id$|_id_/
				@modifysql << "  DEFAULT 0  not null;\n"
			else
				@modifysql << " ;\n"
			end	
		when /date|timestamp/
			@modifysql << "\n alter table #{rec["pobject_code_tbl"]}  ADD COLUMN #{rec["pobject_code_fld"]} #{rec["fieldcode_ftype"]};\n"
		end	
	end	

	def add_default_screenfield tbl,tblfields
		strsql = "select s.id from screens s inner join pobjects p on pobjects_id_scr = p.id
							 where p.code ='r_#{tbl}' "
		screens_id = ActiveRecord::Base.connection.select_value(strsql)
		if screens_id 
			last_screenfields = {}
			ActiveRecord::Base.connection.select_all(last_screenfield_sql(tbl)).each do |screenfield|
				last_screenfields[screenfield["pobject_code_sfd"]] = screenfield
			end
			tblfields.each do |pobject_code_fld,field|
				case pobject_code_fld
					when /persons_id_upd/ 
						person_tbl = "persons" 
						delm = "_upd"
						person_screenfield = {}
						viewfield = "person_id_upd"
						ActiveRecord::Base.connection.select_all(screenfield_sql(person_tbl,nil)).each do |upd_field|
							case upd_field["pobject_code_sfd"]
							when "id"
								upd_field["pobject_code_sfd"] = "#{tbl.chop}_person_id_upd"
								person_screenfield[upd_field["pobject_code_sfd"]] = upd_field
							when "person_code"
								upd_field["screenfield_crtfield"] = "person_upd"
								upd_field["pobject_code_sfd"] = "person_code_upd"
								person_screenfield["person_code_upd"] = upd_field
							when "person_name"
								upd_field["screenfield_crtfield"] = "person_upd"
								upd_field["pobject_code_sfd"] = "person_name_upd"
								person_screenfield["person_name_upd"] = upd_field
							end
						end
						person_screenfield.each do |sfd,upd_field|
							if last_screenfields[sfd]
								last_screenfields.delete(sfd)   ###残った項目が削除対象
							else
								pobjects_id_sfd = chk_pobject_sfd_and_add(sfd)
								add_screenfield_record screens_id,pobjects_id_sfd,upd_field,"add",false
							end
						end
					when /s_id/
						viewfield =  tbl.chop +  "_" +  pobject_code_fld.sub("s_id","_id")
						if last_screenfields[viewfield].nil?
							pobjects_id_sfd = chk_pobject_sfd_and_add viewfield
							add_screenfield_record screens_id,pobjects_id_sfd,field,"add",true
						end
						othertbl,delm = pobject_code_fld.split("_id",2) 
						delm ||= ""
						other_screenfield = {}
						ActiveRecord::Base.connection.select_all(screenfield_sql(othertbl,false)).each do |other|
							other["pobject_code_sfd"] = other["pobject_code_sfd"] + delm
							other_screenfield[other["pobject_code_sfd"]] = other
						end
						other_screenfield.each do |other_sfd,other_field|
							last_other_sfd = last_screenfields[other_sfd] 
							if last_other_sfd
								last_other_sfd["screenfield_crtfield"] = othertbl.chop + delm
								add_screenfield_record screens_id,last_other_sfd["screenfield_pobject_id_sfd"],last_other_sfd,"update",false
								last_screenfields.delete(other_sfd)   ###残った項目が削除対象
							else	
								other_field["pobject_code_sfd"] = other_sfd
								other_field["pobject_code_scr"] = "r_#{tbl}"
								other_field["screenfield_crtfield"] = othertbl.chop + delm
								if delm 
									pobjects_id_sfd = chk_pobject_sfd_and_add(other_sfd)
									add_screenfield_record screens_id,pobjects_id_sfd,other_field,"add",false 
								else
									add_screenfield_record screens_id,other_screenfield["pobjects_id_sfd"],other_field,"add",false
								end
							end
						end
					when "id"
						viewfield = "id"
						pobjects_id_sfd = chk_pobject_sfd_and_add "id"  ###pobjects_id_sfdの返しまたは登録
						if last_screenfields["id"].nil?
							add_screenfield_record screens_id,pobjects_id_sfd,field,"add",true
						end
						viewfield = "#{tbl.chop}_id"
						pobjects_id_sfd = chk_pobject_sfd_and_add viewfield  ###pobjects_id_sfdの返しまたは登録
						if last_screenfields[viewfield].nil?
							add_screenfield_record screens_id,pobjects_id_sfd,field,"add",true
						end
					else
						viewfield = tbl.chop +  "_" + pobject_code_fld
						pobjects_id_sfd = chk_pobject_sfd_and_add viewfield  ###pobjects_id_sfdの返しまたは登録
						if last_screenfields[viewfield]
							if last_screenfields[viewfield]["screenfield_expiredate"].to_date > Time.now
								if last_screenfields[viewfield]["screenfield_updated_at"].to_time > field["updated_at"].to_time
								else
									add_screenfield_record screens_id,pobjects_id_sfd,last_screenfields[viewfield],"update",true
								end
							else
								add_screenfield_record screens_id,pobjects_id_sfd,last_screenfields[viewfield],"delete",true
							end
						else
							add_screenfield_record screens_id,pobjects_id_sfd,field,"add",true
						end
				end
				last_screenfields.delete(viewfield)   ###残った項目が削除対象
			end
			last_screenfields.each do |del_field,screenfield|   ###delete
				next if del_field == "id"
				next if del_field == "#{tbl.chop}_id"
				pobjects_id_sfd = chk_pobject_sfd_and_add del_field 
				add_screenfield_record screens_id,pobjects_id_sfd,screenfield,"delete",true
				if del_field =~ /_id/
					if  @delete_id_to_tbl[tbl] 
						@delete_id_to_tbl[tbl]  << del_field
					else
						@delete_id_to_tbl[tbl] = [] 
						@delete_id_to_tbl[tbl]  << del_field
					end
				end
			end
			create_viewfield "r_#{tbl}"
		else 
			### テーブルscreendsに登録されてない
			@messages << " <p>please add screen  to　screens   --> 'r_#{tbl}' </p>"
			strsql = "select * from pobjects where code ='r_#{tbl}' and objecttype = 'screen'"
			pobject_id_scr = ActiveRecord::Base.connection.select_one(strsql)
			if pobject_id_scr
				###ok
			else
				@messages << " <p>please  add screen code to pobjects --> 'r_#{tbl}' </p>"
			end	
			screens_id = nil
		end	
	end
	
	def create_tbl_and_add_view_screenfields_id fields ### pobject_code_tbl
		pobject_code_tbl = fields["id"]["pobject_code_tbl"]
		tmpstrsql = "\n create table #{pobject_code_tbl} ("
		
		fields.each do |pobject_code_fld,field|
			tmpstrsql << "\n #{pobject_code_fld} #{field["fieldcode_ftype"]}"
            case field["fieldcode_ftype"]
                when /char/
					tmpstrsql    << "(#{field["fieldcode_fieldlength"]})  "
                when /numeric/
					tmpstrsql    <<  if field["fieldcode_dataprecision"] == 0  or field["fieldcode_dataprecision"].nil? 
								 "(22,0) "
							else
								 "(" + field["fieldcode_dataprecision"].to_s + "," + (field["fieldcode_datascale"]||0).to_s + " )  "
							end 
				else
					tmpstrsql     <<     " "
			end	
			["id","code","name"].each do |indispf|
				if pobject_code_fld == indispf 
					tmpstrsql << " not null "
					break
				end
			end			
			if pobject_code_fld =~ /s_id/
				tmpstrsql << " not null ,"
			else	
				tmpstrsql << " ,"
			end 	
			if pobject_code_fld =~ /s_id/
				if  @add_id_to_tbl[pobject_code_tbl] 
					@add_id_to_tbl[pobject_code_tbl]  << pobject_code_fld 
				else
					@add_id_to_tbl[pobject_code_tbl] = [] 
					@add_id_to_tbl[pobject_code_tbl]  << pobject_code_fld 
				end	
			end	
    	end
		##  primkey key対応
		tmpstrsql<<  "\n  CONSTRAINT #{pobject_code_tbl}_id_pk PRIMARY KEY (id));"
		@modifysql << tmpstrsql
	end	
	
	def chk_pobject_sfd_and_add screenfield
		if @screenfields[screenfield]
			pobjects_id_sfd =  @screenfields[screenfield]
		else
			strsql = "select id,expiredate from pobjects where code = '#{screenfield}' and objecttype = 'view_field' "
			pobject = ActiveRecord::Base.connection.select_one(strsql)
			if pobject
				pobjects_id_sfd = pobject["id"]
				if pobject["expiredate"].to_date < Time.now
					update_pobject_record screenfield,pobjects_id_sfd
				end
			else	
				pobjects_id_sfd = add_pobject_record screenfield
			end
		end		
		return pobjects_id_sfd
	end	

	def  add_pobject_record screenfield
		blk = RorBlkCtl::BlkClass.new("r_pobjects")
		command_r = blk.command_init
		command_r["id"] == ""
		command_r["sio_classname"] = "_add_pobject_screenfield"
		command_r["pobject_id"] = ""
		command_r["pobject_remark"] = "auto add pobject screenfield #{screenfield}"
		command_r["pobject_code"] = screenfield
		command_r["pobject_objecttype"] = "view_field"
		command_r["pobject_expiredate"] = '2099/12/31'
		blk.proc_create_tbldata(command_r) ##
		setParams = blk.proc_private_aud_rec({},command_r)
		if command_r["sio_result_f"] ==   "9"
		 	@messages <<  "error  add_pobject_record #{screenfield}\n"
			@messages  << command_r["sio_message_contents"][0..200] + "\n"
			@messages  << command_r["sio_errline"][0..200] 
		end  
		return command_r["id"]
	end	
	
	def  update_pobject_record screenfield,id
		blk = RorBlkCtl::BlkClass.new("r_pobjects")
		command_c = blk.command_init
		command_r["id"] == id
		command_r["sio_classname"] = "_update_pobject_screenfield"
		command_r["pobject_id"] = ""
		command_r["pobject_remark"] = "auto add pobject screenfield #{screenfield}"
		command_r["pobject_code"] = screenfield
		command_r["pobject_objecttype"] = "view_field"
		command_r["pobject_expiredate"] = '2099/12/31'
		blk.proc_create_tbldata(command_c) ##
		setParams = blk.proc_private_aud_rec({},command_c)
		if command_r["sio_result_f"] ==   "9"
		 	@messages <<  "error  update_pobject_record #{screenfield}\n"
			 @messages  << command_r["sio_message_contents"][0..200] + "\n"
			@messages  << command_r["sio_errline"][0..200] 
		end  
	end

	def add_screenfield_record screens_id,pobjects_id_sfd,field,aud,owner  ###aud:add,update,delete   owner:自分自身の	テーブル?
		blk =  RorBlkCtl::BlkClass.new("r_screenfields")
		command_r = blk.command_init
		command_r["sio_classname"] = case aud
										when "add" 
											"_add_screenfield record"
										when "update"
											"_update_screenfields record"
										when "delete"
											"_delete_screenfields record"
										else
											" error screenfield_record  aud"
										end
		command_r["screenfield_id"] =  command_r["id"] =	case aud
																when	"add" 
																		""
																when /update|delete/
																		field["screenfield_id"]
																end
		command_r["screenfield_remark"] =	field["screenfield_remark"]
		command_r["screenfield_expiredate"] = (field["screenfield_expiredate"]||=field["tblfield_expiredate"])
		command_r["screenfield_screen_id"] = screens_id
		command_r["screenfield_indisp"] =	(field["screenfield_indisp"]||="0")
		command_r["screenfield_selection"] = 	if aud == "add"
														if owner == true
															"1"
														else 
															if field["pobject_code_sfd"] =~ /_code|_name|_sno|_cno|_go|person_id_upd|opeitm_/
																"1"
															else
																if command_r["screenfield_indisp"] != "0"   ###必須項目
																	"1"
																else	
																	"0"
																end
															end
														end
													else
														field["screenfield_selection"]			
													end
		command_r["screenfield_hideflg"] = if field["pobject_code_fld"] =~ /s_id/  or field["pobject_code_fld"] == "id"  or
												field["pobject_code_sfd"] =~ /_id/  or field["pobject_code_sfd"] == "id" then "1" else "0"  end
		command_r["screenfield_seqno"] =	if aud == "update"
													field["screenfield_seqno"]
												else
													case field["pobject_code_sfd"]
													when  /created_at|updated_at|update_ip|_id/  
	  													9990
													when "id"
														99999
													when /expiredate/
														8880
													when /remark/
														8885
													when /contents/
														8887
													when /_upd/
														8885
													when /_gno|_cno|_sno/ 
														500
													when /_name_/	
														400
													when /_code_/	
														300
													when /_name/	
														200
													when /_code/	
														100
													else
														600
													end
												end		
		command_r["screenfield_rowpos"]=(field["screenfield_rowpos"]||=0)
		command_r["screenfield_colpos"]=(field["screenfield_colpos"]||=0)
		command_r["screenfield_width"]=(field["screenfield_width"]||=120)
		command_r["screenfield_type"]=  case field["screenfield_type"]
											when nil
												field["fieldcode_ftype"]
											when ""
												field["fieldcode_ftype"]
											else
												field["screenfield_type"]
											end	
		command_r["screenfield_dataprecision"] = (field["screenfield_dataprecision"]||=field["fieldcode_dataprecision"])
		command_r["screenfield_datascale"] = (field["screenfield_datascale"]||=field["fieldcode_datascale"])
		command_r["screenfield_edoptmaxlength"] = (field["screenfield_edoptmaxlength"]||=0)
		command_r["screenfield_subindisp"] =  (field["screenfield_subindisp"]||="")
		command_r["screenfield_editable"] =	if field["pobject_code_sfd"]  =~ /_upd/
													"0"
												else
													if owner == true
														if field["screenfield_created_at"] == field["screenfield_updated_at"] 
															if field["pobject_code_sfd"] =~ /_id/ or field["pobject_code_sfd"] == "id"
																field["screenfield_editable"] = "0"
															else
																field["screenfield_editable"] = "1"
															end
														else
															field["screenfield_editable"]
														end
													else	 	
														if field["pobject_code_sfd"] =~ /_code/
															if field["screenfield_created_at"] == field["screenfield_updated_at"]
																"1"
															else
																field["screenfield_editable"]
															end
														else	
															if field["screenfield_created_at"] == field["screenfield_updated_at"]
																"0"
															else
																field["screenfield_editable"]
															end
														end
													end
												end
		command_r["screenfield_maxvalue"] = (field["screenfield_maxvalue"]||=0)
		command_r["screenfield_minvalue"] = (field["screenfield_minvalue"]||=0)
		command_r["screenfield_edoptsize"] = (field["screenfield_edoptsize"]||="0")
		command_r["screenfield_edoptrow"] = (field["screenfield_edoptrow"]||=0)
		command_r["screenfield_edoptcols"] = (field["screenfield_edoptcols"]||=0)
		if command_r["screenfield_type"] == "select"  
			command_r["screenfield_edoptvalue"] = (field["screenfield_edoptvalue"]||="0:未設定")
		else  
			command_r["screenfield_edoptvalue"] = (field["screenfield_edoptvalue"]||="0")
		end
		command_r["screenfield_pobject_id_sfd"] = pobjects_id_sfd
		command_r["screenfield_tblfield_id"] = (field["screenfield_tblfield_id"] ||=field["fieldcode_tblfield_id"])
		command_r["screenfield_paragraph"] = (field["screenfield_paragraph"]||="")
		command_r["screenfield_formatter"] = (field["screenfield_formatter"]||="")
		command_r["screenfield_crtfield"] = if owner == true
													""
												else
													field["screenfield_crtfield"]	
												end
				
		blk.proc_create_tbldata(command_r) ##
		setParams = blk.proc_private_aud_rec({},command_r)
		if command_r["sio_result_f"] ==   "9"
				@messages  << command_r["sio_message_contents"][0..200] + "\n"
			 	@messages  << command_r["sio_errline"][0..200] 
		 		@messages <<  "error  add screenfield record #{field["pobject_code_tbl"].chop}_#{field["pobject_code_fld"]}"
		else  
		  		@params[:addId] = command_r["id"]
		end  
	end	
	
	
	def create_viewfield screen   ##view
		strsql = "select sfd.code pobject_code_sfd,screenfield.crtfield screenfield_crtfield 
						from screenfields screenfield
						inner join pobjects sfd on screenfield.pobjects_id_sfd = sfd.id 
						inner join (select s.id,px.code pobject_code_scr from screens s inner join pobjects px on s.pobjects_id_scr = px.id
							where px.code =  '#{screen}' and px.objecttype = 'screen') screen
							on screen.id = screenfield.screens_id 
						where  screenfield.selection = '1' and	screenfield.expiredate > current_date" 
		selectfields = ActiveRecord::Base.connection.select_all(strsql)
		createviewscript = "\n  drop view if  exists #{screen} cascade ; "
		createviewscript << "\n create or replace view #{screen} as select  "
		tblchop = screen.split("_")[1].chop
		otherview =[]
		selectfields.each do |rec|
			sfd = rec["pobject_code_sfd"]	
			if rec["screenfield_crtfield"]
				delm = rec["screenfield_crtfield"].split("_",2)[1]
				if !delm.nil?
					delm = "_" + delm 
				end	
			else
				delm = nil
			end	
			if sfd.split("_")[0] == tblchop
				if sfd.split("_")[2] =~/^id/  ## 自分のテーブル.chop_相手のテーブル.chop_id  + delm
					createviewscript << "\n#{tblchop}.#{sfd.split("_")[1]}s_id#{sfd.split("_id")[1]}   #{sfd},"
					otherview << sfd.split("_")[1]  + if sfd.split("_id")[1] then   sfd.split("_id")[1] else "" end
				else	
					createviewscript << "\n#{tblchop}.#{sfd.split("_",2)[1]}  #{sfd},"
				end	
			else
				if sfd == "id"
					createviewscript << "\n#{tblchop}.id id,"
				else
					if !delm.nil?
						createviewscript << "\n  #{rec["screenfield_crtfield"]}.#{sfd.split(/#{delm}$/)[0]}  #{sfd} ,"
					else
						createviewscript << "\n  #{rec["screenfield_crtfield"]}.#{sfd}  #{sfd} ,"
					end	
				end	
			end	
		end	
		createviewscript = createviewscript.chop + "\n from #{tblchop}s   #{tblchop}," 
		createviewscript << "\n"
		otherview.each do |xview|
			createviewscript << ("  r_" + xview.split("_")[0] + "s  " + xview  + " ,")
		end 
		createviewscript = createviewscript.chop + "\n  where      "
		otherview.each do |xview|   ###where でtable間　を結合
			createviewscript << " #{tblchop}.#{xview.split("_")[0]}s_id#{if xview.split("_",2)[1] then "_"+xview.split("_",2)[1] else "" end} = #{xview}.id      and"
		end 
		@modifysql << createviewscript[0..-5]
		@modifysql << ";" 
		@messages << " --- create view script   #{screen} "
	end

	def create_foreign_key_constraint tbl
		@add_id_to_tbl[tbl].each do |field|
				strsql = "SELECT table_name, constraint_name FROM information_schema.table_constraints
							where table_catalog='#{ActiveRecord::Base.configurations["development"]["database"]}' 
							and table_name = '#{tbl}'  and constraint_name = '#{tbl.chop}_#{field}'
							and constraint_type = 'FOREIGN KEY';"
				chk = ActiveRecord::Base.connection.select_one(strsql)
				if chk
					 ###何もしない
				else
					@modifysql << "\n ALTER TABLE #{tbl} ADD CONSTRAINT #{tbl.chop}_#{field} FOREIGN KEY (#{field})
																		 REFERENCES #{field.split("_id",2)[0]} (id);"
				end
		end		
	end

	def delete_foreign_key_constraint tbl
		@delete_id_to_tbl[tbl].each do |field|
				strsql = "SELECT table_name, constraint_name FROM information_schema.table_constraints
							where table_catalog='#{ActiveRecord::Base.configurations["development"]["database"]}' 
							and table_name = '#{tbl}' and constraint_name = '#{tbl.chop}_#{field}'
							AND constraint_type = 'FOREIGN KEY';	"
				chk = ActiveRecord::Base.connection.select_one(strsql)
				if chk
					@modifysql = "\n ALTER TABLE distributors DROP CONSTRAINT  if exists #{tbl.chop}_#{field};"
				else
					###何もしない
				end
		end		
	end
	
	def create_sio_table  viewname
		 @modifysql  << "\n DROP TABLE IF EXISTS " + "sio.sio_" + viewname + ";"
			@modifysql << "\n CREATE TABLE " + "sio.sio_" + viewname   + " (\n"
		  	@modifysql <<  "          sio_id numeric(22,0)  CONSTRAINT " +  "SIO_" + viewname   + "_id_pk PRIMARY KEY "
		 	@modifysql <<  "          ,sio_user_code numeric(22,0)\n"
		  	@modifysql <<  "          ,sio_Term_id varchar(30)\n"
		  	@modifysql <<  "          ,sio_session_id numeric(22,0)\n"
		  	@modifysql <<  "          ,sio_Command_Response char(1)\n"
		  	@modifysql <<  "          ,sio_session_counter numeric(22,0)\n"
		  	@modifysql <<  "          ,sio_classname varchar(50)\n"
		  	@modifysql <<  "          ,sio_viewname varchar(30)\n"
		  	@modifysql <<  "          ,sio_code varchar(30)\n"
		  	@modifysql <<  "          ,sio_strsql varchar(4000)\n"
		  	@modifysql <<  "          ,sio_totalcount numeric(22,0)\n"
		  	@modifysql <<  "          ,sio_recordcount numeric(22,0)\n"
		  	@modifysql <<  "          ,sio_start_record numeric(22,0)\n"
		  	@modifysql <<  "          ,sio_end_record numeric(22,0)\n"
		  	@modifysql <<  "          ,sio_sord varchar(256)\n"
		  	@modifysql <<  "          ,sio_search varchar(10)\n"
		  	@modifysql <<  "          ,sio_sidx varchar(256)\n"
		  	@modifysql  <<  sio_fields(viewname)
		  	@modifysql <<  "          ,sio_errline varchar(4000)\n"
		  	@modifysql <<  "          ,sio_org_tblname varchar(30)\n"
		  	@modifysql <<  "          ,sio_org_tblid numeric(22,0)\n"
		  	@modifysql <<  "          ,sio_add_time date\n"
		  	@modifysql <<  "          ,sio_replay_time date\n"
		  	@modifysql <<  "          ,sio_result_f char(1)\n"
		  	@modifysql <<  "          ,sio_message_code char(10)\n"
		  	@modifysql <<  "          ,sio_message_contents varchar(4000)\n"
		  	@modifysql <<  "          ,sio_chk_done char(1)\n"
			@modifysql <<  ");\n"
			  
		  	@modifysql <<  " CREATE INDEX sio_#{viewname}_uk1 \n"
		  	@modifysql << "  ON sio.sio_#{viewname}(id,sio_id); \n"
			  
			@modifysql <<  "\n drop sequence  if exists sio.sio_#{viewname}_seq ;"##logger.debug @modifysql
			@modifysql <<  "\n create sequence sio.sio_#{viewname}_seq ;"##logger.debug @modifysql
	end #

	def sio_fields screen
			sio_field_strsql = ""
			strsql ="select screenfield.type screenfield_type,screenfield.dataprecision screenfield_dataprecision,
							screenfield.datascale screenfield_datascale,sfd.code pobject_code_sfd,
			 				screenfield.edoptmaxlength screenfield_edoptmaxlength,field.fieldlength fieldcode_fieldlength
					from screenfields screenfield
					inner join pobjects sfd on screenfield.pobjects_id_sfd = sfd.id 
					inner join (select s.id,px.code pobject_code_scr from screens s inner join pobjects px on s.pobjects_id_scr = px.id
								where px.code =  '#{screen}' and px.objecttype = 'screen') screen
						on screen.id = screenfield.screens_id 
					inner join(select t.id,fx.fieldlength from tblfields t  inner join (select f.fieldlength,f.id from fieldcodes f
																inner join pobjects p
																		on f.pobjects_id_fld = p.id) fx  
														on t.fieldcodes_id = fx.id) field
					on  field.id = screenfield.tblfields_id
			 		where  screenfield.selection = '1' and
							screenfield.expiredate > current_date
					order by screenfield.seqno"
			fields = ActiveRecord::Base.connection.select_all(strsql)	
		  	fields.each do |sr|
			  	sio_field_strsql << "," + sr["pobject_code_sfd"] + " " 
			  	case  sr["screenfield_type"]
				when /char|text/
					  	sio_field_strsql << " varchar (" +  sr["fieldcode_fieldlength"].to_s + ") \n"
				when /select/
						sio_field_strsql << " varchar (20) \n"
				when /check/
						sio_field_strsql << " char (01) \n"
				when /number|numeric/
					sio_field_strsql << " numeric "
					sio_field_strsql << if sr["screenfield_dataprecision"] == "0" or sr["screenfield_dataprecision"].nil?
											"(22,0)\n"
										else
											"(#{sr["screenfield_dataprecision"]},#{sr["screenfield_datascale"]})\n"
										end						
				else
					  sio_field_strsql << "  #{sr["screenfield_type"]} \n"
			  	end
		  	end
		 	return sio_field_strsql
	end 

	def proc_drop_index tblname
		proc_blk_get_constrains(tblname,'U').each do |key|
			@modifysql << " ALTER TABLE #{tblname} drop CONSTRAINT #{key}"
		end
	end
	
	def chk_viewfields_exists tbl
		chkfields = {}
		@tblsfields[tbl].each do |pobject_code_fld,rec|   ###{tblname =>{field =>tblrecOfField}}
			if pobject_code_fld =~ /s_id/
				chktbl_delm = pobject_code_fld.split("_id",2)
				chktbl = chktbl_delm[0]
				delm = (chktbl_delm[1]||="")
				if chkfields.empty? or chkfields["r_#{chktbl}"].nil?
					strsql = "
								SELECT     
											cls.relname      AS table_name
											,att.attname      AS column_name
								 FROM        pg_catalog.pg_class       cls
								 LEFT  JOIN  pg_catalog.pg_namespace   nms
										 ON  cls.relnamespace = nms.oid
								 LEFT  JOIN  pg_catalog.pg_attribute   att
										 ON  cls.oid = att.attrelid
										AND  att.attnum > 0
								 WHERE       cls.relkind IN ('r','v','m')
								   AND       nms.nspname = '#{ActiveRecord::Base.connection_config[:schema_search_path]}'
								   and att.attname  not like '%_upd'	and att.attname  != 'id' 
									and cls.relname = 'r_#{chktbl}'
								"
					chks = ActiveRecord::Base.connection.select_all(strsql)
					chks.each do |chkrec|
						if chkfields[chkrec["column_name"]+delm].nil? 
							chkfields[chkrec["column_name"]+delm] = chkrec["table_name"]
						else
							@messages << "<p>step 1-0: view #{chkfields[chkrec["column_name"]+delm]}:#{chkrec["table_name"]}.#{chkrec["column_name"]} duplicate </p>"
						end
					end
					if chks.empty?
						@messages << "<p>step 1-1: view  r_#{chktbl} not exists </p>"
					end
				end
			end
		end		
		strsql = %Q&select sfd.code pobject_code_sfd
						from screenfields s
						inner join pobjects sfd on s.pobjects_id_sfd = sfd.id 
						inner join (select s.id,px.code pobject_code_view from screens s inner join pobjects px on s.pobjects_id_scr = px.id
										where px.code =  'r_#{tbl}' and px.objecttype = 'screen') screen
							on screen.id = s.screens_id 
						inner join(select t.id,fx.fieldlength from tblfields t  inner join (select f.fieldlength,f.id from fieldcodes f
															inner join pobjects p
																	on f.pobjects_id_fld = p.id) fx  
													on t.fieldcodes_id = fx.id) field
							on  field.id = s.tblfields_id
		 				where  s.selection = '1' and
							s.expiredate > current_date
		&
		chkfields = {}
		ActiveRecord::Base.connection.select_values(strsql).each do |sfd|
			if  chkfields[sfd]
				chkfields[sfd] += 1
				@messages << "<p>step 1-2: view field #{sfd} duplicate </p>"
			else
				chkfields[sfd] = 1								
			end
		end
	end

	def proc_createUniqueIndex params
		@messages = [] 
		@sql = ""
		ukey = {}
		params["data"].each do |tmp|
			val = JSON.parse(tmp)
			next if val["blkuky_expiredate"].to_date < Time.now
			if ukey[val["pobject_code_tbl"]].nil?
				ukey[val["pobject_code_tbl"]] = {}
			end	
			if ukey[val["pobject_code_tbl"]][val["blkuky_grp"]].nil?
				ukey[val["pobject_code_tbl"]][val["blkuky_grp"]] = {}
			end	
			ukey[val["pobject_code_tbl"]][val["blkuky_grp"]][val["blkuky_seqno"]] = val["pobject_code_fld"]
		end	
		ukey.each do |tbl,val|
			tblname = tbl.to_s
			val.each do |grp,valseq|  
				grpname = grp.to_s
				constraint_exists = chk_constraint tblname,grpname
				codes = []
				valseq.sort.each do |valseq,code|
					codes << code
				end	
				if constraint_exists
					drop_constraint tblname,grpname,codes
				end	
				create_uniq_constraint tblname,grpname,codes
			end	
		end	
		return @messages,@sql
	end

	def chk_constraint tblname,grpname
		strsql = %Q%SELECT table_name,constraint_name
					FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
					WHERE TABLE_SCHEMA = '#{ActiveRecord::Base.connection_config[:schema_search_path]}' 
					and table_name = '#{tblname}' and constraint_name = '#{tblname}_uky#{grpname}'
					ORDER BY CONSTRAINT_CATALOG, CONSTRAINT_SCHEMA, CONSTRAINT_NAME%
		chkrecs = ActiveRecord::Base.connection.select_one(strsql)
		constraint_exists = nil
		if chkrecs.nil?
			@messages << " create TABLE_CONSTRAINTS :#{tblname}_uky#{grpname} "
		else
			@messages << " table:#{tblname} already exist :#{tblname}_uky#{grpname} "
			@messages << " Therefore ALTER TABLE #{tblname} drop  CONSTRAINT #{tblname}_uky#{grpname}"
			@messages << "	    and  create TABLE_CONSTRAINTS :#{tblname}_uky#{grpname} "
			constraint_exists = true
		end
		return 	constraint_exists
	end	

	def	create_uniq_constraint tblname,grpname,codes
		 @sql << %Q%ALTER TABLE #{tblname}
				ADD CONSTRAINT #{tblname}_uky#{grpname} UNIQUE(#{codes.join(",")});\n%
	end
	
	
	def	drop_constraint tblname,grpname,codes
		 @sql << %Q%ALTER TABLE #{tblname}
				drop CONSTRAINT #{tblname}_uky#{grpname} cascade;\n%
	end

	def screenfield_sql tbl,owner
		strsql =%Q& select  sfd.code pobject_code_sfd,sfd.id pobject_id_sfd,
							s.selection screenfield_selection,s.hideflg screenfield_hideflg,s.seqno screenfield_seqno,
							s.rowpos screenfield_rowpos,s.colpos screenfield_colpos,s.width screenfield_width,
							s.type screenfield_type,s.dataprecision screenfield_dataprecision,s.datascale screenfield_datascale,
							s.indisp screenfield_indisp,s.editable screenfield_editable,s.maxvalue screenfield_maxvalue,
							s.edoptsize screenfield_edoptsize,s.edoptmaxlength screenfield_edoptmaxlength,s.edoptrow screenfield_edoptrow,
							s.edoptcols screenfield_edoptcols,s.edoptvalue screenfield_sdoptvalue,
							s.crtfield screenfield_crtfield,s.expiredate screenfield_expiredate,s.id screenfield_id,
							s.created_at screenfield_created_at,s.updated_at screenfield_updated_at ,s.tblfields_id  screenfield_tblfield_id,
							f.pobject_code_tbl,screen.pobject_code_scr
						from screenfields s
						inner join pobjects sfd on s.pobjects_id_sfd = sfd.id 
						inner join (select s.id ,px.code pobject_code_scr from screens s inner join pobjects px on s.pobjects_id_scr = px.id
										where px.code =  'r_#{tbl}' and px.objecttype = 'screen') screen
							on screen.id = s.screens_id 
						inner join(select t0.id, fy.pobject_code_tbl
										from tblfields t0  	inner join  (select b.id,p1.code pobject_code_tbl 
																				from blktbs b
																				inner join pobjects p1 on p1.id = b.pobjects_id_tbl 	
																				where objecttype = 'tbl') fy
																on t0.blktbs_id = fy.id) f
							on  f.id = s.tblfields_id
		&
		strsql0 = %Q& where s.selection = '1' and s.expiredate > current_date and 
							sfd.code not in('id',
										'#{tbl.chop}_id','#{tbl.chop}_created_at','#{tbl.chop}_update_ip','#{tbl.chop}_remark',
							 				'#{tbl.chop}_updated_at','#{tbl.chop}_expiredate','#{tbl.chop}_person_id_upd',
							 				'person_code_upd','person_name_upd','person_id_upd') 
		&
		str_upd = %Q& where sfd.code  in('id','person_code','person_name')
		&
		case owner
		when true
			strsql
		when nil  ##person upd
			strsql + str_upd
		else
			strsql + strsql0	
		end
	end

	def last_screenfield_sql tbl
		strsql =%Q& select  p4.code pobject_code_sfd,
		s.selection screenfield_selection,s.hideflg screenfield_hideflg,s.seqno screenfield_seqno,
		s.rowpos screenfield_rowpos,s.colpos screenfield_colpos,s.width screenfield_width,
			s.type 	screenfield_type,
			s.dataprecision screenfield_dataprecision,
			s.datascale  screenfield_datascale,
		s.indisp screenfield_indisp,s.editable screenfield_editable,s.maxvalue screenfield_maxvalue,
		s.edoptsize screenfield_edoptsize,s.edoptmaxlength screenfield_edoptmaxlength,s.edoptrow screenfield_edoptrow,
		s.edoptcols screenfield_edoptcols,s.edoptvalue screenfield_sdoptvalue,
		s.crtfield screenfield_crtfield,
		s.expiredate	screenfield_expiredate,s.paragraph screenfield_paragraph,
		s.id screenfield_id,s.tblfields_id screenfield_tblfield_id,s.pobjects_id_sfd screenfield_pobject_id_sfd,
		s.created_at screenfield_created_at,s.updated_at screenfield_updated_at ,s.remark screenfield_remark
		from screenfields s inner join (select s0.id screens_id from screens s0
											inner join pobjects p3 on s0.pobjects_id_scr = p3.id and p3.code = 'r_#{tbl}') s1
								on s1.screens_id = s.screens_id
							inner join pobjects p4 on s.pobjects_id_sfd = p4.id and objecttype = 'view_field'				
	 
		&
	end			 
end