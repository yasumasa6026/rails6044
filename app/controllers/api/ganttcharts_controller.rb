module Api
    class GanttchartsController < ApplicationController
        before_action :authenticate_api_user!
            def index
            end
            def create
                case params[:buttonflg] 
                when 'ganttchart'
                    if params[:linedata]
                        command_r = JSON.parse params[:linedata]
                        case params[:screenCode] 
                            when /nditms/
                                opeitms_id = command_r["nditm_opeitm_id"]
                            when /opeitms/
                                opeitms_id = command_r["opeitm_id"]
                            when /itms/
                            if command_r["itm_id"]
                                opeitms_id =  GanttChart.get_opeitms_id_from_itm(command_r["itm_id"])
                            else
                                opeitms_id = nil
                            end
                    else
                        gantt = []
                        return
                    end    
                end
                if opeitms_id.nil?
                    gantt = []
                    return
                else 
                    gantt =[]
                    ganttchartData =  GanttChart.proc_get_ganttchart_data(opeitms_id)   
                    ganttchartData.each do |level,ganttdata|
                      gantt << [level,ganttdata["itm_code"],
                                "Date(#{ganttdata["start"].year},#{ganttdata["start"].month-1},#{ganttdata["start"].day})",
                                "Date(#{ganttdata["end"].year},#{ganttdata["end"].month-1},#{ganttdata["end"].day})",
                                  nil, "0",ganttdata["depend"]
                                ]
                    end    
                end
            end
            render json: {:ganttChartData=>gantt}   
          end
          def show
          end  
    end
  end
    