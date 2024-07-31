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
                                     "name"=>ganttdata[:itm_code]+":#{ganttdata[:itm_name]},#{ganttdata[:processseq]},#{ganttdata[:loca_code]}:#{ganttdata[:loca_name]},QTY:#{ganttdata[:qty]},"  +
                                               %Q& #{case ganttdata[:classlist_code]
                                                when "installationCharge","mold","apparatus","ITool"
                                                    ""
                                                else
                                                    "NumberOfItems:#{ganttdata[:chilnum]}/#{ganttdata[:parenum]}"
                                                end}&,
                                     "type"=>ganttdata[:type],"start"=>ganttdata[:start],"end"=>ganttdata[:duedate],
                                     "styles"=>case ganttdata[:classlist_code]
                                                when "installationCharge"   ###設置
                                                    {"backgroundColor"=>"#33FFFF"}
                                                when "mold"  ###金型
                                                    {"backgroundColor"=>"#66FF66"}
                                                when "apparatus" ### 設備
                                                    {"backgroundColor"=>"#FFFF66"}
                                                when "ITool" ### 工具
                                                    {"backgroundColor"=>"#009900"}
                                                else
                                                    {"backgroundColor"=>"#9C6E41"} 
                                                end    ,
                                      "progress"=>0,"dependencies"=>ganttdata[:depend]
                                    }
                            end
                    when /pur|prd|custschs|custords/
                        case  params[:buttonflg] 
                        when "ganttchart"
                            gantt =  GanttChart::GanttClass.new(params[:buttonflg],"trns")
                            ganttData =  gantt.proc_get_ganttchart_data(tblcode,line["id"],params[:buttonflg])
                            ganttData.sort.each do |level,ganttdata|
                                str_qty =  case ganttdata[:tblname]
                                            when /schs/
                                                "QTY_SCH:#{ganttdata[:qty_sch]}"
                                            when /ords|insts|reply/
                                                "QTY:#{ganttdata[:qty]}"
                                             when /dlvs|acts/
                                                "STK:#{ganttdata[:qty_stk]}"
                                            else
                                                ""
                                            end
                                tasks << {"id"=>ganttdata[:id],
                                     "name"=>"#{ganttdata[:tblname]}:#{ganttdata[:sno]}" + 
                                                    ",#{ganttdata[:itm_code]}:#{ganttdata[:itm_name]},#{ganttdata[:processseq]},#{ganttdata[:loca_code]}:#{ganttdata[:loca_name]}," +
                                                    str_qty +
                                                    " ,#{ganttdata[:paretblname]}:#{ganttdata[:paretblid]}",
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
                                str_qty =  case ganttdata[:tblname]
                                            when /schs/
                                                "QTY_SCH:#{ganttdata[:qty_sch]}"
                                            when /ords|insts|reply/
                                                "QTY:#{ganttdata[:qty]}"
                                             when /dlvs|acts/
                                                "STK:#{ganttdata[:qty_stk]}"
                                            else
                                                ""
                                            end
                                tasks << {"id"=>ganttdata[:id],
                                "name"=>"#{ganttdata[:tblname]}:#{ganttdata[:sno]}" + 
                                            "#{ganttdata[:itm_code]}:#{ganttdata[:itm_name]},#{ganttdata[:processseq]},#{ganttdata[:loca_code]}:#{ganttdata[:loca_name]}," +
                                            str_qty + 
                                            " ,#{ganttdata[:paretblname]}:#{ganttdata[:paretblid]}",
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
		            Rails.logger.debug " class:#{self} ,line:#{__LINE__},tasks:#{tasks} "
                    render json: {:tasks=>tasks}   
                when "updateNditm"
                    reqparams = params.dup
                    reqparams["email"] = current_api_user[:email]
                    strsql = "select code,id from persons where email = '#{reqparams["email"]}'"
                    person = ActiveRecord::Base.connection.select_one(strsql)
                    if person.nil?
						reqparams["status"] = 403
						reqparams[:err] = "Forbidden charge_paerson not detect"

                        render json: {:params => reqparams}
                        return   
                    end
                    reqparams["person_code_upd"] = person["code"]
                    reqparams["person_id_upd"] = person["id"]
                    gantt_name = JSON.parse(params[:task])["name"]
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
                when "updateTrngantt"
                    reqparams = params.dup
                    reqparams["email"] = current_api_user[:email]
                    strsql = "select code,id from persons  where email = '#{reqparams["email"]}'"
                    person = ActiveRecord::Base.connection.select_one(strsql)
                    if person.nil?
						reqparams["status"] = 403
						reqparams[:err] = "Forbidden paerson code  not detect"
                        render json: {:params => reqparams}
                        return   
                    end
                    reqparams["person_code_upd"] = person["code"]
                    reqparams["person_id_upd"] = person["id"]
                    gantt_name = JSON.parse(params[:task])["name"]
                    tbl_sno,item,processseq,loca, qty,parent = gantt_name.split(",")
                    tblname,sno = tbl_sno.split(":")
                    itm_code,itm_name = item.split(":")
                    loca_code,loca_name = loca.split(":")
                    reqparams[:screenFlg] = "second"
                    reqparams[:pageSize] = 1
                    case params[:aud]
                    when /update_trngantts/
                            reqparams[:buttonflg] = "inlineedit7"
                            reqparams[:screenCode] = "update_trngantts"
                            screen = ScreenLib::ScreenClass.new(reqparams)
                            reqparams[:view]  = "update_trngantts('#{tblname}','#{sno}','#{itm_code}','#{itm_name}',#{processseq})"
                            pagedata,reqparams = screen.proc_search_blk(reqparams)   ###:pageInfo  -->menu7から未使用
                            render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams}
                    when /update_free_to_alloc/
                            reqparams[:buttonflg] = "inlineadd7"
                            reqparams[:screenCode] = "freetoalloc_alloctbls"
                            screen = ScreenLib::ScreenClass.new(reqparams)
                            reqparams[:view] = "freetoalloc_alloctbls('#{tblname}','#{sno}')"
                            pagedata,reqparams = screen.proc_search_blk(reqparams)   ###:pageInfo  -->menu7から未使用
                            render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams}
                    when /insert_trngantts/
                            reqparams[:buttonflg] = "inlineadd7"
                            reqparams[:screenCode] = "insert_trngantts"
                            screen = ScreenLib::ScreenClass.new(reqparams)
                            strsql = %Q&                                        
                                        select 	t.key,t.mlevel,
                                                orgitm.code itm_code_org,orgitm.name itm_name_org,t.processseq_org trngantt_processseq_org,
                                                orgshelfno.loca_code loca_code_org,orgshelfno.loca_name loca_name_org,
                                                t.duedate_org trngantt_duedate_org,
                                                t.duedate_trn trngantt_duedate_trn,t.toduedate_trn trngantt_toduedate_pare,t.starttime_trn trngantt_starttime_pare,
                                                trnitm.code itm_code_pare,trnitm.name itm_name_pare,t.processseq_trn trngantt_processseq_pare,
                                                trnshelfno.code shelfno_code_pare,trnshelfno.name shelfno_name_pare,
                                                trnshelfno.loca_code loca_code_pare,trnshelfno.loca_name loca_name_pare,
                                                t.qty_sch trngantt_qty_sch_pare,prjno.code prjno_code,prjno.name prjno_name,
                                                t.itms_id_org trngantt_itm_id_org,
                                                t.itms_id_trn trngantt_itm_id_pare,
                                                t.shelfnos_id_trn trngantt_shelfno_id_pare,t.shelfnos_id_to_trn trngantt_shelfno_id_to_pare,
                                                t.prjnos_id trngantt_prjno_id
                                            from trngantts t
                                            inner join #{tblname} p on p.id = t.tblid
                                            inner join itms orgitm on orgitm.id = t.itms_id_org
                                            inner join itms trnitm on trnitm.id = t.itms_id_trn
                                            inner join (select s.id,s.code,s.name,l.code loca_code,l.name loca_name,
                                                                                    l.id locas_id
                                                                from shelfnos s 
                                                                inner join locas l on s.locas_id_shelfno = l.id) 
                                                        orgshelfno on orgshelfno.id = t.shelfnos_id_org
                                            inner join (select s.id,s.code,s.name,l.code loca_code,l.name loca_name,
                                                                                    l.id locas_id
                                                                from shelfnos s 
                                                                inner join locas l on s.locas_id_shelfno = l.id) 
                                                        trnshelfno on trnshelfno.id = t.shelfnos_id_trn
                                            inner join prjnos prjno on prjno.id = t.prjnos_id 
                                        where t.tblname = '#{tblname}' and p.sno = '#{sno}'
                            &
                            reqparams[:trngantt] = ActiveRecord::Base.connection.select_one(strsql)
                            strsql = %Q&
                                        select * from screens s
                                                inner join pobjects p on s.pobjects_id_scr = p.id
                                                where p.code = 'insert_trngantts' and s.expiredate > current_date
                            &
                            rec = ActiveRecord::Base.connection.select_one(strsql)
                            if rec 
                                reqparams[:pageSize] = if rec["rows_per_page"].to_i == 0 then 5 else rec["rows_per_page"].to_i end  
                            else
                                reqparams[:pageSize] = 5
                            end
                            pagedata,reqparams = screen.proc_add_empty_data(reqparams)   ###:pageInfo  -->menu7から未使用
                            render json:{:grid_columns_info=>screen.grid_columns_info,:data=>pagedata,:params=>reqparams}
                    else
                            raise
                    end
                else
                     raise
                end
            end
            def show
            end  
    end
  end
    