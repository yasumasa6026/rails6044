module Api
  ###
  ###  rollbackの結果を画面に返せてない。エラー時はlogで確認
  ###　日付は文字タイプ(関数、日付は使用できない。)
  ###
class ImportexcelController < ApplicationController

    # GET /api/uploads
    def index
    end

    # PUT /api/recipes/1
    def update
    end
      
    def create   ###自動で作成されたファイル名は変更しないこと。
        ##skip_before_action :verify_authenticity_token
        ###@importexcel = Importexcel.new(params[:importexcel])
        ###if @importexcel.save
        tblname = params[:screenCode].split("_")[1]
        $email = params[:email]  ###tokenのuid  ===>uidはemailであること
        strsql = "select person_code_chrg,chrg_person_id_chrg from r_chrgs rc where person_email_chrg = '#{$email}'"
        person = ActiveRecord::Base.connection.select_one(strsql)
        if person.nil?
            person = {"person_code_chrg" => "0","chrg_person_id_chrg" =>0 }
        end
        $person_code_chrg = person["person_code_chrg"]
        $person_id_upd = person["chrg_person_id_chrg"]
        jparams = params.dup
        jparams[:importData] = {}  ###jparamsではimportdataは使用しない。processreqへの保存対象外
        jparams[:req] = "import"
        command_c = {}
        screen = ScreenLib::ScreenClass.new(jparams)
        column_info,page_info,where_info,select_fields,fetch_check,dropdownlist,sort_info,nameToCode = 
                  screen.proc_create_upload_editable_columns_info "import" 
        
        strsql = "select	column_name from 	information_schema.columns 
                  where 	table_catalog='#{ActiveRecord::Base.configurations["development"]["database"]}' 
                  and table_name='#{screen.screenCode}' and  column_name not like  '%person_id_upd' "
        keyids = ActiveRecord::Base.connection.select_values(strsql)
        
        performSeqNos = []
        results = {}   
        results[:columns] = []
        results[:rows] = []

        column_info.each do |field|
            if field =~ /_confirm_gridmessage/
                    results[:columns] << field
            else
                    if field =~ /gridmessage$/
                        next
                    else
                        results[:columns] << field
                    end
            end
        end

        rows = []
        importError = false
        idx = 0

  		fetchCode = YupSchema.proc_create_fetchCode screen.screenCode ##
        checkCode  = YupSchema.proc_create_checkCode screen.screenCode   
        tblid = screen.screenCode.split("_")[1].chop + "_id"
        lines = params[:importData][:importexcel]
        lines.each do |linevalues|
            jparams[:parse_linedata] = linevalues.dup
            keyids.each do |idkey|   ###keyids--->view項目
                    if jparams[:parse_linedata][idkey].nil?
                        jparams[:parse_linedata][idkey] = ""
                    end    
            end  
            jparams[:screenCode] = screen.screenCode
            jparams[:err] = nil
            jparams[:parse_linedata]["#{tblname.chop}_confirm_gridmessage"] ||= ""
            if linevalues["confirm"] != false  
                linevalues.each do |field,val| ###confirmはfunction batchcheckで項目追加している。
                        ##エラーと最初のレコード(confirm="confirm")のname項目行を除く
                    jparams[:parse_linedata]["confirm"] = true
                    if fetchCode[field] 
                        jparams[:fetchCode] = %Q%{"#{field}":"#{val}"}%
                        jparams[:fetchview] = fetchCode[field]
                        jparams = CtlFields.proc_chk_fetch_rec jparams
                        if jparams[:err].nil?
                            if checkCode[field] and val != ""
                                jparams = CtlFields.proc_judge_check_code jparams,field,checkCode[field]
                                if jparams[:err]
                                        importError = true
                                        jparams[:parse_linedata]["#{tblname.chop}_confirm_gridmessage"] << jparams[:err]
                                end
                            end
                        else   
                            importError = true  
                            jparams[:parse_linedata]["#{tblname.chop}_confirm_gridmessage"] << jparams[:err]
                            jparams[:parse_linedata]["confirm"] = false
                        end  
                    else  
                    end
                end 
            else
                importError = true
            end 
            rows << jparams[:parse_linedata]
        end
        begin
            ActiveRecord::Base.connection.begin_db_transaction()
            rows.each do |parse_linedata|
                blk =  RorBlkCtl::BlkClass.new(screen.screenCode)
                command_c = blk.command_init.dup  ###blkukyはid以外でユニークを保証するkey
                if parse_linedata["confirm"] == true    ###重複keyチェック
                    err = CtlFields.proc_blkuky_check(screen.screenCode.split("_")[1],parse_linedata)
                    tblid = screen.screenCode.split("_")[1].chop + "_id"
                    err.each do |key,recs|
                        recs.each do |rec|
                            if command_c["id"].nil? or command_c["id"] == ""
                                command_c["id"] = rec["id"]
                                parse_linedata[tblid] = parse_linedata["id"] = rec["id"]
                            else
                                if command_c["id"] != rec["id"]
                                    importError = true  
                                    parse_linedata["confirm"] = false  
                                    parse_linedata["#{tblname.chop}_confirm_gridmessage"] = "error key:#{key}"
                                end
                            end  
                            if  parse_linedata["aud"] == "add" and  rec["id"] 
                                importError = true
                                parse_linedata["confirm"] = false  
                                parse_linedata["#{tblname.chop}_confirm_gridmessage"] = "error already exist key:#{key}"
                            end 
                        end	
                        if recs.empty?
                            if  parse_linedata["aud"] == "update" or parse_linedata["aud"] == "delete"
                                importError = true
                                parse_linedata["confirm"] = false 
                                parse_linedata["#{tblname.chop}_confirm_gridmessage"] = "error key not exist key:#{key}"
                            end
                        end  
                    end
                end                
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
                    command_c["sio_classname"] = "_add_grid_linedata"
                when "update"         
                    command_c["sio_classname"] = "_update_grid_linedata"
                when "delete"       
                    command_c["sio_classname"] = "_delete_grid_linedata"
                else
                end
                if importError == false and parse_linedata["confirm"] == true 
                    blk.proc_create_tbldata(command_c) ### @src_tbl作成
                    setParams = blk.proc_private_aud_rec(jparams,command_c)
                    idx += 1
                    if setParams["seqno"][0]
                        performSeqNos << setParams["seqno"][0]
                    end
                else
                end
                results[:rows] << parse_linedata 
            end
        rescue
            ActiveRecord::Base.connection.rollback_db_transaction()
            command_c["sio_result_f"] =   "9"  ##9:error
            command_c["sio_message_contents"] =  "error class #{self} : LINE #{__LINE__} $!: #{$!} "    ###evar not defined
            command_c["sio_errline"] =  "class #{self} : LINE #{__LINE__} $@: #{$@} "[0..3999]
            Rails.logger.debug"error class #{self} : #{Time.now}: #{$@}\n "
            Rails.logger.debug"error class #{self} : $!: #{$!} \n"
            Rails.logger.debug"  idx = #{idx} command_init: #{command_c} "
            if rows.empty?
              ###redults excelへの返し
            else
              rows[idx+1]["#{tblname.chop}_confirm_gridmessage"] = command_c["sio_message_contents"].to_s[0..1000]
            end
            idx = 0
        else
            ActiveRecord::Base.connection.commit_db_transaction()
            performSeqNos.each do |seq|
				CreateOtherTableRecordJob.perform_later(seq)
            end
            ArelCtl.proc_materiallized tblname
        end
        render json: {:results=>results,:importError=>importError,:idx=>idx}
    end

    def show
    end
    private
        def importexcel_params
            params.require(:importexcel).permit(:title, :filename)
        end 
end   ###class
end    ###module