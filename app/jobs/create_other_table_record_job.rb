class CreateOtherTableRecordJob < ApplicationJob
    queue_as :default 
    def perform(pid)
        # 後で実行したい作業をここに書く
        begin
            perform_strsql = "select * from  processreqs t 
                            where t.result_f = '0'  and t.seqno = #{pid} 
                            and not exists(select 1 from processreqs c where t.seqno = c.seqno and t.id > c.id
                                        and c.result_f != '1')
                            order by t.id limit 1 for update"
            processreq = ActiveRecord::Base.connection.select_one(perform_strsql)            
            params = JSON.parse(processreq["reqparams"])   
            strsql = %Q% select * from persons where id = #{params["tbldata"]["persons_id_upd"]}
                    %
            person = ActiveRecord::Base.connection.select_one(strsql) ###
            params["email"] = person["email"]
            params["person_code_chrg"] = person["code"]
            params["person_id_upd"] = person["id"]
            ActiveRecord::Base.connection.begin_db_transaction()
            until processreq.nil? do
                    tbldata = params["tbldata"].dup
                    setParams = params.dup
                    opeitm = params["opeitm"].dup
                    if setParams["where_str"]
                        setParams["where_str"] = setParams["where_str"].gsub("#!","'")
                    end
                    gantt = params["gantt"].dup
                    tblname = gantt["tblname"]
                    tblid = gantt["tblid"]
                    paretblname = gantt["paretblname"]
                    paretblid = gantt["paretblid"]
                    strsql = %Q%update processreqs set result_f = '5'  where id = #{processreq["id"]}
                    %
                    ActiveRecord::Base.connection.update(strsql)
                    parent = {}
                        ##r_xxxxの処理が遅いためテーブル処理に変更
                    tbldata.each do |key,val| ###依頼元
                        parent[paretblname.chop + "_" + key.sub("s_id","_id")] = val   
                        if key =~ /s_id/ ###孫の項目まで対応
                                    strsql = %Q&
                                        select * from #{key.split("_id")[0]}  where id = #{val}
                                        &
                                    ActiveRecord::Base.connection.select_one(strsql).each do |nextkey,value| ###依頼元
                                        parent[key.split("s_id")[0] + "_" + nextkey.sub("s_id","_id")] = value
                                    end       
                        end
                    end
                    result_f = '1'
                    remark = ""
                    case params["segment"]
                        when "skip" 
                        when "link_lotstkhists_update" ###/insts$|acts$|dlvs$|rets$/のとき
                            opeLotStk = Operation::OpeClass.new(params)  ###xxxschs,xxxords
                            opeLotStk.proc_link_lotstkhists_update()  
                        when "sumrequest" 
                        when "splitrequest"  

                        when "createtable"
                            parent.select do |key,val|  
                                if key.to_s =~ /_autocreate/
                                    fmtbl_totbls = JSON.parse(val)  ###table suppliers等の項目autocreateに次に作成されるテーブルが登録されている。
                                    fmtbl_totbls.each do |totbl,fmtbl|   ### {totbl => fmtbl}
                                        if fmtbl == tblname
                                            ArelCtl.proc_createtable(fmtbl,totbl,parent,params)
                                        end
                                    end
                                end
                            end    

                        when "mkprdpurords"  ###  xxxschsからxxxordsを作成。
                            mkordparams = {}
                            mkordparams[:incnt] = 0
                            mkordparams[:inqty] = 0
                            mkordparams[:inamt] = 0
                            mkordparams[:outcnt] = 0
                            mkordparams[:outqty] = 0
                            mkordparams[:outamt] = 0
                            mkordparams = MkordinstLib.proc_mkprdpurords params,mkordparams
                            mkordparams[:message_code] = ""
                            mkordparams[:remark] = "  CreateOtherTableRecordJob mkprdpurords line:#{__LINE__}"
                            strsql = %Q%update mkprdpurords set incnt = #{mkordparams[:incnt]},inqty = #{mkordparams[:inqty]},
                                                inamt = #{mkordparams[:inamt]},outcnt = #{mkordparams[:outcnt]},
                                                outqty = #{mkordparams[:outqty]},outamt = #{mkordparams[:outamt]} ,
                                                message_code = '#{mkordparams[:message_code]}',remark = '#{mkordparams[:remark]}'
                                                where id = #{params["mkprdpurords_id"]}
                                %
                            ActiveRecord::Base.connection.update(strsql)
                        when "mkbillords"
                        when "mkbillinsts"
                            mkbillinstparams = {}
                            mkbillinst = tbldata.dup
                            mkbillinstparams[:incnt] = mkbillinst["incnt"].to_f
                            mkbillinstparams[:inamt] = mkbillinst["inamt"].to_f
                            mkbillinstparams[:outcnt] = mkbillinst["outcnt"].to_f
                            mkbillinstparams[:outamt] = mkbillinst["outamt"].to_f
                            mkbillinstparams = MkordinstLib.proc_mkbillinsts params,mkbillinstparams
                            mkbillinstparams[:message_code] = ""
                            mkbillinstparams[:remark] = "  CreateOtherTableRecordJob mkbillinsts line:#{__LINE__}"
                            strsql = %Q%update mkbillinsts set incnt = #{mkbillinstparams[:incnt]},
                                                inamt = #{mkbillinstparams[:inamt]},outcnt = #{mkbillinstparams[:outcnt]},
                                                outamt = #{mkbillinstparams[:outamt]} ,
                                                message_code = '#{mkordparams[:message_code]}',remark = '#{mkbillinstparams[:remark]}'
                                                where id = #{params["mkbillinsts_id"]}
                                %
                            ActiveRecord::Base.connection.update(strsql)

                        when /mkpayschs|mkbillschs/
                            ###ArelCtl.proc_createtable は使用しない
                            ###bill_loca_id_bill_cust
                            amt_src = 0
                            isudate = Time.now
                            duedate = Time.now
                            case params["segment"]
                            when "mkpayschs"
                                strsql = %Q%select b.* from payments b
                                            inner join suppliers c on c.payments_id_supplier = b.id   
                                            where c.id = #{params["suppliers_id"]}
                                    %
                            when "mkbillschs"
                                strsql = %Q%select b.* from bills b
                                                inner join custs c on c.bills_id_cust = b.id   
                                            where c.id = #{params["custs_id"]}
                                    %
                            end
                            paybill = ActiveRecord::Base.connection.select_one(strsql)
                            case paybill["period"]
                            when "-30" ###前月を対象
                                isudate = params["duedate"].to_date.since(1.month)  ###params["duedate"]受入日
                                newdd = paybill["termof"].split(",")[0]  ###翌月一回のみ
                                isudate = (isudate.strftime("%Y") + "-" +isudate.strftime("%m") + "-" + newdd).to_date
                                JSON.parse(paybill["ratejson"]).each do |rate|
                                    rate.each do |k,val|
                                        case k
                                        when "rate"
                                            amt_src = params["amt_src"].to_f * val.to_i / 100 
                                        when "duration"
                                            duedate =  isudate.since(val.to_i.day)  ###支払日
                                        end
                                    end
                                end
                            when /-1|0/
                                isudate = params["duedate"].to_date.since(paybill["period"].to_i*-1.day)###params["duedate"]受入日
                                paybill["termof"].split(",").each do |newdd|
                                   if duedate < (isudate.strftime("%Y") + "-" +isudate.strftime("%m") + "-" + newdd).to_date
                                       if isudate > (isudate.strftime("%Y") + "-" +isudate.strftime("%m") + "-" + newdd).to_date
                                            isudate = (isudate.strftime("%Y") + "-" +isudate.strftime("%m") + "-" + newdd).to_date
                                       end
                                    end
                                end
                                JSON.parse(paybill["ratejson"]).each do |rate|
                                    rate.each do |k,val|
                                        case k
                                        when "rate"
                                            amt_src = params["amt_src"].to_f * val.to_i / 100 
                                        when "duration"
                                            duedate =  isudate.since(val.to_i.day)  ###支払日
                                        end
                                    end
                                end
                            end    
                            case params["segment"]
                            when "mkpayschs"           
                                paybillschs = {"amt_src" =>amt_src,"isudate"=>isudate,"duedate" =>duedate,"tax" =>0,"taxrate" =>0,
                                        "payments_id" =>paybill["id"],"persons_id_upd" => person["id"] ,"trngantts_id" => params["trngantts_id"],
                                        "last_duedate" => params["last_duedate"], "chrgs_id" => paybill["chrgs_id_payment"],
                                        "tblname" => params["srctblname"],"tblid" => params["srctblid"]}
                            when "mkbillschs"
                                paybillschs = {"amt_src" =>amt_src,"isudate"=>isudate,"duedate" =>duedate,"tax" =>0,"taxrate" =>0,
                                        "bills_id" =>paybill["id"],"persons_id_upd" => person["id"] ,"trngantts_id" => params["trngantts_id"],
                                        "last_duedate" => params["last_duedate"],"chrgs_id" => paybill["chrgs_id_bill"],
                                        "tblname" => params["srctblname"],"tblid" => params["srctblid"]}
                            end
                            create_paybillschs(paybillschs,paybill)

                        
                        when "mkschs"  ### XXXXschs,ordsの時prdschs,purschsを作成
                            parent = tbldata.dup
                            trnganttkey ||= 0  ###keyのカウンター
                            gantt = params["gantt"].dup
                            gantt_key = gantt["key"]
                            gantt["mlevel"] = gantt["mlevel"].to_i+1
                            gantt["paretblname"] = parent["tblname"] = tblname
                            gantt["paretblid"] = parent["tblid"] =  tblid
                            gantt["itms_id_pare"] = gantt["itms_id_trn"]
                            gantt["duedate_pare"] = gantt["duedate_trn"]
                            gantt["toduedate_pare"] = gantt["toduedate_trn"]
                            gantt["starttime_pare"] = gantt["starttime_trn"]
                            gantt["processseq_pare"] = gantt["processseq_trn"]
                            gantt["qty_sch_pare"] = parent["qty_sch"] 
                            gantt["shelfnos_id_pare"] = gantt["shelfnos_id_trn"]
                            gantt["shelfnos_id_to_pare"] = gantt["shelfnos_id_to_trn"]
                            gantt["qty_pare"] = gantt["qty"].to_f + gantt["qty_sch"].to_f 
                            parent["qty_handover"] =  gantt["qty_handover"]
                            parent["shelfnos_id_trn"] = gantt["shelfnos_id_trn"]
                            setParams["parent"] = parent.dup
                            ActiveRecord::Base.connection.select_all(ArelCtl.proc_nditmSql(tbldata["opeitms_id"])).each do |nd|
                                if nd["prdpur"]  ###opeitmdが登録されてないとprdords,purordsは作成されない。
                                    blk = RorBlkCtl::BlkClass.new("r_"+nd["prdpur"]+"schs")
                                    command_c = blk.command_init   ###  tblname=paretblname
                                    command_c,qty_require = add_update_prdpur_table_from_nditm  nd,parent,tblname,command_c
                                    command_c["id"] = ArelCtl.proc_get_nextval("#{nd["prdpur"]}schs_seq")
                                    command_c["#{nd["prdpur"]}sch_created_at"] = Time.now
                                    trnganttkey += 1
                                    gantt["key"] = gantt_key + format('%05d', trnganttkey)
                                    gantt["tblname"] = nd["prdpur"] + "schs"
                                    gantt["itms_id_trn"] = nd["itms_id"]
                                    gantt["processseq_trn"] = nd["processseq"]
                                    gantt["shelfnos_id_trn"] = nd["shelfnos_id_opeitm"]
                                    gantt["consumtype"] = (nd["consumtype"]||="CON")
                                    gantt["shelfnos_id_to_trn"] = nd["shelfnos_id_to_opeitm"]
                                    gantt["duedate_trn"] = command_c["#{gantt["tblname"].chop}_duedate"]
                                    gantt["toduedate_trn"] = command_c["#{gantt["tblname"].chop}_toduedate"]
                                    gantt["qty_require"] = qty_require
                                    gantt["qty_handover"] = (qty_require / nd["packqty"].to_f).ceil * nd["packqty"].to_f 
                                    gantt["chilnum"] = nd["chilnum"]
                                    gantt["parenum"] = nd["parenum"]
                                    gantt["qty_sch"] = command_c["#{gantt["tblname"].chop}_qty_sch"]
                                    gantt["starttime_trn"] =  command_c["#{gantt["tblname"].chop}_starttime"]
                                    ###作業場所の稼働日考慮要
                                    gantt["locas_id_trn"] = command_c["shelfno_loca_id_shelfno"]
                                    setParams["mkprdpurords_id"] = 0
                                    gantt["tblid"] = command_c["id"]
                                    gantt["consumunitqty"] =  nd["consumunitqty"] 
                                    gantt["consumminqty"]  = nd["consumminqty"]
                                    gantt["consumchgoverqty"] = nd["consumchgoverqty"]
                                    gantt["consumauto"] =  (nd["consumauto"]||="")
                                    command_c["#{gantt["tblname"].chop}_person_id_upd"] = gantt["persons_id_upd"] = setParams["person_id_upd"]
                                    setParams["child"] =  nd.dup
                                    setParams["gantt"] =  gantt.dup
                                    command_c = blk.proc_create_tbldata(command_c)
                                    setParams = blk.proc_private_aud_rec(setParams,command_c) ###create pur,prdschs
                                    if gantt["consumtype"] =~ /CON/  ###出庫 消費と金型・設備の使用
                                        Shipment.proc_create_consume(setParams) do   
                                            "conschs"
                                        end
                                    end
                                else  ###opeitmsに登録されてない時
                                    blk = RorBlkCtl::BlkClass.new("r_dymschs")
                                    command_c = blk.command_init
                                    nd["prdpur"] = "dym"
                                    nd["itms_id"] = nd["itms_id_nditm"]
                                    gantt["tblname"] = "dymschs"
                                    command_c,qty_require = add_update_prdpur_table_from_nditm  nd,parent,tblname,command_c
                                    command_c["dymsch_person_id_upd"] = setParams["person_id_upd"]
                                    command_c["dymsch_itm_id"] = nd["itms_id"]
                                    command_c["dymsch_loca_id"] = 0
                                    command_c["id"] = ArelCtl.proc_get_nextval("#{gantt["tblname"]}_seq")
                                    command_c["dymsch_created_at"] = Time.now
                                    trnganttkey += 1
                                    gantt["key"] = gantt_key + format('%05d', trnganttkey)
                                    gantt["tblid"] = command_c["id"]
                                    gantt["itms_id_trn"] = nd["itms_id_nditm"]
                                    gantt["processseq_trn"] = 999
                                    gantt["locas_id_trn"] = 0
                                    gantt["shelfnos_id_trn"] = 0
                                    gantt["locas_id_to_trn"] = 0
                                    gantt["consumtype"] = (nd["consumtype"]||="CON")
                                    gantt["shelfnos_id_to_trn"] = 0
                                    gantt["duedate_trn"] = command_c["dymsch_duedate"]
                                    gantt["toduedate_trn"] = command_c["#{gantt["tblname"].chop}_toduedate"]
                                    gantt["qty_require"] = qty_require
                                    gantt["qty_handover"] = qty_require  
                                    gantt["chilnum"] = nd["chilnum"]
                                    gantt["parenum"] = nd["parenum"]
                                    gantt["qty_sch"] = command_c["dymsch_qty_sch"]
                                    gantt["starttime_trn"] =  command_c["dymsch_starttime"]
                                    ###作業場所の稼働日考慮要
                                    setParams["mkprdpurords_id"] = 0
                                    setParams["gantt"] = gantt.dup
                                    setParams["child"] = nd.dup
                                    command_c["dymsch_person_id_upd"] = gantt["persons_id_upd"] = setParams["person_id_upd"]
                                    setParams["gantt"] = gantt.dup
                                    command_c = blk.proc_create_tbldata(command_c)
                                    setParams = blk.proc_private_aud_rec(setParams,command_c) ###create pur,prdschs
                                    if gantt["consumtype"] =~ /CON/  ###出庫 消費と金型・設備の使用
                                        Shipment.proc_create_consume(setParams) do   
                                            "conschs"
                                        end
                                    end
                                end
                            end                     
                        when "mkShpschConord"  ### prd,purordsの時shpschs,conordsを作成
                            ### purords,prdordsでshpordsを作成しないのは xxxinsts等でshpordsを作成したいため
                            parent = tbldata.dup
                            parent["duedate"] = parent["duedate"].to_time
                            parent["starttime"] = parent["starttime"].to_time
                            parent["tblname"] = gantt["tblname"]
                            parent["tblid"] = gantt["tblid"]
                            child = {}
                            ActiveRecord::Base.connection.select_all(ArelCtl.proc_pareChildTrnsSqlGroupByChildItem(parent)).each do |nd|
                                setParams["mkprdpurords_id"] = 0
                                child = nd.dup
                                if child["consumtype"] =~ /CON|MET/  ###出庫 消費と金型・設備の使用
                                    child["consumauto"] = (nd["consumauto"]||="")  ###子の保管場所からの出庫
                                    child["packno"] = ""
                                    child["lotno"] = ""   ### shpschs,shpordsの時はlotnoは""  
                                    setParams["parent"] = parent.dup
                                    setParams["child"] = child.dup
                                    if opeitm["shpordauto"] != "M"
                                        Shipment.proc_create_shpxxxs(setParams) do  ###prd,purordsによる自動作成 
                                            "shpsch"
                                        end
                                    end    
                                    if nd["consumtype"] =~ /CON/
                                        Shipment.proc_create_consume(setParams) do   
                                            "conords"
                                        end
                                    end
                                    if child["consumtype"] =~ /MET/ and child_opeitm["consumauto"] == "A"   ###使用後自動返却
                                         ###shpschs,shpordsでは瓶毎、リール毎に出庫してないので、瓶、リールの自動返却はない。
                                        parent["starttime"] = (parent["duedate"].to_time + 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###親の作業後元に戻す。
                                        setParams["child"] = child.dup
                                        setParams["parent"] = parent.dup
                                        Shipment.proc_create_shpxxxs(setParams)   do ###setParams 親のデータ
                                            "shpsch"
                                        end
                                    end
                                end
                            end    
                        when "mkprdpurchildFromCustxxxs"  ### custxxxsからpur,purschsに変更"custord_crr_id_custord"
                            gantt = params["gantt"].dup
                            gantt["mlevel"] = 1
                            gantt["key"] = "00000000"
                            gantt["qty_sch_pare"] = 0 
                            case gantt["orgtblname"] ###parent = orgtbl
                            when "custords"
                                qty =  gantt["qty"].to_f
                                ### free custschsへの引き当て
                                get_free_custschs_sql = %Q&
                                            --- free custschsへの引き当て
                                            select  t.id trngantts_id,link.qty_src,t.orgtblname tblname,t.orgtblid tblid,link.id link_id from trngantts t 
                                                            inner join linkcusts link on link.srctblid = t.tblid  and t.id = link.trngantts_id
                                                                                    and link.srctblname = link.tblname and link.srctblid = link.tblid
                                                                                    and link.srctblname = 'custschs' and link.qty_src > 0 
                                                            where t.orgtblname = 'custschs' and t.paretblname = 'custschs' and t.tblname = 'custschs'
                                                                    and t.orgtblid = t.paretblid and t.tblid = t.paretblid
                                                                    and t.prjnos_id = #{gantt["prjnos_id"]} 
                                                                    and itms_id_pare = #{gantt["itms_id_pare"]} and processseq_pare = #{gantt["processseq_pare"]}
                                                                    and link.srctblname = t.orgtblname 
                                                            order by t.duedate_org

                                &
                                ActiveRecord::Base.connection.select_all(get_free_custschs_sql).each do |sch|
                                    if qty >= sch["qty_src"].to_f
                                            qty_src = sch["qty_src"].to_f
                                            qty -= qty_src
                                            sch["qty_src"] = 0
                                    else
                                        qty_src = qty
                                        sch["qty_src"] = sch["qty_src"].to_f - qty
                                        qty = 0
                                    end
                                    src = {"trngantts_id" => sch["trngantts_id"],"tblname"=> sch["tblname"],"tblid"=> sch["tblid"]}
                                    base = {"tblname" => gantt["tblname"],"tblid" => gantt["tblid"],"qty_src" => qty_src,"amt_src" => 0,
                                            "persons_id_upd" => gantt["persons_id_upd"],    
                                            "remark" => "#{self} line:#{__LINE__}"}
                                    ArelCtl.proc_insert_linkcusts(src,base)
                                    update_sql = %Q&
                                            update linkcusts set qty_src = #{sch["qty_src"]},remark = '#{self} line:#{__LINE__}'||remark,
                                                    updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss')
                                                    where id = #{sch["link_id"]}
                                            &
                                    ActiveRecord::Base.connection.update(update_sql) ###引き当ったcustschsの減
                                end
                                gantt["qty_handover"] = tbldata["qty_handover"] =  gantt["qty_sch"] = qty
                                update_sql = %Q&
                                        update linkcusts set qty_src = #{qty},remark = '#{self} line:#{__LINE__}'||remark,
                                                updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss')
                                                where tblid = #{gantt["tblid"]} and srctblid = #{gantt["tblid"]}
                                        &
                                ActiveRecord::Base.connection.update(update_sql)  ###custords.linkcusts.qtyの減
                            when "custschs"
                                gantt["qty_handover"] = tbldata["qty_handover"] =  gantt["qty_sch"]
                            else
                                3.times{Rails.logger.debug" orgtblname:#{gantt["orgtblname"]} error "}
                                raise
                            end
                            qty_sch = gantt["qty_sch"]
                            gantt["qty"] = 0
                            gantt["qty_require"] = tbldata["qty_require"] = gantt["qty_handover"] 
                            child = {"itms_id_nditm" => gantt["itms_id_trn"],"processseq_nditm" => gantt["processseq_trn"] ,
                                    "opeitms_id"=> tbldata["opeitms_id"],
                                    "parenum" => 1,"chilnum" => 1,"qty_sch" => qty_sch, 
                                    "locas_id_shelfno" => opeitm["locas_id_shelfno"],"shelfnos_id" => opeitm["shelfnos_id_opeitm"], 
                                    "locas_id_shelfno_to" => opeitm["locas_id_shelfno_to"],"shelfnos_id_to" => opeitm["shelfnos_id_to_opeitm"],  
                                    "consumunitqty" => 1,"consumminqty" => 0,"consumchgoverqty" => 0}
                            child.merge!(setParams["opeitm"])
                            blk = RorBlkCtl::BlkClass.new("r_"+ setParams["opeitm"]["prdpur"]+"schs")
                            command_c = blk.command_init
                            command_c["#{setParams["opeitm"]["prdpur"]}sch_person_id_upd"] = setParams["person_id_upd"]
                            command_c,qty_require = add_update_prdpur_table_from_nditm  child,tbldata,paretblname,command_c
                            command_c["id"] = ArelCtl.proc_get_nextval("#{setParams["opeitm"]["prdpur"]}schs_seq")
                            command_c["#{setParams["opeitm"]["prdpur"]}sch_created_at"] = Time.now
                            command_c = blk.proc_create_tbldata(command_c)
                            setParams["gantt"] = gantt.dup
                            setParams = blk.proc_private_aud_rec(setParams,command_c) 
                    else  
                        result_f = '6'
                        remark = "  CreateOtherTableRecordJob line:#{__LINE__}  program nothing for #{setParams["segment"]} "  
                    end ## process   
                    strsql = %Q%update processreqs set result_f = '#{result_f}',remark = '#{remark}' where id = #{processreq["id"]}
                    %
                    ActiveRecord::Base.connection.update(strsql)
                    processreq = ActiveRecord::Base.connection.select_one(perform_strsql)
                    if processreq
                        params = JSON.parse(processreq["reqparams"])  
                    end
            end
        rescue
            ActiveRecord::Base.connection.rollback_db_transaction()
            ActiveRecord::Base.connection.begin_db_transaction()
            if processreq 
                strsql = %Q%update processreqs set result_f = '5'  where seqno = #{pid} and id < #{processreq["id"]}
                %
                ActiveRecord::Base.connection.update(strsql)
            end
            remark =  %Q% $@: #{$@[0..200]} :class #{self} : LINE #{__LINE__} $!: #{$!} %  ###evar not defined
            3.times{Rails.logger.debug"error rollback "}
            Rails.logger.debug"error class #{self} : #{Time.now}: #{$@} "
            Rails.logger.debug"error class #{self} : $!: #{$!} "
            Rails.logger.debug"error class #{self} : params: #{params} "
            if processreq
                strsql = %Q%update processreqs set result_f = '9'  where seqno = #{pid} and id = #{processreq["id"]}
                %
                ActiveRecord::Base.connection.update(strsql)

                strsql = %Q%update processreqs set result_f = '8'  where seqno = #{pid} and id > #{processreq["id"]}
                %
                ActiveRecord::Base.connection.update(strsql)
            end
            if params
                if params["mkprdpurords"]
                    strsql = %Q%update mkprdpurords set incnt = #{mkordparams[:incnt]},inqty = #{mkordparams[:inqty]},
                            inamt = #{mkordparams[:inamt]},outcnt = #{mkordparams[:outcnt]},
                            outqty = #{mkordparams[:outqty]},outamt = #{mkordparams[:outamt]} ,
                            message_code = '#{mkordparams[:message_code]}',remark = ' error ===>rollback'
                            where id = #{params["mkprdpurords_id"]}
                        %
                    ActiveRecord::Base.connection.update(strsql)
                end
                if params["mkbillinsts"]
                    strsql = %Q%update mkbillinsts set incnt = #{mkordparams[:incnt]},outcnt = #{mkordparams[:outcnt]},
                            inamt = #{mkordparams[:inamt]},outamt = #{mkordparams[:outamt]} ,
                            message_code = '#{mkordparams[:message_code]}',remark = ' error ===>rollback'
                            where id = #{params["mkbillinsts_id"]}
                        %
                    ActiveRecord::Base.connection.update(strsql)
                end
            end
            ActiveRecord::Base.connection.commit_db_transaction()
        else
            ActiveRecord::Base.connection.commit_db_transaction()
        end  
    end
 
	###schsの追加	paretblname =~ /schs$|ords$/の時呼ばれる 
	def add_update_prdpur_table_from_nditm  nd,parent,paretblname,command_init ### id processreqsのid child-->nditms  parent ===> r_prd,pur XXXs
            if paretblname =~ /ords/   ###ordsから _schを作成
                parent["qty_sch"] = parent["qty"]
                parent.delete("qty") 
                parent.delete("amt") 
            end
		    command_c,qty_require = CtlFields.proc_schs_fields_making(nd,parent,"r_"+ nd["prdpur"]+"schs",command_init)
		    return command_c,qty_require
    end

    def  create_paybillschs(sch,billpay)
        ###check billscks exists or not
        paybillsch = case sch["tblname"]
                        when "custords"
                            "billsch"
                        when "purords"
                            "paysch"
                        end 
        mst =  case paybillsch  
                when /^pay/ 
                     "payment"
                when /^bill/
                    "bill"
                end

        blk = RorBlkCtl::BlkClass.new("r_#{paybillsch}s")
		command_c = blk.command_init
        command_c["#{paybillsch}_person_id_upd"] = sch["persons_id_upd"]
        command_c["#{paybillsch}_duedate"] = sch["duedate"]
        command_c["#{paybillsch}_isudate"] = sch["isudate"]
        command_c["#{paybillsch}_expiredate"] = "2099/12/31"
        command_c["#{paybillsch}_chrg_id"] = billpay["chrgs_id_#{mst}"]
        command_c["#{paybillsch}_tax"] = command_c["#{paybillsch}_taxrate"] = 0 
        command_c["#{paybillsch}_updated_at"] = Time.now
        command_c["#{paybillsch}_#{mst}_id"] = sch["#{mst}s_id"]
        strsql = %Q&
                    select * from #{paybillsch}s where #{mst}s_id = #{sch["#{mst}s_id"]} 
                                            and to_char(duedate,'yyyy-mm-dd') = '#{sch["duedate"].strftime("%Y-%m-%d")}'
        &
        rec = ActiveRecord::Base.connection.select_one(strsql)
        if rec
		    command_c["sio_classname"] = %Q&_update_from_#{case mst
                                                        when "bill"
                                                            "custords"
                                                        when "payment"
                                                            "purords"
                                                        end } &
		    command_c["#{paybillsch}_remark"] = "auto update "
		    command_c["id"] = command_c["#{paybillsch}_id"] = rec["id"]
            strsql = %Q&
                        select * from linktbls where srctblname = 'custords' and srctblid = #{sch["tblid"]}  
                                and tblname = '#{paybillsch}s' and tblid = #{rec["id"]}
                    &
            link = ActiveRecord::Base.connection.select_one(strsql)
            if link 
                command_c["#{paybillsch}_amt_sch"] = rec["amt_sch"].to_f + (sch["amt_src"].to_f - sch["last_amt"].to_f )
                strsql = %Q&
                            update linktbls set amt_src = #{sch["amt_src"]} ,
                                updated_at = #{Time.now}
                                where id = #{link["id"]}
                &
                ActiveRecord::Base.connection.update(strsql)
            else
                command_c["#{paybillsch}_amt_sch"] = rec["amt_sch"].to_f + sch["amt_src"].to_f 
                base = {"tblname" => "#{paybillsch}s","tblid" => command_c["id"],"qty_src" => 0,"amt_src" => sch["amt_src"],
                         "persons_id_upd" => sch["persons_id_upd"]} 
                ArelCtl.proc_insert_linktbls(sch,base)
            end
        else
		    command_c["sio_classname"] = %Q&_add_from_#{case mst
                                                        when "bill"
                                                            'custords'
                                                        when "payment"
                                                            "purords"
                                                        end } &
		    command_c["#{paybillsch}_remark"] = "auto add "
		    command_c["id"] = command_c["#{paybillsch}_id"] = ArelCtl.proc_get_nextval("#{paybillsch}s_seq")
		    command_c["#{paybillsch}_created_at"] = Time.now
		    command_c["#{paybillsch}_amt_sch"] = sch["amt_src"]
            base = {"tblname" => "#{paybillsch}s","tblid" => command_c["id"],"qty_src" => 0,"amt_src" => sch["amt_src"],
                     "persons_id_upd" => sch["persons_id_upd"]} 
            ArelCtl.proc_insert_linktbls(sch,base)
        end
        strsql = %Q&
                    select * from r_chrgs where id = #{billpay["chrgs_id_#{mst}"]} 
        &
        chrg = ActiveRecord::Base.connection.select_one(strsql)
        command_c["chrg_person_id_chrg_#{mst}"] = chrg["chrg_person_id_chrg"] 
        command_c["person_sect_id_chrg_#{mst}"] =  chrg["person_sect_id_chrg"]
        command_c = blk.proc_create_tbldata(command_c) ##
        billParams = blk.proc_private_aud_rec({},command_c)

        ###old_custords check
        if sch["last_duedate"]
            strsql = %Q&
                        select b.*,l.id linktbl_id from #{paybillsch}s b
                            inner join linktbls l on b.id = l.tblid
                            where srctblname = '#{case mst
                                                    when "bill"
                                                        'custords'
                                                    when "payment"
                                                        'purords'
                                                    end}' 
                                    and srctblid = #{sch["tblid"]}
                                    and tblname = '#{paybillsch}s' and tblid != #{command_c["id"]}
            &
            last_rec = ActiveRecord::Base.connection.select_one(strsql)
            if last_rec
                strsql = %Q&
                            update #{paybillsch}s set amt_sch = amt_sch + (#{sch["amt_src"].to_f - sch["last_amt"].to_f}),
                                updated_at = #{Time.now}
                                where id = #{last_rec["id"]}
                &
                ActiveRecord::Base.connection.update(strsql)
                strsql = %Q&
                            update linktbls set amt_src = #{sch["amt_src"].to_f} ,
                                updated_at = #{Time.now}
                                where id = #{last_rec["linktbl_id"]}
                &
                ActiveRecord::Base.connection.update(strsql)
            end
        end
    end        
end