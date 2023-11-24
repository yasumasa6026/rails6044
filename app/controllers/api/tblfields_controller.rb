module Api
    class TblfieldsController < ApplicationController
        before_action :authenticate_api_user!
          def index
          end
          def create
            params[:email] = current_api_user[:email]
            strsql = "select code,id from persons where email = '#{params[:email]}'"
            person = ActiveRecord::Base.connection.select_one(strsql)
            if person.nil?
                params["status"] = 403
                params[:err] = "Forbidden paerson code not detect"
                render json: {:params => params}
                return   
                
            end
            params[:person_code_upd] = person["code"]
            params[:person_id_upd] = person["id"]
            case params[:buttonflg] 
              when 'yup'
                yup = YupSchema.proc_create_schema 	
                foo = File.open("#{Rails.root}/vendor/yup/yupschema.js", "w:UTF-8") # 書き込みモード
                foo.puts yup[:yupschema]
                params[:message] = " yup schema created " 
                render json:{:params=>params} 
              when 'createTblViewScreen'  ### blktbs tblfields 
                tbl =  TblField::TblClass.new
                messages,modifysql,status,errmsg = tbl.proc_blktbs params   ###params[:data]に画面の表示内容を含む
		            $tblfield_materiallized.each do |view|
				            strsql = %Q%select 1 from pg_catalog.pg_matviews pm 
				                  where matviewname = '#{view}' %
				            if ActiveRecord::Base.connection.select_one(strsql)			
					                strsql = %Q%REFRESH MATERIALIZED VIEW #{view} %
					                ActiveRecord::Base.connection.execute(strsql)
				            else
					                3.times{p "materiallized error :#{view}"}
				            end
		            end
                foo = File.open("#{Rails.root}/vendor/postgresql/tblviewupdate#{(Time.now).strftime("%Y%m%d%H%M%S")}.sql", "w:UTF-8") # 書き込みモード
                foo.puts modifysql
                foo.close
                foo = File.open("#{Rails.root}/vendor/postgresql/messages#{(Time.now).strftime("%Y%m%d%H%M%S")}.sql", "w:UTF-8") # 書き込みモード
                foo.puts messages
                foo.close
                params[:messages] = 	messages 
                params[:status] = 	status  
                params[:errmsg] = 	errmsg 
                render json:{:params=>params}  
              when 'createUniqueIndex'  ### createUniqueIndex
                tbl =  TblField::TblClass.new
                messages,sql = tbl.proc_createUniqueIndex params   ###params[:data]に画面の表示内容を含む
                foo = File.open("#{Rails.root}/vendor/postgresql/tblviewupdate#{(Time.now).strftime("%Y%m%d%H%M%S")}.sql", "w:UTF-8") # 書き込みモード
                foo.puts sql
                foo.close
                foo = File.open("#{Rails.root}/vendor/postgresql/messages#{(Time.now).strftime("%Y%m%d%H%M%S")}.txt", "w:UTF-8") # 書き込みモード
                foo.puts messages
                foo.close
                params[:messages] = 	messages 
                render json:{:params=>params}  
            end 
          end
          def show
          end  
    end
  end