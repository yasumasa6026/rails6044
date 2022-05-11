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
		@gantt["itms_id"]  =  @gantt["itms_id_trn"]
		@gantt["processseq"]  =  @gantt["processseq_trn"]  
		@gantt["starttime"]  =  @gantt["starttime_trn"]    
		@gantt["duedate"]  =  @gantt["duedate_trn"]     
		@gantt["toduedate"]  =  @gantt["toduedate_trn"]  

		@tbldata = params["tbldata"].dup
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
			when /dlvs|acts|rets/
				"qty_stk"
			when /ords|insts|reply/
				"qty"
			else
				"qty_sch"
		end  
	end

	###------------------------------------------------------
	def proc_trngantts()  ###schs,ords専用
		###
		if @reqparams["classname"] =~ /_insert_|_add_/  ###trngantts 追加
			if (@tblid == @paretblid and @tblname == @paretblname) 
				###schs$,ords$--->新規本体を作成  ^pur,^prd 
				init_trngantts_add_detail()
			else ###構成の一部になっているとき(本体を作成後確認)
				child_trngantts()  
			end	
		else ###変更　(削除 qty_sch=qty=qty_stk=0 　を含む) purschs,purords,prdschs,prdords
			@last_rec = get_last_rec()
			return if @last_rec.nil?
			chng_flg = check_shelfnos_duedate_qty()  ###
			return if chng_flg == ""
			###数量・納期・場所の変更があった時
			case @tblname 
			when /ords$/
				strsql = %Q% select * from trngantts where tblname = '#{@tblname}' and tblid = #{@tblid}
						  and orgtblname = paretblname and paretblname = tblname
						  and orgtblid = paretblid and paretblid = tblid
				%
				@gantt = ActiveRecord::Base.connection.select_one(strsql)
			when /schs$/  ###trngantts_id :xxxschs.id = 1:1
				strsql = %Q% select * from trngantts where tblname = '#{@tblname}' and tblid = #{@tblid}
				%  ###
				@gantt = ActiveRecord::Base.connection.select_one(strsql)
			end
			@trngantts_id =  @gantt["trngantts_id"]  = @last_rec["trngantts_id"] = @gantt["id"]
			### qty,qty_stkはqty_linkto_alloctbl以下にはできない。
			###出庫指示数以下にはできない。
			###locas_idの変更は不可(オンライン、入り口でチェック) 
			###前の在庫　をzeroに
			@last_rec["itms_id"] = @opeitm["itms_id"]
			@last_rec["processseq"] = @opeitm["processseq"]
			last_stkinout = ArelCtl.proc_set_stkinout(@last_rec) ###@last_rec get from "check_shelfnos_duedate_qty"
			last_stkinout["wh"] = "lotstkhists"
			last_stkinout[@str_qty] =  @last_rec[@str_qty].to_f * -1
			strsql = %Q&  ---alloctblsはrorblkvtlで更新済
						select alloc.* from alloctbls alloc
								where alloc.srctblname = '#{@tblname}' and alloc.srctblid = #{@tblid}
								and trngantts_id = #{@trngantts_id}
					&
			base_alloc = ActiveRecord::Base.connection.select_one(strsql)
			last_stkinout[@str_qty] =  last_stkinout[@str_qty] + base_alloc["qty_linkto_alloctbl"].to_f  
			set_lotstkhists_custwhs_supplierwhs(last_stkinout,nil)	
			stkinout = ArelCtl.proc_set_stkinout(@gantt) 
			stkinout["wh"] = "lotstkhists"		
			stkinout[@str_qty] =  stkinout[@str_qty] - base_alloc["qty_linkto_alloctbl"].to_f
			set_lotstkhists_custwhs_supplierwhs(stkinout,nil) if stkinout[@str_qty] > 0
			case @tblname
			when /^prdschs|^prdprds|^purschs|^purords/
				###子部品の出庫・消費・在庫の処理
				update_last_children_shp_con()  
			when /^cust/
			end
			###新shelfnos_id_fmで出庫・消費を作成(数量増の変更で対応)
			###数量又は納期の変更があった時   xxxsxhs,xxxordsの時のみ
			strsql = %Q&update trngantts set   --- xxschs,xxxordsが変更された時のみ
							updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
							prjnos_id = #{@tbldata["prjnos_id"]},duedate_trn = '#{@tbldata["duedate"]}',
							qty_sch = #{@tbldata["qty_sch"]},qty = #{@tbldata["qty"]},qty_stk = #{@tbldata["qty_stk"]},
							remark = 'operation line:#{__LINE__}'
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
					change_alloc_last_stkinout(links,last_stkinout,stkinout) 
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
		command_c[:sio_classname] = "_update_#{tblname}_update_prdpur_child"
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
		blk.proc_create_src_tbl(command_c)
		blk.proc_add_update_table(params,command_c)
	end

	def get_last_rec
		strsql = %Q&---最後に登録・修正されたレコード
		select '#{@tblname}' tblname,id tblid,
				opeitm_itm_id itms_id,opeitm_processseq processseq,
				#{@tblname.chop}_shelfno_id_to shelfnos_id_to,#{@tblname.chop}_shelfno_id_fm shelfnos_id_fm,
				#{@tblname.chop}_prjno_id prjnos_id,
				#{@tblname.chop}_#{@str_duedate} #{@str_duedate},
				#{@tblname.chop}_packno packno,#{@tblname.chop}_lotno lotno,
				#{@tblname.chop}_#{@str_qty} #{@str_qty}
				 from sio.sio_r_#{@tblname} where id = #{@tblid} 
					order by sio_id desc limit 1
		&
		ActiveRecord::Base.connection.select_one(strsql)
	end
	
	###--------------------------------------------------------------------------------------------
	###linktblsの追加はRorBlkctlで完了済のこと。
	def proc_add_update_lotstkhists()  ###insts,reply,dlvs,acts,rets専用
		###
		### /insts|replyinputs|dlvs|acts|replyinputs/ではtrnganttsは作成しない。
			###trnganttsがあるのはxxxschsとxxxordsのみ
		### 前の状態の予定在庫補正。linktbls,alloctblsはrorblkctlで修正済
		### qty,qty_stkはqty_linkto_alloctbl以下にはできない。
		###出庫指示数以下にはできない。
		###qty_linkto_alloctbl > 0 の時はlocas_idの変更は不可(オンライン、入り口でチェック)
		###shelfnos_id_fmの変更はinsts,reply,dlvs,acts,retsでは不可
		stkinout = ArelCtl.proc_set_stkinout(@gantt) 
		stkinout["wh"] = "lotstkhists"
		if @reqparams["classname"] =~ /_insert_|_add_/  ###trngantts 追加
			save_src = {"srctblid" => ""}
			link_sql = %Q&   ---linktblsはror_blkctlで作成済
						select * from  linktbls link
								where link.tblname ='#{@tblname}' and link.tblid = #{@tblid} and link.qty_src > 0
						&  ###tblname:acts srctblname:dlvsは在庫補正の対象外
			ActiveRecord::Base.connection.select_all(link_sql).each do |link|
				src = ActiveRecord::Base.connection.select_one(%Q&
						select * from #{link["srctblname"]} where id = #{link["srctblid"]}&)
				src["itms_id"] = @opeitm["itms_id"]
				src["processseq"] = @opeitm["processseq"]
				prev_stkinout = ArelCtl.proc_set_stkinout(src)
				prev_stkinout["wh"] = "lotstkhists"
					tmp_str_qty = case @tblname
								when /dlvs|acts|rets/
									"qty_stk"
								when /ords|insts|reply/
									"qty"
								else
									"qty_sch"
								end
				prev_stkinout[tmp_str_qty] = link["qty_src"].to_f * -1
				stkinout[@str_qty] = link["qty_src"].to_f 
				if (link["tblname"] == "puracts" and link["srctblname"] == "purdlvs") or
					 (link["tblname"] == "custacts" and link["srctblname"] == "custdlvs")
					set_lotstkhists_custwhs_supplierwhs(stkinout,link)
				else
					set_lotstkhists_custwhs_supplierwhs(prev_stkinout,nil)
					set_lotstkhists_custwhs_supplierwhs(stkinout,link)
					###出庫指示変更、消費変更
					if @tblname =~ /insts|reply/ and @tblname =~ /^pur|^prd/
						Shipment.proc_re_create_shpords(@reqparams,srctblname,link["qty_src"].to_f,src)
						Shipment.proc_re_create_conords(@reqparams,srctblname,link["qty_src"].to_f,src)
					end
					###消費実行
					if link["tblname"] =~ /^prdacts|^puracts|^purdlvs/  ###子部品の消費と金型、瓶等の自動返却
						@tbldata["qty_stk"] = link["qty_src"].to_f
						Shipment.proc_mk_conacts(@reqparams)  ###reqparams 親のデータ
					end
				end
			end
		else ###変更　(削除 qty_sch=qty=qty_stk=0 　を含む) 
			@last_rec = get_last_rec()
			return if @last_rec.nil?
			chng_flg = check_shelfnos_duedate_qty()  ###qty_duedate,shelfnos_idの変更チェック
			###
			#数量・納期の変更がないときは何もしない。
			return if chng_flg
			###前の在庫削除
			last_stkinout = ArelCtl.proc_set_stkinout(@last_rec)
			stkinout["wh"] = "lotstkhists"
			last_stkinout[@str_qty] =  @last_rec[@str_qty].to_f * -1
			###
			if chng_flg =~ /qty/
				strsql = %Q% select * from linktbls where tblname = '#{@tblname}' and tblid = #{@tblid}
						%  ### srctblname = '#{@tblname}'の変化はない。次のステータスの数量以下にはできない。
				ActiveRecord::Base.connection.select_all(strsql).each do |link|
					set_lotstkhists_custwhs_supplierwhs(last_stkinout,nil)
					###今回の在庫追加
					if @tbldata[@str_qty].to_f > 0
						stkinout = ArelCtl.proc_set_stkinout(@gantt) 
						stkinout["wh"] = "custwhs"
						set_lotstkhists_custwhs_supplierwhs(stkinout,link)
					end
					change_alloc_last_stkinout(link,last_stkinout,stkinout) ###links:linktbls-->srctblnameとtblnameの関係
				end
			else
				set_lotstkhists_custwhs_supplierwhs(last_stkinout,nil)
			end
			if @tblname =~ /insts|reply/
				###変更が数量のみの時　納期、納入場所についてはif chng_flg =~ /shelfno|due/で対応
				update_last_children_shp_con()  ###在庫の処理を含む
			end
		end		
		return 
	end

	def set_lotstkhists_custwhs_supplierwhs(stkinout,link)
		stkinout["remark"] = "Operation.set_lotstkhists_custwhs_supplierwhs table:#{@tblname}"
		case @tblname
		when /^prdrets|^purrets/
			stkinout = Shipment.proc_lotstkhists_in_out("out",stkinout)  ###在庫の更新
		when /^purdlvs/
			stkinout["qty"] = @tbldata["qty_stk"]
			stkinout["qty_stk"] = 0
			stkinout["starttime"] = (@tbldata["depdate"].to_date + 1).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
			stkinout = Shipment.proc_lotstkhists_in_out("in",stkinout)  ###在庫の更新
			stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = @tbldata["shelfnos_id_fm"]
			stkinout["qty"] = 0
			stkinout["qty_stk"] = @tbldata["qty_stk"]
			stkinout["starttime"] = @tbldata["depdate"] ###カレンダー考慮要
			stkinout["suppliers_id"] = @tbldata["supplers_id"]
			Shipment.proc_mk_supplierwhs_rec("out",stkinout)
		when /^pur|^prd/
			stkinout = Shipment.proc_lotstkhists_in_out("in",stkinout)  ###在庫の更新
		when /^custschs|^custords|^custinsts/   ###qtyの入りと出
			stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = @tbldata["shelfnos_id_fm"]
			stkinout["starttime"] = (@tbldata["duedate"].to_date - 1).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
			stkinout = Shipment.proc_lotstkhists_in_out("out",stkinout)  ##
			stkinout["custrcvplcs_id"] = @tbldata["custrcvplcs_id"]
			stkinout["starttime"] = @tbldata["duedate"]  ###カレンダー考慮要
			stkinout["remark"] = "Operation line #{__LINE__}"
			Shipment.proc_mk_custwhs_rec("in",stkinout,@tbldata)
		when /^custdlvs/  ###qty_stkの出
			stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = @tbldata["shelfnos_id_fm"]
			stkinout = Shipment.proc_lotstkhists_in_out("out",stkinout)  ##
			stkinout["qty"] = @tbldata["qty_stk"]
			stkinout["qty_stk"] = 0
			stkinout["starttime"] = (@tbldata["depdate"].to_date + 1).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
			stkinout["custrcvplcs_id"] = @tbldata["custrcvplcs_id"]
			stkinout["remark"] = "Operation line #{__LINE__}"
			Shipment.proc_mk_custwhs_rec("in",stkinout,@tbldata)
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
			Shipment.proc_mk_custwhs_rec("in",stkinout,@tbldata)
		when /^custrets/   ###qty_stkの入り
			stkinout["custrcvplcs_id"] = @tbldata["custrcvplcs_id"]
			stkinout["remark"] = "Operation line #{__LINE__}"
			Shipment.proc_mk_custwhs_rec("out",stkinout,@tbldata)
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

	def change_alloc_last_stkinout(links,last_stkinout,stkinout)
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
				last_stkinout["trngantts_id"] = link["trngantts_id"]
				last_stkinout["qty"] = qty_src - link["qty_src"]
				last_stkinout["wh"] = "lotstkhists"		
				Shipment.proc_check_inoutlotstk("in",last_stkinout)
				###
				### schs.qty_schの復活とqty_schの在庫修正
				src_alloc_update_strsql = %Q&
					update alloctbls set qty_linkto_alloctbl = qty_linkto_alloctbl - #{link["qty_src"]},
							updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss')												
							where trngantts_id = #{link["trngantts_id"]}
							and srctblname = '#{link["srctblname"]}' and srctblname = '#{link["srctblid"]}' 
						& 
				ActiveRecord::Base.connection.update(src_alloc_update_strsql)
				prev_stkinout = stkinout.dup
				prev_stkinout["tblname"] = link["srctblname"]
				prev_stkinout["tblid"] = link["srctblid"]
				strsql = %Q&
						select * from #{link["srctblname"]} where id = #{link["srctblid"]} 
				&
				@prev_rec = ActiveRecord::Base.connection.select_one(strsql)
				case link["srctblname"]
				when /schs/
					prev_stkinout["qty_sch"] = link["qty_src"].to_f
					prev_stkinout["qty"] = 0
					prev_stkinout["qty_stk"] = 0
				when /ords|insts|reply/
					prev_stkinout["qty_sch"] = 0
					prev_stkinout["qty"] = link["qty_src"].to_f
					prev_stkinout["qty_stk"] = 0
				when /dlvs|acts|rets/
					prev_stkinout["qty_sch"] = 0
					prev_stkinout["qty"] = 0
					prev_stkinout["qty_stk"] = link["qty_src"].to_f
				end
				case link["srctblname"]
				when /schs|ords|insts/
					prev_stkinout["starttime"] = @prev_rec["duedate"]
				when /reply/
					prev_stkinout["starttime"] = @prev_rec["replydate"]
				when /dlvs|/
					prev_stkinout["starttime"] = @prev_rec["depdate"]
				when /^puracts/
					prev_stkinout["starttime"] = @prev_rec["rcptdate"]
				when /^prdacts/
					prev_stkinout["starttime"] = @prev_rec["cmpldate"]
				when /rets/
					prev_stkinout["starttime"] = @prev_rec["retdate"]
				end
				prev_stkinout = Shipment.proc_lotstkhists_in_out("in",prev_stkinout) 
			else
				save_qty -=  link["qty_src"].to_f
			end
		end
	end

	def init_trngantts_add_detail()
		###@src_no = ""
		###トップ登録時org=pare=tbl

		@trngantts_id = @gantt["id"] = @gantt["trngantts_id"] 
		@gantt["remark"] = " Operation.init_trngantts_add_detail "
		
		stkinout = ArelCtl.proc_set_stkinout(@gantt)
		stkinout["wh"] = "lotstkhists"
		stkinout["remark"] =  " Operation.init_trngantts_add_detail"
		stkinout["allocfree"] = if @tblname =~ /ords/
									"free"
								else
									"alloc"
								end
		###insts,replyinputs,dlvs,replyinputs,acts,retsはtrnganttsは作成しない。
		ArelCtl.proc_insert_trngantts(@gantt)  ###@ganttの内容をセット
		stkinout = ArelCtl.proc_insert_alloctbls(stkinout)
		case @tblname	
		when /^purords|^prdords/  ### 単独でxxxordsを画面又はexcelで登録-->mkordinstsを利用してないとき
			###free_ordtbl_alloc_to_sch(stkinout)
				stkinout["qty_free"] = @tbldata["qty"]
				stkinout = Shipment.proc_lotstkhists_in_out("in",stkinout)  ###引当後の在庫の更新
				if @mkprdpurords_id == 0 ###mkordinstsの時は対象外
					@reqparams["segment"]  = "mkschs"   ###構成展開
					###mkschで子部品の出庫、消費も行う		
					@reqparams["remark"]  = "Operation.proc_trngantts.init_trngantts_add_detail  構成展開"   ###構成展開
					processreqs_id ,@reqparams = ArelCtl.proc_processreqs_add @reqparams
				end
		when /^custschs|^custords/
			stkinout["shelfnos_id"] = stkinout["shelfnos_id_real"] = @tbldata["shelfnos_id_fm"]
			stkinout["custrcvplcs_id"] = @tbldata["custrcvplcs_id"]
			stkinout["remark"] = "line #{__LINE__}"
			if @tblname =~ /^custords/
					custords_alloc_to_custschs(stkinout["alloctbls_id"],stkinout)  ###custschsへの引き当て
			end
			stkinout = Shipment.proc_lotstkhists_in_out("out",stkinout)  ##
			Shipment.proc_mk_custwhs_rec("in",stkinout,@tbldata)
			@reqparams["segment"]  = "mkprdpurchild"   ###構成展開		
			@reqparams["remark"]  = "Operation line:#{__LINE__}  pur,prd by custschs,ords"  
			processreqs_id ,@reqparams = ArelCtl.proc_processreqs_add @reqparams
		end
		return
	end

	def update_last_children_shp_con()
		if @tblname =~ /schs/
			shpxxxs = "shpschs"
			conxxxs = "conschs"
			sch_con_qty = @tbldata["qty_sch"].to_f - @last_rec["qty_sch"].to_f
		else
			shpxxxs = "shpords"
			conxxxs = "conords"
			sch_con_qty = @tbldata["qty"].to_f - @last_rec["qty"].to_f
		end
		strsql = %Q&
					select * from #{shpxxxs} shp
							inner join #{@tblname}  pare on shp.paretblid = pare.id
							where shp.paretblname = '#{@tblname}' and shp.paretblid = #{@tblid}
				&
		ActiveRecord::Base.connection.select_all(strsql).each do |shp|
			@reqparams["child"] = shp
			Shipment.proc_update_shpschs_ords(@reqparams,sch_con_qty) do
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
		@gantt["qty_sch"] = @tbldata["qty_sch"].to_f
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
		@gantt["shelfnos_id_to"]  = @tbldata["shelfnos_id_to"] ###完成・受入後の保管場所
		@gantt["shelfnos_id_real"]  = @tbldata["shelfnos_id_to"] ###  purschs,prdschsではshelfnos_id_real　= shelfnos_id
		@gantt["prjnos_id"] = @tbldata["prjnos_id"]
		@gantt["locas_id_trn"] =  @opeitm["locas_id_opeitm"]  ###
		@gantt["duedate_trn"] = @tbldata["duedate"]
		@gantt["toduedate_trn"] = @tbldata["toduedate"]
		@gantt["starttime_trn"] = @tbldata["starttime"]
		@gantt["chrgs_id_trn"] = @tbldata["chrgs_id"]
		@gantt["id"] = @gantt["trngantts_id"]  = @trngantts_id = ArelCtl.proc_get_nextval("trngantts_seq")
		@gantt["remark"] =  " Operation.child_trngantts  "
		@reqparams["gantt"] = @gantt
		ArelCtl.proc_insert_trngantts(@gantt)

		###親の引き当て処理追加要		
		stkinout = ArelCtl.proc_set_stkinout(@gantt)
		stkinout["wh"] = "lotstkhists"
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
		stkinout = Shipment.proc_lotstkhists_in_out("in",stkinout)
		if @gantt["qty_handover"].to_f  > 0  
			@reqparams["segment"]  = "mkschs"   ###構成展開
			@reqparams["remark"]  = "Operation line:#{__LINE__}  構成展開 level > 1"  
			processreqs_id ,@reqparams = ArelCtl.proc_processreqs_add @reqparams
		end
		return 
	end

	# def getfreeOrdStk	
	# 	%Q&select   ---  free　を求めるsql
	# 	 				case
	# 	 				when gantt.qty_stk >  gantt.qty
	# 	 					then '02' 
	# 	 				when  gantt.duedate_trn <= to_date('#{@tbldata["duedate"]}','yyyy-mm-/dd')
	# 	 					then '01'	
	# 	 				else
	# 	 					'03' end  priority,
	# 	 				to_number(to_char(gantt.duedate_trn,'yyyymmdd'),'99999999')*-1 due,
	# 	 				gantt.duedate_trn duedate,
	# 	 				gantt.processseq_trn processseq,gantt.mlevel mlevel,
	# 	 				gantt.itms_id_trn itms_id,gantt.prjnos_id,
	# 	 				alloc.srctblname tblname,alloc.srctblid tblid,alloc.trngantts_id trngantts_id,
	# 	 				alloc.id alloctbls_id	,gantt.qty_free	,gantt.qty_handover,
	# 	 				alloc.qty alloc_qty,alloc.qty_stk alloc_qty_stk,alloc.qty_linkto_alloctbl alloc_qty_linkto_alloctbl	
	# 	 				from trngantts gantt
	# 	 				inner join alloctbls alloc on gantt.id = alloc.trngantts_id and gantt.orgtblname = alloc.srctblname 
	# 	 												and gantt.orgtblid = alloc.srctblid
	# 	 				where gantt.prjnos_id =  #{@tbldata["prjnos_id"]}
	# 	 					and gantt.orgtblname = gantt.paretblname and gantt.paretblname = gantt.tblname
	# 	 					and gantt.orgtblid = gantt.paretblid  and gantt.paretblid = gantt.tblid
	# 	 					and  gantt.itms_id_trn = #{@opeitm["itms_id"]} and gantt.processseq_trn = #{@opeitm["processseq"]}
	# 	 					and  gantt.locas_id_trn = #{@opeitm["locas_id_opeitm"]} 
	# 	 					and (gantt.tblname = 'prdords' or gantt.tblname = 'purords'  or gantt.tblname = 'lotstkhists' )
	# 	 					--- freeの在庫　　未定 仮に"lotstkhists"にした。要確認
	# 	 					and gantt.qty_free > 0 and (alloc.qty + alloc.qty_stk) > alloc.qty_linkto_alloctbl
	# 	 					order by priority,due
	# 	 					---for update
	# 	 				& ### xxxacts等を登録するときは必ずxxxordsを前に登録すること。
	# end
	# def schstbl_alloc_to_freetbl  sch   ###xxxschsをまとめて消費量を決めているので
	# 	###freeを探す　xxxordsのみ引き当てる。
	# 	strsql = %Q%select locas_id_shelfno from shelfnos where id = #{@tbldata["shelfnos_id_to"]}
	# 	%
	# 	locas_id_shelfno =  ActiveRecord::Base.connection.select_value(strsql)

	# 	
	# 	required_sch_qty = sch["qty_sch"].to_f
	# 	alloc_qty = 0
	# 	alloc_qty_stk = 0
	# 	ActiveRecord::Base.connection.select_all(getFreeOrdStk).each do |free|   ### 
	# 		qty_src = 0
	# 		base = proc_set_stkinout(free)
	# 		base["trngantts_id"] = free["trngantts_id"] ####schsの@trngantts_idを変更
	# 		if (free["alloc_qty"].to_f - free["alloc_qty_linkto_alloctbl"].to_f) >= required_sch_qty
	# 			qty_src = required_sch_qty 
	# 			base["qty"] = alloc_qty = required_sch_qty
	# 			base["qty_stk"] = 0
	# 			required_sch_qty = 0
	# 		else
	# 			if (free["alloc_qty_stkj"].to_f - free["alloc_qty_linkto_alloctbl"].to_f) >= required_sch_qty
	# 				qty_src = required_sch_qty 
	# 				base["qty_stk"] = alloc_qty_stk = required_sch_qty
	# 				base["qty"] = 0
	# 				required_sch_qty = 0
	# 			else		
	# 				if (free["alloc_qty"].to_f > free["alloc_qty_linkto_alloctbl"].to_f) 
	# 					qty_src = (free["alloc_qty"].to_f - free["alloc_qty_linkto_alloctbl"].to_f) 
	# 					required_sch_qty -=  (free["alloc_qty"].to_f - free["alloc_qty_linkto_alloctbl"].to_f)
	# 					base["qty"] = qty_src
	# 					base["qty_stk"] = 0
	# 					alloc_qty += qty_src 
	# 				else		
	# 					if (free["alloc_qty_stk"].to_f > free["alloc_qty_linkto_alloctbl"].to_f) 
	# 						qty_src = (free["alloc_qty_stk"].to_f - free["alloc_qty_linkto_alloctbl"].to_f) 
	# 						required_sch_qty -=  (free["alloc_qty_stk"].to_f - free["alloc_qty_linkto_alloctbl"].to_f)
	# 						base["qty_stk"] = qty_src
	# 						base["qty"] = 0
	# 						alloc_qty_stk += qty_src 
	# 					end
	# 				end
	# 			end
	# 		end		
						
	# 		update_strsql = %Q&
	# 					update trngantts set qty_free = qty_free - #{qty_src},
	# 											remark = 'Operation line:#{__LINE__}' 
	# 					where id = #{free["trngantts_id"]}
	# 					&
	# 		ActiveRecord::Base.connection.update(update_strsql)

	# 		####lotstkhists_id　を求める。
	# 		rec = ActiveRecord::Base.connection.select_one(sql_get_lotstkhists_id(free))
	# 		base["lotstkhists_id"] = rec["id"]
	# 		base["amt_src"] = 0
	# 		base["qty_src"] = qty_src
	# 		prev_link_alloc_update("re_alloc",base,sch)
	# 		break if required_sch_qty <= 0
	# 	end
	# 	if sch["qty_sch"].to_f != required_sch_qty
	# 		packqty = if @opeitm["packqty"].to_f == 0 then 1 else @opeitm["packqty"].to_f end
	# 		qty_handover = ((sch["qty_sch"].to_f - alloc_qty_stk  - alloc_qty )/ @opeitm["packqty"].to_f ).ceil * @opeitm["packqty"].to_f 
	# 		update_strsql = %Q&
	# 					update trngantts set 
	# 							--- qty_require = #{required_sch_qty},
	# 							qty_handover = #{qty_handover},  	qty_sch = #{required_sch_qty},
	# 							qty = #{alloc_qty},qty_stk = #{alloc_qty_stk},
	# 							remark = 'Operation line:#{__LINE__}' 
	# 						where id = #{@gantt["trngantts_id"]}   --- schsのtrngantts_id
	# 				&		
	# 		ActiveRecord::Base.connection.update(update_strsql)
	# 		###@gantt["qty_require"] = required_sch_qty
	# 		@gantt["qty_sch"] = required_sch_qty
	# 		@gantt["qty_handover"] = qty_handover
	# 	end
	# 	return  
	# end	

	def sql_free_alloc_sch()  ###free ords等に引き当るschを探す
	 	%Q&
	 	select gantt.tblname,gantt.tblid,
	 	gantt.id id,gantt.id trngantts_id,gantt.prjnos_id,gantt.consumunitqty,
	 	'01' priority,to_number(to_char(gantt.duedate_trn,'yyyymmdd'),'99999999')*-1 due,
	 	gantt.itms_id_trn itms_id,gantt.processseq_trn processseq,gantt.expiredate,gantt.remark sch_remark,
	 	gantt.duedate_trn duedate,
	 	gantt.qty_sch,gantt.qty_require,---親の消費に対しての未達分
	 	gantt.qty_handover, opeitm.packqty,	
	 	gantt.qty, gantt.qty_stk,gantt.parenum,gantt.chilnum,gantt.shelfnos_id_to
	 	from trngantts gantt  --- schでは　trn:alloc= 1:1
	 	inner join opeitms opeitm on  gantt.itms_id_trn = opeitm.itms_id 
	 						and gantt.processseq_trn = opeitm.processseq and gantt.locas_id_trn = opeitm.locas_id_opeitm
	 	where gantt.prjnos_id =  #{@tbldata["prjnos_id"]}
	 		and (gantt.orgtblname like '%ords' or gantt.orgtblname = 'custschs')    --- topがordsとcustschsのみ対象,topにinsts,dlvs,actsはない。
	 		and  gantt.paretblid != gantt.tblid and gantt.tblname like '%schs'
	 		and  gantt.itms_id_trn = #{@opeitm["itms_id"]} and gantt.processseq_trn = #{@opeitm["processseq"]}
	 		and gantt.qty_sch   > 0 
	 		and gantt.shelfnos_id_to = #{@gantt["shelfnos_id_to"]}
	 		---and gantt.itms_id_pare = #{itms_id_pare} and gantt.processseq_pare = #{processseq_pare}
	 		---#{if @mkprdpurords_id then 	"and gantt.mkprdpurords_id_trngantt = #{@mkprdpurords_id}" else "" end}
	 	order by gantt.duedate_trn,gantt.id for update of gantt
	 	&
	end
	
	def sql_sum_sch  ###free ords等に引き当るschを探す
		%Q&
		select 
		gantt.prjnos_id,gantt.consumunitqty,gantt.consumchgoverqty,gantt.consumminqty,
			gantt.itms_id_trn itms_id,gantt.processseq_trn processseq,
			gantt.itms_id_pare,gantt.processseq_pare,gantt.shelfnos_id_to_pare,
			gantt.mkprdpurords_id_trngantt,
			sum(pare.qty_handover) pare_qty_handover,sum(gantt.qty) qty,sum(gantt.qty_stk) qty_stk,	
			gantt.parenum,gantt.chilnum,gantt.shelfnos_id_to
		from trngantts gantt  --- schでは　trn:alloc= 1:1
		inner join trngantts pare on gantt.orgtblname = pare.orgtblname and gantt.orgtblid = pare.orgtblid
							and  gantt.paretblname = pare.tblname and gantt.paretblid = pare.tblid 
		where gantt.prjnos_id =  #{@tbldata["prjnos_id"]}
			and (gantt.orgtblname like '%ords' or gantt.orgtblname = 'custschs')    --- topがordsとcustschsのみ対象
			and  gantt.paretblid != gantt.tblid and gantt.tblname like '%schs'
			and  gantt.itms_id_trn = #{@opeitm["itms_id"]} and gantt.processseq_trn = #{@opeitm["processseq"]}
			and pare.qty_handover   > 0 
			and gantt.shelfnos_id_to = #{@gantt["shelfnos_id_to"]}
			#{if @mkprdpurords_id then 	"and gantt.mkprdpurords_id_trngantt = #{@mkprdpurords_id}" else "" end}
			group by gantt.itms_id_pare ,gantt.processseq_pare,gantt.locas_id_pare,gantt.shelfnos_id_topare,
			gantt.mkprdpurords_id_trngantt,
			gantt.itms_id_trn ,gantt.processseq_trn,gantt.locas_id_trn,
			gantt.parenum,gantt.chilnum,gantt.shelfnos_id_to,
			gantt.prjnos_id,gantt.consumunitqty,gantt.consumchgoverqty,gantt.consumminqty
		&
	end
	
	### free purords又はprdords
	 def free_ordtbl_alloc_to_sch(base) ###base:free   ## xxxschsをまとめてxxxordsを作成する機能と矛盾
	 	 ###freeで登録されたordを引き当てる。free:trngantts-->orgtblid=paretblid=tblid
	 	###親全体の必要量で子部品の必要量を考慮する。
	 	srctblname = @tblname.gsub("ord","sch")
	 	strsql = %Q%
	 				select locas_id_shelfno from shelfnos where id = #{@opeitm["shelfnos_id_fm_opeitm"]}
	 	%  ## free trn org=pare=tbl では qty - qty_linkto_alloctblがfree残数
	 	locas_id_shelfno =  ActiveRecord::Base.connection.select_value(strsql)
	 	free_qty = base["qty_free"].to_f 
	 	# ActiveRecord::Base.connection.select_all(sql_sum_sch).each do |sumreq| 
	 	##	qty_require = (qty_require / sumreq["consumunitqty"].to_f).ceil * sumreq["consumunitqty"].to_f
	 	# 	qty_require +=  sumreq["consumchgoverqty"].to_f
	 	# 	if qty_require < sumreq["consumminqty"].to_f
	 	# 		qty_require = sumreq["consumminqty"].to_f
	 	# 	end
	 	# 	qty_require -= (sumreq["qty"].to_f + sumreq["qty_stk"].to_f)
	 	# 	bal_free_qty = free_qty  ###必要量が不足の時(enougth = false)使用
	 	# 	if free_qty < qty_require
	 		##	qty_require = free_qty
	 		# 	free_qty = 0
	 		# 	enougth = false
	 		# else
	 		# 	free_qty -= qty_require  ###次の親に与えられる数
	 		# 	enougth = true  ###必要子部品はある。
	 		# end
	 		###freeを求めているschsを検索
	 		ActiveRecord::Base.connection.select_all(sql_free_alloc_sch()).each do |sch|  
	 			###freeのtrngantts freeのqtyとfreeのqty_stkはレコードが分かれる。
	 			src = ArelCtl.proc_set_stkinout(sch)
				src = "lotstkhists"
	 			src["trngantts_id"] = sch["trngantts_id"]  ###@trngantts_idから変更
	 			if bal_free_qty >= sch["qty_require"].to_f
	 				case base["tblname"]
	 				when /ords|insts|reply/
	 					base["qty"] = sch["qty_require"].to_f 
	 					base["qty_stk"] = 0
	 				when /dlvs|acts|rets/
	 					base["qty_stk"] = sch["qty_require"].to_f 
	 					base["qty"] = 0 
	 				end
	 				base["qty_src"] = sch["qty_require"]
	 				bal_free_qty -= sch["qty_require"].to_f
	 				base["qty_sch"] = base["qty_require"] = 0
	 			else
	 				case base["tblname"]
	 				when /ords|insts|reply/
	 					base["qty"] = bal_free_qty  
	 					base["qty_stk"] = 0
	 				when /dlvs|acts|rets/
	 					base["qty_stk"] = bal_free_qty 
	 					base["qty"] = 0 
	 				end
	 				base["qty_src"] = bal_free_qty
	 				base["qty_require"] = base["qty_sch"] = sch["qty_require"].to_f - bal_free_qty
	 				bal_free_qty = 0
	 			end
	 			packqty = if sch["packqty"].to_f == 0 then 1 else sch["packqty"].to_f end
	 			qty_handover = (base["qty_require"] / packqty ).ceil * packqty
	 			update_strsql = %Q&
	 				update trngantts set qty = qty + #{base["qty"]},
	 							qty_stk = qty_stk + #{base["qty_stk"]},
	 							qty_sch =  #{base["qty_require"]} ,
	 							---qty_require =  #{base["qty_require"]} + qty + #{base["qty"]} + qty_stk + #{base["qty_stk"]},
	 							qty_handover = #{qty_handover},remark = 'Operation line #{__LINE__} #{Time.now}'
	 							where id = #{sch["trngantts_id"]}
	 				&
	 			ActiveRecord::Base.connection.update(update_strsql)
			
	 			rec = ActiveRecord::Base.connection.select_one(ArelCtl.proc_sql_get_lotstkhists_id(sch))
	 			src["lotstkhists_id"] = rec["id"]
	 			ArelCtl.proc_prev_link_alloc_update("add",base,src)
	 		end
	 	###end 
	 	###発注数、作業単位にまとめて子部品へ引き継ぐ 
	 	###if @mkprdpurords_id == -1
	 		update_strsql = %Q&   ---schsで子部品手配済なので未配分のみ展開
	 					update trngantts set qty_free =  #{free_qty},
	 									remark = 'Operation line #{__LINE__} #{Time.now}'
	 									where id = #{base["trngantts_id"]}
	 				&
	 	ActiveRecord::Base.connection.update(update_strsql)
	 	###end
	 	@gantt["qty_free"] = free_qty
	 end	


	def custords_alloc_to_custschs alloc_id_of_custord,stkinout
		trn_qty = @tbldata["qty"].to_f
		link_qty = 0
		prev_stkinout = stkinout.dup
		strsql = %Q&
					select (alloc.qty_sch - alloc.qty_linkto_alloctbl)  free_qty,
							sch.id sch_id,alloc.trngantts_id trngantts_id,
							ord.id ord_id,sch.duedate prev_duedate,sch.shelfnos_id_fm
					from custschs sch
						inner join alloctbls alloc on sch.id = alloc.srctblid
						inner join custords ord on sch.opeitms_id = ord.opeitms_id and sch.custs_id = ord.custs_id
												and sch.prjnos_id = ord.prjnos_id
						where alloc.srctblname = 'custschs' and alloc.qty_sch > alloc.qty_linkto_alloctbl
						and ord.sno = '#{@tbldata["sno"]}'
		&
		src = {"trngantts_id" => stkinout["trngantts_id"],"tblname" => "custschs","tblid" => ""}
		base = {"tblname" => "custords","tblid" =>"","qty_src" => 0,"amt_src" => "0"}
		ActiveRecord::Base.connection.select_all(strsql).each do |rec|
			if trn_qty >= rec["free_qty"].to_f   ### rec["free_qty"]:custschsの未引き当て
				alloc_qty =  rec["free_qty"].to_f
				trn_qty -= rec["free_qty"].to_f
			else
				alloc_qty =  trn_qty
				trn_qty = 0
			end
			src["trngantts_id"] = rec["trngantts_id"]
			src["tblid"] = rec["sch_id"]
			base["tblid"] = rec["ord_id"]
			base["qty_src"] = rec["alloc_qty"]
			ArelCtl.proc_insert_linktbls(src,base)
			link_qty += alloc_qty
			rec_alloc = {"tblname" => "custords","tblid" => rec["ord_id"],"trngantts_id" => rec["trngantts_id"],
							"qty_sch" => 0,"qty" => alloc_qty,"qty_stk" => 0,"qty_linkto_alloctbl" => 0,
							"remark" => "line #{__LINE__} #{Time.now}","allocfree" => "alloc"}
			ArelCtl.proc_insert_alloctbls(rec_alloc)
			### custschs在庫減
			prev_stkinout["duedate"] = rec["prev_duedate"].to_date - 1  ###稼働日・輸送日の考慮要
			prev_stkinout["qty_sch"] = alloc_qty * -1
			prev_stkinout = Shipment.proc_lotstkhists_in_out("out",prev_stkinout)  ##
			prev_stkinout["shelfnos_id"] = prev_stkinout["shelfnos_id_real"] = rec["shelfnos_id_fm"]
			prev_stkinout["duedate"] = rec["prev_duedate"] ##稼働日・輸送日の考慮要
			prev_stkinout["qty_sch"] = alloc_qty 
			prev_stkinout["custrcvplcs_id"] = @tbldata["custrcvplcs_id"]
			prev_stkinout["remark"] = "Operation.custords_alloc_to_custschs"
			prev_stkinout["wh"] = "lotstkhists"		
			Shipment.proc_mk_custwhs_rec("in",prev_stkinout,@tbldata)
			Shipment.proc_check_inoutlotstk "out",prev_stkinout
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
end   #class
	
end   #module