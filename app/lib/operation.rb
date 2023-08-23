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
		@tbldata["processseq"] = @gantt["processseq_trn"]  
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
		@str_qty = case @tblname
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
			### viewはr_xxxxxxsのみ
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
			return if @gantt.nil?
			chng_flg = check_shelfnos_duedate_qty()  ###
			return if chng_flg == ""
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
			####
			if chng_flg =~ /qty/ 
				###数量の変更があるときはalloctblsも修正する。
				case @tblname
				when /^prdschs|^purschs/   ###schsが減されfreeのordsが発生。xxxschsがtopの時のみ変更可能
					strsql = %Q&  ---alloctblsはrorblkvtlで更新済
								select alloc.* from alloctbls alloc
										where alloc.srctblname = '#{@tblname}' and alloc.srctblid = #{@tblid}
										and trngantts_id = #{@trngantts_id}
							&
					base_alloc = ActiveRecord::Base.connection.select_one(strsql)
					base_sch_alloc_update(base_alloc)  
					###schsが減された時:ords,insts,actsをfreeに　qty_schが増、減されたときshp,conの変更、###在庫の処理を含む
					###trnganttsは修正済  alloctblsは一件のみ
				when /^custschs|^custords/
					###引当済以下の数量減は不可。画面,importでチェック済のこと
					qty =  @tbldata[@str_qty].to_f
					strsql = %Q&
							select * from linkcusts where tblname = '#{@tblname}' and tblid = #{@tblid}
					&
					ActiveRecord::Base.connection.select_all(strsql).each do |link|
						if qty < link["qty_src"].to_f
							update_sql = %Q&
								update linkcusts 
									set qty_src = #{qty},remark = ' #{self} line:#{__LINE__}'||remark
									where id = #{link["id"]}
							&
							ActiveRecord::Base.connection.update(update_sql)
							update_sql = %Q&
								update linkcusts 
									set qty_src = qty_src + #{link["qty_src"]} - #{qty},remark = ' #{self} line:#{__LINE__}' ||remark
									where tblname = '#{link["srctblname"]}}' and tblid = #{link["srctblid"]}
									and srctblname = '#{link["srctblname"]}}' and srctblid = #{link["srctblid"]}
							&
							ActiveRecord::Base.connection.update(update_sql)
							qty = 0
						else
							qty -= link["qty_src"].to_f
						end
					end
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
			if top_trngantt["mlevel"].to_i  == 0
				lowlevel_gantts = []
				lowlevel_gantts[0] = top_trngantt
				until lowlevel_gantts.empty?
					lgantt = lowlevel_gantts.shift
					trns = ActiveRecord::Base.connection.select_all(ArelCtl.proc_pareChildTrnsSql(lgantt))
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
		if @reqparams["classname"] =~ /_insert_|_add_/  ###trngantts 追加
			base = {}
			cust_base = {}
			supp_base = {}
			base["itms_id"] = @gantt["itms_id_trn"]
			base["processseq"]  = @gantt["processseq_trn"]
			base["prjnos_id"]  = @gantt["prjnos_id"]
			base["tblname"]  = @gantt["tblname"]
			base["tblid"]  = @gantt["tblid"]
			base["persons_id_upd"]  = @gantt["persons_id_upd"]
			base["qty_sch"] = base["qty"] = base["qty_stk"] = 0
			inout = "in"
			base["wh"] = "lotstkhists"
			case @tblname
			when /^cust/
				###社内倉庫の更新
				base["shelfnos_id"] =  @tbldata["shelfnos_id_fm"]
				inout = "out" 
				case @tblname 
				when  "custacts"
					base["starttime"] = (@tbldata["saledate"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					base["qty_stk"] = @tbldata["qty_stk"]
				when "custrets"
					base["starttime"] = (@tbldata["retdate"].to_time + 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  
					### 例外
					inout = "in"
					base["qty_stk"] = @tbldata["qty_stk"]
				when "custdlvs"  
					base["starttime"] = (@tbldata["depdate"].to_time ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					base["qty_stk"] =  @tbldata["qty_stk"]
				when /^custords|^custinsts/  
					base["starttime"] = (@tbldata["duedate"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					base["qty"] =  @tbldata["qty"]
				when /^custschs/  
					base["starttime"] = (@tbldata["duedate"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					base["qty_sch"] =  @tbldata["qty_sch"]
				end
				###客先倉庫の更新
				cust_base = base.dup
				cust_base["custrcvplcs_id"] = @tbldata["custrcvplcs_id"]
				cust_base["wh"] = "custwhs"
				cust_inout = "in" 
				case @tblname 
				when  "custacts"
					cust_base["starttime"] = (@tbldata["saledate"].to_time ).strftime("%Y-%m-%d %H:%M:%S")  #
					cust_base["remark"] = "Operation line #{__LINE__}"
				when "custrets"  ###packnoはない
					cust_base["starttime"] = (@tbldata["retdate"].to_time - 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					cust_base["remark"] = "Operation line #{__LINE__}"
					###例外
					cust_inout = "out" 
				when "custdlvs"  ###packnoはない
					cust_base["starttime"] = (@tbldata["dlvdate"].to_time + 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					base["qty"] = @tbldata["qty_stk"]   ###客先は未だ予定
					cust_base["remark"] = "Operation line #{__LINE__}"
				else
					cust_base["starttime"] = (@tbldata["duedate"].to_time).strftime("%Y-%m-%d %H:%M:%S")  
					cust_base["remark"] = "#{self}  line #{__LINE__}"
				end
			when /^purdlvs/  ###packnoはない
				base["shelfnos_id"] =  @tbldata["shelfnos_id_to"]
				base["starttime"] = (@tbldata["depdate"].to_time + 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				base["qty"] = @tbldata["qty_stk"]
				base["remark"] = "#{self}  line #{__LINE__}"
				supp_inout = "out"
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
				base = Shipment.proc_lotstkhists_in_out(inout,base)  ###在庫の更新
				case @tblname
				when /^prdacts|^puracts|^purdlvs/
					ActiveRecord::Base.connection.select_all(ArelCtl.proc_ChildConSql(@tbldata)).each do |conord|
						next if conord["consumauto"] == "M"  ### qty_stk確定時の消費手動は除く
						dupParams = @reqparams.dup
						dupParams["child"] = conord
						dupParams["parent"] = @tbldata
						Shipment.proc_create_consume(dupParams) do
							"conacts"
						end
					end
				when /purinsts$|purreplyinputs$|prdinsts$/
					ActiveRecord::Base.connection.select_all(ArelCtl.proc_ChildConSql(@tbldata)).each do |conord|
						dupParams = @reqparams.dup
						dupParams["child"] = conord
						dupParams["parent"] = @tbldata
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
							prevParams["parent"] = prevparetbl
							prevParams["child"] = prevchildtbl
							Shipment.proc_create_consume(prevParams) do
								"conords"
							end
						end
					end
				end
			end
			if !cust_base.empty?		
				cust_base["wh"] = "custwhs"
				cust_base = Shipment.proc_mk_custwhs_rec(inout,cust_base)  ###在庫の更新
			end
			if !supp_base.empty?
				supp_base["wh"] = "supplierwhs"		
				cust_base = Shipment.proc_mk_supplierwhs_rec(inout,supp_base)  ###在庫の更新
			end
			###
			# 明細(inoutlotstks)と前状態の数量変更
			###
			strsql = %Q&
					select srctblname tblname,srctblid tblid,trngantts_id,qty_src,
							tblname savetblname,tblid savetblid
						from #{if @tblname =~ /^cust/  then "linkcusts" else "linktbls" end}
						where id in(#{@reqparams["linktbl_ids"].join(",")})
						and  qty_src > 0
			&
			ActiveRecord::Base.connection.select_all(strsql).each do |src|
				case @tblname
				when /schs$/
				 	src["qty_sch"] = base["qty_sch"] = src["qty_src"]
				when /ords$|insts$|reply/
					src["qty"] = base["qty"] = src["qty_src"]
				when /acts$|dlvs$/
					src["qty_stk"] = base["qty_stk"] = src["qty_src"]
				end
				base["trngantts_id"] = src["trngantts_id"]
				plusminus = if inout == "in"
								1
							else
								-1
							end
				Shipment.proc_insert_inoutlotstk_sql(plusminus,base)  ###新規明細
				if src["savetblname"] != src["tblname"] or src["savetblid"] != src["tblid"]
					ArelCtl.proc_src_base_trn_stk_update(src,base,src["qty_src"].to_f)
				end
				if !cust_base.empty?	
					cust_base["trngantts_id"] = src["trngantts_id"]
					plusminus = if cust_inout == "in"
									1
								else
									-1
								end
					Shipment.proc_insert_inoutlotstk_sql(plusminus,cust_base)	
					if src["savetblname"] != src["tblname"] or src["savetblid"] != src["tblid"]
						ArelCtl.proc_src_base_trn_stk_update(src,cust_base,src["qty_src"].to_f)
					end
				end
				if !supp_base.empty?	
					supp_base["trngantts_id"] = src["trngantts_id"]
					plusminus = if cust_inout == "in"
									1
								else
									-1
								end
					Shipment.proc_insert_inoutlotstk_sql(plusminus,supp_base)	
					if src["savetblname"] != src["tblname"] or src["savetblid"] != src["tblid"]
						ArelCtl.proc_src_base_trn_stk_update(src,supp_base,src["qty_src"].to_f)
					end
				end
			end	
		else ###変更　(削除 qty_sch=qty=qty_stk=0 　を含む) 
			lastStkinout = ArelCtl.proc_set_stkinout(@last_rec) 
			lastStkinout["persons_id_upd"] = @tbldata["persons_id_upd"]
			stkinout = @tbldata.dup
			case @tblname
			when /^cust/
				###社内倉庫の更新
				lastStkinout["shelfnos_id"] =  @last_rec["#{@tblname.chop}_shelfno_id_fm"]
				lastStkinout["prjnos_id"] =  @last_rec["#{@tblname.chop}_prjno_id"]

				stkinout["wh"] = lastStkinout["wh"] = "lotstkhists"
				case @tblname 
				when  "custacts" 
					lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_saledate"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					lastStkinout = Shipment.proc_lotstkhists_in_out("in",lastStkinout)  ###前の在庫の更新　一旦全数削除
					proc_update_inoutlot_and_src_stk("in","lotstkhists",lastStkinout)
					stkinout["shelfnos_id"] = @tbldata["shelfnos_id_fm"]
					stkinout["starttime"] = (@tbldata["saledate"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				when "custrets"
					lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_retdate"].to_time + 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  
					lastStkinout[@str_qty] = lastStkinout[@str_qty] * -1   ###retのみ例外
					lastStkinout = Shipment.proc_lotstkhists_in_out("in",lastStkinout)  ###前の在庫の更新　
					proc_update_inoutlot_and_src_stk("out","lotstkhists",lastStkinout)
					stkinout["starttime"] = (@tbldata["retdate"].to_time + 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  
					### 例外
					inout = "in"
				when "custdlvs"  
					lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_depdate"].to_time ).strftime("%Y-%m-%d %H:%M:%S")  
					lastStkinout = Shipment.proc_lotstkhists_in_out("in",lastStkinout)  ###前の在庫の更新　
					proc_update_inoutlot_and_src_stk("in","lotstkhists",lastStkinout)
					stkinout["starttime"] = (@tbldata["depdate"].to_time ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				else  
					lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_duedate"].to_time - 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  
					lastStkinout = Shipment.proc_lotstkhists_in_out("in",lastStkinout)  ###前の在庫の更新　
					proc_update_inoutlot_and_src_stk("in","lotstkhists",lastStkinout)
					stkinout["starttime"] = (@tbldata["duedate"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				end
				if stkinout[@str_qty].to_f > 0
					stkinout["shelfnos_id"] =  @tbldata["shelfnos_id_fm"]
					stkinout = Shipment.proc_lotstkhists_in_out("out",stkinout)  ###在庫の更新
					proc_update_inoutlot_and_src_stk("out","lotstkhists",stkinout)
				end
				###客先倉庫の更新
				stkinout["custrcvplcs_id"] = @tbldata["custrcvplcs_id"]
				lastStkinout["custrcvplcs_id"] = @last_rec["#{@tblname.chop}_custrcvplc_id"]  
				stkinout["remark"] = " #{self}  line #{__LINE__}"
				stkinout["wh"] = "custwhs"
				inout = "in" 
				case @tblname 
				when  "custacts"
					lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_saledate"].to_time ).strftime("%Y-%m-%d %H:%M:%S")  #
					lastStkinout = Shipment.proc_mk_custwhs_rec("out",lastStkinout)
					proc_update_inoutlot_and_src_stk("out","custwhs",lastStkinout)
					stkinout["starttime"] = (@tbldata["saledate"].to_time ).strftime("%Y-%m-%d %H:%M:%S")  #
				when "custrets"  ###packnoはない
					lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_retdate"].to_time - 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					lastStkinout[@str_qty] = lastStkinout[@str_qty] * -1   ###retのみ例外
					lastStkinout = Shipment.proc_mk_custwhs_rec("in",lastStkinout)
					proc_update_inoutlot_and_src_stk("in","custwhs",lastStkinout)
					stkinout["starttime"] = (@tbldata["retdate"].to_time - 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					###例外
					inout = "out" 
				when "custdlvs"  ###packnoはない
					lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_dlvdate"].to_time + 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					lastStkinout = Shipment.proc_mk_custwhs_rec("out",lastStkinout)
					proc_update_inoutlot_and_src_stk("out","custwhs",lastStkinout)
					stkinout["starttime"] = (@tbldata["dlvdate"].to_time + 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				else
					lastStkinout = Shipment.proc_mk_custwhs_rec("out",lastStkinout)
					proc_update_inoutlot_and_src_stk("out","custwhs",lastStkinout)
					stkinout["starttime"] = (@tbldata["duedate"].to_time).strftime("%Y-%m-%d %H:%M:%S")  
				end
				if stkinout[@str_qty].to_f > 0
					stkinout["shelfnos_id"] =  @tbldata["shelfnos_id_to"]
					stkinout = Shipment.proc_mk_custwhs_rec("in",stkinout)
					proc_update_inoutlot_and_src_stk("in","custwhs",stkinout)
				end
			# when /^prdrets/
			# 	stkinout = Shipment.proc_lotstkhists_in_out("in",lastStkinout)  ###在庫の更新
			# 	proc_update_inoutlot_and_src_stk("in","lotstkhists",lastStkinout)
			# 	if stkinout[@str_qty].to_f > 0
			# 		stkinout = Shipment.proc_lotstkhists_in_out("out",stkinout)  ###在庫の更新
			# 		proc_update_inoutlot_and_src_stk("out","lotstkhists",stkinout)
			# 	end
			# when /^purrets/   
			# 	stkinout = Shipment.proc_lotstkhists_in_out("in",lastStkinout)  ###在庫の更新
			# 	proc_update_inoutlot_and_src_stk("in","lotstkhists",lastStkinout)
			# 	lastStkinout["shelfnos_id"] =  @last_rec["shelfnos_id_fm"]
			# 	lastStkinout["starttime"] = (@last_rec["retdate"].to_time + 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
			# 	lastStkinout["suppliers_id"] = @last_rec["supplers_id"]
			# 	lastStkinout = Shipment.proc_mk_supplierwhs_rec("out",lastStkinout)
			# 	proc_update_inoutlot_and_src_stk("out","suppliers",lastStkinout)
			# 	if stkinout[@str_qty].to_f > 0
			# 		stkinout = Shipment.proc_lotstkhists_in_out("out",stkinout)  ###在庫の更新
			# 		proc_update_inoutlot_and_src_stk("out","lotstkhists",stkinout)
			# 		stkinout["shelfnos_id"] =  @tbldata["shelfnos_id_fm"]
			# 		stkinout["starttime"] = (@tbldata["retdate"].to_time + 24*3600 ).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
			# 		stkinout["suppliers_id"] = @tbldata["supplers_id"]
			# 		stkinout = Shipment.proc_mk_supplierwhs_rec("out",stkinout)
			# 		proc_update_inoutlot_and_src_stk("out","suppliers",stkinout)
			# 	end
			when /^purdlvs/  ###packnoはない
				lastStkinout["starttime"] = (@last_rec["#{@tblname.chop}_depdate"].to_time + 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				lastStkinout = Shipment.proc_lotstkhists_in_out("out",lastStkinout)  ###在庫の更新
				proc_update_inoutlot_and_src_stk("out","lotstkhists",lastStkinout)
				lastStkinout["shelfnos_id"] =  @last_rec["#{@tblname.chop}_shelfno_id_fm"]
				lastStkinout["starttime"] = @last_rec["#{@tblname.chop}_depdate"] ###カレンダー考慮要
				lastStkinout["suppliers_id"] = @last_rec["#{@tblname.chop}_suppler_id"]
				Shipment.proc_mk_supplierwhs_rec("in",lastStkinout)
				proc_update_inoutlot_and_src_stk("in","suppliers",stkinout)
				if stkinout[@str_qty].to_f > 0
					stkinout["starttime"] = (@tbldata["depdate"].to_time + 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
					stkinout = Shipment.proc_lotstkhists_in_out("in",stkinout)  ###在庫の更新
					proc_update_inoutlot_and_src_stk("in","suppliers",stkinout)
					stkinout["shelfnos_id"] =  @tbldata["shelfnos_id_fm"]
					stkinout["starttime"] = @tbldata["depdate"] ###カレンダー考慮要
					stkinout["suppliers_id"] = @tbldata["supplers_id"]
					Shipment.proc_mk_supplierwhs_rec("out",stkinout)
					proc_update_inoutlot_and_src_stk("out","suppliers",stkinout)
				end
			when /^prdacts|^puracts/
				strsql = %Q&
							select trn.id,sum(alloc.qty_linkto_alloctbl) qty_sch,
									0 qty,0 qty_stk	 from trngantts trn
									inner join alloctbls alloc on trn.id = alloc.trngantts_id
								where alloc.srctblname = '#{@tblname}' and alloc.srctblid = #{@tblid}
								and alloc.qty_linkto_alloctbl > 0 and alloc.srctblname like '%schs'
								group by trn.id
							union
								select trn.id,sum(alloc.qty_linkto_alloctbl) qty,
										0 qty_sch,0 qty_stk	 from trngantts trn
										inner join alloctbls alloc on trn.id = alloc.trngantts_id
									where alloc.srctblname = '#{@tblname}' and alloc.srctblid = #{@tblid}
									and alloc.qty_linkto_alloctbl > 0 
									and (alloc.srctblname like '%ords' or alloc.srctblname like '%insts' or alloc.srctblname like '%dlvs'
											or alloc.srctblname like '%reply%')
									group by trn.id
							union
								select trn.id,sum(alloc.qty_linkto_alloctbl) qty_stk,
										0 qty,0 qty_sch	 from trngantts trn
										inner join alloctbls alloc on trn.id = alloc.trngantts_id
									where alloc.srctblname = '#{@tblname}' and alloc.srctblid = #{@tblid}
									and alloc.qty_linkto_alloctbl > 0 and alloc.srctblname like '%acts'
									group by trn.id 
						&
				ActiveRecord::Base.connection.select_values(strsql).each do |stk|
						update_sql = %Q&
								update trngantts set qty_stk = #{stk["qty_stk"]},qty = #{stk["qty"]},qty_sch = #{stk["qty_sch"]},
									remark = '#{self}  line #{__LINE__}'||remark,
									updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss')
									where id = #{stk["id"]}
							&
						ActiveRecord::Base.connection.update(update_sql)
				end
				stkinout = Shipment.proc_lotstkhists_in_out("in",stkinout)  ###在庫の更新
				proc_update_inoutlot_and_src_stk("in","lotstkhists",stkinout)
			when /^prd|^pur/
				stkinout = Shipment.proc_lotstkhists_in_out("out",lastStkinout)  ###在庫の更新
				proc_update_inoutlot_and_src_stk("out","lotstkhists",lastStkinout)
				if stkinout[@str_qty].to_f > 0
					stkinout = Shipment.proc_lotstkhists_in_out("in",stkinout)  ###在庫の更新
					proc_update_inoutlot_and_src_stk("in","lotstkhists",stkinout)
				end
			end
		end		
		return 		
	end

	def update_prdpur_child(trn)
		screenCode = "r_" + trn["tblname"]
		strsql = %Q&
				select * from #{trn["tblname"]} where id = #{trn["tblid"]}
		&
		rec = ActiveRecord::Base.connection.select_one(strsql)
		blk = RorBlkCtl::BlkClass.new(screenCode)
		command_c = blk.command_init
		rec.each do |key,val|
			command_c[%Q&#{trn["tblname"].chop}_#{key.sub("s_id","_id")}&] = val
		end
		command_c["sio_classname"] = "_update_#{trn["tblname"]}_update_prdpur_child"
		command_c["id"] = rec["id"]
		command_c["#{trn["tblname"].chop}_remark"] = " Operation.update_prdpur_child line:#{__LINE__} "
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
		starttime = CtlFields.proc_field_starttime(command_c["#{trn["tblname"].chop}_duedate"],trn,"gantt")
		command_c["#{trn["tblname"].chop}_starttime"] = starttime
		@gantt["tblname"] = trn["tblname"]
		@gantt["tblid"] = trn["tblid"]
		@gantt["mlevel"] = trn["mlevel"]
		@reqparams["tbldata"] = rec
		blk.proc_create_tbldata(command_c)
		blk.proc_add_update_table(@reqparams,command_c)
		@gantt["paretblname"] = trn["tblname"]
		@gantt["paretblid"] = trn["tblid"]
	end

	def get_last_rec
		strsql = %Q&---最後に登録・修正されたレコード
		select 	opeitm_itm_id itms_id,opeitm_processseq processseq,sio.*
				 from sio.sio_r_#{@tblname} sio where id = #{@tblid} 
					order by sio_id desc limit 1
		&
		@last_rec = ActiveRecord::Base.connection.select_one(strsql)
		@last_rec["tblname"] = @tblname
		@last_rec["tblid"] = @tblid
	end
	
	def check_shelfnos_duedate_qty
		chng_flg = ""
		if @tbldata[@str_qty].to_f != @last_rec[@str_qty].to_f  
			 chng_flg << "qty"
		end
		if @tbldata[@str_duedate] != @last_rec[@str_duedate]
			chng_flg << "due"
		end
		if @tbldata["shelfnos_id_to"] != @last_rec["#{@tblname.chop}_shelfno_id_to"]
			chng_flg << "shelfno"
		end
		if @tbldata["shelfnos_id"] != @last_rec["#{@tblname.chop}_shelfno_id"]
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
				select link.*,alloc.qty_linkto_alloctbl qty_linkto_alloctbl,alloc.id alloc_id
					from linktbls link   ---srctblname :xxxxschs
				inner join alloctbls alloc on link.trngantts_id = alloc.trngantts_id
					where trngantts_id = #{@trngantts_id}  ---既にordsからacts等になったtbl　を含む
					and  alloc.qty_linkto_alloctbl > 0
				&
			qty_sch = @tbldata["qty_sch"].to_f
			src_link = ActiveRecord::Base.connection.select_one(link_strsql)  ###topでは一対一のはず
			if qty_sch < src_link["qty_linkto_alloctbl"].to_f   ###ords,insts・・・では　qty < src_link["qty_src"].to_fは不可
				sql_alloctbl_update = %Q&
						update alloctbls set  qty_linkto_alloctbl = #{qty_sch},
								updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss') ,
								remark = '#{self} line:(#{__LINE__})'|| remark
								where id = #{src_link["alloc_id"]}
						&
				ActiveRecord::Base.connection.update(sql_alloctbls_update)
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
		end
		return
	end

	def change_alloc_last(links)
		save_qty = @tbldata[@str_qty].to_f
		links.each do |link|
			if save_qty < link["qty_src"].to_f
				qty_src = save_qty
				save_qty = 0
				update_strsql = %Q&
					update linktbls set qty_src = #{qty_src},
							updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss')	,
							remark = '#{self} line:(#{__LINE__})'|| remark										
							where id = #{link["id"]}
						& 
				ActiveRecord::Base.connection.update(update_strsql)
				###
				### schs.qty_schの復活とqty_schの在庫修正
				src_alloc_update_strsql = %Q&
					update alloctbls set qty_linkto_alloctbl = qty_linkto_alloctbl - #{link["qty_src"]},
							updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
							remark = '#{self} line:(#{__LINE__})'|| remark
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

		@trngantts_id = @gantt["id"] = @gantt["trngantts_id"] = ArelCtl.proc_get_nextval("trngantts_seq")
		
		###insts,replyinputs,dlvs,replyinputs,acts,retsはtrnganttsは作成しない。
		linktbl_id,alloc_id = ArelCtl.proc_insert_trngantts(@gantt)  ###@ganttの内容をセット
		@reqparams["linktbl_ids"] = [linktbl_id]
		@reqparams["alloctbl_ids"] = [alloc_id]
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
		linktbl_id,alloctbl_id = ArelCtl.proc_insert_trngantts(@gantt)  ###@ganttの内容をセット
		@reqparams["linktbl_ids"] = [linktbl_id]

	 	###proc_mk_instks_rec stkinout,"add"
		if @gantt["qty_handover"].to_f  > 0  and  @gantt["tblname"] != "dymschs"
			@reqparams["segment"]  = "mkschs"   ###構成展開
			@reqparams["remark"]  = "#{self}  line:#{__LINE__}  構成展開 level > 1"  
			processreqs_id ,@reqparams = ArelCtl.proc_processreqs_add @reqparams
		end
		return 
	end


	def proc_update_inoutlot_and_src_stk(inout,wh,lotstk)
		if inout == "out"
			plusminus = -1
		else ### in update
			plusminus = 1
		end
		
		link_sql = %Q&   ---
					select link.srctblname,link.srctblid,link.tblname,link.tblid,link.trngantts_id,link.qty_src
						from  #{if @tblname =~ /^cust/ then "linkcusts" else "linktbls" end} link
						where link.tblname ='#{@tblname}' and link.tblid = #{@tblid} and link.qty_src > 0
							--- and (link.tblid != link.srctblid or link.tblname != link.srctblname)
					&  ###
		links = ActiveRecord::Base.connection.select_all(link_sql)
		stkinout = {}
		srcs = []
		base_qty = lotstk[@str_qty].to_f
		stkinout = lotstk.dup
		stkinout["wh"] = wh
		stkinout["srctblid"] = lotstk["#{wh}_id"]
		stkinout["tblname"] = @tblname
		stkinout["tblid"] = @tblid
		stkinout["qty_sch"] = stkinout["qty"] = stkinout["qty_stk"] = 0
		links.each do |link|
			break if base_qty <= 0
			stkinout["trngantts_id"] = link["trngantts_id"]
			srcStrQty = case link["srctblname"]  ###xxxactsがxxxords又はxxxinsts・・・に引き当っているかはわからない。
						when /acts$|rets$|rsltinputs$/
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
						when /ords$|insts$|replyinputs$/
							"qty"
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

			if link["tblid"] == link["srctblid"]  ###lotstkhists はlink["tblid"] == link["srctblid"]の時変更済
				tmp = link.dup
				tmp["srctblid"] = lotstk["#{wh}_id"]
				tmp["srctblname"] = wh
				tmp[@str_qty] = new_src_qty
				tmp["remark"] = "Operation line #{__LINE__}"
				Shipment.proc_check_inoutlotstk(inout,tmp)
			else
				src_strsql = %Q&
						select * from inoutlotstks where trngantts_id = #{link["trngantts_id"]}
									and tblid = #{link["srctblid"]} and tblname = '#{link["srctblname"]}'
									for update
					&   ###tblidでinoutlotstksはユニーク
				src_inout = ActiveRecord::Base.connection.select_one(src_strsql)
				if src_inout
					new_src_qty = new_src_qty - src_inout[@str_qty].to_f 
					updatesql = %Q&
						update inoutlotstks set #{srcStrQty} = #{srcStrQty} - #{new_src_qty * plusminus},
									updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
									remark = '#{self}  line #{__LINE__}'||remark
						where id = #{src_inout["id"]}
					&
					ActiveRecord::Base.connection.update(updatesql)
					src =  ActiveRecord::Base.connection.select_one(%Q%select * from #{src_inout["srctblname"]} where id = #{src_inout["srctblid"]}%)
					case src_inout["srctblname"]
					when "lotstkhists"
						src_sql = %Q%select * from lotstkhists where
									starttime >= to_timestamp('#{src["starttime"]}','yyyy/mm/dd hh24:mi:ss') and 
									itms_id = #{src["itms_id"]} and processseq = #{src["processseq"]} and
									shelfnos_id = #{src["shelfnos_id"]} and 
									lotno = '#{src["lotno"]}' and packno = '#{src["packno"]}' and
									prjnos_id = #{src["prjnos_id"]} order by starttime
								%
					else ###custwhs,suppierwhs 該当の入出庫のみ対象
						src_sql = %Q%select * from #{src_inout["srctblname"]} where id = #{src_inout["srctblid"]}
								%
					end				
					src_hists = ActiveRecord::Base.connection.select_all(src_sql)
					src_hists.each_with_index do |hist,idx|
						if idx == 0
							strsql = %Q&
									select * from inoutlotstks where trngantts_id = #{link["trngantts_id"]}
												and tblid = #{link["tblid"]} and tblname = '#{link["tblname"]}'
												and srctblid = #{src_inout["srctblid"]} and srctblname = '#{src_inout["srctblname"]}'
								&   ###trngantts_id,tblidでinoutlotstksはユニーク
							inoutlot = ActiveRecord::Base.connection.select_one(strsql)
							if inoutlot
								updatesql = %Q&
									update inoutlotstks set #{@str_qty} = #{@str_qty} + #{new_src_qty * plusminus},
												updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
												remark = 'Operation.update_inoutlot_and_src_stk line #{__LINE__}'
									where id = #{inoutlot["id"]}
								&
								ActiveRecord::Base.connection.update(updatesql)
							else
								stkinout[@str_qty] = new_src_qty * plusminus
								stkinout["wh"] = wh
								stkinout["srctblid"] = hist["id"]
								stkinout["tblname"] = @tblname
								stkinout["tblid"] = @tblid
								Shipment.proc_insert_inoutlotstk_sql(plusminus,stkinout)
							end
						end
						updatesql = %Q&
							update #{src_inout["srctblname"]} set #{srcStrQty} = #{srcStrQty} - #{new_src_qty * plusminus},
									updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
									remark = '#{self}  #{__LINE__}'||remark
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