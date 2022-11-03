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
                reqparams[:parse_linedata] = JSON.parse(params[:linedata])
                reqparams = CtlFields.proc_chk_fetch_rec reqparams
                render json: {:params=>reqparams}   

            when "check_request"  
                reqparams = params.dup
                reqparams[:parse_linedata] = JSON.parse(params[:linedata])
                JSON.parse(params[:checkCode]).each do |sfd,checkcode|
                  reqparams = CtlFields.proc_judge_check_code reqparams,sfd,checkcode
                end
                render json: {:params=>reqparams}   

            when "confirm7"
                reqparams = params.dup   ### fields.proc_chk_fetch_rec でparamsがnilになってしまうため。　　
                reqparams[:parse_linedata] = JSON.parse(params[:linedata])
                reqparams = screen.proc_confirm_screen(reqparams)
                render json: {:linedata=> reqparams[:parse_linedata],:params=>reqparams}

            when 'download7'
                download_columns_info,totalCount,pagedata = screen.proc_download_data_blk(params)   ### nil filtered sorting
                render json:{:excelData=>{:columns=>download_columns_info.to_json,:data=>pagedata.to_json},
                            :totalCount=>totalCount,:filttered=>params[:filtered] }    

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
                Rails.logger.debug"#{Time.now} : buttonflg-->#{buttonflg} not support "    
            end
        end
        def show
        end
    end    
end
