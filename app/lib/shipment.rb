# -*- coding: utf-8 -*-
#shipment
# 2099/12/31を修正する時は　2100/01/01の修正も
module Shipment
	extend self
	def proc_mkShpords screenCode,clickIndex  ###screenCode:r_purords,r_prdords
		###shpschsは変更済
		pagedata = []
		outcnt = 0
		shortcnt = 0
		err = ""
		parent = {}
		parent["tblname"] = screenCode.split("_")[1]
        begin
            ActiveRecord::Base.connection.begin_db_transaction()
			clickIndex.each do |strselected|  ###-次のフェーズに進んでないこと。
				selected = JSON.parse(strselected)
				parent["tblid"] = selected["id"]
				### prd,pur ords,instsでshpordsは自動作成されている。
				strsql = %Q&
						select * from #{parent["tblname"]} where id = #{parent["tblid"]}
				&
				tblrec = ActiveRecord::Base.connection.select_one(strsql)
				case screenCode.split("_")[1] ###shpordsを作成する親を特定する。
				when /ords$/
					ord_strsql = %Q&
						select t.itms_id_trn itms_id,t.processseq_trn processseq,inout.lotno,inout.packno,inout.qty_sch,inout.qty,inout.qty_stk,
								link.tblname ord_tblname,link.tblid ord_tblid ,t.id trngantts_id, t.prjnos_id,t.chrgs_id_trn,t.id trngantts_id,
								t.consumtype,t.parenum,t.chilnum,t.consumunitqty,t.consumminqty,t.consumchgoverqty,
								t.shelfnos_id_pare,   ---親作業場所
								t.shelfnos_id_to_trn shelfnos_id_to,   ---子の保管先
								ope.units_id_case_shp,ope.consumauto,ope.shpordauto
							from trngantts t
							inner join	linktbls link
								on t.paretblname = link.srctblname and t.paretblid = link.srctblid ---t.paretblname,link.srctblname:xxxschs
							inner join (select  l.lotno,l.packno,i.qty_sch,i.qty,i.qty_stk,i.trngantts_id,i.tblname,i.tblid
												from  inoutlotstks i inner join lotstkhists l
												on i.srctblid = l.id 
												where i.srctblname = 'lotstkhists' and (i.tblname like 'prd%' or i.tblname like 'pur%')  
												and (i.qty_sch > 0 or i.qty > 0 or i.qty_stk > 0)  ) inout     
								on inout.trngantts_id = t.id
							inner join opeitms ope on t.itms_id_trn = ope.itms_id and t.processseq_trn = ope.processseq
											and t.shelfnos_id_trn = ope.shelfnos_id_opeitm
							inner join alloctbls alloc on alloc.trngantts_id = t.id and alloc.qty_linkto_alloctbl  > 0
							where link.tblname = '#{parent["tblname"]}' and  link.tblid = #{parent["tblid"]}
							and	link.srctblname like '%schs'  and t.shelfnos_id_pare != t.shelfnos_id_to_trn 
							and alloc.srctblname = inout.tblname and alloc.srctblid = inout.tblid		
							and not exists(select 1 from shpords s where paretblname = '#{parent["tblname"]}' and  paretblid = #{parent["tblid"]}
													and s.itms_id = t.itms_id_trn)					
						
					&
					shpschs_sql = %Q$
						select tblname ord_tblname,tblid ord_tblid ,link.trngantts_id from linktbls link
									where link.tblname = '#{parent["tblname"]}' and  link.tblid = #{parent["tblid"]}
									and	link.srctblname like '%schs' 	
									and not exists(select 1 from shpords s where paretblname = '#{parent["tblname"]}' and  paretblid = #{parent["tblid"]}
													---既にshpordsを作成済の時は削除するshpschsはない。
															)				
						$
					ord_shpschs = ActiveRecord::Base.connection.select_all(shpschs_sql)	
				when /insts$/   ##sno_xxxordは使用できない。　n:1の時もあるため
					ord_strsql = %Q&
						select t.itms_id_trn itms_id,t.processseq_trn processseq,inout.lotno,inout.packno,inout.qty_sch,inout.qty,inout.qty_stk,
							link.tblname ord_tblname,link.tblid ord_tblid ,t.id trngantts_id, t.prjnos_id,t.chrgs_id_trn,,t.id trngantts_id,
							t.consumtype,t.parenum,t.chilnum,t.consumunitqty,t.consumminqty,t.consumchgoverqty,
							t.shelfnos_id_pare,   ---親作業場所
							t.shelfnos_id_to_trn shelfnos_id_to,   ---子の保管先
							ope.units_id_case_shp,ope.consumauto,ope.shpordauto,ope.shuffle_flg
							from trngantts t
							inner join (select ord.* from linktbls ord
														inner join	linktbls inst
																	on ord.tblname = inst.srctblname and ord.tblid = inst.srctblid
											where inst.tblname = '#{parent["tblname"]}' and  inst.tblid = #{parent["tblid"]}
											and	inst.srctblname like '%ords' and  ord.srctblid like '%schs') link
								on t.paretblname = link.srctblname and t.paretblid = link.srctblid 
							inner join (select  l.lotno,l.packno,i.qty_sch,i.qty,i.qty_stk,i.trngantts_id,i.tblname,i.tblid
													from  inoutlotstks i inner join lotstkhists l
													on i.srctblid = l.id 
													where i.srctblname = 'lotstkhists' and (i.tblname like 'prd%' or i.tblname like 'pur%')
													and (i.qty_sch > 0 or  i.qty > 0 or i.qty_stk > 0)) inout     
								on inout.trngantts_id = t.id
							inner join opeitms ope on t.itms_id_trn = ope.itms_id and t.processseq_trn = ope.processseq
													and t.shelfnos_id_trn = ope.shelfnos_id_opeitm
							inner join alloctbls alloc on alloc.trngantts_id = t.id and alloc.qty_linkto_alloctbl  > 0
							and not exists(select 1 from shpords s where paretblname = '#{parent["tblname"]}' and  paretblid = #{parent["tblid"]}
													and s.itms_id = t.itms_id_trn)					
					&
					shpschs_sql = %Q$select inst.srctblname ord_tblname,inst.srctblid ord_tblid,inst.trngantts_id   from linktbls inst
											where inst.tblname = '#{parent["tblname"]}' and  inst.tblid = #{parent["tblid"]}
											and	inst.srctblname like '%ords' 	
											and not exists(select 1 from shpords s where paretblname = '#{parent["tblname"]}' and  paretblid = #{parent["tblid"]}
																	)				
					$
					ord_shpschs = ActiveRecord::Base.connection.select_all(shpschs_sql)	
				when /replyinputs/   ### xxxordsへの回答
					###出庫指示済のはず		
					outcnt = 0
					shortcnt = 0
					err = " please select prdords,purords,prdinsts,purinsts "
					return outcnt,shortcnt,err
				else
					outcnt = 0
					shortcnt = 0
					err = " please select "
					return outcnt,shortcnt,err
				end
				###在庫の確認
				err = ""
				outcnt = shortcnt = 0
                child = {}
				save_itms_id = save_processseq = ""
				save_qty = 0
                ActiveRecord::Base.connection.select_all(ord_strsql).each do |nd|
					if nd["consumtype"] =~ /CON|MET/  ###出庫 消費と金型・設備の使用
						if nd["shpordauto"] != "M"   ###手動出庫は除く
							if save_itms_id == nd["itms_id"] and save_processseq == nd["processseq"]
								next if save_qty <= 0
								qty = save_qty
							else
								if save_qty > 0
									shp["qty"] = save_qty
									shp["qty_shortage"] = save_qty
									save_qty = 0
									shpord_create_by_shpsch(shp,save_nd,stk)   ###prd,purordsによる自動作成 
									outcnt += 1
									shortcnt += 1
									if save_nd["consumtype"] =~ /MET/ and save_nd["consumauto"] == "A"   ###使用後自動返却
								 		###shpschs,shpordsでは瓶毎、リール毎に出庫してないので、瓶、リールの自動返却はない。
										shp["starttime"] = (tblrec["duedate"].to_time + 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###親の作業後元に戻す。
										shp["shelfnos_id_fm"] = save_nd["shelfnos_id_pare"]
										shp["shelfnos_id_to"] = save_nd["shelfnos_id_to"]  
										shpord_create_by_shpsch(shp,save_nd,stk)   ###
									end
								end
								shp = {}
								shp["pare_qty"] = tblrec["qty"]
								shp["pare_starttime"] = tblrec["starttime"].to_time
								shp["trngantts_id"] = nd["trngantts_id"]
								shp["shelfnos_id_to"] = nd["shelfnos_id_pare"]
								shp["shelfnos_id_fm"] = nd["shelfnos_id_to"]  
								shp["transports_id"] = 0  ###CtlFields.trnsport_idに変更のこと
								shp["paretblname"] = parent["tblname"]
								shp["paretblid"] = parent["tblid"]
								shp["itms_id"]  = nd["itms_id"]
								shp["processseq"] = nd["processseq"]
								shp["prjnos_id"] = nd["prjnos_id"]
								shp["chrgs_id"] = nd["chrgs_id_trn"]
								shp["qty_case"] = 0
								qty = save_qty = CtlFields.proc_cal_qty_sch(shp["pare_qty"].to_f,
																		nd["chilnum"].to_f,nd["parenum"].to_f,nd["consumunitqty"].to_f,
																		nd["consumminqty"].to_f,nd["consumchgoverqty"].to_f)
								save_itms_id = nd["itms_id"]
								save_processseq = nd["processseq"]
							end
							stk_sql = %Q$
									select * from lotstkhists lot
										where itms_id = #{shp["itms_id"]} and processseq = #{shp["processseq"]} and prjnos_id = #{shp["prjnos_id"]}
										and shelfnos_id = #{shp["shelfnos_id_fm"]} and lotno = '#{nd["lotno"]}' and packno = '#{nd["packno"]}'
										order by starttime desc limit 1  
							$
							stk = ActiveRecord::Base.connection.select_one(stk_sql)
							if stk
								if stk["qty_stk"].to_f >= save_qty
									shp["qty"] = save_qty
									shp["qty_shortage"] = 0 
									save_qty = 0
									shpord_create_by_shpsch(shp,nd,stk)   
									outcnt += 1
									if nd["consumtype"] =~ /MET/ and nd["consumauto"] == "A"   ###使用後自動返却
								 		###shpschs,shpordsでは瓶毎、リール毎に出庫してないので、瓶、リールの自動返却はない。
										shp["starttime"] = (tblrec["duedate"].to_time + 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###親の作業後元に戻す。
										shp["shelfnos_id_fm"] = nd["shelfnos_id_pare"]
										shp["shelfnos_id_to"] = nd["shelfnos_id_to"]  
										shpord_create_by_shpsch(shp,nd,stk)   ###
									end
								else
									if stk["qty_stk"].to_f > 0
										shp["qty"] = stk["qty_stk"].to_f
										shp["qty_shortage"] = 0 
										save_qty -= stk["qty_stk"].to_f
										shpord_create_by_shpsch(shp,nd,stk)  
										outcnt += 1 
										if nd["consumtype"] =~ /MET/ and nd["consumauto"] == "A"   ###使用後自動返却
											 ###shpschs,shpordsでは瓶毎、リール毎に出庫してないので、瓶、リールの自動返却はない。
											shp["starttime"] = (tblrec["duedate"].to_time + 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###親の作業後元に戻す。
											shp["shelfnos_id_fm"] = nd["shelfnos_id_pare"]
											shp["shelfnos_id_to"] = nd["shelfnos_id_to"]  
											shpord_create_by_shpsch(shp,nd,stk)   ###
										end
									else
										if nd["shuffle_flg"] == "S"   ###他に在庫があれば引当いるケース
											shuffle_sql = %Q$
													select * from lotstkhists stk
														inner join (select itms_id,processseq,shelfnos_id,prjnos_id,lotno,packno,
																		max(starttime) starttime from lotstkhists 
																		where itms_id = #{shp["itms_id"]} and processseq = #{shp["processseq"]} and prjnos_id = #{shp["prjnos_id"]}
																		and shelfnos_id = #{shp["shelfnos_id_fm"]} 
																		group by itms_id,processseq,shelfnos_id,prjnos_id,lotno,packno) lot
															on stk.itms_id = lot.itms_id and stk.processseq = lot.processseq and stk.shelfnos_id = lot.shelfnos_id
																and stk.prjnos_id = lot.prjnos_id and stk.lotno = lot.lotno and stk.packno = lot.packno and stk.starttime = lot.starttime
														where stk.qty_stk > 0
											$
											ActiveRecord::Base.connection.select_all(shuffle_sql).each do |shuffle_stk|
												if shuffle_stk["qty_stk"].to_f >= save_qty
													shp["qty"] = save_qty
													outcnt += 1 
													save_qty = 0
												else
													shp["qty"] = shuffle_stk["qty_stk"].to_f
													outcnt += 1 
													save_qty -= shuffle_stk["qty_stk"].to_f
												end
												shpord_create_by_shpsch(shp,nd,shuffle_stk)   ###prd,purordsによる自動作成 
												if nd["consumtype"] =~ /MET/ and nd["consumauto"] == "A"   ###使用後自動返却
												 	###shpschs,shpordsでは瓶毎、リール毎に出庫してないので、瓶、リールの自動返却はない。
													shp["starttime"] = (tblrec["duedate"].to_time + 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###親の作業後元に戻す。
													shp["shelfnos_id_fm"] = nd["shelfnos_id_pare"]
													shp["shelfnos_id_to"] = nd["shelfnos_id_to"]  
													shpord_create_by_shpsch(shp,nd,shuffle_stk)   ###
												end
												break if save_qty <= 0
											end
											if save_qty > 0 
												shp["qty"] = save_qty
												shp["qty_shortage"] =  save_qty
												save_qty = 0
												shpord_create_by_shpsch(shp,nd,shuffle_stk)   ###prd,purordsによる自動作成 
												save_qty = 0
												outcnt += 1 
												shortcnt += 1
												if nd["consumtype"] =~ /MET/ and nd["consumauto"] == "A"   ###使用後自動返却
												 		###shpschs,shpordsでは瓶毎、リール毎に出庫してないので、瓶、リールの自動返却はない。
														shp["starttime"] = (tblrec["duedate"].to_time + 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###親の作業後元に戻す。
														shp["shelfnos_id_fm"] = nd["shelfnos_id_pare"]
														shp["shelfnos_id_to"] = nd["shelfnos_id_to"]  
														shpord_create_by_shpsch(shp,nd,shuffle_stk)   ###
												end
											end
										else
											shp["qty"] = save_qty
											shp["qty_shortage"] = save_qty 
											save_qty = 0
											shpord_create_by_shpsch(shp,nd,stk)   ###prd,purordsによる自動作成 
											if nd["consumtype"] =~ /MET/ and nd["consumauto"] == "A"   ###使用後自動返却
												 ###shpschs,shpordsでは瓶毎、リール毎に出庫してないので、瓶、リールの自動返却はない。
												shp["starttime"] = (tblrec["duedate"].to_time + 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###親の作業後元に戻す。
												shp["shelfnos_id_fm"] = nd["shelfnos_id_pare"]
												shp["shelfnos_id_to"] = nd["shelfnos_id_to"]  
												shpord_create_by_shpsch(shp,nd,stk)   ###
											end
										end
									end
								end
							else
								shp["qty"] = save_qty
								shp["qty_shortage"] = save_qty
								save_qty = 0
								shortage_sql = %Q$
										select * from lotstkhists lot
											where itms_id = #{shp["itms_id"]} and processseq = #{shp["processseq"]} and prjnos_id = #{shp["prjnos_id"]}
											and shelfnos_id = #{shp["shelfnos_id_fm"]} 
											order by starttime desc limit 1  
								$
								shortage_stk = ActiveRecord::Base.connection.select_one(shortage_sql)
								shpord_create_by_shpsch(shp,nd,shortage_stk)   ###prd,purordsによる自動作成 
								if nd["consumtype"] =~ /MET/ and nd["consumauto"] == "A"   ###使用後自動返却
									 ###shpschs,shpordsでは瓶毎、リール毎に出庫してないので、瓶、リールの自動返却はない。
									shp["starttime"] = (tblrec["duedate"].to_time + 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###親の作業後元に戻す。
									shp["shelfnos_id_fm"] = nd["shelfnos_id_pare"]
									shp["shelfnos_id_to"] = nd["shelfnos_id_to"]  
									shpord_create_by_shpsch(shp,nd,shortage_stk)   ###
								end
							end
						end    
					end
					save_nd = nd.dup
				end
				
				if save_qty > 0
					shp["qty"] = save_qty
					shp["qty_shortage"] = save_qty
					shpord_create_by_shpsch(shp,save_nd,stk)   ###prd,purordsによる自動作成 
					outcnt += 1
					shortcnt += 1
					if save_nd["consumtype"] =~ /MET/ and save_nd["consumauto"] == "A"   ###使用後自動返却
						 ###shpschs,shpordsでは瓶毎、リール毎に出庫してないので、瓶、リールの自動返却はない。
						shp["starttime"] = (tblrec["duedate"].to_time + 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###親の作業後元に戻す。
						shp["shelfnos_id_fm"] = save_nd["shelfnos_id_pare"]
						shp["shelfnos_id_to"] = save_nd["shelfnos_id_to"]  
						shpord_create_by_shpsch(shp,save_nd,stk)   ###
					end
				end

				ord_shpschs.each do |ord|  ###shpschsの減
					strsql = %Q&
							select * from #{ord["ord_tblname"]} where id = #{ord["ord_tblid"]}
					&
					rec = ActiveRecord::Base.connection.select_one(strsql)
					rec["qty"] = ord["prev_qty"].to_f * -1
					rec["tblname"] = ord["ord_tblname"]
					rec["tblid"] = ord["ord_tblid"]
					gantt = {"trngantts_id" => ord["trngantts_id"]}
					setParams = {"parent" =>rec,"mkprdpurords_id" => 0,"gantt" => gantt}
					shp_sql = %Q&
							select * from shpschs where  paretblname =  '#{ord["ord_tblname"]}'  and paretblid = #{ord["ord_tblid"]}
					&
					ActiveRecord::Base.connection.select_all(shp_sql).each do |nd|
						setParams["child"] = nd.dup 
						proc_create_shpschs_delete_shpords(setParams)  do  ###prd,purordsによる自動作成 も含まれる。
							"shpord"
						end
					end
				end  ###ord_parents.each 
			end  ###clickIndex.each
		rescue
			ActiveRecord::Base.connection.rollback_db_transaction()
			Rails.logger.debug"error class #{self} : #{Time.now}: #{$@}\n "
			Rails.logger.debug"error class #{self} : $!: #{$!} \n"
			err << $!
		else
			ActiveRecord::Base.connection.commit_db_transaction()
			err = "" 
		end
		return outcnt,shortcnt,err
	end	

	def proc_second_shp params,grid_columns_info
		tmp = []
		err = ""
		pareTblName = ""
		strselect = "("
		(params["clickIndex"]).each do |selected|  ###-次のフェーズに進んでないこと。
			selected = JSON.parse(selected)
			if selected["screenCode"] =~ /prd|pur/ and selected["screenCode"] =~ /ords$|insts$|replyinputs$/
				strselect << selected["id"]+","
				pareTblName = selected["screenCode"].split("_")[1]
			end
		end
		strselect = strselect.chop + ")"
		strsorting = ""
		if params[:sortBy]  and   params[:sortBy] != [] ###: {id: "itm_name", desc: false}
			params[:sortBy].each do |sortKey|
				strsorting = " order by " if strsorting == ""
				strsorting << %Q% #{sortKey["id"]} #{if sortKey["desc"]  == false then " asc " else "desc" end} ,%
			end	
			if strsorting == ""
				strsorting = " order by id desc "
			else
				strsorting << " id desc "
			end
		else
			case params[:screenCode] 
			when "forInsts_shpords"
				strsorting = "  order by shpord_paretblid,id desc "
				strsql = %Q&
					select id	FROM shpords shp where
						paretblname = '#{pareTblName}' and
						paretblid in #{strselect} and qty_shortage > 0 and
						not exists(select 1 from shpinsts inst where
									inst.paretblname = '#{pareTblName}' and	inst.paretblid in #{strselect} and
									inst.itms_id = shp.itms_id and inst.processseq = shp.processseq and 
									inst.lotno = shp.lotno and inst.packno = shp.packno
									)
				&
				ActiveRecord::Base.connection.select_all(strsql).each do |shpord|
					shpord = ActiveRecord::Base.connection.select_one("select * from r_shpords where id = #{shpord["id"]}")
					blk = RorBlkCtl::BlkClass.new("r_shpords")
					command_c = blk.command_init
					command_c["sio_classname"] = "shpords_delete_"
					shpord.each do |fld,val|
						command_c[fld] = val
					end
					command_c["shpord_qty"] =  0
					command_c["shpord_qty_shortage"] =  0
					blk.proc_create_tbldata(command_c) ##
					blk.proc_private_aud_rec({},command_c)
				end
				proc_mkShpords("r_#{pareTblName}",params["clickIndex"])
			when "foract_shpinsts"
				strsorting = "  order by shpinst_paretblid,id desc "
			when "r_shpacts"
				strsorting = "  order by shpact_paretblid,id desc "
			end
			params[:sortBy] = []
		end
		screenCode = params[:screenCode]
		tblnamechop = screenCode.split("_",2)[1].chop
		pareTblName = params[:pareTblName] ###第一画面のテーブル名
		nextTblName = case screenCode
					when /shpords/
						"shpinsts" 
					when /shpinsts/
						"shpacts"  
					when /shpacts/
						"shpacts" 
					end
		strqty = case tblnamechop
					when /shpord/
						"shpord_qty" 
					when /shpinst/
						"shpinst_qty_stk"  
					when /shpact/
						"shpact_qty_stk" 
					end
		strsql = "select   #{grid_columns_info[:select_fields]} 
						from (SELECT ROW_NUMBER() OVER (#{strsorting}) , #{grid_columns_info[:select_row_fields]} 
												FROM #{screenCode} shp where
												#{tblnamechop}_paretblname = '#{pareTblName}' and
												#{tblnamechop}_paretblid in #{strselect} and 
												#{strqty} > 0 and --- 完了済(マイナス出庫分)は除く
												not exists(select 1 from #{nextTblName} next where
															paretblname = '#{pareTblName}' and
												 			paretblid in #{strselect} and 
															next.itms_id = shp.#{tblnamechop}_itm_id and 
															next.processseq = shp.#{tblnamechop}_processseq and
															next.lotno = shp.#{tblnamechop}_lotno and 
															next.packno = shp.#{tblnamechop}_packno and
															shp.#{strqty} >= next.qty_stk  ) ) x
													where ROW_NUMBER > #{(params[:pageIndex].to_f)*params[:pageSize].to_f} 
													and ROW_NUMBER <= #{(params[:pageIndex].to_f + 1)*params[:pageSize].to_f} 
															  "
		pagedata = ActiveRecord::Base.connection.select_all(strsql)
		
		strsql = " select count(*) FROM #{screenCode} shp where
					#{tblnamechop}_paretblname = '#{pareTblName}' and
					#{tblnamechop}_paretblid in #{strselect} and
					shp.#{strqty} > 0 and
					not exists(select 1 from #{nextTblName} inst where
								paretblname = '#{pareTblName}' and
								 paretblid in #{strselect} and 
								inst.itms_id = shp.#{tblnamechop}_itm_id and 
								inst.processseq = shp.#{tblnamechop}_processseq and 
								inst.lotno = shp.#{tblnamechop}_lotno and inst.packno = shp.#{tblnamechop}_packno and
								shp.#{strqty} >= inst.qty_stk     )"
		 ###fillterがあるので、table名は抽出条件に合わず使用できない。
		totalCount = ActiveRecord::Base.connection.select_value(strsql)
		params[:pageCount] = (totalCount.to_f/params[:pageSize].to_f).ceil
		params[:totalCount] = totalCount.to_f
		params[:parse_linedata] = {}
		return pagedata,params 
	end	
	
	###shp用
	def proc_create_shpschs_delete_shpords(reqparams)  ### shpordsは対象外
			###自分自身のshpschs を作成   
		###
		#  yield=shpsch --> create
		#  yield=shpord --> 入り出の減
		#  yield=shpinst -->出の減
		#  yield=shpact --> 入りの減
		###
		parent = reqparams["parent"]  ###親
		child = reqparams["child"]  #
		case yield
		when "shpsch" 
			tblnamechop = "shpsch"
		when "shpord" 
			tblnamechop = "shpsch"  ###新規に作成し入出庫対象の減 child=shp
		when "shpinst" 
			tblnamechop = "shpord"  ###新規に作成し出庫対象の減 child=shp
		when "shpact"
			tblnamechop = "shpord" ###新規に作成し入り対象の減 child=shp
		end
		blk = RorBlkCtl::BlkClass.new("r_#{tblnamechop}s")
		command_c = blk.command_init
		stkinout = {}
		if child["shelfnos_id_to"] != parent["shelfnos_id"] or yield != "shpsch" ###子部品の保管場所!=shelfnos_id_fm親の作業場所
				command_c["sio_classname"] = "shpschs_add_"
				command_c["#{tblnamechop}_id"] = "" 
				command_c["#{tblnamechop}_isudate"] = Time.now
				### child["shelfnos_id_to"]:購入,製造後の保管場所
				command_c["#{tblnamechop}_transport_id"] = 0 
				command_c["#{tblnamechop}_itm_id"] = child["itms_id"]   ### from shpords
				command_c["#{tblnamechop}_processseq"] = child["processseq"]
				command_c["#{tblnamechop}_sno"] = ""
				command_c["#{tblnamechop}_unit_id_case_shp"] = child["units_id_case_shp"]
				command_c["#{tblnamechop}_packno"] = ""  
				command_c["#{tblnamechop}_lotno"] = ""
				case yield
				when /shpsch/
					command_c["#{tblnamechop}_shelfno_id_fm"] = child["shelfnos_id_to"] ###自身の保管先から出庫
					command_c["#{tblnamechop}_gno"] = parent["sno"] 
					command_c["#{tblnamechop}_paretblname"] = parent["tblname"] 
					command_c["#{tblnamechop}_paretblid"] = parent["tblid"]
					command_c["#{tblnamechop}_prjno_id"] = parent["prjnos_id"]
					command_c["#{tblnamechop}_chrg_id"] = parent["chrgs_id"]
					qty_sch = CtlFields.proc_cal_qty_sch(parent["qty"].to_f,
														child["chilnum"].to_f,child["parenum"].to_f,child["consumunitqty"].to_f,
														child["consumminqty"].to_f,child["consumchgoverqty"].to_f)
					command_c["#{tblnamechop}_qty_sch"] = stkinout["qty_sch"] = qty_sch
					stkinout["qty"] = stkinout["qty_stk"] = stkinout["qty_real"] = 0
					command_c["#{tblnamechop}_shelfno_id_to"] = parent["shelfnos_id"]  ###親の作業場所へ納品
					command_c["#{tblnamechop}_duedate"] = (parent["starttime"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S")   ###稼働日考慮
					command_c["#{tblnamechop}_depdate"] = (parent["starttime"].to_time - 2*24*3600).strftime("%Y-%m-%d %H:%M:%S")
					stkinout["tblname"] = "shpschs"
				when /shpord/
					command_c["#{tblnamechop}_shelfno_id_fm"] = child["shelfnos_id_fm"] ###自身の保管先から出庫
					command_c["#{tblnamechop}_qty_sch"] = stkinout["qty_sch"] =  child["qty_sch"].to_f * -1
					stkinout["qty"] = stkinout["qty_stk"] = stkinout["qty_real"] = 0
					command_c["#{tblnamechop}_gno"] = child["gno"] 
					command_c["#{tblnamechop}_paretblname"] = child["paretblname"] 
					command_c["#{tblnamechop}_paretblid"] = child["paretblid"]
					command_c["#{tblnamechop}_prjno_id"] = child["prjnos_id"]
					command_c["#{tblnamechop}_chrg_id"] = child["chrgs_id"]
					command_c["#{tblnamechop}_shelfno_id_to"] = child["shelfnos_id_to"]  
					command_c["#{tblnamechop}_duedate"] = child["duedate"]
					command_c["#{tblnamechop}_depdate"] = child["depdate"]
					stkinout["tblname"] = "shpschs"
				when /shpinst|shpact/
					command_c["#{tblnamechop}_shelfno_id_fm"] = child["shelfnos_id_fm"] ###自身の保管先から出庫
					command_c["#{tblnamechop}_qty"] = stkinout["qty"] = child["qty"].to_f * -1
					stkinout["qty_sch"] = stkinout["qty_stk"] = stkinout["qty_real"] = 0
					command_c["#{tblnamechop}_gno"] = child["gno"] 
					command_c["#{tblnamechop}_paretblname"] = child["paretblname"] 
					command_c["#{tblnamechop}_paretblid"] = child["paretblid"]
					command_c["#{tblnamechop}_prjno_id"] = child["prjnos_id"]
					command_c["#{tblnamechop}_chrg_id"] = child["chrgs_id"]
					command_c["#{tblnamechop}_shelfno_id_to"] = child["shelfnos_id_to"]  
					command_c["#{tblnamechop}_duedate"] = child["duedate"]
					command_c["#{tblnamechop}_depdate"] = child["depdate"]
					stkinout["tblname"] = "shpords"
				end
	

				blk.proc_create_tbldata(command_c) ##
				blk.proc_private_aud_rec(reqparams,command_c)
				
				stkinout["wh"] = "lotstkhists"
				stkinout["tblid"] = command_c["id"]
				stkinout["trngantts_id"] = reqparams["gantt"]["trngantts_id"]  ###親 purords,prdordsのtrngantts_id
				stkinout["expiredate"] = command_c[tblnamechop+"_expiredate"]
				stkinout["lotno"] = command_c["#{tblnamechop}_lotno"] 
				stkinout["packno"] =  command_c["#{tblnamechop}_packno"] 
				stkinout["prjnos_id"] = command_c[tblnamechop+"_prjno_id"]
				stkinout["itms_id"] = command_c[tblnamechop+"_itm_id"]
				stkinout["processseq"] = command_c[tblnamechop+"_processseq"]
				stkinout["starttime"] = command_c[tblnamechop+"_depdate"]
				stkinout["units_id_case_shp"] = command_c[tblnamechop+"_unit_id_case_shp"]
				stkinout["shelfnos_id"] = command_c[tblnamechop+"_shelfno_id_fm"]   ###出
				stkinout["remark"] = "Shipment line #{__LINE__}"
				case yield
				when /shpsch|shpord/
					stkinout = proc_lotstkhists_in_out("out",stkinout)
					proc_insert_inoutlotstk_sql(-1,stkinout)
					stkinout["shelfnos_id"] = command_c[tblnamechop+"_shelfno_id_to"]   ###入り
					stkinout = proc_lotstkhists_in_out("in",stkinout)   ###入りと出は同一日
					proc_insert_inoutlotstk_sql(1,stkinout)
				when /shpinst/
					stkinout = proc_lotstkhists_in_out("out",stkinout)
					proc_insert_inoutlotstk_sql(-1,stkinout)
				when /shpact/
					stkinout["shelfnos_id"] = command_c[tblnamechop+"_shelfno_id_to"]   ###入り
					stkinout = proc_lotstkhists_in_out("in",stkinout)   ###入りと出は同一日
					proc_insert_inoutlotstk_sql(1,stkinout)
				end

				###
				#  業者倉庫の時は業者倉庫も更新
				###
				if yield =~ /shpsch|shpord|shpinst/
					sql_check_supplier = %Q&
						select s.id from suppliers s  
							inner join shelfnos s2  on s.locas_id_supplier = s2.locas_id_shelfno  
				 			where s2.id = #{command_c["#{tblnamechop}_shelfno_id_fm"]} and s.expiredate > current_date
						&
					suppliers_id = ActiveRecord::Base.connection.select_value(sql_check_supplier)
					if  suppliers_id
						stkinout["wh"] = "supplierwhs"
						stkinout["suppliers_id"] = suppliers_id
						stkinout["remark"] = "Shipment line #{__LINE__}"
						stkinout = proc_mk_supplierwhs_rec("out",stkinout)
						proc_insert_inoutlotstk_sql(1,stkinout)
					end
				end
				if yield =~ /shpsch|shpord|shpact/
					sql_check_supplier = %Q&
							select s.id from suppliers s  
								inner join shelfnos s2  on s.locas_id_supplier = s2.locas_id_shelfno  
				 				where s2.id = #{command_c["#{tblnamechop}_shelfno_id_to"]} and s.expiredate > current_date
						&
					suppliers_id = ActiveRecord::Base.connection.select_value(sql_check_supplier)
					if  suppliers_id
						stkinout["wh"] = "supplierwhs"
						stkinout["suppliers_id"] = suppliers_id
						stkinout = proc_mk_supplierwhs_rec("in",stkinout)
						stkinout["remark"] = "Shipment line #{__LINE__}"
						proc_insert_inoutlotstk_sql(1,stkinout)
					end
				end
		end ###出庫処理
	end 

	def proc_confirmShpinsts(params)
        begin
            ActiveRecord::Base.connection.begin_db_transaction()
			outcnt = 0
			err = "please select shpords"
			if params["clickIndex"] 
				params["clickIndex"].each do |selected|  ###-次のフェーズに進んでないこと。
					selected = JSON.parse(selected)
					if selected["screenCode"] == "forInsts_shpords"
						prev_shpord = ActiveRecord::Base.connection.select_one(%Q&select * from r_shpords where id = #{selected["id"]}&)
						nextshp_create_by_prevshp(prev_shpord,"shpords","shpinsts")
						outcnt += 1
						err = ""
					end
				end
				if outcnt == 0
				err = "no shpords record"
				end
			end
		rescue
			ActiveRecord::Base.connection.rollback_db_transaction()
			Rails.logger.debug"error class #{self} : #{Time.now}: #{$@}\n "
			Rails.logger.debug"error class #{self} : $!: #{$!} \n"
			err << $!
		else
			ActiveRecord::Base.connection.commit_db_transaction()
		end
		return outcnt,err
	end	

	
	def proc_confirmShpacts(params)
        begin
            ActiveRecord::Base.connection.begin_db_transaction()
			outcnt = 0
			err = "please select shpinsts"
			if params["clickIndex"]
				params["clickIndex"].each do |selected|  ###-次のフェーズに進んでないこと。
					selected = JSON.parse(selected)
					if selected["screenCode"] == "foract_shpinsts"
						prev_shpinst = ActiveRecord::Base.connection.select_one(%Q&select * from r_shpinsts where id = #{selected["id"]}&)
						nextshp_create_by_prevshp(prev_shpinst,"shpinsts","shpacts")
						outcnt += 1
						err = ""
					end
				end
				if outcnt == 0
				err = "no shpords record"
				end
			end
		rescue
			ActiveRecord::Base.connection.rollback_db_transaction()
			Rails.logger.debug"error class #{self} : #{Time.now}: #{$@}\n "
			Rails.logger.debug"error class #{self} : $!: #{$!} \n"
			err << $!
		else
			ActiveRecord::Base.connection.commit_db_transaction()
		end
		return outcnt,err
	end	

	def nextshp_create_by_prevshp(shp,prevshp,nextshp)  ###
		###自分自身のshpschs を作成   
		blk = RorBlkCtl::BlkClass.new("r_#{nextshp}")
		command_c = blk.command_init
		nextshpchop = nextshp.chop
		prevshpchop = prevshp.chop
		command_c["sio_classname"] = "#{nextshp}_add_"
		shpord = {}
		shp.each do |k,val|
			tblchop,field = k.to_s.split("_",2)
			shpord[field.sub("_id","s_id")] = val if tblchop == prevshpchop
			next if field =~ /^qty|^sno|^id$|^isudate|^duedate|^depdate/
			if tblchop == prevshpchop
				command_c["#{nextshpchop}_#{field}"] = val
			end
		end
		command_c["#{nextshpchop}_isudate"] = Time.now
		command_c["#{nextshpchop}_sno"] = command_c["#{nextshpchop}_id"] = "" 	

		case prevshp
		when "shpords"
			command_c["shpinst_depdate"] =  (shp["shpord_depdate"]||=Time.now)
			command_c["shpinst_qty_stk"] =  shp["shpord_qty"]
			if shp["shpord_unit_id_case_shp"] == shp["shpord_unit_id_case_shp"]
				command_c["shpinst_qty_real"] =  shp["shpord_qty"]
			else
				strsql = %Q&
							select qty_stk from lotstkhists where itms_id = #{command_c["#{nextshpchop}_itm_id"] }
														and processseq = #{command_c["#{nextshpchop}_processseq"] }
														and shelfnos_id = #{command_c["#{nextshpchop}_shelfno_id_fm"] }
														and lotno = '#{command_c["#{nextshpchop}_lotno"]}'
														and packno = '#{command_c["#{nextshpchop}_packno"]}'
												order by starttime desc limit 1
				&
				command_c["shpinst_qty_real"] =  ActiveRecord::Base.connection.select_value(strsql)
			end	
		when "shpinsts"
			command_c["shpact_qty_stk"] =  shp["shpinst_qty_stk"]
			command_c["shpact_qty_real"] =  shp["shpinst_qty_real"]
			command_c["shpact_rcptdate"] =  (shp["shpinst_rcptdate"]||= Time.now)
		end
		command_c["#{nextshpchop}_qty_shortage"] = shp["#{prevshpchop}_qty_shortage"]
		command_c["#{nextshpchop}_qty_case"] = shp["#{prevshpchop}_qty_case"]
		blk.proc_create_tbldata(command_c) ##
		blk.proc_private_aud_rec({},command_c)
		
		stkinout = {}
		stkinout["tblname"] = nextshp
		stkinout["tblid"] = command_c["id"]
		stkinout["expiredate"] = command_c["#{nextshpchop}_expiredate"]
		stkinout["lotno"] =   command_c["#{nextshpchop}_lotno"] 
		stkinout["packno"] =  command_c["#{nextshpchop}_packno"] 
		stkinout["prjnos_id"] = command_c["#{nextshpchop}_prjno_id"]
		stkinout["itms_id"] = command_c["#{nextshpchop}_itm_id"]
		stkinout["processseq"] = command_c["#{nextshpchop}_processseq"]
		stkinout["qty_sch"] = 0
		stkinout["qty"] =  0
		stkinout["qty_stk"] = command_c["#{nextshpchop}_qty_stk"]
		stkinout["qty_real"] = command_c["#{nextshpchop}_qty_real"]
		if nextshp == "shpinsts"
			stkinout["shelfnos_id"] = command_c["#{nextshpchop}_shelfno_id_fm"]
			stkinout["starttime"] = command_c["#{nextshpchop}_depdate"]
			###
			#  業者倉庫の時は業者倉庫も更新
			###
			sql_check_supplier = %Q&
						select s.id from suppliers s  
								inner join shelfnos s2  on s.locas_id_supplier = s2.locas_id_shelfno  
								 where s2.id = #{stkinout["shelfnos_id"]} and s.expiredate > current_date
			&
			suppliers_id = ActiveRecord::Base.connection.select_value(sql_check_supplier)
			if  suppliers_id
				stkinout["wh"] = "supplierwhs"
				stkinout["suppliers_id"] = suppliers_id
				stkinout = proc_mk_supplierwhs_rec("out",stkinout)
			else
				stkinout["wh"] = "lotstkhists"
				stkinout = proc_lotstkhists_in_out("out",stkinout)
			end
			strsql = %Q&
				select trngantts_id from linktbls where tblname ='#{shp["#{prevshpchop}_paretblname"]}' 
													and tblid = #{shp["#{prevshpchop}_paretblid"]}
													and srctblname = tblname and srctblid = tblid 
			&
			stkinout["trngantts_id"] = ActiveRecord::Base.connection.select_value(strsql)
			proc_insert_inoutlotstk_sql(-1,stkinout)
			gantt = {"trngantts_id" => stkinout["trngantts_id"]}
			setParams = {"mkprdpurords_id" => 0,"gantt" => gantt,"child" => shpord,"parent" => {"shelfnos_id" => "-1"}}
			proc_create_shpschs_delete_shpords(setParams)  do  ###prd,purordsによる自動作成 も含まれる。
				"shpinst"
			end
		else  ###shpacts
			stkinout["starttime"] = command_c["#{nextshpchop}_rcptdate"]
			stkinout["shelfnos_id"] =  command_c["#{nextshpchop}_shelfno_id_to"]
			sql_check_supplier = %Q&
					select s.id from suppliers s  
							inner join shelfnos s2  on s.locas_id_supplier = s2.locas_id_shelfno  
		 					where s2.id = #{stkinout["shelfnos_id"]} and s.expiredate > current_date
				&
			suppliers_id = ActiveRecord::Base.connection.select_value(sql_check_supplier)
			if  suppliers_id
				stkinout["wh"] = "supplierwhs"
				stkinout["suppliers_id"] = suppliers_id
				stkinout = proc_mk_supplierwhs_rec("in",stkinout)
			else	
				stkinout["wh"] = "lotstkhists"
				stkinout = proc_lotstkhists_in_out("in",stkinout)
			end
			strsql = %Q&
				select trngantts_id from linktbls where tblname ='#{shp["#{prevshpchop}_paretblname"]}' 
													and tblid = #{shp["#{prevshpchop}_paretblid"]}
													and srctblname = tblname and srctblid = tblid 
			&
			stkinout["trngantts_id"] = ActiveRecord::Base.connection.select_value(strsql)
			proc_insert_inoutlotstk_sql(1,stkinout)
			gantt = {"trngantts_id" => stkinout["trngantts_id"]}
			shpord["qty"] = shpord["qty_stk"]
			shpord["qty_stk"] = 0
			setParams = {"mkprdpurords_id" => 0,"gantt" => gantt,"child" => shpord,"parent" => {"shelfnos_id" => "-1"}}
			proc_create_shpschs_delete_shpords(setParams)  do  ###prd,purordsによる自動作成 も含まれる。
				"shpact"
			end
		end
	end

	def proc_create_consume(reqparams) ##
		###prdschs,purschsの時は自分自身のconschs を作成   
		command_c = {}
		parent = reqparams["parent"] ###親
		child = reqparams["child"]  ###対象
		tblnamechop = yield.chop  
		###ActiveRecord::Base.connection.begin_db_transaction()
		blk = RorBlkCtl::BlkClass.new("r_#{tblnamechop}s")
		command_c = blk.command_init
		command_c["sio_code"] =  command_c["sio_viewname"] =  "r_#{yield}"
		command_c["sio_message_contents"] = nil
		command_c["sio_recordcount"] = 1
		command_c["sio_result_f"] =   "0"  
		command_c["sio_classname"] = "#{yield}_add_"
		command_c["#{tblnamechop}_id"] = "" 
		command_c["#{tblnamechop}_itm_id"] = child["itms_id"]
		command_c["#{tblnamechop}_processseq"] = child["processseq"]
		command_c["#{tblnamechop}_consumauto"] = (child["consumauto"]||="")
		command_c["#{tblnamechop}_isudate"] = Time.now 
		command_c["#{tblnamechop}_packno"] =  ""  
		command_c["#{tblnamechop}_lotno"] = "" 
		command_c["#{tblnamechop}_shelfno_id_fm"] =  child["shelfnos_id_fm"] = parent["shelfnos_id"]  ###親の作業場所
		command_c["#{tblnamechop}_gno"] = parent["sno"] 
		command_c["#{tblnamechop}_paretblname"] = parent["tblname"] 
		command_c["#{tblnamechop}_paretblid"] = parent["tblid"]
		command_c["#{tblnamechop}_prjno_id"] = parent["prjnos_id"]
		command_c["#{tblnamechop}_chrg_id"] = parent["chrgs_id"]
		command_c["#{tblnamechop}_duedate"] = case  parent["tblname"] 
													when /schs$|ords$|insts$/
														parent["duedate"]
													when /reply/
														parent["replydate"]
													when /puracts/
														parent["rcptdate"]
													when /prdacts/
														parent["cmpldate"]
													end			
		stkinout = {}
		case parent["tblname"]
		when /schs$/
			prev_contblname = "conschs"
			prev_str_con_qty = "qty_sch"
			str_pare_qty = "qty_sch"
		when /ords$/
			prev_contblname = "conschs"
			prev_str_con_qty = "qty_sch"
			str_pare_qty = "qty"
		when /acts/
			prev_contblname = "conords"
			prev_str_con_qty = "qty"
			str_pare_qty = "qty_stk"
		when /purdlvs/
			prev_contblname = "conords"
			prev_str_con_qty = "qty"
			str_pare_qty = "qtystk"
		else
			prev_contblname = "conords"
			prev_str_con_qty = "qty"
			str_pare_qty = "qty"
		end

		case tblnamechop
		when /sch$/
			str_con_qty = "qty_sch"
		when /ord$/
			str_con_qty = "qty"
		when /act$/
			str_con_qty = "qty_stk"
		when /purdlv$/
			str_con_qty = "qty_stk"
		else
			str_con_qty = "qty"
		end
		
		stkinout["qty_sch"] = stkinout["qty"] = stkinout["qty_stk"] =  stkinout["qty_real"] = 0
		con_qty = CtlFields.proc_cal_qty_sch(parent[str_pare_qty],
										child["chilnum"],child["parenum"],child["consumunitqty"],
										child["consumminqty"],child["consumchgoverqty"])
		stkinout[str_con_qty] = command_c["#{tblnamechop}_#{str_con_qty}"] =  con_qty
		stkinout["qty_real"] = stkinout["qty_stk"]
		blk.proc_create_tbldata(command_c) ##
		setParams = blk.proc_private_aud_rec(reqparams,command_c)
			
		stkinout["shelfnos_id"] = command_c[tblnamechop+"_shelfno_id_fm"]  
		stkinout["tblname"] = yield
		stkinout["tblid"] = command_c["id"]
		stkinout["expiredate"] = command_c[tblnamechop+"_expiredate"]
		stkinout["lotno"] =   command_c["#{tblnamechop}_lotno"] 
		stkinout["packno"] =  command_c["#{tblnamechop}_packno"] 
		stkinout["prjnos_id"] = command_c[tblnamechop+"_prjno_id"]
		stkinout["itms_id"] = command_c[tblnamechop+"_itm_id"]
		stkinout["processseq"] = command_c[tblnamechop+"_processseq"]
		if  parent["tblname"] =~ /^pur/
			stkinout["wh"] = "supplierwhs"
			case  parent["tblname"] 
			when /^purdlvs/
				stkinout["depdate"] = parent["depdate"]
			when /^puracts/  ###purdlvsがあるときはArelCtl.proc_ChildConSqlで対象データを除外済
				stkinout["depdate"] = stkinout["starttime"] = parent["rcptdate"]
			else
				stkinout["depdate"] = stkinout["starttime"] = parent["duedate"]
			end
			strsql = %Q&
					select s.id from suppliers s  
						inner join shelfnos s2  on s.locas_id_supplier = s2.locas_id_shelfno  
						 where s2.id = #{child["shelfnos_id_fm"]} and s.expiredate > current_date
					&
			stkinout["suppliers_id"] = ActiveRecord::Base.connection.select_value(strsql)
			supplierwh_stkinout = proc_mk_supplierwhs_rec("out",stkinout)
		else
			stkinout["wh"] = "lotstkhists"
			if  parent["tblname"] =~ /^prdacts/
				stkinout["starttime"] = parent["cmpldate"]
			else
				stkinout["starttime"] = parent["duedate"]
			end
			stkinout = proc_lotstkhists_in_out("out",stkinout)
		end
		if  tblnamechop == "consch"
			stkinout["trngantts_id"] = reqparams["gantt"]["trngantts_id"] 
			if  parent["tblname"] =~ /^pur/
				supplierwh_stkinout["trngantts_id"] = reqparams["gantt"]["trngantts_id"] 
				proc_insert_inoutlotstk_sql(-1,supplierwh_stkinout)
			else
				proc_insert_inoutlotstk_sql(-1,stkinout)
			end
		else
			prev_stkinout = stkinout.dup
			prev_stkinout["qty_sch"] = prev_stkinout["qty"] = prev_stkinout["qty_stk"] = prev_stkinout["qty_real"] = 0   
			ActiveRecord::Base.connection.select_all(ArelCtl.proc_PrevConSql(parent,child,prev_contblname)).each do |conlink|
				prev_stkinout["trngantts_id"] = stkinout["trngantts_id"] = conlink["trngantts_id"]
				stkinout[str_con_qty] = CtlFields.proc_cal_qty_sch(  conlink["qty_src"].to_f,
												child["chilnum"],child["parenum"],child["consumunitqty"],
												child["consumminqty"],child["consumchgoverqty"])
				proc_insert_inoutlotstk_sql(-1,stkinout)  ###今回の消費の明細
				###  前の状態のリセット
				###next if conlink["prev_paretblname"] == conlink["paretblname"] and conlink["prev_paretblid"] == conlink["paretblid"]  
				prev_stkinout[prev_str_con_qty] = stkinout[str_con_qty] 
				strsql = %Q&
						select duedate from #{conlink["prev_paretblname"]} where id = #{conlink["prev_paretblid"]}
				&
				prev_stkinout["starttime"] = ActiveRecord::Base.connection.select_value(strsql).to_time
				if  parent["tblname"] =~ /^pur/  ###業者倉庫も
					prev_stkinout["wh"] = "supplierwhs"
					strsql = %Q&
							select s.id from suppliers s  
									inner join shelfnos s2  on s.locas_id_supplier = s2.locas_id_shelfno  
									 where s2.id = #{child["shelfnos_id_fm"]} and s.expiredate > current_date
					&
					prev_stkinout["suppliers_id"] = ActiveRecord::Base.connection.select_value(strsql)
					prev_stkinout = proc_mk_supplierwhs_rec("in",prev_stkinout)   ###マイナス在庫の入り
				else
					prev_stkinout["wh"] = "lotstkhists"
					prev_stkinout = proc_lotstkhists_in_out("in",prev_stkinout)
				end
				strsql = %Q&
						select id from #{prev_contblname} where paretblname = '#{conlink["prev_paretblname"]}'
															and paretblid = #{conlink["prev_paretblid"]}
															and itms_id = #{child["itms_id"]} and processseq = #{child["processseq"]}
				&
				prev_stkinout["tblid"] = ActiveRecord::Base.connection.select_value(strsql)
				prev_stkinout["tblname"] = prev_contblname
				check_inoutlotstk("in",prev_stkinout)  ###以前の状態の時の消費
			end
		end
	end	
	
	###shpschs用
	def update_shpschs_ords_by_parent reqparams,last_pare_qty  
		###自分自身のshpschs を作成   
		command_c = {}
		parent = reqparams["tbldata"]
		shp = reqparams["shp"]  ###出庫対象

		tblnamechop = yield.chop
		stkinout = {"wh" => "lotstkhists"}

		###ActiveRecord::Base.connection.begin_db_transaction()
			blk = RorBlkCtl::BlkClass.new("r_#{tblnamechop}s")
			command_c = blk.command_init
			command_c["sio_classname"] = "#{yield}_update_"
			command_c["#{tblnamechop}_id"] = command_c["id"] = shp["id"] 
			command_c["#{tblnamechop}_isudate"] = Time.now
			###自身の保管先から出庫
			stkinout["shelfnos_id"] = command_c["#{tblnamechop}_shelfno_id_fm"] = shp["shelfnos_id_fm"] 
			command_c["#{tblnamechop}_shelfno_id_to"] = shp["shelfnos_id_to"]  ###親の作業場所へ納品
			command_c["#{tblnamechop}_duedate"] = shp["duedate"] 
			stkinout["starttime"] = command_c["#{tblnamechop}_depdate"] = shp["depdate"]
			command_c["#{tblnamechop}_transport_id"] = 0 
			command_c["#{tblnamechop}_paretblname"] = shp["paretblname"] 
			command_c["#{tblnamechop}_paretblid"] = shp["paretblid"]
			command_c["#{tblnamechop}_price"] = shp["price"].to_f 
			stkinout["expiredate"] = command_c[tblnamechop+"_expiredate"] = "2099/12/31"
			
			stkinout["itms_id"] = command_c["#{tblnamechop}_itm_id"] = shp["itms_id"]   ### from shpords
			stkinout["processseq"] = command_c["#{tblnamechop}_processseq"] = shp["processseq"]
			stkinout["packno"] =  command_c["#{tblnamechop}_packno"] = shp["packno"]   
			stkinout["lotno"] = command_c["#{tblnamechop}_lotno"] = shp["lotno"]
			stkinout["prjnos_id"] = command_c[tblnamechop+"_prjno_id"] = shp["prjnos_id"]
			case tblnamechop
			when /shpsch/
				qty_sch = shp["qty_sch"].to_f / last_pare_qty * parent["qty"].to_f 
				command_c["#{tblnamechop}_qty_sch"] = qty_sch
				stkinout["qty"] = stkinout["qty_stk"] =  stkinout["qty_real"] = 0 
				command_c["#{tblnamechop}_amt_sch"] = shp["qty_sch"].to_f * command_c["#{tblnamechop}_price"]
			when /shpord/
				qty = shp["qty"].to_f / last_pare_qty * parent["qty"].to_f
				command_c["#{tblnamechop}_qty"] =  qty
				stkinout["qty_stk"] = stkinout["qty_sch"] =  stkinout["qty_real"] = 0
				command_c["#{tblnamechop}_amt"] = shp["qty"].to_f * command_c["#{tblnamechop}_price"]
			end

			blk.proc_create_tbldata(command_c) ##
			setParams = blk.proc_private_aud_rec(reqparams,command_c)

			stkinout["tblname"] = yield
			stkinout["tblid"] = command_c["id"]
			case tblnamechop
			when "shpsch"
				stkinout["qty_sch"] = qty_sch - shp["qty_sch"].to_f
				stkinout["trngantts_id"] = reqparams["trngantts_id"]
				stkinout = proc_lotstkhists_in_out("out",stkinout)
				check_inoutlotstk("out",stkinout)
				stkinout["starttime"] = command_c[tblnamechop+"_duedate"]
				stkinout["shelfnos_id"] = command_c[tblnamechop+"_shelfno_id_to"]   ###入り
				stkinout = proc_lotstkhists_in_out("in",stkinout)
				check_inoutlotstk("in",stkinout)
			when "shpord"
				stkinout["qty"] = qty - shp["qty"].to_f
				stkinout["trngantts_id"] = reqparams["trngantts_id"]
				stkinout = proc_lotstkhists_in_out("out",stkinout)
				check_inoutlotstk("out",stkinout)
				stkinout["starttime"] = command_c[tblnamechop+"_duedate"]
				stkinout["shelfnos_id"] = command_c[tblnamechop+"_shelfno_id_to"]
				stkinout = proc_lotstkhists_in_out("in",stkinout)
				check_inoutlotstk("in",stkinout)
			end

			###
			#  業者倉庫の時は業者倉庫も更新
			###
			sql_check_supplier = %Q&
					select s.id from suppliers s  
						inner join shelfnos s2  on s.locas_id_supplier = s2.locas_id_shelfno  
						 where s2.id = #{shp["shelfnos_id_fm"]} and s.expiredate > current_date
				&
			suppliers_id = ActiveRecord::Base.connection.select_value(sql_check_supplier)
			if  suppliers_id
				stkinout["wh"] = "supplierwhs"
				stkinout["suppliers_id"] = suppliers_id
				stkinout["shelfnos_id"] = shp["shelfnos_id_fm"] 
				stkinout["starttime"] = shp["depdate"]
				stkinout["remark"] = "Shipment line #{__LINE__}"
				stkinout = proc_mk_supplierwhs_rec("out",stkinout)
				proc_insert_inoutlotstk_sql(1,stkinout)
			end
			sql_check_supplier = %Q&
				select s.id from suppliers s  
					inner join shelfnos s2  on s.locas_id_supplier = s2.locas_id_shelfno  
					 where s2.id = #{shp["shelfnos_id_to"]} and s.expiredate > current_date
				&
			suppliers_id = ActiveRecord::Base.connection.select_value(sql_check_supplier)
			if  suppliers_id
				stkinout["wh"] = "supplierwhs"
				stkinout["suppliers_id"] = suppliers_id
				stkinout["remark"] = "Shipment line #{__LINE__}"
				stkinout = proc_mk_supplierwhs_rec("in",stkinout)
				stkinout["starttime"] = command_c[tblnamechop+"_duedate"]
				stkinout["shelfnos_id"] = command_c[tblnamechop+"_shelfno_id_to"]
				proc_insert_inoutlotstk_sql(1,stkinout)
			end	
		####
	end		

	###
	def proc_lotstkhists_in_out(inout,stkinout)   ###,old_alloc,srctblname
		case inout
		when "out" 
			plusminus = -1
		else  ### in update
			plusminus = 1
		end	
		new_stkinout = stkinout.dup
		ActiveRecord::Base.connection.execute("lock table lotstkhists in  SHARE ROW EXCLUSIVE mode")
		###ActiveRecord::Base.connection.select_one("select * from itms where id = #{stkinout["itms_id"]} for update")
		strsql = %Q% select *	from lotstkhists
								where   itms_id = #{stkinout["itms_id"]} and  
										shelfnos_id = #{stkinout["shelfnos_id"]} and 
										processseq = #{stkinout["processseq"]} and
										prjnos_id = #{stkinout["prjnos_id"]} and
										starttime = to_timestamp('#{stkinout["starttime"]}','yyyy-mm-dd hh24:mi:ss') and 
										packno = '#{stkinout["packno"]}' and  lotno = '#{stkinout["lotno"]}'
										---　一件のみ
				%
		lotstkhists =  ActiveRecord::Base.connection.select_one(strsql)
		if lotstkhists.nil?
			last_strsql = %Q% select *	from lotstkhists
									where   itms_id = #{stkinout["itms_id"]} and  											  
										shelfnos_id = #{stkinout["shelfnos_id"]} and 
										processseq = #{stkinout["processseq"]} and
										prjnos_id = #{stkinout["prjnos_id"]} and
										starttime < to_timestamp('#{stkinout["starttime"]}','yyyy-mm-dd hh24:mi:ss') and 
										packno = '#{stkinout["packno"]}' and  lotno = '#{stkinout["lotno"]}'
									order by starttime desc limit 1
					%
			last_lot =  ActiveRecord::Base.connection.select_one(last_strsql)
			if last_lot.nil?
				last_lot = {"qty_sch" =>0,"qty" => 0,"qty_stk" => 0,"qty_real" => 0,"packno" => "","lotno" => ""}
			end
			new_stkinout = stkinout.dup	
			new_stkinout["qty_sch"] = stkinout["qty_sch"].to_f * plusminus + last_lot["qty_sch"].to_f 
			new_stkinout["qty"]     = stkinout["qty"].to_f * plusminus  + last_lot["qty"].to_f
			new_stkinout["qty_stk"] = stkinout["qty_stk"].to_f * plusminus +  last_lot["qty_stk"].to_f
			new_stkinout["qty_real"] = stkinout["qty_real"].to_f * plusminus +  last_lot["qty_real"].to_f
			new_stkinout["lotstkhists_id"] = stkinout["lotstkhists_id"] = stkinout["srctblid"] = ArelCtl.proc_get_nextval("lotstkhists_seq") 
			ActiveRecord::Base.connection.insert(insert_lotstkhists_sql(new_stkinout)) 
			###
		else
			stkinout["lotstkhists_id"] =  stkinout["srctblid"] = lotstkhists["id"]
			###
			new_stkinout["qty_sch"] = stkinout["qty_sch"].to_f * plusminus  + lotstkhists["qty_sch"].to_f
			new_stkinout["qty"]     = stkinout["qty"].to_f * plusminus  + lotstkhists["qty"].to_f
			new_stkinout["qty_stk"] = stkinout["qty_stk"].to_f * plusminus  +  lotstkhists["qty_stk"].to_f
			new_stkinout["qty_real"] = stkinout["qty_real"].to_f * plusminus  +  lotstkhists["qty_real"].to_f
			strsql = %Q& update lotstkhists set  
									updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
									persons_id_upd = #{$person_code_chrg||=0},
									qty_stk = #{new_stkinout["qty_stk"]},
									qty_real = #{new_stkinout["qty_real"]},
									qty = #{new_stkinout["qty"]} ,
									qty_sch = #{new_stkinout["qty_sch"].to_f}  
									where id = #{lotstkhists["id"]}					
						&
			ActiveRecord::Base.connection.update(strsql)
		end
		###先の推定在庫を変更する。
		strsql = %Q& select *
								from lotstkhists
								where   itms_id = #{stkinout["itms_id"]} and  
										shelfnos_id = #{stkinout["shelfnos_id"]} and 
										processseq = #{stkinout["processseq"]} and
										prjnos_id = #{stkinout["prjnos_id"]} and
										starttime > to_timestamp('#{stkinout["starttime"]}','yyyy-mm-dd hh24:mi:ss') and 
										packno = '#{stkinout["packno"]}' and  lotno = '#{stkinout["lotno"]}'
										order by starttime 
				&
		ActiveRecord::Base.connection.select_all(strsql).each do |futrec|
			strsql = %Q& update lotstkhists set  
									updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
									persons_id_upd = #{$person_code_chrg||=0},
									qty_stk = #{stkinout["qty_stk"].to_f * plusminus + futrec["qty_stk"].to_f},
									qty = #{stkinout["qty"].to_f * plusminus + futrec["qty"].to_f},
									qty_sch = #{stkinout["qty_sch"].to_f  * plusminus + futrec["qty_sch"].to_f} 
									where id = #{futrec["id"]}					
						&
			ActiveRecord::Base.connection.update(strsql) 
		end
		return stkinout
	end

	def check_inoutlotstk(inout,stkinout)
		if inout == "out"
			plusminus = -1
		else
			plusminus = 1
		end
		strsql = %Q&
			select * from inoutlotstks where trngantts_id = #{stkinout["trngantts_id"]}
										and srctblid = #{stkinout["srctblid"]} and srctblname = '#{stkinout["wh"]}'
										and tblid = #{stkinout["tblid"]} and tblname = '#{stkinout["tblname"]}'
										for update
		&
		inoutlotstk = ActiveRecord::Base.connection.select_one(strsql)
		if inoutlotstk
			update_sql = %Q&
				update inoutlotstks set qty_sch = qty_sch + #{stkinout["qty_sch"].to_f * plusminus},
										qty = qty + #{stkinout["qty"].to_f * plusminus},
										qty_stk = qty_stk + #{stkinout["qty_stk"].to_f * plusminus},
										updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
										remark = '#{stkinout["remark"]}'
						where id = #{inoutlotstk["id"]}				 
			& 
			ActiveRecord::Base.connection.update(update_sql)
		else
			proc_insert_inoutlotstk_sql(plusminus,stkinout)
		end	
	end
	
	def insert_lotstkhists_sql stkinout
		 %Q&insert into lotstkhists(id,
								starttime,
								itms_id,processseq,
								shelfnos_id,stktaking_proc,
								qty_sch,qty_stk,qty,qty_real,
								lotno,packno,
								prjnos_id,
								created_at,
								updated_at,
								update_ip,persons_id_upd,expiredate,remark)
						values(#{stkinout["lotstkhists_id"]},
								'#{stkinout["starttime"]}',
								#{stkinout["itms_id"]} ,#{stkinout["processseq"]},
								#{stkinout["shelfnos_id"]},'#{stkinout["stktaking_proc"]}',
								#{stkinout["qty_sch"]} ,#{stkinout["qty_stk"]},#{stkinout["qty"]},#{stkinout["qty_real"]||=stkinout["qty_stk"]},
								'#{stkinout["lotno"]}' ,'#{stkinout["packno"]}',
								#{stkinout["prjnos_id"]},
								to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
								to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
								' ',#{$person_code_chrg||=0},'2099/12/31','#{stkinout["remark"]}')
		&
	 end

	def proc_insert_inoutlotstk_sql(plusminus,stkinout)
		inoutlotstks_seq = ArelCtl.proc_get_nextval("inoutlotstks_seq")
		strsql =   %Q&insert into inoutlotstks(id,
								 trngantts_id,
								 tblname,tblid,
								 srctblname,srctblid,
								 qty_sch,   
								 qty_stk,
								 qty,
								 created_at,
								 updated_at,
								 update_ip,persons_id_upd,expiredate,remark)
						values(#{inoutlotstks_seq},
								 #{stkinout["trngantts_id"]},
								 '#{stkinout["tblname"]}',#{stkinout["tblid"]},
								 '#{stkinout["wh"]}',#{stkinout["srctblid"]},
								 #{stkinout["qty_sch"].to_f * plusminus} ,
								 #{stkinout["qty_stk"].to_f * plusminus},
								 #{stkinout["qty"].to_f * plusminus},
								 to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
								 to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
								 ' ',#{$person_code_chrg||=0},'2099/12/31','#{stkinout["remark"]}')
		&
		ActiveRecord::Base.connection.insert(strsql)
		return inoutlotstks_seq
	end
	
	def proc_mk_custwhs_rec inout,stkinout  ###lotstkhistsは棚のみ
		if inout == "in"
			plusminus = 1
		else
			plusminus = -1
		end
		strsql = %Q&
				select * from custwhs where itms_id = #{stkinout["itms_id"]} and processseq = #{stkinout["processseq"]}
					and custrcvplcs_id = #{stkinout["custrcvplcs_id"]} and lotno = '#{stkinout["lotno"]}'
					and starttime = '#{stkinout["starttime"]}'
		&
		rec = ActiveRecord::Base.connection.select_one(strsql)
		if rec.nil?
			custwhs_id = ArelCtl.proc_get_nextval("custwhs_seq")
			strsql = %Q&insert into custwhs(id,custrcvplcs_id,
								starttime,
								qty_sch,qty,qty_stk,
								lotno,itms_id,processseq,
								created_at,
								updated_at,
								update_ip,persons_id_upd,expiredate,remark)
						values(#{custwhs_id},#{stkinout["custrcvplcs_id"]},
								'#{stkinout["starttime"]}',
								#{stkinout["qty_sch"]},#{stkinout["qty"]},#{stkinout["qty_stk"]},
								'#{stkinout["lotno"]}',#{stkinout["itms_id"]},#{stkinout["processseq"]},
								to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
								to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
								' ','#{$person_code_chrg||=0}','2099/12/31','#{stkinout["remark"]}')
				&
			ActiveRecord::Base.connection.insert(strsql)
		else
			custwhs_id = rec["id"]
			update_sql = %Q% update custwhs set 
									updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
									qty_sch = qty_sch + #{stkinout["qty_sch"].to_f * plusminus},
									qty = qty + #{stkinout["qty"].to_f * plusminus},
									qty_stk = qty_stk + #{stkinout["qty_stk"].to_f * plusminus},
									remark = '#{stkinout["remark"] }'
									where id = #{custwhs_id} 
				%
			ActiveRecord::Base.connection.update(update_sql) 
		end
		stkinout["srctblid"] =  custwhs_id
		return stkinout
	end

	def proc_mk_supplierwhs_rec inout,stkinout  ###lotstkhistsは棚のみ

		if inout == "in"
			plusminus = 1
		else
			plusminus = -1
		end
		strsql = %Q& ---packnoの管理はしない。
				select * from supplierwhs where itms_id = #{stkinout["itms_id"]} and processseq = #{stkinout["processseq"]}
										and suppliers_id = #{stkinout["suppliers_id"]} and lotno = '#{stkinout["lotno"]}'
										and starttime = to_timestamp('#{stkinout["starttime"]}','yyyy/mm/dd hh24:mi:ss')
		&
		rec = ActiveRecord::Base.connection.select_one(strsql)
		if rec.nil?
			supplierwhs_id = ArelCtl.proc_get_nextval("supplierwhs_seq")
			strsql = %Q&insert into supplierwhs(id,suppliers_id,
								starttime,
								qty_sch,
								qty,
								qty_stk,
								lotno,itms_id,processseq,
								created_at,
								updated_at,
								update_ip,persons_id_upd,expiredate,remark)
						values(#{supplierwhs_id},#{stkinout["suppliers_id"]},
								'#{stkinout["starttime"]}',
								#{stkinout["qty_sch"].to_f * plusminus},
								#{stkinout["qty"].to_f * plusminus},
								#{stkinout["qty_stk"].to_f * plusminus},
								'#{stkinout["lotno"]}',#{stkinout["itms_id"]},#{stkinout["processseq"]},
								to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
								to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
								' ','#{$person_code_chrg||=0}','2099/12/31','')
				&
			ActiveRecord::Base.connection.insert(strsql)
		else
			update_sql = %Q% update supplierwhs set 
									updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
									qty_sch = qty_sch + #{stkinout["qty_sch"].to_f * plusminus},
									qty = qty + #{stkinout["qty"].to_f * plusminus},
									qty_stk = qty_stk + #{stkinout["qty_stk"].to_f * plusminus}
									where id = #{rec["id"]} 
				%
			ActiveRecord::Base.connection.update(update_sql) 
			supplierwhs_id = rec["id"]
		end
		stkinout["srctblid"] = supplierwhs_id
		return stkinout
	end

	def shpord_create_by_shpsch(shp,nd,stk)  ###
		###自分自身のshpschs を作成   
		blk = RorBlkCtl::BlkClass.new("r_shpords")
		command_c = blk.command_init
		command_c["sio_classname"] = "shpords_add_"
		command_c["shpord_id"] = "" 
		command_c["shpord_isudate"] = Time.now
		command_c["shpord_shelfno_id_to"] = shp["shelfnos_id_to"] ##
		command_c["shpord_shelfno_id_fm"] = shp["shelfnos_id_fm"]  ###
		command_c["shpord_duedate"] = shp["pare_starttime"].to_time - 24*3600
		command_c["shpord_depdate"] = shp["pare_starttime"].to_time - 2*24*3600
		command_c["shpord_transport_id"] = shp["transports_id"]
		command_c["shpord_paretblname"] = shp["paretblname"] 
		command_c["shpord_paretblid"] = shp["paretblid"]
		command_c["shpord_itm_id"] = shp["itms_id"]   ### from shpords
		command_c["shpord_processseq"] = shp["processseq"]
		command_c["shpord_prjno_id"] = shp["prjnos_id"]
		command_c["shpord_chrg_id"] = shp["chrgs_id"]

		if shp["paretblname"] =~ /^pur/   ###tblname= 'feepayment'--->有償支給
			command_c = PriceLib.proc_price_amt("shpord",command_c)
		else
			command_c["shpord_crr_id"] = 0
			command_c["shpord_price"] = 0
			command_c["shpord_tax"] = 0
		end		
		command_c["shpord_qty_case"] =  shp["qty_case"]
		command_c["shpord_tax"] = 0   ###CtlFieldsから求める。
		command_c["shpord_sno"] = "" 	

		command_c["shpord_qty"] = shp["qty"]
		command_c["shpord_qty_shortage"] = shp["qty_shortage"].to_f  
		command_c["shpord_qty_case"] =  if stk["packqty"].to_f == 0 
												1
											else
												(qty / stk["packqty"].to_f).ceil
											end
		command_c["shpord_amt"] = command_c["shpord_qty"] * command_c["shpord_price"].to_f  ###CtlFieldsから求める。
		command_c["shpord_packno"] = stk["packno"]  
		command_c["shpord_lotno"] = stk["lotno"]

		blk.proc_create_tbldata(command_c) ##
		blk.proc_private_aud_rec({},command_c)
		
		stkinout = {}
		stkinout["tblname"] = "shpords"
		stkinout["tblid"] = command_c["id"]
		stkinout["trngantts_id"] = shp["trngantts_id"]  ###親tableのtrngannts_id
		stkinout["expiredate"] = command_c["shpord_expiredate"]
		stkinout["lotno"] =   command_c["shpord_lotno"] 
		stkinout["packno"] =  command_c["shpord_packno"] 
		stkinout["prjnos_id"] = command_c["shpord_prjno_id"]
		stkinout["itms_id"] = command_c["shpord_itm_id"]
		stkinout["processseq"] = command_c["shpord_processseq"]
		stkinout["starttime"] = command_c["shpord_depdate"]
		stkinout["qty_sch"] = 0
		stkinout["qty"] =  command_c["shpord_qty"]
		stkinout["qty_stk"] = stkinout["qty_real"] = 0
		stkinout["shelfnos_id"] = command_c["shpord_shelfno_id_fm"]
		stkinout["wh"] = "lotstkhists"
		stkinout["remark"] = "Shipment line #{__LINE__}"
		stkinout = proc_lotstkhists_in_out("out",stkinout)
		proc_insert_inoutlotstk_sql(-1,stkinout)
		stkinout["starttime"] = command_c["shpord_duedate"]
		stkinout["shelfnos_id"] =  command_c["shpord_shelfno_id_to"]
		stkinout["remark"] = "Shipment line #{__LINE__}"
		stkinout = proc_lotstkhists_in_out("in",stkinout)
		proc_insert_inoutlotstk_sql(1,stkinout)
		###
		#  業者倉庫の時は業者倉庫も更新
		###
		sql_check_supplier = %Q&
					select s.id from suppliers s  
							inner join shelfnos s2  on s.locas_id_supplier = s2.locas_id_shelfno  
		 					where s2.id = #{shp["shelfnos_id_fm"]} and s.expiredate > current_date
			&
		suppliers_id = ActiveRecord::Base.connection.select_value(sql_check_supplier)
		if  suppliers_id
				stkinout["wh"] = "supplierwhs"
				stkinout["suppliers_id"] = suppliers_id
				stkinout["remark"] = "Shipment line #{__LINE__}"
				stkinout = proc_mk_supplierwhs_rec("out",stkinout)
				proc_insert_inoutlotstk_sql(1,stkinout)
		end
		sql_check_supplier = %Q&
					select s.id from suppliers s  
							inner join shelfnos s2  on s.locas_id_supplier = s2.locas_id_shelfno  
		 					where s2.id = #{shp["shelfnos_id_to"]} and s.expiredate > current_date
				&
		suppliers_id = ActiveRecord::Base.connection.select_value(sql_check_supplier)
		if  suppliers_id
				stkinout["wh"] = "supplierwhs"
				stkinout["suppliers_id"] = suppliers_id
				stkinout["remark"] = "Shipment line #{__LINE__}"
				stkinout = proc_mk_supplierwhs_rec("in",stkinout)
				proc_insert_inoutlotstk_sql(1,stkinout)
		end
	end	
end    
