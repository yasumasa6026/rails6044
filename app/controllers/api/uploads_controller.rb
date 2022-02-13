module Api
  ###
  ###
  ###  rollbackの結果を画面に返せてない。
  ###
  ###
  class UploadsController < ApplicationController
    before_action :authenticate_api_user!
    before_action :set_upload, only: [:update]

    # GET /api/uploads
      def index
      end

    # PUT /api/recipes/1
      def update
      end
      
      def create   ###自動で作成されたファイル名は変更しないこと。
        upload = Upload.create!(upload_params)
        blob_path = Rails.application.routes.url_helpers.rails_blob_path(upload.excel, only_path: true)
        tmp1,screenCode,tmp2 = blob_path.split("@")
        tblname = screenCode.split("_")[1]
        $email = current_api_user[:email]
        strsql = "select person_code_chrg from r_chrgs rc where person_email_chrg = '#{$email}'"
        $person_code_chrg = ActiveRecord::Base.connection.select_value(strsql)
        screen = ScreenLib::ScreenClass.new(screenCode)
        column_info,page_info,where_info,select_fields,yup,dropdownlist,sort_info,nameToCode = 
                  screen.proc_create_upload_editable_columns_info "inlineaddreq" 
        
        strsql = "select	column_name from 	information_schema.columns 
                  where 	table_catalog='#{ActiveRecord::Base.configurations["development"]["database"]}' 
                  and table_name='#{screen.screenCode}' and  column_name not like  '%person_id_upd' "
        keyids = ActiveRecord::Base.connection.select_values(strsql)
        
        command_all = []
        results = []   
        status = true
        jparams = {}

  		  yupfetchcode = YupSchema.proc_create_yupfetchcode screen.screenCode ##
        yupcheckcode  = YupSchema.create_yupcheckcode screen.screenCode   
        tblid = screen.screenCode.split("_")[1].chop + "_id"
        
        lines = JSON.parse(upload.excel.download)
        lines.each do |linedata|
            jparams[:parse_linedata] = linedata.dup
            keyids.each do |idkey|   ###keyids--->view項目
                if jparams[:parse_linedata][idkey].nil?
                    jparams[:parse_linedata][idkey] = ""
                end    
            end  
            jparams[:screenCode] = screen.screenCode
            jparams[:err] = ""  
            linedata.each do |field,val| ###confirmはfunction batchcheckで項目追加している。
                if (linedata["confirm"] == true  or linedata["confirm"].nil?) and status == true
                  ##エラーと最初のレコード(confirm="confirm")のname項目行を除く
                  jparams[:parse_linedata]["confirm"] = true
                  if yupfetchcode[field] 
                    jparams[:fetchcode] = %Q%{"#{field}":"#{val}"}%
                    jparams[:fetchview] = yupfetchcode[field]
                    jparams = ControlFields.proc_chk_fetch_rec jparams
                    if jparams[:err] == ""
                        jparams[:fetch_data].each do |fd,vl|
                            jparams[:parse_linedata][fd] = vl
                        end  
                        if yupcheckcode[field] and val != ""
                            jparams["yupcheckcode"] = %Q%{"#{field}":"#{val}"}%
                            jparams = ControlFields.proc_judge_check_code jparams,field,yupcheckcode[field]
                            if jparams[:err] != ""
                                jparams[:parse_linedata]["confirm_gridmessage"] = jparams[:err]
                                status = false 
                                jparams[:parse_linedata]["confirm"] = false
                            else
                                jparams[:parse_linedata]["#{field}_gridmessage"] = "ok"
                            end
                        end
                    else   
                        status = false   
                        jparams[:parse_linedata]["confirm"] = false
                    end  
                  else  
                  end
                end 
            end 
            if status == false    
                jparams[:parse_linedata]["confirm_gridmessage"] = jparams[:err]
            end
            results << jparams[:parse_linedata]
        end
          
        begin
          ActiveRecord::Base.connection.begin_db_transaction()
          idx = 0
          results.each do |parse_linedata|
            blk =  RorBlkCtl::BlkClass.new(screen.screenCode)
            command_c = blk.command_init.dup  ###blkukyはid以外でユニークを保証するkey
            if parse_linedata["confirm"] == true    ###重複keyチェック
                err = ControlFields.proc_blkuky_check(screen.screenCode.split("_")[1],parse_linedata)
                tblid = screen.screenCode.split("_")[1].chop + "_id"
                err.each do |key,recs|
                    recs.each do |rec|
                        if command_c["id"].nil? or command_c["id"] == ""
                              command_c["id"] = rec["id"]
                              parse_linedata[tblid] = parse_linedata["id"] = rec["id"]
                        else
                          if command_c["id"] != rec["id"]
                              status = false  
                              parse_linedata["confirm_gridmessage"] = "error key:#{key}"
                          end
                        end  
                        if  parse_linedata["aud"] == "add" and  rec["id"] 
                          status = false  
                          parse_linedata["confirm_gridmessage"] = "error already exist key:#{key}"
                        end 
                    end	
                    if recs.empty?
                      if  parse_linedata["aud"] == "update" or parse_linedata["aud"] == "delete"
                          status = false  
                          parse_linedata["confirm_gridmessage"] = "error key not exist key:#{key}"
                      end
                    end  
                end
            end
            if status == true and parse_linedata["confirm"] == true 
                parse_linedata.each do |key,value|
                    case value.class.to_s  ###画面からの入力はすべてcharとして扱っている。
                    when "Integer"
                      command_c[key]  = value.to_s
                    when "Float"
                      command_c[key]  = value.to_s
                    when "Time"
                      command_c[key]  = value.to_s
                    when "Date"
                      command_c[key] = value.to_s
                    else
                      command_c[key] = (value||="")
                    end
                end
                case command_c["aud"] 
                when "add" 
                    command_c[:sio_classname] = "_add_grid_line_data"
                when "update"         
                    command_c[:sio_classname] = "_update_grid_line_data"
                when "delete"       
                    command_c[:sio_classname] = "_delete_grid_line_data"
                end
                command_all << command_c
                blk.proc_create_src_tbl(command_c) ### @src_tbl作成
                blk.proc_private_aud_rec(jparams,command_c)
                idx += 1
              else
                command_all << command_c
                idx += 1
                rasie
            end
          end
        rescue
            ActiveRecord::Base.connection.rollback_db_transaction()
            command_all[idx][:sio_result_f] =   "9"  ##9:error
            command_all[idx][:sio_message_contents] =  "error class #{self} : LINE #{__LINE__} $!: #{$!} "    ###evar not defined
            command_all[idx][:sio_errline] =  "class #{self} : LINE #{__LINE__} $@: #{$@} "[0..3999]
            Rails.logger.debug"error class #{self} : #{Time.now}: #{$@} "
            Rails.logger.debug"error class #{self} : $!: #{$!} "
            Rails.logger.debug"  idx = #{idx} command_init: #{command_all[idx]} "
            if results.nil?
              ###redults excelへの返し
            else
              results[idx+1]["confirm_gridmessage"] = command_all[idx][:sio_message_contents].to_s[0..1000]
            end
        else
            ActiveRecord::Base.connection.commit_db_transaction()
            ArelCtl.proc_materiallized tblname
        end
        render json: {:results=>results,:importError=>importerr}
      end

      def show
      end
    private
        def upload_params
          params.require(:upload).permit(:excel,:title)
        end 
      # Use callbacks to share common setup or constraints between actions.
      def set_upload
          @upload = Upload.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def update_params
        params.permit(:id,:title, :contents)
      end
      def create_params
        params.permit(:excel)
      end
  end
end  