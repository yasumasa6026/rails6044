module Api
    class GanttchartsController < ApplicationController
        before_action :authenticate_api_user!
            def index
            end
            def create
                case params[:buttonflg] 
                when 'ganttchart'
                    case params[:screenCode]
                    when /itms|opeitms|nditms/
                        tasks = []
                        tblcode = params[:screenCode].split("_")[1]
                        gantt =  GanttChart::GanttClass.new()
                        line = JSON.parse(params[:linedata])   ###最後にclickされた行のみ有効
                        ### 第三パラメータ　gantt_xxx-->順方向　reverse-->逆方向
                        ###　　　　　　　　　xxx_mst-->mater系  xxx-trn--->trn系
                        ganttData =  gantt.proc_get_ganttchart_data(tblcode,line["id"],"gantt_mst")   
                        ganttData.sort.each do |level,ganttdata|
                            tasks << {"id"=>ganttdata[:id],
                                 "name"=>ganttdata[:itm_code]+"(#{ganttdata[:itm_name]},#{ganttdata[:processseq]}):場所(#{ganttdata[:loca_code]}:#{ganttdata[:loca_name]}),
                                            QTY(#{ganttdata[:qty]}),NumberOfItems(#{ganttdata[:parenum]},#{ganttdata[:chilnum]})",
                                 "type"=>ganttdata[:type],
                                 "start"=>ganttdata[:start],"end"=>ganttdata[:duedate],
                                  "progress"=>0,"dependencies"=>ganttdata[:depend]
                                }
                        end    
                    end
                end
                render json: {:tasks=>tasks}   
            end
            def show
            end  
    end
  end
    