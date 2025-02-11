module Api
    class Menus7Controller < ApplicationController
        before_action :authenticate_api_user!
        def index
        end
        def create
            ###JSON.parseのエラー対応　要
            params["email"] = current_api_user[:email]
            strsql = "select code,id,name from persons where email = '#{params["email"]}'"
            person = ActiveRecord::Base.connection.select_one(strsql)
            if person.nil?
                params["status"] = 403
                params[:err] = "Forbidden parson code Or not detected"
                render json: {:params => params}
                return   
                
            end
            params["person_code_upd"] = person["code"]
            params["person_name_upd"] = person["name"]
            params["person_id_upd"] = person["id"]

            #####    
            case params[:buttonflg] 
            when 'menureq'   ###大項目
                sgrp_menue = Rails.cache.fetch('sgrp_menue'+params["email"]) do
                    if Rails.env == "development" 
                        strsql = "select * from func_get_screen_menu('#{params["email"]}')"
                    else
                        strsql = "select * from func_get_screen_menu('#{params["email"]}') and pobject_code_sgrp <'S'"
                    end      
                    sgrp_menue = ActiveRecord::Base.connection.select_all(strsql)
                end
                render json:  sgrp_menue , status: :ok 

            when 'bottunlistreq'  ###大項目内のメニュー
                screenList = Rails.cache.fetch('screenList'+params["email"]) do
                    strsql = "select pobject_code_scr_ub screen_code,button_code,button_contents,button_title
                        from r_usebuttons u
                        inner join persons p on u.screen_scrlv_id_ub = p.scrlvs_id
                                   and p.email = '#{params["email"]}' 
                        where usebutton_expiredate > current_date
                        order by pobject_code_scr_ub,button_seqno"
                    screenList = ActiveRecord::Base.connection.select_all(strsql)
                end
                render json:  screenList , status: :ok
            
            when 'viewtablereq7'
							begin
                screen = ScreenLib::ScreenClass.new(params)
                pagedata,reqparams = screen.proc_search_blk(params)   ###:pageInfo  -->menu7から未使用
							rescue
								params[:err] = "  #{$@}"
                render json:{:grid_columns_info=>{},:data=>{},:params=>params},:status =>500
							else
                render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams}
							end
            
            # when 'linechart'
            #     screen = ScreenLib::ScreenClass.new(params)
            #     pagedata,reqparams = screen.proc_linechart(params)   ###:pageInfo  -->menu7から未使用
            #     render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams}

            when 'inlineedit7'
                screen = ScreenLib::ScreenClass.new(params)
                pagedata,reqparams = screen.proc_search_blk(params)   ###:pageInfo  -->menu7から未使用
                render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams}
             
            when 'inlineadd7'
                screen = ScreenLib::ScreenClass.new(params)
                pagedata,reqparams = screen.proc_add_empty_data(params)  ### nil filtered sorting
                render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams}
            
             
            when 'showdetail'   
                reqparams = params.dup   ### 
                reqparams[:where_str] ||= ""
                reqparams[:filtered] ||= []
                reqparams[:pageIndex] ||= 0
                reqparams[:pageSize] ||= 100
                reqparams[:buttonflg] = 'viewtablereq7'
                reqparams[:screenFlg] = "second"
                reqparams[:screenCode] = params[:screenCode].sub("head","")
                str_func = %Q&select * from func_get_name('screen','#{reqparams[:screenCode]}','#{reqparams["email"]}')&
                reqparams[:screenName] = ActiveRecord::Base.connection.select_value(str_func)
                if reqparams[:screenName].nil?
                    reqparams[:screenName] = reqparams[:screenCode]
                end
                reqparams["gantt"] ||= {}
                reqparams["gantt"]["paretblname"] = params[:screenCode].split("_",2)[1]
                reqparams[:head] = JSON.parse(params[:head])
                secondScreen = ScreenLib::ScreenClass.new(reqparams)
                grid_columns_info = secondScreen.proc_create_grid_editable_columns_info(reqparams)
                pagedata,reqparams = secondScreen.proc_showdetail reqparams ###共通lib
                render json:{:grid_columns_info=>grid_columns_info,:data=>pagedata,:params=>reqparams}             
                
            when "fetch_request"
                reqparams = params.dup   ### 　　
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
                screen = ScreenLib::ScreenClass.new(params)
                reqparams = params.dup   ### 　
                reqparams[:parse_linedata] = JSON.parse(params[:lineData])
                reqparams[:head] = JSON.parse(params[:head]||="{}")
                reqparams = screen.proc_confirm_screen(reqparams)
                if reqparams[:err]
                    render json: {:params=>reqparams}
                else
                    if  params[:screenCode] =~ /heads$/
                        render json: {:params=>reqparams,:outcnt =>reqparams["count"] ,:outamt =>reqparams["amt"],:outqty =>reqparams["qty"]}
                    else
                        render json: {:params=>reqparams}
                    end
                end

            when 'download'
                screen = ScreenLib::ScreenClass.new(params)
                download_columns_info,totalCount,pagedata = screen.proc_download_data_blk(params)   ### nil filtered sorting
                render json:{:excelData=>{:columns=>download_columns_info.to_json,:data=>pagedata.to_json},
                            :totalCount=>totalCount,:filttered=>params[:filtered] }    

            when 'confirmAll'   ###purords,prdordsからshpordsを表示
                if params["clickIndex"]
                    outcnt = outqty = outamt = 0
                    reqparams = params.dup
                    ActiveRecord::Base.connection.begin_db_transaction()
                    params["clickIndex"].each_with_index do |strselected,idx|
                        next if strselected == "undefined" 
                        selected = JSON.parse(strselected)
                        next if selected.empty?
                        if params[:screenCode] == selected["screenCode"]
                            screen = ScreenLib::ScreenClass.new(params)
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
                                                select pobject_code_sfd from func_get_screenfield_grpname('#{params["email"]}','r_#{params[:screenCode].split("_")[1]}')&)
                                strsql = %Q& select #{fields.join(",")} from r_#{params[:screenCode].split("_")[1]} 
                                                    where id = #{strselected["id"]} & 
                            end
                            reqparams[:parse_linedata] = ActiveRecord::Base.connection.select_one(strsql)
                            # if params[:changeData]
                            #     JSON.parse(params[:changeData][idx]).each do |k,v|
                            #         if reqparams[:parse_linedata][k]
                            #             reqparams[:parse_linedata][k] = v
                            #         end
                            #     end
                            # end
                            reqparams = screen.proc_confirm_screen(reqparams)
                            if reqparams[:err].nil?
                                outcnt += 1
                                outamt += reqparams[:outamt]
                                outqty += reqparams[:outqty]
                            else
                                ActiveRecord::Base.connection.rollback_db_transaction()
                                command_c["sio_result_f"] = "9"  ##9:error
                                command_c["sio_message_contents"] =  "class #{self} : LINE #{__LINE__} $!: #{$!} "[0..3999]    ###evar not defined
                                command_c["sio_errline"] =  "class #{self} : LINE #{__LINE__} $@: #{$@} "[0..3999]
                                Rails.logger.debug"error class #{self} : #{Time.now}: #{$@} "
                                Rails.logger.debug"error class #{self} : $!: #{$!} "
                                Rails.logger.debug"  command_c: #{command_c} "
                                render json:{:params => reqparams}
                                raise    
                            end
                        else
                            Rails.logger.debug "#{Time.now} #{self} line:#{__LINE__} screnCode ummatch  params[:screenCode]:#{params[:screenCode]}  selected[screenCode]:#{selected["screenCode"]} "
                            raise
                        end
                    end
                    if  outcnt > 0
                        ActiveRecord::Base.connection.commit_db_transaction()
                        params[:err] = ""
                        render json:{:outcnt => outcnt,:outqty => outqty,:outamt => outamt,:params => {:buttonflg => params[:buttonflg]}}
                    else
                        params[:err] = "please  select Order"
                        render json:{:params => params}
                    end
                else
                  params[:err] = "please  select Order"
                  render json:{:params => params}
                end  

            when 'MkPackingListNo'   ###purords,prdordsからshpordsを表示
                if params[:clickIndex]
                    outcnt = 0
                    reqparams = params.dup
                    packingListNo = "P-" + format('%06d',ArelCtl.proc_get_nextval("packinglistno_seq"))
                    strPackingListNo = "#{params[:screenCode].split("_")[1].chop}_packinglistno"
                    begin
                    ActiveRecord::Base.connection.begin_db_transaction()
                      params["clickIndex"].each_with_index do |strselected,idx|
                        next if strselected == "undefined"
                        selected = JSON.parse(strselected)
                        next if selected.empty?
                        if params[:screenCode] == selected["screenCode"]
                            screen = ScreenLib::ScreenClass.new(params)
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
                                                select pobject_code_sfd from func_get_screenfield_grpname('#{params["email"]}','r_#{params[:screenCode].split("_")[1]}')&)
                                strsql = %Q& select #{fields.join(",")} from r_#{params[:screenCode].split("_")[1]} 
                                                    where id = #{selected["id"]} & 
                            end
                            reqparams[:parse_linedata] = ActiveRecord::Base.connection.select_one(strsql)
                            reqparams[:parse_linedata][strPackingListNo] =  packingListNo
                            reqparams = screen.proc_confirm_screen(reqparams)
                            if reqparams[:err].nil?
                                outcnt += 1
                            else
                                ActiveRecord::Base.connection.rollback_db_transaction()
                                Rails.logger.debug"error class #{self} : #{Time.now}: #{$@} "
                                Rails.logger.debug"error class #{self} : $!: #{$!} "
                                render json:{:params => reqparams[:err]}
                            end
                        else
                            params[:err] = "#{Time.now} #{self} line:#{__LINE__} screnCode ummatch  params[:screenCode]:#{params[:screenCode]}  selected[screenCode]:#{selected["screenCode"]} "
                            render json:{:params => params[:err]}
                        end
                      end
                      ActiveRecord::Base.connection.commit_db_transaction()
                      params[:err] = ""
                      render json:{:outcnt => outcnt,:params => params}
                    rescue
                      params[:err] = " state 500"
                      params[:parse_linedata][:confirm] = false  
                      ActiveRecord::Base.connection.rollback_db_transaction()
                    else
                      ActiveRecord::Base.connection.commit_db_transaction()
                    end
                else
                  params[:err] = "please  select Order"
                  render json:{:params=> params}    
                end

            # when 'MkInvoiceNo'  
            #     if params["clickIndex"]
            #         outcnt = 0
            #         totalAmt =  0
            #         totalTax = 0
            #         reqparams = params.dup
            #         invoiceNo = "Inv-" + format('%06d',ArelCtl.proc_get_nextval("invoiceno_seq"))
            #         strInvoiceNo = "custacthead_invoiceno"
            #         ActiveRecord::Base.connection.begin_db_transaction()
            #         params["clickIndex"].each_with_index do |strselected,idx|
            #             next if strselected == "undefined"
            #             selected = JSON.parse(strselected)
            #             if params[:screenCode] == selected["screenCode"]
            #                 screen = ScreenLib::ScreenClass.new(params)
            #                 grid_columns_info = screen.proc_create_grid_editable_columns_info(reqparams)
            #                 if selected["id"] == "" or selected["id"].nil? 
            #                     render json:{:err=>"please  select after add custacts "}   ###mesaage    
            #                     return
            #                 else
            #                     fields =  ActiveRecord::Base.connection.select_values(%Q&
            #                                     select pobject_code_sfd from func_get_screenfield_grpname('#{params["email"]}','r_#{params[:screenCode].split("_")[1]}')&)
            #                     strsql = %Q& select #{fields.join(",")} from r_#{params[:screenCode].split("_")[1]} 
            #                                         where id = #{strselected["id"]} & 
            #                 end
            #                 reqparams[:parse_linedata] = ActiveRecord::Base.connection.select_one(strsql)
            #                 if params[:changeData]
            #                     JSON.parse(params[:changeData][idx]).each do |k,v|
            #                         if reqparams[:parse_linedata][k]
            #                             if k != strInvoiceNo 
            #                                 reqparams[:parse_linedata][k] = v
            #                             else
            #                                 if val != "" and val
            #                                     if CtlFields.proc_billord_exists(reqparams[:parse_linedata])
            #                                         render json:{:err=>" already issue billords "}   ###mesaage
            #                                         return    
            #                                     end
            #                                 else ###新しいInvoiceNoに変更される。
            #                                     ###ここでは何もしない。
            #                                 end
            #                             end
            #                         end
            #                     end
            #                 end
            #                 reqparams[:parse_linedata][strInvoiceNo] =  invoiceNo
            #                 reqparams["custactheads"] = []  ###amtの計算用
            #                 reqparams = screen.proc_confirm_screen(reqparams)
            #                 if reqparams[:err].nil?
            #                     outcnt += 1
            #                 else
            #                     ActiveRecord::Base.connection.rollback_db_transaction()
            #                     command_c["sio_result_f"] = "9"  ##9:error
            #                     command_c["sio_message_contents"] =  "class #{self} : LINE #{__LINE__} $!: #{$!} "[0..3999]    ###evar not defined
            #                     command_c["sio_errline"] =  "class #{self} : LINE #{__LINE__} $@: #{$@} "[0..3999]
            #                     Rails.logger.debug"error class #{self} : #{Time.now}: #{$@} "
            #                     Rails.logger.debug"error class #{self} : $!: #{$!} "
            #                     Rails.logger.debug"  command_c: #{command_c} "
            #                     render json:{:err=>reqparams[:err]}
            #                     raise    
            #                 end
            #             else
            #                 Rails.logger.debug%Q&#{Time.now} #{self} line:#{__LINE__} screnCode ummatch  params[:screenCode]:#{params[:screenCode]}  selected[screenCode]:#{selected["screenCode"]} &
            #                 raise
            #             end
            #         end
            #         amtTaxRate = {}
            #         reqparams["custactheads"].each do |head|
            #             totalAmt += head["amt"]
            #             totalTax += totalAmt * head["taxrate"]  / 100 ###変更要
            #             if amtTaxRate[head["taxrate"]]
            #                 amtTaxRate[head["taxrate"]]["amt"] += head["amt"]
            #                 amtTaxRate[head["taxrate"]]["count"] += 1
            #             else
            #                 amtTaxRate[head["taxrate"]] ={"amt" => head["amt"],"count" => 1}
            #             end
            #         end
            #         custactHead =  RorBlkCtl::BlkClass.new("r_custactheads")
            #         custactHeadCommand_c = custactHead.command_init
            #         reqparams["custactheads"].each do |head|
            #             custactHeadCommand_c["id"] = head["custacthead_id"]   ###修正のみ
            #             custactHeadCommand_c["custacthead_amt"] = totalAmt
            #             custactHeadCommand_c["custacthead_tax"] = totaltax
            #             custactHeadCommand_c["custacthead_taxjson"] = amtTaxRate.to_json 
            #             custactHeadCommand_c["custacthead_created_at"] = Time.now
            #             custactHeadCommand_c = custactHead.proc_create_tbldata(custactHeadCommand_c)
            #             custactHead.proc_private_aud_rec({},custactHeadCommand_c)
            #         end
            #         ActiveRecord::Base.connection.commit_db_transaction()
            #         render json:{:outcnt => outcnt,:err => "",:outqty => 0,:outamt => totalAmt,
            #                         :params => {:buttonflg => params[:buttonflg]}}
            #     else
            #         render json:{:err=>"please  select Order"}    
            #     end

            when 'mkShpords'  ###shpschsは作成済が条件。shpschsはpurords,prdords時に自動作成
                if params[:clickIndex]
                    outcnt,shortcnt,err,last_lotstks = Shipment.proc_mkShpords(params)      
                    if last_lotstks.size > 0 and err == ""
                      setParams = {}
                      setParams["segment"]  = "link_lotstkhists_update"   ###
                      setParams["tbldata"] = {}
                      setParams["gantt"] = {}
                      setParams["person_id_upd"] = params["person_id_upd"]
                      setParams["last_lotstks"] = last_lotstks.dup
                      processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
                      CreateOtherTableRecordJob.perform_later(setParams["seqno"][0])
                      ActiveRecord::Base.connection.commit_db_transaction()
                      render json:{:outcnt=>outcnt,:shortcnt=>shortcnt,:params=>{:buttonflg=>"mkShpords",:err => err}}
                    else
                      ActiveRecord::Base.connection.rollback_db_transaction()
                      render json:{:outcnt=>0,:shortcnt=>0,:params=>{:buttonflg=>"mkShpords",:err => err}}
                    end        
                else
                    render json:{:outcnt=>0,:shortcnt=>0,:params=>{:buttonflg=>"mkShpords",:err=>" please select"}}
                end
            
            when 'refShpords'   ###purords,prdordsからshpordsを表示
                reqparams = params.dup   ###
                if params["clickIndex"]
                    reqparams[:where_str] ||= ""
                    reqparams[:filtered] ||= []
                    reqparams[:pageIndex] ||= 0
                    reqparams[:pageSize] ||= 100
                    reqparams[:buttonflg] = "inlineedit7"
                    reqparams[:aud] = "edit"
                    reqparams[:screenCode] = "forInsts_shpords"   ###shpordsがshpinstsに変わるため
                    reqparams[:screenFlg] = "second"
                    reqparams["gantt"] ||= {}
                    reqparams["gantt"]["paretblname"] = params[:screenCode].split("_",2)[1]
                    secondScreen = ScreenLib::ScreenClass.new(reqparams)
                    grid_columns_info = secondScreen.proc_create_grid_editable_columns_info(reqparams)
                    pagedata,reqparams = Shipment.proc_second_shp reqparams,grid_columns_info
                    if pagedata == []
                        params[:screenFlg] = "first"
                        reqparams[:err] = "no shpords "
                        render json:{:params=>params}
                    else
                        render json:{:grid_columns_info=>grid_columns_info,:data=>pagedata,:params=>reqparams}
                    end
                else
                  screen = ScreenLib::ScreenClass.new(reqparams)
                  pagedata,reqparams = screen.proc_search_blk(reqparams)   ###:pageInfo  -->menu7から未使用
                  reqparams[:message] = "please  select "
                  render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams}   
                end
            
            when 'refShpinsts'  ###purords,prdordsからshpinstsを表示
                reqparams = params.dup   ### f
                if params["clickIndex"]
                    reqparams[:where_str] ||= ""
                    reqparams[:filtered] ||= []
                    reqparams[:pageIndex] ||= 0
                    reqparams[:pageSize] ||= 100
                    reqparams[:buttonflg] = "inlineedit7"
                    reqparams[:aud] = "edit"
                    reqparams[:screenCode] = "foract_shpinsts"   ###shpordsがshpinstsに変わるため
                    reqparams[:screenFlg] = "second"
                    reqparams["gantt"] ||= {}
                    reqparams["gantt"]["paretblname"] = params[:screenCode].split("_",2)[1]
                    secondScreen = ScreenLib::ScreenClass.new(reqparams)
                    grid_columns_info = secondScreen.proc_create_grid_editable_columns_info(reqparams)
                    pagedata,reqparams = Shipment.proc_second_shp reqparams,grid_columns_info   ###
                    if pagedata == []
                        params[:err] = "no shpinsts "
                        render json:{:params=>reqparams}  
                    else
                        render json:{:grid_columns_info=>grid_columns_info,:data=>pagedata,:params=>reqparams}
                    end
                else
                  screen = ScreenLib::ScreenClass.new(reqparams)
                  pagedata,reqparams = screen.proc_search_blk(reqparams)   ###:pageInfo  -->menu7から未使用
                  reqparams[:message] = "please  select Order"
                  render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams}
                end
          
            when 'refShpacts'   ###purords,prdordsからshpactsを表示
                reqparams = params.dup   ### 
                if params["clickIndex"]
                    reqparams[:where_str] ||= ""
                    reqparams[:filtered] ||= []
                    reqparams[:pageIndex] ||= 0
                    reqparams[:pageSize] ||= 100
                    reqparams[:buttonflg] = 'viewtablereq7'
                    reqparams[:screenCode] = "r_shpacts"   ###shpordsがshpinstsに変わるため
                    reqparams[:screenFlg] = "second"
                    reqparams["gantt"] ||= {}
                    reqparams["gantt"]["paretblname"] = params[:screenCode].split("_",2)[1]
                    secondScreen = ScreenLib::ScreenClass.new(reqparams)
                    grid_columns_info = secondScreen.proc_create_grid_editable_columns_info(reqparams)
                    pagedata,reqparams = secondScreen.proc_second_shpview reqparams  ###共通lib
                    render json:{:grid_columns_info=>grid_columns_info,:data=>pagedata,:params=>reqparams}
                else
                  screen = ScreenLib::ScreenClass.new(reqparams)
                  pagedata,reqparams = screen.proc_search_blk(reqparams)   ###:pageInfo  -->menu7から未使用
                  reqparams[:message] = "please  select Order"
                  render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams} 
                end

            when /^prdDvs|^prdErc/
                  reqparams = params.dup   ### 
                  reqparams[:where_str] ||= ""
                  if params["clickIndex"]
                      reqparams[:filtered] ||= []
                      reqparams[:pageIndex] ||= 0
                      reqparams[:pageSize] ||= 10
                      reqparams[:buttonflg] = 'inlineedit7'
                      reqparams[:screenFlg] = "second"
                      reqparams[:aud] = "update"
                      reqparams[:screenCode] =  params[:buttonflg].sub("D","_d").sub("E","_e")
                      reqparams[:view] =  reqparams[:screenCode].sub("prd_","r_")
                      if reqparams[:gantt]
                        reqparams[:gantt] = JSON.parse(reqparams[:gantt])
                      else
                        reqparams[:gantt] = {}
                      end
                      secondScreen = ScreenLib::ScreenClass.new(reqparams)
                      grid_columns_info = secondScreen.proc_create_grid_editable_columns_info(reqparams)
                      pagedata,reqparams = secondScreen.proc_second_dvserc reqparams  ###共通lib
                      render json:{:grid_columns_info=>grid_columns_info,:data=>pagedata,:params=>reqparams}
                  else
                    screen = ScreenLib::ScreenClass.new(reqparams)
                    pagedata,reqparams = screen.proc_search_blk(reqparams)   ###:pageInfo  -->menu7から未使用
                    reqparams[:message] = "please  select Order"
                    render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams}
                  end

            when /^rejection/
                reqparams = params.dup   ### 
                reqparams[:pageIndex] ||= 0
                reqparams[:pageSize] ||= 10
                if params[:clickIndex]
                      reqparams[:where_str] ||= ""
                      reqparams[:filtered] ||= []
                      reqparams[:screenCode] = reqparams[:view] =  "r_rejections"
                      selected_id = ""
                      cnt = 0
                      (params[:clickIndex]).each_with_index  do |selected,idx|  ###-次のフェーズに進んでないこと。
                        selected = JSON.parse(selected)
                        if selected["id"]
                          selected_id = selected["id"]
                          cnt +=1
                        end
                      end
                      if cnt == 0
                        reqparams[:screenFlg] = "first"
                        screen = ScreenLib::ScreenClass.new(reqparams)
                        pagedata,reqparams = second.proc_search_blk(reqparams)   ###:pageInfo  -->menu7から未使用
                        reqparams[:message] = "please  select Order"
                        render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams}
                      else
                        if cnt > 1
                          reqparams[:screenFlg] = "first"
                          screen = ScreenLib::ScreenClass.new(reqparams)
                          pagedata,reqparams = second.proc_search_blk(reqparams)   ###:pageInfo  -->menu7から未使用
                          reqparams[:message] = "please  select only one record "
                          render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams}
                        else
                          reqparams[:screenCode] = "r_rejections"
                          reqparams[:screenFlg] = "second"
                          strsql = %Q&
                                  select id from rejections  
                                            where paretblname = '#{params[:screenCode].split("_")[1]}'
                                            and paretblid = #{selected_id}
                              &
                          reject_id = ActiveRecord::Base.connection.select_value(strsql)
                          if reject_id 
                              reqparams[:buttonflg] = 'inlineedit7'
                              reqparams[:aud] = "update" 
                              reqparams[:where_str] = " where rejection_id = #{reject_id} "
                              second = ScreenLib::ScreenClass.new(reqparams)
                              pagedata,reqparams = second.proc_search_blk(reqparams)   ###:pageInfo  -->menu7から未使用
                              render json:{:grid_columns_info=>second.grid_columns_info,:data=>pagedata,:params=>reqparams}
                          else
                              reqparams[:buttonflg] = 'inlineadd7'
                              reqparams[:aud] = "add"
                              reqparams[:paretblname] = params[:screenCode].split("_")[1]
                              reqparams[:paretblid] = selected_id
                              strsql = %Q&
                                      select * from r_#{reqparams[:paretblname]} where id = #{selected_id}
                                  &
                              reqparams[:lineData] = ActiveRecord::Base.connection.select_one(strsql) 
                              reqparams[:pageSize] = 3
                              second = ScreenLib::ScreenClass.new(reqparams)
                              pagedata,reqparams = second.proc_add_empty_data(reqparams)  ### nil filtered sorting
                              render json:{:grid_columns_info=>second.grid_columns_info,:data=>pagedata,:params=>reqparams}
                          end
                        end
                      end
                else
                        screen = ScreenLib::ScreenClass.new(reqparams)
                        pagedata,reqparams = screen.proc_search_blk(reqparams)   ###:pageInfo  -->menu7から未使用
                        reqparams[:message] = "please  select Order"
                        render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams}
                end    

            when 'confirmShpinsts'
                reqparams = params.dup   ### 
                outcnt,err = Shipment.proc_confirmShpinsts(reqparams)
                reqparams[:buttonflg] = 'confirmAllSecond'
                reqparams[:err] = err
                render json:{:outcnt => outcnt,:params => reqparams}    
            
            when 'confirmShpacts'
                reqparams = params.dup   ### 
                outcnt,reqparams[:err] = Shipment.proc_confirmShpacts(reqparams)
                reqparams[:buttonflg] = 'confirmAllSecond'
                render json:{:outcnt => outcnt,:params => reqparams}    
            else
                Rails.logger.debug"#{Time.now} : buttonflg-->#{params[:buttonflg]} not support "
                Rails.logger.debug"#{Time.now} : buttonflg-->#{params[:buttonflg]} not support "
                Rails.logger.debug"#{Time.now} : buttonflg-->#{params[:buttonflg]} not support "    
            end
        end
        def show
        end
    end    
end
