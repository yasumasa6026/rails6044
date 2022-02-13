class CreateOtherTableRecordJob < ApplicationJob
    queue_as :default 
    def perform(pid)
        # 後で実行したい作業をここに書く
        begin
            ActiveRecord::Base.connection.begin_db_transaction()
            perform_strsql = "select * from  processreqs t 
                            where t.result_f = '0'  and t.seqno = #{pid} 
                            and not exists(select 1 from processreqs c where t.seqno = c.seqno and t.id > c.id
                                        and c.result_f != '1')
                            order by t.id limit 1 for update"
            processreq = ActiveRecord::Base.connection.select_one(perform_strsql)
            strsql = %Q% select email from persons where id = #{params["tbldata"]["persons_id_upd"]}
                    %
            rec = ActiveRecord::Base.connection.select_one(strsql) ###
            $email = rec["email"]
            $person_code_chrg = rec["code"]
            until processreq.nil? do
                    params = JSON.parse(processreq["reqparams"])
                    setParams = params.dup
                    gantt = params["gantt"]
                    tblname = gantt["tblname"]
                    tblid = gantt["tblid"]
                    paretblname = gantt["paretblname"]
                    paretblid = gantt["paretblid"]
                    tbldata = params["tbldata"]
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
                    remark = " "
                    case params["segment"]
                        when "skip" 
                        when "trngantts" ###prd,pur,cust xxxschs,xxxordsのとき
                            Operation.proc_trngantts(params)  ###xxxschs,xxxords
                        when "add_update_lotstkhists" ###prd,pur,cust xxxinsts,xxxreplyxxx,xxxdlvs,xxxacts,xxxxretsのとき
                            Operation.proc_add_update_lotstkhists(params)  
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
                            mkord = tbldata.dup
                            mkordparams[:incnt] = mkord["incnt"].to_f
                            mkordparams[:inqty] = mkord["inqty"].to_f
                            mkordparams[:inamt] = mkord["inamt"].to_f
                            mkordparams[:outcnt] = mkord["outcnt"].to_f
                            mkordparams[:outqty] = mkord["outqty"].to_f
                            mkordparams[:outamt] = mkord["outamt"].to_f
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
                    
                        
                        when "mkschs"  ### XXXXschs,ordsの時XXXschsを作成
                            parent = tbldata.dup
                            trnganttkey ||= 0  ###keyのカウンター
                            gantt = params["gantt"].dup
                            gantt_key = gantt["key"]
                            gantt["mlevel"] = gantt["mlevel"].to_i+1
                            gantt["paretblname"] = tblname
                            gantt["paretblid"] = tblid
                            gantt["itms_id_pare"] = gantt["itms_id_trn"]
                            gantt["duedate_pare"] = gantt["duedate_trn"]
                            gantt["shelfnos_id_to_pare"] = gantt["shelfnos_id_to"]
                            gantt["processseq_pare"] = gantt["processseq_trn"]
                            gantt["locas_id_pare"] = gantt["locas_id_trn"]
                            gantt["qty_stk_pare"] = gantt["qty_stk"] 
                            gantt["qty_pare"] = gantt["qty"] + gantt["qty_sch"] 
                            parent["qty_handover"] =  gantt["qty_handover"]
                            strsql = %Q%
                                        select ope.itms_id,ope.processseq,itm.consumtype,
                                                nditm.parenum,nditm.chilnum, ope.locas_id_fm,
                                                nditm.consumunitqty,nditm.consumminqty,nditm.consumchgoverqty,
                                                ope.id,ope.prdpur,ope.packno_proc,ope.locas_id_opeitm,ope.duration,
                                                ope.packqty,ope.shelfnos_id_to_opeitm,ope.shelfnos_id_fm_opeitm,ope.locas_id_opeitm
                                        from nditms nditm 
                                        inner join itms itm on itm.id = nditm.itms_id_nditm 
                                        inner join (select o.*,s.locas_id_shelfno locas_id_fm from opeitms o inner join shelfnos s
                                                on o.shelfnos_id_to_opeitm = s.id) ope ---完成後の移動場所から親の場所に
                                        on  ope.itms_id = nditm.itms_id_nditm  and ope.processseq = nditm.processseq_nditm
                                        where nditm.expiredate > current_date and nditm.opeitms_id = #{tbldata["opeitms_id"]}
                                        and ope.priority = 999
                                    %  
                            ActiveRecord::Base.connection.select_all(strsql).each do |nd|
                                child = {"itms_id_nditm" => nd["itms_id"] ,"processseq_nditm" => nd["processseq"] ,
                                    "parenum" =>nd["parenum"],"chilnum" => nd["chilnum"],"locas_id_fm" => nd["locas_id_fm"],  
                                    "consumunitqty" =>nd["consumunitqty"],"consumminqty" => nd["consumminqty"],
                                    "consumchgoverqty" => nd["consumchgoverqty"],"consumtype" => nd["consumtype"]}
                                child_opeitm = {"id" => nd["id"],"prdpur" => nd["prdpur"], "packno_proc" => nd["packno_proc"],
                                    "locas_id_opeitm" => nd["locas_id_opeitm"],"duration" => nd["duration"],"packqty" => nd["packqty"],
                                    "itms_id" => nd["itms_id"] ,"processseq" => nd["processseq"] ,
                                    "shelfnos_id_to_opeitm" => nd["shelfnos_id_to_opeitm"],"shelfnos_id_fm_opeitm" =>nd["shelfnos_id_fm_opeitm"]}
                                blk = RorBlkCtl::BlkClass.new("r_"+child_opeitm["prdpur"]+"schs")
                                command_c,qty_require = add_update_prdpur_table_from_nditm  child,parent,tblname,child_opeitm,blk.command_init
                                blk.proc_create_src_tbl(command_c)
                                trnganttkey += 1
                                gantt["key"] = gantt_key + format('%05d', trnganttkey)
                                gantt["tblname"] = nd["prdpur"] + "schs"
                                gantt["tblid"] = command_c["id"]
                                gantt["itms_id_trn"] = nd["itms_id"]
                                gantt["processseq_trn"] = nd["processseq"]
                                gantt["locas_id_trn"] = nd["locas_id_opeitm"]
                                gantt["duedate_trn"] = command_c["#{gantt["tblname"].chop}_duedate"]
                                gantt["qty_require"] = qty_require
                                gantt["chilnum"] = nd["chilnum"]
                                gantt["parenum"] = nd["parenum"]
                                setParams["gantt"] = gantt.dup
                                setParams["opeitm"] = child_opeitm.dup
                                setParams["mkprdpurords_id"] = 0
                                blk.proc_private_aud_rec(setPparams,command_c) ###create pur,prdschs
                                if child["consumtype"] =~ /CON|MET/  ###出庫
                                        if tblname =~ /^prd/
                                            child["locas_id_to"] = tbldata["loas_id_wrokplace"]
                                            child["shelfnos_id_to"] = tbldata["shelfnos_id_fm"]
                                        else     
                                            child["locas_id_to"] = tbldata["loas_id_suppier"]
                                            child["shelfnos_id_to"] = tbldata["shelfnos_id_fm"]
                                        end
                                        if tblname =~ /schs$/
                                            shptblname = "shpschs"
                                            contblname = "conschs"

                                        else    
                                            shptblname = "shpords"
                                            contblname = "conords"
                                        end
                                        child["packno"] = if (child_opeitm["packno_proc"]||="0") != "0" then "packno" else "" end
                                        child["lotno"] = ""   ### shpschs,shpordsの時はlotnoは""  
                                        Shipment.proc_create_shp(setParams) do   
                                            shptblname
                                        end
                                        if child["consumtype"] =~ /CON/   ###消費
                                            Shipment.proc_create_consume(setParams) do   
                                                contblname
                                            end
                                        end
                                        if child["consumtype"] =~ /MET/ and child_opeitm["consumauto"] == "A"   ###使用後自動返却
                                            ###shpschs,shpordsでは瓶毎、リール毎に出庫してないので、瓶、リールの自動返却はない。
                                            tbldata["starttime"] = tbldata["duedate"] + 3  ###親の作業後2日後元に戻す。
                                            child["shelfnos_id_to"] = child["shelfnos_id_fm"] 
                                            if tblname =~ /^prd/
                                                child["locas_id_fm"] = tbldata["loas_id_wrokplace"]
                                                child["shelfnos_id_fm"] = tbldata["shelfnos_id_fm"]
                                            else     
                                                child["locas_id_fm"] = tbldata["loas_id_suppier"]
                                                child["shelfnos_id_fm"] = tbldata["shelfnos_id_fm"]
                                            end
                                            Shipment.proc_create_shp(setParams) do   ###setParams 親のデータ
                                                shptblname
                                            end
                                        end
                                end
                            end
                        
                        when "mkprdpurchild"  ### custxxxsからpur,purschsに変更"custord_crr_id_custord"
                            gantt = params["gantt"].dup
                            gantt["key"] = "00001"
                            gantt["itms_id_pare"] = gantt["itms_id_trn"]
                            gantt["processseq_pare"] = gantt["processseq_trn"]
                            gantt["shelfnos_id_to_pare"] = gantt["shelfnos_id_to"]
                            gantt["locas_id_pare"] = gantt["locas_id_trn"] 
                            gantt["qty_stk_pare"] = 0 
                            case gantt["orgtblname"] ###parent = orgtbl
                            when "custords"
                                gantt["qty_handover"] =  tbldata["qty_handover"] =  gantt["qty"]
                            when "custschs"
                                gantt["qty_handover"] = tbldata["qty_handover"] =  gantt["qty_sch"]
                            else
                                Rails.logger.debug" orgtblname:#{gantt["orgtblname"]} error "                                
                                Rails.logger.debug" orgtblname:#{gantt["orgtblname"]} error "
                                raise
                            end
                            gantt["qty_require"] = tbldata["qty_require"] = gantt["qty_handover"] 
                            child = {"itms_id_nditm" => gantt["itms_id_trn"],"processseq_nditm" => gantt["processseq_trn"] ,
                                    "parenum" => 1,"chilnum" => 1,"locas_id_fm" => 0,  ###親が子部品をどこから持ってくるかなので今回は不要
                                    "consumunitqty" => 1,"consumminqty" => 0,"consumchgoverqty" => 0}
                            blk = RorBlkCtl::BlkClass.new("r_"+ setParams["opeitm"]["prdpur"]+"schs")
                            command_c,qty_require = add_update_prdpur_table_from_nditm  child,tbldata,paretblname,setParams["opeitm"],blk.command_init
                            blk.proc_create_src_tbl(command_c)
                            setParams["child"] = child.dup
                            setParams["gantt"] = gantt.dup
                            setParams = bkl.proc_private_aud_recset(setParams,command_c) 

                    else  
                        result_f = '6'
                        remark = "  CreateOtherTableRecordJob line:#{__LINE__}  program nothing for #{setParams["segment"]} "  
                    end ## process   
                    strsql = %Q%update processreqs set result_f = '#{result_f}',remark = '#{remark}' where id = #{processreq["id"]}
                    %
                    ActiveRecord::Base.connection.update(strsql)
                    processreq = ActiveRecord::Base.connection.select_one(perform_strsql)
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
            Rails.logger.debug"error rollback "
            Rails.logger.debug"error rollback "
            Rails.logger.debug"error rollback "
            Rails.logger.debug"error class #{self} : #{Time.now}: #{$@} "
            Rails.logger.debug"error class #{self} : $!: #{$!} "
            Rails.logger.debug"error class #{self} : setParams: #{setParams} "
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
	def add_update_prdpur_table_from_nditm  child,parent,paretblname,opeitm,command_init ### id processreqsのid child-->nditms  parent ===> r_prd,pur XXXs
        if paretblname =~ /ords/   ###ordsから _schを作成
            parent.delete("qty") 
            parent.delete("amt") 
        end
		command_c,qty_require = ControlFields.proc_fields_update(parent,"r_"+ opeitm["prdpur"]+"schs",command_init) do |command,para|
			command["id"] = ""
			command["opeitm_loca_id_opeitm"] = opeitm["locas_id_opeitm"]
			para["opeitms_id"] = opeitm["id"]
			para["duration"] =  opeitm["duration"].to_f
			para["packqty"] =  if opeitm["packqty"].to_f == 0
                                    1
                                else
                                    opeitm["packqty"].to_f
                                end
			para["shelfnos_id_to"] = opeitm["shelfnos_id_to_opeitm"]
			para["shelfnos_id_fm"] = opeitm["shelfnos_id_fm_opeitm"]
			para["locas_id"] = opeitm["locas_id_opeitm"]  ###発注の時の作業場所
			para["parenum"] = child["parenum"].to_f
			para["chilnum"] = child["chilnum"].to_f
			para["locas_id_fm"] = child["locas_id_fm"]
			para["consumunitqty"] = child["consumunitqty"].to_f
			para["consumminqty"] = child["consumminqty"].to_f
            para["consumchgoverqty"] = child["consumchgoverqty"].to_f
		end
		return command_c,qty_require
    end
        
    def  custxxx_strsql tbldata
        strsql = %Q%select id from r_opeitms where itm_code = 'dummyship' and opeitm_processseq = 999
            %
        val  = ActiveRecord::Base.connection.select_value(strsql)
        if val.nil? ###nditmは自動作成
            p " missing item 'dummyship' please entry"
            p " missing item 'dummyship' please entry"
            p " missing item 'dummyship' please entry"
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