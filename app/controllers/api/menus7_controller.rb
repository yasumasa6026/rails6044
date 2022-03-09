module Api
    class Menus7Controller < ApplicationController
        before_action :authenticate_api_user!
        def index
        end
        def create
            ###JSON.parseのエラー対応　要
            $email = current_api_user[:email]
            strsql = "select person_code_chrg from r_chrgs rc where person_email_chrg = '#{$email}'"
            $person_code_chrg = ActiveRecord::Base.connection.select_value(strsql)
 
            screen = ScreenLib::ScreenClass.new(params)
            #####    
            case params[:req] 
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
            
            when 'viewtablereq7','inlineedit7'
              pagedata,reqparams = screen.proc_search_blk(params)   ###:pageInfo  -->menu7から未使用
              render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams}
             
            when 'inlineadd7'
              pagedata,reqparams = screen.proc_add_empty_data(params)  ### nil filtered sorting
              render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams}               
                
            when "fetch_request"
                reqparams = params.dup   ### CtlFields.proc_chk_fetch_rec でparamsがnilになってしまうため。　　
                reqparams[:parse_linedata] = JSON.parse(params[:linedata])
                reqparams = CtlFields.proc_chk_fetch_rec reqparams
                ###xparams[:parse_linedata] = {}
                render json: {:params=>reqparams}   

            when "check_request"  
                reqparams = params.dup
                reqparams[:parse_lineddata] = JSON.parse(params[:linedata])
                JSON.parse(params[:checkcode]).each do |sfd,checkcode|
                  reqparams = CtlFields.proc_judge_check_code reqparams,sfd,checkcode
                end
               ### ?????????? reqparams[:parse_linedata] = {}
                render json: {:params=>reqparams}   

            when "confirm7"
                reqparams = params.dup   ### CtlFields.proc_chk_fetch_rec でparamsがnilになってしまうため。　　
                reqparams[:parse_linedata] = JSON.parse(params[:linedata])
                reqparams = screen.proc_confirm_screen(reqparams)
                render json: {:linedata=> reqparams[:parse_linedata]}

            when 'download7'
              download_columns_info,totalCount,pagedata = screen.proc_download_data_blk(params)   ### nil filtered sorting
              render json:{:excelData=>{:columns=>download_columns_info.to_json,:data=>pagedata.to_json},
                            :totalCount=>totalCount,:filttered=>params[:filtered] }    

            when 'mkshpinsts'  ###shpordsは作成済が条件
                outcnt,shortcnt,err = Shipment.proc_mkshpinsts(screen.screenCode),params[:clickIndex]
                render json:{:outcnt=>outcnt,:shortcnt=>shortcnt,:err=>err}    
            
            when 'mkshpacts'
                reqparams[:where_str] ||= ""
                reqparams[:filtered] ||= []
                reqparams[:pageIndex] ||= 0
                reqparams[:pageSize] ||= 100
                req = reqparams[:req] = "inlineedit7"
                screenCode = reqparams[:screenCode] = "foract_shpinsts"   ###shpinstsがshpactsに変わるため
                screen.proc_create_grid_editable_columns_info(reqparams)
                pagedata = Shipment.proc_mkshpacts params,screen.grid_columns_info
                render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams}  
            
            when 'refshpacts'
                reqparams[:where_str] ||= ""
                reqparams[:filtered] ||= []
                reqparams[:pageIndex] ||= 0
                reqparams[:pageSize] ||= 100
                req = reqparams[:req] = "'viewtablereq7'"
                screenCode = reqparams[:screenCode] = "r_shpacts"   ###shpinstsがshpactsに変わるため
                reqparams = screen.proc_create_grid_editable_columns_info(reqparams)
                pagedata = Shipment.proc_refshpacts reqparams
                render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams}
  
            when 'confirm_all'  ###チェック済が条件
                case screen.screenCode
                when "foract_shpinsts"
                    outcnt,shortcnt,err = Shipment.proc_shpact_confirmall
                    render json:{:outcnt=>outcnt,:err=>err}  
                end  
            else
              p "#{Time.now} : req-->#{req} not support "    
            end
        end
        def show
        end
    end    
end
