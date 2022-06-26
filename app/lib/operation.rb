# -*- coding: utf-8 -*-
# operation
# 2099/12/31を修正する時は　2100/01/01の修正も
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
		@gantt["itms_id"]  =  @tbldata["itms_id"] = @gantt["itms_id_trn"]
		@gantt["processseq"]  =  @tbldata["processseq"] = @gantt["processseq_trn"]  
		@gantt["starttime"]  =  @gantt["starttime_trn"]    
		@gantt["duedate"]  =  @gantt["duedate_trn"]     
		@gantt["toduedate"]  =  @gantt["toduedate_trn"]  
		@mkprdpurords_id = (params["mkprdpurords_id"]||=0)
		@mkbillinsts_id = (params["mkbillinsts_id"]||=0)
		
		@opeitm = params["opeitm"]  ###tbldataのopeitmsの情報
		@str_duedate = case @tblname
			when /dlvs/
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
		@str_qty =case @tblname
			when /acts$|rets$/
				"qty_stk"
			when /custdlvs$/
					"qty_stk"
			when /purdlvs$/
					"qty_stk"
			when /schs$/
				"qty_sch"
			else
				"qty"
			end
		if @tblname =~ /^prd|^pur|^cust/ and @tblname =~ /schs$|ords$|insts$|reply|dlvs$|acts$|rets$/ 
			get_last_rec()   ##set @last_rec
		end
	end

	###------------------------------------------------------
	def proc_trngantts()  ###schs,ords専用
		###
		if @reqparams["classname"] =~ /_insert_|_add_/  ###trngantts 追加
			if (@tblid == @paretblid and @tblname == @paretblname and @tblid == @orgtblid and @tblname == @orgtblname) 
				###schs$,ords$--->新規本体を作成  ^pur,^prd 
				init_trngantts_add_detail()
			else ###構成の一部になっているとき(本体を作成後確認)
				child_trngantts()  
			end	
		else ###変更　(削除 qty_sch=qty=qty_stk=0 　を含む) purschs,purords,prdschs,prdords
			###return if @last_rec.empty?   ###@last_rec initでset
			chng_flg = check_shelfnos_duedate_qty()  ###
			return if chng_flg == ""
			###数量・納期・場所の変更があった時
			strsql = %Q% select * from trngantts where tblname = '#{@tblname}' and tblid = #{@tblid}
						  and orgtblname = paretblname and paretblname = tblname
						  and orgtblid = paretblid and paretblid = tblid
						%
			@gantt = ActiveRecord::Base.connection.select_one(strsql)
			return if @gantt.nil?
			@trngantts_id =  @gantt["trngantts_id"]  = @last_rec["trngantts_id"] = @gantt["id"]
			### qty,qty_stkはqty_linkto_alloctbl以下にはできない。
			###出庫指示数以下にはできない。
			###locas_idの変更は不可(オンライン、入り口でチェック) 
			###前の在庫　をzeroに
			###  xxxschsはtop以外修正できない trnganttsの値を修正

			strsql = %Q&  ---alloctblsはrorblkvtlで更新済
						select alloc.* from alloctbls alloc
								where alloc.srctblname = '#{@tblname}' and alloc.srctblid = #{@tblid}
								and trngantts_id = #{@trngantts_id}
					&
			base_alloc = ActiveRecord::Base.connection.select_one(strsql)
			# case @tblname
			# when /^prdschs|^prdprds|^purschs|^purords/
			# 	###子部品の出庫・消費・在庫の処理
			# 	update_last_children_shp_con()  
			# when /^cust/
			# end
			###新shelfnos_id_fmで出庫・消費を作成(数量増の変更で対応)
			###数量又は納期の変更があった時   xxxsxhs,xxxordsの時のみ
			strsql = %Q&update trngantts set   --- xxschs,xxxordsが変更された時のみ
							updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
							#{@str_qty.to_s} = #{@tbldata[@str_qty]},remark = 'Operation.proc_trangantts line:#{__LINE__}'
							prjnos_id = #{@tbldata["prjnos_id"]},duedate_trn = '#{@tbldata[@str_duedate]}',
							shelfnos_id_to = #{@tbldata["shelfnos_id_to"]}
							where  id = #{@trngantts_id} &
			ActiveRecord::Base.connection.update(strsql) 
			####
			if chng_flg =~ /qty/ 
				###数量の変更があるときはalloctblsも修正する。
				case @tblname
				when /^prdschs|^purschs/   ###schsが減されfreeのordsが発生
					base_sch_alloc_update(base_alloc)  
					###schsが減された時:ords,insts,actsをfreeに　qty_schが増、減されたときshp,conの変更、###在庫の処理を含む
					###trnganttsは修正済  alloctblsは一件のみ
				when /^custschs|^custords/
					###linktblsの変更はしない。
					###custschsか増減してもlinktblsは変更しない。custordsにfreeはない。
					###custordsが減数しても、一度引き当てたcustschsは変更なし。custordsの数量増はない。
				when /ords$/  ###既に引き当てられている数以下にはできない。画面でチェック済
					###linktblsとlink先のalloctblの変更
					strsql = %Q&
							select * from linktbls where tblname = '#{@tblname}' and tblid =#{@tblid} order by id desc
					&
					links = ActiveRecord::Base.connection.select_all(strsql)
					change_alloc_last(links) 
				end
				###shp,conの変更 callされるのはschs,ordsの時のみ
			end
			###下位の構成変更
			if @gantt["mlevel"]  == 0
				lowlevel_gantts = []
				lowlevel_gantts[0] = [@gantt]
				until lowlevel_gantts.empty?
					lgantt = lowlevel_gantts.shift
					strsql = %Q&
							select 	child.orgtblname,child.orgtblid,child.tblname,child.tblid,
									pare.qty_sch,child.mlevel,
									child.parenum,child.chilnum,
									child.consumunitqty,child.consumminqty,child.consumchgoverqty 
								from trngantts pare
								inner join trngantts child
									on pare.orgtblname = child.orgtblname and pare.orgtblid = child.orgtblid
									and pare.tblname = child.paretblname and pare.tblid = child.paretblid
									and pare.mlevel < child.mlevel
								where pare.orgtblname = '#{lgantt["orgtblname"]}' and pare.orgtblid = '#{lgantt["orgtblid"]}'
								and pare.tblname = '#{lgantt["tblname"]}' and pare.tblid = '#{lgantt["tblid"]}'
						&
					trns = ActiveRecord::Base.connection.select_all(strsql)
					trns.each do |trn|
						update_prdpur_child(trn) 
						lowlevel_gantts << trn
					end
				end
			end
		end
		return @reqparams
	end
	
	###--------------------------------------------------------------------------------------------
	###linktblsの追加はRorBlkctlで完了済のこと。
	def proc_link_lotstkhists_update()  ###
		###
		### /insts|replyinputs|dlvs|acts|replyinputs/ではtrnganttsは作成しない。
			###trnganttsがあるのはxxxschsとxxxordsのみ
		### 前の状態の予定在庫補正。linktbls,alloctblsはrorblkctlで修正済
		### qty,qty_stkはqty_linkto_alloctbl以下にはできない。
		###出庫指示数以下にはできない。
		###qty_linkto_alloctbl > 0 の時はlocas_idの変更は不可(オンライン、入り口でチェック)
		###shelfnos_id_fmの変更はinsts,reply,dlvs,acts,retsでは不可
		stkinout = ArelCtl.proc_set_stkinout(@tbldata) 
		if @reqparams["classname"] =~ /_insert_|_add_/  ###trngantts 追加
			case @tblname
			when /^cust/
				###社内倉庫の更新
				stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = @tbldata["shelfnos_id_fm"]
				stkinout["srctblname"] = "lotstkhists"
				inout = "out" 
				case @tblname 
				when  "custacts"
					stkinout["starttime"] = (@tbldata["saledate"].to_date - 1).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				when "custrets"
					stkinout["starttime"] = (@tbldata["retdate"].to_date + 1 ).strftime("%Y-%m-%d %H:%M:%S")  
					### 例外
					inout = "in"
				when "custdlvs"  
					stkinout["starttime"] = (@tbldata["depdate"].to_date ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				when /^custschs|^custords/  
					stkinout["starttime"] = (@tbldata["duedate"].to_date - 1).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					src = {"tblname" => stkinout["tblname"],"tblid" => stkinout["tblid"],"trngantts_id" => stkinout["trngantts_id"]}
					base = {"tblname" => stkinout["tblname"],"tblid" => stkinout["tblid"],"qty_src" => @tbldata[@str_qty].to_f,"amt_src" => 0}
					ArelCtl.proc_insert_linktbls(src,base)
				end
				stkinout = Shipment.proc_lotstkhists_in_out(inout,stkinout)  ###在庫の更新
				proc_update_inoutlot_and_src_stk(inout,"lotstkhists",stkinout)
				###客先倉庫の更新
				stkinout["custrcvplcs_id"] = @tbldata["custrcvplcs_id"]
				stkinout["remark"] = "Operation line #{__LINE__}"
				stkinout["srctblname"] = "custwhs"
				inout = "in" 
				case @tblname 
				when  "custacts"
					stkinout["starttime"] = (@tbldata["saledate"].to_date ).strftime("%Y-%m-%d %H:%M:%S")  #
				when "custrets"  ###packnoはない
					stkinout["starttime"] = (@tbldata["retdate"].to_date - 1 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					###例外
					inout = "out" 
					stkinout = Shipment.proc_mk_custwhs_rec("out",stkinout)
				when "custdlvs"  ###packnoはない
					stkinout["starttime"] = (@tbldata["dlvdate"].to_date + 1 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				else
					stkinout["starttime"] = (@tbldata["duedate"].to_date).strftime("%Y-%m-%d %H:%M:%S")  
				end
				stkinout = Shipment.proc_mk_custwhs_rec(inout,stkinout)
				proc_update_inoutlot_and_src_stk(inout,"custwhs",stkinout)
			when /^prdrets/   ###手直し可能、不可(返品場所)　　返品理由　　
				stkinout = Shipment.proc_lotstkhists_in_out("out",stkinout)  ###在庫の更新
				proc_update_inoutlot_and_src_stk("out","lotstkhists",stkinout)
			when /^purrets/   
				stkinout = Shipment.proc_lotstkhists_in_out("out",stkinout)  ###在庫の更新
				proc_update_inoutlot_and_src_stk("out","lotstkhists",stkinout)
				stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = @tbldata["shelfnos_id_fm"]
				stkinout["starttime"] = (@tbldata["retdate"].to_date + 1 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				stkinout["suppliers_id"] = @tbldata["supplers_id"]
				stkinout = Shipment.proc_mk_supplierwhs_rec("out",stkinout)
				proc_update_inoutlot_and_src_stk("out","suppliers",stkinout)
			when /^purdlvs/  ###packnoはない
				stkinout["starttime"] = (@tbldata["depdate"].to_date + 1).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				stkinout = Shipment.proc_lotstkhists_in_out("in",stkinout)  ###在庫の更新
				proc_update_inoutlot_and_src_stk("in","suppliers",stkinout)
				stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = @tbldata["shelfnos_id_fm"]
				stkinout["starttime"] = @tbldata["depdate"] ###カレンダー考慮要
				stkinout["suppliers_id"] = @tbldata["supplers_id"]
				Shipment.proc_mk_supplierwhs_rec("out",stkinout)
				proc_update_inoutlot_and_src_stk("out","suppliers",stkinout)
			when /^prdords|^purords/
				if @mkprdpurords_id == 0   ###mkordinst以外 mkordinstで在庫更新
					stkinout = Shipment.proc_lotstkhists_in_out("in",stkinout)  ###在庫の更新
					proc_update_inoutlot_and_src_stk("in","lotstkhists",stkinout)
				end
			when /^prdacts|^puracts/
					stkinout = Shipment.proc_lotstkhists_in_out("in",stkinout)  ###在庫の更新
					proc_update_inoutlot_and_src_stk("in","lotstkhists",stkinout)
			when /^prdschs|^purschs/
				stkinout = Shipment.proc_lotstkhists_in_out("in",stkinout)  ###在庫の更新
				proc_update_inoutlot_and_src_stk("in","lotstkhists",stkinout)
			end			
		else ###変更　(削除 qty_sch=qty=qty_stk=0 　を含む) 
			# if @tblname =~ /insts|reply/
			# 	###変更が数量のみの時　納期、納入場所についてはif chng_flg =~ /shelfno|due/で対応
			# 	update_last_children_shp_con()  ###在庫の処理を含む
			# end
			lastStkinout = ArelCtl.proc_set_stkinout(@last_rec) 
			case @tblname
			when /^cust/
				###社内倉庫の更新
				inout = "out" 
				lastStkinout[@str_qty] = lastStkinout[@str_qty] 
				lastStkinout["shelfnos_id"] = lastStkinout["shelfnos_id_real"] = @last_rec["shelfnos_id_fm"]
				stkinout["srctblname"] = lastStkinout["srctblname"] = "lotstkhists"
				case @tblname 
				when  "custacts" 
					lastStkinout["starttime"] = (@last_rec["saledate"].to_date - 1).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					lastStkinout = Shipment.proc_lotstkhists_in_out("update",lastStkinout)  ###前の在庫の更新　一旦全数削除
					proc_update_inoutlot_and_src_stk("in","lotstkhists",lastStkinout)
					stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = @tbldata["shelfnos_id_fm"]
					stkinout["starttime"] = (@tbldata["saledate"].to_date - 1).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				when "custrets"
					lastStkinout["starttime"] = (@last_rec["retdate"].to_date + 1 ).strftime("%Y-%m-%d %H:%M:%S")  
					lastStkinout[@str_qty] = lastStkinout[@str_qty] * -1   ###retのみ例外
					lastStkinout = Shipment.proc_lotstkhists_in_out("update",lastStkinout)  ###前の在庫の更新　
					proc_update_inoutlot_and_src_stk("out","lotstkhists",lastStkinout)
					stkinout["starttime"] = (@tbldata["retdate"].to_date + 1 ).strftime("%Y-%m-%d %H:%M:%S")  
					### 例外
					inout = "in"
				when "custdlvs"  
					lastStkinout["starttime"] = (@last_rec["depdate"].to_date ).strftime("%Y-%m-%d %H:%M:%S")  
					lastStkinout = Shipment.proc_lotstkhists_in_out("update",lastStkinout)  ###前の在庫の更新　
					proc_update_inoutlot_and_src_stk("in","lotstkhists",lastStkinout)
					stkinout["starttime"] = (@tbldata["depdate"].to_date ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				else  
					lastStkinout["starttime"] = (@last_rec["duedate"].to_date - 1 ).strftime("%Y-%m-%d %H:%M:%S")  
					lastStkinout = Shipment.proc_lotstkhists_in_out("update",lastStkinout)  ###前の在庫の更新　
					proc_update_inoutlot_and_src_stk("in","lotstkhists",lastStkinout)
					stkinout["starttime"] = (@tbldata["duedate"].to_date - 1).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				end
				if stkinout[@str_qty].to_f > 0
					stkinout = Shipment.proc_lotstkhists_in_out(inout,stkinout)  ###在庫の更新
					proc_update_inoutlot_and_src_stk(inout,"lotstkhists",stkinout)
				end
				###客先倉庫の更新
				stkinout["custrcvplcs_id"] = @tbldata["custrcvplcs_id"]
				lastStkinout["custrcvplcs_id"] = @last_rec["custrcvplcs_id"]  
				stkinout["remark"] = "Operation line #{__LINE__}"
				stkinout["srctblname"] = "custwhs"
				inout = "in" 
				case @tblname 
				when  "custacts"
					lastStkinout["starttime"] = (@last_rec["saledate"].to_date ).strftime("%Y-%m-%d %H:%M:%S")  #
					latStkinout = Shipment.proc_mk_custwhs_rec("update",lastStkinout)
					proc_update_inoutlot_and_src_stk(inout,"custwhs",lastStkinout)
					stkinout["starttime"] = (@tbldata["saledate"].to_date ).strftime("%Y-%m-%d %H:%M:%S")  #
				when "custrets"  ###packnoはない
					lastStkinout["starttime"] = (@last_rec["retdate"].to_date - 1 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					lastStkinout[@str_qty] = lastStkinout[@str_qty] * -1   ###retのみ例外
					latStkinout = Shipment.proc_mk_custwhs_rec("update",lastStkinout)
					proc_update_inoutlot_and_src_stk("in","custwhs",lastStkinout)
					stkinout["starttime"] = (@tbldata["retdate"].to_date - 1 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					###例外
					inout = "out" 
				when "custdlvs"  ###packnoはない
					lastStkinout["starttime"] = (@last_rec["dlvdate"].to_date + 1 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					latStkinout = Shipment.proc_mk_custwhs_rec("update",lastStkinout)
					proc_update_inoutlot_and_src_stk("out","custwhs",lastStkinout)
					stkinout["starttime"] = (@tbldata["dlvdate"].to_date + 1 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				else
					latStkinout = Shipment.proc_mk_custwhs_rec("update",lastStkinout)
					proc_update_inoutlot_and_src_stk("update","custwhs",lastStkinout)
					stkinout["starttime"] = (@tbldata["duedate"].to_date).strftime("%Y-%m-%d %H:%M:%S")  
				end
				stkinout = Shipment.proc_mk_custwhs_rec(inout,stkinout)
				proc_update_inoutlot_and_src_stk(inout,"custwhs",stkinout)
			when /^prdrets/
				stkinout = Shipment.proc_lotstkhists_in_out("out",stkinout)  ###在庫の更新
				proc_update_inoutlot_and_src_stk("out","lotstkhists",stkinout)
			when /^purrets/   
				stkinout = Shipment.proc_lotstkhists_in_out("out",stkinout)  ###在庫の更新
				proc_update_inoutlot_and_src_stk("out","lotstkhists",stkinout)
				stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = @tbldata["shelfnos_id_fm"]
				stkinout["starttime"] = (@tbldata["retdate"].to_date + 1 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				stkinout["suppliers_id"] = @tbldata["supplers_id"]
				stkinout = Shipment.proc_mk_supplierwhs_rec("out",stkinout)
				proc_update_inoutlot_and_src_stk("out","suppliers",stkinout)
			when /^purdlvs/  ###packnoはない
				stkinout["starttime"] = (@tbldata["depdate"].to_date + 1).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				stkinout = Shipment.proc_lotstkhists_in_out("in",stkinout)  ###在庫の更新
				proc_update_inoutlot_and_src_stk("in","suppliers",stkinout)
				stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = @tbldata["shelfnos_id_fm"]
				stkinout["starttime"] = @tbldata["depdate"] ###カレンダー考慮要
				stkinout["suppliers_id"] = @tbldata["supplers_id"]
				Shipment.proc_mk_supplierwhs_rec("out",stkinout)
				proc_update_inoutlot_and_src_stk("out","suppliers",stkinout)
			when /^prd/
				stkinout = Shipment.proc_lotstkhists_in_out("in",stkinout)  ###在庫の更新
				proc_update_inoutlot_and_src_stk("in","lotstkhists",stkinout)
			when /^pur/
				stkinout = Shipment.proc_lotstkhists_in_out("in",stkinout)  ###在庫の更新
				proc_update_inoutlot_and_src_stk("in","lotstkhists",stkinout)
			end
			# ###出庫指示変更、消費変更
			# if @tblname =~ /insts|reply/ and @tblname =~ /^pur|^prd/
			# 	Shipment.proc_re_create_shpords(@reqparams,srctblname,link["qty_src"].to_f,src)
			# 	Shipment.proc_re_create_conords(@reqparams,srctblname,link["qty_src"].to_f,src)
			# end
			# ###消費実行
			# if link["tblname"] =~ /^prdacts|^puracts|^purdlvs/  ###子部品の消費と金型、瓶等の自動返却
			# 	@tbldata["qty_stk"] = link["qty_src"].to_f
			# 	Shipment.proc_mk_conacts(@reqparams)  ###reqparams 親のデータ
			# end
		end		
		return 		
	end

	def update_prdpur_child(trn)
		screenCode = "r_" + trn["tblname"]
		strsql = %Q&
				select * from #{trn["tblname"]} where id = #{trn["id"]}
		&
		rec = ActiveRecord::Base.connection.select_one(strsql)
		blk = RorBlkCtl::BlkClass.new(screenCode)
		command_c = blk.command_init
		rec.each do |key,val|
			command_c[%Q&#{tblname.chop}"_"#{key.sub("s_id","_id")}&] = val
		end
		command_c["sio_classname"] = "_update_#{tblname}_update_prdpur_child"
		command_c["id"] = rec["id"]
		command_c["#{tblname.chop}_remark"] = " Operation.update_prdpur_child line:#{__LINE__} "
		if trn["pare_qty_sch"].to_f == 0
			commnd_c["#{tblname.chop}_qty_sch"] = 0
		else
			commnd_c["#{tblname.chop}_qty_sch"] = rec["pare_qty_sch"].to_f * rec["chilnum"].to_f / rec["parenum"].to_f
		end
		reqparams = @reqparams.dup
		gantt = reqparams["gantt"]
		gantt["tblname"] = trn["tblname"]
		gantt["tblid"] = trn["tblid"]
		gantt["mlevel"] = trn["mlevel"]
		reqparams["tbldata"] = rec
		blk.proc_create_tbldata(command_c)
		blk.proc_add_update_table(params,command_c)
	end

	def get_last_rec
		strsql = %Q&---最後に登録・修正されたレコード
		select '#{@tblname}' tblname,id tblid,
				opeitm_itm_id itms_id,opeitm_processseq processseq
				 from sio.sio_r_#{@tblname} where id = #{@tblid} 
					order by sio_id desc limit 1
		&
		last_view = ActiveRecord::Base.connection.select_one(strsql)
		@last_rec = {}
		if last_view
			last_view.each do |fd,val|
				tblfd = fd.sub("#{@tblname.chop}_","")
				@last_rec[tblfd] = val
			end
		end
	end
	
	def set_lotstkhists_custwhs_supplierwhs(stkinout,link)  ###/insts$|acts$|dlvs$|rets$/専用
		stkinout["remark"] = "Operation.set_lotstkhists_custwhs_supplierwhs table:#{@tblname}"
		case @tblname
		when /^purinsts|^prdinsts/
			stkinout = Shipment.proc_lotstkhists_in_out("in",stkinout)  ###
		when /^puracts|^prdacts/
			stkinout = Shipment.proc_lotstkhists_in_out("in",stkinout)  ##
		when /^custschs|^custords|^custinsts/   ###qtyの入りと出
			stkinout = Shipment.proc_lotstkhists_in_out("out",stkinout)  ##
		when /^custdlvs/  ###qty_stkの出
			stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = @tbldata["shelfnos_id_fm"]
			stkinout = Shipment.proc_lotstkhists_in_out("out",stkinout)  ##
			stkinout["qty"] = @tbldata["qty_stk"]
			stkinout["qty_stk"] = 0
			stkinout["starttime"] = (@tbldata["depdate"].to_date + 1).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
			stkinout["custrcvplcs_id"] = @tbldata["custrcvplcs_id"]
			stkinout["remark"] = "Operation line #{__LINE__}"
			Shipment.proc_mk_custwhs_rec("in",stkinout)
		when /^custacts/   ###qty_stkの入り
			if link
				if link["srctblname"] =~ /custords|custinsts/  ###custdlvs以外の時
					stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = @tbldata["shelfnos_id_fm"]
					stkinout["starttime"] = (@tbldata["saledate"].to_date - 1).strftime("%Y-%m-%d %H:%M:%S") ###カレンダー!!!
					stkinout["qty"] = stkinout["qty_stk"].to_f * -1
					stkinout["qty_stk"] = 0
					stkinout = Shipment.proc_lotstkhists_in_out("out",stkinout)  ##
					stkinout["qty_stk"] = stkinout["qty"].to_f * -1
					stkinout["qty"] = 0
					stkinout = Shipment.proc_lotstkhists_in_out("out",stkinout)  ##
					stkinout["starttime"] = @tbldata["saledate"]
				end
			end
			stkinout["custrcvplcs_id"] = @tbldata["custrcvplcs_id"]
			stkinout["remark"] = "Operation line #{__LINE__}"
			Shipment.proc_mk_custwhs_rec("in",stkinout)
		when /^custrets/   ###qty_stkの入り
			stkinout["custrcvplcs_id"] = @tbldata["custrcvplcs_id"]
			stkinout["remark"] = "Operation line #{__LINE__}"
			Shipment.proc_mk_custwhs_rec("out",stkinout)
			Shipment.proc_lotstkhists_in_out("in",stkinout)  ##
		end
	end	

	def check_shelfnos_duedate_qty
		chng_flg = ""
		if @tbldata[@str_qty].to_f != @last_rec[@str_qty].to_f  
			 chng_flg << "qty"
		end
		if @tbldata[@str_duedate] != @last_rec[@str_duedate]
			chng_flg << "due"
		end
		if @tbldata["shelfnos_id_to"] != @last_rec["shelfnos_id_to"]
			chng_flg << "shelfno"
		end
		if @tbldata["shelfnos_id_fm"] != @last_rec["shelfnos_id_fm"]
			chng_flg << "shelfno"
		end
		###
		#数量・納期の変更がないときは何もしない。
		return chng_flg
	end

	def base_sch_alloc_update(base_alloc)   ###purschs,prdschs
		### xxxords:alloctblsの変更 ordsはlinktblsのqty_src以下にはできない。--->画面又は入り口でチェック済であること。
		### alloctblsのqty_schの変更はror_blkctlで実施済
		if @tbldata["qty_sch"].to_f < base_alloc["qty_linkto_alloctbl"].to_f
			link_strsql = %Q&
				select link.*,alloc.qty qty,alloc.qty_stk qty_stk,qty.qty_linkto_alloctbl qty_linkto_alloctbl,alloc.id alloc_id
					from linktbls link   ---srctblname :xxxxschs
				inner join alloctbls alloc on link.trngantts_id = alloc.trngantts_id
					where trngantts_id = #{@trngantts_id}  ---既にordsからacts等になったtbl　を含む
					and (alloc.qty + alloc.qty_stk) > alloc.qty_linkto_alloctbl
				&
			qty_sch = @tbldata["qty_sch"].to_f
			ActiveRecord::Base.connection.select_all(link_strsql).each do |src_link|
				if qty_sch < src_link["qty_src"].to_f   ###ords,insts・・・では　qty < src_link["qty_src"].to_fは不可
					case src_link["tblname"]
					when /ords|insts|reply/
						if qty_sch < (src_link["qty"].to_f - src_link["qty_linkto_alloctbl"].to_f)
							src_link["qty"] = src_link["qty_linkto_alloctbl"].to_f
							qty_sch = 0
						else
							src_link["qty"] = qty_sch - (src_link["qty"].to_f - src_link["qty_linkto_alloctbl"].to_f)
							qty_sch -= (src_link["qty"].to_f - src_link["qty_linkto_alloctbl"].to_f)
						end
						src_link["qty_stk"] = 0	
					when /dlvs|acts|rets/
						if qty_sch < (src_link["qty_stk"].to_f - src_link["qty_linkto_alloctbl"].to_f)
							src_link["qty_stk"] = src_link["qty_linkto_alloctbl"].to_f
							qty_sch = 0
						else
							src_link["qty_stk"] = qty_sch - (src_link["qty_stk"].to_f - src_link["qty_linkto_alloctbl"].to_f)
							qty_sch -= (src_link["qty"].to_f - src_link["qty_linkto_alloctbl"].to_f)
						end
						src_link["qty"] = 0
					end
					sql_alloctbl_update = %Q&
						update alloctbls set qty = #{src_link["qty"]} ,qty_stk = #{src_link["qty_stk"]} where id = #{src_link["alloc_id"]}
						&
					ActiveRecord::Base.connection.update(sql_alloctbls_update)
					base_tbl = ActiveRecord::Base.connection.select_one(sql_get_org_free_tbl(src_link))
					if base_tbl
							sql_alloctbl_update = %Q&
								update alloctbls set qty_link_toalloctbl = qty_link_toalloctbl - #{src_link["qty"].to_f + src_link["qty_stk"]}
										 where id = #{base_tbl["alloc_id"]}
								&
							ActiveRecord::Base.connection.update(sql_alloctbls_update)
					else
							p"#{__LINE__} error no base_trngantts \n#{src_link.to_json}"
							raise
					end
				else
					qty_sch -= src_link["qty_src"].to_f
				end
			end
		end
		return
	end

	def sql_get_org_free_tbl(src_link)
		%Q&   ---freeに戻す
					select alloc.qty,alloc.qty_stk,alloc.id alloc_id,alloc.qty_linkto_alloctbl from  alloctbls alloc
								inner join linktbls link on link.tblname = alloc.srctblname and link.tblid = alloc.srctblid  
								inner join trngantts trn on alloc.trngantts_id = trn.id
								where trn.orgtblname = trn.paretblname and trn.paretblname = trn.tblname
								and trn.orgtblid = trn.paretblid and trn.paretblid = trn.tblid
								and link.srctblname = '#{src_link["tblname"]}' and  link.srctblid = #{src_link["tblid"]} 
		&
	end

	def change_alloc_last(links)
		save_qty = @tbldata[@str_qty].to_f
		links.each do |link|
			if save_qty < link["qty_src"].to_f
				qty_src = save_qty
				save_qty = 0
				update_strsql = %Q&
					update linktbls set qty_src = #{qty_src},
							updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss')											
							where id = #{link["id"]}
						& 
				ActiveRecord::Base.connection.update(update_strsql)
				###
				### qtyの減とqtyの在庫修正
				alloc_update_strsql = %Q&
					update alloctbls set #{@str_qty} = #{qty_src},
							updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss')											
							where trngantts_id = #{link["trngantts_id"]}
							and tblname = '#{link["tblname"]}' and tblid = #{link["tblid"]} 
						& 
				ActiveRecord::Base.connection.update(alloc_update_strsql)
				###
				### schs.qty_schの復活とqty_schの在庫修正
				src_alloc_update_strsql = %Q&
					update alloctbls set qty_linkto_alloctbl = qty_linkto_alloctbl - #{link["qty_src"]},
							updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss')												
							where trngantts_id = #{link["trngantts_id"]}
							and srctblname = '#{link["srctblname"]}' and srctblname = '#{link["srctblid"]}' 
						& 
				ActiveRecord::Base.connection.update(src_alloc_update_strsql)
			end
		end
	end

	def init_trngantts_add_detail()
		###@src_no = ""
		###トップ登録時org=pare=tbl

		@trngantts_id = @gantt["id"] = @gantt["trngantts_id"] 
		
		###insts,replyinputs,dlvs,replyinputs,acts,retsはtrnganttsは作成しない。
		ArelCtl.proc_insert_trngantts(@gantt)  ###@ganttの内容をセット
		rec_alloc = {"tblname" => @tblname,"tblid" => @tblid,"trngantts_id" => @trngantts_id,
					"qty_sch" => @gantt["qty_sch"] ,"qty" => @gantt["qty"] ,"qty_stk" => @gantt["qty_stk"] ,
					"qty_linkto_alloctbl" => 0}
		rec_alloc["allocfree"] = if @tblname =~ /ords/
									"free"
								else
									"alloc"
								end
		rec_alloc = ArelCtl.proc_insert_alloctbls(rec_alloc)
		case @tblname	
		when /^purords|^prdords/  ### 単独でxxxordsを画面又はexcelで登録-->mkordinstsを利用してないとき
			###free_ordtbl_alloc_to_sch(stkinout)
			if @mkprdpurords_id == 0 ###mkordinstsの時は子部品展開は対象外
					@reqparams["segment"]  = "mkschs"   ###構成展開
					@reqparams["remark"]  = "Operation.proc_trngantts.init_trngantts_add_detail  構成展開"   ###構成展開
					processreqs_id ,@reqparams = ArelCtl.proc_processreqs_add @reqparams
			end
		when /^custschs|^custords/
			stkinout = ArelCtl.proc_set_stkinout(@gantt)
			stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = @tbldata["shelfnos_id_fm"]
			stkinout["custrcvplcs_id"] = @tbldata["custrcvplcs_id"]
			if @tblname =~ /^custords/
					custords_alloc_to_custschs(stkinout["alloctbls_id"],stkinout)  ###custschsへの引き当て
			end
			@reqparams["segment"]  = "mkprdpurchildFromCustxxxs"   ###構成展開		
			@reqparams["remark"]  = "Operation.init_trngantts_add_detail  pur,prd by custschs,ords"  
			processreqs_id ,@reqparams = ArelCtl.proc_processreqs_add @reqparams
		end
		return
	end

	def update_last_children_shp_con()
		if @tblname =~ /schs/
			shpxxxs = "shpschs"
			conxxxs = "conschs"
			sch_con_qty = @last_rec["qty_sch"].to_f
		else
			shpxxxs = "shpords"
			conxxxs = "conords"
			sch_con_qty = @last_rec["qty"].to_f
		end
		strsql = %Q&
					select * from #{shpxxxs} shp
							inner join #{@tblname}  pare on shp.paretblid = pare.id
							where shp.paretblname = '#{@tblname}' and shp.paretblid = #{@tblid}
				&
		ActiveRecord::Base.connection.select_all(strsql).each do |shp|
			@reqparams["child"] = shp
			Shipment.proc_update_shpschs_ords_by_parent(@reqparams,sch_con_qty) do
				shpxxxs
			end
		end	
		strsql = %Q&
					select * from #{conxxxs} con
							inner join #{@tblname}  pare on con.paretblid = pare.id
							where con.paretblname = '#{@tblname}'  and con.paretblid = #{@tblid}
				&
		ActiveRecord::Base.connection.select_all(strsql).each do |con|
			@reqparams["child"] = con
			Shipment.proc_update_conschs_ords(@reqparams,sch_con_qty) do
						conxxxs
			end
		end
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
		@gantt["qty_free"] = 0 ###child(xxxschs)にfreeはない。  
		### parenum chilnum
		@gantt["id"] = @gantt["trngantts_id"]  = @trngantts_id = ArelCtl.proc_get_nextval("trngantts_seq")
		@gantt["remark"] =  " Operation.child_trngantts  "
		@reqparams["gantt"] = @gantt
		ArelCtl.proc_insert_trngantts(@gantt)

		###親の引き当て処理追加要		
		stkinout = ArelCtl.proc_set_stkinout(@gantt)
		stkinout["qty_linkto_alloctbl"] = 0
		stkinout["remark"] =  " Operation.child_trngantts "
		stkinout["allocfree"]  =  "alloc" 
		ArelCtl.proc_insert_alloctbls(stkinout)
	 	###proc_mk_instks_rec stkinout,"add"
		###元(top)がordsの時のみ子のschsをords等に引き当てる。
		# if @orgtblname =~ /^custschs|^custords|^purords|^prdords/   ###データはxxxschsのデータのみ　
		# 	###新規登録なのでqty_linkto_alloctbl=0
		# 	schstbl_alloc_to_freetbl(stkinout) ###trn==sch
		# end
		if @gantt["qty_handover"].to_f  > 0  
			@reqparams["segment"]  = "mkschs"   ###構成展開
			@reqparams["remark"]  = "Operation line:#{__LINE__}  構成展開 level > 1"  
			processreqs_id ,@reqparams = ArelCtl.proc_processreqs_add @reqparams
		end
		return 
	end


	def custords_alloc_to_custschs alloc_id_of_custord,stkinout
		trn_qty = @tbldata["qty"].to_f
		link_qty = 0
		src_stkinout = stkinout.dup
		strsql = %Q&
					select (alloc.qty_sch - alloc.qty_linkto_alloctbl)  free_qty,
							sch.id sch_id,alloc.trngantts_id trngantts_id,
							ord.id ord_id,sch.duedate src_duedate,sch.shelfnos_id_fm
					from custschs sch
						inner join alloctbls alloc on sch.id = alloc.srctblid
						inner join custords ord on sch.opeitms_id = ord.opeitms_id and sch.custs_id = ord.custs_id
												and sch.prjnos_id = ord.prjnos_id
						where alloc.srctblname = 'custschs' and alloc.qty_sch > alloc.qty_linkto_alloctbl
						and ord.sno = '#{@tbldata["sno"]}'
		&
		ActiveRecord::Base.connection.select_all(strsql).each do |rec|
			if trn_qty >= rec["free_qty"].to_f   ### rec["free_qty"]:custschsの未引き当て
				alloc_qty =  rec["free_qty"].to_f
				trn_qty -= rec["free_qty"].to_f
			else
				alloc_qty =  trn_qty
				trn_qty = 0
			end
			link_qty += alloc_qty
			rec_alloc = {"tblname" => "custords","tblid" => rec["ord_id"],"trngantts_id" => rec["trngantts_id"],
							"qty_sch" => 0,"qty" => alloc_qty,"qty_stk" => 0,"qty_linkto_alloctbl" => 0,
							"remark" => "line #{__LINE__} #{Time.now}","allocfree" => "alloc"}
			ArelCtl.proc_insert_alloctbls(rec_alloc)
			### custschs在庫減
			src_stkinout["duedate"] = rec["src_duedate"].to_date - 1  ###稼働日・輸送日の考慮要
			src_stkinout["qty_sch"] = alloc_qty * -1
			src_stkinout = Shipment.proc_lotstkhists_in_out("out",src_stkinout)  ##
			src_stkinout["shelfnos_id"] = src_stkinout["shelfnos_id_real"] = rec["shelfnos_id_fm"]
			src_stkinout["duedate"] = rec["src_duedate"] ##稼働日・輸送日の考慮要
			src_stkinout["qty_sch"] = alloc_qty 
			src_stkinout["custrcvplcs_id"] = src_stkinout["srctblid"] = @tbldata["custrcvplcs_id"]
			src_stkinout["wh"] = "custwhs"
			src_stkinout["remark"] = "Operation.custords_alloc_to_custschs"
			Shipment.proc_mk_custwhs_rec("in",src_stkinout)
			Shipment.proc_check_inoutlotstk "out",src_stkinout
			strsql = %Q&
						update trngantts set qty_handover = qty_handover - #{alloc_qty}}
								where id = #{rec["trngantts_id"]}
			&
			ActiveRecord::Base.connection.update(strsql)
		end
		if link_qty > 0
			strsql = %Q&
						update alloctbls set qty_linkto_alloctbl = #{link_qty}
								where id = #{alloc_id_of_custord}
			&
			ActiveRecord::Base.connection.update(strsql)
		end
	end	
	def proc_update_inoutlot_and_src_stk(inout,wh,lotstk)
		link_sql = %Q&   ---linktblsはror_blkctlで作成済
					select * from  linktbls link
							where link.tblname ='#{@tblname}' and link.tblid = #{@tblid} and link.qty_src > 0
							--- and (link.tblid != link.srctblid or link.tblname != link.srctblname)
					&  ###
		links = ActiveRecord::Base.connection.select_all(link_sql)
		stkinout = {}
		srcs = []
		if inout == "out"
			plusminus = -1
		else ### in update
			plusminus = 1
		end
		base_qty = lotstk[@str_qty].to_f
		stkinout["srctblname"] = wh
		stkinout["srctblid"] = lotstk["#{wh}_id"]
		stkinout["tblname"] = @tblname
		stkinout["tblid"] = @tblid
		stkinout["srctblid"] = lotstk["#{wh}_id"]
		stkinout["qty_sch"] = stkinout["qty"] = stkinout["qty_stk"] = 0
		links.each do |link|
			break if base_qty <= 0
			stkinout["trngantts_id"] = link["trngantts_id"]
			srcStrQty = case link["srctblname"]  ###xxxactsがxxxords又はxxxinsts・・・に引き当っているかはわからない。
						when /acts$|rets$/
							"qty_stk"
						when /custdlvs$/
							 if wh == "custwhs"
								"qty"
							 else
								"qty_stk"
							 end
						when /purdlvs$/
							if wh == "supplierwhs"
								"qty_stk"
							 else
								"qty"
							 end
						when /schs$/
							"qty_sch"
						else  
							"qty_sch"
						end
			if base_qty >= link["qty_src"].to_f
				new_src_qty = link["qty_src"].to_f
				base_qty -= new_src_qty
			else   ###下記のケースはないはず
				new_src_qty = base_qty
				base_qty = 0
			end
			strsql = %Q&
						select * from inoutlotstks where trngantts_id = #{link["trngantts_id"]}
									and tblid = #{link["tblid"]} and tblname = '#{link["tblname"]}'
									for update
					&   ###trngantts_id,tblidでinoutlotstksはユニーク
			inoutlotstk = ActiveRecord::Base.connection.select_one(strsql)
			if inoutlotstk
				updatesql = %Q&
						update inoutlotstks set #{srcStrQty} = #{srcStrQty} + #{new_src_qty * plusminus},
									remark = 'Operation.update_inoutlot_and_src_stk line #{__LINE__}'
						where id = #{inoutlotstk["id"]}
					&
				ActiveRecord::Base.connection.update(updatesql)
			else
				stkinout[@str_qty] = new_src_qty * plusminus
				ActiveRecord::Base.connection.insert(Shipment.proc_insert_inoutlotstk_sql(plusminus,stkinout))
			end

			if link["tblid"] != link["srctblid"]  ###lotstkhists はlink["tblid"] == link["srctblid"]の時変更済
				src_strsql = %Q&
						select * from inoutlotstks where trngantts_id = #{link["trngantts_id"]}
									and tblid = #{link["srctblid"]} and tblname = '#{link["srctblname"]}'
									for update
					&   ###trngantts_id,tblidでinoutlotstksはユニーク
				src_inout = ActiveRecord::Base.connection.select_one(src_strsql)
				if src_inout
					updatesql = %Q&
						update inoutlotstks set #{srcStrQty} = #{srcStrQty} - #{new_src_qty * plusminus},
									remark = 'Operation.update_inoutlot_and_src_stk line #{__LINE__}'
						where id = #{src_inout["id"]}
					&
					ActiveRecord::Base.connection.update(updatesql)
					src =  ActiveRecord::Base.connection.select_one(%Q%select * from #{src_inout["srctblname"]} where id = #{src_inout["srctblid"]}%)
					case src_inout["srctblname"]
					when "lotstkhists"
						src_sql = %Q%select * from lotstkhists where
									starttime >= to_timestamp('#{src["starttime"]}','yyyy/mm/dd hh24:mi:ss') and 
									itms_id = #{src["itms_id"]} and processseq = #{src["processseq"]} and
									shelfnos_id = #{src["shelfnos_id"]} and shelfnos_id_real = #{src["shelfnos_id_real"]} and
									lotno = '#{src["lotno"]}' and packno = '#{src["packno"]}' and
									prjnos_id = #{src["prjnos_id"]} order by starttime
								%
					else ###custwhs,suppierwhs 該当の入出庫のみ対象
						src_sql = %Q%select * from #{src_inout["srctblname"]} where id = #{src_inout["srctblid"]}
								%
					end				
					src_hists = ActiveRecord::Base.connection.select_all(src_sql)
					src_hists.each do |hist|
						updatesql = %Q&
							update lotstkhists set #{srcStrQty} = #{srcStrQty} - #{new_src_qty * plusminus},
									remark = 'Operation.update_inoutlot_and_src_stk line #{__LINE__}'
							where id = #{hist["id"]}
							&
						ActiveRecord::Base.connection.update(updatesql)
					end
				else
					Rails.logger.debug"error update_inoutlot_and_src_stk link :引き当て元在庫更新  "
					Rails.logger.debug"error update_inoutlot_and_src_stk link :#{link}  "
					Rails.logger.debug"error update_inoutlot_and_src_stk link :#{stkinout}  "
					raise
				end
			end
		end
	end
end   #class
	
end   #module