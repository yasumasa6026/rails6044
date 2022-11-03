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
            rec = ActiveRecord::Base.connection.select_one(strsql) ###
            $email = rec["email"]
            $person_code_chrg = rec["code"]
            $person_id_upd = rec["id"]
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
                            opeClass = Operation::OpeClass.new(params)  ###xxxschs,xxxords
                            opeClass.proc_link_lotstkhists_update()  
                        when "sumrequest" 
                        when "splitrequest"  

                        when "createtable"
                            parent.select do |key,val|  
                                if key.to_s =~ /_autocreate/
                                    fmtbl_totbls = JSON.parse(val)  ###table suppliers等の項目autocreateに次に作成されるテーブルが登録されている。
                                    fmtbl_totbls.each do |totbl,fmtbl|   ### {totbl => fmtbl}
                                        if fmtbl == tblname
                                            ArelCtl.proc_createtable(fmtbl,totbl,parent,params["classname"])
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

                        when "consume_exception"
                            ###出庫の前の完成,完成時の員数可変による消費数対応

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
                            gantt["qty_stk_pare"] = gantt["qty_stk"] 
                            gantt["locas_id_pare"] = gantt["locas_id_trn"]
                            gantt["shelfnos_id_pare"] = gantt["shelfnos_id_trn"]
                            gantt["shelfnos_id_to_pare"] = gantt["shelfnos_id_to_trn"]
                            gantt["qty_stk_pare"] = gantt["qty_stk"] 
                            gantt["qty_pare"] = gantt["qty"].to_f + gantt["qty_sch"].to_f 
                            parent["qty_handover"] =  gantt["qty_handover"]
                            parent["shelfnos_id_trn"] = gantt["shelfnos_id_trn"]
                            setParams["parent"] = parent.dup
                            ActiveRecord::Base.connection.select_all(ArelCtl.proc_nditmSql(tbldata["opeitms_id"])).each do |nd|
                                child = nd.dup
                                blk = RorBlkCtl::BlkClass.new("r_"+nd["prdpur"]+"schs")
                                command_c = blk.command_init
                                command_c,qty_require = add_update_prdpur_table_from_nditm  nd,parent,tblname,command_c
                                blk.proc_create_tbldata(command_c)
                                trnganttkey += 1
                                gantt["key"] = gantt_key + format('%05d', trnganttkey)
                                gantt["tblname"] = nd["prdpur"] + "schs"
                                gantt["tblid"] = command_c["id"]
                                gantt["itms_id_trn"] = nd["itms_id"]
                                gantt["processseq_trn"] = nd["processseq"]
                                gantt["locas_id_trn"] = nd["locas_id_opeitm"]
                                gantt["shelfnos_id_trn"] = nd["shelfnos_id_opeitm"]
                                gantt["locas_id_to_trn"] = nd["locas_id_to_opeitm"]
                                gantt["consumtype"] = child["consumtype"] = (nd["consumtype"]||="CON")
                                gantt["shelfnos_id_to_trn"] = nd["shelfnos_id_to_opeitm"]
                                gantt["duedate_trn"] = command_c["#{gantt["tblname"].chop}_duedate"]
                                gantt["toduedate_trn"] = command_c["#{gantt["tblname"].chop}_toduedate"]
                                gantt["qty_require"] = qty_require
                                gantt["qty_handover"] = (qty_require / nd["packqty"].to_f).ceil * nd["packqty"].to_f 
                                gantt["chilnum"] = child["chilnum"] = nd["chilnum"]
                                gantt["parenum"] = child["parenum"] = nd["parenum"]
                                gantt["qty_sch"] = child["qty_sch"] = command_c["#{gantt["tblname"].chop}_qty_sch"]
                                gantt["starttime_trn"] =  command_c["#{gantt["tblname"].chop}_starttime"]
                                ###作業場所の稼働日考慮要
                                gantt["locas_id_trn"] = command_c["shelfno_loca_id_shelfno"]
                                setParams["mkprdpurords_id"] = 0
                                setParams["gantt"] = gantt.dup
                                child["tblid"] = command_c["id"]
                                child["consumunitqty"] = nd["consumunitqty"] 
                                child["consumminqty"]  = nd["consumminqty"]
                                child["consumchgoverqty"] = nd["consumchgoverqty"]
                                child["consumchgoverqty"] = (nd["consumauto"]||="")
                                setParams["child"] = child.dup
                                setParams = blk.proc_private_aud_rec(setParams,command_c) ###create pur,prdschs
                                if gantt["consumtype"] =~ /CON/  ###出庫 消費と金型・設備の使用
                                    Shipment.proc_create_consume(setParams) do   
                                        "conschs"
                                    end
                                end
                            end                     
                        when "mkShpschConord"  ### prd,purordsの時shpschs,conordsを作成
                            ### purords,prdordsでshpordsを作成しないのは xxxinsts等でshpordsを作成したいため
                            parent = tbldata.dup
                            parent["tblname"] = gantt["tblname"]
                            parent["tblid"] = gantt["tblid"]

                            child = {}
                            ActiveRecord::Base.connection.select_all(ArelCtl.proc_trnganttSql(parent)).each do |nd|
                                setParams["mkprdpurords_id"] = 0
                                child = nd.dup
                                if child["consumtype"] =~ /CON|MET/  ###出庫 消費と金型・設備の使用
                                    child["consumauto"] = (nd["consumauto"]||="")  ###子の保管場所からの出庫
                                    child["packno"] = ""
                                    child["lotno"] = ""   ### shpschs,shpordsの時はlotnoは""  
                                    setParams["parent"] = parent.dup
                                    setParams["child"] = child.dup
                                    if opeitm["shpordauto"] != "M"
                                        Shipment.proc_create_shpschs_delete_shpords(setParams) do  ###prd,purordsによる自動作成 
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
                                        Shipment.proc_create_shpschs_delete_shpords(setParams)   do ###setParams 親のデータ
                                            "shpsch"
                                        end
                                    end
                                end
                            end    
                        when "mkprdpurchildFromCustxxxs"  ### custxxxsからpur,purschsに変更"custord_crr_id_custord"
                            gantt = params["gantt"].dup
                            gantt["mlevel"] = 1
                            gantt["key"] = "00000000"
                            gantt["qty_stk_pare"] = 0 
                            case gantt["orgtblname"] ###parent = orgtbl
                            when "custords"
                                strsql = %Q&select qty_linkto_alloctbl from alloctbls 
                                                    where srctblname = 'custords' and srctblid = #{gantt["tblid"]}
                                                    and trngantts_id = #{gantt["trngantts_id"]} &
                                qty_sch = ActiveRecord::Base.connection.select_value(strsql).to_f
                                gantt["qty_handover"] =  tbldata["qty_handover"] =  gantt["qty"] = qty_sch
                                gantt["qty_sch"] = gantt["qty"]
                                gantt["qty"] = 0
                            when "custschs"
                                gantt["qty_handover"] = tbldata["qty_handover"] =  gantt["qty_sch"]
                                qty_sch = gantt["qty_sch"]
                                gantt["qty"] = 0
                            else
                                3.times{Rails.logger.debug" orgtblname:#{gantt["orgtblname"]} error "}
                                raise
                            end
                            gantt["qty_require"] = tbldata["qty_require"] = gantt["qty_handover"] 
                            child = {"itms_id_nditm" => gantt["itms_id_trn"],"processseq_nditm" => gantt["processseq_trn"] ,
                                    "opeitms_id"=> tbldata["opeitms_id"],
                                    "parenum" => 1,"chilnum" => 1,"qty_sch" => qty_sch, 
                                    "locas_id_opeitm" => opeitm["locas_id_opeitm"],"shelfnos_id" => opeitm["shelfnos_id_opeitm"], 
                                    "locas_id_to_opeitm" => opeitm["locas_id_to_opeitm"],"shelfnos_id_to" => opeitm["shelfnos_id_to_opeitm"],  
                                    "consumunitqty" => 1,"consumminqty" => 0,"consumchgoverqty" => 0}
                            child.merge!(setParams["opeitm"])
                            blk = RorBlkCtl::BlkClass.new("r_"+ setParams["opeitm"]["prdpur"]+"schs")
                            command_c = blk.command_init
                            command_c,qty_require = add_update_prdpur_table_from_nditm  child,tbldata,paretblname,command_c
                            blk.proc_create_tbldata(command_c)
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
        command_init["id"] = ""
		command_c,qty_require = CtlFields.proc_schs_fields_making(nd,parent,"r_"+ nd["prdpur"]+"schs",command_init)
		return command_c,qty_require
    end
        
    def  custxxx_strsql tbldata
        strsql = %Q%select id from r_opeitms where itm_code = 'dummyship' and opeitm_processseq = 999
            %
        val  = ActiveRecord::Base.connection.select_value(strsql)
        if val.nil? ###nditmは自動作成
            Rails.logger.debug" missing item 'dummyship' please entry"
            Rails.logger.debug" missing item 'dummyship' please entry"
            Rails.logger.debug" missing item 'dummyship' please entry"
            raise
        end    ###opeitms itm_code : dummyship
        strsql = %Q&select itms_id,processseq from opeitms where id = #{tbldata["opeitms_id"]}
        &
        opeitm  = ActiveRecord::Base.connection.select_one(strsql)
        strsql = %Q%select * from nditms where expiredate > current_date and 
                opeitms_id = #{val} and itms_id_nditm = #{opeitm["itms_id"]} 
                and processseq_nditm = #{opeitm["processseq"]} limit 1
        %
        return strsql
    end
end