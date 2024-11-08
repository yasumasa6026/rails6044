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
			  when /acts$|rets$|purdlvs$|custdlvs$/
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
			  return @reqparams if @gantt.nil?
			  check_shelfnos_duedate_qty()  ###
			  return @reqparams  if @chng_flg == ""
			  ###数量・納期・場所の変更があった時
			  case @tblname
			  when /schs$|ords$/  ###topのみ schsの修正はganttchartから
				  strsql = %Q% 
						select * from trngantts where tblname = '#{@tblname}' and tblid = #{@tblid}
						  and orgtblname = paretblname and paretblname = tblname
						  and orgtblid = paretblid and paretblid = tblid
						%
			  else
				  return @reqparams
			  end
			  top_trngantt = ActiveRecord::Base.connection.select_one(strsql)
			  if top_trngantt.nil?
				  return @reqparams
			  end
			  @trngantts_id =  @gantt["trngantts_id"]  = @last_rec["trngantts_id"] = top_trngantt["id"]
			  ### qty,qty_stkはqty_linkto_alloctbl以下にはできない。
			  ###出庫指示数以下にはできない。
			  ###locas_idの変更は不可(オンライン、入り口でチェック) 
			  ###前の在庫　をzeroに
			  ###  xxxschsはtop以外修正できない trnganttsの値を修正

			  ###新shelfnos_id_fmで出庫・消費を作成(数量増の変更で対応)
			  ###数量又は納期の変更があった時   xxxsxhs,xxxordsの時のみ
			  strsql = %Q&
			 			update trngantts set   --- xxschs,xxxordsが変更された時のみ
			 				updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
			 				#{@str_qty.to_s} = #{@tbldata[@str_qty]},
			 				remark = '#{self}  line:#{__LINE__}'||remark,
			 				prjnos_id = #{@tbldata["prjnos_id"]},duedate_trn = '#{@tbldata[@str_duedate]}'
			 				#{if @tblname =~ /^cust/ then "" else ",shelfnos_id_to_trn = #{@tbldata["shelfnos_id_to"]}" end}
			 				where  id = #{@trngantts_id} &
			  ActiveRecord::Base.connection.update(strsql) 
			  ###
			  ###
			  if @chng_flg =~ /qty/ 
				  ###数量の変更があるときはalloctblsも修正する。
				  case @tblname
				  when /^prdschs|^purschs/   ###schsが減されfreeのordsが発生。xxxschsがtopの時のみ変更可能
            ###lotstkhistsの変更本体のみ
					  strsql = %Q&  ---alloctblsはrorblkvtlで更新済
								select alloc.* from alloctbls alloc
										where alloc.srctblname = '#{@tblname}' and alloc.srctblid = #{@tblid}
										and trngantts_id = #{@trngantts_id}
							&
					  base_alloc = ActiveRecord::Base.connection.select_one(strsql)
					  alloctbls_id ,last_lotstk = base_sch_alloc_update(base_alloc)  
            last_lotstks << last_lotstk
					  ###schsが減された時:ords,insts,actsをfreeに　qty_schが増、減されたときshp,conの変更、###在庫の処理を含む
					  ###trnganttsは修正済  alloctblsは一件のみ
            if @tblname == "prdschs" and @tbldata["qty_sch"].to_f  == 0
              delete_dvs_link   ###装置の解除
            end
				  when /purords$|prdords$/  ###既に引き当てられている数以下にはできない。画面でチェック済
					  last_lotstks = change_alloc_last() 			  ###linktblsとlink先のalloctblの変更
            if @tblname == "prdords" and @tbldata["qty"].to_f  == 0
              delete_dvs_link   ###装置の解除
            end
				  when /^custords/
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
						  return @reqparams
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
								"duration" => 0,"duration_facility" => 0,"packqtyfacility" => 0}
						  update_prdpur_child(trn)
				 	  end
				  end
				  ###shp,conの変更 callされるのはschs,ordsの時のみ
        end
        if @chng_flg != "qty"
          last_lotstks << {"tblname" => @tblname,"tblid" => @tblid,"qty_src" => - @last_rec[@str_qty],
                            @str_duedate => @last_rec["duedate"],"prjnos_id" => @last_rec["prjnos_id"],
                            @str_shelfnos_id => @last_rec[@str_shelfnos_id]}
          last_lotstks << {"tblname" => @tblname,"tblid" => @tblid,"qty_src" =>  @tbldata[@str_qty]}
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
      @reqparams["last_lotstks"] = last_lotstks.dup
		  return @reqparams
	  end
	  ###--------------------------------------------------------------------------------------------
  	###linktblsの追加はRorBlkctlで完了済のこと。
		###
		### /insts|replyinputs|dlvs|acts|replyinputs/ではtrnganttsは作成しない。
			###trnganttsがあるのはxxxschsとxxxordsのみ
		### 前の状態の予定在庫補正。linktbls,alloctblsはrorblkctlで修正済
		### qty,qty_stkはqty_linkto_alloctbl以下にはできない。
		###出庫指示数以下にはできない。
		###qty_linkto_alloctbl > 0 の時はlocas_idの変更は不可(オンライン、入り口でチェック)
		###shelfnos_id_fmの変更はinsts,reply,dlvs,acts,retsでは不可
	  def proc_link_lotstkhists_update()  ###
		  return if @gantt["stktaking_proc"] != "1"
		  if @reqparams["classname"] =~ /_insert_|_add_/  ###trngantts 追加
			  base = {}
			  cust_base = {}
			  ###supp_base = {}
			  base["itms_id"] = @gantt["itms_id_trn"]
		  	base["processseq"]  = @gantt["processseq_trn"]
			  base["prjnos_id"]  = @gantt["prjnos_id"]
			  base["tblname"]  = @gantt["tblname"]
			  base["tblid"]  = @gantt["tblid"]
		  	base["persons_id_upd"]  = @gantt["persons_id_upd"]
			  base["qty_sch"] = base["qty"] = base["qty_stk"] = 0
			  inout = "in"
			  base["srctblname"] = "lotstkhists"
			  base["trngantts_id"] = @gantt["trngantts_id"]
			  case @tblname
			  when /^cust/
				  ###社内倉庫の更新
				  base["shelfnos_id"] =  @tbldata["shelfnos_id_fm"]
				  inout = "out" 
				  ###客先倉庫の更新
				  cust_base = base.dup
				  cust_base["custrcvplcs_id"] = @tbldata["custrcvplcs_id"]
				  cust_base["srctblname"] = "custwhs"
				  cust_inout = "in" 
				  case @tblname 
				  when  "custacts"
					  base["starttime"] = (@tbldata["saledate"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					  base["qty_stk"] = @tbldata["qty_stk"]
					  cust_base["starttime"] = (@tbldata["saledate"].to_time ).strftime("%Y-%m-%d %H:%M:%S")  #
					  cust_base["remark"] = "Operation line #{__LINE__}"
				  when "custrets"
					  base["starttime"] = (@tbldata["retdate"].to_time + 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  
					  ### 例外
					  inout = "in"
					  base["qty_stk"] = @tbldata["qty_stk"]
					  cust_base["starttime"] = (@tbldata["retdate"].to_time - 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					  cust_base["remark"] = "Operation line #{__LINE__}"
					  ###例外
					  cust_inout = "out" 
				  when "custdlvs"  
					  base["starttime"] = (@tbldata["depdate"].to_time ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					  base["qty_stk"] =  @tbldata["qty_stk"]
					  cust_base["starttime"] = (@tbldata["dlvdate"].to_time + 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					  base["qty"] = @tbldata["qty_stk"]   ###客先は未だ予定
					  cust_base["remark"] = "Operation line #{__LINE__}"
				  when /^custinsts/  
					  base["starttime"] = (@tbldata["duedate"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					  base["qty_stk"] =  @tbldata["qty_stk"]
					  cust_base["starttime"] = (@tbldata["duedate"].to_time).strftime("%Y-%m-%d %H:%M:%S")  
					  cust_base["remark"] = "#{self}  line #{__LINE__}"
				  when /^custords/  
					  base["starttime"] = (@tbldata["duedate"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					  base["qty"] =  @tbldata["qty"]
					  cust_base["starttime"] = (@tbldata["duedate"].to_time).strftime("%Y-%m-%d %H:%M:%S")  
					  cust_base["remark"] = "#{self}  line #{__LINE__}"
				  when /^custschs/  
					  base["starttime"] = (@tbldata["duedate"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					  base["qty_sch"] =  @tbldata["qty_sch"]
					  cust_base["starttime"] = (@tbldata["duedate"].to_time).strftime("%Y-%m-%d %H:%M:%S")  
					  cust_base["remark"] = "#{self}  line #{__LINE__}"
				  end
				  cust_base["srctblname"] = "custwhs"
				  cust_base = Shipment.proc_mk_custwhs_rec(inout,cust_base)  ###在庫の更新
				  # Shipment.proc_alloc_change_inoutlotstk(cust_base)
				  # base = Shipment.proc_lotstkhists_in_out(inout,base)  ###在庫の更新
				  # Shipment.proc_alloc_change_inoutlotstk(base)
				  base = {}
			  when /^purdlvs/  ###packnoはない
				  base["shelfnos_id"] =  @tbldata["shelfnos_id_to"]
				  base["starttime"] = (@tbldata["depdate"].to_time + 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				  base["qty"] = @tbldata["qty_stk"]
				  base["remark"] = "#{self}  line #{__LINE__}"
			  when /^prdords|^purords/
				  if @mkprdpurords_id == 0   ###mkordinst以外。if @mkprdpurords_id != 0 then  mkordinstで在庫更新
					  base["shelfnos_id"] =  @tbldata["shelfnos_id_to"]
					  base["starttime"] = @tbldata["duedate"]
					  base["qty"]  = @tbldata["qty"]
					  base["remark"] = "#{self}  line #{__LINE__}"
				  else
					  base = {}
				  end
			  when /^prdacts/
				  ### trngantts.qty_stkの変更
				  ### qtyはxxxords作成時又は引当時に変更済
				  ### insts,replyints,instsではtrngantts.qtyは変化しない。
				  base["shelfnos_id"] =  @tbldata["shelfnos_id_to"]
				  base["starttime"] = @tbldata["cmpldate"]
				  base["qty_stk"]  = base["qty_real"]  = @tbldata["qty_stk"]
				  base["remark"] = "#{self}  line #{__LINE__}"
			  when /^puracts/
				  base["shelfnos_id"] =  @tbldata["shelfnos_id_to"]
				  base["starttime"] = @tbldata["rcptdate"]
				  base["qty_stk"]  = base["qty_real"]  = @tbldata["qty_stk"]
				  base["remark"] = "#{self}  line #{__LINE__}"
			  when /insts|replyinputs/
				  base["shelfnos_id"] =  @tbldata["shelfnos_id_to"]
				  base["starttime"] = @tbldata["duedate"]
				  base["qty"]  = @tbldata["qty"]
				  base["remark"] = "Operation line #{__LINE__}"
			  when /schs/
				  base["shelfnos_id"] =  @tbldata["shelfnos_id_to"]
				  base["starttime"] = @tbldata["duedate"]
				  base["qty_sch"]  = @tbldata["qty_sch"]
				  base["remark"] = "#{self}  line #{__LINE__}"
			  end	
			  if !base.empty?		
				  # base = Shipment.proc_lotstkhists_in_out(inout,base)  ###
				  # Shipment.proc_alloc_change_inoutlotstk(base)
				  case @tblname
				  when /^prdacts|^purdlvs/
					  ActiveRecord::Base.connection.select_all(ArelCtl.proc_ChildConSql(@tbldata)).each do |conord|
						  next if conord["consumauto"] == "M"  ### qty_stk確定時の消費手動は除く
						  dupParams = @reqparams.dup
						  dupParams["child"] = conord.dup
						  dupParams["parent"] = @tbldata.dup
						  dupParams["parent"]["trngantts_id"] = @gantt["trngantts_id"]  ### shpxxxs,conxxxsのtrngantts_idは親のtrngantts_id
						  Shipment.proc_create_consume(dupParams) do
							  "conacts"
						  end
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
							  Shipment.proc_create_consume(dupParams) do
								  "conacts"
							  end
						  end
					  end
				  when /purinsts$|purreplyinputs$|prdinsts$/
					  ActiveRecord::Base.connection.select_all(ArelCtl.proc_ChildConSql(@tbldata)).each do |conord|
						  dupParams = @reqparams.dup
						  dupParams["child"] = conord.dup
						  dupParams["parent"] = @tbldata.dup
						  dupParams["parent"]["trngantts_id"] = @gantt["trngantts_id"]  ### shpxxxs,conxxxsのtrngantts_idは親のtrngantts_id
						  Shipment.proc_create_consume(dupParams) do
							  "conords"
						  end
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
							  Shipment.proc_create_consume(prevParams) do
								  "conords"
							  end
						  end
					  end
				  when /purords$|prdords$/
					  ActiveRecord::Base.connection.select_all(ArelCtl.proc_ChildConSql(@tbldata)).each do |consch|
						  dupParams = @reqparams.dup
						  dupParams["child"] = consch.dup
						  dupParams["parent"] = @tbldata.dup
						  dupParams["parent"]["trngantts_id"] = @gantt["trngantts_id"]  ### shpxxxs,conxxxsのtrngantts_idは親のtrngantts_id
						  Shipment.proc_create_consume(dupParams) do
							  "conschs"
						  end
					  end
				  end
			  end
			# if !supp_base.empty?
			#  	supp_base["wh"] = "supplierwhs"		
			#  	cust_base = Shipment.proc_mk_supplierwhs_rec(inout,supp_base)  ###在庫の更新
			# end
			###
			# 明細(inoutlotstks)と前状態の数量変更
			###
			# strsql = %Q&
			# 		select srctblname tblname,srctblid tblid,trngantts_id,qty_src,
			# 				tblname savetblname,tblid savetblid
			# 			from #{if @tblname =~ /^cust/  then "linkcusts" else "linktbls" end}
			# 			where id in(#{@reqparams["linktbl_ids"].join(",")})
			# 			and  qty_src > 0
			# &
			# ActiveRecord::Base.connection.select_all(strsql).each do |src|
			# 	case @tblname
			# 	when /schs$/
			# 	 	src["qty_sch"] = base["qty_sch"] = src["qty_src"]
			# 	when /ords$|insts$|reply/
			# 		src["qty"] = base["qty"] = src["qty_src"]
			# 	when /acts$|dlvs$/
			# 		src["qty_stk"] = base["qty_stk"] = src["qty_src"]
			# 	end
			# 	base["trngantts_id"] = src["trngantts_id"]
			# 	plusminus = if inout == "in"
			# 					1
			# 				else
			# 					-1
			# 				end
			# 	# Shipment.proc_insert_inoutlotstk_sql(plusminus,base)  ###新規明細
			# 	# if src["savetblname"] != src["tblname"] or src["savetblid"] != src["tblid"]
			# 	ArelCtl.proc_src_trn_stk_update(src,base)
			# 	# end
			# 	if !cust_base.empty?	
			# 		cust_base["trngantts_id"] = src["trngantts_id"]
			# 		plusminus = if cust_inout == "in"
			# 						1
			# 					else
			# 						-1
			# 					end
			# 		# Shipment.proc_insert_inoutlotstk_sql(plusminus,cust_base)	
			# 		# if src["savetblname"] != src["tblname"] or src["savetblid"] != src["tblid"]
			# 		ArelCtl.proc_src_trn_stk_update(src,cust_base)
			# 		# end
			# 	end
			# 	if !supp_base.empty?	
			# 		supp_base["trngantts_id"] = src["trngantts_id"]
			# 		plusminus = if cust_inout == "in"
			# 						1
			# 					else
			# 						-1
			# 					end
			# 		# Shipment.proc_insert_inoutlotstk_sql(plusminus,supp_base)	
			# 		# if src["savetblname"] != src["tblname"] or src["savetblid"] != src["tblid"]
			# 		ArelCtl.proc_src_trn_stk_update(src,supp_base)
			# 		# end
			# 	end
			# end	
		  else ###変更　(削除 qty_sch=qty=qty_stk=0 　を含む) 
			  lastStkinout = {"tblname" => @tblname,"tblid" => @tblid,
                      "srctblname" => @tblname,"srctblid" => @tblid,
                      "itms_id" => @last_rec["itms_id"] ,"processseq" => @last_rec["processseq"] ,
                      "shelfnos_id" => @last_rec["shelfnos_id_to"],  ###shpxxx,custxxxでは個別の設定が必要
                      "prjnos_id" => @last_rec["prjnos_id"] ,
                      "starttime" => @last_rec["duedate"],"packno" => (@last_rec["packno"]||=""),"lotno" => (@last_rec["lotno"]||=""),
                      "lotstkhists_id" => "","trngantts_id" => "","alloctbls_id" => "",
                      "qty_src" => 0,"amt_src" => 0,"qty_linkto_alloctbl" => 0,
                      "qty_sch" => @last_rec["qty_sch"].to_f,"qty" =>@last_rec["qty"].to_f,"qty_stk" => @last_rec["qty_stk"].to_f,
                      "qty_real" => @last_rec["qty_stk"].to_f}	  ###last_rec:view type
			  stkinout = {}
			  lastStkinout["persons_id_upd"] = @tbldata["persons_id_upd"]
			  stkinout = @tbldata.dup
			  lastStkinout["trngantts_id"] = stkinout["trngantts_id"] = @gantt["trngantts_id"]
			  case @tblname
			  when /^cust/
				  ###社内倉庫の更新
				  lastStkinout["shelfnos_id"] =  @last_rec["#{@tblname.chop}_shelfno_id_fm"]
				  lastStkinout["prjnos_id"] =  @last_rec["#{@tblname.chop}_prjno_id"]

				  stkinout["srctblname"] = lastStkinout["srctblname"] = "lotstkhists"
				  case @tblname 
				  when  "custacts" 
					  lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_saledate"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					  lastStkinout = Shipment.proc_lotstkhists_in_out("in",lastStkinout)  ###前の在庫の更新　一旦全数削除
					  stkinout["shelfnos_id"] = @tbldata["shelfnos_id_fm"]
					  stkinout["starttime"] = (@tbldata["saledate"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				  when "custrets"
					  lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_retdate"].to_time + 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  
					  lastStkinout[@str_qty] = lastStkinout[@str_qty] * -1   ###retのみ例外
					  lastStkinout = Shipment.proc_lotstkhists_in_out("in",lastStkinout)  ###前の在庫の更新　
					  stkinout["starttime"] = (@tbldata["retdate"].to_time + 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  
					  ### 例外
					  inout = "in"
				  when "custdlvs"  
					  lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_depdate"].to_time ).strftime("%Y-%m-%d %H:%M:%S")  
					  lastStkinout = Shipment.proc_lotstkhists_in_out("in",lastStkinout)  ###前の在庫の更新　
					  stkinout["starttime"] = (@tbldata["depdate"].to_time ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				  else  
					  lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_duedate"].to_time - 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  
					  lastStkinout = Shipment.proc_lotstkhists_in_out("in",lastStkinout)  ###前の在庫の更新　
					  stkinout["starttime"] = (@tbldata["duedate"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				  end
				  if stkinout[@str_qty].to_f > 0
					  stkinout["shelfnos_id"] =  @tbldata["shelfnos_id_fm"]
					  stkinout = Shipment.proc_lotstkhists_in_out("out",stkinout)  ###在庫の更新
				  end
				  # Shipment.proc_alloc_change_inoutlotstk(stkinout)
				  ###客先倉庫の更新
				  stkinout["custrcvplcs_id"] = @tbldata["custrcvplcs_id"]
				  lastStkinout["custrcvplcs_id"] = @last_rec["#{@tblname.chop}_custrcvplc_id"]  
				  stkinout["remark"] = " #{self}  line #{__LINE__} "
				  stkinout["srctblname"] = "custwhs"
				  inout = "in" 
				  case @tblname 
				  when  "custacts"
					  lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_saledate"].to_time ).strftime("%Y-%m-%d %H:%M:%S")  #
					  stkinout["starttime"] = (@tbldata["saledate"].to_time ).strftime("%Y-%m-%d %H:%M:%S")  #
				  when "custrets"  ###packnoはない
					  lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_retdate"].to_time - 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					  lastStkinout[@str_qty] = lastStkinout[@str_qty] * -1   ###retのみ例外
					  stkinout["starttime"] = (@tbldata["retdate"].to_time - 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					  ###例外
					  inout = "out" 
				  when "custdlvs"  ###packnoはない
					  lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_dlvdate"].to_time + 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					  stkinout["starttime"] = (@tbldata["dlvdate"].to_time + 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				  else
					  stkinout["starttime"] = (@tbldata["duedate"].to_time).strftime("%Y-%m-%d %H:%M:%S")  
				  end
				  if stkinout[@str_qty].to_f > 0
				 	  stkinout["shelfnos_id"] =  @tbldata["shelfnos_id_fm"]
					  lastStkinout = Shipment.proc_mk_custwhs_rec(inout,stkinout)
				  end
				  lastStkinout = Shipment.proc_mk_custwhs_rec("out",lastStkinout)
			  when /^purdlvs/  ###packnoはない
				  lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_depdate"].to_time + 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				  lastStkinout = Shipment.proc_lotstkhists_in_out("out",lastStkinout)  ###在庫の更新
				  lastStkinout["shelfnos_id"] =  @last_rec["#{@tblname.chop}_shelfno_id_fm"]
				  lastStkinout["starttime"] = @last_rec["#{@tblname.chop}_depdate"] ###カレンダー考慮要
				  lastStkinout["suppliers_id"] = @last_rec["#{@tblname.chop}_suppler_id"]
				  Shipment.proc_mk_supplierwhs_rec("in",lastStkinout)
				  if stkinout[@str_qty].to_f > 0
					  stkinout["starttime"] = (@tbldata["depdate"].to_time + 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					  stkinout = Shipment.proc_lotstkhists_in_out("in",stkinout)  ###在庫の更新
					  stkinout["shelfnos_id"] =  @tbldata["shelfnos_id_fm"]
					  stkinout["starttime"] = @tbldata["depdate"] ###カレンダー考慮要
					  stkinout["suppliers_id"] = @tbldata["supplers_id"]
					  Shipment.proc_mk_supplierwhs_rec("out",stkinout)
				    # Shipment.proc_alloc_change_inoutlotstk(stkinout)
				  end
			  when /^prdords|^purords/
				  # stkinout = Shipment.proc_lotstkhists_in_out("out",lastStkinout)  ###在庫の更新
				  # if stkinout[@str_qty].to_f > 0
					#   stkinout = Shipment.proc_lotstkhists_in_out("in",stkinout)  ###在庫の更新
				  # end
          ###
          # 数量減の時元の引当在庫に戻す
          ###
          de_qty = lastStkinout[@str_qty].to_f - stkinout[@str_qty].to_f
          if de_qty > 0
            strsql = %Q&
                    select a.srctblname,a.srctblid,min(t.duedate_trn),a.qty_linkto_alloctbl qty_alloc from alloctbls a 
                          inner join trngantts t on t.id = a.trngantts_id
                          inner join linktbls l on l.tblname = a.srctblname and l.tblid = a.srctblid
                                                and a.trngantts_id = l.trngantts_id  
                        where l.tblname = '#{@tblname}' and l.tblid = #{@tblid}
                        and l.qty_src > 0 and a.qty_linkto_alloctbl > 0
                        group by a.srctblname,a.srctblid order by min(t.duedate_trn)
                  &
				    ActiveRecord::Base.connection.select_all(strsql).each do |link|
            end
			    end
			  when /^prschs|^purschs/
				  # stkinout = Shipment.proc_lotstkhists_in_out("out",lastStkinout)  ###在庫の更新
				  # if stkinout[@str_qty].to_f > 0
					#   stkinout = Shipment.proc_lotstkhists_in_out("in",stkinout)  ###在庫の更新
				  # end
          ###
		    end
      end
		  return 		
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
			  command_c = CtlFields.proc_field_starttime(parent,trn,trn["tblname"].chop,command_c)
		  end
		  @gantt["tblname"] = trn["tblname"]
		  @gantt["tblid"] = trn["tblid"]
		  @gantt["mlevel"] = trn["mlevel"]
		  child_blk.proc_create_tbldata(command_c)
		  child_blk.proc_private_aud_rec(cParams,command_c)
		  @gantt["paretblname"] = trn["tblname"]
		  @gantt["paretblid"] = trn["tblid"]
		  @reqparams["gantt"] = @gantt.dup
		  if @chng_flg =~ /due/ and @tblname =~ /^prd/ and @tbldata[@str_qty]  == 0
        delete_dvs_link   ###装置の解除
      end
	  end

	  def last_rec
		  @last_rec
	  end
	
	  def check_shelfnos_duedate_qty
		  Rails.logger.debug"  class: #{self} , line:#{__LINE__} "
		  Rails.logger.debug"  @tbldata: #{@tbldata} ,@last_rec: #{@last_rec} "
		  Rails.logger.debug"   qty:#{@tbldata[@str_qty]}, #{@last_rec[@str_qty]} " 
		  if @tbldata[@str_qty].to_f != @last_rec[@str_qty].to_f  
			 @chng_flg << "qty"
		  end
		  if @tbldata[@str_duedate] != @last_rec["duedate"]
			  @chng_flg << "due"
		  end
		  if @tbldata[prjnos_id] != @last_rec[prjno_id]
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
		  else
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

			end
			# if qty_sch < src_link["qty_src"].to_f   ###ords,insts・・・では　qty < src_link["qty_src"].to_fは不可
			# 	sql_link_update = %Q&
			# 			update linktbls set qty_src = #{qty_sch},
			# 					updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss') 	 
			# 					where id = #{src_link["id"]}
			# 					&
			# 	ActiveRecord::Base.connection.update(sql_link_update)
			# end
		else		
			###数量増の変更は不可
      last_lotstk = []
		end
		return last_lotstk
	end

	def change_alloc_last()   ###when /purords$|prdords$/
    last_lotstks = []
		save_qty = @tbldata[@str_qty].to_f
		strsql = %Q&
					select * from linktbls where tblname = '#{@tblname}' and tblid = #{@tblid} order by id desc  
              ----root を最後に
					&
		ActiveRecord::Base.connection.select_all(strsql).each do |link|
			if link["srctblname"]  == @tblname and link["srctblid"] == @tblid  ###xxxords のroot  last record
        if link["qty_src"].to_f > save_qty  
					update_strsql = %Q&
						update linktbls set qty_src = #{save_qty},
								updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss')	,
								remark = '#{self} line:(#{__LINE__})'|| remark										
								where id = #{link["id"]}
							& 
					ActiveRecord::Base.connection.update(update_strsql)
        end
				###
				#
				###
				trn_update_strsql = %Q&
						update trngantts set qty  =  #{save_qty},
								updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
								remark = '#{self} line:(#{__LINE__})'|| remark
								where id = #{link["trngantts_id"]} 
							& 
				ActiveRecord::Base.connection.update(trn_update_strsql)
        alloc = {"srctblname" => @tblname,"srctblid" => @tblid,"trngantts_id" => root_trngantts_id,
                "qty_linkto_alloctbl" => save_qty,
                "remark" => "#{self} line #{__LINE__} #{Time.now}","persons_id_upd" => shp["persons_id_upd"]}
        alloctbl_id,last_lotstk = ArelCtl.proc_aud_alloctbls(alloc,"update")
        last_lotstks << last_lotstk
				root_trngantts_id = link["trngantts_id"]
			else
				if save_qty < link["qty_src"].to_f
					update_strsql = %Q&
						update linktbls set qty_src = #{save_qty},
							updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss')	,
							remark = '#{self} line:(#{__LINE__})'|| remark										
							where id = #{link["id"]}
						& 
					ActiveRecord::Base.connection.update(update_strsql)
					###
					### schs.qty_schの復活とqty_schの在庫修正
          alloc = {"srctblname" =>link["tblname"],"srctblid" => link["tblid"],"trngantts_id" => link["trngantts_id"],
                  "qty_linkto_alloctbl" => link["qty_src"],"remark" => "#{self} line #{__LINE__} #{Time.now}"}
          alloctbl_id,last_lotstk = ArelCtl.proc_aud_alloctbls(alloc,"update+")
          last_lotstks << last_lotstk
					###
					### schs.qty_schの復活とqty_schの在庫修正
					trn_update_strsql = %Q&
						update trngantts set qty  =  qty  - #{link["qty_src"]},
								qty_sch  =  qty_sch   + #{link["qty_src"]},
								updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
								remark = '#{self} line:(#{__LINE__})'|| remark
								where id = #{link["trngantts_id"]} 
							& 
					ActiveRecord::Base.connection.update(trn_update_strsql)
					save_qty = 0
				else
					save_qty =- link["qty_src"].to_f
				end
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
		last_lotstks = ArelCtl.proc_insert_trngantts(@gantt)  ###@ganttの内容をセット
		# @reqparams["linktbl_ids"] = [linktbl_id]
		# @reqparams["alloctbl_ids"] = [alloctbls_id]
		@reqparams["gantt"] = @gantt.dup
		case @tblname	
		when /^purords/  ### 単独でxxxordsを画面又はexcelで登録-->mkordinstsを利用してないとき
			###free_ordtbl_alloc_to_sch(stkinout)
			if @mkprdpurords_id == 0 ###mkordinstsの時は子部品展開は対象外
					@reqparams["segment"]  = "mkschs"   ###構成展開
					@reqparams["remark"]  = "#{self}   構成展開"  ###構成展開
					processreqs_id ,@reqparams = ArelCtl.proc_processreqs_add @reqparams
			end
		when /^prdords/  ### 単独でxxxordsを画面又はexcelで登録-->mkordinstsを利用してないとき
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
		return
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
		last_lotstks = ArelCtl.proc_insert_trngantts(@gantt)  ###@ganttの内容をセット
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

	def proc_add_dvs_link   ###前の状態のalloc解除と現在のalloc作成
		strsql = %Q&
					select n.itms_id_nditm itms_id ,ic.code classlist_code from nditms n 
								inner join (select i.id itms_id ,c.code from itms i
													inner join classlists c on c.id = i.classlists_id ) ic
								on ic.itms_id = n.itms_id_nditm
								where ic.code = 'apparatus' and n.opeitms_id = #{@tbldata["opeitms_id"]}
		&
		apparatus = ActiveRecord::Base.connection.select_all(strsql)
		return if apparatus.empty?
		### prdschsは作成のみ　trnganttsと連動
		case @tblname  ###親 prdxxxs
		when "prdschs"
			prevdvstbl = "dvsschs"
			currdvstbl = "dvsschs"
			preverctbl = "ercschs"
			currerctbl = "ercschs"
			prevprdtbl = "prdschs"
			strduedate = "duedate"
			val_qty_sch = 1
			val_qty = 0
			val_qty_stk = 0
		when "prdords"
			prevdvstbl = "dvsschs"
			currdvstbl = "dvsords"
			preverctbl = "ercschs"
			currerctbl = "ercords"
			prevprdtbl = "prdschs"
			strduedate = "duedate"
			val_qty_sch = 0
			val_qty = 1
			val_qty_stk = 0
		when "prdinsts"
			prevdvstbl = "dvsords"
			currdvstbl = "dvsinsts"
			preverctbl = "ercords"
			currerctbl = "ercinsts"
			prevprdtbl = "prdords"
			strduedate = "duedate"
			val_qty_sch = 0
			val_qty = 1
			val_qty_stk = 0
		when "prdacts"
			currdvstbl = "dvsacts"
			currerctbl = "ercacts"
			strduedate = "cmpldate"
			val_qty_sch = 0
			val_qty = 0
			val_qty_stk = 1
		else
			return 
		end 

		gantt = @reqparams["gantt"].dup
		gantt["tblname"] = "dvsschs"
		dvs = RorBlkCtl::BlkClass.new("r_#{currdvstbl}")
		command_dvs = dvs.command_init
		command_dvs["id"] = ArelCtl.proc_get_nextval("#{currdvstbl}_seq")
		prevdvs = {}
		erc = RorBlkCtl::BlkClass.new("r_#{currerctbl}")
		command_erc = erc.command_init
		command_erc["id"] = ArelCtl.proc_get_nextval("#{currerctbl}_seq")
		preverc = {}
		strsql = %Q&
			select * from linktbls link
                    inner join alloctbls alloc on alloc.srctblname = link.tblname and alloc.srctblid = link.tblid
                                               and alloc.trngantts_id = link.trngantts_id    
                    where  tblname = '#{@tblname}' and tblid = #{@tbldata["id"]}   --- @tblname-->prdxxxs
                    and link.tblname != link.srctblname and link.qty_src > 0
			&
		ActiveRecord::Base.connection.select_all(strsql).each do |link|
				if @tblname == "prdacts"
					if link["srctblname"] == "prdords"
						prevdvstbl = "dvsords"
						preverctbl = "ercords"
						prevprdtbl = "prdords"
					else
						prevdvstbl = "dvsinsts"
						preverctbl = "ercinsts"
						prevprdtbl = "prdinsts"
					end
				end
				strsql = %Q&
						select id,starttime from #{prevdvstbl} where #{prevprdtbl}_id_#{prevdvstbl.chop} = #{link["srctblid"]}
				  &
			  prevdvs = ActiveRecord::Base.connection.select_one(strsql)
				 alloc_dvs_sql = %Q&
								select id ,trngantts_id from alloctbls
									where srctblname = '#{prevdvstbl} and srctblid = #{prevdvs["id"]}  ---xxxschs.id unique on alloctbls
				    & 
				ActiveRecord::Base.connection.select_all(alloc_dvs_sql).each do |dvs_alloc|
					  alloc = {"alloc_id" =>dvs_alloc["id"],"qty_linkto_alloctbl" => 0,"remark" => "#{self} line #{__LINE__} #{Time.now}"}
            alloctbl_id,temp_last_lotstk = ArelCtl.proc_aud_alloctbls(alloc,"update")
					  src = {"tblname" => prevdvstbl,"tblid" => prevdvs["id"],"trngantts_id" => dvs_alloc["trngantts_id"]}
					  base = {"tblname" =>currdvstbl,"tblid" => command_dvs["id"],"qty_src" => 1,"amt_src" => 0,
						  "remark" => "#{self} line #{__LINE__}", 
						  "persons_id_upd" => @reqparams["person_id_upd"]}
            linktbl_id = ArelCtl.proc_insert_linktbls(src,base)
					  alloc = {"srctblname" => currdvstbl,"srctblid" => command_dvs["id"],"trngantts_id" => dvs_alloc["trngantts_id"],
							"qty_linkto_alloctbl" => 1,
							"remark" => "#{self} line #{__LINE__} #{Time.now}","persons_id_upd" => gantt["persons_id_upd"],
							"allocfree" => 	"alloc"}
					  alloctbl_id,temp_last_lotstk = ArelCtl.proc_aud_alloctbls(alloc,nil)
				end
        ###
        ##  ercxxxs
        ###
				strsql = %Q&
							select id,starttime from #{preverctbl} where #{prevprdtbl}_id_#{preverctbl.chop} = #{link["srctblid"]}
					  	&
				preverc = ActiveRecord::Base.connection.select_one(strsql)
				alloc_erc_sql = %Q&
								select id ,trmgantts_id from alloctbls
									where srctblname = '#{preverctbl} and srctblid = #{preverc["id"]}  ---xxxschs.id unique on alloctbls
				    & 
				  ActiveRecord::Base.connection.select_all(alloc_erc_sql).each do |erc_alloc|
					  alloc = {"alloc_id" =>erc_alloc["id"],"qty_linkto_alloctbl" => 0,
                  "remark" => "#{self} line #{__LINE__} #{Time.now}","persons_id_upd" => shp["persons_id_upd"]}
            alloctbl_id,temp_last_lotstk = ArelCtl.proc_aud_alloctbls(alloc,"update")
					  src = {"tblname" => preverctbl,"tblid" => preverc["id"],"trngantts_id" => erc_alloc["trngantts_id"]}
					  base = {"tblname" =>currerctbl,"tblid" => command_erc["id"],"qty_src" => 1,"amt_src" => 0,
						  "remark" => "#{self} line #{__LINE__}", 
						  "persons_id_upd" => @reqparams["person_id_upd"]}
            linktbl_id = ArelCtl.proc_insert_linktbls(src,base)
					  alloc = {"srctblname" => currerctbl,"srctblid" => command_erc["id"],"trngantts_id" => erc_alloc["trngantts_id"],
							"qty_linkto_alloctbl" => 1,
							"remark" => "#{self} line #{__LINE__} #{Time.now}","persons_id_upd" => gantt["persons_id_upd"],
							"allocfree" => 	"alloc"}
					  alloctbl_id,temp_last_lotstk = ArelCtl.proc_aud_alloctbls(alloc,nil)
				  end
    end
    command_dvs["#{currdvstbl.chop}_#{strduedate}"] = command_erc["#{currerctbl.chop}_#{strduedate}"] = @tbldata[strduedate]
    command_dvs["#{currdvstbl.chop}_starttime"] = command_erc["#{currerctbl.chop}_starttime"] = (@tbldata["commencementdate"]||=@tbldata["starttime"])
    if  @tblname =~ /prdords|prdinsts|prdacts/ and @tbldata["commencementdate"]
		  command_dvs["#{currdvstbl.chop}_commencementdate"] = @tbldata["commencementdate"]
    end
		command_dvs["#{currdvstbl.chop}_prjno_id"] = command_erc["#{currerctbl.chop}_prjno_id"] = @tbldata["prjnos_id"]
		command_dvs["#{currdvstbl.chop}_expiredate"] = command_erc["#{currerctbl.chop}_expiredate"] = "2099/12/31"
		gantt["duedate_trn"] = @tbldata[strduedate]
		gantt["qty_require"] = 1
		gantt["qty_handover"] = 0
		gantt["qty_sch"] = val_qty_sch
		gantt["qty"] = val_qty
		gantt["qty_stk"] = val_qty_stk 
		command_dvs["#{currdvstbl.chop}_#{@tblname.chop}_id_#{currdvstbl.chop}"] = @tbldata["id"]
		command_erc["#{currerctbl.chop}_#{@tblname.chop}_id_#{currerctbl.chop}"] = @tbldata["id"]
		command_dvs["#{currdvstbl.chop}_person_id_upd"] = command_erc["#{currerctbl.chop}_person_id_upd"] = gantt["persons_id_upd"] = @reqparams["person_id_upd"]
    @reqparams["mkprdpurords_id"] = 0
    @reqparams["child"] = {}
    @reqparams["gantt"] = gantt.dup
    command_dvs["sio_classname"] = "_add_dvs_link"
		command_erc["sio_classname"] = "_add_erc_link"
    apparatus.each do |appa|
		  command_dvs["#{currdvstbl.chop}_sno"] = CtlFields.proc_field_sno(currdvstbl.chop,Time.now,command_dvs["id"])
      command_dvs,err = CtlFields.proc_field_facilities_id(currdvstbl.chop,command_dvs,appa)
		  command_dvs = dvs.proc_create_tbldata(command_dvs)
		  dvs.proc_private_aud_rec(@reqparams,command_dvs) ###create pur,prdschs
			###
			### erc
			###
		  command_erc["#{currerctbl.chop}_sno"] = CtlFields.proc_field_sno(currerctbl.chop,Time.now,command_erc["id"])
		  parent = {"facilities_id" => command_dvs["#{currdvstbl.chop}_facilitie_id"]}
		  command_erc,err = CtlFields.proc_field_fcoperators_id(currerctbl.chop,command_erc,parent)
		  command_erc = erc.proc_create_tbldata(command_erc)
		  erc.proc_private_aud_rec(@reqparams,command_erc) ###create pur,prdschs
    end
	end 

  def proc_update_dvs_link
		strsql = %Q&
					select n.itms_id_nditm itms_id ,ic.code classlist_code from nditms n 
								inner join (select i.id itms_id ,c.code from itms i
													inner join classlists c on c.id = i.classlists_id ) ic
								on ic.itms_id = n.itms_id_nditm
								where ic.code = 'apparatus' and n.opeitms_id = #{@tbldata["opeitms_id"]}
		&
		apparatus = ActiveRecord::Base.connection.select_one(strsql)
		return if apparatus.nil?
		case @tblname  ###親 prdxxxs
		when "prdschs"
			currdvstbl = "dvsschs"
			currerctbl = "ercschs"
			ganttdvstbl = "dvsschs"
			gantterctbl = "ercschs"
			strduedate = "duedate"
		when "prdords"
			currdvstbl = "dvsords"
			currerctbl = "ercords"
			ganttdvstbl = "dvsords"
			gantterctbl = "ercords"
			strduedate = "duedate"
		when "prdinsts"
			currdvstbl = "dvsinsts"
			currerctbl = "ercinsts"
			ganttdvstbl = "dvsords"
			gantterctbl = "ercords"
			strduedate = "duedate"
		when "prdacts"
			currdvstbl = "dvsacts"
			currerctbl = "ercacts"
			ganttdvstbl = "dvsords"
			gantterctbl = "ercords"
			strduedate = "cmpldate"
		else
			return 
		end 

			gantt = @reqparams["gantt"].dup
			gantt["tblname"] = ganttdvstbl  ###trngantts top以外tblnameはxxxschs
			dvs = RorBlkCtl::BlkClass.new("r_#{currdvstbl}")
			command_dvs = dvs.command_init
			strsql = %Q&
									select id from #{currdvstbl} where #{@tblname}_id_#{currdvstbl.chop} = #{@tbldata["id"]}
			&
			dvs_id = ActiveRecord::Base.connection.select_value(strsql)
			command_dvs["id"] = command_dvs["#{currdvstbl.chop}_id"] = dvs_id
			case @tblname
			when "prdords","prdinsts"
				command_dvs["#{currdvstbl.chop}_duedate"] = @tbldata["duedate"]
			when "prdacts"
				command_dvs["#{currdvstbl.chop}_cmpldate"] = @tbldata["cmpldate"]
				command_dvs["#{currdvstbl.chop}_starttime"] = @tbldata["commencementdate"]
			end
			command_dvs["#{currdvstbl.chop}_commencementdate"] = @tbldata["commencementdate"]
			command_dvs["#{currdvstbl.chop}_prjno_id"] = @tbldata["prjnos_id"]
			gantt["duedate_trn"] = @tbldata[strduedate]
			command_dvs["#{currdvstbl.chop}_person_id_upd"] = gantt["persons_id_upd"] = @reqparams["person_id_upd"]
			command_dvs["#{currdvstbl.chop}_created_at"] = command_dvs["#{currdvstbl.chop}_updated_at"] = Time.now
			@reqparams["mkprdpurords_id"] = 0
			@reqparams["gantt"] = gantt.dup
			@reqparams["child"] = {}
			command_dvs["sio_classname"] = "_update_dvs_link"
			command_dvs = dvs.proc_create_tbldata(command_dvs)
			dvs.proc_private_aud_rec(setParams,command_dvs) ###create pur,prdschs
      ###
			### ercxxxs
			###
			gantt["tblname"] = gantterctbl  ###trngantts top以外tblnameはxxxschs
			erc = RorBlkCtl::BlkClass.new("r_#{currerctbl}")
			command_erc = erc.command_init
			strsql = %Q&
									select id from #{currerctbl} where #{@tblname.chop}_id_#{currerctbl.chop} = #{@tbldata["id"]}
			&
			erc_id = ActiveRecord::Base.connection.select_value(strsql)
			command_erc["id"] = command_erc["#{currerctbl.chop}_id"] = erc_id
			case @tblname
			when "prdords","prdinsts"
				command_erc["#{currerctbl.chop}_duedate"] = @tbldata["duedate"]
				command_erc["#{currerctbl.chop}_starttime"] = (@tbldata["commencementdate"]||= @tbldata["starttime"])
			when "prdacts"
				command_erc["#{currerctbl.chop}_cmpldate"] = @tbldata["cmpldate"]
				command_erc["#{currerctbl.chop}_starttime"] = @tbldata["commencementdate"]
			end
			command_erc["#{currerctbl.chop}_commencementdate"] = @tbldata["commencementdate"]
			command_erc["#{currerctbl.chop}_prjno_id"] = @tbldata["prjnos_id"]
			command_erc["#{currerctbl.chop}_person_id_upd"] = gantt["persons_id_upd"] = @reqparams["person_id_upd"]
			command_erc["#{currerctbl.chop}_created_at"] = command_erc["#{currerctbl.chop}_updated_at"] = Time.now
			@reqparams["child"] = {}
			command_erc["sio_classname"] = "_update_erc_link"
			command_erc = erc.proc_create_tbldata(command_erc)
			erc.proc_private_aud_rec(s@reqparams,command_erc) ###create pur,prdschs
	end 


	def delete_dvs_link
		case @tblname  ###親 prdxxxs
		when "prdschs"
			currdvstbl = "dvsschs"
			currerctbl = "ercschs"
			strduedate = "duedate"
			val_qty_sch = 0
			val_qty = 0
			val_qty_stk = 0
		when "prdords"
			currdvstbl = "dvsords"
			currerctbl = "ercords"
			strduedate = "duedate"
			val_qty_sch = 1
			val_qty = 0
			val_qty_stk = 0
		when "prdinsts"
			currdvstbl = "dvsinsts"
			currerctbl = "ercsinsts"
			strduedate = "duedate"
			val_qty_sch = 0
			val_qty = 1
			val_qty_stk = 0
		when "prdacts"
			currdvstbl = "dvsacts"
			currerctbl = "ercsacts"
			strduedate = "cmpldate"
			val_qty_sch = 0
			val_qty = 1
			val_qty_stk = 0
		else
			return 
		end 

		strsql = %Q&
					select n.itms_id_nditm itms_id ,ic.code classlist_code from nditms n 
								inner join (select i.id itms_id ,c.code from itms i
													inner join classlists c on c.id = i.classlists_id ) ic
								on ic.itms_id = n.itms_id_nditm
								where ic.code = 'apparatus' and n.opeitms_id = #{@tbldata["opeitms_id"]}
		&
		apparatus = ActiveRecord::Base.connection.select_one(strsql)
		if apparatus
			gantt = @reqparams["gantt"].dup
			dvs = RorBlkCtl::BlkClass.new("r_#{currdvstbl}")
			command_dvs = dvs.command_init
			erc = RorBlkCtl::BlkClass.new("r_#{currerctbl}")
			command_erc = erc.command_init
			strsql = %Q&
									select id from #{currdvstbl} where #{@tblname.chop}_id_#{currdvstbl.chop} = #{@tbldata["id"]}
			&
			dvs_id = ActiveRecord::Base.connection.select_value(strsql)
			alloc = {"srctblname" => currdvstbl,"srctblid" => dvs_id,
              "qty_linkto_alloctbl" => 0,
              "remark" => "#{self} line #{__LINE__} #{Time.now}","persons_id_upd" => shp["persons_id_upd"]}
      alloctbl_id,temp_last_lotstk = ArelCtl.proc_aud_alloctbls(alloc,"update")
			link_update_dvs_sql = %Q&
						update linktbls set qty_src = 0 ,remark = '#{self} #{__LINE__} #{Time.now}'||remark
						where  tblname = '#{currdvstbl}' and tblid = #{dvs_id}  
						& 
			ActiveRecord::Base.connection.update(link_update_dvs_sql)
			###
			###
			###
			strsql = %Q&
									select id from #{currerctbl} where #{@tblname.chop}_id_#{currerctbl.chop} = #{@tbldata["id"]}
			&
			erc_id = ActiveRecord::Base.connection.select_value(strsql)
			alloc = {"srctblname" => currerctbl,"srctblid" => erc_id,
              "qty_linkto_alloctbl" => 0,
              "remark" => "#{self} line #{__LINE__} #{Time.now}","persons_id_upd" => shp["persons_id_upd"]}
      alloctbl_id,temp_last_lotstk = ArelCtl.proc_aud_alloctbls(alloc,"update")
			link_update_erc_sql = %Q&
						update linktbls set qty_src = 0 ,remark = '#{self} #{__LINE__} #{Time.now}'||remark
						where  tblname = '#{currerctbl}' and tblid = #{erc_id}  
						& 
			ActiveRecord::Base.connection.update(link_update_erc_sql)
			command_dvs["id"] =  command_dvs["#{currdvstbl.chop}_id"] = dvs_id
			gantt["tblname"] = "dvsschs"
			gantt["duedate_trn"] = @tbldata[strduedate]
			gantt["qty_require"] = 0
			gantt["qty_handover"] = 0
			gantt["qty_sch"] = val_qty_sch
			gantt["qty"] = val_qty
			gantt["qty_stk"] = val_qty_stk 
			command_dvs["#{currdvstbl.chop}_person_id_upd"] = gantt["persons_id_upd"] = @reqparams["person_id_upd"]
			command_dvs["#{currdvstbl.chop}_created_at"] = command_dvs["#{currdvstbl.chop}_updated_at"] = Time.now
			@reqparams["mkprdpurords_id"] = 0
			@reqparams["gantt"] = gantt.dup
			@reqparams["child"] = {}
			command_dvs["sio_classname"] = "_delete_dvs_link"
			command_dvs = dvs.proc_create_tbldata(command_dvs)
			dvs.proc_private_aud_rec(@reqparams,command_dvs) ###create pur,prdschs
			###
			###
			###
			command_erc["id"] =  command_erc["#{currerctbl.chop}_id"] = erc_id
			gantt["tblname"] = "ercschs" 
			command_erc["#{currerctbl.chop}_person_id_upd"] = gantt["persons_id_upd"] = @reqparams["person_id_upd"]
			command_erc["#{currdvstbl.chop}_created_at"] = command_erc["#{currerctbl.chop}_updated_at"] = Time.now
			@reqparams["gantt"] = gantt.dup
			command_erc["sio_classname"] = "_delete_erc_link"
			command_erc = erc.proc_create_tbldata(command_erc)
			erc.proc_private_aud_rec(@reqparams,command_erc) ###create pur,prdschs
		end
	end 

end   #class
	
end   #module