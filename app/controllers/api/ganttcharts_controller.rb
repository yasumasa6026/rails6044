module Api
    class GanttchartsController < ApplicationController
        before_action :authenticate_api_user!
            def index
            end
            def create
                tasks = []
                tblcode = params[:screenCode].split("_")[1]
                line = JSON.parse(params[:linedata])   ###最後にclickされた行のみ有効
                    case params[:screenCode]
                    when /itms|opeitms|nditms/
                        ### 第三パラメータ　gantt_xxx-->順方向　reverse-->逆方向
                        ###　　　　　　　　　xxx_mst-->mater系  xxx-trn--->trn系
                        case  params[:buttonflg] 
                        when "ganttchart"
                            gantt_reverse_mast = "gantt_mst"
                            gantt =  GanttChart::GanttClass.new(gantt_reverse_mast)
                        when "reversechart"
                            gantt_reverse_mast = "reverse_mst"
                            gantt =  GanttChart::GanttClass.new(gantt_reverse_mast)
                        else
                             raise
                        end
                            ganttData =  gantt.proc_get_ganttchart_data(tblcode,line["id"],gantt_reverse_mast)  
                            ganttData.sort.each do |level,ganttdata|
                                tasks << {"id"=>ganttdata[:id],
                                     "name"=>ganttdata[:itm_code]+"(#{ganttdata[:itm_name]},#{ganttdata[:processseq]}):場所(#{ganttdata[:loca_code]}:#{ganttdata[:loca_name]}),
                                                QTY(#{ganttdata[:qty]}),NumberOfItems(#{ganttdata[:parenum]},#{ganttdata[:chilnum]})",
                                     "type"=>ganttdata[:type],
                                     "start"=>ganttdata[:start],"end"=>ganttdata[:duedate],
                                      "progress"=>0,"dependencies"=>ganttdata[:depend]
                                    }
                            end  
                    when /pur|prd|custschs|custords/
                        case  params[:buttonflg] 
                        when "ganttchart"
                            gantt =  GanttChart::GanttClass.new("gantt_trn")
                            ganttData =  gantt.proc_get_ganttchart_data(tblcode,line["id"],"gantt_trn")
                            ganttData.sort.each do |level,ganttdata|
                                tasks << {"id"=>ganttdata[:id],
                                     "name"=>ganttdata[:itm_code]+"(#{ganttdata[:itm_name]},#{ganttdata[:processseq]}):場所(#{ganttdata[:loca_code]}:#{ganttdata[:loca_name]}),
                                                QTY(#{ganttdata[:qty]}),STK(#{ganttdata[:qty_stk]}),#{ganttdata[:tblname]}(#{ganttdata[:sno]}),",
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
                                      "dependencies"=>ganttdata[:depend]
                                    }
                            end
                        when "reversechart"
                            gantt =  GanttChart::GanttClass.new("reverse_trn")
                            ganttData =  gantt.proc_get_ganttchart_data(tblcode,line["id"],"reverse_trn")
                            ganttData.sort.reverse.each do |level,ganttdata|
                                tasks << {"id"=>ganttdata[:id],
                                     "name"=>ganttdata[:itm_code]+"(#{ganttdata[:itm_name]},#{ganttdata[:processseq]}):場所(#{ganttdata[:loca_code]}:#{ganttdata[:loca_name]}),
                                                QTY(#{ganttdata[:qty]}),STK(#{ganttdata[:qty_stk]}),#{ganttdata[:tblname]}(#{ganttdata[:sno]}),",
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
                                      "dependencies"=>ganttdata[:depend]
                                    }
                            end
                        else
                             raise
                        end
                    end
                render json: {:tasks=>tasks}   
            end
            def show
            end  
    end
  end
    