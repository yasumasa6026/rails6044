# -*- coding: utf-8 -*-
#shipment
# 2099/12/31を修正する時は　2100/01/01の修正も
module Shipment
	extend self
	def proc_mkShpords params   ###screenCode:r_purords,r_prdords
		clickIndex  = params["clickIndex"].dup
    screenCode = params["screenCode"]
		###shpschsは変更済
		pagedata = []
		outcnt = 0
		shortcnt = 0
		err = ""
		parent = {}
    last_lotstks = []
    begin
      ActiveRecord::Base.connection.begin_db_transaction()
			clickIndex.each do |strselected|  ###-次のフェーズに進んでないこと。
				selected = JSON.parse(strselected)
				next if selected["id"].nil?
				### prd,pur ords,instsでshpordsは自動作成されている。
				strsql = %Q&	select * from #{screenCode.split("_")[1]} where id = #{selected["id"]} 	&
				parent = ActiveRecord::Base.connection.select_one(strsql)
        parent["tblname"] = screenCode.split("_")[1]
				parent["tblid"] = selected["id"]
					shpord_strsql = %Q&
            select t.itms_id_trn itms_id,t.processseq_trn processseq,max(t.id) trngantts_id,
								t.prjnos_id,t.chrgs_id_trn,
								t.consumtype,t.parenum,t.chilnum,t.consumunitqty,t.consumminqty,t.consumchgoverqty,
								t.shelfnos_id_pare,   ---親作業場所
								t.shelfnos_id_to_trn shelfnos_id_to,   ---子の保管先
                ope.packqty,'' packno,'' lotno,
								ope.units_id_case_shp,ope.consumauto,ope.shpordauto,
               --- alloc.srctblname ,alloc.srctblid,
                  sum(alloc.qty_linkto_alloctbl) qty_sch,0 qty,0 qty_stk  from trngantts t
              inner join (select pare.*	from trngantts pare
							                  inner join alloctbls alloc on alloc.trngantts_id = pare.id 
							                  where alloc.srctblname =  '#{parent["tblname"]}'  and  alloc.srctblid = #{parent["tblid"]} 	
                                and alloc.qty_linkto_alloctbl  > 0) p
                              on p.orgtblname = t.orgtblname and p.orgtblid = t.orgtblid 
                              and p.tblname = t.paretblname and p.tblid = t.paretblid 
                              and p.paretblname != t.paretblname and p.paretblid != t.paretblid   
							inner join opeitms ope on t.itms_id_trn = ope.itms_id and t.processseq_trn = ope.processseq
											and t.shelfnos_id_trn = ope.shelfnos_id_opeitm
							inner join alloctbls alloc on alloc.trngantts_id = t.id and alloc.qty_linkto_alloctbl  > 0    
							where not exists(select 1 from shpords s where paretblname =  '#{parent["tblname"]}' and  paretblid = #{parent["tblid"]}
																and s.qty > 0	)		
              and alloc.srctblname like '%schs'
              group by t.itms_id_trn ,t.processseq_trn ,	t.prjnos_id,t.chrgs_id_trn,
								t.consumtype,t.parenum,t.chilnum,t.consumunitqty,t.consumminqty,t.consumchgoverqty,
                ope.packqty,
								t.shelfnos_id_pare, t.shelfnos_id_to_trn ,  ope.units_id_case_shp,ope.consumauto,ope.shpordauto	
          union
            select t.itms_id_trn itms_id,t.processseq_trn processseq,max(t.id) trngantts_id,
								t.prjnos_id,t.chrgs_id_trn,
								t.consumtype,t.parenum,t.chilnum,t.consumunitqty,t.consumminqty,t.consumchgoverqty,
								t.shelfnos_id_pare,   ---親作業場所
								t.shelfnos_id_to_trn shelfnos_id_to,   ---子の保管先
                ope.packqty,'' packno,'' lotno,
								ope.units_id_case_shp,ope.consumauto,ope.shpordauto,
               --- alloc.srctblname ,alloc.srctblid,
                  0 qty_sch,sum(alloc.qty_linkto_alloctbl)  qty,0 qty_stk  from trngantts t
              inner join (select pare.*	from trngantts pare
							                  inner join alloctbls alloc on alloc.trngantts_id = pare.id 
							                  where alloc.srctblname =  '#{parent["tblname"]}' and  alloc.srctblid = #{parent["tblid"]} 	
                                and alloc.qty_linkto_alloctbl  > 0) p
                              on p.orgtblname = t.orgtblname and p.orgtblid = t.orgtblid 
                              and p.tblname = t.paretblname and p.tblid = t.paretblid   
                              and (p.paretblname != t.paretblname or p.paretblid != t.paretblid ) 
							inner join opeitms ope on t.itms_id_trn = ope.itms_id and t.processseq_trn = ope.processseq
											and t.shelfnos_id_trn = ope.shelfnos_id_opeitm
							inner join alloctbls alloc on alloc.trngantts_id = t.id and alloc.qty_linkto_alloctbl  > 0    
							where not exists(select 1 from shpords s where paretblname ='#{parent["tblname"]}' and  paretblid = #{parent["tblid"]}
																and s.qty > 0	)		
              and (alloc.srctblname like '%ords' or alloc.srctblname like '%insts' or alloc.srctblname like '%reply')  
              group by t.itms_id_trn ,t.processseq_trn ,	t.prjnos_id,t.chrgs_id_trn,
								t.consumtype,t.parenum,t.chilnum,t.consumunitqty,t.consumminqty,t.consumchgoverqty,
                ope.packqty,
								t.shelfnos_id_pare, t.shelfnos_id_to_trn ,  ope.units_id_case_shp,ope.consumauto,ope.shpordauto	
          union 
            select t.itms_id_trn itms_id,t.processseq_trn processseq,max(t.id) trngantts_id,
								t.prjnos_id,t.chrgs_id_trn,
								t.consumtype,t.parenum,t.chilnum,t.consumunitqty,t.consumminqty,t.consumchgoverqty,
								t.shelfnos_id_pare,   ---親作業場所
								t.shelfnos_id_to_trn shelfnos_id_to,   ---子の保管先
                ope.packqty,''  packno,'' lotno,
								ope.units_id_case_shp,ope.consumauto,ope.shpordauto,
                  0 qty_sch,0 qty,sum(alloc.qty_linkto_alloctbl)  qty_stk  from trngantts t
              inner join (select pare.*	from trngantts pare
							                  inner join alloctbls alloc on alloc.trngantts_id = pare.id 
							                  where alloc.srctblname =  '#{parent["tblname"]}' and  alloc.srctblid = #{parent["tblid"]} 	
                                and alloc.qty_linkto_alloctbl  > 0) p
                              on p.orgtblname = t.orgtblname and p.orgtblid = t.orgtblid 
                              and p.tblname = t.paretblname and p.tblid = t.paretblid   
                              and (p.paretblname != t.paretblname or p.paretblid != t.paretblid ) 
							inner join opeitms ope on t.itms_id_trn = ope.itms_id and t.processseq_trn = ope.processseq
											and t.shelfnos_id_trn = ope.shelfnos_id_opeitm
							inner join alloctbls alloc on alloc.trngantts_id = t.id and alloc.qty_linkto_alloctbl  > 0    
							where not exists(select 1 from shpords s where  paretblname =  '#{parent["tblname"]}' and  paretblid = #{parent["tblid"]}
																and s.qty > 0	)		
              and alloc.srctblname like '%dlvs'
              group by t.itms_id_trn ,t.processseq_trn ,	t.prjnos_id,t.chrgs_id_trn,
								t.consumtype,t.parenum,t.chilnum,t.consumunitqty,t.consumminqty,t.consumchgoverqty,
                ope.packqty, 
								t.shelfnos_id_pare, t.shelfnos_id_to_trn ,  ope.units_id_case_shp,ope.consumauto,ope.shpordauto	
          union 
            select t.itms_id_trn itms_id,t.processseq_trn processseq,max(t.id) trngantts_id,
								t.prjnos_id,t.chrgs_id_trn,
								t.consumtype,t.parenum,t.chilnum,t.consumunitqty,t.consumminqty,t.consumchgoverqty,
								t.shelfnos_id_pare,   ---親作業場所
								t.shelfnos_id_to_trn shelfnos_id_to,   ---子の保管先
                ope.packqty,alloc.packno  packno,alloc.lotno lotno,
								ope.units_id_case_shp,ope.consumauto,ope.shpordauto,
                  0 qty_sch,0 qty,sum(alloc.qty_linkto_alloctbl)  qty_stk  from trngantts t
              inner join (select pare.*	from trngantts pare
							                  inner join alloctbls alloc on alloc.trngantts_id = pare.id 
							                  where alloc.srctblname =  '#{parent["tblname"]}' and  alloc.srctblid = #{parent["tblid"]} 	
                                and alloc.qty_linkto_alloctbl  > 0) p
                              on p.orgtblname = t.orgtblname and p.orgtblid = t.orgtblid 
                              and p.tblname = t.paretblname and p.tblid = t.paretblid   
                              and (p.paretblname != t.paretblname or p.paretblid != t.paretblid ) 
							inner join opeitms ope on t.itms_id_trn = ope.itms_id and t.processseq_trn = ope.processseq
											and t.shelfnos_id_trn = ope.shelfnos_id_opeitm
							inner join (select a.*,act.packno,act.lotno,act.opeitms_id from alloctbls a
                                inner join prdacts act on act.id = a.srctblid and a.qty_linkto_alloctbl > 0)
                        alloc on alloc.trngantts_id = t.id     
							where not exists(select 1 from shpords s where  paretblname =  '#{parent["tblname"]}' and  paretblid = #{parent["tblid"]}
																and s.qty > 0	)		
              and alloc.srctblname = 'prdacts'   and alloc.opeitms_id = ope.id
              group by t.itms_id_trn ,t.processseq_trn ,	t.prjnos_id,t.chrgs_id_trn,
								t.consumtype,t.parenum,t.chilnum,t.consumunitqty,t.consumminqty,t.consumchgoverqty,
                ope.packqty, alloc.packno ,alloc.lotno,
								t.shelfnos_id_pare, t.shelfnos_id_to_trn ,  ope.units_id_case_shp,ope.consumauto,ope.shpordauto	
          union 
            select t.itms_id_trn itms_id,t.processseq_trn processseq,max(t.id) trngantts_id,
								t.prjnos_id,t.chrgs_id_trn,
								t.consumtype,t.parenum,t.chilnum,t.consumunitqty,t.consumminqty,t.consumchgoverqty,
								t.shelfnos_id_pare,   ---親作業場所
								t.shelfnos_id_to_trn shelfnos_id_to,   ---子の保管先
                ope.packqty,alloc.packno  packno,alloc.lotno lotno,
								ope.units_id_case_shp,ope.consumauto,ope.shpordauto,
                  0 qty_sch,0 qty,sum(alloc.qty_linkto_alloctbl)  qty_stk  from trngantts t
              inner join (select pare.*	from trngantts pare
							                  inner join alloctbls alloc on alloc.trngantts_id = pare.id 
							                  where alloc.srctblname =  '#{parent["tblname"]}' and  alloc.srctblid = #{parent["tblid"]} 	
                                and alloc.qty_linkto_alloctbl  > 0) p
                              on p.orgtblname = t.orgtblname and p.orgtblid = t.orgtblid 
                              and p.tblname = t.paretblname and p.tblid = t.paretblid   
                              and (p.paretblname != t.paretblname or p.paretblid != t.paretblid ) 
							inner join opeitms ope on t.itms_id_trn = ope.itms_id and t.processseq_trn = ope.processseq
											and t.shelfnos_id_trn = ope.shelfnos_id_opeitm
							inner join (select a.*,act.packno,act.lotno,act.opeitms_id from alloctbls a
                                inner join puracts act on act.id = a.srctblid and a.qty_linkto_alloctbl > 0)
                        alloc on alloc.trngantts_id = t.id     
							where not exists(select 1 from shpords s where  paretblname =  '#{parent["tblname"]}' and  paretblid = #{parent["tblid"]}
																and s.qty > 0	)		
              and alloc.srctblname = 'puracts'   and alloc.opeitms_id = ope.id
              group by t.itms_id_trn ,t.processseq_trn ,	t.prjnos_id,t.chrgs_id_trn,
								t.consumtype,t.parenum,t.chilnum,t.consumunitqty,t.consumminqty,t.consumchgoverqty,
                ope.packqty, alloc.packno ,alloc.lotno,
								t.shelfnos_id_pare, t.shelfnos_id_to_trn ,  ope.units_id_case_shp,ope.consumauto,ope.shpordauto	
					&
					shpschs_sql = %Q$
						select link.tblname ord_tblname,link.tblid ord_tblid from linktbls link
									where link.tblname = '#{parent["tblname"]}' and  link.tblid = #{parent["tblid"]}
									and	link.srctblname like '%ords' 	
									and not exists(select 1 from shpords s where paretblname = '#{parent["tblname"]}' and  paretblid = #{parent["tblid"]}
													---既にshpordsを作成済の時は削除するshpschsはない。
															)				
            union ---/ITool|mold/ by xxxords
						  select link.tblname ord_tblname,link.tblid ord_tblid from linktbls link
									where link.tblname = '#{parent["tblname"]}' and  link.tblid = #{parent["tblid"]}
									and	link.srctblname like '%schs' 	
									and not exists(select 1 from shpords s where paretblname = '#{parent["tblname"]}' and  paretblid = #{parent["tblid"]}
													---既にshpordsを作成済の時は削除するshpschsはない。
															)		
            union ---/ITool|mold/ by xxxinst
						  select link.tblname ord_tblname,link.tblid ord_tblid from linktbls link
                  inner join linktbls linkinst on link.tblname = linkinst.srctblname and link.tblid = linkinst.srctblid 
									where linkinst.tblname = '#{parent["tblname"]}' and  linkinst.tblid = #{parent["tblid"]}
									and	link.srctblname like '%schs' 	
									and not exists(select 1 from shpords s where paretblname = '#{parent["tblname"]}' and  paretblid = #{parent["tblid"]}
													---既にshpordsを作成済の時は削除するshpschsはない。
															)		
						$
				ord_shpschs = ActiveRecord::Base.connection.select_all(shpschs_sql)	
				###在庫の確認
				err = ""
				outcnt = shortcnt = 0
        child = {}
        ActiveRecord::Base.connection.select_all(shpord_strsql).each do |shpord|
          shp = shpord.dup
					if shp["consumtype"] =~ /CON|ITool|mold/  ###出庫 消費と金型・設備の使用
						if shp["shpordauto"] != "M"   ###手動出庫は除く
								shp["persons_id_upd"] = params["person_id_upd"]
								shp["pare_qty"] = parent["qty"]
								shp["pare_starttime"] = parent["starttime"]
                shp["duedate"] = (shp["pare_starttime"].to_time - 1*3600).strftime("%Y/%m/%d %H:%M:%S")  ###稼働日　稼働時間
                shp["depdate"] = (shp["pare_starttime"].to_time - 4*3600).strftime("%Y/%m/%d %H:%M:%S")
								shp["trngantts_id"] = shp["trngantts_id"]
								shp["shelfnos_id_to"] = shp["shelfnos_id_pare"]
								shp["shelfnos_id_fm"] = shp["shelfnos_id_to"]  
								shp["paretblname"] = parent["tblname"]
								shp["paretblid"] = parent["tblid"]
								shp["qty_case"] = 0
								shp["qty"] = save_qty_stk = shp["qty_stk"].to_f
								shp["qty_shortage"] = shp["qty_sch"].to_f + shp["qty"].to_f
                if shp["qty_shortage"] > 0
                  save_lotno = shp["lotno"]
                  save_packno = shp["packno"]
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
									if shp["shuffle_flg"] == "S"   ###他に在庫があれば引当るケース
                    ActiveRecord::Base.connection.select_all(shuffle_sql).each do |stk|
                      if save_lotno == stk["lotno"]  and save_packno == stk["packno"]
                          stk["qty_stk"] =  stk["qty_stk"].to_f - save_qty_stk
                          next if stk["qty_stk"] <= 0
                      end
                      shpf = true
                      if shp["packno"] != stk["packno"] or shp["lotno"] != stk["lotno"]
                        outcnt += 1
                        last_lotstks_parts = shpord_create_by_shpsch(shp)   ###
                        last_lotstks.concat last_lotstks_parts
                        shp["packno"] = stk["packno"]
                        shp["lotno"] = stk["lotno"]
                        if shp["qty_shortage"] >  stk["qty_stk"].to_f
                          shp["qty_shortage"] -= stk["qty_stk"].to_f
                          shp["qty_stk"] = stk["qty_stk"].to_f
                        else
                          shp["qty_stk"] =  shp["qty_shortage"] 
                          shp["qty_shortage"] = 0
                          outcnt += 1
                          last_lotstks_parts = shpord_create_by_shpsch(shp)   ###
                          last_lotstks.concat last_lotstks_parts
                          shpf = false
                          break
                        end
                      else 
                        if shp["qty_shortage"] > stk["qty_stk"].to_f
								          shp["qty"] = shp["qty"].to_f + stk["qty_stk"].to_f
                          shp["qty_shortage"] -= stk["qty_stk"].to_f
                        else
                          shp["qty_stk"] +=  shp["qty_shortage"] 
                          shp["qty_shortage"] = 0
                          outcnt += 1
                          last_lotstks_parts = shpord_create_by_shpsch(shp)   ###　  
                          last_lotstks.concat last_lotstks_parts
                          shpf = false
                          break
                        end
                      end
                    end
                    if shpf 
                      outcnt += 1
                      shortcnt += 1 if shp["qty_shortage"]  > 0
                      last_lotstks_parts = shpord_create_by_shpsch(shp)   ###
                      last_lotstks.concat last_lotstks_parts
                    end
                  else
                    ActiveRecord::Base.connection.select_all(shuffle_sql).each do |stk|
                        shp["qty_stk"] = shp["qty_stk"].to_f + stk["qty_stk"].to_f   ###shp["qty_stk"]  他にある在庫
                    end
                    outcnt += 1
                    shortcnt += 1 if shp["qty_shortage"]  > 0
                    last_lotstks_parts = shpord_create_by_shpsch(shp)   ###
                    last_lotstks.concat last_lotstks_parts
                  end
                else
								  last_lotstks_parts = shpord_create_by_shpsch(shp)   ###prd,purordsによる自動作成 
                  last_lotstks.concat last_lotstks_parts
								  outcnt += 1
                  shortcnt += 1 if shp["qty_shortage"]  > 0
								  if shp["consumauto"] == "A"   ###使用後自動返却
								 		###shpschs,shpordsでは瓶毎、リール毎に出庫してないので、瓶、リールの自動返却はない。
		                shp["duedate"] = (parent["duedate"].to_time + 4*3600).strftime("%Y/%m/%d %H:%M:%S")  ###稼働日　稼働時間
		                shp["depdate"] = (parent["duedate"].to_time  + 1*3600).strftime("%Y/%m/%d %H:%M:%S")
										shp["shelfnos_id_fm"] = shp["shelfnos_id_pare"]
										shp["shelfnos_id_to"] = shp["shelfnos_id_to"]  
										last_lotstks_parts = shpord_create_by_shpsch(shp)   ###
                    last_lotstks.concat last_lotstks_parts
								  end
                end
            end
					end
				end
				
				ord_shpschs.each do |ord|  ###shpschsの減
					shp_sql = %Q&
							select * from shpschs where  paretblname =  '#{ord["ord_tblname"]}'  and paretblid = #{ord["ord_tblid"]}
					&
					ActiveRecord::Base.connection.select_all(shp_sql).each do |nd|
						strsql = %Q&
									update shpschs set qty_sch = 0,qty_case = 0,
											updated_at = current_timestamp,
											remark = '#{self} line:#{__LINE__}'
										where id = #{nd["id"]}
						&
						ActiveRecord::Base.connection.update(strsql)
            last_lotstks << {"tblname" => "shpschs","tblid" => nd["id"],"qty_src" => nd["qty_sch"].to_f * -1}
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
		return outcnt,shortcnt,err,last_lotstks
	end	

	def proc_second_shp params,grid_columns_info
		tmp = []
		err = ""
		pareTblName = "" 
		str_func = %Q&select * from func_get_name('screen','#{params[:screenCode]}','#{params["email"]}')&
		params[:screenName] = ActiveRecord::Base.connection.select_value(str_func)
		if params[:screenName].nil?
			params[:screenName] = params[:screenCode]
		end
		strselect = "("
		(params["clickIndex"]).each do |selected|  ###-次のフェーズに進んでないこと。
			selected = JSON.parse(selected)
			if selected["screenCode"] =~ /prd|pur/ and selected["screenCode"] =~ /ords$|insts$|replyinputs$/
				strselect << selected["id"]+","
				pareTblName = selected["screenCode"].split("_")[1]
			end
		end
		if strselect == "("
			totalCount = 0
		    params[:pageCount] = 0
		    params[:totalCount] = 0
		    params[:parse_linedata] = {}
		    return [],params
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
						paretblid in #{strselect} and qty_shortage = 0 and
						not exists(select 1 from shpinsts inst where
									inst.paretblname = '#{pareTblName}' and	inst.paretblid in #{strselect} and
									inst.itms_id = shp.itms_id and inst.processseq = shp.processseq and 
									inst.lotno = shp.lotno and inst.packno = shp.packno
									)
				&
				shpords = ActiveRecord::Base.connection.select_all(strsql)
				shpords.each do |shpord|
					shpord = ActiveRecord::Base.connection.select_one("select * from r_shpords where id = #{shpord["id"]}")
					blk = RorBlkCtl::BlkClass.new("r_shpords")
					command_c = blk.command_init
					command_c["sio_classname"] = "shpords_delete_"
					shpord.each do |fld,val|
						command_c[fld] = val
					end
					command_c["shpord_qty"] =  0
					command_c["shpord_qty_shortage"] =  0
					command_c["shpord_person_id_upd"] = params["person_id_upd"]
					blk.proc_create_tbldata(command_c) ##
					blk.proc_private_aud_rec({},command_c)
				end
				
			when "foract_shpinsts"
				strsorting = "  order by shpinst_paretblid,id desc "
			when "r_shpacts"
				strsorting = "  order by shpact_paretblid,id desc "
			end
			params[:sortBy] = []
		end
		screenCode = params[:screenCode]
		tblnamechop = screenCode.split("_",2)[1].chop
		pareTblName = params["gantt"]["paretblname"] ###第一画面のテーブル名
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
	def proc_create_shpxxxs(params)  ### shpordsは対象外
		setParams = params.dup
			###自分自身のshpschs を作成   
		###
		#  yield=shpsch --> create
		#  yield=shpord --> 入り出の減
		#  yield=shpinst -->出の減
		#  yield=shpact --> 入りの減
		###
		parent = setParams["parent"]  ###親
		child = setParams["child"]  #
		tblnamechop = yield
		# case yield
		# when "shpest" 
		# 	tblnamechop = "shpsch"
		# when "shpsch" 
		# 	tblnamechop = "shpsch"
		# when "shpord" 
		# 	tblnamechop = "shpsch"  ###新規に作成し入出庫対象の減 child=shp
		# when "shpinst" 
		# 	tblnamechop = "shpord"  ###新規に作成し出庫対象の減 child=shp
		# when "shpact"
		# 	tblnamechop = "shpact" ###新規に作成し入り対象の減 child=shp
		# end
		blk = RorBlkCtl::BlkClass.new("r_#{tblnamechop}s")
		command_c = blk.command_init
		if child["shelfnos_id_to"] != parent["shelfnos_id"]  ###子部品の保管場所!=shelfnos_id_fm親の作業場所
				command_c["sio_classname"] = "shpxxxx_add_"
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
				command_c["#{tblnamechop}_person_id_upd"] = params["person_id_upd"]
				command_c["#{tblnamechop}_paretblname"] = parent["tblname"] 
				command_c["#{tblnamechop}_paretblid"] = parent["tblid"]
				command_c["#{tblnamechop}_prjno_id"] = parent["prjnos_id"]
				command_c["#{tblnamechop}_chrg_id"] = parent["chrgs_id"]
				case yield
				when /shpest/  ### mold 
					case child["consumtype"]
					when "mold","ITool"
						command_c["#{tblnamechop}_shelfno_id_fm"] = child["shelfnos_id_to"] ###自身の保管先から出庫
						command_c["#{tblnamechop}_qty_est"] = qty_src = 1
						###親の作業場所へ納品
						if parent["tblname"] =~ /^pur/
							strsql = %Q&
									select shelf.id from shelfnos shelf
												inner join suppliers supp on shelf.locas_id_shelfno = locas_id_supplier
															and supp.id = #{parent["suppliers_id"]} 	
												where shelf.code = '000'
							&
							command_c["#{tblnamechop}_shelfno_id_to"] = ActiveRecord::Base.connection.select_value(strsql)
						else
							command_c["#{tblnamechop}_shelfno_id_to"] = parent["shelfnos_id"] 
						end
						command_c["#{tblnamechop}_duedate"] = parent["duedate"] 
						command_c["#{tblnamechop}_depdate"] = (parent["starttime"].to_time - 1*24*3600).strftime("%Y-%m-%d %H:%M:%S")
					else
						Rails.logger.debug" class #{self} ,line:#{__LINE__} logic error not support  consumtype:#{child["consumtype"]} "
						raise
					end
				when /shpsch/
					command_c["#{tblnamechop}_shelfno_id_fm"] = child["shelfnos_id_to"] ###自身の保管先から出庫
					command_c["#{tblnamechop}_gno"] = parent["sno"] 
					case child["consumtype"]
					when "CON"
						qty_sch = CtlFields.proc_cal_qty_sch(parent["qty"].to_f,
														child["chilnum"].to_f,child["parenum"].to_f,child["consumunitqty"].to_f,
														child["consumminqty"].to_f,child["consumchgoverqty"].to_f)
						command_c["#{tblnamechop}_duedate"] = command_c["#{tblnamechop}_depdate"] = (parent["starttime"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S")   ###稼働日考慮
					when "mold","ITool"
						qty_sch = 1
						command_c["#{tblnamechop}_duedate"] = parent["duedate"]
						command_c["#{tblnamechop}_depdate"] = (parent["starttime"].to_time - 1*24*3600).strftime("%Y-%m-%d %H:%M:%S")
					else
						Rails.logger.debug"logic error not support  consumtype:#{child["consumtype"]} "
						Rails.logger.debug"error class #{self} , line:#{__LINE__} "
						raise
					end
					command_c["#{tblnamechop}_qty_sch"] = qty_src = qty_sch
					###親の作業場所へ納品
					if parent["tblname"] =~ /^pur/
						strsql = %Q&
									select shelf.id from shelfnos shelf
												inner join suppliers supp on shelf.locas_id_shelfno = locas_id_supplier
															and supp.id = #{parent["suppliers_id"]} 	
												where shelf.code = '000'
						&
						command_c["#{tblnamechop}_shelfno_id_to"] = ActiveRecord::Base.connection.select_value(strsql)
					else
						command_c["#{tblnamechop}_shelfno_id_to"] = parent["shelfnos_id"] 
					end
				when /shpord/   ###	未使用
					command_c["#{tblnamechop}_shelfno_id_fm"] = child["shelfnos_id_fm"] ###自身の保管先から出庫
					command_c["#{tblnamechop}_qty_sch"] = qty_src =  child["qty_sch"].to_f * -1
					command_c["#{tblnamechop}_gno"] = child["gno"]
					command_c["#{tblnamechop}_shelfno_id_to"] = child["shelfnos_id_to"]  
          ### perfotm　実行のため　.to_json日付が"2024-12-17T20:53:26.000Z"になている
					command_c["#{tblnamechop}_duedate"] = child["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S")   ###稼働日考慮
					command_c["#{tblnamechop}_depdate"] = child["depdate"].to_time.strftime("%Y-%m-%d %H:%M:%S")   ###稼働日考慮
				when /shpinst|shpact/
					command_c["#{tblnamechop}_shelfno_id_fm"] = child["shelfnos_id_fm"] ###自身の保管先から出庫
					command_c["#{tblnamechop}_qty"] = qty_src = child["qty"].to_f * -1
					command_c["#{tblnamechop}_gno"] = child["gno"] 
					command_c["#{tblnamechop}_shelfno_id_to"] = child["shelfnos_id_to"]  
					command_c["#{tblnamechop}_duedate"] = child["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S")
					command_c["#{tblnamechop}_depdate"] = child["depdate"].to_time.strftime("%Y-%m-%d %H:%M:%S")
					case child["consumtype"]
					when "CON"
						command_c["#{tblnamechop}_depdate"] = (parent["starttime"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S")   ###稼働日考慮
						command_c["#{tblnamechop}_duedate"] = parent["starttime"].to_time.strftime("%Y-%m-%d %H:%M:%S")
					when "mold","ITool"
						qty_sch = 1
						command_c["#{tblnamechop}_duedate"] = parent["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S")
						command_c["#{tblnamechop}_depdate"] = (parent["starttime"].to_time - 1*24*3600).strftime("%Y-%m-%d %H:%M:%S")
					else
						Rails.logger.debug"logic error not support  consumtype:#{child["consumtype"]} "
						Rails.logger.debug"error class #{self} , line:#{__LINE__} "
						raise
					end
				end
	
				
				command_c["id"] = ArelCtl.proc_get_nextval("#{yield}s_seq")
				command_c["#{tblnamechop}_created_at"] = Time.now
				blk.proc_create_tbldata(command_c) ##
				blk.proc_private_aud_rec(setParams,command_c)
				###
				#  mold,ITollのshpxxxxのlinktbls
				###
        last_lotstks = []
        last_lotstks << {"tblname" => yield + "s" ,"tblid" => command_c["id"],"qty_src" => qty_src }
				return last_lotstks if yield == "shpest"
				last_lotstks_parts = update_mold_IToll_shp_link(blk.proc_tbldata,"add") do
						yield
				end
        last_lotstks.concat last_lotstks_parts
				###
		end ###
					 Rails.logger.debug " calss:#{self},line:#{__LINE__},last_lotstks:#{last_lotstks}"
    return last_lotstks
	end 

	def proc_confirmShpinsts(params)
      begin
            ActiveRecord::Base.connection.begin_db_transaction()
			outcnt = 0
			err = "please select shpords"
      last_lotstks = []
			if params["clickIndex"] 
				params["clickIndex"].each do |selected|  ###-次のフェーズに進んでないこと。
					selected = JSON.parse(selected)
					if selected["screenCode"] == "forInsts_shpords"
						prev_shpord = ActiveRecord::Base.connection.select_one(%Q&select * from r_shpords where id = #{selected["id"]}&)
						prev_shpord["shpord_person_id_upd"] = params["person_id_upd"]
						last_lotstks_parts = nextshp_create_by_prevshp(prev_shpord,"shpords","shpinsts")
						outcnt += 1
						err = ""
            last_lotstks.concat last_lotstks_parts
					end
				end
				if outcnt == 0
				err = " no shpords record"
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
					Rails.logger.debug"  #{self} line:#{__LINE__}"
					selected = JSON.parse(selected)
					if selected["screenCode"] == "foract_shpinsts"
						prev_shpinst = ActiveRecord::Base.connection.select_one(%Q&select * from r_shpinsts where id = #{selected["id"]}&)
						prev_shpinst["shpinst_person_id_upd"] = params["person_id_upd"]
						nextshp_create_by_prevshp(prev_shpinst,"shpinsts","shpacts")
						outcnt += 1
						err = ""
					end
				end
				if outcnt == 0
				err = "  no shpinsts record"
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
		rec = {}
    last_lotstks  = []
		shp.each do |k,val|
			tblchop,field = k.to_s.split("_",2)
			rec[field.sub("_id","s_id")] = val if tblchop == prevshpchop
			next if field =~ /^qty|^sno|^id$|^isudate|masterprice/
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
		command_c["id"] = ArelCtl.proc_get_nextval("#{nextshpchop}s_seq")
		command_c["#{nextshpchop}_created_at"] = Time.now
		blk.proc_create_tbldata(command_c) ##
		blk.proc_private_aud_rec({},command_c)

		last_lotstks << {"tblname" => nextshpchop + "s","tblid" => command_c["id"],"qty_src" => command_c["#{nextshpchop}_qty_stk"] ,
                    "set_f" => true ,"rec" => blk.proc_tbldata}
		###
		#  mold,ITollのshpxxxxのlinktbls
		###
		last_lotstks_parts = update_mold_IToll_shp_link(blk.proc_tbldata,"add") do
			nextshpchop
		end
		###
    last_lotstks.concat << last_lotstks_parts
		
		# stkinout = {}
		# stkinout["tblname"] = nextshp
		# stkinout["tblid"] = command_c["id"]
		# stkinout["expiredate"] = command_c["#{nextshpchop}_expiredate"]
		# stkinout["lotno"] =   command_c["#{nextshpchop}_lotno"] 
		# stkinout["packno"] =  command_c["#{nextshpchop}_packno"] 
		# stkinout["prjnos_id"] = command_c["#{nextshpchop}_prjno_id"]
		# stkinout["itms_id"] = command_c["#{nextshpchop}_itm_id"]
		# stkinout["processseq"] = command_c["#{nextshpchop}_processseq"]
		# stkinout["qty_sch"] = 0
		# stkinout["qty"] =  - command_c["#{nextshpchop}_qty_stk"]
		# stkinout["qty_stk"] = command_c["#{nextshpchop}_qty_stk"]
		# stkinout["qty_real"] = command_c["#{nextshpchop}_qty_real"]
		# stkinout["persons_id_upd"] = command_c["#{nextshpchop}_person_id_upd"]
		# stkinout["remark"] = "  #{self} line:#{__LINE__}"
		# if nextshp == "shpinsts"
		# 	stkinout["shelfnos_id"] = command_c["#{nextshpchop}_shelfno_id_fm"]
		# 	stkinout["starttime"] = command_c["#{nextshpchop}_depdate"]
		# 	###
		# 	#  業者倉庫の時は業者倉庫も更新
		# 	###
		# 	strsql = %Q&
		# 	select trngantts_id from linktbls where tblname ='#{shp["#{prevshpchop}_paretblname"]}' 
		# 										and tblid = #{shp["#{prevshpchop}_paretblid"]}
		# 										and srctblname = tblname and srctblid = tblid 
		# 		&
		# 	stkinout["trngantts_id"] = ActiveRecord::Base.connection.select_value(strsql)
		# 	sql_check_supplier = %Q&
		# 				select s.id from suppliers s  
		# 						inner join shelfnos s2  on s.locas_id_supplier = s2.locas_id_shelfno  
		# 						 where s2.id = #{stkinout["shelfnos_id"]} and s.expiredate > current_date
		# 	&
		# 	suppliers_id = ActiveRecord::Base.connection.select_value(sql_check_supplier)
		# 	if  suppliers_id
		# 		stkinout["srctblnaame"] = "supplierwhs"
		# 		stkinout["suppliers_id"] = suppliers_id
		# 		stkinout = proc_mk_supplierwhs_rec("out",stkinout)
		# 	else
		# 		stkinout["srrtblname"] = "lotstkhists"
		# 		stkinout = proc_lotstkhists_in_out("out",stkinout)
		# 	end
		# 	# parent = {"trngantts_id" => stkinout["trngantts_id"]}  ### shpxxxs,conxxxsのtrngantts_idは親のtrngantts_id
		# 	# setParams = {"mkprdpurords_id" => 0,"parent" => parent,"child" => shpord,"parent" => {"shelfnos_id" => "-1"}}
		# 	# proc_create_shpxxxs(setParams)  do  ###prd,purordsによる自動作成 も含まれる。
		# 	# 	"shpinst"
		# 	# end
		# else  ###shpacts
		# 	stkinout["starttime"] = command_c["#{nextshpchop}_rcptdate"]
		# 	stkinout["shelfnos_id"] =  command_c["#{nextshpchop}_shelfno_id_to"]
		# 	sql_check_supplier = %Q&
		# 			select s.id from suppliers s  
		# 					inner join shelfnos s2  on s.locas_id_supplier = s2.locas_id_shelfno  
		#  					where s2.id = #{stkinout["shelfnos_id"]} and s.expiredate > current_date
		# 		&
		# 	suppliers_id = ActiveRecord::Base.connection.select_value(sql_check_supplier)
		# 	strsql = %Q&
		# 		select trngantts_id from linktbls where tblname ='#{shp["#{prevshpchop}_paretblname"]}' 
		# 											and tblid = #{shp["#{prevshpchop}_paretblid"]}
		# 											and srctblname = tblname and srctblid = tblid 
		# 	&
		# 	stkinout["trngantts_id"] = ActiveRecord::Base.connection.select_value(strsql)
		# 	if  suppliers_id
		# 		stkinout["srctblname"] = "supplierwhs"
		# 		stkinout["suppliers_id"] = stkinout["srctblid"] = suppliers_id
		# 	else	
		# 		stkinout["srctblname"] = "lotstkhists"
		# 	end
		# 	###stkinout = shp_inoutlotstk("in",stkinout)
		#   case stkinout["srctblname"]
		#   when "lotstkhists"
		#  	  stkinout = proc_lotstkhists_in_out("in",stkinout)
		#   when "supplierwhs"
		#  	  stkinout = proc_mk_supplierwhs_rec("in",stkinout)   ###マイナス在庫の入り
		#   end
		# 	# parent = {"trngantts_id" => stkinout["trngantts_id"]}   ### shpxxxs,conxxxsのtrngantts_idは親のtrngantts_id
		# 	# rec["qty"] = rec["qty_stk"]
		# 	# rec["qty_stk"] = 0
		# 	# setParams = {"mkprdpurords_id" => 0,"parent" => parent,"child" => rec,"parent" => {"shelfnos_id" => "-1"}}
		# 	# Rails.logger.debug"  #{self} line:#{__LINE__}"
		# 	# proc_create_shpxxxs(setParams)  do  ###prd,purordsによる自動作成 も含まれる。
		# 	# 	"shpact"
		# 	# end
		# end
					 Rails.logger.debug " calss:#{self},line:#{__LINE__},last_lotstks:#{last_lotstks}"
		return last_lotstks
	end

	def proc_create_consume(params) ## by child item
		###prdschs,purschsの時は自分自身のconschs を作成   
		command_c = {}
		setParams = params.dup
		parent = setParams["parent"] ###親
		child = setParams["child"]  ###対象
		tblnamechop = params["screenCode"].split("_",2)[1].chop
		blk = RorBlkCtl::BlkClass.new("r_#{tblnamechop}s")
		command_c = blk.command_init
		command_c["sio_code"] =  command_c["sio_viewname"] =  params["screenCode"]  ###viewは関係ない
		command_c["sio_message_contents"] = nil
		command_c["sio_recordcount"] = 1
		command_c["sio_result_f"] =   "0"  
		command_c["sio_classname"] = "#{params["screenCode"]}_add_consume"
		command_c["#{tblnamechop}_id"] = "" 
		command_c["#{tblnamechop}_itm_id"] = child["itms_id"]
		command_c["#{tblnamechop}_processseq"] = child["processseq"]
		command_c["#{tblnamechop}_consumauto"] = (child["consumauto"]||="")
		command_c["#{tblnamechop}_isudate"] = Time.now 
		command_c["#{tblnamechop}_packno"] =  ""  
		command_c["#{tblnamechop}_lotno"] = "" 
		case parent["tblname"]
		when /^pur/
			strsql = %Q&
						select s.id from shelfnos s 
									inner join  suppliers supplier on supplier.locas_id_supplier = s.locas_id_shelfno
																	and supplier.id = #{parent["suppliers_id"]}
									where s.code = '000'	
			&
			command_c["#{tblnamechop}_shelfno_id_fm"] =  child["shelfnos_id_fm"] = ActiveRecord::Base.connection.select_value(strsql)
		else
			command_c["#{tblnamechop}_shelfno_id_fm"] =  child["shelfnos_id_fm"] = parent["shelfnos_id"]  ###親の作業場所
		end
		command_c["#{tblnamechop}_gno"] = parent["sno"] 
		command_c["#{tblnamechop}_paretblname"] = parent["tblname"] 
		command_c["#{tblnamechop}_paretblid"] = parent["tblid"]
		command_c["#{tblnamechop}_prjno_id"] = parent["prjnos_id"]
		command_c["#{tblnamechop}_chrg_id"] = parent["chrgs_id"]
    ### perfotm　実行のため　.to_json日付が"2024-12-17T20:53:26.000Z"になている
		command_c["#{tblnamechop}_duedate"] = 	case  parent["tblname"] 
													when /schs$|ords$|insts$/
														parent["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S")
													when /reply/
														parent["replydate"].to_time.strftime("%Y-%m-%d %H:%M:%S")
													when /purdlvs/
														parent["depdate"].to_time.strftime("%Y-%m-%d %H:%M:%S")
													when /puracts/
														parent["rcptdate"].to_time.strftime("%Y-%m-%d %H:%M:%S")
													when /prdacts/
														parent["cmpldate"].to_time.strftime("%Y-%m-%d %H:%M:%S")
													end			
		stkinout = {}
		case parent["tblname"]
		when /schs$/
		# 	prev_contblname = "conschs"
		# 	prev_str_con_qty = "qty_sch"
		 	str_pare_qty = "qty_sch"
		when /ords$/
		# 	prev_contblname = "conschs"
		# 	prev_str_con_qty = "qty_sch"
		 	str_pare_qty = "qty"
		when /acts/
		# 	prev_contblname = "conords"
		# 	prev_str_con_qty = "qty"
		 	str_pare_qty = "qty_stk"
		when /purdlvs/
		# 	prev_contblname = "conords"
		# 	prev_str_con_qty = "qty"
		 	str_pare_qty = "qty_stk"
		else
		# 	prev_contblname = "conords"
		# 	prev_str_con_qty = "qty"
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
		command_c["#{tblnamechop}_#{str_con_qty}"] =  con_qty
		command_c["#{tblnamechop}_person_id_upd"] = setParams["person_id_upd"]
		command_c["#{tblnamechop}_created_at"] = Time.now
		command_c["id"] = ArelCtl.proc_get_nextval("#{tblnamechop}s_seq")
		blk.proc_create_tbldata(command_c) ##
		blk.proc_private_aud_rec(setParams,command_c)
		last_lotstk = {"tblname" =>  tblnamechop + "s" ,"tblid" => command_c["id"] ,"qty_src" => con_qty }	
		# stkinout["shelfnos_id"] = command_c[tblnamechop+"_shelfno_id_fm"]  
		# stkinout["tblname"] = yield
		# stkinout["tblid"] = command_c["id"]
		# stkinout["expiredate"] = command_c[tblnamechop+"_expiredate"]
		# stkinout["lotno"] =   command_c["#{tblnamechop}_lotno"] 
		# stkinout["packno"] =  command_c["#{tblnamechop}_packno"] 
		# stkinout["prjnos_id"] = command_c[tblnamechop+"_prjno_id"]
		# stkinout["itms_id"] = command_c[tblnamechop+"_itm_id"]
		# stkinout["processseq"] = command_c[tblnamechop+"_processseq"]
		# stkinout["persons_id_upd"] = command_c[tblnamechop+"_person_id_upd"]
		# stkinout["remark"] =  "  #{self} line:#{__LINE__}"
		# if  parent["tblname"] =~ /^pur/
		# 	stkinout["srctblname"] = "supplierwhs"
		# 	case  parent["tblname"] 
		# 	when /^purdlvs/
		# 		stkinout["depdate"] = parent["depdate"]
		# 	when /^puracts/  ###purdlvsがあるときはArelCtl.proc_ChildConSqlで対象データを除外済
		# 		stkinout["depdate"] = stkinout["starttime"] = parent["rcptdate"]
		# 	else
		# 		stkinout["depdate"] = stkinout["starttime"] = parent["duedate"]
		# 	end
		# 	strsql = %Q&
		# 			select s.id from suppliers s  
		# 				inner join shelfnos s2  on s.locas_id_supplier = s2.locas_id_shelfno  
		# 				 where s2.id = #{child["shelfnos_id_fm"]} and s.expiredate > current_date
		# 			&
		# 	stkinout["suppliers_id"] = stkinout["srctblid"] = ActiveRecord::Base.connection.select_value(strsql)
		# else
		# 	stkinout["srctblname"] = "lotstkhists"
		# 	if  parent["tblname"] =~ /^prdacts/
		# 		stkinout["starttime"] = parent["cmpldate"]
		# 	else
		# 		stkinout["starttime"] = parent["duedate"]
		# 	end
		# end
		# stkinout["remark"] =  "  #{self} line:#{__LINE__}"
		# if parent["tblname"] =~ /schs$|ords$/
		# 	stkinout["trngantts_id"] = params["parent"]["trngantts_id"]  ### shpxxxs,conxxxsのtrngantts_idは親のtrngantts_id
		# 	stkinout[str_con_qty] = command_c["#{tblnamechop}_#{str_con_qty}"]
		# 	###stkinout = shp_inoutlotstk("out",stkinout)
		#   case stkinout["srctblname"]
		#   when "lotstkhists"
		#  	  stkinout = proc_lotstkhists_in_out("out",stkinout)
		#   when "supplierwhs"
		#  	  stkinout = proc_mk_supplierwhs_rec("out",stkinout)   ###マイナス在庫の入り
		#   end
		# else
		# 	strsql = %Q&
		# 				select trngantts_id,sum(qty_src) qty_src from linktbls where tblname = '#{yield}'
		# 											and	tblid = #{parent["tblid"]} group by trngantts_id
		# 			&
		# 	ActiveRecord::Base.connection.select_all(strsql).each do |link|
		# 		stkinout["trngantts_id"] = link["trngantts_id"]
		# 		skinout[str_con_qty] = CtlFields.proc_cal_qty_sch(parent[str_pare_qty],
		# 										child["chilnum"],child["parenum"],child["consumunitqty"],
		# 										child["consumminqty"],child["consumchgoverqty"])
		# 		###stkinout = shp_inoutlotstk("out",stkinout)
		#     case stkinout["srctblname"]
		#     when "lotstkhists"
		#  	    stkinout = proc_lotstkhists_in_out("out",stkinout)
		#     when "supplierwhs"
		#  	    stkinout = proc_mk_supplierwhs_rec("out",stkinout)   ###マイナス在庫の入り
		#     end
		# 	end
		# end
		####
		###  前の状態のリセット
		####
		# strsql = "select link.* ,alloc.qty_linkto_alloctbl alloc_qty from linktbls link
    #                   inner join alloctbls alloc on link.tblname = alloc.srctblname and  link.tblid = alloc.srctblid
    #                                             and alloc.trngantts_id = link.trngantts_id   
    #                   where tblname = '#{parent["tblname"]}' 
		# 										and tblid = #{parent["tblid"]}
		# 										and srctblname like '#{parent["tblname"][0..2]}%'
		# 										and qty_src > 0 and srctblname != tblname and qty_linkto_alloctbl > 0"
		# ActiveRecord::Base.connection.select_all(strsql).each do |link|
    #   strsql = %Q&
    #               select * from #{link["srctblname"].sub(/prd|pur/,"con")} 
    #                             where #{link["srctblname"]}_id_#{link["srctblname"].sub(/prd|pur/,"con")}.chop = #{link["srctblid"]}
    #                             and itms_id = #{blk.proc_tbldata["itms_id"]} and processseq = #{blk.proc_tbldata["processseq"]}
    #   &
		#   prev_con = ActiveRecord::Base.connection.select_one(strsql)
    #   str_qty = case link["srctblname"]
    #             when /schs/
    #               "qty_sch"
    #             when  /ords|insts|reply/
    #               "qty"
    #             when /acts|dlvs/
    #               "qty_stk"
    #             else
    #               raise
    #             end
    #   redude_prev_con_qty = prev_con[str_qty].to_f - (prev_con[str_qty].to_f *  (link["alloc_qty"] / link["qty_src"].to_f)) 
    #   prev_tblnamechop = link["srctblname"].sub(/prd|pur/,"con").chop
    #   prev = RorBlkCtl::BlkClass.new("r_#{prev_tblname}s")
		#   command_prev = prev.command_init
		#   command_prev["sio_code"] =  command_prev["sio_viewname"] =  "r_#{prev_tblnamechop}s"
		#   command_prev["sio_message_contents"] = nil
		#   command_prev["sio_recordcount"] = 1
		#   command_prev["sio_result_f"] =   "0"  
		#   command_prev["sio_classname"] = "r_#{prev_tblnamechop}s_update_"
		#   command_prev["id"] = prev_con["id"] 
    #   prev_con.each do |field,val|
    #     command_prev["#{prev_tblnamechop}_#{field.sub("s_id","_id")}"] = val
    #   end
    #   prev.proc_create_tbldata(command_prev) ##
    #   prev.proc_private_aud_rec(setParams,command_c)
    #   last_lotstks << {"tblname" => prev_tblnamechop + "s","tblid" => prev_con["id"],qty_src =>  -(prev_con[str_qty].to_f *  (link["alloc_qty"] / link["qty_src"].to_f))}

			# stkinout["trngantts_id"] = link["trngantts_id"]
			# case link["srctblname"]
			# when /schs$/
			# 	str_con_qty = "qty_sch"
			# 	prev_contbl ="conschs" 
			# when /ords$/
			# 	str_con_qty = "qty"
			# 	prev_contbl ="conords" 
			# when /acts$|purdlvs$/
			# 	str_con_qty = "qty_stk"
			# 	prev_contbl ="conacts" 
			# else
			# 	Rails.logger.debug"logic error not support  table:#{link["srctblname"]} "
			# 	Rails.logger.debug"error class:#{self} , line:#{__LINE__} "
			# 	raise
			# end
			# strsql = %Q&
			# 		select prev.#{str_con_qty} #{str_con_qty},alloc.qty_linkto_alloctbl alloc_qty,alloc.trngantts_id,prev.id 
			# 					from #{prev_contbl} prev 
			# 					inner join (select alloc.* from #{link["srctblname"]} prd 
			# 									inner join alloctbls alloc on prd.id = alloc.srctblid and alloc.srctblname = '#{link["srctblname"]}') alloc
			# 							 					on alloc.srctblid = prev.paretblid and alloc.srctblname = prev.paretblname
			# 					where prev.paretblid = #{link["srctblid"]} and prev.#{str_con_qty} > 0
			# 					and prev.itms_id = #{stkinout["itms_id"]} and prev.processseq = #{stkinout["processseq"]}
			# 			& 
			# prev_consume = ActiveRecord::Base.connection.select_one(strsql)
			# bal_qty =  prev_consume[str_con_qty].to_f * link["qty_src"].to_f / prev_consume[str_con_qty].to_f
			# strsql = %Q&
			# 				update #{prev_contbl} set 	#{str_con_qty} = #{bal_qty}	where id = #{prev_consume["id"]} 
			# 			&
			# ActiveRecord::Base.connection.update(strsql)
			# # strsql = %Q&
			# #  			select * from inoutlotstks  where tblname = '#{prev_contbl}' and tblid = #{prev_consume["id"]} 
			# #  											and trngantts_id = #{prev_consume["trngantts_id"]}
			# #  		& 
			# # prev_inout = ActiveRecord::Base.connection.select_one(strsql)
			# stkinout["qty_sch"] = stkinout["qty"] = stkinout["qty_stk"] = 0
			# stkinout[str_con_qty] = prev_consume[str_con_qty].to_f - bal_qty
			# stkinout["remark"] =  "  #{self} line:#{__LINE__}"
			# ###shp_inoutlotstk("in",stkinout)
      # case stkinout["srctblname"]
		  #   when "lotstkhists"
		 	#     stkinout = proc_lotstkhists_in_out("in",stkinout)
		  #   when "supplierwhs"
		 	#     stkinout = proc_mk_supplierwhs_rec("in",stkinout)   ###マイナス在庫の入り
		  # end
		###end
    return last_lotstk
	end	

  
	def proc_update_consume(tblname,tbldata,last_rec,decrease) ##   tblname-->paretblname decrease
		####
		###  decrease :true 消費の取り消し ,:false 消費の復活     all chiid items by parent 
		#### 
    last_lotstks = []
    str_qty = case tblname
              when /schs/
                "qty_sch"
              when  /ords|insts|reply/
                "qty"
              when /acts|dlvs/
                "qty_stk"
              else
                raise
              end
    conTblname = tblname.sub(/prd|pur/,"con")
    strsql = %Q&
                select * from #{conTblname} con 
                          where con.paretblid =  #{tbldata["id"]} and paretblname = '#{tblname}' and #{str_qty} > 0
    &
    ActiveRecord::Base.connection.select_all(strsql).each do |consume|
		  # consume["duedate"] = 	case  tblname 
			# 										when /schs$|ords$|insts$/
			# 											tbldata["duedate"]
			# 										when /reply/
			# 											tbldata["replydate"]
			# 										when /puracts/
			# 											tbldata["rcptdate"]
			# 										when /prdacts/
			# 											tbldata["cmpldate"]
			# 										end			
      if decrease 
        new_con_qty = - consume[str_qty].to_f + consume[str_qty].to_f * (tbldata[str_qty].to_f / last_rec[str_qty].to_f)
        if new_con_qty >= 0
          last_lotstks << {"tblname" => conTblname,"tblid" => consume["id"],"qty_src" =>  new_con_qty -  consume[str_qty].to_f ,
                          "set_f" => true,"rec" => consume}
        else
          new_con_qty = 0
          last_lotstks << {"tblname" => conTblname,"tblid" => consume["id"],"qty_src" => - consume[str_qty].to_f ,
                          "set_f" => true,"rec" => consume}
        end
      else 
        ndsql = %Q%
                    select itms_id_nditm itms_id,processseq_nditm processseq,chilnum,parenum,consumunitqty,consumminqty,consumchgoverqty
                               from nditms nd 
                               where nd.opeitms_id = #{tbldata["opeitms_id"]}  ---親
                               and nd.itms_id_nditm = #{consume["itms_id"]}  and nd.processseq_nditm = #{consume["processseq"]}
                       %
        nd = ActiveRecord::Base.connection.select_one(ndsql)
        new_con_qty = CtlField.proc_cal_qty_sch(tbldata[str_qty],
                                 nd["chilnum"],nd["parenum"],
                                 nd["consumunitqty"],nd["consumminqty"],nd["consumchgoverqty"])
        last_lotstks << {"tblname" => conTblname,"tblid" => consume["id"],"qty_src" =>  new_con_qty - consume[str_qty].to_f,
                          "set_f" => true,"rec" => consume}
      end
      prev = RorBlkCtl::BlkClass.new("r_#{conTblname}")
		  command_prev = prev.command_init
      consume.each do |field,val|
        command_prev[conTblname.chop+ "_" +field.sub("s_id","_id")] = val
      end
      command_prev[conTblname.chop+"_"+str_qty] = new_con_qty
      command_prev[conTblname.chop+"_person_id_upd"] = tbldata["persons_id_upd"]
		  command_prev["sio_classname"] = "r_#{conTblname}_update_"
		  command_prev["sio_code"] =  command_prev["sio_viewname"] =  "r_#{conTblname}"
		  command_prev["sio_message_contents"] = nil
		  command_prev["sio_recordcount"] = 1
		  command_prev["sio_result_f"] =   "0"  
		  command_prev["id"] =   consume["id"]  
      prev.proc_create_tbldata(command_prev) ##
      prev.proc_private_aud_rec({},command_prev)
    end
      ####
      ###  前の状態の消費復活
      ####
    #   strsql = "select link.* ,alloc.qty_linkto_alloctbl alloc_qty from linktbls link
    #                     inner join alloctbls alloc on link.srctblname = alloc.srctblname and  link.srctblid = alloc.srctblid
    #                                               and alloc.trngantts_id = link.trngantts_id   
    #                     where link.tblname = '#{parent["tblname"]}'  and tblid = #{parent["tblid"]}
    #                       and srctblname like '#{parent["tblname"][0..2]}%'
    #                       and qty_src > 0 and srctblname != tblname and qty_linkto_alloctbl > 0"
    #   ActiveRecord::Base.connection.select_all(strsql).each do |link|
    #     prev_str_qty = case link["srctblname"]
    #               when /schs/
    #                 "qty_sch"
    #               when  /ords|insts|reply/
    #                 "qty"
    #               when /acts|dlvs/
    #                 "qty_stk"
    #               else
    #                 raise
    #               end
    #     setParams = params.dup
    #     ndsql = %Q%
    #                 select itms_id_nditm itms_id,processseq_nditm processseq,chilnum,parenum,consumunitqty,consumminqty,consumchgoverqty
    #                       from nditms nd 
    #                       where nd.opeitms_id = #{params["tbldata"]["opeitms_id"]}  ---親
    #                       and nd.itms_id_nditm = #{prev.proc_tbldata["itms_id"]}  and nd.processseq_nditm = #{prev.proc_tbldata["processseq"]}
    #               %
    #     nd = ActiveRecord::Base.connection.select_one(ndsql)
    #     prev_tblnamechop = link["srctblname"].sub(/prd|pur/,"con").chop
    #     prev = RorBlkCtl::BlkClass.new("r_#{prev_tblname}s")
    #     command_prev = prev.command_init
    #     command_prev["sio_code"] =  command_prev["sio_viewname"] =  "r_#{prev_tblnamechop}s"
    #     command_prev["sio_message_contents"] = nil
    #     command_prev["sio_recordcount"] = 1
    #     command_prev["sio_result_f"] =   "0"  
    #     command_prev["sio_classname"] = "r_#{prev_tblnamechop}s_update_"
    #     command_prev["id"] = prev_con["id"] 
    #     prev_con.each do |field,val|
    #       command_prev["#{prev_tblnamechop}_#{field}"] = val
    #     end
    #     command_prev["#{prev_tblnamechop}_#{str_qty}"]  = CtlField.proc_cal_qty_sch(params["tbldata"][str_qty],
    #                         nd["chilnum"],nd["parenum"],
    #                         nd["consumunitqty"],nd["consumminqty"],nd["consumchgoverqty"])
    #     prev.proc_create_tbldata(command_prev) ##
    #     prev.proc_private_aud_rec(setParams,command_c)
    #     last_lotstks << {"tblname" => prev_tblnamechop + "s","tblid" => prev_con["id"],"qty_src" => command_prev["#{prev_tblnamechop}_#{str_qty}"] }
    #   end
    #   ###
    #   # 消費再作成
    #   ###
    #   if params["tbldata"][str_qty].to_f > 0
    #     setParams["parent"] = params["tbldata"]
    #     setParams["child"] = nd
    #     last_lotstks_parts = proc_create_consume(setParams) do
    #       conTblname
    #     end
    #     last_lotstks.concat last_lotstks_parts
    #   end
		# end
					 Rails.logger.debug " calss:#{self},line:#{__LINE__},last_lotstks:#{last_lotstks}"
    return last_lotstks
	end	
	
	###shpschs用
	def update_shpschs_ords_by_parent params,last_pare_qty  
		###自分自身のshpschs を作成   
		command_c = {}
    last_lotstks = []
		setParams = params.dup
		parent = setParams["tbldata"]
		shp = setParams["shp"]  ###出庫対象

		tblnamechop = yield.chop
		###stkinout = {"srctblname" => "lotstkhists"}

		###ActiveRecord::Base.connection.begin_db_transaction()
			blk = RorBlkCtl::BlkClass.new("r_#{tblnamechop}s")
			command_c = blk.command_init
			command_c["sio_classname"] = "#{yield}_update_"
			command_c["#{tblnamechop}_id"] = command_c["id"] = shp["id"] 
			command_c["#{tblnamechop}_isudate"] = Time.now
			###自身の保管先から出庫
			###stkinout["shelfnos_id"] = command_c["#{tblnamechop}_shelfno_id_fm"] = shp["shelfnos_id_fm"] 
			command_c["#{tblnamechop}_shelfno_id_to"] = shp["shelfnos_id_to"]  ###親の作業場所へ納品
			command_c["#{tblnamechop}_duedate"] = shp["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S") 
			###stkinout["starttime"] = command_c["#{tblnamechop}_depdate"] = shp["depdate"]
			command_c["#{tblnamechop}_transport_id"] = 0 
			command_c["#{tblnamechop}_paretblname"] = shp["paretblname"] 
			command_c["#{tblnamechop}_paretblid"] = shp["paretblid"]
			command_c["#{tblnamechop}_price"] = shp["price"].to_f 
			case tblnamechop
			when /shpsch/
				qty_sch = shp["qty_sch"].to_f / last_pare_qty * parent["qty"].to_f 
				qty_src = command_c["#{tblnamechop}_qty_sch"] = qty_sch
				###stkinout["qty"] = stkinout["qty_stk"] =  stkinout["qty_real"] = 0 
				command_c["#{tblnamechop}_amt_sch"] = shp["qty_sch"].to_f * command_c["#{tblnamechop}_price"]
			when /shpord/
				qty = shp["qty"].to_f / last_pare_qty * parent["qty"].to_f
				qty_src = command_c["#{tblnamechop}_qty"] =  qty
				###stkinout["qty_stk"] = stkinout["qty_sch"] =  stkinout["qty_real"] = 0
				command_c["#{tblnamechop}_amt"] = shp["qty"].to_f * command_c["#{tblnamechop}_price"]
			end
			
			command_c["#{tblnamechop}_created_at"] = Time.now
			blk.proc_create_tbldata(command_c) ##
			setParams = blk.proc_private_aud_rec(setParams,command_c)
      last_lotstks = {"tblname" => tblnamechop + "s","tblid" => command_c["id"],"qty_src" => qty_src ,
                      "set_f" => true ,"rec" => blk.proc_tbldata}
			###
			#  mold,ITollのshpxxxxのlinktbls
			###
			last_lotstks_parts = update_mold_IToll_shp_link(blk.proc_tbldata,"update") do
				tblnamechop
			end
			###
      last_lotstks.concat last_lotstks_parts

			# stkinout["tblname"] = yield
			# stkinout["tblid"] = command_c["id"]
			# stkinout["trngantts_id"] = params["gantt"]["trngantts_id"]
			# stkinout["persons_id_upd"] = params["person_id_upd"]
			# stkinout["remark"] =  "  #{self} line:#{__LINE__}"
			# Rails.logger.debug" class #{self} ,line:#{__LINE__} ,stkinout,#{stkinout}"
			# case tblnamechop
			# when "shpsch"
			# 	stkinout["qty_sch"] = qty_sch - shp["qty_sch"].to_f
			# 	###shp_inoutlotstk("out",stkinout)
		  #   case stkinout["srctblname"]
		  #     when "lotstkhists"
		 	#       stkinout = proc_lotstkhists_in_out("out",stkinout)
		  #     when "supplierwhs"
		 	#       stkinout = proc_mk_supplierwhs_rec("out",stkinout)   ###マイナス在庫の入り
		  #   end
			# 	stkinout["starttime"] = command_c[tblnamechop+"_duedate"]
			# 	stkinout["shelfnos_id"] = command_c[tblnamechop+"_shelfno_id_to"]   ###入り
			# 	###shp_inoutlotstk("in",stkinout)
		  #   case stkinout["srctblname"]
		  #   when "lotstkhists"
		 	#     stkinout = proc_lotstkhists_in_out("in",stkinout)
		  #   when "supplierwhs"
		 	#     stkinout = proc_mk_supplierwhs_rec("in",stkinout)   ###マイナス在庫の入り
		  #   end
			# when "shpord"
			# 	stkinout["qty"] = qty - shp["qty"].to_f
			# 	###shp_inoutlotstk("out",stkinout)
		  #   case stkinout["srctblname"]
		  #   when "lotstkhists"
		 	#     stkinout = proc_lotstkhists_in_out("out",stkinout)
		  #   when "supplierwhs"
		 	#     stkinout = proc_mk_supplierwhs_rec("out",stkinout)   ###マイナス在庫の入り
		  #   end
			# 	stkinout["starttime"] = command_c[tblnamechop+"_duedate"]
			# 	stkinout["shelfnos_id"] = command_c[tblnamechop+"_shelfno_id_to"]
			# 	##shp_inoutlotstk("in",stkinout)
		  #   case stkinout["srctblname"]
		  #   when "lotstkhists"
		 	#     stkinout = proc_lotstkhists_in_out("in",stkinout)
		  #   when "supplierwhs"
		 	#     stkinout = proc_mk_supplierwhs_rec("in",stkinout)   ###マイナス在庫の入り
		  #   end
			# end

			# ###
			# #  業者倉庫の時は業者倉庫も更新
			# ###
			# sql_check_supplier = %Q&
			# 		select s.id from suppliers s  
			# 			inner join shelfnos s2  on s.locas_id_supplier = s2.locas_id_shelfno  
			# 			 where s2.id = #{shp["shelfnos_id_fm"]} and s.expiredate > current_date
			# 	&
			# suppliers_id = ActiveRecord::Base.connection.select_value(sql_check_supplier)
			# if  suppliers_id
			# 	stkinout["srctblname"] = "supplierwhs"
			# 	stkinout["suppliers_id"] = stkinout["srctblid"] = suppliers_id
			# 	stkinout["shelfnos_id"] = shp["shelfnos_id_fm"] 
			# 	stkinout["starttime"] = shp["depdate"]
			# 	stkinout["remark"] =  "  #{self} line:#{__LINE__}"
			# 	###shp_inoutlotstk("in",stkinout)
		 	#   stkinout = proc_lotstkhists_in_out("in",stkinout)
			# end
			# sql_check_supplier = %Q&
			# 	select s.id from suppliers s  
			# 		inner join shelfnos s2  on s.locas_id_supplier = s2.locas_id_shelfno  
			# 		 where s2.id = #{shp["shelfnos_id_to"]} and s.expiredate > current_date
			# 	&
			# suppliers_id = ActiveRecord::Base.connection.select_value(sql_check_supplier)
			# if  suppliers_id
			# 	stkinout["srctblname"] = "supplierwhs"
			# 	stkinout["suppliers_id"] = stkinout["srctblid"] = suppliers_id
			# 	stkinout["remark"] = "  #{self} line:#{__LINE__}"
			# 	stkinout["starttime"] = command_c[tblnamechop+"_duedate"]
			# 	stkinout["shelfnos_id"] = command_c[tblnamechop+"_shelfno_id_to"]
			# 	###shp_inoutlotstk("in",stkinout)
      #   stkinout = proc_mk_supplierwhs_rec("in",stkinout)   ###マイナス在庫の入り
			# end	
		####
					 Rails.logger.debug " calss:#{self},line:#{__LINE__},last_lotstks:#{last_lotstks}"
    return last_lotstks
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
		stkinout["qty_sch"] = stkinout["qty_sch"].to_f * plusminus  
		stkinout["qty"] = stkinout["qty"].to_f * plusminus  
		stkinout["qty_stk"] = stkinout["qty_stk"].to_f * plusminus  
		stkinout["qty_real"] = stkinout["qty_real"].to_f * plusminus 
		##ActiveRecord::Base.connection.execute("lock table lotstkhists in  SHARE ROW EXCLUSIVE mode")
		###ActiveRecord::Base.connection.select_one("select * from itms where id = #{stkinout["itms_id"]} for update")
		strsql = %Q% select *	from lotstkhists
								where   itms_id = #{stkinout["itms_id"]} and  
										shelfnos_id = #{stkinout["shelfnos_id"]} and 
										processseq = #{stkinout["processseq"]} and
										prjnos_id = #{stkinout["prjnos_id"]} and
										starttime = to_timestamp('#{stkinout["starttime"]}','yyyy-mm-dd hh24:mi:ss') and 
										packno = '#{stkinout["packno"]}' and  lotno = '#{stkinout["lotno"]}'
										for update
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
									order by starttime desc limit 1 for update
					%
			last_lotstk =  ActiveRecord::Base.connection.select_one(last_strsql)
			if last_lotstk.nil?
				last_lotstk = {"qty_sch" =>0,"qty" => 0,"qty_stk" => 0,"qty_real" => 0,"packno" => "","lotno" => ""}
			end
			new_stkinout = stkinout.dup	
			new_stkinout["qty_sch"] = stkinout["qty_sch"] + last_lotstk["qty_sch"].to_f 
			new_stkinout["qty"]     = stkinout["qty"] + last_lotstk["qty"].to_f
			new_stkinout["qty_stk"] = stkinout["qty_stk"] +  last_lotstk["qty_stk"].to_f
			new_stkinout["qty_real"] = stkinout["qty_real"] +  last_lotstk["qty_real"].to_f
			new_stkinout["lotstkhists_id"] = stkinout["lotstkhists_id"] = stkinout["srctblid"] = ArelCtl.proc_get_nextval("lotstkhists_seq") 
			ActiveRecord::Base.connection.insert(insert_lotstkhists_sql(new_stkinout)) 
			###
		else
			stkinout["lotstkhists_id"] =  stkinout["srctblid"] = lotstkhists["id"]
			###
			new_stkinout["qty_sch"] = stkinout["qty_sch"] + lotstkhists["qty_sch"].to_f
			new_stkinout["qty"]     = stkinout["qty"]+ lotstkhists["qty"].to_f
			new_stkinout["qty_stk"] = stkinout["qty_stk"] +  lotstkhists["qty_stk"].to_f
			new_stkinout["qty_real"] = stkinout["qty_real"] +  lotstkhists["qty_real"].to_f
			strsql = %Q& update lotstkhists set  
									updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
									persons_id_upd = #{new_stkinout["persons_id_upd"]||=0},
									qty_stk = #{new_stkinout["qty_stk"]},
									qty_real = #{new_stkinout["qty_real"]},
									qty = #{new_stkinout["qty"]} ,
									qty_sch = #{new_stkinout["qty_sch"].to_f}  
									where id = #{lotstkhists["id"]}
						&
			ActiveRecord::Base.connection.update(strsql)
		end
		# stkinout["srctblname"] = "lotstkhists"
		# proc_check_inoutlotstk(stkinout)
		###
		###未来の推定在庫を変更する。
		###
		strsql = %Q& select *
								from lotstkhists
								where   itms_id = #{stkinout["itms_id"]} and  
										shelfnos_id = #{stkinout["shelfnos_id"]} and 
										processseq = #{stkinout["processseq"]} and
										prjnos_id = #{stkinout["prjnos_id"]} and
										starttime > to_timestamp('#{stkinout["starttime"]}','yyyy-mm-dd hh24:mi:ss') and 
										packno = '#{stkinout["packno"]}' and  lotno = '#{stkinout["lotno"]}'
										order by starttime for update
				&
		ActiveRecord::Base.connection.select_all(strsql).each do |futrec|
			strsql = %Q& update lotstkhists set  
									updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
									persons_id_upd = #{new_stkinout["persons_id_upd"]||=0},
									qty_stk = #{stkinout["qty_stk"].to_f * plusminus + futrec["qty_stk"].to_f},
									qty = #{stkinout["qty"].to_f * plusminus + futrec["qty"].to_f},
									qty_sch = #{stkinout["qty_sch"].to_f  * plusminus + futrec["qty_sch"].to_f} 
									where id = #{futrec["id"]}					
						&
			ActiveRecord::Base.connection.update(strsql) 
		end
		return stkinout
	end

	def check_inoutlotstk(stkinout)   ###
		# strsql = %Q&
		# 	select   * from inoutlotstks  
		# 				where 	 tblid = #{stkinout["tblid"]} and tblname = '#{stkinout["tblname"]}'
		# 				and trngantts_id = #{stkinout["trngantts_id"]}
		# &
		# inoutlotstk = ActiveRecord::Base.connection.select_one(strsql)
		# if inoutlotstk
		# 		stkinout["remark"] = "  #{self} line:#{__LINE__}"
		# 		update_sql = %Q&
		# 			update inoutlotstks set qty_sch = #{stkinout["qty_sch"]},
		# 								qty = #{stkinout["qty"]},
		# 								qty_stk =  #{stkinout["qty_stk"]},
		# 								updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
		# 								remark = '#{stkinout["remark"]}'||remark
		# 				where id = #{inoutlotstk["id"]}				 
		# 		& 
		# 		ActiveRecord::Base.connection.update(update_sql)
		# else
		# 		stkinout["remark"] = "  #{self} line:#{__LINE__}" + (stkinout["remark"]||="") 
		# 		proc_insert_inoutlotstk_sql(stkinout)
		# end
	end

	def shp_inoutlotstk(inout,stkinout)   ##
		# case stkinout["srctblname"]
		# when "lotstkhists"
		# 	stkinout = proc_lotstkhists_in_out(inout,stkinout)
		# when "supplierwhs"
		# 	stkinout = proc_mk_supplierwhs_rec(inout,stkinout)   ###マイナス在庫の入り
		# end
		# ###
		# #   qty_sch,qty,qty_stkはproc_lotstkhists_in_outで調整済
		# ###
		# strsql = %Q&
		# 	select   * from inoutlotstks  
		# 				where 	 tblid = #{stkinout["tblid"]} and tblname = '#{stkinout["tblname"]}'
		# 				and trngantts_id = #{stkinout["trngantts_id"]}
		# &
		# inoutlotstk = ActiveRecord::Base.connection.select_one(strsql)
		# stk = stkinout.dup
		# stk["qty_sch"]  = stkinout["qty_sch"] 
		# stk["qty"]  = stkinout["qty"] 
		# stk["qty_stk"]  = stkinout["qty_stk"]
		# if inoutlotstk
		# 		stk["remark"] = "  #{self} line:#{__LINE__}"
		# 		update_sql = %Q&
		# 			update inoutlotstks set qty_sch = #{stk["qty_sch"]},
		# 								qty =  #{stk["qty"]},
		# 								qty_stk =  #{stk["qty_stk"]},
		# 								updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
		# 								remark = '#{stk["remark"]}'||remark
		# 				where id = #{inoutlotstk["id"]}				 
		# 		& 
		# 		ActiveRecord::Base.connection.update(update_sql)
		# else
		# 		stk["remark"] = "  #{self} line:#{__LINE__}," + (stkinout["remark"]||="") 
		# 		proc_insert_inoutlotstk_sql(stk)
		# end
		# return stkinout
	end

	def proc_alloc_change_inoutlotstk(stkinout)  ###  alloctbls,linktblsは更新済
		###
		#  現在のinout
		###
		###
		# lotstkhists は　proc_lotstkhists_in_outで対応済
		###
		# strlink = case stkinout["tblname"]
		# 			when /cust/
		# 				"linkcusts"
		# 			else
		# 				"linktbls"
		# 			end
		# strsql = %Q&
		# 			select link.qty_src,link.srctblname tblname,link.srctblid tblid,alloc.qty_linkto_alloctbl ,alloc.trngantts_id,
		# 					alloc.srctblname alloctblname
		# 					from alloctbls alloc 
		# 					left join  #{strlink} link on alloc.trngantts_id = link.trngantts_id  
		# 							and alloc.srctblname = link.tblname and alloc.srctblid = link.tblid 
		# 					where 	alloc.srctblid = #{stkinout["tblid"]} and alloc.srctblname = '#{stkinout["tblname"]}'
		# 	&
		# ActiveRecord::Base.connection.select_all(strsql).each do |inoutlotstk|
		# 	case inoutlotstk["alloctblname"]
		# 	when /schs$/
		# 		stkinout["qty_sch"] = inoutlotstk["qty_linkto_alloctbl"]
		# 		stkinout["qty"] = 0
		# 		stkinout["qty_stk"] = 0
		# 	when /ords$|insts$|replyinput/
		# 		stkinout["qty"]  = inoutlotstk["qty_linkto_alloctbl"]
		# 		stkinout["qty_sch"] = 0
		# 		stkinout["qty_stk"] = 0
		# 	when /dlvs$|acts$/
		# 		stkinout["qty_stk"] = inoutlotstk["qty_linkto_alloctbl"]
		# 		stkinout["qty"] = 0
		# 		stkinout["qty_sch"] = 0
		# 	end
		# 	stkinout["trngantts_id"] = inoutlotstk["trngantts_id"]
		# 	stkinout["remark"] = "#{self} line:#{__LINE__}," + (stkinout["remark"]||="") 
		# 	check_inoutlotstk(stkinout)
		# end
		# ###
		# # 前の状態のinout
		# ###
		# strsql = %Q&
		# 	select link.qty_src,link.srctblname tblname,link.srctblid tblid,alloc.qty_linkto_alloctbl ,alloc.trngantts_id
		# 				from alloctbls alloc 
		# 				inner join  #{strlink} link on alloc.trngantts_id = link.trngantts_id  
		# 							and alloc.srctblname = link.tblname and alloc.srctblid = link.tblid 
		# 				where 	alloc.srctblid = #{stkinout["tblid"]} and alloc.srctblname = '#{stkinout["tblname"]}'
		# 				and (link.srctblname != link.tblname or link.srctblid != link.tblid) 
		# &
		# ActiveRecord::Base.connection.select_all(strsql).each do |inoutlotstk|
		# 	case inoutlotstk["tblname"]
		# 	when /schs$/
		# 		qty_sch = inoutlotstk["qty_linkto_alloctbl"].to_f
		# 		qty = 0
		# 		qty_stk = 0
		# 	when /ords$|insts$|replyinput/
		# 		qty  = inoutlotstk["qty_linkto_alloctbl"].to_f
		# 		qty_sch = 0
		# 		qty_stk = 0
		# 	when /dlvs$|acts$/
		# 		qty_stk = inoutlotstk["qty_linkto_alloctbl"].to_f
		# 		qty = 0
		# 		qty_sch = 0
		# 	end
		# 	strsql = %Q&
		# 			select * from inoutlotstks 
		# 				where tblname = '#{inoutlotstk["tblname"]}' and tblid = #{inoutlotstk["tblid"]}
		# 				and trngantts_id = #{inoutlotstk["trngantts_id"]} 				 
		# 		& 
		# 	prev = ActiveRecord::Base.connection.select_one(strsql)
		# 	update_sql = %Q&
		# 			update inoutlotstks set qty_sch = #{qty_sch},
		# 								qty = #{qty},
		# 								qty_stk =  #{qty_stk},
		# 								updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
		# 								remark = '#{stkinout["remark"]}'||remark
		# 				where id = #{prev["id"]}	----srctblid lotstkhists_id,・・・S			 
		# 		& 
		# 	ActiveRecord::Base.connection.update(update_sql)
		# end 
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
								' ',#{stkinout["persons_id_upd"]},'2099/12/31','#{stkinout["remark"]}')
		&
	end

	def proc_insert_inoutlotstk_sql(stkinout)
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
								 '#{stkinout["srctblname"]}',#{stkinout["srctblid"]},
								 #{stkinout["qty_sch"]} ,
								 #{stkinout["qty_stk"]},
								 #{stkinout["qty"]},
								 to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
								 to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
								 ' ',#{stkinout["persons_id_upd"]},'2099/12/31','#{stkinout["remark"]}')
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
		stkinout["qty_sch"] = stkinout["qty_sch"].to_f * plusminus
		stkinout["qty"] = stkinout["qty"].to_f * plusminus
		stkinout["qty_stk"] = stkinout["qty_stk"].to_f * plusminus
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
								' ',#{stkinout["persons_id_upd"]},'2099/12/31','#{stkinout["remark"]}')
				&
			ActiveRecord::Base.connection.insert(strsql)
		else
			custwhs_id = rec["id"]
			update_sql = %Q% update custwhs set 
									updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
									qty_sch = qty_sch + #{stkinout["qty_sch"]},
									qty = qty + #{stkinout["qty"]},
									qty_stk = qty_stk + #{stkinout["qty_stk"]},
									remark = '#{stkinout["remark"] }'
									where id = #{custwhs_id} 
				%
			ActiveRecord::Base.connection.update(update_sql) 
		end
		stkinout["srctblid"] =  stkinout["custwhs_id"] =  custwhs_id
		stkinout["srctblname"] =   "custwhs"

		return stkinout
	end

	def proc_mk_supplierwhs_rec inout,stkinout  ###lotstkhistsは棚のみ

		if inout == "in"
			plusminus = 1
		else
			plusminus = -1
		end
		stkinout["qty_sch"] = stkinout["qty_sch"].to_f * plusminus
		stkinout["qty"] = stkinout["qty"].to_f * plusminus
		stkinout["qty_stk"] = stkinout["qty_stk"].to_f * plusminus
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
								#{stkinout["qty_sch"]},
								#{stkinout["qty"]},
								#{stkinout["qty_stk"]},
								'#{stkinout["lotno"]}',#{stkinout["itms_id"]},#{stkinout["processseq"]},
								to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
								to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
								' ',#{stkinout["persons_id_upd"]},'2099/12/31','')
				&
			ActiveRecord::Base.connection.insert(strsql)
		else
			update_sql = %Q% update supplierwhs set 
									updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
									qty_sch = qty_sch + #{stkinout["qty_sch"]},
									qty = qty + #{stkinout["qty"]},
									qty_stk = qty_stk + #{stkinout["qty_stk"]}
									where id = #{rec["id"]} 
				%
			ActiveRecord::Base.connection.update(update_sql) 
			supplierwhs_id = rec["id"]
		end
		stkinout["srctblid"] = stkinout["suppliers_id"] =  supplierwhs_id
		stkinout["srctblname"] =   "suppliers"
		return stkinout
	end

	def shpord_create_by_shpsch(shp)  ###
		###自分自身のshpschs を作成   
    last_lotstks = []
		blk = RorBlkCtl::BlkClass.new("r_shpords")
		command_c = blk.command_init
		command_c["sio_classname"] = "shpords_add_"
		command_c["shpord_id"] = "" 
		command_c["shpord_isudate"] = Time.now
		command_c["shpord_shelfno_id_to"] = shp["shelfnos_id_to"] ##
		command_c["shpord_shelfno_id_fm"] = shp["shelfnos_id_fm"]  ###
		command_c["shpord_duedate"] = shp["duedate"]
		command_c["shpord_depdate"] = shp["depdate"]
    ###
    #  transports_id not support yet
    #
		command_c["shpord_transport_id"] = 0
    ###
		command_c["shpord_paretblname"] = shp["paretblname"] 
		command_c["shpord_paretblid"] = shp["paretblid"]
		command_c["shpord_itm_id"] = shp["itms_id"]   ### from shpords
		command_c["shpord_processseq"] = shp["processseq"]
		command_c["shpord_prjno_id"] = shp["prjnos_id"]
		command_c["shpord_chrg_id"] = shp["chrgs_id_trn"]
		command_c["shpord_person_id_upd"] = shp["persons_id_upd"]

		if shp["paretblname"] =~ /^pur/   ###tblname= 'feepayment'--->有償支給
			command_c = CtlFields.proc_judge_check_supplierprice(command_c,"",0,"r_shpords")
		else
			command_c["shpord_crr_id"] = 0
			command_c["shpord_price"] = 0
			command_c["shpord_tax"] = 
			command_c["shpord_taxrate"] = 0
			command_c["shpord_masterprice"] = 0
		end		
		command_c["shpord_qty_case"] =  shp["qty_case"]
		command_c["shpord_tax"] = 0   ###CtlFieldsから求める。
		command_c["shpord_sno"] = "" 	

		command_c["shpord_qty"] = shp["qty"]
		command_c["shpord_qty_shortage"] = shp["qty_shortage"].to_f  
		command_c["shpord_qty_case"] =  if shp["packqty"].to_f == 0 
												1
											else
												(shp["qty"].to_f / shp["packqty"].to_f).ceil

											end
		command_c["shpord_amt"] = command_c["shpord_qty"] * command_c["shpord_price"].to_f  ###CtlFieldsから求める。
		command_c["shpord_packno"] = shp["packno"]  
		command_c["shpord_lotno"] = shp["lotno"]
		
		command_c["id"] = ArelCtl.proc_get_nextval("shpords_seq")
		command_c["shpord_created_at"] = Time.now
		blk.proc_create_tbldata(command_c) ##
		blk.proc_private_aud_rec({},command_c)
    
		last_lotstks << {"tblname" => "shpords","tblid" => command_c["id"],"qty_src" => command_c["shpord_qty"] ,
                    "set_f" => true ,"rec" => blk.proc_tbldata}
		###
		#  mold,ITollのshpxxxxのlinktbls
		###
		last_lotstks_parts = update_mold_IToll_shp_link(blk.proc_tbldata,"add") do
			"shpord"
		end
    last_lotstks.concat last_lotstks_parts
		###
		
		# stkinout = {}
		# stkinout["tblname"] = "shpords"
		# stkinout["tblid"] = command_c["id"]
		# stkinout["trngantts_id"] = shp["trngantts_id"]  ###親tableのtrngannts_id
		# stkinout["expiredate"] = command_c["shpord_expiredate"]
		# stkinout["lotno"] =   command_c["shpord_lotno"] 
		# stkinout["packno"] =  command_c["shpord_packno"] 
		# stkinout["prjnos_id"] = command_c["shpord_prjno_id"]
		# stkinout["itms_id"] = command_c["shpord_itm_id"]
		# stkinout["processseq"] = command_c["shpord_processseq"]
		# stkinout["starttime"] = command_c["shpord_depdate"]
		# stkinout["qty_sch"] = 0
		# stkinout["qty"] =  command_c["shpord_qty"]
		# stkinout["qty_stk"] = stkinout["qty_real"] = 0
		# stkinout["persons_id_upd"] = command_c["shpord_person_id_upd"]
		# stkinout["remark"] = "  #{self} line:#{__LINE__}"
		# ###
		# #  業者倉庫の時は業者倉庫も更新
		# ###
		# sql_check_supplier = %Q&
		# 			select s.id from suppliers s  
		# 					inner join shelfnos s2  on s.locas_id_supplier = s2.locas_id_shelfno  
		#  					where s2.id = #{shp["shelfnos_id_fm"]} and s.expiredate > current_date
		# 	&
		# suppliers_id = ActiveRecord::Base.connection.select_value(sql_check_supplier)
		# if  suppliers_id
		# 	stkinout["srctblname"] = "supplierwhs"
		# 	stkinout["suppliers_id"] = stkinout["srctblid"] = suppliers_id
		# else
		# 	stkinout["shelfnos_id"] = command_c["shpord_shelfno_id_fm"]
		# 	stkinout["persons_id_upd"] = command_c["shpord_person_id_upd"]
		# 	stkinout["srctblname"] = "lotstkhists"
		# end
		# ##stkinout = shp_inoutlotstk("out",stkinout)
		# case stkinout["srctblname"]
		# when "lotstkhists"
		#  	stkinout = proc_lotstkhists_in_out("out",stkinout)
		# when "supplierwhs"
		#  	stkinout = proc_mk_supplierwhs_rec("out",stkinout)   ###マイナス在庫の入り
		# end
		# sql_check_supplier = %Q&
		# 			select s.id from suppliers s  
		# 					inner join shelfnos s2  on s.locas_id_supplier = s2.locas_id_shelfno  
		#  					where s2.id = #{shp["shelfnos_id_to"]} and s.expiredate > current_date
		# 		&
		# suppliers_id = ActiveRecord::Base.connection.select_value(sql_check_supplier)
		# if  suppliers_id
		# 	stkinout["srctblname"] = "supplierwhs"
		# 	stkinout["suppliers_id"] = stkinout["srctblid"] = suppliers_id
		# else
		# 	stkinout["starttime"] = command_c["shpord_duedate"]
		# 	stkinout["shelfnos_id"] =  command_c["shpord_shelfno_id_to"]
		# end
		# ###stkinout = shp_inoutlotstk("in",stkinout)
		# case stkinout["srctblname"]
		# when "lotstkhists"
		#  	stkinout = proc_lotstkhists_in_out("in",stkinout)
		# when "supplierwhs"
		#  	stkinout = proc_mk_supplierwhs_rec("in",stkinout)   ###マイナス在庫の入り
		# end
					 Rails.logger.debug " calss:#{self},line:#{__LINE__},last_lotstks:#{last_lotstks}"
    return last_lotstks
	end	

	def update_mold_IToll_shp_link(shp,aud)  ###金型の出荷はtrnganttsに含む
    last_lotstks = []
		case yield
		when "shpest"
			if aud == "add"
				return
			else
			end
		when "shpsch"
			prevshp = "shpests"
			currshp = "shpschs"
		when "shpord"
			prevshp = "shpschs"
			currshp = "shpords"
		when "shpinst"
			prevshp = "shpords"
			currshp = "shpinsts"
		when "shpact"
			prevshp = "shpinsts"
			currshp = "shpacts"
		else
			return
		end

		case  yield 
		when /shpsch|shpord/
			strsql = %Q&
					select l.* from #{currshp} s  
								inner join (select i.id itms_id ,c.code from itms i
												inner join classlists c on c.id = i.classlists_id ) ic
								on s.itms_id = ic.itms_id
								inner join linktbls l on l.tblid = s.paretblid and l.tblname = s.paretblname
								where ic.code in('mold','IToll') and s.id = #{shp["id"]} 
								and (l.srctblname != l.tblname or l.srctblid != l.tblid) 
			&
			ActiveRecord::Base.connection.select_all(strsql).each do |link|
				strsql = %Q&
					select shplink.* from linktbls shplink
							inner join #{prevshp} prevshp
							on shplink.tblname = '#{prevshp}' and shplink.tblid = prevshp.id 
							where	  prevshp.paretblname = '#{link["srctblname"]}'  and prevshp.paretblid = #{link["srctblid"]}) shp
					&
				ActiveRecord::Base.connection.select_all(strsql).each do |shplink|
					link_update_sql = %Q&
							update linktbls set qty_src = 0 ,remark = '#{self} #{__LINE__} #{Time.now}'||remark 
								where    id = #{shplink["id"]}
					& 
					ActiveRecord::Base.connection.update(link_update_sql)
          alloc = {trngantts_id => shplink["trngantts_id"] ,srctblname => shplink["srctblname"],srctblid => shplink["srctblname"],
                  "qty_linkto_alloctbl" => 0,
                  "remark" => "#{self} line #{__LINE__} #{Time.now}"}
          alloctbl_id,last_lotstk = ArelCtl.proc_aud_alloctbls(alloc,"update")
          last_lotstks << last_lotstk
          3.times{Rails.logger.debug" class:#{self} , line:#{__LINE__} ,error last_lotstk:#{last_lotstk}"} if  last_lotstk.nil? or last_lotstk["tblname"].nil? or last_lotstk["tblname"] == ""

					src = {"tblname" => prevshp,"tblid" => shplink["tblid"],"trngantts_id" => shplink["trngantts_id"]}
					base = {"tblname" =>currshp,"tblid" => shp["id"],"qty_src" => 1,"amt_src" => 0,
						"remark" => "#{self} line #{__LINE__}", 
						"persons_id_upd" => setParams["person_id_upd"]}
					alloc = {"srctblname" => currshp,"srctblid" => shp["id"],"trngantts_id" => shplink["trngantts_id"],
						"qty_linkto_alloctbl" => 1,
						"remark" => "#{self} line #{__LINE__} #{Time.now}","persons_id_upd" => shp["persons_id_upd"],
						"allocfree" => 	"alloc"}
					linktbl_id = ArelCtl.proc_insert_linktbls(src,base)
					alloctbl_id,last_lotstk = ArelCtl.proc_aud_alloctbls(alloc,nil)
          last_lotstks << last_lotstk
				end
			end 
		when /shpinst|shpact/  ###paretblname,paretblidはshpordsから引き継ぐ
			strsql = %Q&
					select l.* from #{prevshp} s  
								inner join (select i.id itms_id ,c.code from itms i
													inner join classlists c on c.id = i.classlists_id ) ic
								on s.itms_id = ic.itms_id
								inner join linktbls l on l.tblid = s.id and l.tblname = '#{prevshp}'  ---linktbks shpxxx
								where ic.code in('mold','IToll') and s.paretblid = #{shp["paretblid"]}
								and (l.srctblname != l.tblname or l.srctblid != l.tblid) 
			&
			ActiveRecord::Base.connection.select_all(strsql).each do |shplink|
				link_update_sql = %Q&
						update linktbls set qty_src = 0 ,remark = '#{self} #{__LINE__} #{Time.now}'||remark 
							where    id = #{shplink["id"]}
				& 
				ActiveRecord::Base.connection.update(link_update_sql)
        alloc = {trngantts_id => shplink["trngantts_id"] ,srctblname => shplink["tblname"],srctblid => shplink["tblname"],
                "qty_linkto_alloctbl" => 0, "remark" => "#{self} line #{__LINE__} #{Time.now}"}
        alloctbl_id,last_lotstk = ArelCtl.proc_aud_alloctbls(alloc,"update")
        last_lotstks << last_lotstk
        3.times{Rails.logger.debug" class:#{self} , line:#{__LINE__} ,error last_lotstk:#{last_lotstk}"} if  last_lotstk.nil? or last_lotstk["tblname"].nil? or last_lotstk["tblname"] == ""


				src = {"tblname" => prevshp,"tblid" => shplink["tblid"],"trngantts_id" => shplink["trngantts_id"]}
				base = {"tblname" =>currshp,"tblid" => shp["id"],"qty_src" => 1,"amt_src" => 0,
					      "remark" => "#{self} line #{__LINE__}"}
				alloc = {"srctblname" => currshp,"srctblid" => shp["id"],"trngantts_id" => shplink["trngantts_id"],
					"qty_linkto_alloctbl" => 1,
					"remark" => "#{self} line #{__LINE__} #{Time.now}","persons_id_upd" => shp["persons_id_upd"],
					"allocfree" => 	"alloc"}
				alloctbl_id,last_lotstk = ArelCtl.proc_aud_alloctbls(alloc,nil)
        last_lotstks << last_lotstk
				linktbl_id = ArelCtl.proc_insert_linktbls(src,base)
			end
		end
					 Rails.logger.debug " calss:#{self},line:#{__LINE__},last_lotstks:#{last_lotstks}"
    return last_lotstks
	end 
end
