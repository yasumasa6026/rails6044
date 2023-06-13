module Api
    class GanttchartsController < ApplicationController
        before_action :authenticate_api_user!
            def index
            end
            def create
                case  params[:buttonflg] 
                when /ganttchart|reversechart/
                    tasks = []
                    tblcode = params[:screenCode].split("_")[1]
                    line = JSON.parse(params[:linedata])   ###最後にclickされた行のみ有効
                    case params[:screenCode]
                    when /itms|opeitms|nditms/
                        ### 第三パラメータ　gantt_xxx-->順方向　reverse-->逆方向
                        ###　　　　　　　　　xxx_mst-->mater系  xxx-trn--->trn系
                            gantt =  GanttChart::GanttClass.new(params[:buttonflg],"itms")
                            ganttData =  gantt.proc_get_ganttchart_data(tblcode,line["id"],params[:buttonflg])  
                            ganttData.sort.each do |level,ganttdata|
                                tasks << {"id"=>ganttdata[:id],
                                     "name"=>ganttdata[:itm_code]+":#{ganttdata[:itm_name]},#{ganttdata[:processseq]},#{ganttdata[:loca_code]}:#{ganttdata[:loca_name]},QTY:#{ganttdata[:qty]},
                                                NumberOfItems:#{ganttdata[:chilnum]}/#{ganttdata[:parenum]}",
                                     "type"=>ganttdata[:type],
                                     "start"=>ganttdata[:start],"end"=>ganttdata[:duedate],
                                     "styles"=>{"backgroundColor"=>"#9C6E41"} ,
                                      "progress"=>0,"dependencies"=>ganttdata[:depend]
                                    }
                            end
                    when /pur|prd|custschs|custords/
                        case  params[:buttonflg] 
                        when "ganttchart"
                            gantt =  GanttChart::GanttClass.new(params[:buttonflg],"trns")
                            ganttData =  gantt.proc_get_ganttchart_data(tblcode,line["id"],params[:buttonflg])
                            ganttData.sort.each do |level,ganttdata|
                                tasks << {"id"=>ganttdata[:id],
                                     "name"=>ganttdata[:itm_code]+":#{ganttdata[:itm_name]},#{ganttdata[:processseq]},#{ganttdata[:loca_code]}:#{ganttdata[:loca_name]},
                                                    QTY_SCH:#{ganttdata[:qty_sch]},QTY:#{ganttdata[:qty]},STK:#{ganttdata[:qty_stk]},
                                                        #{ganttdata[:tblname]}:#{ganttdata[:sno]},#{ganttdata[:paretblname]}:#{ganttdata[:paretblid]}",
                                     "type"=>ganttdata[:type],
                                     "start"=>ganttdata[:start],"end"=>ganttdata[:duedate],
                                      "progress"=>case ganttdata[:tblname]
                                                when /ords/
                                                    50
                                                when /insts/
                                                    60
                                                when /rply/
                                                    70
                                                when /dlvs/
                                                    90
                                                when /acts/
                                                    100
                                                else
                                                    0
                                                end,
                                       "styles"=>if ganttdata[:delay] then {"backgroundColor"=>"#FF0000"} else {"backgroundColor"=>"#9C6E41"} end,
                                      "dependencies"=>ganttdata[:depend]
                                    }
                            end
                        when "reversechart"
                            gantt =  GanttChart::GanttClass.new(params[:buttonflg],"trns")
                            ganttData =  gantt.proc_get_ganttchart_data(tblcode,line["id"],params[:buttonflg])
                            ganttData.sort.each do |level,ganttdata|
                                tasks << {"id"=>ganttdata[:id],
                                "name"=>ganttdata[:itm_code]+":#{ganttdata[:itm_name]},#{ganttdata[:processseq]},#{ganttdata[:loca_code]}:#{ganttdata[:loca_name]},
                                               QTY_SCH:#{ganttdata[:qty_sch]},QTY:#{ganttdata[:qty]},STK:#{ganttdata[:qty_stk]},
                                               #{ganttdata[:tblname]}:#{ganttdata[:sno]},#{ganttdata[:paretblname]}:#{ganttdata[:paretblid]}",
                                     "type"=>ganttdata[:type],
                                     "start"=>ganttdata[:start],"end"=>ganttdata[:duedate],
                                      "progress"=>case ganttdata[:tblname]
                                                when /ords/
                                                    50
                                                when /insts/
                                                    60
                                                when /rply/
                                                    70
                                                when /dlvs/
                                                    90
                                                when /acts/
                                                    100
                                                else
                                                    0
                                                end,
                                        "styles"=>if ganttdata[:delay] then {"backgroundColor"=>"#FF0000"} else {"backgroundColor"=>"#9C6E41"} end,
                                      "dependencies"=>ganttdata[:depend]
                                    }
                            end
                        else
                             raise
                        end
                    end
                    render json: {:tasks=>tasks}   
                when "updategantt"
                    $email = current_api_user[:email]
                    strsql = "select person_code_chrg,chrg_person_id_chrg from r_chrgs rc where person_email_chrg = '#{$email}'"
                    person = ActiveRecord::Base.connection.select_one(strsql)
                    if person.nil?
                        person = {"person_code_chrg" => "0","chrg_person_id_chrg" =>0 }
                    end
                    $person_code_chrg = person["person_code_chrg"]
                    $person_id_upd = person["chrg_person_id_chrg"]
                    gantt_name = JSON.parse(params[:task])["name"]
                    reqparams = params.dup
                    if params[:screenCode] =~ /itm/
                        itm,processseq,loca, qty,numberOfItems = gantt_name.split(",")
                        reqparams[:filtered] = [%Q%{"id":"itm_code","value":"#{itm.split(":")[0]}"}%,
                                                %Q%{"id":"opeitm_processseq","value":"#{processseq}"}%,
                                                %Q%{"id":"opeitm_priority","value":"999"}%]
                        reqparams[:screenCode] = "gantt_nditms"
                        reqparams[:screenFlg] = "second"
                        strsql = %Q&
                                    select * from screens s
                                            inner join pobjects p on s.pobjects_id_scr = p.id
                                            where p.code = 'gantt_nditms' and s.expiredate > current_date
                        &
                        rec = ActiveRecord::Base.connection.select_one(strsql)
                        if rec 
                            reqparams[:pageSize] = if rec["rows_per_page"].to_i == 0 then 5 else rec["rows_per_page"].to_i end  
                        else
                            reqparams[:pageSize] = 5
                        end
                        case params[:aud]
                        when /add/  ###子部品を追加
                            reqparams[:parse_linedata] = {}
                            reqparams[:parse_linedata][:itm_code],reqparams[:parse_linedata][:itm_name] = itm.split(":")
                            reqparams[:parse_linedata][:processseq] = processseq
                            reqparams[:parse_linedata][:priority] = 999
                            reqparams[:buttonflg] = "inlineedit7"
                            screen = ScreenLib::ScreenClass.new(reqparams)
                            pagedata,reqparams = screen.proc_add_empty_data(reqparams)   ###:pageInfo  -->menu7から未使用
                            render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams}
                        when /update/
                            reqparams[:buttonflg] = "inlineedit7"
                            screen = ScreenLib::ScreenClass.new(reqparams)
                            pagedata,reqparams = screen.proc_search_blk(reqparams)   ###:pageInfo  -->menu7から未使用
                            render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams}
                        when /search/
                            reqparams[:buttonflg] = "viewtablereq7"
                            screen = ScreenLib::ScreenClass.new(reqparams)
                            pagedata,reqparams = screen.proc_search_blk(reqparams)   ###:pageInfo  -->menu7から未使用
                            render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams}
                        else
                            raise
                        end
                    else
                        itm,processseq,loca, qty_sch,qty,stk,tblname,sno = gantt_name.split(",")
                    end
                else
                     raise
                end
            end
            def show
            end  
    end
  end
    