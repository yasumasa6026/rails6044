module Api
    class Menus7Controller < ApplicationController
        before_action :authenticate_api_user!
        def index
        end
        def create
            ###JSON.parseのエラー対応　要
            $email = current_api_user[:email]
            strsql = "select person_code_chrg,chrg_person_id_chrg from r_chrgs rc where person_email_chrg = '#{$email}'"
            person = ActiveRecord::Base.connection.select_one(strsql)
            if person.nil?
                person = {"person_code_chrg" => "0","chrg_person_id_chrg" =>0 }
            end
            $person_code_chrg = person["person_code_chrg"]
            $person_id_upd = person["chrg_person_id_chrg"]

            screen = ScreenLib::ScreenClass.new(params)
            #####    
            case params[:buttonflg] 
            when 'menureq'   ###大項目
                sgrp_menue = Rails.cache.fetch('sgrp_menue'+$email) do
                    if Rails.env == "development" 
                        strsql = "select * from func_get_screen_menu('#{$email}')"
                    else
                        strsql = "select * from func_get_screen_menu('#{$email}') and pobject_code_sgrp <'S'"
                    end      
                    sgrp_menue = ActiveRecord::Base.connection.select_all(strsql)
                end
                render json:  sgrp_menue , status: :ok 

            when 'bottunlistreq'  ###大項目内のメニュー
                screenList = Rails.cache.fetch('screenList'+$email) do
                    strsql = "select pobject_code_scr_ub screen_code,button_code,button_contents,button_title
                        from r_usebuttons u
                        inner join r_persons p on u.screen_scrlv_id_ub = p.person_scrlv_id
                                   and p.person_email = '#{$email}' 
                        where usebutton_expiredate > current_date
                        order by pobject_code_scr_ub,button_seqno"
                    screenList = ActiveRecord::Base.connection.select_all(strsql)
                end
                render json:  screenList , status: :ok
            
            when 'viewtablereq7'
                pagedata,reqparams = screen.proc_search_blk(params)   ###:pageInfo  -->menu7から未使用
                render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams}

            when 'inlineedit7'
                pagedata,reqparams = screen.proc_search_blk(params)   ###:pageInfo  -->menu7から未使用
                render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams}
             
            when 'inlineadd7'
                pagedata,reqparams = screen.proc_add_empty_data(params)  ### nil filtered sorting
                render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams}               
                
            when "fetch_request"
                reqparams = params.dup   ### fields.proc_chk_fetch_rec でparamsがnilになってしまうため。　　
                reqparams[:parse_linedata] = JSON.parse(params[:lineData])
                reqparams = CtlFields.proc_chk_fetch_rec reqparams
                render json: {:params=>reqparams}   

            when "check_request"  
                reqparams = params.dup
                reqparams[:parse_linedata] = JSON.parse(params[:lineData])
                # if params[:fetchview] and params[:fetchview] != ""
                #     reqparams = CtlFields.proc_chk_fetch_rec reqparams
                # end
                JSON.parse(params[:checkCode]).each do |sfd,checkcode|
                  reqparams = CtlFields.proc_judge_check_code reqparams,sfd,checkcode
                end
                # if params[:fetchview] and params[:fetchview] != ""
                #     reqparams = CtlFields.proc_chk_fetch_rec reqparams
                # end
                render json: {:params=>reqparams}   

            when "confirm7"
                reqparams = params.dup   ### fields.proc_chk_fetch_rec でparamsがnilになってしまうため。　　
                reqparams[:parse_linedata] = JSON.parse(params[:lineData])
                reqparams = screen.proc_confirm_screen(reqparams)
                render json: {:params=>reqparams}

            when 'download7'
                download_columns_info,totalCount,pagedata = screen.proc_download_data_blk(params)   ### nil filtered sorting
                render json:{:excelData=>{:columns=>download_columns_info.to_json,:data=>pagedata.to_json},
                            :totalCount=>totalCount,:filttered=>params[:filtered] }    

            when 'confirmAll'   ###purords,prdordsからshpordsを表示
                if params["clickIndex"]
                    outcnt = 0
                    reqparams = params.dup
                    ActiveRecord::Base.connection.begin_db_transaction()
                    params["clickIndex"].each_with_index do |strselected,idx|
                        next if strselected == "undefined"
                        selected = JSON.parse(strselected)
                        if params[:screenCode] == selected["screenCode"]
                            grid_columns_info = screen.proc_create_grid_editable_columns_info(reqparams)
                            if selected["id"] == "" or selected["id"].nil? 
                                case params[:screenCode]
                                when "fmcustord_custinsts"
                                    strSno = %Q& custinst_sno_custord  = '#{selected["sNo"]}' &
                                else
                                    Rails.logger.debug%Q&#{Time.now self} line:#{__LINE__} screnCode ummatch params[screenCode]:#{params[:screenCode]}  selected[screenCode]:#{selected["screenCode"]} &
                                    raise
                                end
                                strsql = %Q&select #{grid_columns_info[:select_fields]} from #{params[:screenCode]} where #{strSno}&
                            else
                                fields =  ActiveRecord::Base.connection.select_values(%Q&
                                                select pobject_code_sfd from func_get_screenfield_grpname('#{$mail}','r_#{params[:screenCode].split("_")[1]}')&)
                                strsql = %Q& select #{fields.join(",")} from r_#{params[:screenCode].split("_")[1]} 
                                                    where id = #{strselected["id"]} & 
                            end
                            reqparams[:parse_linedata] = ActiveRecord::Base.connection.select_one(strsql)
                            if params[:changeData]
                                JSON.parse(params[:changeData][idx]).each do |k,v|
                                    if reqparams[:parse_linedata][k]
                                        reqparams[:parse_linedata][k] = v
                                    end
                                end
                            end
                            reqparams = screen.proc_confirm_screen(reqparams)
                            if reqparams[:err].nil?
                                outcnt += 1
                            else
                                ActiveRecord::Base.connection.rollback_db_transaction()
                                command_c["sio_result_f"] = "9"  ##9:error
                                command_c["sio_message_contents"] =  "class #{self} : LINE #{__LINE__} $!: #{$!} "[0..3999]    ###evar not defined
                                command_c["sio_errline"] =  "class #{self} : LINE #{__LINE__} $@: #{$@} "[0..3999]
                                Rails.logger.debug"error class #{self} : #{Time.now}: #{$@} "
                                Rails.logger.debug"error class #{self} : $!: #{$!} "
                                Rails.logger.debug"  command_c: #{command_c} "
                                render json:{:err=>reqparams[:err]}
                                raise    
                            end
                        else
                            Rails.logger.debug%Q&#{Time.now} #{self} line:#{__LINE__} screnCode ummatch  params[:screenCode]:#{params[:screenCode]}  selected[screenCode]:#{selected["screenCode"]} &
                            raise
                        end
                    end
                    ##  pagedata,reqparams = screen.proc_search_blk(reqparams)   ###:pageInfo  -->menu7から未使用
                    ##  render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams,:outcnt => outcnt,:err => ""}
                    ActiveRecord::Base.connection.commit_db_transaction()
                    render json:{:outcnt => outcnt,:err => ""}
                else
                    render json:{:err=>"please  select Order"}    
                end  

            when 'MkPackingListNo'   ###purords,prdordsからshpordsを表示
                if params["clickIndex"]
                    outcnt = 0
                    reqparams = params.dup
                    packingListNo = "P-" + format('%06d',ArelCtl.proc_get_nextval("packinglistno_seq"))
                    strPackingListNo = "#{params[:screenCode].split("_")[1].chop}_packinglistno"
                    ActiveRecord::Base.connection.begin_db_transaction()
                    params["clickIndex"].each_with_index do |strselected,idx|
                        next if strselected == "undefined"
                        selected = JSON.parse(strselected)
                        if params[:screenCode] == selected["screenCode"]
                            grid_columns_info = screen.proc_create_grid_editable_columns_info(reqparams)
                            if selected["id"] == "" or selected["id"].nil? 
                                case params[:screenCode]
                                when "fmcustinst_custdlvs"
                                    strSno = %Q& custdlv_sno_custinst  = '#{selected["sNo"]}' &
                                else
                                    Rails.logger.debug%Q&#{Time.now self} line:#{__LINE__} screnCode ummatch params[screenCode]:#{params[:screenCode]}  selected[screenCode]:#{selected["screenCode"]} &
                                    raise
                                end
                                strsql = %Q&select #{grid_columns_info[:select_fields]} from #{params[:screenCode]} where #{strSno}&
                            else
                                fields =  ActiveRecord::Base.connection.select_values(%Q&
                                                select pobject_code_sfd from func_get_screenfield_grpname('#{$mail}','r_#{params[:screenCode].split("_")[1]}')&)
                                strsql = %Q& select #{fields.join(",")} from r_#{params[:screenCode].split("_")[1]} 
                                                    where id = #{strselected["id"]} & 
                            end
                            reqparams[:parse_linedata] = ActiveRecord::Base.connection.select_one(strsql)
                            if params[:changeData]
                                JSON.parse(params[:changeData][idx]).each do |k,v|
                                    if reqparams[:parse_linedata][k]
                                        reqparams[:parse_linedata][k] = v
                                    end
                                end
                            end
                            reqparams[:parse_linedata][strPackingListNo] =  packingListNo
                            reqparams = screen.proc_confirm_screen(reqparams)
                            if reqparams[:err].nil?
                                outcnt += 1
                            else
                                ActiveRecord::Base.connection.rollback_db_transaction()
                                command_c["sio_result_f"] = "9"  ##9:error
                                command_c["sio_message_contents"] =  "class #{self} : LINE #{__LINE__} $!: #{$!} "[0..3999]    ###evar not defined
                                command_c["sio_errline"] =  "class #{self} : LINE #{__LINE__} $@: #{$@} "[0..3999]
                                Rails.logger.debug"error class #{self} : #{Time.now}: #{$@} "
                                Rails.logger.debug"error class #{self} : $!: #{$!} "
                                Rails.logger.debug"  command_c: #{command_c} "
                                render json:{:err=>reqparams[:err]}
                                raise    
                            end
                        else
                            Rails.logger.debug%Q&#{Time.now} #{self} line:#{__LINE__} screnCode ummatch  params[:screenCode]:#{params[:screenCode]}  selected[screenCode]:#{selected["screenCode"]} &
                            raise
                        end
                    end
                    ##  pagedata,reqparams = screen.proc_search_blk(reqparams)   ###:pageInfo  -->menu7から未使用
                    ##  render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams,:outcnt => outcnt,:err => ""}
                    ActiveRecord::Base.connection.commit_db_transaction()
                    render json:{:outcnt => outcnt,:err => ""}
                else
                    render json:{:err=>"please  select Order"}    
                end

            when 'MkInvoiceNo'   ###purords,prdordsからshpordsを表示
                if params["clickIndex"]
                    outcnt = 0
                    totalAmt =  0
                    totalTax = 0
                    reqparams = params.dup
                    invoiceNo = "Inv-" + format('%06d',ArelCtl.proc_get_nextval("invoiceno_seq"))
                    strInvoiceNo = "custacthead_invoiceno"
                    ActiveRecord::Base.connection.begin_db_transaction()
                    params["clickIndex"].each_with_index do |strselected,idx|
                        next if strselected == "undefined"
                        selected = JSON.parse(strselected)
                        if params[:screenCode] == selected["screenCode"]
                            grid_columns_info = screen.proc_create_grid_editable_columns_info(reqparams)
                            if selected["id"] == "" or selected["id"].nil? 
                                render json:{:err=>"please  select after add custacts "}   ###mesaage    
                                return
                            else
                                fields =  ActiveRecord::Base.connection.select_values(%Q&
                                                select pobject_code_sfd from func_get_screenfield_grpname('#{$mail}','r_#{params[:screenCode].split("_")[1]}')&)
                                strsql = %Q& select #{fields.join(",")} from r_#{params[:screenCode].split("_")[1]} 
                                                    where id = #{strselected["id"]} & 
                            end
                            reqparams[:parse_linedata] = ActiveRecord::Base.connection.select_one(strsql)
                            if params[:changeData]
                                JSON.parse(params[:changeData][idx]).each do |k,v|
                                    if reqparams[:parse_linedata][k]
                                        if k != strInvoiceNo 
                                            reqparams[:parse_linedata][k] = v
                                        else
                                            if val != "" and val
                                                if CtlFields.proc_billord_exists(reqparams[:parse_linedata])
                                                    render json:{:err=>" already issue billords "}   ###mesaage
                                                    return    
                                                end
                                            else ###新しいInvoiceNoに変更される。
                                                ###ここでは何もしない。
                                            end
                                        end
                                    end
                                end
                            end
                            reqparams[:parse_linedata][strInvoiceNo] =  invoiceNo
                            reqparams["heads"] = []  ###amtの計算用
                            reqparams = screen.proc_confirm_screen(reqparams)
                            if reqparams[:err].nil?
                                outcnt += 1
                            else
                                ActiveRecord::Base.connection.rollback_db_transaction()
                                command_c["sio_result_f"] = "9"  ##9:error
                                command_c["sio_message_contents"] =  "class #{self} : LINE #{__LINE__} $!: #{$!} "[0..3999]    ###evar not defined
                                command_c["sio_errline"] =  "class #{self} : LINE #{__LINE__} $@: #{$@} "[0..3999]
                                Rails.logger.debug"error class #{self} : #{Time.now}: #{$@} "
                                Rails.logger.debug"error class #{self} : $!: #{$!} "
                                Rails.logger.debug"  command_c: #{command_c} "
                                render json:{:err=>reqparams[:err]}
                                raise    
                            end
                        else
                            Rails.logger.debug%Q&#{Time.now} #{self} line:#{__LINE__} screnCode ummatch  params[:screenCode]:#{params[:screenCode]}  selected[screenCode]:#{selected["screenCode"]} &
                            raise
                        end
                    end
                    amtTaxRate = {}
                    reqparams["heads"].each do |head|
                        totalAmt += head["amt"]
                        totalTax += totalAmt * head["taxrate"]  / 100 ###変更要
                        if amtTaxRate[head["taxrate"]]
                            amtTaxRate[head["taxrate"]]["amt"] += head["amt"]
                            amtTaxRate[head["taxrate"]]["count"] += 1
                        else
                            amtTaxRate[head["taxrate"]] ={"amt" => head["amt"],"count" => 1}
                        end
                    end
                    custactHead =  RorBlkCtl::BlkClass.new("r_custactheads")
                    custactHeadCommand_c = custactHead.command_init
                    reqparams["heads"].each do |head|
                        custactHeadCommand_c["id"] = head["custacthead_id"]   ###修正のみ
                        custactHeadCommand_c["custacthead_amt"] = totalAmt
                        custactHeadCommand_c["custacthead_tax"] = totaltax
                        custactHeadCommand_c["custacthead_taxjson"] = amtTaxRate.to_json 
                        custactHeadCommand_c = custactHead.proc_create_tbldata(command_c)
                        custactHead.proc_private_aud_rec({},custactHeadCommand_c)
                    end
                    ActiveRecord::Base.connection.commit_db_transaction()
                    render json:{:outcnt => outcnt,:err => ""}
                else
                    render json:{:err=>"please  select Order"}    
                end

            when 'mkShpords'  ###shpschsは作成済が条件。shpschsはpurords,prdords時に自動作成
                if params[:clickIndex]
                    outcnt,shortcnt,err = Shipment.proc_mkShpords(screen.screenCode,params[:clickIndex])
                    render json:{:outcnt=>outcnt,:shortcnt=>shortcnt,:err=>err,:params=>{:buttonflg=>"mkShpords"}}
                else
                    render json:{:outcnt=>0,:shortcnt=>0,:err=>" please select",:params=>{:buttonflg=>"mkShpords"}}
                end
            
            when 'refShpords'   ###purords,prdordsからshpordsを表示
                if params["clickIndex"]
                    reqparams = params.dup   ### fields.proc_chk_fetch_rec でparamsがnilになってしまうため。
                    reqparams[:where_str] ||= ""
                    reqparams[:filtered] ||= []
                    reqparams[:pageIndex] ||= 0
                    reqparams[:pageSize] ||= 100
                    reqparams[:buttonflg] = "inlineedit7"
                    reqparams[:screenCode] = "forInsts_shpords"   ###shpordsがshpinstsに変わるため
                    reqparams[:pareTblName] = params[:screenCode].split("_",2)[1]   
                    secondScreen = ScreenLib::ScreenClass.new(reqparams)
                    grid_columns_info = secondScreen.proc_create_grid_editable_columns_info(reqparams)
                    pagedata,reqparams = Shipment.proc_second_shp reqparams,grid_columns_info
                    render json:{:grid_columns_info=>grid_columns_info,:data=>pagedata,:params=>reqparams}
                else
                    render json:{:err=>"please  select Order"}    
                end
            
            when 'refShpinsts'  ###purords,prdordsからshpinstsを表示
                if params["clickIndex"]
                    reqparams = params.dup   ### fields.proc_chk_fetch_rec でparamsがnilになってしまうため。
                    reqparams[:where_str] ||= ""
                    reqparams[:filtered] ||= []
                    reqparams[:pageIndex] ||= 0
                    reqparams[:pageSize] ||= 100
                    reqparams[:buttonflg] = "inlineedit7"
                    reqparams[:screenCode] = "foract_shpinsts"   ###shpordsがshpinstsに変わるため
                    reqparams[:pareTblName] = params[:screenCode].split("_",2)[1]   
                    secondScreen = ScreenLib::ScreenClass.new(reqparams)
                    grid_columns_info = secondScreen.proc_create_grid_editable_columns_info(reqparams)
                    pagedata,reqparams = Shipment.proc_second_shp reqparams,grid_columns_info   ###shp専用
                    render json:{:grid_columns_info=>grid_columns_info,:data=>pagedata,:params=>reqparams}
                else
                    render json:{:err=>"please  select Order"}    
                end
            
            when 'refShpacts'   ###purords,prdordsからshpactsを表示
                if params["clickIndex"]
                    reqparams = params.dup   ### fields.proc_chk_fetch_rec でparamsがnilになってしまうため。
                    reqparams[:where_str] ||= ""
                    reqparams[:filtered] ||= []
                    reqparams[:pageIndex] ||= 0
                    reqparams[:pageSize] ||= 100
                    reqparams[:buttonflg] = 'viewtablereq7'
                    reqparams[:screenCode] = "r_shpacts"   ###shpordsがshpinstsに変わるため
                    reqparams[:pareTblName] = params[:screenCode].split("_",2)[1]   
                    secondScreen = ScreenLib::ScreenClass.new(reqparams)
                    grid_columns_info = secondScreen.proc_create_grid_editable_columns_info(reqparams)
                    pagedata,reqparams = secondScreen.proc_second_view reqparams,grid_columns_info  ###共通lib
                    render json:{:grid_columns_info=>grid_columns_info,:data=>pagedata,:params=>reqparams}
                else
                    render json:{:err=>"please  select Order"}    
                end

            when 'confirmShpinsts'
                reqparams = params.dup   ### fields.proc_chk_fetch_rec でparamsがnilになってしまうため。
                outcnt,err = Shipment.proc_confirmShpinsts(params)
                reqparams[:buttonflg] = 'confirmSecond'
                render json:{:outcnt => outcnt,:err => err,:params => reqparams}    
            
            when 'confirmShpacts'
                reqparams = params.dup   ### fields.proc_chk_fetch_rec でparamsがnilになってしまうため。
                outcnt,err = Shipment.proc_confirmShpacts(params)
                reqparams[:buttonflg] = 'confirmSecond'
                render json:{:outcnt => outcnt,:err => err,:params => reqparams}    
            else
                Rails.logger.debug"#{Time.now} : buttonflg-->#{params.buttonflg} not support "    
            end
        end
        def show
        end
    end    
end
