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
                        if key =~ /s_id/ ###孫の項目まで対応
                          parent[key.split("s_id")[0] + key.sub("s_id","_id")] = val   
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
                          Rails.logger.debug "class #{self},line:#{__LINE__} ,last_lotstks:#{params["last_lotstks"]}"
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
                              add_update_lotstkhists(last_lotstks,params["person_id_upd"])
                            end
                        when "mkpayords"
                            ### 　parent 未使用
                            if params["last_amt"] and (params["last_amt"].to_f != params["amt"].to_f or params["last_tax"].to_f != params["tax"].to_f )
                                delete_payords(params)
                                next if params["tbldata"]["amt"].to_f == 0
                            else
                              next if params["last_amt"].to_f == params["amt"].to_f and params["last_tax"].to_f == params["tax"].to_f 
                            end
                            ###ArelCtl.proc_createtable は使用しない
                            ###bill_loca_id_bill_cust
                            isudate = Time.now
                            duedate = Time.now
                            denomination = ""
                            trn_day = duedate =  params["tbldata"]["rcptdate"].to_date.strftime("%d").to_i
                            trn_month = duedate =  params["tbldata"]["rcptdate"].to_date.strftime("%m").to_i
                            strsql = %Q%select b.* from payments b
                                            inner join suppliers c on c.payments_id_supplier = b.id   
                                            where c.id = #{params["suppliers_id"]}
                                    %
                            payment = ActiveRecord::Base.connection.select_one(strsql)
                            payord_tbldata = {"isudate"=>isudate,"payments_id" => payment["id"],
                                        "last_amt" => params["last_amt"],"last_duedate" => params["last_duedate"],
                                        "termofs" => payment["termof"],"payment" => payment["ratejson"],
                                        "payments_id" =>payment["id"],"persons_id_upd" => person["id"] ,"trngantts_id" => params["trngantts_id"],
                                         "chrgs_id" => payment["chrgs_id_payment"],"crrs_id" => tbldata["crrs_id"],
                                        "srctblname" => params["srctblname"],"srctblid" => params["srctblid"]}
                            
                            termofs = payment["termof"].split(",")
                            termofs.each_with_index do |termof,idx| 
                              case termof
                              when "0","00"   ###随時
                                JSON.parse(payment["ratejson"]).each do |rate|   ###rate["duration"] 0:同月　1:翌月
                                    duedate =  params["tbldata"]["rcptdate"].to_date.since(rate["duration"].to_i.month)
                                    if rate["day"].to_i >= 28
                                      duedate =  duedate.since(1.month)
                                      duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                                      duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                                    else
                                      if rate["day"] == "0" or rate["day"] == "00"
                                        duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                                      else 
                                        duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"])
                                      end
                                    end
                                    payord_tbldata.merge!({"amt_src" => params["tbldata"]["amt"].to_f * rate["rate"].to_i / 100,
                                                "tax" =>  params["tax"].to_f * rate["rate"].to_i / 100,
                                                "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
                                    MkordinstLib.proc_create_paybilltbl("payords",payord_tbldata)
                                end
                                break
                              when "28","29","30","31" ###月末締め
                                JSON.parse(payment["ratejson"]).each do |rate|
                                    duedate =  params["tbldata"]["rcptdate"].to_date.since(rate["duration"].to_i.month)
                                    if rate["day"].to_i >= 28
                                      duedate =  duedate.since(1.month)
                                      duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                                      duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                                    else
                                      duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"])
                                    end
                                    payord_tbldata.merge!({"amt_src" => params["tbldata"]["amt"].to_f * rate["rate"].to_i / 100 ,
                                                "tax" =>  params["tax"].to_f * rate["rate"].to_i / 100,
                                                "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
                                    MkordinstLib.proc_create_paybilltbl("payords",payord_tbldata)
                                end
                                break
                              else
                                if trn_day > termof.to_i and (idx + 1) >= termofs.size
                                  JSON.parse(payment["ratejson"]).each do |rate|
                                      duedate =  Time.now.to_date.since((rate["duration"].to_i + 1).month)
                                      if rate["day"].to_i >= 28
                                        duedate =  duedate.since(1.month)
                                        duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                                        duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                                      else
                                        duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"])
                                      end
                                      payord_tbldata.merge!({"amt_src" => params["tbldata"]["amt"].to_f * rate["rate"].to_i / 100 ,
                                                  "tax" =>  params["tax"].to_f * rate["rate"].to_i / 100,
                                                  "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
                                      MkordinstLib.proc_create_paybilltbl("payords",payord_tbldata)
                                  end
                                  break
                                else
                                    if  trn_day <= termof.to_i
                                      JSON.parse(payment["ratejson"]).each do |rate|
                                        duedate =  params["tbldata"]["rcptdate"].to_date.since(rate["duration"].to_i.month)
                                        if rate["day"].to_i >= 28
                                            duedate =  duedate.since(1.month)
                                            duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                                            duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                                        else
                                            duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"])
                                        end
                                        payord_tbldata.merge!({"amt_src" => params["tbldata"]["amt"].to_f * rate["rate"].to_i / 100 ,
                                                "tax" =>  params["tax"].to_f * rate["rate"].to_i / 100,
                                                "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
                                        MkordinstLib.proc_create_paybilltbl("payords",payord_tbldata)
                                      end
                                    end
                                    break
                                end
                              end 
                            end
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
                                                remark = ' #{mkbillinstparams[:remark]} '
                                                where id = #{params["mkbillinsts_id"]}
                                %
                            ActiveRecord::Base.connection.update(strsql)


                        when "mkpayinsts"
                            ### 　parent 未使用
                            mkpayinstparams = {}
                            mkpayinst = tbldata.dup
                            mkpayinstparams[:incnt] = 0
                            mkpayinstparams[:inamt] = 0
                            mkpayinstparams[:outcnt] = 0
                            mkpayinstparams[:outamt] = 0
                            mkpayinstparams = MkordinstLib.proc_mkpayinsts params,mkpayinstparams
                            mkpayinstparams[:remark] = " #{self} line:#{__LINE__} "
                            strsql = %Q%update mkpayinsts set incnt = #{mkpayinstparams[:incnt]},
                                                  inamt = #{mkpayinstparams[:inamt]},outcnt = #{mkpayinstparams[:outcnt]},
                                                  outamt = #{mkpayinstparams[:outamt]} ,
                                                  remark = ' #{mkpayinstparams[:remark]} '
                                                  where id = #{params["mkpayinsts_id"]}
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
                                            where c.id = #{params["custs_id"]} and c.crrs_id_cust = b.crrs_id_bill
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
                                        paybillschs = {"amt_src" =>amt_src,"isudate"=>isudate,"duedate" =>duedate,"tax" =>0,
                                                "payments_id" => paybill["id"],"suppliers_id" => paybill["suppliers_id"],
                                                "persons_id_upd" => person["id"] ,"trngantts_id" => params["trngantts_id"],
                                                "last_duedate" => params["last_duedate"], "chrgs_id" => paybill["chrgs_id_payment"],
                                                "tblname" => params["srctblname"],"tblid" => params["srctblid"]}
                                    when "mkbillschs","mkbillests"
                                        paybillschs = {"amt_src" =>amt_src,"isudate"=>isudate,"duedate" =>duedate,
                                                "tax" =>0,
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
                                                "tax" =>0,
                                                "payments_id" =>paybill["id"],"suppliers_id" => paybill["suppliers_id"],
                                                "persons_id_upd" => person["id"] ,"trngantts_id" => params["trngantts_id"],
                                                "last_duedate" => params["last_duedate"], "chrgs_id" => paybill["chrgs_id_payment"],
                                                "tblname" => params["srctblname"],"tblid" => params["srctblid"]}
                                    when "mkbillschs","mkbillests"
                                        paybillschs = {"amt_src" =>amt_src,"isudate"=>isudate,"duedate" =>duedate,"tax" =>0,
                                                "bills_id" => paybill["id"],
                                                "persons_id_upd" => person["id"] ,"trngantts_id" => params["trngantts_id"],
                                                "last_duedate" => params["last_duedate"],"chrgs_id" => paybill["chrgs_id_bill"],
                                                "tblname" => params["srctblname"],"tblid" => params["srctblid"]}
                                    end
                                    create_paybillschs(src,paybillschs,paybill)
                                end
                            else
                                3.times{Rails.logger.debug" error class:#{self} , line:#{__LINE__} ,paybillschs:#{paybillschs}" }
                                raise
                            end 
                        when /mkbillords/
                            ###ArelCtl.proc_createtable は使用しない
                            ###bill_loca_id_bill_cust
                            ### 　parent 未使用
                            amt_src = 0
                            isudate = duedate = Time.now
                            src = {"tblname" => params["srctblname"],"tblid" => params["srctblid"],"trngantts_id" => 0}
                            strsql = %Q%select b.* from bills b   
                                            where b.id = #{tbldata["bills_id"]}
                                    %
                            billmst = ActiveRecord::Base.connection.select_one(strsql)
                            billord_tbldata = {"isudate"=>isudate,
                                        "bills_id" =>billmst["id"],"persons_id_upd" => person["id"] ,"trngantts_id" => params["trngantts_id"],
                                        "last_duedate" => tbldata["last_duedate"],"chrgs_id" => billmst["chrgs_id_bill"],
                                        "srctblname" => params["srctblname"],"srctblid" => params["srctblid"]}
                            termofs = billmst["termof"].split(",")
                            termofs.each_with_index do |termof,idx| 
                              case termof
                              when "0","00"   ###随時
                                  JSON.parse(billmst["ratejson"]).each do |rate|   ###rate["duration"] 0:同月　1:翌月
                                      duedate =  params["tbldata"]["rcptdate"].to_date.since(rate["duration"].to_i.month)
                                      if rate["day"].to_i >= 28
                                                  duedate =  duedate.since(1.month)
                                                  duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                                                  duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                                      else
                                          if rate["day"] == "0" or rate["day"] == "00"
                                                duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                                          else 
                                              duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"])
                                          end
                                      end
                                      payord_tbldata.merge!({"amt_src" => params["tbldata"]["amt"].to_f * rate["rate"].to_i / 100,
                                                            "tax" =>  params["tax"].to_f * rate["rate"].to_i / 100,
                                                            "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
                                      MkordinstLib.proc_create_paybilltbl("payords",payord_tbldata)
                                  end
                                  break
                              when "28","29","30","31" ###月末締め
                                  JSON.parse(billmst["ratejson"]).each do |rate|
                                     duedate =  params["tbldata"]["rcptdate"].to_date.since(rate["duration"].to_i.month)
                                      if rate["day"].to_i >= 28
                                        duedate =  duedate.since(1.month)
                                        duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                                        duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                                      else
                                         duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"])
                                      end
                                  payord_tbldata.merge!({"amt_src" => params["tbldata"]["amt"].to_f * rate["rate"].to_i / 100 ,
                                                           "tax" =>  params["tax"].to_f * rate["rate"].to_i / 100,
                                                           "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
                                  MkordinstLib.proc_create_paybilltbl("payords",payord_tbldata)
                                  end
                                  break
                              else
                                 if trn_day > termof.to_i and (idx + 1) >= termofs.size
                                     JSON.parse(billmst["ratejson"]).each do |rate|
                                        duedate =  Time.now.to_date.since((rate["duration"].to_i + 1).month)
                                        if rate["day"].to_i >= 28
                                                    duedate =  duedate.since(1.month)
                                                    duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                                                    duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                                        else
                                                    duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"])
                                        end
                                        payord_tbldata.merge!({"amt_src" => params["tbldata"]["amt"].to_f * rate["rate"].to_i / 100 ,
                                                              "tax" =>  params["tax"].to_f * rate["rate"].to_i / 100,
                                                              "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
                                        MkordinstLib.proc_create_paybilltbl("payords",payord_tbldata)
                                        break
                                      end
                                  else
                                      if  trn_day <= termof.to_i
                                           duedate =  params["tbldata"]["rcptdate"].to_date.since(rate["duration"].to_i.month)
                                        JSON.parse(billmst["ratejson"]).each do |rate|
                                          if rate["day"].to_i >= 28
                                                        duedate =  duedate.since(1.month)
                                                        duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                                                     duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                                          else
                                            duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"])
                                          end
                                          payord_tbldata.merge!({"amt_src" => params["tbldata"]["amt"].to_f * rate["rate"].to_i / 100 ,
                                                            "tax" =>  params["tax"].to_f * rate["rate"].to_i / 100,
                                                            "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
                                          MkordinstLib.proc_create_paybilltbl("payords",payord_tbldata)
                                          break
                                        end
                                      end
                                      next
                                  end
                              end 
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
                            last_lotstks = []
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
                                    setParams["gantt"] =  gantt.dup
                                    command_c = blk.proc_create_tbldata(command_c)
                                    setParams = blk.proc_private_aud_rec(setParams,command_c) ###create pur,prdschs
                                    if gantt["consumtype"] == "CON"  ###出庫 消費と金型・設備の使用
                                      setParams["child"] =  nd.dup
                                      last_lotstks <<  Shipment.proc_create_consume(setParams)   ###自身の消費を作成
                                    end
                                else  ###
                                    nd["opeitms_id"] = 0
                                    nd["shelfnos_id_opeitm"] = 0
                                    nd["shelfnos_id_opeitm"] = 0
                                    nd["locas_id_shelfno_to"] = 0
                                    nd["locas_id_shelfno"] = 0
                                    case nd["classlist_code"]
                                    when "apparatus"  ###
                                        dvsParams = setParams
                                        dvsParams["screenCode"] = "r_prdschs"
                                        dvs = Operation::OpeClass.new(dvsParams)  ###prdinsts,prdacts
                                        dvs.proc_add_dvs_data(nd)
                                        dvs.proc_add_erc_data(nd)
                                        # blk = RorBlkCtl::BlkClass.new("r_dvsschs")
                                        # command_c = blk.command_init
                                        # nd["prdpur"] = "dvs"
                                        # gantt["tblname"] = "dvsschs"
                                        # command_c,qty_require,err = add_update_prdpur_table_from_nditm(nd,parent,tblname,command_c)  ###tblname = paretblname
                                        # next if err
                                        # gantt["duedate_trn"] = command_c["#{gantt["tblname"].chop}_duedate"]
                                        # gantt["qty_require"] = 1
                                        # gantt["qty_handover"] = 0
                                        # gantt["qty_sch"] = 1 
                                        # gantt["consumtype"] = (nd["consumtype"]||="apparatus")
                                        # command_c["dvssch_prdsch_id_dvssch"] = parent["tblid"]
                                        # command_c["dvssch_person_id_upd"] = gantt["persons_id_upd"] = setParams["person_id_upd"]
                                        # command_c["dvssch_created_at"] = Time.now
                                        # setParams["mkprdpurords_id"] = 0
                                        # setParams["gantt"] = gantt.dup
                                        # setParams["child"] = nd.dup
                                        # setParams["gantt"] = gantt.dup
                                        # command_c = blk.proc_create_tbldata(command_c)
                                        # setParams = blk.proc_private_aud_rec(setParams,command_c) ###
                                        # ###
                                        # # 人のリソース
                                        # ###
                                        # mk_ercschsords(nd,setParams,"ercschs")
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
                                        last_lotstks_parts = Shipment.proc_create_shpxxxs(setParams) do  ###
                                            "shpest"
                                        end
                                        last_lotstks.concat last_lotstks_parts
                                        3.times{Rails.logger.debug" class:#{self} , line:#{__LINE__} ,error last_lotstk:#{last_lotstk}"} if  last_lotstk.nil? or last_lotstk["tblname"].nil? or last_lotstk["tblname"] == ""
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
                                        command_c = blk.proc_create_tbldata(command_c)
                                        setParams = blk.proc_private_aud_rec(setParams,command_c) ###create pur,prdschs
                                        if gantt["consumtype"] == "CON"  ###出庫 消費と金型・設備の使用
                                          last_lotstks << Shipment.proc_create_consume(setParams)
                                        end
                                    end
                                end
                            end       
                            if !last_lotstks.empty?
                              Rails.logger.debug"class #{self},line:#{__LINE__} ,last_lotstks:#{last_lotstks}" 
                              add_update_lotstkhists(last_lotstks,params["person_id_upd"])
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
                            last_lotstks = []
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
                                    if opeitm["shpordauto"] != "M" and nd["pare_shelfnos_id"] != nd["shelfnos_id_to"]  ###手動出荷ではない、親の作業場所!=部品の保管場所
                                      setParams["screenCode"] = "r_shpschs"    
                                      last_lotstks_parts =  Shipment.proc_create_shpxxxs(setParams) do  ###prd,purordsによる自動作成 
                                            "shpsch"
                                      end
                                      last_lotstks.concat last_lotstks_parts
                                    end
                                    setParams["screenCode"] = "r_conords"    
                                    last_lotstks <<  Shipment.proc_create_consume(setParams)
                                when "mold","ITool"  ###出庫 金型・工具の使用
                                    child["consumauto"] = (nd["consumauto"]||="")  ###子の保管場所からの出庫
                                    child["packno"] = ""
                                    child["lotno"] = ""   ### shpschs,shpordsの時はlotnoは""  
                                    setParams["parent"] = parent.dup
                                    setParams["child"] = child.dup
                                    if opeitm["shpordauto"] != "M"
                                      setParams["screenCode"] = "r_shpschs"  
                                      last_lotstks_parts =  Shipment.proc_create_shpxxxs(setParams) do  ###prd,purordsによる自動作成 
                                            "shpsch"
                                        end
                                      last_lotstks.concat last_lotstks_parts
                                    end    
                                when "BYP"   ###副産物
                                    ###
                                else
                                    next
                                end
                            end 
                            if !last_lotstks.empty?
                              add_update_lotstkhists(last_lotstks,params["person_id_upd"])
                            end
                        when "mkprdpurchildFromCustxxxs"  ### custxxxsからpur,purschsに変更"custord_crr_id_custord" 
                            ###　parent 未使用
                            gantt = params["gantt"].dup
                            gantt["mlevel"] = 1
                            gantt["key"] = "00000000"
                            gantt["qty_sch_pare"] = 0 
                            last_lotstks = []
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
                                    src = {"tblname" => "custschs","tblid" => sch["srctblid"],"trngantts_id" => sch["trngantts_id"]}
                                    base = {"tblname" => "custords","tblid" => gantt["orgtblid"],"qty_src" => qty_src,"amt_src" => 0,"persons_id_upd" => setParams["person_id_upd"]}
                                    ArelCtl.proc_insert_linkcusts(src,base)  ###
                                    last_lotstks << {"tblname" => "custschs","tblid" => sch["srctblid"],"qty_src" => qty_src}
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
                            command_c["#{setParams["opeitm"]["prdpur"]}sch_person_id_upd"] = setParams["person_id_upd"]
                            command_c["#{setParams["opeitm"]["prdpur"]}sch_duedate"] = tbldata["starttime"].to_time.strftime("%Y-%m-%d") + " 16:00:00"
                            command_c,qty_require = add_update_prdpur_table_from_nditm(child,tbldata,paretblname,command_c)  ###tbldata--->parent
                            command_c["#{setParams["opeitm"]["prdpur"]}sch_created_at"] = Time.now
                            command_c = blk.proc_create_tbldata(command_c)
                            setParams["gantt"] = gantt.dup
                            setParams = blk.proc_private_aud_rec(setParams,command_c)   
                            result_f = '1'
                            if !last_lotstks.empty?
                              Rails.logger.debug"class #{self},line:#{__LINE__} , last_lotstks: #{last_lotstks} "
                              add_update_lotstkhists(last_lotstks,params["person_id_upd"])
                            end
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
		    command_c,qty_require,err = CtlFields.proc_schs_fields_making(nd,parent,command_init)
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
        command_c["#{paybillsch}_tax"] = 0 
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
		    command_c["#{paybillsch}_created_at"] = Time.now  ###
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
        # blk = RorBlkCtl::BlkClass.new("r_billords")
        # command_c = blk.command_init
        # command_c["billord_person_id_upd"] = billord["persons_id_upd"]
        # command_c["billord_duedate"] = billord["duedate"]
        # command_c["billord_isudate"] = billord["isudate"]
        # command_c["billord_expiredate"] = "2099/12/31"
        # command_c["billord_chrg_id"] = billord["chrgs_id"]
        # command_c["billord_tax"] = billord["tax"] 
        # command_c["billord_updated_at"] = Time.now
        # command_c["billord_bill_id"] = billmst["id"]
        # command_c["billord_denomination"] = billord["denomination"]
        # strsql = %Q&
        #                 select * from billords where bills_id = #{billmst["id"]} 
        #                                         and to_char(duedate,'yyyy-mm-dd') = '#{billord["duedate"].strftime("%Y-%m-%d")}'
        #                                         and denomination = '#{billord["denomination"]}'
        #     &
        # chk_billord = ActiveRecord::Base.connection.select_one(strsql)
        # if chk_billord
        #     command_c["sio_classname"] = "_update_from_custacts "
        #     command_c["custord_remark"] = "auto update "
        #     command_c["id"] = command_c["billord_id"] = chk_billord["id"]
        #     strsql = %Q&
        #                     select * from srctbllinks where srctblname = 'custacts' and srctblid = #{custord["tblid"]} ---tblid = puracts.id  
        #                             and tblname = 'custords' and tblid = #{chk_custord["id"]}
        #                 &
        #     link = ActiveRecord::Base.connection.select_one(strsql)
        #     if link 
        #         link["amt_src"] = link["amt_src"].to_f + (billord["amt_src"].to_f - billord["last_amt"].to_f )
        #          strsql = %Q&
        #                         update srctbllinks set amt_src = #{link["amt_src"]} ,
        #                             updated_at = #{Time.now}
        #                             where id = #{link["id"]}
        #             &
        #             ActiveRecord::Base.connection.update(strsql)
        #     else
        #         command_c["billord_amt"] = chk_billord["amt"].to_f + billord["amt_src"].to_f 
        #         base = {"tblname" => "billords","tblid" => command_c["id"],"qty_src" => 0,"amt_src" => billord["amt_src"],
        #                      "persons_id_upd" => billord["persons_id_upd"]} 
        #             ArelCtl.proc_insert_srctbllinks(src,base)
        #     end
        # else
        #     command_c["sio_classname"] = "_add_from_custacts"
        #     command_c["billord_remark"] = "auto add "
        #     command_c["id"] = command_c["billord_id"] = ArelCtl.proc_get_nextval("billords_seq")
        #     command_c["billord_created_at"] = Time.now
        #     command_c["billord_amt"] = billord["amt_src"]
        #     base = {"tblname" => "billords","tblid" => command_c["id"],"amt_src" => billord["amt_src"],
        #             "persons_id_upd" => billord["persons_id_upd"]} 
        #     ArelCtl.proc_insert_srctbllinks(src,base)
        # end
        # strsql = %Q&
        #                 select * from r_chrgs where id = #{billmst["chrgs_id_bill"]} 
        #     &
        # chrg = ActiveRecord::Base.connection.select_one(strsql)
        # command_c["chrg_person_id_chrg_bill"] = chrg["chrg_person_id_chrg"] 
        # command_c["person_sect_id_chrg_bill"] =  chrg["person_sect_id_chrg"]
        # command_c = blk.proc_create_tbldata(command_c) ##
        # blk.proc_private_aud_rec({},command_c)
    
        #     ###old_custords check
        # if billord["last_duedate"]
        #         strsql = %Q&
        #                     select b.*,l.id linktbl_id from billords b
        #                         inner join srctbllinks l on b.id = l.tblid
        #                         where srctblname = 'custacts' 
        #                                 and srctblid = #{billord["tblid"]}
        #                                 and tblname = 'billords' and tblid != #{command_c["id"]}
        #         &
        #         last_rec = ActiveRecord::Base.connection.select_one(strsql)
        #         if last_rec
        #             strsql = %Q&
        #                         update srctbllinks set amt_src = #{billord["amt_src"].to_f} ,
        #                             updated_at = current_timestamp
        #                             where id = #{last_rec["linktbl_id"]}
        #             &
        #             ActiveRecord::Base.connection.update(strsql)
        #         end
        # end
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
  def mk_ercschsords(nd,setParams,erctblname)
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
        when /ords/
            gantt["qty_sch"] = 0
            gantt["qty"] = 1 
            gantt["qty_stk"] = 0 
        else
            3.times{Rails.logger.debug"  erctbl not suppurt:#{erctblname},class: #{self} , line:#{__LINE__} "}
            raise 
        end
        gantt["consumtype"] = "apparatus"
        gantt_key = gantt["key"]
        trnganttkey = 0
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
                next if 
                ### perfotm　実行のため　.to_json日付が"2024-12-17T20:53:26.000Z"になている
                command_c["#{erctblname.chop}_starttime"] =  command_c["#{erctblname.chop}_starttime"].to_time.strftime("%Y-%m-%d %H:%M:%S")
                command_c["#{erctblname.chop}_duedate"] = command_c["#{erctblname.chop}_duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S")
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
                command_c = blk.proc_create_tbldata(command_c)
                setParams = blk.proc_private_aud_rec(setParams,command_c) ###
            end
        end
  end
  ###
  def add_update_lotstkhists(last_lotstks,persons_id_upd)
      tmptbls = []
      save_tblbame = save_tblid = ""
      last_lotstks.each do |last_lotstk| 
          if last_lotstk["set_f"]
              rec = last_lotstk["rec"].dup
          else
            case last_lotstk["tblname"]
            when /^prd|^pur|^cust/
                  strsql = %Q& select rec.*,ope.itms_id,ope.processseq from #{last_lotstk["tblname"]} rec 
                          inner join opeitms ope on ope.id = rec.opeitms_id
                          where rec.id = #{last_lotstk["tblid"]}&
                  rec = ActiveRecord::Base.connection.select_one(strsql)
                  case last_lotstk["tblname"]
                  when /^pur/
                      suppliers_id_fm  = rec["suppliers_id"]
                      supp_str = %Q&
                              select supp.id from suppliers supp
                                            inner join shelfnos shelf on shelf.locas_id_shelfno = supp.locas_id_supplier
                                            where shelf.id = #{rec["shelfnos_id_to"]}
                      &
                      suppliers_id_to = ActiveRecord::Base.connection.select_value(supp_str)
                      suppliers_id_to ||= ""
                  else
                      suppliers_id_fm = ""
                      suppliers_id_to = ""
                  end
            when /^con/
                      strsql = %Q& select rec.* from #{last_lotstk["tblname"]} rec where rec.id = #{last_lotstk["tblid"]}&
                      rec = ActiveRecord::Base.connection.select_one(strsql)
                      supp_str = %Q&
                              select supp.id from suppliers supp
                                            inner join shelfnos shelf on shelf.locas_id_shelfno = supp.locas_id_supplier
                                            where shelf.id = #{rec["shelfnos_id_fm"]}
                      &
                      suppliers_id_fm = ActiveRecord::Base.connection.select_value(supp_str)
                      suppliers_id_fm ||= ""
                      suppliers_id_to = ""
            when /^shp/
                  strsql = %Q& select rec.* from #{last_lotstk["tblname"]} rec where rec.id = #{last_lotstk["tblid"]}&
                  rec = ActiveRecord::Base.connection.select_one(strsql)
                  supp_str = %Q&
                          select supp.id from suppliers supp
                                        inner join shelfnos shelf on shelf.locas_id_shelfno = supp.locas_id_supplier
                                        where shelf.id = #{rec["shelfnos_id_to"]}
                  &
                  suppliers_id_to = ActiveRecord::Base.connection.select_value(supp_str)
                  suppliers_id_to ||= ""
                  supp_str = %Q&
                          select supp.id from suppliers supp
                                        inner join shelfnos shelf on shelf.locas_id_shelfno = supp.locas_id_supplier
                                        where shelf.id = #{rec["shelfnos_id_fm"]}
                  &
                  suppliers_id_fm = ActiveRecord::Base.connection.select_value(supp_str)
                  suppliers_id_fm ||= ""
            else
              3.times{Rails.logger.debug" class:#{self} , line:#{__LINE__} ,error last_lotstk:#{last_lotstk}"}
              raise
            end
          end
          temp = {"itms_id" => rec["itms_id"],"processseq" => rec["processseq"],"prjnos_id" => rec["prjnos_id"],
                    "tblname" => last_lotstk["tblname"],"tblid" => last_lotstk["tblid"],
                    "shelfnos_id" => "","suppliers_id_fm" => suppliers_id_fm,"suppliers_id_to" => suppliers_id_to ,"custrcvplcs_id" => "" }
          case last_lotstk["tblname"]
            when /purschs|prdschs/
              temp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                        "qty_sch" => last_lotstk["qty_src"],"qty" => 0,"qty_stk" => 0, "qty_real" => 0,
                      "lotno" => "","packno" => ""})
              tmptbls << temp
            when /custschs/
              temp.merge!({"starttime" => rec["starttime"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                                "qty_sch" => last_lotstk["qty_src"]*-1,"qty" => 0,"qty_stk" => 0, "qty_real" => 0,
                              "lotno" => "","packno" => ""})
              tmptbls << temp
              temp = {"shelfnos_id" => rec["shelfnos_id_to"],"itms_id" => rec["itms_id"],
                      "processseq" => rec["processseq"],"prjnos_id" => rec["prjnos_id"]}
              temp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"custrcvplcs_id" => rec["custrcvplcs_id"],
                                "qty_sch" => last_lotstk["qty_src"]*-1,"qty" => 0,"qty_stk" => 0, "qty_real" => 0,
                                "lotno" => "","packno" => ""})
              tmptbls << temp
            when /purords|purinsts/
              temp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                      "qty_sch" => 0,"qty" => last_lotstk["qty_src"],"qty_stk" => 0, "qty_real" => 0,
                      "lotno" => "","packno" => ""})
              tmptbls << temp
              temp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => "",
                      "suppliers_id_fm" => rec["suppliers_id"],
                      "qty_sch" => 0,"qty" => last_lotstk["qty_src" ] * -1,"qty_stk" => 0, "qty_real" => 0,
                      "lotno" => "","packno" => ""})
              tmptbls << temp
            when /prdords|prdinsts/
              temp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                      "qty_sch" => 0,"qty" => last_lotstk["qty_src"],"qty_stk" => 0, "qty_real" => 0,
                      "lotno" => "","packno" => ""})
              tmptbls << temp
            when /custords/
              temp.merge!({"starttime" => rec["starttime"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                              "custrcvplcs_id" => "",
                              "qty" => last_lotstk["qty_src"]*-1,"qty_sch" => 0,"qty_stk" => 0, "qty_real" => 0,
                              "lotno" => "","packno" => ""})
              tmptbls << temp
              temp = {"itms_id" => rec["itms_id"],"processseq" => rec["processseq"],"prjnos_id" => rec["prjnos_id"],
                      "shelfnos_id" => "","custrcvplcs_id" => "" }
              temp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => "",
                      "custrcvplcs_id" => rec["custrcvplcs_id"],
                      "qty_sch" => 0,"qty" => last_lotstk["qty_src"],"qty_stk" => 0, "qty_real" => 0,
                      "lotno" => "","packno" => ""})
              tmptbls << temp
            when /purreplyinputs/
              temp.merge!({"starttime" => rec["replaydate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                        "qty_sch" => 0,"qty" => last_lotstk["qty_src"],"qty_stk" => 0, "qty_real" => 0,
                      "lotno" => "","packno" => ""})
              tmptbls << temp
            when /custdlvs/
              temp.merge!({"starttime" => rec["depdate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                      "custrcvplcs_id" => "",
                        "qty_sch" => 0,"qty" => 0,"qty_stk" => last_lotstk["qty_src"], "qty_real" => 0,
                      "lotno" => "","packno" => ""})
              tmptbls << temp
            when /purdlvs/
              temp.merge!({"starttime" => rec["depdate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => "","custrcvplcs_id" => "",
                        "suppliers_id_fm" => suppliers_id_fm,

                        "qty_sch" => 0,"qty" => 0,"qty_stk" => last_lotstk["qty_src"], "qty_real" => 0,
                      "lotno" => "","packno" => ""})
              tmptbls << temp
            when /puracts/
              temp.merge!({"starttime" => rec["rcptdate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                      "qty_sch" => 0,"qty" => 0,"qty_stk" => last_lotstk["qty_src"], "qty_real" => last_lotstk["qty_src"],
                      "lotno" => rec["lotno"],"packno" => rec["packno"]})
              tmptbls << temp
            when /prdacts/
              temp.merge!({"starttime" => rec["cmpldate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                            "qty_sch" => 0,"qty" => 0,"qty_stk" => last_lotstk["qty_src"], "qty_real" => last_lotstk["qty_src"],
                              "lotno" => rec["lotno"],"packno" => rec["packno"]})
              tmptbls << temp
            when /custacts/
              temp.merge!({"starttime" => rec["saledate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => "",
                        "custrcvplcs_id" => rec["custrcvplcs_id"],
                        "qty_sch" => 0,"qty" => 0,"qty_stk" => last_lotstk["qty_src"], "qty_real" => last_lotstk["qty_src"],
                        "lotno" => rec["lotno"],"packno" => rec["packno"]})
              tmptbls << temp
            when /shpests/
              temp.merge!({"starttime" => rec["depdate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                        "qty_sch" => last_lotstk["qty_src"] * -1,"qty" => 0,"qty_stk" => 0, "qty_real" => 0,
                        "lotno" => "","packno" => ""})
              tmptbls << temp
              temp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                         "qty_sch" => last_lotstk["qty_src"],"qty" => 0,"qty_stk" => 0, "qty_real" => 0,
                         "lotno" => "","packno" => ""})
               tmptbls << temp
            when /shpschs/
              temp.merge!({"starttime" => rec["depdate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                                    "qty_sch" => last_lotstk["qty_src"] * -1,"qty" => 0,"qty_stk" => 0, "qty_real" => 0,
                                    "lotno" => "","packno" => ""})
               tmptbls << temp
              temp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                                     "qty_sch" => last_lotstk["qty_src"],"qty" => 0,"qty_stk" => 0, "qty_real" => 0,
                                     "lotno" => "","packno" => ""})
              tmptbls << temp
            when /shpords/
              temp.merge!({"starttime" => rec["depdate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                               "qty_sch" => 0,"qty" => last_lotstk["qty_src"] * -1,"qty_stk" => 0, "qty_real" => 0,
                                    "lotno" => "","packno" => ""})
              tmptbls << temp
              temp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                                     "qty_sch" => 0,"qty" => last_lotstk["qty_src"],"qty_stk" => 0, "qty_real" => 0,
                                     "lotno" => "","packno" => ""})
               tmptbls << temp
            when /shpinsts/
              temp.merge!({"starttime" => rec["depdate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                      "qty_sch" => 0,"qty" => 0,"qty_stk" => last_lotstk["qty_src"] * -1, "qty_real" => last_lotstk["qty_src"] * -1,
                                    "lotno" =>rec["lotno"],"packno" => rec["packno"]})
              tmptbls << temp
            when /shpacts/
              temp.merge!({"starttime" => rec["rcptdate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                      "qty_sch" => 0,"qty" => 0,"qty_stk" => last_lotstk["qty_src"], "qty_real" => last_lotstk["qty_src"],
                      "lotno" => rec["lotno"],"packno" => rec["packno"]})
              tmptbls << temp
            when /conschs/
              temp.merge!({"starttime" => rec["duedate"],"shelfnos_id" => rec["shelfnos_id_fm"],
                     "qty_sch" => last_lotstk["qty_src"] * -1,"qty" => 0,"qty_stk" => 0, "qty_real" => 0,
                     "lotno" => "","packno" => ""})
              tmptbls << temp
            when /conords|coninsts/
                temp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                     "qty_sch" => 0,"qty" => last_lotstk["qty_src"] * -1,"qty_stk" => 0, "qty_real" => 0,
                     "lotno" => "","packno" => ""})
              tmptbls << temp
            when /conacts/
                      temp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                              "qty_sch" => 0,"qty" => 0 ,
                              "qty_stk" => last_lotstk["qty_src"] * -1, "qty_real" => last_lotstk["qty_src"] * -1,
                              "lotno" => rec["lotno"],"packno" => rec["packno"]})
              tmptbls << temp
            else
              3.times{Rails.logger.debug" error class:#{self} , line:#{__LINE__} ,tblname not support last_lotstk:#{last_lotstk}"}
              raise
          end 
      end
      ###data.sort_by { |h| h.values_at(:k1, :k2, :k3, :k4) }else
      Rails.logger.debug"###"
      Rails.logger.debug" class:#{self} , line:#{__LINE__} ,tmptbls:#{tmptbls}"
      Rails.logger.debug"###"
      tmplotstktbls = tmptbls.sort_by {|h| [h["itms_id"],h["processseq"],h["prjnos_id"],h["starttime"],h["lotno"],h["packno"],
                        h["shelfnos_id"],h["suppliers_id_fm"],h["suppliers_id_to"],h["custrcvplcs_id"]]}
      lotstktbls = []
      save_itms_id = save_processseq = save_shelfnos_id = save_lotno = save_packno = save_prjnos_id = save_starttime = ""
      save_suppliers_id_fm = save_suppliers_id_to = save_custrcvplcs_id = save_tblname = save_tblid = ""
      save_qty_sch = save_qty = save_qty_stk = save_qty_real = 0
      tmplotstktbls.each do |tmpl|
        if save_itms_id == tmpl["itms_id"] and save_processseq == tmpl["processseq"] and 
              save_shelfnos_id == tmpl["shelfnos_id"] and
                 save_lotno == tmpl["lotno"] and save_packno == tmpl["packno"]  and 
                  save_prjnos_id == tmpl["prjnos_id"]  and save_starttime == tmpl["starttime"] and 
                     save_suppliers_id_fm == tmpl["suppliers_id_fm"]  and save_suppliers_id_to == tmpl["suppliers_id_to"] and 
                          save_custrcvplcs_id == tmpl["custrcvplcs_id"]
          save_qty_sch += tmpl["qty_sch"].to_f
          save_qty += tmpl["qty"].to_f
          save_qty_stk += tmpl["qty_stk"].to_f
          save_qty_real += tmpl["qty_real"].to_f
        else
          if save_itms_id == "" and save_processseq == "" and 
                save_shelfnos_id == "" and save_lotno == "" and save_packno == ""  and 
                    save_prjnos_id == ""  and save_starttime == "" and 
                      save_suppliers_id_fm == "" and  save_suppliers_id_to == "" and  save_custrcvplcs_id == ""
          else
            lotstktbls << {"itms_id" => save_itms_id ,"processseq" => save_processseq ,
                          "shelfnos_id" => save_shelfnos_id ,
                          "suppliers_id_fm" => save_suppliers_id_fm ,"suppliers_id_to" => save_suppliers_id_to , 
                          "custrcvplcs_id" => save_custrcvplcs_id,
                          "tblname" => save_tblname,"tblid" => save_tblid,
                          "lotno" => save_lotno ,"packno" => save_packno,  "persons_id_upd" => persons_id_upd,
                           "prjnos_id" => save_prjnos_id ,"starttime" => save_starttime ,
                          "qty_sch" => save_qty_sch ,"qty" => save_qty ,"qty_stk" => save_qty_stk ,"qty_real" => save_qty_real}
          end
            save_itms_id = tmpl["itms_id"] 
            save_processseq = tmpl["processseq"] 
            save_shelfnos_id = tmpl["shelfnos_id"] 
            save_suppliers_id_fm = tmpl["suppliers_id_fm"] 
            save_suppliers_id_to = tmpl["suppliers_id_to"] 
            save_custrcvplcs_id = tmpl["custrcvplcs_id"] 
            save_lotno = tmpl["lotno"] 
            save_packno = tmpl["packno"]  
            save_prjnos_id = tmpl["prjnos_id"]  
            save_starttime = tmpl["starttime"]
            save_qty_sch = tmpl["qty_sch"].to_f
            save_qty = tmpl["qty"].to_f
            save_qty_stk = tmpl["qty_stk"].to_f
            save_tblname = tmpl["tblname"]
            save_tblid = tmpl["tblid"]
        end
      end
      lotstktbls << {"itms_id" =>save_itms_id ,"processseq" => save_processseq ,
                      "shelfnos_id" => save_shelfnos_id ,"suppliers_id_fm" => save_suppliers_id_fm,"suppliers_id_to" => save_suppliers_id_to,
                      "custrcvplcs_id" => save_custrcvplcs_id,"lotno" => save_lotno ,"packno" => save_packno , 
                      "prjnos_id" => save_prjnos_id ,"starttime" => save_starttime , "persons_id_upd" => persons_id_upd,
                      "tblname" => save_tblname,"tblid" => save_tblid,
                      "qty_sch" => save_qty_sch ,"qty" => save_qty ,"qty_stk" => save_qty_stk ,"qty_real" => save_qty_real}
      lotstktbls.each do |lotstktbl|
        if lotstktbl["suppliers_id_fm"] and lotstktbl["suppliers_id_fm"] != ""
            lotstktbl["suppliers_id"] = lotstktbl["suppliers_id_fm"] 
            Shipment.proc_mk_supplierwhs_rec "in",lotstktbl
        else  
          if lotstktbl["suppliers_id_to"] and lotstktbl["suppliers_id_to"] != ""
              lotstktbl["suppliers_id"] = lotstktbl["suppliers_id_to"] 
              Shipment.proc_mk_supplierwhs_rec "in",lotstktbl
          else
            if lotstktbl["custrcvplcs_id"] and lotstktbl["custrcvplcs_id"] != "" 
              Shipment.proc_mk_custwhs_rec "in",lotstktbl
            else
              if lotstktbl["shelfnos_id"].nil? or lotstktbl["shelfnos_id"] == ""
                  3.times{Rails.logger.debug" error shelfnos_id missing class:#{self} , line:#{__LINE__} ,lotstktbl:#{lotstktbl}"}
                  raise
              else
                Shipment.proc_lotstkhists_in_out('in',lotstktbl)
              end
            end
          end
        end
      end
  end
end