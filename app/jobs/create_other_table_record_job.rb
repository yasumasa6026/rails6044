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
            return if processreq.nil?            
            params = JSON.parse(processreq["reqparams"])   
            strsql = %Q% select * from persons where id = #{params["person_id_upd"]}
                    %
            person = ActiveRecord::Base.connection.select_one(strsql) ###
            params["email"] = person["email"]
            params["person_code_chrg"] = person["code"]
            ###params["person_id_upd"] = person["id"]
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
                            # ###parent：在庫移送を発生させたprd,pur
                          add_update_lotstkhists(params["last_lotstks"],params["person_id_upd"])
                        when "sumrequest" 
                        when "splitrequest"  

                        when "createtable"
                            # parent.select do |key,val|  
                            #     if key.to_s =~ /_autocreate/
                            #         fmtbl_totbls = JSON.parse(val)  ###table suppliers等の項目autocreateに次に作成されるテーブルが登録されている。
                            #         fmtbl_totbls.each do |totbl,fmtbl|   ### {totbl => fmtbl}
                            #             if fmtbl == tblname
                            #                 ArelCtl.proc_createtable(fmtbl,totbl,parent,params)
                            #             end
                            #         end
                            #     end
                            # end    

                        when "mkprdpurords"  ###  xxxschsからxxxordsを作成。
                            ### 　parent 未使用
                            mkordparams = {}
                            mkordparams[:incnt] = 0
                            mkordparams[:inqty] = 0
                            mkordparams[:inamt] = 0
                            mkordparams[:outcnt] = 0
                            mkordparams[:outqty] = 0
                            mkordparams[:outamt] = 0
                            mkordparams,last_lotstks = MkordinstLib.proc_mkprdpurords params,mkordparams
                            mkordparams[:message_code] = ""
                            mkordparams[:remark] = "  #{self} line:#{__LINE__} "
                            strsql = %Q%update mkprdpurords set incnt = #{mkordparams[:incnt]},inqty = #{mkordparams[:inqty]},
                                                inamt = #{mkordparams[:inamt]},outcnt = #{mkordparams[:outcnt]},
                                                outqty = #{mkordparams[:outqty]},outamt = #{mkordparams[:outamt]} ,
                                                message_code = '#{mkordparams[:message_code]}',remark = ' #{mkordparams[:remark]} '
                                                where id = #{params["mkprdpurords_id"]}
                                %
                            ActiveRecord::Base.connection.update(strsql)
                            if !last_lotstks.empty?
                              params["last_lotstks"] = last_lotstks
                              opeLotStk = Operation::OpeClass.new(params)  ###xxxschs,xxxords
                              opeLotStk.proc_link_lotstkhists_update()
                            end
                        when "mkpayords"
                            ### 　parent 未使用
                            if params["last_amt"] and (params["last_amt"].to_f != params["amt"].to_f or params["last_tax"].to_f != params["tax"].to_f )
                                delete_payords(params)
                                next if params["tbldata"]["amt"].to_f == 0 
                            end
                            ###ArelCtl.proc_createtable は使用しない
                            ###bill_loca_id_bill_cust
                            amt_src = 0
                            isudate = Time.now
                            duedate = Time.now
                            denomination = ""
                            strsql = %Q%select b.* from payments b
                                            inner join suppliers c on c.payments_id_supplier = b.id   
                                            where c.id = #{params["suppliers_id"]}
                                    %
                            payment = ActiveRecord::Base.connection.select_one(strsql)
                            src = {"tblname" => params["srctblname"],"tblid" => params["srctblid"]}
                            case payment["period"]
                            when "-30" ###前月を対象
                                isudate = tbldata["rcptdate"].to_date.since(1.month)  ###params["duedate"]受入日
                                newdd = payment["termof"].split(",")[0]  ###翌月一回のみ
                                isudate = (isudate.strftime("%Y") + "-" +isudate.strftime("%m") + "-" + newdd).to_date
                                JSON.parse(payment["ratejson"]).each do |rate|
                                    rate.each do |k,val|
                                        case k
                                        when "rate"
                                            amt_src = params["amt_src"].to_f * val.to_i / 100 
                                        when "duration"
                                            duedate =  isudate.since(val.to_i.day)  ###支払日
                                        when "denomination"
                                            denomination =  val
                                        end
                                    end      
                                    payord = {"amt_src" =>amt_src,"isudate"=>isudate,"duedate" =>duedate,
                                                "last_amt" => params["last_amt"],"crrs_id" => tbldata["crrs_id"],
                                                "tax" => tbldata["tax"],"taxrate" =>tbldata["taxrate"],"denomination" => denomination,
                                                "payments_id" =>payment["id"],"persons_id_upd" => person["id"] ,"trngantts_id" => params["trngantts_id"],
                                                "last_duedate" => params["last_duedate"], "chrgs_id" => payment["chrgs_id_payment"],
                                                "tblname" => params["srctblname"],"tblid" => params["srctblid"]}
                                    create_payords(src,payord,payment)
                                end
                            when /-1|0/
                                isudate = tbldata["rcptdate"].to_date.since(payment["period"].to_i*-1.day)###
                                payment["termof"].split(",").each do |newdd|
                                   if duedate < (isudate.strftime("%Y") + "-" +isudate.strftime("%m") + "-" + newdd).to_date
                                       if isudate > (isudate.strftime("%Y") + "-" +isudate.strftime("%m") + "-" + newdd).to_date
                                            isudate = (isudate.strftime("%Y") + "-" +isudate.strftime("%m") + "-" + newdd).to_date
                                       end
                                    end
                                end
                                JSON.parse(payment["ratejson"]).each do |rate|
                                    rate.each do |k,val|
                                        case k
                                        when "rate"
                                            amt_src = params["amt_src"].to_f * val.to_i / 100 
                                        when "duration"
                                            duedate =  isudate.since(val.to_i.day)  ###支払日
                                        when "denomination"
                                            denomination =  val
                                        end
                                    end
                                end      
                                payord = {"amt_src" =>amt_src,"isudate"=>isudate,"duedate" =>duedate,
                                            "amt_src" => params["amt_src"],"last_amt" => params["last_amt"],"denomination" => denomination,
                                            "tax" => tbldata["tax"],"taxrate" => tbldata["taxrate"],"crrs_id" => tbldata["crrs_id"],
                                            "payments_id" =>payment["id"],"persons_id_upd" => person["id"] ,"trngantts_id" => params["trngantts_id"],
                                            "last_duedate" => params["last_duedate"], "chrgs_id" => payment["chrgs_id_payment"],
                                            "tblname" => params["srctblname"],"tblid" => params["srctblid"]}
                                create_payords(src,payord,payment)
                            end 

                        # when "mkpayinsts"
                        #     mkpayinstparams = {}
                        #     mkpayinst = tbldata.dup
                        #     mkpayinstparams[:incnt] = 0
                        #     mkpayinstparams[:inamt] = 0
                        #     mkpayinstparams[:outcnt] = 0
                        #     mkpayinstparams[:outamt] = 0
                        #     mkpayinstparams = MkordinstLib.proc_mkpayinsts params,mkpayinstparams
                        #     mkpayinstparams[:message_code] = ""
                        #     mkpayinstparams[:remark] = " #{self} line:#{__LINE__} "
                        #     strsql = %Q%update mkpayinsts set incnt = #{mkpayinstparams[:incnt]},
                        #                         inamt = #{mkpayinstparams[:inamt]},outcnt = #{mkpayinstparams[:outcnt]},
                        #                         outamt = #{mkpayinstparams[:outamt]} ,
                        #                         message_code = '#{mkordparams[:message_code]}',remark = ' #{mkpatinstparams[:remark]} '
                        #                         where id = #{params["mkpayinsts_id"]}
                        #         %
                        #     ActiveRecord::Base.connection.update(strsql)
                        when "mkbillinsts"
                            ### 　parent 未使用
                            mkbillinstparams = {}
                            mkbillinst = tbldata.dup
                            mkbillinstparams[:incnt] = 0
                            mkbillinstparams[:inamt] = 0
                            mkbillinstparams[:outcnt] = 0
                            mkbillinstparams[:outamt] = 0
                            mkbillinstparams = MkordinstLib.proc_mkbillinsts params,mkbillinstparams
                            mkbillinstparams[:message_code] = ""
                            mkbillinstparams[:remark] = " #{self} line:#{__LINE__} "
                            strsql = %Q%update mkbillinsts set incnt = #{mkbillinstparams[:incnt]},
                                                inamt = #{mkbillinstparams[:inamt]},outcnt = #{mkbillinstparams[:outcnt]},
                                                outamt = #{mkbillinstparams[:outamt]} ,
                                                message_code = '#{mkordparams[:message_code]}',remark = ' #{mkbillinstparams[:remark]} '
                                                where id = #{params["mkbillinsts_id"]}
                                %
                            ActiveRecord::Base.connection.update(strsql)

                        when /mkpayschs|mkbillschs|mkbillests|updatepayschs/
                            ### 　parent 未使用
                            if params["segment"] == "updatepayschs"
                                delete_paybillschs(params["segment"],params)
                            end
                            ###payestsは作成されない。在庫に引き当っていることがある為。
                            ###ArelCtl.proc_createtable は使用しない
                            ###bill_loca_id_bill_cust
                            amt_src = 0
                            isudate = Time.now
                            duedate = Time.now
                            src = {"tblname" => params["srctblname"],"tblid" => params["srctblid"],"trngantts_id" => 0}
                            case params["segment"]
                            when "mkpayschs","updatepayschs"
                                strsql = %Q%select b.*,c.id suppliers_id from payments b
                                            inner join suppliers c on c.payments_id_supplier = b.id   
                                            where c.id = #{params["suppliers_id"]}
                                    %
                            when "mkbillschs","mkbillests"
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
                                JSON.parse(paybill["ratejson"]).each do |rate|   ###例：[{rate:60,duration:30,payment:deposit},{rate:40,duration:60,payment:"draf"t}]
                                    rate.each do |k,val|
                                        case k
                                        when "rate"
                                            amt_src = params["amt_src"].to_f * val.to_i / 100 
                                        when "duration"
                                            duedate =  isudate.since(val.to_i.day)  ###支払日
                                        end
                                    end   
                                    case params["segment"]
                                    when "mkpayschs","updatepayschs"           
                                        paybillschs = {"amt_src" =>amt_src,"isudate"=>isudate,"duedate" =>duedate,"tax" =>0,"taxrate" =>0,
                                                "payments_id" => paybill["id"],"suppliers_id" => paybill["suppliers_id"],
                                                "persons_id_upd" => person["id"] ,"trngantts_id" => params["trngantts_id"],
                                                "last_duedate" => params["last_duedate"], "chrgs_id" => paybill["chrgs_id_payment"],
                                                "tblname" => params["srctblname"],"tblid" => params["srctblid"]}
                                    when "mkbillschs","mkbillests"
                                        paybillschs = {"amt_src" =>amt_src,"isudate"=>isudate,"duedate" =>duedate,
                                                "tax" =>0,"taxrate" =>0,
                                                "bills_id" =>paybill["id"],"persons_id_upd" => person["id"] ,"trngantts_id" => params["trngantts_id"],
                                                "last_duedate" => params["last_duedate"],"chrgs_id" => paybill["chrgs_id_bill"],
                                                "tblname" => params["srctblname"],"tblid" => params["srctblid"]}
                                    end
                                    create_paybillschs(src,paybillschs,paybill)        
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
                                    case params["segment"]
                                    when "mkpayschs","updatepayschs"           
                                        paybillschs = {"amt_src" =>amt_src,"isudate"=>isudate,"duedate" =>duedate,
                                                "tax" =>0,"taxrate" =>0,
                                                "payments_id" =>paybill["id"],"suppliers_id" => paybill["suppliers_id"],
                                                "persons_id_upd" => person["id"] ,"trngantts_id" => params["trngantts_id"],
                                                "last_duedate" => params["last_duedate"], "chrgs_id" => paybill["chrgs_id_payment"],
                                                "tblname" => params["srctblname"],"tblid" => params["srctblid"]}
                                    when "mkbillschs","mkbillests"
                                        paybillschs = {"amt_src" =>amt_src,"isudate"=>isudate,"duedate" =>duedate,"tax" =>0,"taxrate" =>0,
                                                "bills_id" => paybill["id"],
                                                "persons_id_upd" => person["id"] ,"trngantts_id" => params["trngantts_id"],
                                                "last_duedate" => params["last_duedate"],"chrgs_id" => paybill["chrgs_id_bill"],
                                                "tblname" => params["srctblname"],"tblid" => params["srctblid"]}
                                    end
                                    create_paybillschs(src,paybillschs,paybill)
                                end
                            else
                                3.times{Rails.logger.debug" error class:#{self} , line:#{__LINE__} ,paybillschs:#{paybillschs}" }
                                3.times{Rails.logger.debug" error period not support class:#{self} , line:#{__LINE__} " }
                                raise
                            end 
                        when /mkbillords/
                            ###ArelCtl.proc_createtable は使用しない
                            ###bill_loca_id_bill_cust
                            ### 　parent 未使用
                            amt_src = 0
                            isudate = Time.now
                            duedate = Time.
                            src = {"tblname" => params["srctblname"],"tblid" => params["srctblid"],"trngantts_id" => 0}
                            strsql = %Q%select b.* from bills b   
                                            where b.id = #{tbldata["bills_id"]}
                                    %
                            billmst = ActiveRecord::Base.connection.select_one(strsql)
                            case billmst["period"]
                            when "-30" ###前月を対象
                                isudate = tbldata["duedate"].to_date.since(1.month)  ###params["duedate"]受入日
                                newdd = billmst["termof"].split(",")[0]  ###翌月一回のみ
                                isudate = (isudate.strftime("%Y") + "-" +isudate.strftime("%m") + "-" + newdd).to_date
                                JSON.parse(billmst["ratejson"]).each do |rate|
                                    rate.each do |k,val|
                                        case k
                                        when "rate"
                                            amt_src = tbldata["amt"].to_f * val.to_i / 100 
                                        when "duration"
                                            duedate =  isudate.since(val.to_i.day)  ###支払日
                                        when "denomination"
                                            denomination =  val
                                        end
                                    end
                                    billords = {"amt_src" =>amt_src,"isudate"=>isudate,"duedate" =>duedate,"tax" =>tbldata["tax"],"taxrate" => tbldata["taxrate"],
                                                "bills_id" =>billmst["id"],"persons_id_upd" => person["id"] ,"trngantts_id" => params["trngantts_id"],
                                                "last_duedate" => tbldata["last_duedate"],"chrgs_id" => billmst["chrgs_id_bill"],"denomination" => denomination,
                                                "tblname" => params["srctblname"],"tblid" => params["srctblid"]}
                                    create_billords(src,billords,billmst)        
                                end
                            when /-1|0/
                                isudate = tbldata["duedate"].to_date.since(paybill["period"].to_i*-1.day)###params["duedate"]受入日
                                billmst["termof"].split(",").each do |newdd|
                                   if duedate < (isudate.strftime("%Y") + "-" +isudate.strftime("%m") + "-" + newdd).to_date
                                       if isudate > (isudate.strftime("%Y") + "-" +isudate.strftime("%m") + "-" + newdd).to_date
                                            isudate = (isudate.strftime("%Y") + "-" +isudate.strftime("%m") + "-" + newdd).to_date
                                       end
                                    end
                                end
                                JSON.parse(billmst["ratejson"]).each do |rate|
                                    rate.each do |k,val|
                                        case k
                                        when "rate"
                                            amt_src = tbldata["amt"].to_f * val.to_i / 100 
                                        when "duration"
                                            duedate =  isudate.since(val.to_i.day)  ###支払日
                                        when "denomination"
                                            denomination =  val
                                        end
                                    end   
                                    billords = {"amt_src" =>amt_src,"isudate"=>isudate,"duedate" =>duedate,
                                            "tax" => tbldata["tax"],"taxrate" => tbldata["taxrate"],
                                            "bills_id" =>billmst["id"],"persons_id_upd" => person["id"] ,"trngantts_id" => params["trngantts_id"],
                                            "last_duedate" => tbldata["last_duedate"],"chrgs_id" => billmst["chrgs_id_bill"],"denomination" => denomination,
                                            "tblname" => params["srctblname"],"tblid" => params["srctblid"]}
                                    create_billords(src,billords,billmst)
                                end
                            else
                                3.times{Rails.logger.debug" error class:#{self} , line:#{__LINE__} ,paybillschs:#{paybillschs}" }
                                3.times{Rails.logger.debug" error period not support class:#{self} , line:#{__LINE__} " }
                                raise
                            end 
                        
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
                            gantt["qty_sch_pare"] = gantt["qty_sch"] 
                            gantt["shelfnos_id_pare"] = gantt["shelfnos_id_trn"]
                            gantt["shelfnos_id_to_pare"] = gantt["shelfnos_id_to_trn"]
                            gantt["qty_pare"] = gantt["qty"].to_f  
                            parent["qty_handover"] =  gantt["qty_handover"]
                            parent["shelfnos_id_trn"] = gantt["shelfnos_id_trn"]
                            parent["trngantts_id"] = gantt["trngantts_id"]   ### shpxxxs,conxxxsのtrngantts_idは親のtrngantts_id
                            setParams["parent"] = parent.dup
                            ActiveRecord::Base.connection.select_all(ArelCtl.proc_nditmSql(tbldata["opeitms_id"])).each do |nd|
                                trnganttkey += 1
                                gantt["key"] = gantt_key + format('%05d', trnganttkey)
                                case nd["prdpur"]  ###opeitmdが登録されてないとprdords,purordsは作成されない。
                                when "prd","pur"
                                    blk = RorBlkCtl::BlkClass.new("r_"+nd["prdpur"]+"schs")
                                    command_c = blk.command_init   ###  tblname=paretblname
                                    command_c,qty_require,err = add_update_prdpur_table_from_nditm(nd,parent,tblname,command_c)  ###tblname = paretblname
                                    command_c["#{nd["prdpur"]}sch_created_at"] = Time.now
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
                                    if gantt["consumtype"] == "CON"  ###出庫 消費と金型・設備の使用
                                        Shipment.proc_create_consume(setParams) do   
                                            "conschs"
                                        end
                                    end
                                else  ###
                                    nd["opeitms_id"] = 0
                                    nd["shelfnos_id_opeitm"] = 0
                                    nd["shelfnos_id_opeitm"] = 0
                                    nd["locas_id_shelfno_to"] = 0
                                    nd["locas_id_shelfno"] = 0
                                    case nd["classlist_code"]
                                    when "apparatus"  ###装置
                                        blk = RorBlkCtl::BlkClass.new("r_dvsschs")
                                        command_c = blk.command_init
                                        nd["prdpur"] = "dvs"
                                        gantt["tblname"] = "dvsschs"
                                        blk = RorBlkCtl::BlkClass.new("r_dvsschs")
                                        command_c = blk.command_init
                                        command_c,qty_require,err = add_update_prdpur_table_from_nditm(nd,parent,tblname,command_c)  ###tblname = paretblname
                                        next if err
                                        gantt["duedate_trn"] = command_c["#{gantt["tblname"].chop}_duedate"]
                                        gantt["qty_require"] = 1
                                        gantt["qty_handover"] = 0
                                        gantt["qty_sch"] = 1 
                                        gantt["consumtype"] = (nd["consumtype"]||="apparatus")
                                        command_c["dvssch_prdsch_id_dvssch"] = parent["tblid"]
                                        command_c["dvssch_person_id_upd"] = gantt["persons_id_upd"] = setParams["person_id_upd"]
                                        command_c["dvssch_created_at"] = Time.now
                                        setParams["mkprdpurords_id"] = 0
                                        setParams["gantt"] = gantt.dup
                                        setParams["child"] = nd.dup
                                        setParams["gantt"] = gantt.dup
                                        command_c = blk.proc_create_tbldata(command_c)
                                        setParams = blk.proc_private_aud_rec(setParams,command_c) ###
                                        ###
                                        # 人のリソース
                                        ###
                                        proc_mk_ercschs(nd,setParams,"ercschs")
                                        ###
                                    when "mold","ITool"       ###金型 ###工具
                                        setParams["mkprdpurords_id"] = 0
                                        gantt["consumtype"] = (nd["consumtype"]||="mold")
                                        setParams["gantt"] = gantt.dup
                                        setParams["child"] = nd.dup
                                        setParams["gantt"] = gantt.dup
                                        setParams["child"]["units_id_case_shp"] = nd["units_id"]
                                        strsql = %Q&
                                                    select l.shelfnos_id from lotstkhists l 
                                                                inner join shelfnos s on s.id = l.shelfnos_id
                                                                where l.itms_id = #{nd["itms_id"]}  and s.code = '#{nd["classlist_code"]}'
                                                                order by l.starttime desc
                                            &
                                        shelfnos_id = ActiveRecord::Base.connection.select_value(strsql)
                                        setParams["child"]["shelfnos_id_to"] = (shelfnos_id ||= "0")
                                        Shipment.proc_create_shpxxxs(setParams) do  ###
                                            "shpest"
                                        end
                                    when "installationCharge"   ###設置
                                        next
                                    else
                                        blk = RorBlkCtl::BlkClass.new("r_dymschs")
                                        command_c = blk.command_init
                                        nd["prdpur"] = "dym"
                                        gantt["tblname"] = 'dymschs'
                                        nd["locas_id_shelfno"] = 0 
                                        nd["locas_id_shelfno_to"] = 0
                                        command_c,qty_require = add_update_prdpur_table_from_nditm(nd,parent,tblname,command_c)  ###tblname -->paretblname
                                        command_c["dymsch_itm_id_dym"] = nd["itms_id"]
                                        command_c["dymsch_shelfno_id"] = 0
                                        command_c["dymsch_shelfno_id_to"] = 0
                                        gantt["duedate_trn"] = command_c["#{gantt["tblname"].chop}_duedate"]
                                        gantt["locas_id_trn"] = 0
                                        gantt["shelfnos_id_trn"] = 0
                                        gantt["qty_require"] = qty_require
                                        gantt["qty_handover"] = qty_require  
                                        gantt["processseq_trn"] = command_c["#{gantt["tblname"].chop}_processseq"] = 999
                                        gantt["toduedate_trn"] = command_c["#{gantt["tblname"].chop}_toduedate"]
                                        gantt["qty_sch"] = command_c["#{gantt["tblname"].chop}_qty_sch"]
                                        command_c["#{gantt["tblname"].chop}_person_id_upd"] = gantt["persons_id_upd"] = setParams["person_id_upd"]
                                        command_c["#{gantt["tblname"].chop}_created_at"] = Time.now
                                        gantt["starttime_trn"] =  command_c["#{gantt["tblname"].chop}_starttime"]
                                        trnganttkey += 1
                                        gantt["key"] = gantt_key + format('%05d', trnganttkey)
                                        gantt["tblid"] = command_c["id"]
                                        gantt["itms_id_trn"] = nd["itms_id"]
                                        gantt["locas_id_to_trn"] = 0
                                        gantt["consumtype"] = (nd["consumtype"]||="CON")
                                        gantt["shelfnos_id_to_trn"] = 0
                                        gantt["chilnum"] = nd["chilnum"]
                                        gantt["parenum"] = nd["parenum"]
                                        ###作業場所の稼働日考慮要
                                        setParams["mkprdpurords_id"] = 0
                                        setParams["gantt"] = gantt.dup
                                        setParams["child"] = nd.dup
                                        setParams["gantt"] = gantt.dup
                                        command_c = blk.proc_create_tbldata(command_c)
                                        setParams = blk.proc_private_aud_rec(setParams,command_c) ###create pur,prdschs
                                        if gantt["consumtype"] == "CON"  ###出庫 消費と金型・設備の使用
                                            Shipment.proc_create_consume(setParams) do   
                                                "conschs"
                                            end
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
                            parent["trngantts_id"] = gantt["trngantts_id"]  ### shpxxxs,conxxxsのtrngantts_idは親のtrngantts_id
                            child = {}
                            ActiveRecord::Base.connection.select_all(ArelCtl.proc_pareChildTrnsSqlGroupByChildItem(parent)).each do |nd|
                                setParams["mkprdpurords_id"] = 0
                                child = nd.dup
                                case child["consumtype"]
                                when "CON"  ###出庫 消費 
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
                                    Shipment.proc_create_consume(setParams) do   
                                        "conords"
                                    end
                                when "mold","ITool"  ###出庫 金型・工具の使用
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
                                when "BYP"   ###副産物
                                    ###
                                else
                                    next
                                end
                            end    
                        when "mkprdpurchildFromCustxxxs"  ### custxxxsからpur,purschsに変更"custord_crr_id_custord" 
                            ###　parent 未使用
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
                                        select  t.id trngantts_id,link.qty_src,t.orgtblname tblname,t.orgtblid tblid,link.id link_id,link.srctblid from trngantts t 
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
                                ###  custschsに引き当ててもcustschs.qty_schは減しない
                                    # custsch_blk = RorBlkCtl::BlkClass.new("r_custschs")
                                    # command_c = custsch_blk.command_init
                                    # rec = ActiveRecord::Base.connection.select_one(%Q&  select * from r_custschs where id = #{sch["srctblid"]}  &)
                                    # command_c = command_c.merge(rec)
                                    # command_c["sio_classname"] = %Q&_update_from_custschs &
                                    # command_c["id"] = command_c["custsch_id"] = sch["tblid"]
                                    if qty >= sch["qty_src"].to_f
                                            qty_src = sch["qty_src"].to_f
                                            qty -= qty_src
                                            sch["qty_src"] = 0
                                    else
                                        qty_src = qty
                                        sch["qty_src"] = sch["qty_src"].to_f - qty
                                        qty = 0
                                    end
                                    update_sql = %Q&  --- free custschs 減
                                            update linkcusts set qty_src = #{sch["qty_src"]},remark = '#{self} line:#{__LINE__}'||remark,
                                                    updated_at = current_timestamp
                                                    where id = #{sch["link_id"]}
                                            &
                                    ActiveRecord::Base.connection.update(update_sql) ###引き当ったcustschsの減gantt = setParams["gantt"].dup
                                    # command_c["custsch_qty_sch"] = sch["qty_src"].to_f
                                    # command_c = custsch_blk.proc_create_tbldata(command_c)
                                    # setParams = custsch_blk.proc_private_aud_rec(setParams,command_c)
                                    src = {"tblname" => "custschs","tblid" => sch["srctblid"],"trngantts_id" => sch["trngantts_id"]}
                                    base = {"tblname" => "custords","tblid" => gantt["orgtblid"],"qty_src" => qty_src,"amt_src" => 0,"persons_id_upd" => setParams["person_id_upd"]}
                                    ArelCtl.proc_insert_linkcusts(src,base)  ###
                                end
                                gantt["qty_handover"] = tbldata["qty_handover"] =  gantt["qty_sch"] = qty
                                update_sql = %Q&  --- custords free 引当後
                                        update linkcusts set qty_src = #{qty},remark = ' #{self} line:#{__LINE__} '||remark,
                                                updated_at = current_timestamp
                                                where tblid = #{gantt["tblid"]} and srctblid = #{gantt["tblid"]} and trngantts_id = #{gantt["trngantts_id"]}
                                                and tblname = 'custords' and srctblname = 'custords'
                                        &
                                ActiveRecord::Base.connection.update(update_sql)  ###custords.linkcusts.qtyの減
                            when "custschs"
                                gantt["qty_handover"] = tbldata["qty_handover"] =  gantt["qty_sch"]
                            else
                                3.times{Rails.logger.debug" orgtblname:#{gantt["orgtblname"]} error "}
                                raise
                            end
                            ###
                            #
                            ###
                            qty_sch = gantt["qty_sch"]
                            gantt["qty"] = 0
                            gantt["qty_require"] = tbldata["qty_require"] = gantt["qty_handover"] 
                            child = {"itms_id_nditm" => gantt["itms_id_trn"],"processseq_nditm" => gantt["processseq_trn"] ,
                                    "opeitms_id"=> tbldata["opeitms_id"],
                                    "parenum" => 1,"chilnum" => 1,"qty_sch" => qty_sch, 
                                    "locas_id_shelfno" => opeitm["locas_id_shelfno"],"shelfnos_id_opeitm" => opeitm["shelfnos_id_opeitm"], 
                                    "locas_id_shelfno_to" => opeitm["locas_id_shelfno_to"],"shelfnos_id_to" => opeitm["shelfnos_id_to_opeitm"],  
                                    "consumunitqty" => 1,"consumminqty" => 0,"consumchgoverqty" => 0}
                            child.merge!(setParams["opeitm"])
                            blk = RorBlkCtl::BlkClass.new("r_"+ setParams["opeitm"]["prdpur"]+"schs")
                            command_c = blk.command_init
                            Rails.logger.debug"debugg class #{self},line:#{__LINE__} . command_c: #{command_c} "
                            command_c["#{setParams["opeitm"]["prdpur"]}sch_person_id_upd"] = setParams["person_id_upd"]
                            command_c["#{setParams["opeitm"]["prdpur"]}sch_duedate"] = tbldata["starttime"].to_time.strftime("%Y-%m-%d") + " 16:00:00"
                            command_c,qty_require = add_update_prdpur_table_from_nditm(child,tbldata,paretblname,command_c)  ###tbldata--->parent
                            command_c["#{setParams["opeitm"]["prdpur"]}sch_created_at"] = Time.now
                            command_c = blk.proc_create_tbldata(command_c)
                            setParams["gantt"] = gantt.dup
                            setParams = blk.proc_private_aud_rec(setParams,command_c)   
                            result_f = '1'
                            setParams["segment"]  = "link_lotstkhists_update"   ###
                            setParams["tbldata"] = {}
                            setParams["gantt"] = {}
                            processreqs_id,setParams = ArelCtl.proc_processreqs_add(setParams)
                    else  
                        result_f = '6'
                        remark = "    #{self} line:#{__LINE__}  program nothing for #{setParams["segment"]} "  
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
	def add_update_prdpur_table_from_nditm(nd,parent,paretblname,command_init) ### id processreqsのid child-->nditms  parent ===> r_prd,pur XXXs
            parent["qty_sch"] = parent["qty_sch"].to_f + parent["qty"].to_f 
            if paretblname =~ /ords/   ###ordsから _schを作成
                parent.delete("qty") 
                parent.delete("amt") 
            end
		    command_c,qty_require,err = CtlFields.proc_schs_fields_making(nd,parent,"r_"+ nd["prdpur"]+"schs",command_init)
		    return command_c,qty_require,err
  end

  def create_paybillschs(src,sch,billpay)
        ###check billscks exists or not
        case sch["tblname"]
        when "custords"
            paybillsch =  "billsch"
            blk = RorBlkCtl::BlkClass.new("r_billschs")
            command_c = blk.command_init
            command_c["billsch_accounttitle"] = "A"  ### 売上
            mst = "bill"
            str_amt = "amt_sch"
        when "custschs"
            paybillsch =  "billest"
            blk = RorBlkCtl::BlkClass.new("r_billests")
            command_c = blk.command_init
            command_c["billest_accounttitle"] = "A"  ### 売上
            mst = "bill"
            str_amt = "amt_est"
        when "purords"
            paybillsch = "paysch"
            blk = RorBlkCtl::BlkClass.new("r_payschs")
            command_c = blk.command_init
            command_c["paysch_accounttitle"] = "1"  ### 仕入
            mst = "payment"
            str_amt = "amt_sch"
        end 

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
                                            and accounttitle = '#{case mst 
                                                                when "payment"  
                                                                    '1'
                                                                when "bill"
                                                                    'A'
                                                                end}'
        &
        rec = ActiveRecord::Base.connection.select_one(strsql)
        if rec
		    command_c["sio_classname"] = %Q&_update_from_#{paybillsch}s &
		    command_c["#{paybillsch}_remark"] = "auto update "
		    command_c["id"] = command_c["#{paybillsch}_id"] = rec["id"]
            strsql = %Q&
                        select * from srctbllinks where srctblname = '#{sch["tblname"]}' and srctblid = #{sch["tblid"]}  
                                and tblname = '#{paybillsch}s' and tblid = #{rec["id"]}
                    &
            link = ActiveRecord::Base.connection.select_one(strsql)
            if link 
                command_c["#{paybillsch}_#{str_amt}"] = rec[str_amt].to_f + (sch[str_amt].to_f - sch[str_amt].to_f )
                strsql = %Q&
                            update srctbllinks set amt_src = #{sch["amt_src"]} ,
                                updated_at = current_timestamp
                                where id = #{link["id"]}
                &
                ActiveRecord::Base.connection.update(strsql)
            else
                command_c["#{paybillsch}_#{str_amt}"] = rec["amt_sch"].to_f + sch["amt_src"].to_f 
                base = {"tblname" => "#{paybillsch}s","tblid" => command_c["id"],"amt_src" => sch["amt_src"],
                         "persons_id_upd" => sch["persons_id_upd"]} 
                ArelCtl.proc_insert_srctbllinks(sch,base)
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
		    command_c["#{paybillsch}_created_at"] = Time.now  ###proc_field_sno(tblnamechop,isudate,id)
		    command_c["#{paybillsch}_sno"] = CtlFields.proc_field_sno(paybillsch,sch["isudate"],command_c["id"]) 
		    command_c["#{paybillsch}_#{str_amt}"] = sch["amt_src"] 
            base = {"tblname" => "#{paybillsch}s","tblid" => command_c["id"],"qty_src" => 0,"amt_src" => sch["amt_src"],
                     "persons_id_upd" => sch["persons_id_upd"]} 
            ArelCtl.proc_insert_srctbllinks(src,base)
        end
        strsql = %Q&
                    select * from r_chrgs where id = #{billpay["chrgs_id_#{mst}"]} 
        &
        chrg = ActiveRecord::Base.connection.select_one(strsql)
        command_c["chrg_person_id_chrg_#{mst}"] = chrg["chrg_person_id_chrg"] 
        command_c["person_sect_id_chrg_#{mst}"] =  chrg["person_sect_id_chrg"]
        command_c = blk.proc_create_tbldata(command_c) ##
        billParams = blk.proc_private_aud_rec({},command_c)
  end

    

  def delete_paybillschs(segment,params)
        ###check billscks exists or not
        case segment
        when "updatebillords"
            # blk = RorBlkCtl::BlkClass.new("r_billords")
            # command_c = blk.command_init
            # command_c["billord_accounttitle"] = "A"  ### 売上
            paybillsch = "billord"
            mst = "bill"
            str_amt = "amt"
        when "updatebillschs"
            # blk = RorBlkCtl::BlkClass.new("r_billschs")
            # command_c = blk.command_init
            # command_c["billsch_accounttitle"] = "A"  ### 売上
            paybillsch = "billsch"
            mst = "bill"
            str_amt = "amt_sch"
        when "updatebillests"
            # blk = RorBlkCtl::BlkClass.new("r_billests")
            # command_c = blk.command_init
            # command_c["billest_accounttitle"] = "A"  ### 売上
            mst = "bill"
            paybillsch = "billest"
            str_amt = "amt_est"
        when "updatepayschs"
            # blk = RorBlkCtl::BlkClass.new("r_payschs")
            # command_c = blk.command_init
            # command_c["paysch_accounttitle"] = "1"  ### 仕入
            mst = "payment"
            paybillsch = "paysch"
            str_amt = "amt_sch"
        when "updatepayords"
            # blk = RorBlkCtl::BlkClass.new("r_payords")
            # command_c = blk.command_init
            # command_c["payord_accounttitle"] = "1"  ### 仕入
            mst = "payment"
            paybillsch = "payord"
            str_amt = "amt"
        end 

        strsql = %Q& --- payxxxsとpurxxxs、billxxxsとcustxxxsの関係
                    select * from srctbllinks where srctblname = '#{params["srctblname"]}' and srctblid = #{params["srctblid"]} 
                &
        link =  ActiveRecord::Base.connection.select_one(strsql)

        update_sql = %Q&
                    update srctbllinks set amt_src = amt_src - #{params["last_amt"]} where id = #{link["id"]}
        &

        ActiveRecord::Base.connection.update(update_sql)
  end

  def  create_payords(src,payord,payment)  ###src:puracts puracts_id
        blk = RorBlkCtl::BlkClass.new("r_payords")
        command_c = blk.command_init
        command_c["payord_person_id_upd"] = payord["persons_id_upd"]
        command_c["payord_duedate"] = payord["duedate"]
        command_c["payord_isudate"] = payord["isudate"]
        command_c["payord_expiredate"] = "2099/12/31"
        command_c["payord_chrg_id"] = payord["chrgs_id"]
        command_c["payord_tax"] = payord["tax"] 
        command_c["payord_taxrate"] = payord["taxrate"] 
        command_c["payord_updated_at"] = Time.now
        command_c["payord_crr_id"] = payord["crrs_id"]
        command_c["payord_payment_id"] = payment["id"]
        command_c["payord_accounttitle"] = "1"  ###仕入
        command_c["payord_amt"] = payord["amt_src"]
        command_c["payord_denomination"] = payord["denomination"]
        strsql = %Q&  ---支払額計算
                        select * from payords where payments_id = #{payment["id"]} 
                                                and to_char(duedate,'yyyy-mm-dd') = '#{payord["duedate"].strftime("%Y-%m-%d")}'
                                                and denomination = '#{payord["denomination"]}'
            &
        chk_payord = ActiveRecord::Base.connection.select_one(strsql)
        if chk_payord
            strsql = %Q&  --- 支払済み？
                        select * from srctbllinks a where a.srctblname = 'payords' and a.srctblid = #{chk_payord["id"]} ---  
                                    and a.tblname = 'payacts' and a.amt_src > 0  ---入金済は除く
                        &
            payact = ActiveRecord::Base.connection.select_one(strsql)
            if payact
                command_c["sio_classname"] = "_add_from_puracts"
                command_c["payord_remark"] = "auto add "
                command_c["id"] = command_c["payord_id"] = ArelCtl.proc_get_nextval("payords_seq")
                command_c["payord_created_at"] = Time.now
                command_c["payord_sno"] = CtlFields.proc_field_sno("payord",payord["isudate"],command_c["id"])
                base = {"tblname" => "payords","tblid" => command_c["id"],"amt_src" => payord["amt_src"],
                        "persons_id_upd" => payord["persons_id_upd"]} 
                ArelCtl.proc_insert_srctbllinks(src,base)
                command_c["payord_remark"] = "auto add other payords "
            else
                command_c["sio_classname"] = "_update_from_puracts "
                command_c["payord_remark"] = "auto update "
                command_c["id"] = command_c["payord_id"] = chk_payord["id"]
                strsql = %Q&
                                update srctbllinks set amt_src = amt_src + #{payord["amt_src"]} ,
                                    updated_at = current_timestamp
                                    where srctblname = 'puracts' and srctblid = #{src["tblid"]} 
                                    and tblname = 'payords' and tblid = #{chk_payord["id"]} 
                                &
                ActiveRecord::Base.connection.update(strsql)
            end
        else
            command_c["sio_classname"] = "_add_from_puracts"
            command_c["payord_remark"] = "auto add "
            command_c["id"] = command_c["payord_id"] = ArelCtl.proc_get_nextval("payords_seq")
            command_c["payord_created_at"] = Time.now
            command_c["payord_amt"] = payord["amt_src"]
            command_c["payord_sno"] = CtlFields.proc_field_sno("payord",payord["isudate"],command_c["id"])
            base = {"tblname" => "payords","tblid" => command_c["id"],"amt_src" => payord["amt_src"],
                    "persons_id_upd" => payord["persons_id_upd"]} 
            ArelCtl.proc_insert_srctbllinks(src,base)
        end
        strsql = %Q&
                        select * from r_chrgs where id = #{payment["chrgs_id_payment"]} 
            &
        chrg = ActiveRecord::Base.connection.select_one(strsql)
        command_c["chrg_person_id_chrg_payment"] = chrg["chrg_person_id_chrg"] 
        command_c["person_sect_id_chrg_payment"] =  chrg["person_sect_id_chrg"]
        command_c = blk.proc_create_tbldata(command_c) ##
        blk.proc_private_aud_rec({},command_c)
    
        notords = [src]
        new_notords = []
        until notords == [] do
            notords.each do |notord|
                ords,new_notords = getprdpurord_from_linktbls(notord["tblname"],notord["tblid"],"pur")  ###ords-->acts
                ords.each do |ord|
                    updatepaybillschs(ord["srctblid"],"pay",payord["amt_src"])
                end
            end
            notords = new_notords.dup
        end
    end

    
    def delete_payords(params)
        strsql = %Q&
                         select * from  srctbllinks 
                                 where tblname = 'payords' 
                                 and srctblname = 'puracts' and tblid = #{params["tbldata"]["id"]}
                 &
        last_amt = params["last_amt"].to_f
        ActiveRecord::Base.connection.select_all(strsql).each do |rec|
            if last_amt > rec["amt_src"].to_f
                update_sql = %Q&
                        update srctbllinks set amt_src = #{rec["amt_src"]}
                                where #{rec["id"]}
                    &
                ActiveRecord::Base.connection.update(update_sql)
                update_sql = %Q&
                         update payords set amt = #{rec["amt_src"]}
                                 where id = #{rec["tblid"]}
                 &
                ActiveRecord::Base.connection.update(update_sql)
                last_amt -=  rec["amt_src"].to_f
            else
                last_amt -=  rec["amt_src"].to_f
            end
        end
  end

    
  def  create_billords(src,billord,billmst)
        blk = RorBlkCtl::BlkClass.new("r_billords")
        command_c = blk.command_init
        command_c["billord_person_id_upd"] = billord["persons_id_upd"]
        command_c["billord_duedate"] = billord["duedate"]
        command_c["billord_isudate"] = billord["isudate"]
        command_c["billord_expiredate"] = "2099/12/31"
        command_c["billord_chrg_id"] = billord["chrgs_id"]
        command_c["billord_tax"] = billord["tax"] 
        command_c["billord_taxrate"] = billord["taxrate"] 
        command_c["billord_updated_at"] = Time.now
        command_c["billord_bill_id"] = billmst["id"]
        command_c["billord_denomination"] = billord["denomination"]
        strsql = %Q&
                        select * from billords where bills_id = #{billmst["id"]} 
                                                and to_char(duedate,'yyyy-mm-dd') = '#{billord["duedate"].strftime("%Y-%m-%d")}'
                                                and denomination = '#{billord["denomination"]}'
            &
        chk_billord = ActiveRecord::Base.connection.select_one(strsql)
        if chk_billord
            command_c["sio_classname"] = "_update_from_custacts "
            command_c["custord_remark"] = "auto update "
            command_c["id"] = command_c["billord_id"] = chk_billord["id"]
            strsql = %Q&
                            select * from srctbllinks where srctblname = 'custacts' and srctblid = #{custord["tblid"]} ---tblid = puracts.id  
                                    and tblname = 'custords' and tblid = #{chk_custord["id"]}
                        &
            link = ActiveRecord::Base.connection.select_one(strsql)
            if link 
                link["amt_src"] = link["amt_src"].to_f + (billord["amt_src"].to_f - billord["last_amt"].to_f )
                 strsql = %Q&
                                update srctbllinks set amt_src = #{link["amt_src"]} ,
                                    updated_at = #{Time.now}
                                    where id = #{link["id"]}
                    &
                    ActiveRecord::Base.connection.update(strsql)
            else
                command_c["billord_amt"] = chk_billord["amt"].to_f + billord["amt_src"].to_f 
                base = {"tblname" => "billords","tblid" => command_c["id"],"qty_src" => 0,"amt_src" => billord["amt_src"],
                             "persons_id_upd" => billord["persons_id_upd"]} 
                    ArelCtl.proc_insert_srctbllinks(src,base)
            end
        else
            command_c["sio_classname"] = "_add_from_custacts"
            command_c["billord_remark"] = "auto add "
            command_c["id"] = command_c["billord_id"] = ArelCtl.proc_get_nextval("billords_seq")
            command_c["billord_created_at"] = Time.now
            command_c["billord_amt"] = billord["amt_src"]
            base = {"tblname" => "billords","tblid" => command_c["id"],"amt_src" => billord["amt_src"],
                    "persons_id_upd" => billord["persons_id_upd"]} 
            ArelCtl.proc_insert_srctbllinks(src,base)
        end
        strsql = %Q&
                        select * from r_chrgs where id = #{billmst["chrgs_id_bill"]} 
            &
        chrg = ActiveRecord::Base.connection.select_one(strsql)
        command_c["chrg_person_id_chrg_bill"] = chrg["chrg_person_id_chrg"] 
        command_c["person_sect_id_chrg_bill"] =  chrg["person_sect_id_chrg"]
        command_c = blk.proc_create_tbldata(command_c) ##
        blk.proc_private_aud_rec({},command_c)
    
            ###old_custords check
        if billord["last_duedate"]
                strsql = %Q&
                            select b.*,l.id linktbl_id from billords b
                                inner join srctbllinks l on b.id = l.tblid
                                where srctblname = 'custacts' 
                                        and srctblid = #{billord["tblid"]}
                                        and tblname = 'billords' and tblid != #{command_c["id"]}
                &
                last_rec = ActiveRecord::Base.connection.select_one(strsql)
                if last_rec
                    strsql = %Q&
                                update srctbllinks set amt_src = #{billord["amt_src"].to_f} ,
                                    updated_at = current_timestamp
                                    where id = #{last_rec["linktbl_id"]}
                    &
                    ActiveRecord::Base.connection.update(strsql)
                end
        end
        ###
    end    
    ###  
    #
    ###
  def getprdpurord_from_linktbls(tblname,tblid,prdpur)  ### xxxactsからxxxordsを求める
        ords = []
        notords = []
        strsql = %Q&
                    select * from linktbls where tblname = '#{tblname}' and tblid = #{tblid}
                                            and srctblname like '#{prdpur}%' and srctblname != tblname
        &
        ActiveRecord::Base.connection.select_all(strsql).each do |rec|
            if rec["srctblname"] == "#{prdpur}ords"
                ords << rec
            else
                notords << rec
            end
        end
        return ords,notords
  end    
    ###  
    #
    ###
  def updatepaybillschs(tblid,paybill,amt)
        purcust = case paybill
                    when "pay"
                        "pur"
                    when "bill"
                        "cust"
                    end 
        strsql = %Q&
                    select * from srctbllinks where tblname = '#{paybill}schs' 
                                            and srctblname = '#{purcust}ords' and srctblid = #{tblid}
        &
        rec = ActiveRecord::Base.connection.select_one(strsql)
        updatelinktblsql = %Q& 
                            update srctbllinks set amt_src = amt_src - #{amt},
                                updated_at = current_timestamp,remark = '#{self} line:#{__LINE__}'||remark
                                where id = #{rec["id"]}
        &
        ActiveRecord::Base.connection.update(updatelinktblsql)
  end
    ###
    #
    ###     
  def proc_mk_ercschs(nd,setParams,erctblname)
        prdtblname = erctblname.sub("erc","prd")
        dvstblname = erctblname.sub("erc","dvs")
        gantt = setParams["gantt"].dup
        parent = setParams["tbldata"].dup
        setParams["mkprdpurords_id"] = 0
        gantt["tblname"] = erctblname
        gantt["qty_require"] = 1
        gantt["qty_handover"] = 0
        case erctblname
        when /schs/
            gantt["qty_sch"] = 1 
            gantt["qty"] = 0 
            gantt["qty_stk"] = 0 
        when /acts/
            gantt["qty_sch"] = 0
            gantt["qty"] = 0 
            gantt["qty_stk"] = 1 
        else
            gantt["qty_sch"] = 0
            gantt["qty"] = 1 
            gantt["qty_stk"] = 0 
        end
        gantt["consumtype"] = "apparatus"
        gantt_key = gantt["key"]
        trnganttkey = 0
        Rails.logger.debug" class:#{self} , line:#{__LINE__} ,nd:#{nd}" 
        Rails.logger.debug" class:#{self} , line:#{__LINE__} ,setParams:#{setParams}" 
        if nd["changeoverlt"].to_f > 0 and nd["changeoverop"].to_i > 0
            nd["prdpur"] = "erc"
            nd["changeoverop"].to_i.times do
                trnganttkey += 1
                gantt["key"] = gantt_key + format('%05d', trnganttkey)
                blk = RorBlkCtl::BlkClass.new("r_ercschs")
                command_c = blk.command_init
                command_c["#{erctblname.chop}_#{prdtblname.chop}_id_#{erctblname.chop}"] = parent["#{prdtblname}_id_#{dvstblname.chop}"]
                command_c["#{erctblname.chop}_created_at"] = Time.now
                command_c["#{erctblname.chop}_person_id_upd"] = gantt["persons_id_upd"] = setParams["person_id_upd"]
                command_c["#{erctblname.chop}_processname"] = "changeover"
                command_c,qty_require,err = add_update_prdpur_table_from_nditm(nd,parent,prdtblname,command_c)  ###tblname = paretblname(prdschs)
                next if err
                gantt["starttime_trn"] = command_c["#{erctblname.chop}_starttime"]
                gantt["duedate_trn"] = command_c["#{erctblname.chop}_duedate"]
                setParams["gantt"] = gantt.dup
                setParams["child"] = nd.dup
                setParams["gantt"] = gantt.dup
                command_c = blk.proc_create_tbldata(command_c)
                setParams = blk.proc_private_aud_rec(setParams,command_c) ###
            end
        end
        if nd["duration_facility"].to_f > 0 and nd["requireop"].to_i > 0
            nd["prdpur"] = "erc"
            nd["requireop"].to_i.times do
                trnganttkey += 1
                gantt["key"] = gantt_key + format('%05d', trnganttkey)
                blk = RorBlkCtl::BlkClass.new("r_ercschs")
                command_c = blk.command_init
                command_c["#{erctblname.chop}_#{prdtblname.chop}_id_#{erctblname.chop}"] = parent["#{prdtblname}_id_#{dvstblname.chop}"]
                command_c["#{erctblname.chop}_created_at"] = Time.now
                command_c["#{erctblname.chop}_person_id_upd"] = gantt["persons_id_upd"] = setParams["person_id_upd"]
                command_c["#{erctblname.chop}_processname"] = "require"
                command_c,qty_require,err = add_update_prdpur_table_from_nditm(nd,parent,prdtblname,command_c)  ###tblname = paretblname
                next if err
                gantt["starttime_trn"] = command_c["#{erctblname.chop}_starttime"]
                gantt["duedate_trn"] = command_c["#{erctblname.chop}_duedate"]
                setParams["gantt"] = gantt.dup
                setParams["child"] = nd.dup
                setParams["gantt"] = gantt.dup
                command_c = blk.proc_create_tbldata(command_c)
                setParams = blk.proc_private_aud_rec(setParams,command_c) ###
            end
        end
        if nd["postprocessinglt"].to_f > 0 and nd["postprocessingop"].to_i > 0
            nd["prdpur"] = "erc"
            nd["postprocessingop"].to_i.times do
                trnganttkey += 1
                gantt["key"] = gantt_key + format('%05d', trnganttkey)
                blk = RorBlkCtl::BlkClass.new("r_ercschs")
                command_c = blk.command_init
                command_c["#{erctblname.chop}_#{prdtblname.chop}_id_#{erctblname.chop}"] = parent["#{prdtblname}_id_#{dvstblname.chop}"]
                command_c["#{erctblname.chop}_created_at"] = Time.now
                command_c["#{erctblname.chop}_person_id_upd"] = gantt["persons_id_upd"] = setParams["person_id_upd"]
                command_c["#{erctblname.chop}_processname"] = "postprocess"
                command_c,qty_require,err = add_update_prdpur_table_from_nditm(nd,parent,prdtblname,command_c)  ###tblname = paretblname
                next if err
                gantt["starttime_trn"] = command_c["#{erctblname.chop}_starttime"]
                gantt["duedate_trn"] = command_c["#{erctblname.chop}_duedate"]
                setParams["gantt"] = gantt.dup
                setParams["child"] = nd.dup
                setParams["gantt"] = gantt.dup
                command_c = blk.proc_create_tbldata(command_c)
                setParams = blk.proc_private_aud_rec(setParams,command_c) ###
            end
        end
  end
  def add_update_lotstkhists(last_lotstks,persons_id_upd)
      tmptbls = []
      save_tblbame = save_tblid = ""
      last_lotstks.each do |last_lotstk|
        if last_lotstk["starttime"].nil? or last_lotstk["shelfnos_id"].nil? or last_lotstk["prjnos_id"]
          strsql = %Q& select rec.*,ope.itms_id,ope.processseq from #{last_lotstk["tblname"]} rec 
                          inner join opeitms ope on ope.id = rec.opeitms_id
                          where rec.id = #{last_lotstk["tblid"]}&
          rec = ActiveRecord::Base.connection.select_one(strsql)
          temp = {"shelfnos_id" => rec["shelfnos_id_to"],"itms_id" => rec["itms_id"],"processseq" => rec["processseq"],
                  "prjnos_id" => rec["prjnos_id"],"lotno" => rec["lotno"],"packno" => rec["packno"]}
          case last_lotstk["tblname"]
          when /purschs|prdschs/
            temp.merge!({"starttime" => rec["duedate"],
                        "qty_sch" => last_lotstk["qty_src"],"qty" => 0,"qty_stk" => 0, "qty_real" => 0,
                      "lotno" => "","packno" => ""})
          when /purords|purinsts|prdords|prdinsts/
            temp.merge!({"starttime" => rec["duedate"],
                        "qty_sch" => 0,"qty" => last_lotstk["qty_src"],"qty_stk" => 0, "qty_real" => 0,
                      "lotno" => "","packno" => ""})
          when /purreplyinputs/
            temp.merge!({"starttime" => rec["replaydate"],
                        "qty_sch" => 0,"qty" => last_lotstk["qty_src"],"qty_stk" => 0, "qty_real" => 0,
                      "lotno" => "","packno" => ""})
          when /purdlvs/
            temp.merge!({"starttime" => rec["depdate"],
                        "qty_sch" => 0,"qty" => 0,"qty_stk" => last_lotstk["qty_src"], "qty_real" => 0,
                      "lotno" => "","packno" => ""})
            temp.merge!({"starttime" => (rec["depdate"].to_date + 1).strftime("%-%m-%d"),
                         "qty_sch" => 0,"qty" => 0,"qty_stk" => -last_lotstk["qty_src"], "qty_real" => 0,
                         "lotno" => "","packno" => ""})
          when /puracts/
            temp.merge!({"starttime" => rec["rcptdate"],
                      "qty_sch" => 0,"qty" => 0,"qty_stk" => last_lotstk["qty_src"], "qty_real" => last_lotstk["qty_src"],
                      "lotno" => rec["lotno"],"packno" => rec["packno"]})
          when /puracts|prdacts/
            temp.merge!({"starttime" => rec["depdate"],
                       "qty_sch" => 0,"qty" => 0,"qty_stk" => last_lotstk["qty_src"], "qty_real" => last_lotstk["qty_src"],
                       "lotno" => rec["lotno"],"packno" => rec["packno"]})
          end 
          tmptbls << temp
        else
          tmptbls << last_lotstk
        end
      end
      ###data.sort_by { |h| h.values_at(:k1, :k2, :k3, :k4) }else
      Rails.logger.debug" error class:#{self} , line:#{__LINE__} ,tmptbls:#{tmptbls}"
      tmplotstktbls = tmptbls.sort_by {|h| [h["itms_id"],h["processseq"],h["shelfnos_id"],h["lotno"],h["packno"],h["prjnos_id"],h["starttime"]]}
      lotstktbls = []
      save_itms_id = save_processseq = save_shelfnos_id = save_lotno = save_packno = save_prjnos_id = save_starttime = ""
      save_qty_sch = save_qty = save_qty_stk = save_qty_real = 0
      tmplotstktbls.each do |lotstktbl|
        if save_itms_id == lotstktbl["itms_id"] and save_processseq == lotstktbl["processseq"] and 
              save_shelfnos_id == lotstktbl["shelfnos_id"] and
                 save_lotno == lotstktbl["lotno"] and save_packno == lotstktbl["packno"]  and 
                  save_prjnos_id == lotstktbl["prjnos_id"]  and save_starttime == lotstktbl["starttime"]
          save_qty_sch += lotstktbl["qty_sch"].to_f
          save_qty += lotstktbl["qty"].to_f
          save_qty_stk += lotstktbl["qty_stk"].to_f
          save_qty_real += lotstktbl["qty_real"].to_f
        else
          if save_itms_id == "" and save_processseq == "" and 
                save_shelfnos_id == "" and save_lotno == "" and save_packno == ""  and 
                    save_prjnos_id == ""  and save_starttime == ""
            save_qty_sch = lotstktbl["qty_sch"].to_f
            save_qty = lotstktbl["qty"].to_f
            save_qty_stk = lotstktbl["qty_stk"].to_f
            save_qty_real = lotstktbl["qty_real"].to_f
            save_itms_id = lotstktbl["itms_id"] 
            save_processseq = lotstktbl["processseq"] 
            save_shelfnos_id = lotstktbl["shelfnos_id"] 
            save_lotno = lotstktbl["lotno"] 
            save_packno = lotstktbl["packno"]  
            save_prjnos_id = lotstktbl["prjnos_id"]  
            save_starttime = lotstktbl["starttime"]
          else
            lotstktbls << {"itms_id" => save_itms_id ,"processseq" => save_processseq ,"shelfnos_id" => save_shelfnos_id , 
                          "lotno" => save_lotno ,"packno" => save_packno, 
                           "prjnos_id" => save_prjnos_id ,"starttime" => save_starttime ,
                          "qty_sch" => save_qty_sch ,"qty" => save_qty ,"qty_stk" => save_qty_stk ,"qty_real" => save_qty_real}
            save_itms_id = lotstktbl["itms_id"] 
            save_processseq = lotstktbl["processseq"] 
            save_shelfnos_id = lotstktbl["shelfnos_id"] 
            save_lotno = lotstktbl["lotno"] 
            save_packno = lotstktbl["packno"]  
            save_prjnos_id = lotstktbl["prjnos_id"]  
            save_starttime = lotstktbl["starttime"]
            save_qty_sch = lotstktbl["qty_sch"].to_f
            save_qty = lotstktbl["qty"].to_f
            save_qty_stk = lotstktbl["qty_stk"].to_f
            save_qty_real = lotstktbl["qty_real"].to_f
          end
        end
      end
      lotstktbls << {"itms_id" =>save_itms_id ,"processseq" => save_processseq ,"shelfnos_id" => save_shelfnos_id ,
                      "lotno" => save_lotno ,"packno" => save_packno , 
                      "prjnos_id" => save_prjnos_id ,"starttime" => save_starttime , "persons_id_upd" => persons_id_upd,
                      "qty_sch" => save_qty_sch ,"qty" => save_qty ,"qty_stk" => save_qty_stk ,"qty_real" => save_qty_real}
      lotstktbls.each do |lotstktbl|
        Shipment.proc_lotstkhists_in_out('in',lotstktbl)
      end
  end
end