# -*- coding: utf-8 -*-
# operation
# 2099/12/31を修正する時は　2100/01/01の修正も
# Operationではamtは扱わない
module Operation
	extend self
  class OpeClass
	  def initialize(params)
		  @reqparams = params.dup
		  @gantt = params["gantt"].dup ###reqparamsのtblの情報もここでセットしている。
		  @tblname = @gantt["tblname"] ###
		  @tblid = @gantt["tblid"]
		  @paretblname = @gantt["paretblname"]
		  @paretblid = @gantt["paretblid"]
		  @orgtblname = @gantt["orgtblname"]
		  @orgtblid = @gantt["orgtblid"]

		  @tbldata = params["tbldata"].dup
		  @tbldata["tblname"] = @tblname
		  @tbldata["tblid"] = @tblid
		  @tbldata["trngantts_id"] = @gantt["trngantts_id"]
		  @tbldata["itms_id"] = @gantt["itms_id_trn"]
		  @tbldata["processseq"] = @gantt["processseq_trn"]  
		  @mkprdpurords_id = (params["mkprdpurords_id"]||=0)
		
		  @opeitm = params["opeitm"]  ###tbldataのopeitmsの情報
		  @str_duedate = case @tblname
			  when /purdlvs|custdlvs/
				  "depdate"
			  when /^puracts/
				  "rcptdate"
			  when /^prdacts/
				  "cmpldate"
			  when /^custacts/
				  "saledate"
			  when /rets/
				  "retdate"
			  when /reply/
				  "replydate"
			  else
				  "duedate"
			  end  
      @str_starttime = case @tblname
          when /purdlvs|custdlvs/
            "depdate"
          when /^puracts/
            "rcptdate"
          when /^prdacts/
            "cmpldate"
          when /^custacts/
            "saledate"
          when /rets/
            "retdate"
          when /reply/
            "replydate"
          else
            "starttime"
          end  
		  @str_qty = case @tblname
			  when /acts$|rets$|purdlvs$|custdlvs$|custinsts$/
				  "qty_stk"
			  when /schs$/
				  "qty_sch"
			  else
				  "qty"
			  end
      if @tblname =~ /^cust/
        str_shelfnos = "sio.#{@tblname.chop}_shelfno_id_fm shelfnos_id_fm"
        @str_shelfnos_id = "shelfnos_id_fm"
      else
        str_shelfnos = "sio.#{@tblname.chop}_shelfno_id_to shelfnos_id_to"
        @str_shelfnos_id = "shelfnos_id_to"
      end

		  if @tblname =~ /^prd|^pur|^cust/ and @tblname =~ /schs$|ords$|insts$|reply|dlvs$|acts$|rets$/ and
        params["aud"] =~ /edit|update|purge|delete/
			  ### viewはr_xxxxxxsのみ
			  
			  strsql = %Q&---最後に登録・修正されたレコード
				    select 	ope.itms_id itms_id,ope.processseq processseq,
					    sio.#{@tblname.chop}_prjno_id prjnos_id,
					    sio.#{@tblname.chop}_#{@str_starttime} starttime,
              sio.#{@tblname.chop}_#{@str_duedate} duedate,
					    sio.#{@tblname.chop}_#{@str_qty} #{@str_qty},
              #{str_shelfnos},sio.*
					  from sio.sio_r_#{@tblname} sio
					  inner join opeitms ope on ope.id = sio.#{@tblname.chop}_opeitm_id
					  where sio.id = #{@tblid} 
					  and sio.#{@tblname.chop}_updated_at < cast('#{@tbldata["updated_at"]}' as timestamp)
					  order by sio_id desc limit 1
			      &
	  	  @last_rec = ActiveRecord::Base.connection.select_one(strsql)
	  	  @last_rec ||= {}
		    @last_rec["tblname"] = @tblname
		    @last_rec["tblid"] = @tblid
      else
        @last_rec = {}
		  end
		  @chng_flg = "" 
      ### 登録　変更用にファイルをわける
      check_shelfnos_duedate_qty() if params["aud"] =~ /edit|update|purge|delete/  ###
	  end

    def proc_opeParams
        @reqparams
    end

	  def last_rec
		  @last_rec
	  end

    def chng_flg
      @chng_flg
    end

	  ###------------------------------------------------------
	  def proc_trngantts()  ###schs,ords専用
		  ###
		  if @reqparams["classname"] =~ /_insert_|_add_/  ###trngantts 追加
			  if (@tblid == @paretblid and @tblname == @paretblname and @tblid == @orgtblid and @tblname == @orgtblname) 
				  ###schs$,ords$--->新規本体を作成  ^pur,^prd 
				  last_lotstks = init_trngantts_add_detail()
			  else ###構成の一部になっているとき(本体を作成後確認)
				  last_lotstks =  child_trngantts()  
			  end	
		  else ###変更　(削除 qty_sch=qty=qty_stk=0 　を含む) purschs,purords,prdschs,prdords
			  return if @gantt.nil?
        last_lotstks = []
			  check_shelfnos_duedate_qty()  ###
			  return  if @chng_flg == ""
			  ###数量・納期・場所の変更があった時
			  case @tblname
			  when /schs$|ords$/  ###topのみ schsの修正はganttchartから
				  strsql = %Q% 
						select * from trngantts where tblname = '#{@tblname}' and tblid = #{@tblid}
						  and orgtblname = paretblname and paretblname = tblname
						  and orgtblid = paretblid and paretblid = tblid
						%
			  else
				  return
			  end
			  top_trngantt = ActiveRecord::Base.connection.select_one(strsql)
			  if top_trngantt.nil?
				  return 
			  end
			  @trngantts_id =  @gantt["trngantts_id"]  = @last_rec["trngantts_id"] = top_trngantt["id"]
			  ### qty,qty_stkはqty_linkto_alloctbl以下にはできない。
			  ###出庫指示数以下にはできない。
			  ###locas_idの変更は不可(オンライン、入り口でチェック) 
			  ###前の在庫　をzeroに
			  ###  xxxschsはtop以外修正できない trnganttsの値を修正

			  ###新shelfnos_id_fmで出庫・消費を作成(数量増の変更で対応)
			  ###数量又は納期の変更があった時   xxxsxhs,xxxordsの時のみ
			  ###
			  ### 
				  ###数量の変更があるときはalloctblsも修正する。
          if @chng_flg =~ /qty/ 
            if  @tblname =~ /^prdschs|^purschs/
				      ###schsが減されfreeのordsが発生。xxxschsがtopの時のみ変更可能
              strsql = %Q&
                 update trngantts set   --- xxschs,xxxordsが変更された時のみ
                   updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
                   #{@str_qty.to_s} = #{@tbldata[@str_qty]},
                   remark = '#{self}  line:#{__LINE__}'||left(remark,3000),
                   prjnos_id = #{@tbldata["prjnos_id"]},duedate_trn = '#{@tbldata[@str_duedate]}',
                   shelfnos_id_to_trn = #{@tbldata["shelfnos_id_to"]}"
                   where  id = #{@trngantts_id} &
              ActiveRecord::Base.connection.update(strsql) 
              ###lotstkhistsの変更本体のみ
					    strsql = %Q&  ---alloctblsはrorblkvtlで更新済
								select alloc.* from alloctbls alloc
										where alloc.srctblname = '#{@tblname}' and alloc.srctblid = #{@tblid}
										and trngantts_id = #{@trngantts_id}
							  &
					    base_alloc = ActiveRecord::Base.connection.select_one(strsql)
					    alloctbls_id ,last_lotstk = base_sch_alloc_update(base_alloc)  
              last_lotstks << last_lotstk
            end
          else
            if @chng_flg =~ /due|shelfno/
				        ###shp,conの変更 callされるのはschs,ordsの時のみ
                last_lotstks << {"tblname" => @tblname,"tblid" => @tblid,"qty_src" => - @last_rec[@str_qty],"set_f" => true,"rec" => @last_rec}
                last_lotstks << {"tblname" => @tblname,"tblid" => @tblid,"qty_src" =>  @tbldata[@str_qty]}
            end
          end
					  ###schsが減された時:ords,insts,actsをfreeに　qty_schが増、減されたときshp,conの変更、###在庫の処理を含む
					  ###trnganttsは修正済  alloctblsは一件のみ
          if @tblname =~ /^prd/ 
              if (@tbldata["qty_sch"].to_f  == 0 or @chng_flg =~ /due/)   
                ActiveRecord::Base.connection.select_all(ArelCtl.proc_apparatus_sql(@tbldata["opeitms_id"])).each do |apparatus|
                  @reqparams["apparatus"] = apparatus
                  ope = Operation::OpeClass.new(@reqparams)  ###prdinsts,prdacts
                  ope.proc_delete_dvs_data
                  ope.proc_delete_erc_data
                end
              end
              if (@tbldata["qty_sch"].to_f  > 0 and  @chng_flg =~ /due/)   
                ActiveRecord::Base.connection.select_all(strsql).each_with_index do |apparatus,idx|
                  if idx == 0
                    schsParams = @reqparams.dup
                    schsParams["gantt"] =  ActiveRecord::Base.connection.select_one(%Q&
                                            select key ,
						                                      orgtblname,orgtblid,tblname paretblname,tblid paretblid,
						                                      tblname,tblid,mlevel,shuffle_flg,parenum,chilnum,qty_sch,qty,qty_stk,
                                                  qty_require,qty_pare,qty_sch_pare,qty_handover,prjnos_id,shelfnos_id_to_trn,
                                                  shelfnos_id_to_pare,itms_id_trn,processseq_trn,shelfnos_id_trn,
                                                  itms_id_pare,processseq_pare,shelfnos_id_pare,
                                                  itms_id_org,processseq_org,shelfnos_id_org,consumunitqty,consumminqty,
                                                  consumchgoverqty,starttime_trn,starttime_pare,starttime_org,duedate_trn,
                                                  duedate_pare,duedate_org,toduedate_trn,toduedate_pare,toduedate_org,consumtype,
                                                  chrgs_id_trn,chrgs_id_pare,chrgs_id_org 
                                                  from trngantts 
                                                  where tblname = 'prdschs' and tblid = #{link["prev_tblid"]}
                                          &)
                    schsParams["tbldata"] =  ActiveRecord::Base.connection.select_one(%Q&
                                    select * from #{link["prev_tblname"]} where id = #{link["prev_tblid"]}
                                &)
                  end
                  schsParams["gantt"]["key"] = schsParams["gantt"]["key"] + format('%05d', idx)
                  schParams["apparatus"] = apparatus
                  ope = Operation::OpeClass.new(schParams)  ###prdinsts,prdacts
                  ope.proc_add_dvs_data apparatus  ###target:current table
                  ope.proc_add_erc_data apparatus
                end
              end
          end
				  if @tblname =~ /purords$|prdords$/ and  @chng_flg != ""
            ###既に引き当てられている数以下にはできない。画面でチェック済
            if @chng_flg =~ /qty/
					    last_lotstks_parts = change_alloc_last() 			  ###linktblsとlink先のalloctblの変更
              last_lotstks.concat last_lotstks_parts
            else
              if @chng_flg =~ /due|shelfno/
                  ###shp,conの変更 callされるのはschs,ordsの時のみ
                  last_lotstks << {"tblname" => @tblname,"tblid" => @tblid,"qty_src" => - @last_rec[@str_qty],"set_f" => true,"rec" => @last_rec}
                  last_lotstks << {"tblname" => @tblname,"tblid" => @tblid,"qty_src" =>  @tbldata[@str_qty]}
              end
            end
            ### 消費、出庫の取り消し
            last_lotstks_parts = Shipment.proc_update_consume(@tblname,@tbldata,@last_rec,true)
            last_lotstks.concat last_lotstks_parts
            last_lotstks_parts = Shipment.proc_delete_shpxxxsby_parent @tblname,@tblid
            last_lotstks.concat last_lotstks_parts
            if @tbldata[@str_qty].to_f > 0
              ActiveRecord::Base.connection.select_all(ArelCtl.proc_ChildConSql(@tbldata)).each do |conord|
                dupParams = @reqparams.dup
                dupParams["child"] = conord.dup
                dupParams["parent"] = @tbldata.dup
                dupParams["parent"]["trngantts_id"] = @gantt["trngantts_id"]  ### shpxxxs,conxxxsのtrngantts_idは親のtrngantts_id
                dupParams["screenCode"] = "r_conords"
                last_lotstks <<  Shipment.proc_create_consume(dupParams)
                ###
                last_lotstks_parts = Shipment.proc_create_shpxxxs(dupParams) do
                  "shpsch"
                end
                last_lotstks.concat last_lotstks_parts
              end 
            end
          end
          if @tblname =~ /^dvs|^erc/
            if @reqparams["classname"] =~ /_purge_|_delete_/
                strsql = %Q&
                            select * from linktbls where tblname = '#{@tblname}' and tblid = #{@tblid}
                &
                ActiveRecord::Base.connection.select_all(strsql).each do |link|
                  strdelsql = %Q&
                            delete from trngantts where id =#{link["id"]}
                  &
                  ActiveRecord::Base.connection.delete(strdelsql)
                end
                strsql = %Q&
                            select * from alloctbls where srctblname = '#{@tblname}' and srctblid = #{@tblid}
                &
                ActiveRecord::Base.connection.select_all(strsql).each do |alloc|
                  strdelsql = %Q&
                            delete from trngantts where id =#{alloc["id"]}
                  &
                  ActiveRecord::Base.connection.delete(strdelsql)
                end
                strsql = %Q&
                            select * from trngantts where tblname = '#{@tblname}' and tblid = #{@tblid}
                &
                ActiveRecord::Base.connection.select_all(strsql).each do |trn|
                  strdelsql = %Q&
                            delete from trngantts where id =#{trn["id"]}
                  &
                  ActiveRecord::Base.connection.delete(strdelsql)
                end
            end
          end
				  if @tblname =~ /^custords/
			      strsql = %Q&
			 			  update trngantts set   --- xxschs,xxxordsが変更された時のみ
			 				  updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
			 				  #{@str_qty.to_s} = #{@tbldata[@str_qty]},
			 				  remark = '#{self}  line:#{__LINE__} '|left(|remark,3000),
			 				  prjnos_id = #{@tbldata["prjnos_id"]},duedate_trn = '#{@tbldata[@str_duedate]}'
			 				  where  id = #{@trngantts_id} &
		    	  ActiveRecord::Base.connection.update(strsql) 
				 	  qty =  @tbldata[@str_qty].to_f
				 	  strsql = %Q&
				 			select * from linkcusts where tblname = 'custords' and tblid = #{@tblid}
													and srctblname = 'custschs' 
				 	    &
				 	  links = ActiveRecord::Base.connection.select_all(strsql)
					  if links.to_ary.size > 0    ###custschs引当
				 		  if qty < link["qty_src"].to_f
				 			  update_sql = %Q&
				 				  update linkcusts 
				 					set qty_src = #{qty},remark = ' #{self} line:#{__LINE__} '||remark
				 					where id = #{link["id"]}
				 			    &
				 			  ActiveRecord::Base.connection.update(update_sql)
							  rcv_qty = qty
							  qty = 0
				 		  else
							  rcv_qty = link["qty_src"]
				 			  qty -= link["qty_src"].to_f
				 		  end
						  custschs_rcv_sql = %Q&
							  update linkcusts 
								  set qty_src = qty_src + #{rcv_qty},remark = ' #{self} line:#{__LINE__} '||remark
								    where tblname = 'custschs' and srctblname = 'custschs'
								    and tblid = #{link["srctblid"]} and srctblid = #{link["srctblid"]}
						 	    &
						  ActiveRecord::Base.connection.update(custschs_rcv_sql)
						  return 
					  else  ###paretblname=custords,tblname=prd,pur
						  strsql = %Q% 
									select * from trngantts where paretblname = '#{@tblname}' and paretblid = #{@tblid}
					  							and orgtblname = paretblname and paretblname != tblname
					  							and orgtblid = paretblid 
                          and tblname in ('prdschs','purschs') 
								%
						  top_trngantt = ActiveRecord::Base.connection.select_one(strsql)
						  strsql = %Q&
									 update trngantts set   --- 
										 updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
										 qty_pare = #{@tbldata[@str_qty]},
										 remark = '#{self}  line:#{__LINE__}'||remark
										 where  id = #{top_trngantt["id"]} &
						  ActiveRecord::Base.connection.update(strsql) 
						  ### custordsの直下prdschs,purschsの修正
						  trn = {"tblname" => top_trngantt["tblname"],"tblid" => top_trngantt["tblid"],
								"pare_qty" =>  @tbldata[@str_qty],"qty" => 0,"qty_stk" => 0,
								"chilnum" => 1,"parenum" => 1,"consumunitqty" => 0,
								"consumminqty" => 0,"consumchgoverqty" => 0,
								"itms_id" => top_trngantt["itms_id_trn"],"processseq" => top_trngantt["processseq_trn"],
								"duration" => 0,"durationfacility" => 0,"packqtyfacility" => 0}
						  update_prdpur_child(trn)
				 	  end
				  end
			  ###下位の構成変更  
			  ###if top_trngantt["mlevel"].to_i  == 0
				lowlevel_gantts = []
				lowlevel_gantts[0] = top_trngantt
				until lowlevel_gantts.empty?
					lgantt = lowlevel_gantts.shift
					trns = ActiveRecord::Base.connection.select_all(ArelCtl.proc_pareChildTrnsSql(lgantt))
					trns.each do |trn|
						update_prdpur_child(trn) ###custxxxs,prdxxxxs,purxxxsが対象
						lowlevel_gantts << trn
					end
				end
      end
		  return last_lotstks
	  end
	  ###--------------------------------------------------------------------------------------------
  	###linktblsの追加はRorBlkctlで完了済のこと。
	  def proc_link_lotstkhists_update()  ###
	
	  end
    ###
    # consume schs,ords,insts,acts
    #### 
	  def proc_consume_by_parent()  ### target ==> all children 
		  return if @gantt["stktaking_proc"] != "1"
      last_lotstks = []
		  ###if @reqparams["classname"] =~ /_insert_|_add_/  ###trngantts 追加
			  base = {}
        base["shelfnos_id"] =  @tbldata["shelfnos_id"]
        case @tblname
			  when /^purdlvs/  ###packnoはない
				  base["starttime"] = (@tbldata["depdate"].to_time + 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				  base["qty"] = @tbldata["qty_stk"]
				  base["remark"] = "#{self}  line #{__LINE__}"
			  when /^prdords|^purords/
					base["starttime"] = @tbldata["duedate"]
					base["qty"]  = @tbldata["qty"]
				  base["remark"] = "#{self}  line #{__LINE__} purords,prdords"
			  when /^prdacts/
				  ### trngantts.qty_stkの変更
				  ### qtyはxxxords作成時又は引当時に変更済
				  ### insts,replyints,instsではtrngantts.qtyは変化しない。
				  base["starttime"] = @tbldata["cmpldate"]
				  base["qty_stk"]  = base["qty_real"]  = @tbldata["qty_stk"]
				  base["remark"] = "#{self}  line #{__LINE__} prdacts"
			  when /^puracts/
				  base["shelfnos_id"] =  @tbldata["shelfnos_id_to"]
				  base["starttime"] = @tbldata["rcptdate"]
				  base["qty_stk"]  = base["qty_real"]  = @tbldata["qty_stk"]
				  base["remark"] = "#{self}  line #{__LINE__} puracts"
			  when /insts|replyinputs/
				  base["starttime"] = @tbldata["duedate"]
				  base["qty"]  = @tbldata["qty"]
				  base["remark"] = "Operation line #{__LINE__}   xxxinsts"
			  when /schs/
				  base["starttime"] = @tbldata["duedate"]
				  base["qty_sch"]  = @tbldata["qty_sch"]
				  base["remark"] = "#{self}  line #{__LINE__}  xxxschs"
			  end	
				  # base = Shipment.proc_lotstkhists_in_out(inout,base)  ###
				  # Shipment.proc_alloc_change_inoutlotstk(base)
				case @tblname
				when /^prdacts|^purdlvs/
					  ActiveRecord::Base.connection.select_all(ArelCtl.proc_ChildConSql(@tbldata)).each do |conact|
						  next if conact["consumauto"] == "M"  ### qty_stk確定時の消費手動は除く
						  dupParams = @reqparams.dup
						  dupParams["child"] = conact.dup
						  dupParams["parent"] = @tbldata.dup
						  dupParams["parent"]["trngantts_id"] = @gantt["trngantts_id"]  ### shpxxxs,conxxxsのtrngantts_idは親のtrngantts_id
              dupParams["screenCode"] = "r_conacts"
						  last_lotstks << Shipment.proc_create_consume(dupParams)
					  end
				when /^puracts/
					  strsql = %Q&
								select * from linktbls link where tblname = '#{@gantt["tblname"]}' and tblid = #{@gantt["tblid"]}
															and srctblname != 'purdlvs' and qty_src > 0
					  & 
					  ActiveRecord::Base.connection.select_all(strsql).each do |notdlv| 
						  ActiveRecord::Base.connection.select_all(ArelCtl.proc_ChildConSql(@tbldata)).each do |conord|
							  next if conord["consumauto"] == "M"  ### qty_stk確定時の消費手動は除く
							  dupParams = @reqparams.dup
							  dupParams["child"] = conord.dup
							  dupParams["parent"] = @tbldata.dup
							  dupParams["parent"]["trngantts_id"] = @gantt["trngantts_id"]  ### shpxxxs,conxxxsのtrngantts_idは親のtrngantts_id
                dupParams["screenCode"] = "r_conacts"
							  last_lotstks << Shipment.proc_create_consume(dupParams)  ###one child
						  end
					  end
				when /purinsts$|purreplyinputs$|prdinsts$/
					  ActiveRecord::Base.connection.select_all(ArelCtl.proc_ChildConSql(@tbldata)).each do |conord|
						  dupParams = @reqparams.dup
						  dupParams["child"] = conord.dup
						  dupParams["parent"] = @tbldata.dup
						  dupParams["parent"]["trngantts_id"] = @gantt["trngantts_id"]  ### shpxxxs,conxxxsのtrngantts_idは親のtrngantts_id
              dupParams["screenCode"] = "r_conords"
						  last_lotstks << Shipment.proc_create_consume(dupParams)
					  end
					  strsql = %Q%
						  select srctblname,srctblid,qty_src from linktbls where tblname = '#{@tblname}' and tblid = #{@tblid}
					    %
					  ActiveRecord::Base.connection.select_all(strsql).each do |srctbl|
						  prevparetbl = ActiveRecord::Base.connection.select_one(%Q%select * from #{srctbl["srctblname"]} where id = #{srctbl["srctblid"]} %)
						  prevparetbl["tblname"] = srctbl["srctblname"]
						  prevparetbl["tblid"] = srctbl["srctblid"]
						  prevparetbl["qty"] = srctbl["qty_src"] * -1
						  prevchildsql = %Q%
									select nd.* from nditms nd 
											inner join opeitms ope on ope.id = nd.opeitms_id
										where ope.itms_id = #{prevparetbl["opeitms_id"]}
                %
						  ActiveRecord::Base.connection.select_all(prevchildsql).each do |prevchildtbl|
							  prevParams = @reqparams.dup
							  prevParams["parent"] = prevparetbl.dup
							  prevParams["child"] = prevchildtbl.dup
							  dupParams["parent"]["trngantts_id"] = @gantt["trngantts_id"]  ### shpxxxs,conxxxsのtrngantts_idは親のtrngantts_id
                dupParams["screenCode"] = "r_conords"
							  last_lotstks << Shipment.proc_create_consume(prevParams)
						  end
					  end
				when /purords$|prdords$/
					  ActiveRecord::Base.connection.select_all(ArelCtl.proc_ChildConSql(@tbldata)).each do |conord|
						  dupParams = @reqparams.dup
						  dupParams["child"] = conord.dup
						  dupParams["parent"] = @tbldata.dup
						  dupParams["parent"]["trngantts_id"] = @gantt["trngantts_id"]  ### shpxxxs,conxxxsのtrngantts_idは親のtrngantts_id
              dupParams["screenCode"] = "r_conords"
						  last_lotstks <<  Shipment.proc_create_consume(dupParams)
					  end
        end
			# 	end
		  # else ###変更　(削除 qty_sch=qty=qty_stk=0 　を含む) 
			#   lastStkinout = {"tblname" => @tblname,"tblid" => @tblid,
      #                 "srctblname" => @tblname,"srctblid" => @tblid,
      #                 "itms_id" => @last_rec["itms_id"] ,"processseq" => @last_rec["processseq"] ,
      #                 "shelfnos_id" => @last_rec["shelfnos_id_to"],  ###shpxxx,custxxxでは個別の設定が必要
      #                 "prjnos_id" => @last_rec["prjnos_id"] ,
      #                 "starttime" => @last_rec["duedate"],"packno" => (@last_rec["packno"]||=""),"lotno" => (@last_rec["lotno"]||=""),
      #                 "lotstkhists_id" => "","trngantts_id" => "","alloctbls_id" => "",
      #                 "qty_src" => 0,"amt_src" => 0,"qty_linkto_alloctbl" => 0,
      #                 "person_id_upd" => @tbldata["persons_id_upd"],"persons_id_upd" => @tbldata["persons_id_upd"],
      #                 "qty_sch" => @last_rec["qty_sch"].to_f,"qty" =>@last_rec["qty"].to_f,"qty_stk" => @last_rec["qty_stk"].to_f,
      #                 "qty_real" => @last_rec["qty_stk"].to_f}	  ###last_rec:view type
			#   stkinout = {}
			#   stkinout = @tbldata.dup
			#   lastStkinout["trngantts_id"] = stkinout["trngantts_id"] = @gantt["trngantts_id"]
			#   case @tblname
			#   # when /^cust/
				#   ###社内倉庫の更新
				#   lastStkinout["shelfnos_id"] =  @last_rec["#{@tblname.chop}_shelfno_id_fm"]
				#   lastStkinout["prjnos_id"] =  @last_rec["#{@tblname.chop}_prjno_id"]

				#   stkinout["srctblname"] = lastStkinout["srctblname"] = "lotstkhists"
				#   case @tblname 
				#   when  "custacts" 
				# 	  lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_saledate"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				# 	  lastStkinout = Shipment.proc_lotstkhists_in_out("in",lastStkinout)  ###前の在庫の更新　一旦全数削除
				# 	  stkinout["shelfnos_id"] = @tbldata["shelfnos_id_fm"]
				# 	  stkinout["starttime"] = (@tbldata["saledate"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				#   when "custrets"
				# 	  lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_retdate"].to_time + 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  
				# 	  lastStkinout[@str_qty] = lastStkinout[@str_qty] * -1   ###retのみ例外
				# 	  lastStkinout = Shipment.proc_lotstkhists_in_out("in",lastStkinout)  ###前の在庫の更新　
				# 	  stkinout["starttime"] = (@tbldata["retdate"].to_time + 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  
				# 	  ### 例外
				# 	  inout = "in"
				#   when "custdlvs"  
				# 	  lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_depdate"].to_time ).strftime("%Y-%m-%d %H:%M:%S")  
				# 	  lastStkinout = Shipment.proc_lotstkhists_in_out("in",lastStkinout)  ###前の在庫の更新　
				# 	  stkinout["starttime"] = (@tbldata["depdate"].to_time ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				#   else  
				# 	  lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_duedate"].to_time - 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  
				# 	  lastStkinout = Shipment.proc_lotstkhists_in_out("in",lastStkinout)  ###前の在庫の更新　
				# 	  stkinout["starttime"] = (@tbldata["duedate"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				#   end
				#   if stkinout[@str_qty].to_f > 0
				# 	  stkinout["shelfnos_id"] =  @tbldata["shelfnos_id_fm"]
				# 	  stkinout = Shipment.proc_lotstkhists_in_out("out",stkinout)  ###在庫の更新
				#   end
				#   # Shipment.proc_alloc_change_inoutlotstk(stkinout)
				#   ###客先倉庫の更新
				#   stkinout["custrcvplcs_id"] = @tbldata["custrcvplcs_id"]
				#   lastStkinout["custrcvplcs_id"] = @last_rec["#{@tblname.chop}_custrcvplc_id"]  
				#   stkinout["remark"] = " #{self}  line #{__LINE__} "
				#   stkinout["srctblname"] = "custwhs"
				#   inout = "in" 
				#   case @tblname 
				#   when  "custacts"
				# 	  lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_saledate"].to_time ).strftime("%Y-%m-%d %H:%M:%S")  #
				# 	  stkinout["starttime"] = (@tbldata["saledate"].to_time ).strftime("%Y-%m-%d %H:%M:%S")  #
				#   when "custrets"  ###packnoはない
				# 	  lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_retdate"].to_time - 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				# 	  lastStkinout[@str_qty] = lastStkinout[@str_qty] * -1   ###retのみ例外
				# 	  stkinout["starttime"] = (@tbldata["retdate"].to_time - 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				# 	  ###例外
				# 	  inout = "out" 
				#   when "custdlvs"  ###packnoはない
				# 	  lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_dlvdate"].to_time + 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				# 	  stkinout["starttime"] = (@tbldata["dlvdate"].to_time + 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				#   else
				# 	  stkinout["starttime"] = (@tbldata["duedate"].to_time).strftime("%Y-%m-%d %H:%M:%S")  
				#   end
				#   if stkinout[@str_qty].to_f > 0
				# #  	  stkinout["shelfnos_id"] =  @tbldata["shelfnos_id_fm"]
				# # 	  lastStkinout = Shipment.proc_mk_custwhs_rec(inout,stkinout)
				# #   end
				# #   lastStkinout = Shipment.proc_mk_custwhs_rec("out",lastStkinout)
			  # when /^purdlvs/  ###packnoはない
				#   lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_depdate"].to_time + 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				#   lastStkinout = Shipment.proc_lotstkhists_in_out("out",lastStkinout)  ###在庫の更新
				#   lastStkinout["shelfnos_id"] =  @last_rec["#{@tblname.chop}_shelfno_id_fm"]
				#   lastStkinout["starttime"] = @last_rec["#{@tblname.chop}_depdate"] ###カレンダー考慮要
				#   lastStkinout["suppliers_id"] = @last_rec["#{@tblname.chop}_suppler_id"]
				#   Shipment.proc_mk_supplierwhs_rec("in",lastStkinout)
				#   if stkinout[@str_qty].to_f > 0
				# 	  stkinout["starttime"] = (@tbldata["depdate"].to_time + 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				# 	  stkinout = Shipment.proc_lotstkhists_in_out("in",stkinout)  ###在庫の更新
				# 	  stkinout["shelfnos_id"] =  @tbldata["shelfnos_id_fm"]
				# 	  stkinout["starttime"] = @tbldata["depdate"] ###カレンダー考慮要
				# 	  stkinout["suppliers_id"] = @tbldata["supplers_id"]
				# 	  Shipment.proc_mk_supplierwhs_rec("out",stkinout)
				#     # Shipment.proc_alloc_change_inoutlotstk(stkinout)
				#   end
			  # when /^prdords|^purords/  ### operation.change_alloc_lastで実施
				#   # stkinout = Shipment.proc_lotstkhists_in_out("out",lastStkinout)  ###在庫の更新
				#   # if stkinout[@str_qty].to_f > 0
				# 	#   stkinout = Shipment.proc_lotstkhists_in_out("in",stkinout)  ###在庫の更新
				#   # end
        #   ###
        #   # 数量減の時元の引当在庫に戻す
        #   ###
        #   # del_qty = lastStkinout[@str_qty].to_f - stkinout[@str_qty].to_f
        #   # if del_qty > 0
        #   #   last_lotstks << {"tblname" => @tblname,"tblid" => @tblid,"qty_src" => del_qty * -1}
        #   #   strsql = %Q&
        #   #           select a.srctblname,a.srctblid,t.duedate_trn,a.qty_linkto_alloctbl qty_alloc,a.id alloc_id ,a.trngantts_id
        #   #               from alloctbls a 
        #   #                 inner join trngantts t on t.id = a.trngantts_id
        #   #                 inner join linktbls l on l.tblname = a.srctblname and l.tblid = a.srctblid
        #   #                                       and a.trngantts_id = l.trngantts_id  
        #   #               where l.tblname = '#{@tblname}' and l.tblid = #{@tblid}
        #   #               and l.qty_src > 0 and a.qty_linkto_alloctbl > 0
        #   #               order by t.duedate_trn desc
        #   #         &
				#   #   ActiveRecord::Base.connection.select_all(strsql).each do |link|
        #   #     if del_qty > link["qty_alloc"].to_f
        #   #       update_allosql = %Q&
        #   #                       update alloctbls alloc set qty_linkto_alloctbl = 0
        #   #                           where id = #{link["alloc_id"]}
        #   #       &
        #   #       update_trn = %Q&
        #   #                       update trngantts  set qty  = qty - #{link["qty_alloc"]}
        #   #                           where id = #{link["trngantts_id"]}
        #   #       &
        #   #       update_link = %Q&
        #   #                       update linktbls  set qty_src  = qty_src - #{link["qty_alloc"]}
        #   #                           where trngantts_id = #{link["trngantts_id"]}
        #   #                           and tblname = '#{@tblname}' and tblid = #{@tblid}
        #   #       &
        #   #       del_qty -= link["qty_alloc"].to_f
        #   #     else
        #   #       update_allocsql = %Q&
        #   #                       update alloctbls alloc set qty_linkto_alloctbl = qty_linkto_alloctbl - #{del_qty}
        #   #                           where id = #{link["alloc_id"]}
        #   #       &
        #   #       update_trn = %Q&
        #   #                       update trngantts  set qty  = qty - #{del_qty}
        #   #                           where id = #{link["trngantts_id"]}
        #   #       &
        #   #       update_link = %Q&
        #   #                       update linktbls  set qty_src  = qty_src - #{del_qty}
        #   #                           where trngantts_id = #{link["trngantts_id"]}
        #   #                           and tblname = '#{@tblname}' and tblid = #{@tblid}
        #   #       &
        #   #       del_qty = 0
        #   #     end
        #   #     ActiveRecord::Base.connection.update(update_allocsql)
        #   #     ActiveRecord::Base.connection.update(update_trn)
        #   #     ActiveRecord::Base.connection.update(update_link)
        #   #     break if del_qty == 0
        #   #   end
			  #   # end
			  # when /^prschs|^purschs/
				#   # stkinout = Shipment.proc_lotstkhists_in_out("out",lastStkinout)  ###在庫の更新
				#   # if stkinout[@str_qty].to_f > 0
				# 	#   stkinout = Shipment.proc_lotstkhists_in_out("in",stkinout)  ###在庫の更新
				#   # end
        #   ###
		    # end
      ##end
		  return 	last_lotstks
	  end
      
	  def update_prdpur_child(trn)
		  cParams = @reqparams.dup
		  cParams[:screenCode] = "r_" + trn["tblname"]
		  strsql = %Q&
				select * from r_#{trn["tblname"]} where id = #{trn["tblid"]}
		    &
		  rec = ActiveRecord::Base.connection.select_one(strsql)
		  child_blk = RorBlkCtl::BlkClass.new(cParams[:screenCode])
		  command_c = child_blk.command_init
		  command_c.merge!rec 
		  command_c["sio_classname"] = "_update_#{trn["tblname"]}_update_prdpur_child"
		  command_c["#{trn["tblname"].chop}_remark"] = " #{self} line:(#{__LINE__}) "
		  if trn["pare_qty"].to_f == 0
			  command_c["#{trn["tblname"].chop}_qty_sch"] = 0
		  else
			  qty_require = CtlFields.proc_cal_qty_sch(trn["pare_qty"],trn["chilnum"],trn["parenum"],trn["consumunitqty"],
												trn["consumminqty"],trn["consumchgoverqty"])
			  if qty_require > (trn["qty"].to_f + trn["qty_stk"].to_f)
				  command_c["#{trn["tblname"].chop}_qty_sch"]  = qty_require - (trn["qty"].to_f + trn["qty_stk"].to_f)
			  else
				  command_c["#{trn["tblname"].chop}_qty_sch"]  = 0
			  end
		  end
		  if trn["tblname"] =~ /^pur/
			  command_c,err = CtlFields.proc_judge_check_supplierprice(command_c.symbolize_keys,"",0,"r_purschs") 
			  command_c = command_c.stringify_keys
		  end
		  if @chng_flg =~ /due|shelfno/
			  parent = {"duedate"=>@gantt["duedate_pare"],"starttime"=>@gantt["starttime_trn"]}
			  command_c = CtlFields.proc_field_starttime(trn["tblname"].chop,command_c,parent,trn)
		  end
		  @gantt["tblname"] = trn["tblname"]
		  @gantt["tblid"] = trn["tblid"]
		  @gantt["mlevel"] = trn["mlevel"]
		  child_blk.proc_create_tbldata(command_c)
		  child_blk.proc_private_aud_rec(cParams,command_c)
		  @gantt["paretblname"] = trn["tblname"]
		  @gantt["paretblid"] = trn["tblid"]
		  @reqparams["gantt"] = @gantt.dup
	  end
	
	  def check_shelfnos_duedate_qty
		  if @tbldata[@str_qty].to_f != @last_rec[@str_qty].to_f  
			 @chng_flg << "qty"
		  end
		  if @tbldata[@str_duedate] != @last_rec["duedate"]
			  @chng_flg << "due"
		  end
		  if @tbldata["prjnos_id"] != @last_rec["prjno_id"]
			  @chng_flg << "prjnos_id"
		  end
		  case @tblname
		  when /^pur/
			  if @tbldata["suppliers_id"] != @last_rec["#{@tblname.chop}_supplier_id"]
				  @chng_flg << "shelfno"
				  strsql = %Q&
							select s.id from shelfnos s 
										inner join  suppliers supplier on supplier.locas_id_supplier = s.locas_id_shelfno
																							and supplier.id = #{@tbldata["suppliers_id"]}
										where s.code = '000'												
				    &
				  crr_shelfnos_id = ActiveRecord::Base.connection.select_value(strsql)
				  update_sql = %Q&
							update trngantts set shelfnos_id_trn = #{crr_shelfnos_id},shelfnos_id_to_trn = #{@tbldata["shelfnos_id_to"]}
								where tblname = '#{@tblname}' and tblid = #{@tblid}
					  &
				  ActiveRecord::Base.connection.update(update_sql)
			  else
				  if @tbldata["shelfnos_id_to"] != @last_rec["#{@tblname.chop}_shelfno_id_to"]
					  @chng_flg << "shelfno"
					  update_sql = %Q&
								update trngantts set shelfnos_id_to_trn = #{@tbldata["shelfnos_id_to"]}
									where tblname = '#{@tblname}' and tblid = #{@tblid}
						&
					  ActiveRecord::Base.connection.update(update_sql)
				  end
			  end
		  when /^prd/
			  if @tbldata["shelfnos_id_to"] != @last_rec["#{@tblname.chop}_shelfno_id_to"] or  @tbldata["shelfnos_id"] != @last_rec["#{@tblname.chop}_shelfno_id"]
				  @chng_flg << "shelfno"
				  ###locas_id = ActiveRecord::Base.connection.select_value("select locas_id_shelfno from shelfnos where id = #{@last_rec["#{@tblname.chop}_shelfno_id"]}")
				  update_sql = %Q&
							update trngantts set shelfnos_id_trn = #{@tbldata["shelfnos_id"]},shelfnos_id_to_trn = #{@tbldata["shelfnos_id_to"]}
								where tblname = '#{@tblname}' and tblid = #{@tblid}
					  &
				  ActiveRecord::Base.connection.update(update_sql)
			  end
		  end
		  ###
		  #数量・納期の変更がないときは何もしない。
		  return 
	  end

	  def base_sch_alloc_update(base_alloc)   ###purschs,prdschs
		  ### xxxords:alloctblsの変更 ordsはlinktblsのqty_src以下にはできない。--->画面又は入り口でチェック済であること。
		  ### alloctblsのqty_schの変更はror_blkctlで実施済
		  if @tbldata["qty_sch"].to_f < base_alloc["qty_linkto_alloctbl"].to_f
			  link_strsql = %Q&
				select link.*,alloc.qty_linkto_alloctbl qty_linkto_alloctbl,alloc.id alloctbls_id
					from linktbls link   ---srctblname :xxxxschs
				inner join alloctbls alloc on link.trngantts_id = alloc.trngantts_id
					where trngantts_id = #{@trngantts_id}  ---既にordsからacts等になったtbl　を含む
					and  alloc.qty_linkto_alloctbl > 0
				&
			  qty_sch = @tbldata["qty_sch"].to_f
			  src_link = ActiveRecord::Base.connection.select_one(link_strsql)  ###topでは一対一のはず
			  if qty_sch < src_link["qty_linkto_alloctbl"].to_f   ###ords,insts・・・では　qty < src_link["qty_src"].to_fは不可
				  alloc = {alloc_id => src_link["alloctbls_id"],"qty_linkto_alloctbl" => qty_sch,
					        "remark" => "#{self} line #{__LINE__} #{Time.now}","persons_id_upd" => shp["persons_id_upd"]}
				  alloctbl_id,last_lotstk = ArelCtl.proc_aud_alloctbls(alloc,"update")
          last_lotstks << last_lotstk
			  end
		  else		
			  ###数量増の変更は不可
        last_lotstks = []
		  end
		  return last_lotstks
	  end

	  def change_alloc_last()   ###when /purords$|prdords$/
      ###出庫指示済の時はなにもしない　画面でエラーになっている
        strsql = %Q&
                    select 1 from shpords where paretblname = '#{@tblname}' and paretblid =#{@tblid}
              &
        chk = ActiveRecord::Base.connection.select_value(strsql)
        return [] if chk == "1"
      ###旧在庫削除　＠＠
        last_lotstks = [] ###prd,purxxxxは数量減のみ
			  lastStkinout = {"tblname" => @tblname,"tblid" => @tblid,
                      "srctblname" => @tblname,"srctblid" => @tblid,
                      "itms_id" => @last_rec["itms_id"] ,"processseq" => @last_rec["processseq"] ,
                      "shelfnos_id" => @last_rec["shelfnos_id_to"],  ###shpxxx,custxxxでは個別の設定が必要
                      "prjnos_id" => @last_rec["prjnos_id"] ,
                      "starttime" => @last_rec["duedate"],"packno" => (@last_rec["packno"]||=""),"lotno" => (@last_rec["lotno"]||=""),
                      "person_id_upd" => @tbldata["persons_id_upd"],"persons_id_upd" => @tbldata["persons_id_upd"],
                      "qty_sch" => 0,"qty" =>@last_rec["qty"].to_f,"qty_stk" => 0,"qty_real" => 0}	  ###last_rec:view type
        last_lotstks << {"tblname" => @tblname,"tblid" => @tblid,"qty_src" => @last_rec["qty"].to_f * -1,"set_f" => true,"rec" => lastStkinout}
        ###旧消費取り消し       
        tbldata = @tbldata.dup
        tbldata["qty"] = tbldata["qty_sch"] = 0
        last_lotstks_parts = Shipment.proc_update_consume(@tblname,tbldata,lastStkinout,true)  ###全部取り消し
        last_lotstks.concat last_lotstks_parts
        ###
        ### 引当変更
        del_qty = lastStkinout[@str_qty].to_f - @tbldata[@str_qty].to_f
        if del_qty > 0
          strsql = %Q&   ---schsへの戻し
                  select a.srctblname,a.srctblid,a.qty_linkto_alloctbl qty_alloc,a.id alloc_id ,a.trngantts_id,
                          l.srctblname prev_tblname,l.srctblid prev_tblid
                      from alloctbls a 
                        inner join trngantts t on t.id = a.trngantts_id
                        inner join linktbls l on l.tblname = a.srctblname and l.tblid = a.srctblid
                                              and a.trngantts_id = l.trngantts_id  
                      where l.tblname = '#{@tblname}' and l.tblid = #{@tblid}
                      and  (l.tblname != l.srctblname or l.tblid != l.srctblid)
                      and l.qty_src > 0 and a.qty_linkto_alloctbl > 0
                      order by t.duedate_trn desc
                &
				  ActiveRecord::Base.connection.select_all(strsql).each do |link|
            if del_qty > link["qty_alloc"].to_f
              update_allocsql = %Q&
                              update alloctbls alloc set qty_linkto_alloctbl = 0,
                                  remark =  'class:#{self},line:#{__LINE__},qty_alloc:#{link["qty_alloc"]} '||left(remark,3000)
                                  where id = #{link["alloc_id"]}
              &
              ###旧在庫削除 は＠で実施済
              ###消費の復活はない
              update_trn = %Q&
                              update trngantts  set qty  = qty - #{link["qty_alloc"]},qty_sch  = qty_sch + #{link["qty_alloc"]},
                                  remark =  'class:#{self},line #{__LINE__},qty_alloc:#{link["qty_alloc"]} '||left(remark,3000)
                                  where id = #{link["trngantts_id"]}
              &
              update_link = %Q&
                              update linktbls  set qty_src  = qty_src - #{link["qty_alloc"]},
                                  remark =  'class:#{self},line:#{__LINE__},qty_alloc:#{link["qty_alloc"]}'||left(remark,3000)
                                  where trngantts_id = #{link["trngantts_id"]}
                                  and tblname = '#{@tblname}' and tblid = #{@tblid}
              &
              ###まえの引当復活
              rec_alloc = {"srctblname" => link["prev_tblname"],"srctblid" => link["prev_tblid"],
                            "trngantts_id" => link["trngantts_id"],"qty_linkto_alloctbl" => link["qty_alloc"]}
              ArelCtl.proc_aud_alloctbls(rec_alloc,"update+") 
              last_lotstks << {"tblname" => link["prev_tblname"],"tblid" => link["prev_tblid"],"qty_src" => link["qty_alloc"].to_f}
              del_qty -= link["qty_alloc"].to_f
            else
              update_allocsql = %Q&
                              update alloctbls alloc set qty_linkto_alloctbl = qty_linkto_alloctbl - #{del_qty},
                                  remark =  '#{self} line #{__LINE__} #{Time.now} '||left(remark,3000)
                                  where id = #{link["alloc_id"]}
              &
              ###
              update_trn = %Q&
                              update trngantts  set qty  = qty - #{del_qty},qty_sch  = qty_sch + #{del_qty},
                                  remark =  'class:#{self},line #{__LINE__} #{Time.now} '||left(remark,3000)
                                  where id = #{link["trngantts_id"]}
              &
              update_link = %Q&
                              update linktbls  set qty_src  = qty_src - #{del_qty},
                                  remark =  'class:#{self},line #{__LINE__} #{Time.now} '||left(remark,3000)
                                  where trngantts_id = #{link["trngantts_id"]}
                                  and tblname = '#{@tblname}' and tblid = #{@tblid}
              &
              rec_alloc = {"srctblname" => link["prev_tblname"],"srctblid" => link["prev_tblid"],
                            "remark" =>  "class:#{self},line:#{__LINE__} #{Time.now} ",
                            "trngantts_id" => link["trngantts_id"],"qty_linkto_alloctbl" => del_qty } 
              ArelCtl.proc_aud_alloctbls(rec_alloc,"update+")
              last_lotstks << {"tblname" => link["prev_tblname"],"tblid" => link["prev_tblid"],"qty_src" => del_qty }
              del_qty = 0
            end
            ActiveRecord::Base.connection.update(update_allocsql)
            ActiveRecord::Base.connection.update(update_trn)
            ActiveRecord::Base.connection.update(update_link)
            ###prdschs のdvsschs,ercschs復活
            if link["prev_tblname"] =~ /^prd/ and link["prev_tblname"] != link["srctblname"] and @tbldata[@str_qty].to_f == 0
                ActiveRecord::Base.connection.select_all(ArelCtl.proc_apparatus_sql(@tbldata["opeitms_id"])).each_with_index do |apparatus,idx|
                  if idx == 0
                    schsParams = @reqparams.dup
                    schsParams["gantt"] =  ActiveRecord::Base.connection.select_one(%Q&
                                            select key ,
						                                      orgtblname,orgtblid,tblname paretblname,tblid paretblid,
						                                      tblname,tblid,mlevel,shuffle_flg,parenum,chilnum,qty_sch,qty,qty_stk,
                                                  qty_require,qty_pare,qty_sch_pare,qty_handover,prjnos_id,shelfnos_id_to_trn,
                                                  shelfnos_id_to_pare,itms_id_trn,processseq_trn,shelfnos_id_trn,
                                                  itms_id_pare,processseq_pare,shelfnos_id_pare,
                                                  itms_id_org,processseq_org,shelfnos_id_org,consumunitqty,consumminqty,
                                                  consumchgoverqty,starttime_trn,starttime_pare,starttime_org,duedate_trn,
                                                  duedate_pare,duedate_org,toduedate_trn,toduedate_pare,toduedate_org,consumtype,
                                                  chrgs_id_trn,chrgs_id_pare,chrgs_id_org 
                                                  from trngantts 
                                                  where tblname = 'prdschs' and tblid = #{link["prev_tblid"]}
                                          &)
                    schsParams["tbldata"] =  ActiveRecord::Base.connection.select_one(%Q&
                                    select * from #{link["prev_tblname"]} where id = #{link["prev_tblid"]}
                                &)
                  end
                  schsParams["gantt"]["key"] = schsParams["gantt"]["key"] + format('%05d', idx)
                  ope = Operation::OpeClass.new(schsParams)  ###prdinsts,prdacts
                  ope.proc_add_dvs_data(apparatus)
                  ope.proc_add_erc_data(apparatus)
                end
            end
            break if del_qty == 0
          end          
          if @tbldata["qty"].to_f > 0
            ###在庫の復活、消費の復活   duedate shelfnos_idが変更されている可能性のため
            last_lotstks << {"tblname" => link["srctblname"],"tblid" => link["srctblid"],"qty_src" => link["qty_alloc"].to_f - del_qty}
            last_lotstks_parts = proc_consume_by_parent()
            last_lotstks.concat last_lotstks_parts
          end
          ord_sql =  %Q&  ---xxxords の linktbls　は一件のみ
                          select * from  linktbls  
                                  where  tblname = '#{@tblname}' and tblid = #{@tblid}
                                  and  srctblname = '#{@tblname}' and srctblid = #{@tblid}
                        &
          ord_link = ActiveRecord::Base.connection.select_one(ord_sql)
          update_link = %Q&
                            update linktbls  set qty_src  = #{@tbldata["qty"]},
                                remark =  'class:#{self},line #{__LINE__} #{Time.now} '||left(remark,3000)
                                where  id = #{ord_link["id"]}
            &
          ActiveRecord::Base.connection.update(update_link)
          update_trn = %Q&
                            update trngantts  set qty  = #{@tbldata["qty"]},
                                remark =  'class:#{self},line #{__LINE__} #{Time.now} '||left(remark,3000)
                                where  id = #{ord_link["trngantts_id"]}
            &
          ActiveRecord::Base.connection.update(update_link)
          if del_qty > 0
            update_alloc = %Q&
                            update alloctbls  set qty_linkto_alloctbl  = qty_linkto_alloctbl - #{del_qty},
                                remark =  'class:#{self},line #{__LINE__} #{Time.now} '||left(remark,3000)
                                where  trngantts_id = #{ord_link["trngantts_id"]}  and  srctblname = '#{@tblname}' and srctblid = #{@tblid}
              &
            ActiveRecord::Base.connection.update(update_alloc)
          end
			  end
		    ###
      return last_lotstks
	  end

	  def init_trngantts_add_detail()
		###@src_no = ""
		###トップ登録時org=pare=tbl

		  @trngantts_id = @gantt["id"] = @gantt["trngantts_id"] = ArelCtl.proc_get_nextval("trngantts_seq")
		
		  ###insts,replyinputs,dlvs,replyinputs,acts,retsはtrnganttsは作成しない。
		  last_lotstks = ArelCtl.proc_insert_trngantts(@gantt,@tbldata)  ###@ganttの内容をセット
		  # @reqparams["linktbl_ids"] = [linktbl_id]
		  # @reqparams["alloctbl_ids"] = [alloctbls_id]
		  @reqparams["gantt"] = @gantt.dup
		  case @tblname	
		  when /^purords|^prdords/  ### 単独でxxxordsを画面又はexcelで登録-->mkordinstsを利用してないとき
			  ###free_ordtbl_alloc_to_sch(stkinout)
			  if @mkprdpurords_id == 0 ###mkordinstsの時は子部品展開は対象外
					@reqparams["segment"]  = "mkschs"   ###構成展開
					@reqparams["remark"]  = "#{self}   構成展開"  ###構成展開
					processreqs_id ,@reqparams = ArelCtl.proc_processreqs_add @reqparams
			  end
		  when /^custschs|^custords/
			  @reqparams["segment"]  = "mkprdpurchildFromCustxxxs"   ###構成展開		
			  @reqparams["remark"]  = "#{self}   pur,prd by custschs,ords"  
			  processreqs_id ,@reqparams = ArelCtl.proc_processreqs_add @reqparams
		  end
		  return last_lotstks
	  end

	  def child_trngantts   ###データはxxxschsのデータで追加のみ
		  @gantt["qty"] = @gantt["qty_stk"] = 0   ###schsのみテーブルしかありえないため
		  packqty = if @opeitm["packqty"].to_f == 0 
					1
				 else
					@opeitm["packqty"].to_f
				 end 
		  @gantt["qty_stk"] = 0
		  @gantt["consumunitqty"] = 	if @gantt["consumunitqty"].to_f  == 0
										1
									else
										@gantt["consumunitqty"].to_f
									end
		  ###@gantt["qty_require"] create_other_table_record_job.mkschで対応済
		  ### parenum chilnum
		  @gantt["id"] = @gantt["trngantts_id"]  = @trngantts_id = ArelCtl.proc_get_nextval("trngantts_seq")
		  @gantt["remark"] =  " #{self}  line:#{__LINE__} "
		  @reqparams["gantt"] = @gantt
		  last_lotstks = ArelCtl.proc_insert_trngantts(@gantt,@tbldata)  ###@ganttの内容をセット
		  # @reqparams["linktbl_ids"] = [linktbl_id]
		  # @reqparams["alloctbl_ids"] = [alloctbl_id]

	 	  ###proc_mk_instks_rec stkinout,"add"
		  if @gantt["qty_handover"].to_f  > 0  ### and  @gantt["itms_id_trn"] != "0"  ### dummy @gantt["tblname"] != "dymschs"
			  @reqparams["segment"]  = "mkschs"   ###構成展開
			  @reqparams["remark"]  = "#{self}  line:#{__LINE__}  構成展開 level > 1"  
			  processreqs_id ,@reqparams = ArelCtl.proc_processreqs_add @reqparams
		  end
		  return  last_lotstks
	  end

	  def proc_add_dvs_data(apparatus)   ###前の状態のalloc解除と現在のalloc作成
		  ### prdschsは作成のみ　trnganttsと連動
		  case @tblname  ###親 prdxxxs
		  when "prdschs"
			  currdvstbl = "dvsschs"
			  strduedate = "duedate"
			  val_qty_sch = 1
			  val_qty = 0
			  val_qty_stk = 0
		  when "prdords"
			  currdvstbl = "dvsords"
			  strduedate = "duedate"
			  val_qty_sch = 0
			  val_qty = 1
			  val_qty_stk = 0
		  when "prdinsts"
			  currdvstbl = "dvsinsts"
			  strduedate = "duedate"
			  val_qty_sch = 0
			  val_qty = 1
			  val_qty_stk = 0
		  when "prdacts"
			  currdvstbl = "dvsacts"
			  strduedate = "cmpldate"
			  val_qty_sch = 0
			  val_qty = 0
			  val_qty_stk = 1
		  else
			  raise 
		  end 

		  gantt = @reqparams["gantt"].dup
		  dvs = RorBlkCtl::BlkClass.new("r_#{currdvstbl}")
		  command_dvs = dvs.command_init
      command_dvs["#{currdvstbl.chop}_prjno_id"] = @tbldata["prjnos_id"]
      command_dvs["#{currdvstbl.chop}_expiredate"] = "2099/12/31"
      command_dvs["sio_classname"] = "_add_dvs_data"
			command_dvs["id"]  = command_dvs["#{currdvstbl.chop}_id"]  = ArelCtl.proc_get_nextval("#{currdvstbl}_seq")
      @reqparams["mkprdpurords_id"] = 0
      @reqparams["child"] = {}
      command_dvs["#{currdvstbl.chop}_#{@tblname.chop}_id_#{currdvstbl.chop}"] = @tbldata["id"] ###@tbldata=prdschs or prdords
      command_dvs["#{currdvstbl.chop}_person_id_upd"] = @reqparams["person_id_upd"] = @tbldata["persons_id_upd"]
		  prevdvs = {}
		   
	
      if currdvstbl == "dvsacts" or currdvstbl == "dvsinsts"
              acttbldata = @tbldata.dup
              strsql = %Q&
                          select link.* from linktbls link 
                                inner join alloctbls alloc on alloc.srctblname = 'prdacts' and alloc.srctblid = #{@tbldata["id"]}
                                        and link.trngantts_id = alloc.trngantts_id
                                where link.tblname = '#{@tblname}' and link.tblid = #{@tbldata["id"]}
              &
              prev_prd = ActiveRecord::Base.connection.select_one(strsql)
              strsql = %Q&
                          select * from #{prev_prd["srctblname"].sub("prd","dvs")} dvs
                                where  #{prev_prd["srctblname"]}_id_#{prev_prd["srctblname"].sub("prd","dvs").chop} = #{prev_prd["srctblid"]}
              &
              prev_dvs = ActiveRecord::Base.connection.select_one(strsql)
              acttbldata["starttime"] = prev_dvs["starttime"]
              if currdvstbl == "dvsacts"
                acttbldata["duedate"] = @tbldata["cmpldate"]
              else
                acttbldata["duedate"] = @tbldata["duedate"]
              end
              acttbldata["commencementdate"] = prev_dvs["commencementdate"]
              command_dvs = CtlFields.proc_field_duedate(currdvstbl.chop,command_dvs,acttbldata,apparatus)
              command_dvs = CtlFields.proc_field_starttime(currdvstbl.chop,command_dvs,acttbldata,apparatus)
      else
              command_dvs = CtlFields.proc_field_duedate(currdvstbl.chop,command_dvs,@tbldata,apparatus)
              command_dvs = CtlFields.proc_field_starttime(currdvstbl.chop,command_dvs,@tbldata,apparatus)
      end
      command_dvs["#{currdvstbl.chop}_sno"] = CtlFields.proc_field_sno(currdvstbl.chop,Time.now,command_dvs["id"])
      command_dvs = CtlFields.proc_field_facilities_id(currdvstbl.chop,command_dvs,@tbldata,apparatus)
      command_dvs = dvs.proc_create_tbldata(command_dvs)
      dvs.proc_private_aud_rec(@reqparams,command_dvs) ###create pur,prdschs
      ###paretblname:prdxxxxs,tblname:erc,dvsxxxs paretblid paretblname.id,tblid tblname.id
      # src = {"paretblname" => @tblname,"paretblid" => @tbldata["id"],"tblname" => currdvstbl,"tblid" => command_dvs["id"]}
      # add_dvserc_link(src)
	  end 
    ###
    ##  ercxxxs
    ###
	  def proc_add_erc_data(apparatus)   ###前の状態のalloc解除と現在のalloc作成
		  ### prdschsは作成のみ　trnganttsと連動
		  case @tblname  ###親 prdxxxs
		  when "prdschs"
			  currerctbl = "ercschs"
			  preverctbl = "ercschs"
			  strduedate = "duedate"
			  val_qty_sch = 1
			  val_qty = 0
			  val_qty_stk = 0
		  when "prdords"
        currerctbl = "ercords"
			  preverctbl = "ercschs"
			  strduedate = "duedate"
			  val_qty_sch = 0
			  val_qty = 1
			  val_qty_stk = 0
		  when "prdinsts"
			  currerctbl = "ercinsts"
			  preverctbl = "ercords"
			  strduedate = "duedate"
			  val_qty_sch = 0
			  val_qty = 1
			  val_qty_stk = 0
		  when "prdacts"
			  currerctbl = "ercacts"
			  preverctbl = "ercords"
			  strduedate = "cmpldate"
			  val_qty_sch = 0
			  val_qty = 0
			  val_qty_stk = 1
		  else
			  return 
		  end 

		  gantt = @reqparams["gantt"].dup
      erc = RorBlkCtl::BlkClass.new("r_#{currerctbl}")
      command_erc = erc.command_init
      command_erc["#{currerctbl.chop}_prjno_id"] = @tbldata["prjnos_id"]
      command_erc["#{currerctbl.chop}_expiredate"] = "2099/12/31"
      command_erc["sio_classname"] = "_add_erc_data"
			command_erc["id"]  = command_erc["#{currerctbl.chop}_id"]  = ArelCtl.proc_get_nextval("#{currerctbl}_seq")
      @reqparams["mkprdpurords_id"] = 0
      @reqparams["child"] = {}
      command_erc["#{currerctbl.chop}_person_id_upd"] = @reqparams["person_id_upd"] = @tbldata["persons_id_upd"]
		  prev_erc = {}
		   
	    command_erc["sio_classname"] = "_add_erc_link"
      command_erc["#{currerctbl.chop}_#{@tblname.chop}_id_#{currerctbl.chop}"] = @tbldata["id"]
      cnt = 0
      gantt_key = gantt["key"]
      ["changeover","require","postprocess"].each do |processname|   ###前処理、処理、後処理
          next if processname == "changeover" and (apparatus["changeoverlt"].to_f == 0 or apparatus["changeoverop"].to_f == 0)
          next if processname == "require" and apparatus["requireop"].to_f == 0
          next if processname == "postprocess" and (apparatus["postprocessingop"].to_f == 0 or apparatus["postprocessinglt"].to_f == 0)
          command_erc["id"] = ArelCtl.proc_get_nextval("#{currerctbl}_seq")
          command_erc["#{currerctbl.chop}_sno"] = CtlFields.proc_field_sno(currerctbl.chop,Time.now,command_erc["id"])
          command_erc["#{currerctbl.chop}_processname"] = processname
          if currerctbl == "ercacts" or currerctbl == "ercinsts"  
              strsql = %Q&
                  select link.* from linktbls link 
                    inner join alloctbls alloc on alloc.srctblid = #{@tbldata["id"]} and link.trngantts_id = alloc.trngantts_id
                    where link.tblname = '#{@tblname}' and link.tblid = #{@tbldata["id"]}
                    and (alloc.srctblname = 'prdacts' or alloc.srctblname = 'prdinsts')
                    &
               prev_prd = ActiveRecord::Base.connection.select_one(strsql)
		          strsql = %Q&  ---前の状態を引き継ぐ
							    select erc.* from #{preverctbl} erc
                      inner join fcoperators f on f.id = erc.fcoperators_id 
                      where  #{prev_prd["srctblname"]}_id_#{preverctbl.chop} = #{prev_prd["srctblid"]}
                      and f.itms_id_fcoperator = #{apparatus["itms_id"]}
                      and erc.processname = '#{processname}'
					  	    &
              prev_erc = ActiveRecord::Base.connection.select_one(strsql)
              command_erc["#{currerctbl.chop}_duedate"] = prev_erc["duedate"]
              command_erc["#{currerctbl.chop}_starttime"] = prev_erc["starttime"]
              command_erc["#{currerctbl.chop}_commencementdate"] = prev_erc["commencementdate"]
              command_erc["#{currerctbl.chop}_fcoperator_id"] = prev_erc["fcoperators_id"]
          else
		          strsql = %Q&  --- from master when ercords
							    select f.id from  fcoperators f 
                      where f.itms_id_fcoperator = #{apparatus["itms_id"]}
                      order by f.priority desc
					  	    &
              fcop = ActiveRecord::Base.connection.select_one(strsql)
              command_erc = CtlFields.proc_field_duedate(currerctbl.chop,command_erc,@tbldata,apparatus)
              command_erc = CtlFields.proc_field_starttime(currerctbl.chop,command_erc,@tbldata,apparatus)
              command_erc = CtlFields.proc_field_fcoperators_id(currerctbl.chop,command_erc,nil,apparatus)
              command_erc["#{currerctbl.chop}_fcoperator_id"] = fcop["id"]
          end
		      command_erc = erc.proc_create_tbldata(command_erc)
          gantt["key"] = gantt_key +  format('%04d', cnt) 
          @reqparams["gantt"] = gantt.dup
		      erc.proc_private_aud_rec(@reqparams,command_erc) ###create pur,prdschs
          cnt += 1
          # ###paretblname:prdxxxxs,tblname:erc,dvsxxxs paretblid paretblname.id,tblid tblname.id
          # src = {"paretblname" => @tblname,"paretblid" => @tbldata["id"],"tblname" => currerctbl,"tblid" => command_erc["id"]}
          # add_dvserc_link(src)
      end
	  end 

	  def proc_delete_dvs_data
		
		  ### prdschsは作成のみ　trnganttsと連動
		  case @tblname  ###親 prdxxxs
		  when "prdschs"
			  currdvstbl = "dvsschs"
			  strduedate = "duedate"
		  when "prdords"
			  currdvstbl = "dvsords"
			  strduedate = "duedate"
		  when "prdinsts"
			  currdvstbl = "dvsinsts"
			  strduedate = "duedate"
		  when "prdacts"
			  currdvstbl = "dvsacts"
			  strduedate = "cmpldate"
		  else
			  return 
		  end 

		  dvs = RorBlkCtl::BlkClass.new("r_#{currdvstbl}")
		  command_dvs = dvs.command_init
      command_dvs["#{currdvstbl.chop}_prjno_id"] =  @tbldata["prjnos_id"]
      command_dvs["#{currdvstbl.chop}_person_id_upd"] = @reqparams["person_id_upd"]
      command_dvs["sio_classname"] = "_delete_dvs_link"
		
			strsql = %Q&
						select * from #{currdvstbl} dvs
                where #{@tblname}_id_#{currdvstbl.chop} = #{@tbldata["id"]}
				  &
		  ActiveRecord::Base.connection.select_all(strsql).each do |currdvs|
          command_dvs["#{currdvstbl.chop}_facilitie_id"] = currdvs["facilities_id"]
          command_dvs["id"] = command_dvs["#{currdvstbl.chop}_id"] = currdvs["id"]
		      command_dvs = dvs.proc_create_tbldata(command_dvs)
		      dvs.proc_private_aud_rec(@reqparams,command_dvs) ###create pur,prdschs
          src = {"tblname" => currdvstbl,"tblid" => currdvs["id"]} 
          delete_dvserc_link(src)
      end
    end
    ###
    #  erc
    ###
	  def proc_delete_erc_data
		
		  ### prdschsは作成のみ　trnganttsと連動
		  case @tblname  ###親 prdxxxs
		  when "prdschs"
			  preverctbl = "ercschs"
			  currerctbl = "ercschs"
			  strduedate = "duedate"
		  when "prdords"
			  preverctbl = "ercschs"
			  currerctbl = "ercords"
			  strduedate = "duedate"
		  when "prdinsts"
			  preverctbl = "ercords"
			  currerctbl = "ercinsts"
			  strduedate = "duedate"
		  when "prdacts"
			  currerctbl = "ercacts"
			  strduedate = "cmpldate"
		  else
			  return 
		  end 

		  erc = RorBlkCtl::BlkClass.new("r_#{currerctbl}")
		  command_erc = erc.command_init
      command_erc["#{currerctbl.chop}_prjno_id"] =  @tbldata["prjnos_id"]
      command_erc["#{currerctbl.chop}_person_id_upd"] = @reqparams["person_id_upd"]
      command_erc["sio_classname"] = "_delete_erc_link"		
			strsql = %Q&
						select * from #{currerctbl} dvs
                where #{@tblname}_id_#{currerctbl.chop} = #{@tbldata["id"]}
				  &
		  ActiveRecord::Base.connection.select_all(strsql).each do |currdvs|
        ["changeover","require","ostprocess"].each do |processname|
		      strsql = %Q&
							select erc.* from #{currerctbl} erc
                    where #{@tblname}_id_#{currerctbl.chop} = #{@tbldata["id"]}
                    and erc.processname = '#{processname}'
					  	&
		      ActiveRecord::Base.connection.select_all(strsql).each do |currerc|
            command_erc["#{currerctbl.chop}_fcoperator_id"] = currerc["fcoperators_id"]
            command_erc["id"] = command_erc["#{currerctbl.chop}_id"] = currerc["id"]
		        command_erc = erc.proc_create_tbldata(command_erc)
		        erc.proc_private_aud_rec(@reqparams,command_erc) ###create pur,prdschs
            src = {"tblname" => currerctbl,"tblid" => currerc["id"]} 
            delete_dvserc_link(src)
          end
        end
      end
	  end 
    # def proc_add_dvserc_link src  ###paretblname:prdxxxxs,tblname:erc,dvsxxxs paretblid paretblname.id,tblid tblname.id
    #   strsql = %Q&
    #               select * from linktbls where tblname = '#{src["paretblname"]}' and tblid = #{src["paretblid"]}
    #                                     and (srctblname != tblname or srctblid != tblid)
    #   &
    #   ActiveRecord::Base.connection.select_all(strsql).each do |prev_link|
    #     strsql =%Q&
    #                 select link.srctblname paretblname,link.srctblid paretblid from linktbls link 
    #                           inner join alloctbls alloc on link.tblname = alloc.srctblname and  link.tblid = alloc.srctblid
    #                                                   and link.trngantts_id = alloc.trngantts_id
    #                           where link.tblname = '#{prev_link["srctblname"]}' and link.tblid = #{prev_link["srctblid"]}
    #                           and alloc.qty_linkto_alloctbl > 0
    #           &
    #     ActiveRecord::Base.connection.select_all(strsql).each do |prev_pare|   ###parents prdxxxxs
    #       strsql = %Q&
    #                     select '#{prev_pare["paretblname"].sub("prd",src["tblname"][0..2])}' tblname,id tblid
    #                            from #{prev_pare["paretblname"].sub("prd",src["tblname"][0..2])}
    #                               where #{prev_pare["paretblname"]}_id_#{src["tblname"].chop} = #{prev_pare["paretblid"]}
    #               &
    #       ActiveRecord::Base.connection.select_all(strsql).each do |prev_dvserc| 
    #         strsql = %Q&
    #                     select * from linktbls where tblname = '#{prev_dvserc["tblname"]}' and tblid = #{prev_dvserc["tblid"]} 
    #                                             and qty_src > 0
    #               &
    #         ActiveRecord::Base.connection.select_all(strsql).each do |link|  ###trngantts_idを求める
    #           link_src = {"tblname" => link["tblname"],"tblid" => link["tblid"],"qty_src" => 1,"trngantts_id" => link["trngantts_id"]}
    #           base = {"tblname" => src["tblname"],"tblid" => src["tblid"],"qty_src" => 1,"amt_src" => 0,
    #                   "remark" => "#{self} line #{__LINE__}", 
    #                   "persons_id_upd" => @reqparams["person_id_upd"]}
    #           ArelCtl.proc_insert_linktbls(link_src,base)
    #           alloc = {"srctblname" => src["tblname"],"srctblid" => src["tblid"],"trngantts_id" => link["trngantts_id"],
    #                     "qty_linkto_alloctbl" => 1,
    #                     "remark" => "#{self} line #{__LINE__} #{Time.now}","persons_id_upd" => @reqparams["person_id_upd"],
    #                       "allocfree" =>"alloc"}
    #           ArelCtl.proc_aud_alloctbls(alloc,"add")
    #         end                 
    #         delete_dvserc_link prev_dvserc
    #       end
    #     end
    #   end
    # end
    def delete_dvserc_link src  ###tblname--> dvsxxxs OR ercxxxS ,tblid--> dvsxxxs_id OR ercxxxs_id
       strsql = %Q&
                   select * from linktbls where tblname = '#{src["tblname"]}' and tblid = #{src["tblid"]}
       &
       ActiveRecord::Base.connection.select_all(strsql).each do |link|
         ActiveRecord::Base.connection.delete(%Q&delete from linktbls where id = #{link["id"]}&)
         strsql = %Q&
                 select * from alloctbls where srctblname = '#{src["tblname"]}' and srctblid = #{src["tblid"]}
                                         and trngantts_id = #{link["trngantts_id"]}
         &
         ActiveRecord::Base.connection.select_all(strsql).each do |alloc|
           ActiveRecord::Base.connection.delete(%Q&delete from alloctbls where id = #{alloc["id"]}&)
           ### dvsschs,ercschsのtrnganttsは残す
         end
       end
     end
  end   #class	
end   #module