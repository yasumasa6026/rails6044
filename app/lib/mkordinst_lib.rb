# -*- coding: utf-8 -*-
# mkordlib
# 2099/12/31を修正する時は　2100/01/01の修正も
module MkordinstLib
	extend self
	###mkordparams-->schsからordsを作成した結果
	def proc_mkprdpurords params,mkordparams  ###xxxschsからxxxordsを作成する。 trngantts:xxxschs= 1:1
		### mkprdpurordsではxno_xxxschはセットしない。schsをまとめたり分割したりする機能のため
		setParams = params.dup
		tbldata = params["tbldata"].dup  ###tbldata -->テーブル項目　　viewではない。
		mkprdpurords_id = params["mkprdpurords_id"]   
		seqno = params["seqno"].dup   
		add_tbl = "" 
		add_tbl_org = ""   ###topから必要数を計算するときの必要数抽出用
		add_tbl_pare = ""    ###topから必要数を計算するときの必要数抽出用
		add_tbl_trn = ""
		strwhere = {"org"=>"","pare"=>"","trn"=>""} 
		tblxxx = ""
		incnt = inqty = outcnt = outqty = outamt = 0		 
		command_c = nil
		["org","pare","trn"].each do |sel|  ###抽出条件のsql作成
			case sel
				when "org"
					next if tbldata["orgtblname"] == "" or tbldata["orgtblname"].nil? or tbldata["orgtblname"] == "dummy"
					tblxxx = tbldata["orgtblname"]		
					add_tbl_org = %Q%	inner join  #{tblxxx} org  on  gantt.orgtblid = org.id 	
										inner join  itms itm_org  on  gantt.itms_id_org = itm_org.id 
										inner join  shelfnos  shelfno_org  on  gantt.shelfnos_id_org = shelfno_org.id 	 
										inner join  (select loca.*,s.id shelfno_id from locas loca
																	inner join shelfnos s on s.locas_id_shelfno = loca.id )
												loca_org  on  gantt.shelfnos_id_pare = loca_org.shelfno_id
										inner join  r_chrgs person_org  on  gantt.chrgs_id_org = person_org.id 	%   
					add_tbl << add_tbl_org
					strwhere[sel] << "and orgtblname = '#{tblxxx}'     "
				when "pare"
				 	next if tbldata["paretblname"] == "" or tbldata["paretblname"].nil? or tbldata["paretblname"] == "dummy"
					 tblxxx = tbldata["paretblname"]
				 	case tbldata["paretblname"]  
				 	when /schs$/		
						add_tbl_pare = %Q%	inner join  #{tblxxx} pare  on  gantt.paretblid = pare.id 	
										inner join  itms itm_pare  on  gantt.itms_id_pare = itm_pare.id 
										inner join  shelfnos shelfno_pare  on  gantt.shelfnos_id_pare = shelfno_pare.id 
										inner join  (select loca.*,s.id shelfno_id from locas loca
																	inner join shelfnos s on s.locas_id_shelfno = loca.id )
												loca_pare  on  gantt.shelfnos_id_pare = loca_pare.shelfno_id 	
										inner join  r_chrgs person_pare  on  gantt.chrgs_id_pare = person_pare.id 	%   
						add_tbl << add_tbl_pare
					when /ords$/
						add_tbl_pare = %Q$ inner join (select link.srctblid from linktbls link
															inner join #{tblxxx} p   	
																on p.id = link.tblid and link.tblname = '#{tblxxx}' and  link.srctblname like '%schs') sch
												on gantt.paretblid = sch.srctblid 
											inner join  r_chrgs person_pare  on  gantt.chrgs_id_pare = person_pare.id 	
											inner join  itms itm_pare  on  gantt.itm_id_pare = itm_pare.id 
											inner join  shelfnos shelfno_pare  on gantt.shelfnos_id_pare = loca_pare.id 
											inner join  (select loca.*,s.id shelfno_id from locas loca
																		inner join shelfnos s on s.locas_id_shelfno = loca.id )
													loca_pare  on  gantt.shelfnos_id_pare = loca_pare.shelfno_id $   
				###	else
				###		next
					end	
					strwhere[sel] << "and paretblname = '#{tblxxx}'    "

				when "trn"   ###必須項目	
					add_tbl_trn = %Q%	inner join  itms itm_trn  on  gantt.itms_id_trn = itm_trn.id 
									inner join  shelfnos shelfno_trn  on  gantt.shelfnos_id_trn = shelfno_trn.id 	
									inner join  r_chrgs person_trn  on  gantt.chrgs_id_trn = person_trn.id 	
									inner join  (select loca.*,s.id shelfno_id from locas loca
																inner join shelfnos s on s.locas_id_shelfno = loca.id )
											loca_trn  on  gantt.shelfnos_id_trn = loca_trn.shelfno_id %   
					case tbldata["tblname"] 
					when 	"all"	  ###pur,prd両方抽出
						strwhere[sel] << " and gantt.tblname in ('purschs','prdschs')      "
						add_tbl_trn << " left join  prdschs prd  on  gantt.tblid = prd.id "
						add_tbl_trn << " left join purschs pur  on  gantt.tblid = pur.id "
					when "prdords"		
						strwhere[sel] << "and  gantt.tblname = 'prdschs'      "
						add_tbl_trn << " inner join  prdschs prd  on  gantt.tblid = prd.id "
					when "purords"
						strwhere[sel] << "and  gantt.tblname = 'purschs'      "
						add_tbl_trn << " inner join  purschs pur  on  gantt.tblid = pur.id "
					end
					add_tbl << add_tbl_trn
				else
					next	
			end

			tbldata.each do |field_delm,val|  ###field-->r_purxxxs,r_prdxxxsのfield  delm-->org,pare,trn
				next if field_delm =~ /_id/ ###画面から入力された項目のみが対象
				next if val == "" or val.nil? or val == "dummy"
				if field_delm.to_s =~ /_#{sel}/  ###sel:[org,pare,trn]のどれか
					field = field_delm.sub(/_#{sel}/,"")
					tag = field_delm.split("_")[0] + "_" + sel  ###field.split("_")[0]  --> [itm,loca,person,sno]のどれか
					case  field
					when /itm_code|loca_code/  ###itms
						strwhere[sel] << %Q% and #{tag}.code  = '#{val}' 
							%
					when /person_code_chrg/  ###r_chrgs
						strwhere[sel] << %Q% and #{tag}.person_code_chrg  = '#{val}'  
							%
					when /processseq/  ###
						if val > "0"
						    strwhere[sel] << %Q% and gantt.processseq_#{sel} = '#{val}'   
								%
						end		
					when /duedate/						
						strwhere[sel] << %Q% and gantt.#{field}_#{sel} <= cast('#{val}' as date)  
								%
					when /starttime/						
						strwhere[sel] << %Q% and gantt.#{field}_#{sel} >= cast('#{val}' as date)   
								%
					when /sno/			###snoが	
						case sel
						when /org|pare/	
							strwhere[sel] << %Q% and #{sel}.sno = '#{val}'   %
						when /trn/
							case tbldata["tblname"] 
							when 	"all"	  ###pur,prd両方抽出
								strwhere[sel] << %Q% and (prd.sno = '#{val}'  or pur.sno = '#{val}' ) %
							when "prdords"		
								strwhere[sel] << %Q% and prd.sno = '#{val}'   %
							when "purords"
								strwhere[sel] << %Q% and pur.sno = '#{val}'   %
							end
						end
					else
						### itms.name not support
						### p"MkordinstLib line #{__LINE__} field:#{field_delm} not support"
					end
				end	  ### case
			end  ###fields.each
		end   ### ["_org","_pare","_trn"].each do |tbl|

		###ordsは prjnos_id,itms_id,processseq,locas_id(作業場所、発注先),shelfnos_id_to(完成後、受入後)の保管場所毎に作成
		###対象データの特定 trnganttsにmkprdpurords_idをセット
		ActiveRecord::Base.connection.execute("lock table trngantts in  SHARE ROW EXCLUSIVE mode")
		ActiveRecord::Base.connection.update(set_mkprdpurords_id_in_trngantts_strsql(add_tbl,strwhere,mkprdpurords_id))
		###上記対象データの中で期間がある品目の選定opeitm.optfixoterm　　期間ごとにxxxordsを分ける。
		ActiveRecord::Base.connection.insert(mkord_term(mkprdpurords_id))
		### topの親を設定 
		ActiveRecord::Base.connection.insert(init_sum_ord_qty_strsql(mkprdpurords_id))  ###  mkordtmpfs  親子関係あり
		###ActiveRecord::Base.connection.insert(init_ordorg_strsql(mkprdpurords_id))       ### mkordorgs 親のみ
		###員数に従って必要数を計算
		strsql = %Q&
				select max(trn.mlevel) mlevel,trn.itms_id_trn itms_id_trn ,trn.processseq_trn  processseq_trn,trn.prjnos_id,
					trn.shelfnos_id_trn shelfnos_id_trn,trn.shelfnos_id_to_trn shelfnos_id_to_trn,
					trn.mkprdpurords_id_trngantt mkprdpurords_id,#{params["person_id_upd"]} persons_id_upd
				 	from trngantts	trn
					where trn.mkprdpurords_id_trngantt = #{mkprdpurords_id}
					and (trn.qty_sch > 0 or trn.qty > 0)
					group by trn.mkprdpurords_id_trngantt,trn.prjnos_id,
							trn.itms_id_pare,trn.processseq_pare,trn.shelfnos_id_pare,trn.shelfnos_id_to_pare,
							trn.itms_id_trn,trn.processseq_trn,trn.shelfnos_id_trn,trn.shelfnos_id_to_trn
					---having max(trn.mlevel) > 1
					order by max(trn.mlevel),trn.itms_id_trn,trn.processseq_trn,trn.prjnos_id,
							trn.shelfnos_id_trn,trn.shelfnos_id_to_trn,
							trn.mkprdpurords_id_trngantt
				&
			###opeitm.packqtyに対応
		handovers = ActiveRecord::Base.connection.select_all(strsql)
		handovers.each do |handover|
			ActiveRecord::Base.connection.insert(sum_ord_qty_strsql(handover)) ###schs.qtyから親毎の部品必要数を計算する。
		end	
		handovers.each do |handover|
			ActiveRecord::Base.connection.select_all(get_ordqty(handover)).each do |cal_rec|  ###
			    sum_sql = %Q&
                    select trunc(sum(qty_require)/ max(packqty) + 0.99999) * max(packqty) qty_handover	from mkordtmpfs 
                where  itms_id_trn = #{cal_rec["itms_id_trn"]} and processseq_trn = #{cal_rec["processseq_trn"]}
                and shelfnos_id_trn = #{cal_rec["shelfnos_id_trn"]} and shelfnos_id_to_trn = #{cal_rec["shelfnos_id_to_trn"]}
                          and mkprdpurords_id = #{cal_rec["mkprdpurords_id"]}    and prjnos_id = #{cal_rec["prjnos_id"]}
              &
          qty_handover = ActiveRecord::Base.connection.select_value(sum_sql)
			    strsql = %Q&
		                update 	mkordtmpfs set  qty_require =  #{cal_rec["qty_require"]},
						                        qty_handover =  #{qty_handover}
								where  itms_id_trn = #{cal_rec["itms_id_trn"]} and processseq_trn = #{cal_rec["processseq_trn"]}
                          and shelfnos_id_trn = #{cal_rec["shelfnos_id_trn"]} and shelfnos_id_to_trn = #{cal_rec["shelfnos_id_to_trn"]}
                                    and mkprdpurords_id = #{cal_rec["mkprdpurords_id"]}    and prjnos_id = #{cal_rec["prjnos_id"]}
					&
			    ActiveRecord::Base.connection.update(strsql)
			    strsql = %Q&
		                update 	mkordtmpfs set  qty_require =  #{cal_rec["qty_require"]},
						                        qty_handover =  #{qty_handover}
								where  itms_id_pare = #{cal_rec["itms_id_trn"]} and processseq_pare = #{cal_rec["processseq_trn"]}
								and shelfnos_id_pare = #{cal_rec["shelfnos_id_trn"]} and shelfnos_id_to_pare = #{cal_rec["shelfnos_id_to_trn"]}
			                    and mkprdpurords_id = #{cal_rec["mkprdpurords_id"]}    and prjnos_id = #{cal_rec["prjnos_id"]}
					&
			    ActiveRecord::Base.connection.update(strsql)
			end						
		end
		fields_opeitm = {}
		env = ActiveRecord::Base.configurations["#{ENV["RAILS_ENV"]}"]["database"]
		field_check_sql = %Q& select column_name from information_schema.columns
						where 	table_catalog='#{env}' 
						and 	table_name = 'r_prdords'  and column_name like 'opeitm_%' &
		fields_opeitm["prdord"] = ActiveRecord::Base.connection.select_values(field_check_sql)
		field_check_sql = %Q& select column_name from information_schema.columns
						where 	table_catalog='#{env}' 
						and 	table_name = 'r_purords'  and column_name like 'opeitm_%' &
		fields_opeitm["purord"] = ActiveRecord::Base.connection.select_values(field_check_sql)	
    last_lotstks = []
		ActiveRecord::Base.connection.select_all(req_ord_sql(mkprdpurords_id)).each do |sumSchs|  ### xxxordsの元schs
					line_data = {}
					incnt = sumSchs["incnt"].to_f
					inqty = sumSchs["qty_require"].to_f
					sumSchs["persons_id_upd"] = params["person_id_upd"]
					### freeの確認
					sumSchs,last_lotstks_parts = sch_trn_alloc_to_freetrn(sumSchs)  ###schsをfreeのordsに引き当てる。shselfnosごとに引き当てている。
          last_lotstks.concat last_lotstks_parts
					# ###
					if sumSchs["qty_require"] > 0   ###sumSchs["qty_require"].to_f free　qty引当済
						qty_handover = ((sumSchs["qty_require"].to_f + sumSchs["consumchgoverqty"].to_f) / sumSchs["packqty"].to_f).ceil  * sumSchs["packqty"].to_f
						if sumSchs["consumminqty"].to_f > qty_handover
							qty_handover =  sumSchs["consumminqty"].to_f
						end
						tblord = sumSchs["tblname"].sub("schs","ord")
						case tbldata["tblname"] ###抽出対象は発注or作業指示？
						when "prdords"		
							next if tblord == "purord"
						when "purords"
							next if tblord == "prdord"
						end
						if strwhere["pare"].size > 1  ###親で指定された子部品のみ選択
							next if ActiveRecord::Base.connection.select_value(select_schs_from_mkprdpurords_by_pare(add_tbl_pare,strwhere,handover)).nil?
						else
							if strwhere["trn"].size > 1 
								next if ActiveRecord::Base.connection.select_value(select_schs_from_mkprdpurords_by_trn(add_tbl_trn,strwhere,sumSchs)).nil?
							end
						end
						schRec = ActiveRecord::Base.connection.select_one(%Q& select * from #{sumSchs["tblname"]} where id = #{sumSchs["tblid"]}&)
						blk =  RorBlkCtl::BlkClass.new("r_#{tblord}s")
						command_c = blk.command_init
						symqty = tblord + "_qty"
						command_c[symqty] = qty_handover
						command_c["sio_classname"] = "_add_ord_by_mkordinst"
						command_c["sio_viewname"] = "r_#{tblord}s"
						opeitm = {}
						schRec.each do |key,val|   ###schRec:xxxschs
							case key
							when "id","qty_sch","price","masterprice","tax","taxrate"
								next
							when  /sno|cno/  ###sno,cnoはschから引き継がない。
								command_c["#{tblord}_#{key}"] = ""
							when /amt_sch/  ##ordにはamt_schはない。
								next
							when /opeitms_id/
								opeitm = ActiveRecord::Base.connection.select_one("select itm.taxflg,o.* from opeitms o 
																					inner join itms itm on o.itms_id = itm.id
																						where o.id = #{val}")
								command_c["#{tblord}_#{key.sub("s_id","_id")}"] = val
								opeitm.each do |opekey,value|
									next if opekey.to_s =~ /_upd|_at/
									next if opekey == "id"
									###postgresql のみ
									if fields_opeitm[tblord].find{|n| n == %Q%opeitm_#{opekey.sub("s_id","_id")}%}				
                                		command_c["opeitm_#{opekey.sub("s_id","_id")}"] = value
									end
								end
								line_data[:itm_taxflg] = opeitm["taxflg"]	
							# if opeitm["packqty"].to_f != 0
							# 	command_c["#{tblord}_qty_case"] = command_c[symqty]  / opeitm["packqty"].to_f
							# else
							# 	command_c["#{tblord}_qty_case"] = 0
							# end
							when /duedate|starttime/
								command_c["#{tblord}_#{key}"] = sumSchs[key].strftime("%Y-%m-%d %H:%M:%S")
							when /isudate/
								command_c["#{tblord}_#{key}"] = Time.now
							else	 ###xxxschsとxxxordsと項目は同一が原則　　payments_id_purord
								sym = "#{tblord}_#{key.sub("s_id","_id")}"
								command_c[sym] = line_data[sym.to_sym]  = val
							end
						end
						if tblord == "purord"  ###購入
							###command_c["#{tblord}_amt"] = schRec["price"].to_f * command_c[symqty]
							line_data[:purord_duedate] =  command_c["#{tblord}_duedate"]
							line_data[:purord_supplier_id]  = schRec["suppliers_id"]
							line_data[:purord_isudate] = command_c["#{tblord}_isuedate"]
							line_data,err = CtlFields.proc_judge_check_taxrate(line_data,"purord_taxrate",0,"r_purords")
							3.times{Rails.logger.debug" #{self} ,LINE:#{__LINE__}  #{line_data}"}
							# strsql = %Q&
							# 		select locas_id_shelfno from shelfnos where id = #{schRec["shelfnos_id"]}
							# 	&
							# command_c["shelfno_loca_id_shelfno"] = line_data[:shelfno_loca_id_shelfno] = ActiveRecord::Base.connection.select_value(strsql)
							strsql = %Q&
									select * from suppliers where id = #{schRec["suppliers_id"]}
								&
							supplier = ActiveRecord::Base.connection.select_one(strsql)
							###line_data[:supplier_contractprice] = command_c["supplier_contractprice"] = supplier["contractprice"]
							line_data[:supplier_amtround] = command_c["supplier_amtround"] = supplier["amtround"]
							line_data[:purord_opeitm_id] = command_c["purord_opeitm_id"] = schRec["opeitms_id"]							
							line_data[:purord_qty] = command_c[symqty]
							line_data,err = CtlFields.proc_judge_check_supplierprice(line_data,"purord_price",0,"r_purords")
							command_c["purord_price"] = line_data[:purord_price]
							command_c["purord_masterprice"] = line_data[:purord_masterprice] 
							command_c["purord_amt"] = line_data[:purord_amt]  
							command_c["purord_tax"] = line_data[:purord_tax]  
							command_c["purord_taxrate"] = line_data[:purord_taxrate]  
							command_c["purord_contractprice"] = line_data[:purord_contractprice] 
						end
						command_c["#{tblord}_gno"] = "" ### 
						command_c["#{tblord}_remark"] = "create by mkord" ### 
						command_c["#{tblord}_id"] = command_c["id"] = ArelCtl.proc_get_nextval("#{tblord}s_seq")
						command_c["sio_classname"] = "_add_proc_mkprdpurord_"
						setParams = {}  ###mkprdpurordsをリセット
            setParams["screenCode"] = "r_#{tblord}s"
						setParams["seqno"] = seqno.dup
						setParams["mkprdpurords_id"] = mkprdpurords_id 
            setParams["person_id_upd"] = params["person_id_upd"] 
						###
						###  xxxords作成
						###
						command_c["#{tblord}_person_id_upd"] = setParams["person_id_upd"] = params["person_id_upd"]
						command_c["#{tblord}_created_at"] = Time.now
						blk.proc_create_tbldata(command_c)
						setParams = blk.proc_private_aud_rec(setParams,command_c)
						stkinout = {"tblname"=> tblord + "s" ,"tblid" => command_c["id"],
							"itms_id"=>sumSchs["itms_id"],"processseq" => sumSchs["processseq"],
							"prjnos_id" => sumSchs["prjnos_id"],"starttime" => command_c["#{tblord}_duedate"] ,
							"shelfnos_id" => command_c["#{tblord}_shelfno_id_to"],"trngantts_id" => setParams["gantt"]["trngantts_id"],
							"persons_id_upd" => setParams["person_id_upd"],
							"qty_sch" => 0,"qty" => command_c[symqty] ,"qty_stk" => 0,
							"lotno" => "","packno" => "","qty_src" => command_c[symqty].to_f , "amt_src"=> 0}
            last_lotstks  << {"tblname"=> tblord + "s" ,"tblid" => command_c["id"],"qty_src" => command_c[symqty]}
						outcnt += 1
						outqty +=  command_c[symqty].to_f
						gantt = setParams["gantt"].dup
						free_qty = command_c[symqty].to_f
            ###
            #
            ###
						ActiveRecord::Base.connection.select_all(sch_trn_strsql(sumSchs)).each do |sch_trn|   ###trngantts.qty_schの変更
							if stkinout["qty_src"] > 0   
								stkinout["qty_src"] = free_qty  
                save_sch_qty = sch_trn["qty_linkto_alloctbl"]
								stkinout["remark"] = " #{self} line:(#{__LINE__}) "
                last_lotstks_parts = ArelCtl.proc_add_linktbls_update_alloctbls(sch_trn,stkinout)  ###
                last_lotstks.concat last_lotstks_parts 
								###Shipment.proc_alloc_change_inoutlotstk(stkinout) ### xxxordsの在庫明細変更
                ###schsの消費の取り消し
                prev = {"id" => sch_trn["tblid"],"qty_src" => save_sch_qty}
                new_prev = {"id" => sch_trn["tblid"],"qty_src" => last_lotstks_parts[0]["qty_src"],"persons_id_upd" => params["person_id_upd"]}
                last_lotstks_parts = Shipment.proc_update_consume(sch_trn["tblname"],new_prev,prev,true)  ###:true 消費の取り消し
                last_lotstks.concat last_lotstks_parts
							else
								break
							end
						end
						# ord = ActiveRecord::Base.connection.select_one("select * from #{sumSchs["tblname"]} where id = #{sumSchs["tblid"]}")
						# if ord["remark"] =~ /create by mkord/ or sumSchs["qty_stk"].to_f <= 0
						# 	###子部品を持たないfree ordsに引きあった時 
					else
						qty_handover = 0
					end 
		end
		mkordparams[:incnt] = incnt
		mkordparams[:inqty] = inqty
		mkordparams[:outcnt] = outcnt
		mkordparams[:outqty] = outqty
		# ###未処理－－＞最大発注量の分割
		return mkordparams,last_lotstks
	end	
	###
	#
	###
	###
	def proc_mkprdpurordv1 params,mkordparams  ###xxxschsからxxxordsを作成する。 trngantts:xxxschs= 1:1
		### mkprdpurordsではxno_xxxschはセットしない。schsをまとめたり分割したりする機能のため
		setParams = params.dup
		tbldata = params["tbldata"].dup  ###tbldata -->テーブル項目　　viewではない。
		mkprdpurords_id = params["mkprdpurords_id"]   
		seqno = params["seqno"].dup   
		add_tbl = "" 
		add_tbl_org = ""   ###topから必要数を計算するときの必要数抽出用
		add_tbl_pare = ""    ###topから必要数を計算するときの必要数抽出用
		add_tbl_trn = ""
		strwhere = {"org"=>"","pare"=>"","trn"=>""} 
		tblxxx = ""
		incnt = inqty = inamt = outcnt = outqty = outamt = 0		 
		command_c = nil
		["org","pare","trn"].each do |sel|  ###抽出条件のsql作成
			case sel
				when "org"
					next if tbldata["orgtblname"] == "" or tbldata["orgtblname"].nil? or tbldata["orgtblname"] == "dummy"
					tblxxx = tbldata["orgtblname"]		
					add_tbl_org = %Q%	inner join  #{tblxxx} org  on  gantt.orgtblid = org.id 	
										inner join  itms itm_org  on  gantt.itms_id_org = itm_org.id 
										inner join  shelfnos  shelfno_org  on  gantt.shelfnos_id_org = shelfno_org.id 	 
										inner join  (select loca.*,s.id shelfno_id from locas loca
																	inner join shelfnos s on s.locas_id_shelfno = loca.id )
												loca_org  on  gantt.shelfnos_id_pare = loca_org.shelfno_id
										inner join  r_chrgs person_org  on  gantt.chrgs_id_org = person_org.id 	%   
					add_tbl << add_tbl_org
					strwhere[sel] << "and orgtblname = '#{tblxxx}'     "
				when "pare"
				 	next if tbldata["paretblname"] == "" or tbldata["paretblname"].nil? or tbldata["paretblname"] == "dummy"
					 tblxxx = tbldata["paretblname"]
				 	case tbldata["paretblname"]  
				 	when /schs$/		
						add_tbl_pare = %Q%	inner join  #{tblxxx} pare  on  gantt.paretblid = pare.id 	
										inner join  itms itm_pare  on  gantt.itms_id_pare = itm_pare.id 
										inner join  shelfnos shelfno_pare  on  gantt.shelfnos_id_pare = shelfno_pare.id 
										inner join  (select loca.*,s.id shelfno_id from locas loca
																	inner join shelfnos s on s.locas_id_shelfno = loca.id )
												loca_pare  on  gantt.shelfnos_id_pare = loca_pare.shelfno_id 	
										inner join  r_chrgs person_pare  on  gantt.chrgs_id_pare = person_pare.id 	%   
						add_tbl << add_tbl_pare
					when /ords$/
						add_tbl_pare = %Q$ inner join (select link.srctblid from linktbls link
															inner join #{tblxxx} p   	
																on p.id = link.tblid and link.tblname = '#{tblxxx}' and  link.srctblname like '%schs') sch
												on gantt.paretblid = sch.srctblid 
											inner join  r_chrgs person_pare  on  gantt.chrgs_id_pare = person_pare.id 	
											inner join  itms itm_pare  on  gantt.itm_id_pare = itm_pare.id 
											inner join  shelfnos shelfno_pare  on gantt.shelfnos_id_pare = loca_pare.id 
											inner join  (select loca.*,s.id shelfno_id from locas loca
																		inner join shelfnos s on s.locas_id_shelfno = loca.id )
													loca_pare  on  gantt.shelfnos_id_pare = loca_pare.shelfno_id $   
				###	else
				###		next
					end	
					strwhere[sel] << "and paretblname = '#{tblxxx}'    "

				when "trn"   ###必須項目	
					add_tbl_trn = %Q%	inner join  itms itm_trn  on  gantt.itms_id_trn = itm_trn.id 
									inner join  shelfnos shelfno_trn  on  gantt.shelfnos_id_trn = shelfno_trn.id 	
									inner join  r_chrgs person_trn  on  gantt.chrgs_id_trn = person_trn.id 	
									inner join  (select loca.*,s.id shelfno_id from locas loca
																inner join shelfnos s on s.locas_id_shelfno = loca.id )
											loca_trn  on  gantt.shelfnos_id_trn = loca_trn.shelfno_id %   
					case tbldata["tblname"] 
					when 	"all"	  ###pur,prd両方抽出
						strwhere[sel] << " and gantt.tblname in ('purschs','prdschs')      "
						add_tbl_trn << " left join  prdschs prd  on  gantt.tblid = prd.id "
						add_tbl_trn << " left join purschs pur  on  gantt.tblid = pur.id "
					when "prdords"		
						strwhere[sel] << "and  gantt.tblname = 'prdschs'      "
						add_tbl_trn << " inner join  prdschs prd  on  gantt.tblid = prd.id "
					when "purords"
						strwhere[sel] << "and  gantt.tblname = 'purschs'      "
						add_tbl_trn << " inner join  purschs pur  on  gantt.tblid = pur.id "
					end
					add_tbl << add_tbl_trn
				else
					next	
			end

			tbldata.each do |field_delm,val|  ###field-->r_purxxxs,r_prdxxxsのfield  delm-->org,pare,trn
				next if field_delm =~ /_id/ ###画面から入力された項目のみが対象
				next if val == "" or val.nil? or val == "dummy"
				if field_delm.to_s =~ /_#{sel}/  ###sel:[org,pare,trn]のどれか
					field = field_delm.sub(/_#{sel}/,"")
					tag = field_delm.split("_")[0] + "_" + sel  ###field.split("_")[0]  --> [itm,loca,person,sno]のどれか
					case  field
					when /itm_code|loca_code/  ###itms
						strwhere[sel] << %Q% and #{tag}.code  = '#{val}' 
							%
					when /person_code_chrg/  ###r_chrgs
						strwhere[sel] << %Q% and #{tag}.person_code_chrg  = '#{val}'  
							%
					when /processseq/  ###
						if val > "0"
						    strwhere[sel] << %Q% and gantt.processseq_#{sel} = '#{val}'   
								%
						end		
					when /duedate/						
						strwhere[sel] << %Q% and gantt.#{field}_#{sel} <= cast('#{val}' as date)  
								%
					when /starttime/						
						strwhere[sel] << %Q% and gantt.#{field}_#{sel} >= cast('#{val}' as date)   
								%
					when /sno/			###snoが	
						case sel
						when /org|pare/	
							strwhere[sel] << %Q% and #{sel}.sno = '#{val}'   %
						when /trn/
							case tbldata["tblname"] 
							when 	"all"	  ###pur,prd両方抽出
								strwhere[sel] << %Q% and (prd.sno = '#{val}'  or pur.sno = '#{val}' ) %
							when "prdords"		
								strwhere[sel] << %Q% and prd.sno = '#{val}'   %
							when "purords"
								strwhere[sel] << %Q% and pur.sno = '#{val}'   %
							end
						end
					else
						### itms.name not support
						### p"MkordinstLib line #{__LINE__} field:#{field_delm} not support"
					end
				end	  ### case
			end  ###fields.each
		end   ### ["_org","_pare","_trn"].each do |tbl|

		###ordsは prjnos_id,itms_id,processseq,locas_id(作業場所、発注先),shelfnos_id_to(完成後、受入後)の保管場所毎に作成
		###対象データの特定 trnganttsにmkprdpurords_idをセット
		ActiveRecord::Base.connection.execute("lock table trngantts in  SHARE ROW EXCLUSIVE mode")
		set_mkprdpurords_id_in_trngantts(add_tbl,strwhere,mkprdpurords_id)
    cal_rec = {"qty_require" => 0}
    last_lotstks = []  ###free ords,stkの引当
		shsAllocToStk(mkprdpurords_id).each do |sumSchs|
        cal_rec,last_lotstks_parts = sch_trn_alloc_to_freetrnv1(sumSchs)  
        last_lotstks.concat last_lotstks_parts
    end
    ### itms_id_trn,processseq_trn,shelfnos_id_trnで纏める
		terms = mkord_termv1(mkprdpurords_id)
    save_terms = terms.dup
    cnt = 0
		###上記対象データの中で期間がある品目の選定opeitm.optfixoterm　　期間ごとにxxxordsを分ける。
    while terms.size > 0 do
      terms.each do |term|
          mkord_term_next_update(term)  ###mkordtmpfsの期間を更新する。
      end
      terms = mkord_term_next(mkprdpurords_id)
      cnt += 1
      if cnt > Constants::MaxSplitCnt
        raise "mkordinst_lib.rb line #{__LINE__}  mkord_term_next error"
      end
    end
		### topの親を設定 
		init_sum_ord_qty(mkprdpurords_id)  ###  mkordtmpfs  親子関係あり
    #  xxxschs alllocto ords,stk
    ###
    ###
		###ActiveRecord::Base.connection.insert(init_ordorg_strsql(mkprdpurords_id))       ### mkordorgs 親のみ
		###員数に従って必要数を計算
    mlevel = 1
    max_mlevel = ActiveRecord::Base.connection.select_value("select max(mlevel) from trngantts where mkprdpurords_id = #{mkprdpurords_id}")
    if max_mlevel.nil?
      max_mlevel = 0
    end
    min_duedate = Constants::MinDuedate
    prev_cal_rec = {"itms_id_trn" => 0, "processseq_trn" => 0 ,"itms_id_pare" => 0, "processseq_pare" => 0,"shelfnos_id_trn" => 0,
                    "shelfnos_id_to_trn" => 0, "shelfnos_id_to_pare" => 0,"prjnos_id" => "0","optfixodate" => "0",
                    "qty_require" => 0}
    qty_require = tmp_qty_require = qty = qty_stk = qty_handover = cnt = inqty = inamt = outamt = 0
    prd_duedate = []
    until mlevel > max_mlevel do
      strsql = "select mkprdpurords_id,mlevel,prjnos_id,itms_id_trn,processseq_trn ,optfixodate,sun(qty_handover) qty_handover
                        from mkordtmpfs 
                        where mkprdpurords_id = #{mkprdpurords_id} and mlevel = #{mlevel}
                        group by mkprdpurords_id,mlevel,prjnos_id,itms_id_trn,processseq_trn,optfixodate
								"
      ActiveRecord::Base.connection.select_all(strsql).each do |sel_rec|
        mk_tmp_trngantts(sel_rec).each_with_index do |cal_rec,idx|
          cnt  += 1
          inqty += cal_rec["qty_require"].to_f
          ### inamt zero purschs.amt_schは利用しない。
          cal_rec["consumunitqty"].to_f == 0 ? cal_rec["consumunitqty"] = 1 : cal_rec["consumunitqty"] = cal_rec["consumunitqty"].to_f 
          cal_rec["parenum"].to_f == 0 ? cal_rec["parenum"] = 1 : cal_rec["parenum"] = cal_rec["parenum"].to_f
          cal_rec["packqty"].to_f == 0 ? cal_rec["packqty"] = 1 : cal_rec["packqty"] = cal_rec["packqty"].to_f
          if idx == 0 or  (prev_cal_rec["itms_id_trn"] == cal_rec["itms_id_trn"] and prev_cal_rec["processseq_trn"] == cal_rec["processseq_trn"] and
            prev_cal_rec["prjnos_id"] == cal_rec["prjnos_id"] and prev_cal_rec["optfixodate"] == cal_rec["optfixodate"] and
            prev_cal_rec["shelfnos_id_trn"] == cal_rec["shelfnos_id_trn"] and 
            ((prec_cal_rec["tblname"] == "purschs" and prev_cal_rec["shelfnos_id_to_trn"] == cal_rec["shelfnos_id_to_trn"]) or ###発注は納入先毎に分ける。
              prec_cal_rec["tblname"] == "prdschs") )
                ###qty_require   ###子部品の数量　　員数計算済
                ###tmp_qty_handover   ###親の数量
                ###chk_qty_require   ###子部品の数量　　員数計算済 opeitm_maxqtyを超えたかの判断用
                cal_rec["duedate"] > prev_cal_rec["duedate"] ? cal_rec["duedate"] = prev_cal_rec["duedate"] : cal_rec["duedate"] = cal_rec["duedate"]
                qty_require += cal_rec["qty_require"].to_f   ###子部品の数量　　員数計算済　maxqtyでの分割の残り　通常は0
                if  idx != 0 and (
                    cal_rec["itms_id_pare"] != prev_cal_rec["itms_id_pare"] or cal_rec["processseq_pare"] != prev_cal_rec["processseq_pare"] or
                    cal_rec["shelfnos_id_pare"] != prev_cal_rec["shelfnos_id_pare"] or ###機械が変わった場合、親部品が変わった場合
                    cal_rec["chilnum"]  != prev_cal_rec["chilnum"] or  cal_rec["parenum"] != prev_cal_rec["parenum"] or ###trngantts画面で変更された場合
                    cal_rec["consumunitqty"] != prev_cal_rec["consumunitqty"] or cal_rec["consumchgoverqty"] != prev_cal_rec["consumchgoverqty"])  
                      qty_require += (tmp_qty_handover * prev_cal_rec["chilnum"].to_f / prev_cal_rec["parenum"] /prev_cal_rec["consumunitqty"] ).ceil  * 
                                                                        prev_cal_rec["consumunitqty"] + prev_cal_rec["consumchgoverqty"].to_f 
                      tmp_qty_handover = cal_rec["qty_handover"].to_f
                      chk_qty_require = qty_require - cal_rec["qty"].to_f - cal_rec["qty_stk"].to_f 
                else
                      tmp_qty_handover += cal_rec["qty_handover"].to_f  ###は親の数量
                      chk_qty_require = (tmp_qty_handover * cal_rec["chilnum"].to_f / cal_rec["parenum"] /cal_rec["consumunitqty"] ).ceil  * 
                                                                        cal_rec["consumunitqty"] + cal_rec["consumchgoverqty"].to_f - 
                                                                        cal_rec["qty"].to_f - cal_rec["qty_stk"].to_f + qty_require
                end
                if idx == 0  ###cal_rec["remark"]:prdordsの移動先毎の数量を保持するための項目,purordsでは使用しない。発注を分ける。
                  cal_rec["remark"] = [{"shelfnos_id_to" => cal_rec["shelfnos_id_to_trn"],"duedate" => cal_rec["duedate"],"qty_sch" => chk_qty_require}]
                else 
                  save_remark = cal_rec["remark"].dup
                  matchflg = false
                  cal_rec["remark"].each_with_index do |remark,idx|
                      if  remark["shelfnos_id_to"] ==  cal_rec["shelfnos_id_to_trn"]
                        remark["qty_sch"] = chk_qty_require
                        remark["duedate"] = cal_rec["duedate"]
                        save_remark[idx] = remark
                        matchflg = true
                        break
                      else
                        next
                      end 
                  end
                  if matchflg == false
                    cal_rec["remark"] << {"shelfnos_id_to" => cal_rec["shelfnos_id_to_trn"],"duedate" => cal_rec["duedate"],"qty_sch" => chk_qty_require}
                  else
                    cal_rec["remark"] = save_remark.dup
                  end
                end 
          else
            if prev_cal_rec["itms_id_trn"] == cal_rec["itms_id_trn"] and prev_cal_rec["processseq_trn"] == cal_rec["processseq_trn"] and
                 prev_cal_rec["prjnos_id"] == cal_rec["prjnos_id"]  and
                  prev_cal_rec["shelfnos_id_trn"] == cal_rec["shelfnos_id_trn"] and 
                  ((prec_cal_rec["tblname"] == "purschs" and prev_cal_rec["shelfnos_id_to_trn"] == cal_rec["shelfnos_id_to_trn"]) or ###発注は納入先毎に分ける。
                    prec_cal_rec["tblname"] == "prdschs")
                      cal_rec["consumunitqty"].to_f == 0 ? cal_rec["consumunitqty"] = 1 : cal_rec["consumunitqty"] = cal_rec["consumunitqty"].to_f 
            end  ### cal_rec["optfixodate"] だけが異なる場合、opeitm_maxqtyによる分割なので納期を引継ぐ
            qty_require  += ((tmp_qty_handover * prev_cal_rec["chilnum"].to_f / prev_cal_rec["parenum"].to_f / prev_cal_rec["consumunitqty"].to_f ).ceil  * 
                              prev_cal_rec["consumunitqty"].to_f + prev_cal_rec["consumchgoverqty"].to_f)
            qty_require -= qty
            qty_require -= qty_stk
            prev_cal_rec["qty_require"] = qty_require 
            last_lotstks_parts = mkprdordpurord(prev_cal_rec,false) do
              tbldata["tblname"]
            end
            last_lotstks.concat last_lotstks_parts
            outqty += cal_rec["purord_qty"].to_f
            outqty += cal_rec["prdord_qty"].to_f
            tmp_qty_handover = cal_rec["qty_handover"].to_f 
            qty_require = cal_rec["qty_require"].to_f 
            qty = qty_stk = 0 
            chk_qty_require = (tmp_qty_handover * cal_rec["chilnum"].to_f / cal_rec["parenum"] / cal_rec["consumunitqty"] ).ceil  * 
                                                              cal_rec["consumunitqty"] + cal_rec["consumchgoverqty"].to_f - 
                                                              cal_rec["qty"].to_f - cal_rec["qty_stk"].to_f + qty_require
            cal_rec["remark"] = [{"shelfnos_id_to" => cal_rec["shelfnos_id_to_trn"],"duedate" => cal_rec["duedate"],"qty_sch" => chk_qty_require}]
          end
          qty += cal_rec["qty"].to_f
          qty_stk += cal_rec["qty_stk"].to_f
          cal_rec["maxqty"].to_f == 0 ? opeitm_maxqty = 999999999 : opeitm_maxqty = cal_rec["maxqty"].to_f 
          if chk_qty_require < opeitm_maxqty
                prev_cal_rec = cal_rec.dup
                next
          else
                cal_rec["requestQty"] = chk_qty_require
                until chk_qty_require <= opeitm_maxqty do
                    cal_rec["qty_require"] = opeitm_maxqty
                    last_lotstks_parts = mkprdordpurord(cal_rec,true) do
                      tbldata["tblname"]
                    end
                    last_lotstks.concat last_lotstks_parts
                    chk_qty_require -= opeitm_maxqty
                end
                cal_rec["qty_require"] = chk_qty_require
                prev_cal_rec = cal_rec.dup
          end
          outqty += cal_rec["qty"].to_f
          outamt += cal_rec["amt"].to_f
        end
      end		
      mlevel += 1	
		end
    if prev_cal_rec["itm_id_trn"] != "0"
      last_lotstks_parts = mkprdordpurord(cal_rec,false) do
        tbldata["tblname"]  ###tbldata["tblname"]:選択されるテーブル名
      end
      last_lotstks.concat last_lotstks_parts
      outqty += cal_rec["purord_qty"].to_f
      outqty += cal_rec["prdord_qty"].to_f
    end
		mkordparams[:incnt] = incnt
		mkordparams[:inqty] = inqty
		mkordparams[:outcnt] = outcnt
		mkordparams[:outqty] = outqty
		return mkordparams,last_lotstks
  end
  def mkprdordpurord(cal_rec,splitflg) 
		fields_opeitm = {}  ###opeitm_xxx
		#env = ActiveRecord::Base.configurations["#{ENV["RAILS_ENV"]}"]["database"]
		# field_check_sql = %Q& select column_name from information_schema.columns
		# 				where 	table_catalog='#{env}' 
		# 				and 	table_name = 'r_prdords'  and column_name like 'opeitm_%' &
		field_check_sql = %Q&
                        select pobject_code_sfd from r_screenfields rs 
                                where pobject_code_scr  = 'r_prdords' 
                                and   pobject_code_sfd like 'opeitm_%'
			                          and rs.screenfield_selection = '1' and screenfield_expiredate > current_date &
		fields_opeitm["prdord"] = ActiveRecord::Base.connection.select_values(field_check_sql)
		field_check_sql = %Q& 
                        select pobject_code_sfd from r_screenfields rs 
                                where pobject_code_scr  = 'r_prdords' 
                                and   pobject_code_sfd like 'opeitm_%'
			                          and rs.screenfield_selection = '1' and screenfield_expiredate > current_date &
		fields_opeitm["purord"] = ActiveRecord::Base.connection.select_values(field_check_sql)	
    last_lotstks = []
		line_data = {}
		# ###
		qty_handover = cal_rec["qty_require"].to_f + cal_rec["qty"].to_f 
		tblord = cal_rec["tblname"].sub("schs","ord")
		schRec = ActiveRecord::Base.connection.select_one(%Q& select * from #{cal_rec["tblname"]} where id = #{cal_rec["tblid"]}&)
		blk =  RorBlkCtl::BlkClass.new("r_#{tblord}s")
		command_c = blk.command_init
		symqty = tblord + "_qty"
    cal_rec["packqty"] = 1 if cal_rec["packqty"].to_f == 0
    ###親の消費単位にあわせ自身の作業単位に変換する。
		command_c[symqty] =  (((cal_rec["qty_require"].to_f / cal_rec["consumunitqty"].to_f ).ceil  * 
                                cal_rec["consumunitqty"].to_f + cal_rec["consumchgoverqty"].to_f) / cal_rec["packqty"].to_f).ceil * cal_rec["packqty"].to_f
		command_c["sio_classname"] = "_add_ord_by_mkordinst"
		command_c["sio_viewname"] = "r_#{tblord}s"
		opeitm = {}
		cal_rec.each do |key,val|   ###schRec:xxxschs
						case key
							when "id","qty_sch","price","masterprice","tax","taxrate"  ###purordで再計算　数量、納期が変わっている
								next
							when  /sno|cno/  ###sno,cnoはschから引き継がない。
								command_c["#{tblord}_#{key}"] = ""
							when /amt_sch/  ##ordにはamt_schはない。
								next
							when /opeitms_id/
								opeitm = ActiveRecord::Base.connection.select_one("select itm.taxflg,o.* from opeitms o 
																					inner join itms itm on o.itms_id = itm.id
																						where o.id = #{val}")
								command_c["#{tblord}_#{key.sub("s_id","_id")}"] = val
								opeitm.each do |opekey,value|
									next if opekey.to_s =~ /_upd|_at/
									next if opekey == "id"
									###postgresql のみ
									if fields_opeitm[tblord].find{|n| n == %Q%opeitm_#{opekey.sub("s_id","_id")}%}				
                                		command_c["opeitm_#{opekey.sub("s_id","_id")}"] = value
									end
								end
								line_data[:itm_taxflg] = opeitm["taxflg"]	
							# if opeitm["packqty"].to_f != 0
							# 	command_c["#{tblord}_qty_case"] = command_c[symqty]  / opeitm["packqty"].to_f
							# else
							# 	command_c["#{tblord}_qty_case"] = 0
							# end
							when /toduedate|starttime/
								command_c["#{tblord}_#{key}"] = cal_rec[key]
							when /duedate/
								command_c["#{tblord}_#{key}"] = cal_rec[key]
                if splitflg == true
                  case tblord
                    when "prdord"
                      command_x = {"#{tblord}_shelfno_id_to" => cal_rec["shelfnos_id_to_trn"],
                                "shelfno_loca_id_shelfno_to" => cal_rec["locas_id_to_trn"],
                                "shelfno_loca_id_shelfno" => cal_rec["locas_id_trn"],
                               "prdord_remark" => cal_rec["remark"]}   ###納入先毎の納期、数量 
                    when "purord"
                      command_x = {"#{tblord}_shelfno_id_to" => cal_rec["shelfnos_id_to_trn"],
                                "purord_supplier_id" => schRec["suppliers_id"]}  
                  end
                  parent = {"starttime" => cal_rec["starttime"],"duedate" => cal_rec["duedate"],
                            "shelfnos_id" => cal_rec["shelfnos_id_pare"],
                            "unitofduration" => cal_rec["unitofduration"],"processseq" => cal_rec["processseq_pare"]}
                  nd = {"unitofduration" => cal_rec["unitofduration"],"locas_id_pare" => cal_rec["locas_id_pare"]}
                  command_x = CtlFields.proc_field_duedate(tblord,command_x,parent,nd)
                  command_x = CtlFields.proc_field_starttime(tblord,command_x,parent,nd)
                  cal_rec["duedate"] = command_x["#{tblord}_starttime"]
                  command_x["#{tblord}_contents"] = "over maxqty :#{cal_rec["maxqty"]},request qty:#{cal_rec["reuestQty"]}"
                end
							when /isudate/
								command_c["#{tblord}_#{key}"] = Time.now
							else	 ###xxxschsとxxxordsと項目は同一が原則　　payments_id_purord
								sym = "#{tblord}_#{key.sub("s_id","_id")}"
								command_c[sym] = line_data[sym.to_sym]  = val
						end
		end
    skipflg = false
		case yield ###抽出対象は発注or作業指示？
		 	when "prdords"		
        skipflg = true if tblord == "purord"
		 	when "purords"
        skipflg = true  if tblord == "prdord"
       else
        skipflg = true   if tblord != "prdord" and tblord != "purord"  
		end
    
		if strwhere["pare"].size > 1  ###親で指定された子部品のみ選択
      skipflg = true  if ActiveRecord::Base.connection.select_value(select_schs_from_mkprdpurords_by_pare(add_tbl_pare,strwhere,handover)).nil?
    end
    if strwhere["trn"].size > 1 
      skipflg = true   if ActiveRecord::Base.connection.select_value(select_schs_from_mkprdpurords_by_trn(add_tbl_trn,strwhere,cal_rec)).nil?
    end    
    split_trngantt_duedate_update(cal_rec) if splitflg == true ###納期変更
    if skipflg == true
      ### xxxordsの作成はしない。但しxxxschsの納期更新はする。
      return []
    end
		command_c["#{tblord}_gno"] = "" ### 
		command_c["#{tblord}_id"] = command_c["id"] = ArelCtl.proc_get_nextval("#{tblord}s_seq")
		command_c["sio_classname"] = "_add_proc_mkprdpurord_"
		case tblord 
      when "purord"  ###購入
              line_data = {}
							###command_c["#{tblord}_amt"] = schRec["price"].to_f * command_c[symqty]
							line_data[:purord_duedate] =  command_c["#{tblord}_duedate"]
							line_data[:purord_supplier_id]  = schRec["suppliers_id"]
							line_data[:purord_isudate] = command_c["#{tblord}_isuedate"]
							line_data,err = CtlFields.proc_judge_check_taxrate(line_data,"purord_taxrate",0,"r_purords")
							# strsql = %Q&
							# 		select locas_id_shelfno from shelfnos where id = #{schRec["shelfnos_id"]}
							# 	&
							# command_c["shelfno_loca_id_shelfno"] = line_data[:shelfno_loca_id_shelfno] = ActiveRecord::Base.connection.select_value(strsql)
							strsql = %Q&
									select * from suppliers where id = #{schRec["suppliers_id"]}
								&
							supplier = ActiveRecord::Base.connection.select_one(strsql)
							###line_data[:supplier_contractprice] = command_c["supplier_contractprice"] = supplier["contractprice"]
							line_data[:supplier_amtround] = command_c["supplier_amtround"] = supplier["amtround"]
							line_data[:purord_opeitm_id] = command_c["purord_opeitm_id"] = schRec["opeitms_id"]							
							line_data[:purord_qty] = cal_rec["purord_qty"] = command_c[symqty]
							line_data,err = CtlFields.proc_judge_check_supplierprice(line_data,"purord_price",0,"r_purords")
							command_c["purord_price"] = line_data[:purord_price]
							command_c["purord_masterprice"] = line_data[:purord_masterprice] 
							command_c["purord_amt"] = cal_rec["outamt"] = line_data[:purord_amt]  
							command_c["purord_tax"] = line_data[:purord_tax]  
							command_c["purord_taxrate"] = line_data[:purord_taxrate]  
							command_c["purord_contractprice"] = line_data[:purord_contractprice] 
              command_c["#{tblord}_remark"] = "create by mkord" ### 
      when "prdord"  ###製造        
              shpParams = {"parent" => blk.tbldata,"child" => blk.tbldata,"person_id_upd" => "0"}
              shpParams["parent"]["tblname"] = "prdords"
              shpParams["parent"]["tblid"] = blk.tbldata["id"]
              shpParams["child"]["units_id_case_shp"] = "0"
              shpParams["child"]["depdate"] = cal_rec["duedate"]
              shpParams["child"]["shelfnos_id_fm"] = cal_rec["shelfnos_id"]
              command_x["#{tblord}_remark"] = cal_rec["remark"]
              cal_rec["remark"].each do |remark|
                shpParams["child"]["depdate"] = remark["duedate"]
                shpParams["child"]["qty"] = remark["qty"]
                shpParams["child"]["shelfnos_id_to"] = remark["shelfnos_id_to"]
              end
              cal_rec["outamt"] = 0
              cal_rec["prdord_qty"] = command_c[symqty]
		end
		setParams = {}  ###mkprdpurordsをリセット
    setParams["screenCode"] = "r_#{tblord}s"
		setParams["seqno"] = seqno.dup
		setParams["mkprdpurords_id"] = mkprdpurords_id 
    setParams["person_id_upd"] = params["person_id_upd"] 
    ord_insert_mkordtmpfs(cal_rec,blk.tbldata)  ###mkordtmpfsにinsert
		###
		###  xxxords作成
		###
		command_c["#{tblord}_person_id_upd"] = setParams["person_id_upd"] = params["person_id_upd"]
		command_c["#{tblord}_created_at"] = Time.now
		blk.proc_create_tbldata(command_c)
		setParams = blk.proc_private_aud_rec(setParams,command_c)
    if tblord == "prdord"  ###製造
      proc_create_shpxxxs(params) do 
        "shpords"
      end
    end
		stkinout = {"tblname"=> tblord + "s" ,"tblid" => command_c["id"],
							"itms_id"=>cal_rec["itms_id"],"processseq" => cal_rec["processseq"],
							"prjnos_id" => cal_rec["prjnos_id"],"starttime" => command_c["#{tblord}_duedate"] ,
							"shelfnos_id" => command_c["#{tblord}_shelfno_id_to"],"trngantts_id" => setParams["gantt"]["trngantts_id"],
							"persons_id_upd" => setParams["person_id_upd"],
							"qty_sch" => 0,"qty" => command_c[symqty] ,"qty_stk" => 0,
							"lotno" => "","packno" => "","qty_src" => command_c[symqty].to_f , "amt_src"=> 0}
    last_lotstks  << {"tblname"=> tblord + "s" ,"tblid" => command_c["id"],"qty_src" => command_c[symqty]}
		outcnt += 1
		outqty +=  command_c[symqty].to_f
		gantt = setParams["gantt"].dup
    ###
    #  ###stkinout["qty_src"] :free_qty
    ###
		ActiveRecord::Base.connection.select_all(reverse_sch_trn_strsql(cal_rec)).each do |sch_trn|   ###trngantts.qty_schの変更
		 		if		stkinout["qty_src"] > 0  ###stkinout["qty_src"] :free_qty  
            save_sch_qty = sch_trn["qty_linkto_alloctbl"]
		 				stkinout["remark"] = " #{self} line:(#{__LINE__}) "
            last_lotstks_parts = ArelCtl.proc_add_linktbls_update_alloctbls(sch_trn,stkinout)  ###schs_qtyをfree_qtyに自動で引き当ててくれる。
            last_lotstks.concat last_lotstks_parts 
		 				###Shipment.proc_alloc_change_inoutlotstk(stkinout) ### xxxordsの在庫明細変更
            ###schsの消費の取り消し
            prev = {"id" => sch_trn["tblid"],"qty_src" => save_sch_qty}
            new_prev = {"id" => sch_trn["tblid"],"qty_src" => last_lotstks_parts[0]["qty_src"],"persons_id_upd" => params["person_id_upd"]}
            last_lotstks_parts = Shipment.proc_update_consume(sch_trn["tblname"],new_prev,prev,true)  ###:true 消費の取り消し
            last_lotstks.concat last_lotstks_parts
		 		else
		 						break
		 		end
		end
    return last_lotstks
	end	
  def split_trngantt_duedate_update(cal_rec)	
    ActiveRecord::Base.connection.select_one(split_trngantt_duedate_update(cal_rec)) do |sch|
      blk =  RorBlkCtl::BlkClass.new("r_#{sch["tblname"]}")
      command_c = blk.command_init
      tblord = sch["tblname"].chop
      view = ActiveRecord::Base.connection.select_one(%Q&select * from r_#{sch["tblname"]} where id = #{sch["tblid"]}&) 
      view.each do |key,val|
        command_c[key] = val
      end
      command_c["#{tblord}_duedate"] = cal_rec["duedate"] 
      command_c["#{tblord}_remark"] = "update duedate split ords by maxqty" ### 
      command_c["#{tblord}_id"] = command_c["id"] = sch["tblid"]
      command_c["sio_classname"] = "_update_duedate_"
      setParams = {}  ###mkprdpurordsをリセット
      setParams["screenCode"] = "r_#{tblord}s"
      setParams["seqno"] = seqno.dup
      setParams["mkprdpurords_id"] = mkprdpurords_id 
      setParams["person_id_upd"] = params["person_id_upd"] 
      ###
      ###  xxxords作成
      ###
      command_c["#{tblord}_person_id_upd"] = setParams["person_id_upd"] = "0"
      blk.proc_create_tbldata(command_c)
      setParams = blk.proc_private_aud_rec(setParams,command_c)
    end
  end
  ###
	#
	###
	def proc_mkbillinsts params,mkbillinstparams   
		setParams = params.dup
		tbldata = params["tbldata"].dup  ###tbldata -->
    str_cust_join = str_bill_join = str_chrg_join = ""
		tbldata.each do |field,val|  ### mkbillinsts
			next if val == "" or val.nil?
			case field
			when /loca_code_cust/
        str_cust_join = %Q& where l.code = '#{val}' &     
			when /loca_code_bill/
        str_bill_join = %Q& where l.code = '#{val}'&
			when /person_code_chrg/
        str_chrg_join = %Q& where per.code = '#{val}'&
			end
		end  ###fields.each
    str_joinsql = %Q& inner join (select s.id custs_id,bill.termof,bill.bills_id,bill.ratejson,chrgs_id_bill
                                             from custs s 
                                              inner join ( select p.id bills_id ,p.termof,p.ratejson,p.chrgs_id_bill from bills p 
                                                            inner join  (select c.id from chrgs c 
                                                                          inner join persons per on per.id = c.persons_id_chrg
                                                                            #{str_chrg_join} ) chrg
                                                                on chrg.id = p.chrgs_id_bill
                                                            inner join locas lp on lp.id = p.locas_id_bill     
                                                                #{str_bill_join}
                                                                ) bill                                                                           
                                                on bills_id = s.bills_id_bill
                                              inner join locas ls on ls.id = s.locas_id_cust
                                                    #{str_cust_join}
                                              ) billcust
                       on act.custs_id = billcust.custs_id &

    strsql = %Q&
                select act.id custacts_id,act.amt amt_src,act.saledate,act.crrs_id,billcust.* from custacts act
                      #{str_joinsql}
                      where not exists(select 1 from  srctbllinks link where act.id = link.srctblid
                                        and link.srctblname = 'custacts' and link.tblname = 'billinsts')
                      order by bills_id,act.saledate
              &
      billinst_isudate = Time.now
      last_manth = (Time.now.strftime("%Y") + "-" +Time.now.strftime("%m") + "-" + "01").to_date.since(-1.day)  
      ActiveRecord::Base.connection.select_all(strsql).each do |inst|
        mkbillinstparams[:incnt] += 1
        billinst_tbldata = {"isudate"=>payinst_isudate,"pays_id" => inst["pays_id"],
                      "last_amt" => nil,"last_duedate" => nil,
                      "termofs" => inst["termof"],"payment" => inst["ratejson"],
                      "persons_id_upd" => params["person_id_upd"] ,"trngantts_id" => nil,
                      "chrgs_id" => inst["chrgs_id_pay"],"crrs_id" => inst["crrs_id"],
                      "tblname" => "payinsts",
                      "srctblname" => "custacts","srctblid" => inst["custacts_id"]}
        
        mkbillinstparams = paybillinsts(inst,mkbillinstparams,billinst_tbldata)
		  end
		return mkbillinstparams  
	end	
	###
	def proc_mkpayinsts params,mkpayinstparams  
		setParams = params.dup
		tbldata = params["tbldata"].dup  ###tbldata -->
    str_supplier_join = str_payment_join = str_chrg_join = ""
		tbldata.each do |field,val|  ### mkpayinsts
			next if val == "" or val.nil?
			case field
			when /loca_code_supplier/
        str_supplier_join = %Q& where l.code = '#{val}' &     
			when /loca_code_payment/
        str_payment_join = %Q& where l.code = '#{val}'&
			when /person_code_chrg/
        str_chrg_join = %Q& where per.code = '#{val}'&
			end
		end  ###fields.each
    str_joinsql = %Q& inner join (select s.id suppliers_id,payment.termof,payment.payments_id,payment.ratejson,chrgs_id_payment
                                             from suppliers s 
                                              inner join ( select p.id payments_id ,p.termof,p.ratejson,p.chrgs_id_payment from payments p 
                                                            inner join  (select c.id from chrgs c 
                                                                          inner join persons per on per.id = c.persons_id_chrg
                                                                            #{str_chrg_join} ) chrg
                                                                on chrg.id = p.chrgs_id_payment
                                                            inner join locas lp on lp.id = p.locas_id_payment      
                                                                #{str_payment_join}
                                                                ) payment                                                                             
                                                on payments_id = s.payments_id_supplier
                                              inner join locas ls on ls.id = s.locas_id_supplier
                                                    #{str_supplier_join}
                                              ) paysupp
                       on act.suppliers_id = paysupp.suppliers_id &

    strsql = %Q&
                select act.id puracts_id,act.amt amt_src,act.rcptdate,act.crrs_id,paysupp.* from puracts act
                      #{str_joinsql}
                      where not exists(select 1 from  srctbllinks link where act.id = link.srctblid
                                        and link.srctblname = 'puracts' and link.tblname = 'payinsts')
                      order by payments_id,act.rcptdate
              &
      payinst_isudate = Time.now
      last_manth = (Time.now.strftime("%Y") + "-" +Time.now.strftime("%m") + "-" + "01").to_date.since(-1.day)  
      ActiveRecord::Base.connection.select_all(strsql).each do |inst|
        mkpayinstparams[:incnt] += 1
        payinst_tbldata = {"isudate"=>payinst_isudate,"pays_id" => inst["pays_id"],
                      "last_amt" => nil,"last_duedate" => nil,
                      "termofs" => inst["termof"],"payment" => inst["ratejson"],
                      "persons_id_upd" => params["person_id_upd"] ,"trngantts_id" => nil,
                      "chrgs_id" => inst["chrgs_id_pay"],"crrs_id" => inst["crrs_id"],
                      "tblname" => "payinsts",
                      "srctblname" => "custacts","srctblid" => inst["custacts_id"]}
        mkpayinstparams = paybillinsts(inst,mkpayinstparams,payinst_tbldata)
		  end
		return mkpayinstparams  
	end	

  def paybillinsts(inst,paybillParams,paybill_tbldata)
    inst["termof"].split(",").each do |termof|
      case termof
      when "0","00"   ###随時
        JSON.parse(inst["ratejson"]).each do |rate|   ###rate["duration"] 0:同月　1:翌月
            duedate =  inst["saledate"].to_date.since(rate["duration"].to_i.month)
            if rate["day"].to_i >= 28
              duedate =  duedate.since(1.month)
              duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
              duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
            else
                duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"].to_s)
            end
            paybill_tbldata.merge!({"amt_src" => inst["amt_src"].to_f * rate["rate"].to_i / 100 ,
                        "tax" =>  params["tax"].to_f * rate["rate"].to_i / 100,
                        "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
            proc_create_paybilltbl("payinsts",paybill_tbldata)
            paybillParams[:outcnt] += 1
            paybillParams[:inamt] += paybill_tbldata["amt_src"]
            paybillParams[:outamt] += paybill_tbldata["amt_src"]
        end
        break
      when "28","29","30","31"
        if inst["saledate"].to_date > last_month
          break
        else
          JSON.parse(inst["ratejson"]).each do |rate|
              duedate =  inst["saledate"].to_date.since(rate["duration"].to_i.month)
              if rate["day"].to_i >= 28
                duedate =  duedate.since(1.month)
                duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
              else
                duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"].to_s)
              end
              paybill_tbldata.merge!({"amt_src" => inst["amt_src"].to_f * rate["rate"].to_i / 100 ,
                          "tax" =>  params["tax"].to_f * rate["rate"].to_i / 100,
                          "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
              proc_create_paybilltbl("billinsts",paybill_tbldata)
              paybillParams[:outcnt] += 1
              paybillParams[:inamt] += paybill_tbldata["amt_src"]
              paybillParams[:outamt] += paybill_tbldata["amt_src"]
          end
          break
        end
      else
        if inst["saledate"].to_date > (Time.now.strftime("%Y") + "-" +Time.now.strftime("%m") + "-" + termof).to_date
          next
        else
          JSON.parse(inst["ratejson"]).each do |rate|
              duedate =  inst["saledate"].to_date.since(rate["duration"].to_i.month)
              if rate["day"].to_i >= 28
                duedate =  duedate.since(1.month)
                duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
              else
                duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"].to_s)
              end
              paybill_tbldata.merge!({"amt_src" => inst["amt_src"].to_f * rate["rate"].to_i / 100 ,
                          "tax" =>  params["tax"].to_f * rate["rate"].to_i / 100,
                          "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
              proc_create_paybilltbl(paybill_tbldat["tblname"],paybill_tbldata)
              paybillParams[:outcnt] += 1
              paybillParams[:inamt] += paybill_tbldata["amt_src"]
              paybillParams[:outamt] += paybill_tbldata["amt_src"]
          end
          break ### 重複しないように
        end
      end
    end
  end

	def sch_trn_alloc_to_freetrn(sumSchs)   ###xxxschsをまとめて消費量を決めているので
	 	###freeを探す　
		sumSchs["qty_require"] = qty_require = sumSchs["qty_require"].to_f
		###freeのxxxordsは子部品を既に手配済が条件
		free_qty =  sch_qty = 0
		base = {"qty_src" => 0 }
    last_lotstks = []
			####
			###	個別にひきあてるのでfreeは過剰に消費される
			####
		ActiveRecord::Base.connection.select_all(sch_trn_strsql(sumSchs)).each do |sch_trn|
			sch_qty = sch_trn["qty_linkto_alloctbl"].to_f + sch_qty
			if free_qty <= 0
				strsql = %Q&select * from func_get_free_ord_stk('#{sumSchs["duedate"]}',#{sumSchs["prjnos_id"] },#{sumSchs["itms_id"]},#{sumSchs["processseq"]})&
				ActiveRecord::Base.connection.select_all(strsql).each do |free|   ### 
		   		free.each do |k,v|
						base[k] = v
					end
		   		base["persons_id_upd"] = sumSchs["persons_id_upd"]
					base["amt_src"] = 0
					base["qty_src"] = free_qty = free["qty_linkto_alloctbl"].to_f   ###free_qty
          base["tblname"] = free["tblname"]
          base["tblid"] = free["tblid"]
          base["trnganttd_id"] = free["trngantts_id"]
					if sch_qty > base["qty_src"]
						sch_qty  -= base["qty_src"]
						free_qty = 0
					else
						sch_qty = 0
						free_qty = base["qty_src"] - sch_qty 
					end
					base["remark"] = "#{self} line:(#{__LINE__})"
					last_lotstks_parts =  ArelCtl.proc_add_linktbls_update_alloctbls(sch_trn,base)  ###freeの引当
          last_lotstks.concat last_lotstks_parts
          ###schsの消費の取り消し
          prev = {"id" => sch_trn["tblid"],"qty_src" => sch_trn["qty_linkto_alloctbl"]}
          new_prev = {"id" => sch_trn["tblid"],"qty_src" => sch_qty,"persons_id_upd" => 0}
          last_lotstks_parts = Shipment.proc_update_consume(sch_trn["tblname"],new_prev,prev,true)  ###:true 消費の取り消し
          last_lotstks.concat last_lotstks_parts
          ###
					base["qty_src"] = free_qty
					sch_trn["qty_linkto_alloctbl"] = sch_qty
					break if free_qty > 0
					break if sch_qty <=0
				end
			end
		end
		if free_qty > 0
			sumSchs["qty_require"] = 0
		else
			sumSchs["qty_require"] = qty_require  ###不足時は全数手配
		end
	 	return sumSchs,last_lotstks
	end	
	
	
	def sch_trn_alloc_to_freetrnv1(sumSchs)   ###xxxschsをまとめて消費量を決めているので
    ###freeを探す　
    sumSchs["qty_require"] = qty_require = sumSchs["qty_require"].to_f
    ###freeのxxxordsは子部品を既に手配済が条件
    free_qty =  sch_qty = 0
    base = {"qty_src" => 0 }
    last_lotstks = []
     ####
     ###	個別にひきあてるのでfreeは過剰に消費される
     ####
    ActiveRecord::Base.connection.select_all(sch_trn_strsqlv1(sumSchs)).each do |sch_trn|
      sch_qty = sch_trn["qty_linkto_alloctbl"].to_f + sch_qty
      if free_qty <= 0
        strsql = %Q&select * from func_get_free_ord_stk('#{sumSchs["duedate"]}',#{sumSchs["prjnos_id"] },
                                                          #{sumSchs["itms_id_trn"]},#{sumSchs["processseq_trn"]},#{sumSchs["shelfnos_id_to"]})&
        ActiveRecord::Base.connection.select_all(strsql).each do |free|   ### 
          free.each do |k,v|
           base[k] = v
          end
          base["persons_id_upd"] = sumSchs["persons_id_upd"]
          base["amt_src"] = 0
          base["qty_src"] = free_qty = free["qty_linkto_alloctbl"].to_f   ###free_qty
          base["tblname"] = free["tblname"]
          base["tblid"] = free["tblid"]
          base["trnganttd_id"] = free["trngantts_id"]
          if sch_qty > base["qty_src"]
           sch_qty  -= base["qty_src"]
           free_qty = 0
          else
           sch_qty = 0
           free_qty = base["qty_src"] - sch_qty 
          end
          base["remark"] = "#{self} line:(#{__LINE__})"
          last_lotstks_parts =  ArelCtl.proc_add_linktbls_update_alloctbls(sch_trn,base)  ###freeの引当
          last_lotstks.concat last_lotstks_parts
          ###schsの消費の取り消し
          prev = {"id" => sch_trn["tblid"],"qty_src" => sch_trn["qty_linkto_alloctbl"]}
          new_prev = {"id" => sch_trn["tblid"],"qty_src" => sch_qty,"persons_id_upd" => 0}
          last_lotstks_parts = Shipment.proc_update_consume(sch_trn["tblname"],new_prev,prev,true)  ###:true 消費の取り消し
          last_lotstks.concat last_lotstks_parts
          ###
          base["qty_src"] = free_qty
          sch_trn["qty_linkto_alloctbl"] = sch_qty
          break if free_qty > 0
          break if sch_qty <=0
        end
     end
    end
    if free_qty > 0
      sumSchs["qty_require"] = 0
    else
      sumSchs["qty_require"] = qty_require  ###不足時は全数手配
    end
    return sumSchs,last_lotstks
  end	 

	def set_mkprdpurords_id_in_trngantts_strsql(add_tbl,strwhere,mkprdpurords_id)   ##alocctblのxxxschsは一件のみ
		%Q&
		update trngantts bgantt set mkprdpurords_id_trngantt = #{mkprdpurords_id},
				remark = ' #{self} line:#{__LINE__}'||left(remark,3000),
        optfixodate = cast(duedate_trn as date),
				updated_at = current_timestamp  
				from (select gantt.orgtblid 
										from trngantts gantt #{add_tbl}
										where	gantt.qty_sch > 0 
											 #{strwhere["org"]} #{strwhere["pare"]} #{strwhere["trn"]}
										group by gantt.orgtblid
					) target
				where 	bgantt.orgtblid = target.orgtblid     
			&
	end

	def set_mkprdpurords_id_in_trngantts(add_tbl,strwhere,mkprdpurords_id)   ##alocctblのxxxschsは一件のみ
    ActiveRecord::Base.connection.update(
		  %Q&
		      update trngantts bgantt set mkprdpurords_id_trngantt = #{mkprdpurords_id},
				          remark = ' #{self} line:#{__LINE__}'||left(remark,3000),
                  optfixodate = cast(duedate_trn as date),
				          updated_at = current_timestamp  
				            from (select gantt.orgtblid 
										        from trngantts gantt #{add_tbl}
										        where	gantt.qty_sch > 0 
											          #{strwhere["org"]} #{strwhere["pare"]} #{strwhere["trn"]}
										        group by gantt.orgtblid
					                ) target
				        where 	bgantt.orgtblid = target.orgtblid     
			  &)
	end


	
	def select_schs_from_mkprdpurords_by_pare(add_tbl_pare,strwhere,handover)   ##alocctblのxxxschsは一件のみ
		%Q&
			select  1	from trngantts gantt #{add_tbl_pare} --- 親の属性による選択mkord_term
										where mkprdpurords_id_trngantt = #{handover["mkprdpurords_id"]}
											and gantt.itms_id_pare = #{handover["itms_id_trn"]} 
											and gantt.processseq_pare = #{handover["processseq_trn"]} 
											and gantt.shelfnos_id_pare = #{handover["shelfnos_id_trn"]} 
											and gantt.shelfnos_id_to_pare = #{handover["shelfnos_id_to_trn"]} 
											#{strwhere["pare"]} 
											
			&
	end

	def select_schs_from_mkprdpurords_by_trn(add_tbl_trn,strwhere,sumSchs)   ##alocctblのxxxschsは一件のみ
		%Q&
			select  1 from trngantts gantt #{add_tbl_trn} --- 子の属性による選択
										where mkprdpurords_id_trngantt = #{sumSchs["mkprdpurords_id"]} and
											gantt.itms_id_trn = #{sumSchs["itms_id"]} and
											gantt.processseq_trn = #{sumSchs["processseq"]} and
											gantt.shelfnos_id_trn = #{sumSchs["shelfnos_id"]} and
											gantt.shelfnos_id_to_trn = #{sumSchs["shelfnos_id_to"]}
											#{strwhere["trn"]} 
											
			&
	end

 
	def mkord_termv1 mkprdpurords_id  ###早い納期から先何日纏めか決定する。週纏め、月纏めの機能はない。
    ActiveRecord::Base.connection.select_all(
		      %Q&	
			        select nextval('mkordterms_seq'),prjnos_id ,
				              max(gantt.mlevel), gantt.itms_id_trn,gantt.processseq_trn, 
				              gantt.shelfnos_id_trn,
				              case gantt.optfixoterm
				                when 0 then
					                (cast(max(gantt.duedate_trn) as date) - 365)
				                when null then
					                (cast(max(gantt.duedate_trn) as date) - 365)
				                else
					                (cast(max(gantt.duedate_trn) as date) - cast(max(gantt.optfixoterm) as integer)) 
                      end optfixodate,
                      0,current_timestamp,current_timestamp,
				              #{mkprdpurords_id}  ---xxx
			            from trngantts gantttm 
			            where mkprdpurords_id_trngantt = #{mkprdpurords_id}   ---xxx
			            group by gantt.prjnos_id,gantt.itms_id_trn,gantt.processseq_trn,gantt.shelfnos_id_trn
		        &)
	end	
  
	def mkord_term_next mkprdpurords_id  ###早い納期から先何日纏めか決定する。週纏め、月纏めの機能はない。
        ActiveRecord::Base.connection.select_all(
		        %Q&	
			          select nextval('mkordterms_seq') id,prjnos_id ,
				                max(gantt.mlevel), gantt.itms_id_trn,gantt.processseq_trn, 
				                gantt.shelfnos_id_trn,
                        (cast(max(gantt.duedate_trn) as date) - cast(max(gantt.optfixoterm) as integer)) optfixodate,
				                mkprdpurords_id_trngantt  ---xxx
			              from trngantts gantt
			              where mkprdpurords_id_trngantt = #{mkprdpurords_id}  
                      and cast(gantt.duedate_trn as date) < optfixodate
			              group by gantt.prjnos_id,gantt.itms_id_trn,gantt.processseq_trn,
						                gantt.shelfnos_id_trn, mkprdpurords_id_trngantt
              &)
  end
  
	def mkord_term_next_update term
        ActiveRecord::Base.connection.update( 
		      %Q&	
			        update trngantts set optfixodate = '#{term["optfixodate"]}',
                  remark = ' #{self} line:#{__LINE__}'||left(remark,3000),updated_at = current_timestamp
      	        where prjnos_id = #{term["prjnos_id"]} ,
                and itms_id_trn =  #{term["itms_id_trn"]} and processseq_trn = #{term["processseq_trn"]}
                and shelfnos_id_trn =   #{term["shelfnos_id_trn"]} 
                and cast(duedate_trn as date) >= #{term["optfixodate"]} and cast(duedate_trn as date) < optfixodate
                and mkprdpurords_id = #{term["mkprdpurords_id"]}
            &)
	end	
	
	def init_sum_ord_qty_strsql mkprdpurords_id
		%Q&
		 insert into mkordtmpfs(id,persons_id_upd,
								 mkprdpurords_id,mlevel,itms_id_trn,itms_id_pare,
								processseq_trn,processseq_pare,locas_id_trn,
								prjnos_id,
								shelfnos_id_to_trn,shelfnos_id_trn,
								shelfnos_id_pare,shelfnos_id_to_pare,
								qty_sch,qty,qty_stk,
								duedate,toduedate,starttime,
								packqty,
								consumchgoverqty,consumminqty,
								consumunitqty,
								parenum,chilnum,
								qty_handover,qty_require,   --- qty_handover key='00001'の時のみ有効
								tblname,tblid,incnt,optfixodate
								expiredate,created_at,updated_at)
				select nextval('mkordtmpfs_seq'),0 persons_id_upd, 
						gantt.mkprdpurords_id_trngantt ,'1' mlevel,gantt.itms_id_trn itms_id_trn, gantt.itms_id_pare itms_id_pare,
						gantt.processseq_trn,gantt.processseq_pare ,s.locas_id_shelfno locas_id_trn,
						gantt.prjnos_id ,
            min(gantt.shelfnos_id_to_trn) shelfnos_id_to_trn,  ---発注時は納入先毎に分ける
                --- 作業指示は納入先毎に分けない。remarkに納入先を記載する。
						gantt.shelfnos_id_to_trn ,
            gantt.shelfnos_id_trn,
						max(gantt.shelfnos_id_pare) shelfnos_id_pare,
						max(gantt.shelfnos_id_to_pare) shelfnos_id_to_pare,
						sum(gantt.qty_sch) qty_sch,sum(gantt.qty) qty,sum(gantt.qty_stk) qty_stk,
						min(gantt.duedate_trn),	max(gantt.toduedate_trn),	min(gantt.starttime_trn),
						max(gantt.packqty) packqty,max(gantt.consumchgoverqty) consumchgoverqty,
            max(gantt.consumminqty) consumminqty,max(gantt.consumunitqty) consumunitqty,
						1 parenum,1 chilnum,
						sum(gantt.qty_sch + gantt.qty_) qty_handover,sum(gantt.qty_sch) qty_require,
						max(gantt.tblname) tblname,min(gantt.tblid) tblid,count(tblid),optfixodate,
						'2099/12/31',current_timestamp,current_timestamp 
						from trngantts gantt 
						inner join shelfnos s on s.id = gantt.shelfnos_id_trn
						where  gantt.mkprdpurords_id_trngantt = #{mkprdpurords_id} ---xxx
						group by gantt.mkprdpurords_id_trngantt ,gantt.prjnos_id,
							gantt.itms_id_pare,gantt.processseq_pare ,
              gantt.itms_id_trn,gantt.processseq_trn ,
							gantt.shelfnos_id_trn,gantt.shelfnos_id_to_trn,gantt.optfixodate
							having max(gantt.mlevel) = '1'  --- topの直下の子供を選択する
				&
	end	

	def init_sum_ord_qty mkprdpurords_id
        ActiveRecord::Base.connection.update(
		      %Q&
              insert into mkordtmpfs(id,persons_id_upd,
								 mkprdpurords_id,mlevel,
                 itms_id_pare,itms_id_trn,
								  processseq_pare,processseq_trn,
								  locas_id_trn,prjnos_id,
								  shelfnos_id_to_pare,shelfnos_id_to_trn,
								  shelfnos_id_pare,shelfnos_id_trn,
                  qty_sch,qty,qty_stk,
                  duedate,toduedate,starttime,
								  packqty,consumchgoverqty,
                  consumminqty,	consumunitqty,
								  parenum,chilnum,
								  qty_handover,qty_require,   --- qty_handover key='00001'の時のみ有効
								  tblname,tblid,incnt,
                  optfixodate,
								  expiredate,created_at,updated_at)
				        select nextval('mkordtmpfs_seq'),0 persons_id_upd, 
						      gantt.mkprdpurords_id_trngantt ,'1' mlevel,
                  gantt.itms_id_trn itms_id_pare, gantt.itms_id_trn itms_id_trn,
						      gantt.processseq_trn processseq_pare,gantt.processseq_trn processseq_trn ,
                  max(s.locas_id_shelfno) locas_id_trn,	gantt.prjnos_id ,
                  max(gantt.shelfnos_id_to_trn) shelfnos_id_to_pare,max(gantt.shelfnos_id_to_trn) shelfnos_id_to_trn,
                    ---発注時は納入先毎に分ける
                    --- 作業指示は納入先毎に分けない。remarkに納入先を記載する。
                  max(gantt.shelfnos_id_pare), gantt.shelfnos_id_trn  shelfnos_id_trn,
						      sum(gantt.qty_sch) qty_sch,sum(gantt.qty) qty,sum(gantt.qty_stk) qty_stk,
						      min(gantt.duedate_trn),	max(gantt.toduedate_trn),	min(gantt.starttime_trn),
						      max(gantt.packqty) packqty,max(gantt.consumchgoverqty) consumchgoverqty,
                  max(gantt.consumminqty) consumminqty,max(gantt.consumunitqty) consumunitqty,
						      1 parenum,1 chilnum,
						      sum(gantt.qty_sch) qty_handover,sum(gantt.qty_sch) qty_require,
						      max(gantt.tblname) tblname,min(gantt.tblid) tblid,count(tblid),
                  gantt.optfixodate,
						      '2099/12/31',current_timestamp,current_timestamp 
						    from trngantts gantt 
						    inner join shelfnos s on s.id = gantt.shelfnos_id_trn
                inner join opeitms opeitm on opeitm.itms_id = gantt.itms_id_trn 
                                          and gantt.processseq_trn = opeitm.processseq 
                                          and gantt.shelfnos_id_trn = opeitm.shelfnos_id_opeitm
						    where  gantt.orgtblname = gantt.paretblname and gantt.orgtblid = gantt.paretblid  
                  and gantt.tblname in ('prdschs','purschs')  ---手入力でprdschs,purschsを取り込んだ
                  and gantt.mkprdpurords_id_trngantt = #{mkprdpurords_id}
						    group by gantt.mkprdpurords_id_trngantt ,gantt.prjnos_id,
							        gantt.itms_id_trn,gantt.processseq_trn ,gantt.shelfnos_id_trn,gantt.optfixodate
                having max(gantt.mlevel) = '0' or max(gantt.mlevel) = '1'  --- topの直下の子供を選択する
            --- ex melvel='0':orgtblname=prdschs=paretblname=tblname=prdschs
            --- ex melvel='1':orgtblname=custords=paretblname , tblname=prdschs
				&)
	end	

	def sum_ord_qty_strsql(handover)
		%Q&
	 	insert into mkordtmpfs(id,persons_id_upd,
			 					mkprdpurords_id,mlevel,itms_id_trn,itms_id_pare,
								processseq_trn,processseq_pare,locas_id_trn,
								prjnos_id,
								shelfnos_id_to_trn,shelfnos_id_trn,
								shelfnos_id_pare,shelfnos_id_to_pare,
								qty_sch,qty,qty_stk,
								duedate,toduedate,starttime,
								packqty,
								consumchgoverqty,consumminqty,
								consumunitqty,
								parenum,chilnum,
								qty_handover,qty_require,   --- 
								tblname,tblid,incnt,
								expiredate,created_at,updated_at)
				select nextval('mkordtmpfs_seq'),0 persons_id_upd, 
						gantt.mkprdpurords_id_trngantt ,max(gantt.mlevel) mlevel,gantt.itms_id_trn itms_id_trn,
						gantt.itms_id_pare ,
						gantt.processseq_trn,
						gantt.processseq_pare  ,
						s.locas_id_shelfno ,
						gantt.prjnos_id ,
						gantt.shelfnos_id_to_trn ,gantt.shelfnos_id_trn,
						gantt.shelfnos_id_pare shelfnos_id_pare,gantt.shelfnos_id_to_pare shelfnos_id_to_pare,
            --- COALESCE関数は、NULLでない自身の最初の引数を返します。
						coalesce(sum(alloc.qty_linkto_alloctbl),0) qty_sch,coalesce(sum(ord.qty_linkto_alloctbl),0) qty,
						coalesce(sum(stk.qty_linkto_alloctbl),0) qty_stk,
						min(gantt.duedate_trn) duedate,	min(gantt.toduedate_trn) toduedate,	min(gantt.starttime_trn) starttime,
						term.packqty,gantt.consumchgoverqty,gantt.consumminqty,gantt.consumunitqty,gantt.parenum,gantt.chilnum,
						coalesce(sum(alloc.qty_linkto_alloctbl),0) + coalesce(sum(ord.qty_linkto_alloctbl),0) qty_handover,
						coalesce(sum(alloc.qty_linkto_alloctbl),0)  qty_require,
						max(gantt.tblname) tblname,min(gantt.tblid) tblid,count(gantt.tblid),
						'2099/12/31',current_timestamp,current_timestamp 
						from trngantts gantt 
						inner join mkordterms term on gantt.itms_id_trn = term.itms_id  and gantt.processseq_trn = term.processseq 
													and gantt.shelfnos_id_trn = term.shelfnos_id and gantt.shelfnos_id_to_trn = term.shelfnos_id_to 
													and gantt.prjnos_id = term.prjnos_id  
						inner join shelfnos s on s.id = gantt.shelfnos_id_trn 
						left join alloctbls alloc on alloc.trngantts_id = gantt.id and alloc.qty_linkto_alloctbl > 0 and alloc.srctblname like '%schs'  
						left join alloctbls ord on ord.trngantts_id = gantt.id and ord.qty_linkto_alloctbl > 0 and 
                                        (ord.srctblname like '%ords' or ord.srctblname like '%insts' or ord.srctblname like '%reply%') ---xxxordを含む  
						left join alloctbls stk on stk.trngantts_id = gantt.id and stk.qty_linkto_alloctbl > 0 and (stk.srctblname like '%acts' or
																														stk.srctblname like '%dlvs')  ---xxxordを含む
						where   gantt.mlevel > '1' and 
								gantt.mkprdpurords_id_trngantt = #{handover["mkprdpurords_id"]} ---xxx
							and gantt.duedate_trn >= term.duedate and gantt.duedate_trn < term.optfixodate
							and gantt.itms_id_trn = #{handover["itms_id_trn"]} 
							and gantt.processseq_trn = #{handover["processseq_trn"]}  
							and gantt.shelfnos_id_trn = #{handover["shelfnos_id_trn"]} 
							and gantt.shelfnos_id_to_trn	= #{handover["shelfnos_id_to_trn"]}
						group by gantt.mkprdpurords_id_trngantt ,
							gantt.itms_id_pare,gantt.processseq_pare ,gantt.shelfnos_id_pare,gantt.shelfnos_id_to_pare,  
		 					gantt.itms_id_trn,gantt.processseq_trn ,s.locas_id_shelfno ,gantt.shelfnos_id_to_trn   ,
							gantt.parenum,gantt.chilnum,gantt.prjnos_id,gantt.shelfnos_id_trn,
						  term.packqty,gantt.consumchgoverqty,gantt.consumminqty,gantt.consumunitqty,gantt.parenum,gantt.chilnum
				&
	end		
  
  def ord_insert_mkordtmpfs(cal_rec,tbldata)
    ActiveRecord::Base.connection.insert(
		        %Q&
	 	          insert into mkordtmpfs(id,persons_id_upd,
                mkprdpurords_id,mlevel,
                itms_id_trn,itms_id_pare,
								processseq_trn,processseq_pare,locas_id_trn,
								prjnos_id,
								shelfnos_id_to_trn,shelfnos_id_trn,
								shelfnos_id_pare,shelfnos_id_to_pare,
								qty_sch,qty,qty_stk,
								duedate,toduedate,starttime,
								packqty,consumchgoverqty,
                consumminqty,consumunitqty,
								parenum,chilnum,
								qty_handover,qty_require,   --- 
								expiredate,created_at,updated_at)
				      values (nextval('mkordtmpfs_seq'),0 persons_id_upd, 
                #{cal_rec["mkprdpurords_id"]},#{cal_rec["mlevel"].to_i + 1},
                #{tbldata["itms_id"]},#{tbldata["itms_id"]},  ---xxx_trn=xxx_pare
                #{tbldata["processseq"]},#{tbldata["processseq"]}, 0,
								#{tbldata["prjnos_id"]},
								#{tbldata["shelfnos_id_to"]},#{tbldata["shelfnos_id_trn"]},
                0,0,  ---shelfnos_id_pare,shelfnos_id_to_pare,
                0,#{tbldata["qty"]},0,
                #{tbldata["duedate"]},#{tbldata["toduedate"]},#{tbldata["starttime"]},
                #{cal_rec["packqty"]},#{cal_rec["consumchgoverqty"]},
                #{cal_rec["consumminqty"]},#{cal_rec["consumunitqty"]},
                #{cal_rec["parenum"]},#{cal_rec["chilnum"]},
                #{cal_rec["qty_handover"]},0,   --- 
                '2099/12/31',current_timestamp,current_timestamp )
              &)
  end
	def mk_tmp_trngantts(sel_rec)
    ActiveRecord::Base.connection.select_all(
		      %Q&
				    select nextval('mkordtmpfs_seq'),gantt.mkprdpurords_id_trngantt ,#{sel_rec["mlevel"]} mlevel,
                gantt.itms_id_trn itms_id_trn,gantt.itms_id_pare ,
						    gantt.processseq_trn,	gantt.processseq_pare  ,
						    gantt.prjnos_id ,
						    gantt.shelfnos_id_to_trn ,gantt.shelfnos_id_trn,
						    gantt.shelfnos_id_pare shelfnos_id_pare,gantt.shelfnos_id_to_pare shelfnos_id_to_pare,
                --- COALESCE関数は、NULLでない自身の最初の引数を返します。
						    coalesce(sum(alloc.qty_linkto_alloctbl),0) qty_sch,coalesce(sum(ord.qty_linkto_alloctbl),0) qty,
						    coalesce(sum(stk.qty_linkto_alloctbl),0) qty_stk,
						    gantt.duedate_trn duedate,	gantt.toduedate_trn,	gantt.starttime_trn,gantt.maxqty,
						    gantt.packqty,gantt.consumchgoverqty,gantt.consumminqty,gantt.consumunitqty,gantt.parenum,gantt.chilnum,
						    0 persons_id_upd, pare.qty_handover qty_handover, 0 qty_require
					    from trngantts gantt 
					    inner join (select  itms_id_trn,processseq_trn,qty_handover,optfixodate,#{sel_rec["mlevel"]} mlevel,
                                  #{sel_rec["qty_handover"]} qty_handover,
                                  tblname,tblid from trngantts
                              where mkprdpurords_id_trngantt = #{sel_rec["mkprdpurords_id"]} ---xxx
                              and prjnos_id = #{sel_rec["prjnos_id"]} and optfixodate = '#{sel_rec["optfixodate"]}'
							                and itms_id_trn = #{sel_rec["itms_id_trn"]} 
							                and processseq_trn = #{sel_rec["processseq_trn"]}) pare
                    on gantt.itms_id_pare = pare.itms_id_trn  and gantt.processseq_trn = pare.processseq_trn
                     and  gantt.paretblname = pare.tblname  and gantt.paretblid = pare.tblid 
                     and gantt.mkprdpurords_id_trngantt = pare.mkprdpurords_id_trngantt
                order by gantt.prjnos_id ,gantt.itms_id_trn,gantt.processseq_trn,gantt.shelfnos_id_trn,gannt.optfixodate,
                    gantt.shelfnos_id_to_trn,	gantt.duedate_trn dsc					
				&)
	end		
  	
	def split_trngantt_duedate_update_sql(sel_rec)
		%Q&
          select  itms_id_trn,processseq_trn,tblname,tblid from trngantts
                              where mkprdpurords_id_trngantt = #{sel_rec["mkprdpurords_id"]} ---xxx
                              and prjnos_id = #{sel_rec["prjnos_id"]} 
                              and optfixodate = '#{sel_rec["optfixodate"]}'
                              and optfixodate > '#{sel_rec["duedate_trn"]}'
                              and optfixodate =< cast(duedate_trn as date)
							                and itms_id_trn = #{sel_rec["itms_id_trn"]} 
							                and processseq_trn = #{sel_rec["processseq_trn"]}                              
							                and shelfnos_id_trn = #{sel_rec["shelfnos_id_trn"]} ) pare
            order by gantt.prjnos_id ,gantt.itms_id_trn,gantt.processseq_trn,gantt.shelfnos_id_trn,
                    gantt.shelfnos_id_to_trn,	gantt.duedate_trn dsc					
				&
	end		
  
	def update_tmp_trngantts_sql(cal_rec)
		%Q&
				select id,tblname,tblid,duedate_trn
						from trngantts gantt 
						where  gantt.mkprdpurords_id_trngantt = #{cal_rec["mkprdpurords_id"]} ---xxx
							and gantt.itms_id_pare = #{cal_rec["itms_id_trn"]} 
							and gantt.processseq_pare = #{cal_rec["processseq_trn"]}  
							and gantt.shelfnos_id_pare = #{cal_rec["shelfnos_id_trn"]} 
							and gantt.shelfnos_id_to_pare	= #{cal_rec["shelfnos_id_to_trn"]}
							and gantt.duedate_pare	= '#{cal_rec["duedate_trn"]}'
				&
	end

	def sum_ord_qty_strsqlv1(handover)
		%Q&
				select nextval('mkordtmpfs_seq'),0 persons_id_upd, 
						gantt.mkprdpurords_id_trngantt ,max(gantt.mlevel) mlevel,gantt.itms_id_trn itms_id_trn,gantt.itms_id_trn itms_id,
						gantt.itms_id_pare ,
						gantt.processseq_trn,
						gantt.processseq_pare  ,gantt.processseq_pare  processseq,
						s.locas_id_shelfno ,
						gantt.prjnos_id ,
						gantt.shelfnos_id_to_trn ,gantt.shelfnos_id_trn,
						gantt.shelfnos_id_pare shelfnos_id_pare,gantt.shelfnos_id_to_pare shelfnos_id_to_pare,
            gantt.locas_id_trn,gantt.locas_id_to_trn,gantt.locas_id_pare, 
						gantt.qty_sch,gtantt.qty,
						qty_stk,
						gantt.duedate,	gantt.toduedate,	gantt.starttime,
						term.packqty,gantt.consumchgoverqty,gantt.consumminqty,gantt.consumunitqty,gantt.parenum,gantt.chilnum,
						pare.qty_handover,
						gantt.qty_require,
						gantt.tblname,gantt.tblid,gantt.cnt,
            opeitm.maxqty opeitm_maxqty, gantt.duration,gantt.unitofduration
						from trngantts gantt 
            where   gantt.mlevel > '1' and 
								gantt.mkprdpurords_id_trngantt = #{handover["mkprdpurords_id"]} ---xxx
							and gantt.duedate_trn >= term.duedate and gantt.duedate_trn < term.optfixodate
							and gantt.itms_id_pare = #{handover["itms_id_trn"]} 
							and gantt.processseq_pare = #{handover["processseq_trn"]}  
							and gantt.shelfnos_id_pare = #{handover["shelfnos_id_trn"]} 
							and gantt.shelfnos_id_to_pare	= #{handover["shelfnos_id_to_trn"]}
            order by gantt.prjnos_id ,
                      gantt.itms_id_trn,gantt.processseq_trn,gantt.shelfnos_id_trn,
                      gantt.itms_id_pare,gantt.processseq_pare,
                      gantt.shelfnos_id_to_trn,gantt.duedate_trn dsc
				&
	end			

	def schs_alloc_to_ordstksql(handover)
		%Q&
				select *
						from trngantts gantt 
            where   gantt.mlevel > '1' and 
								gantt.mkprdpurords_id_trngantt = #{handover["mkprdpurords_id"]} ---xxx
							and gantt.duedate_trn >= term.duedate and gantt.duedate_trn < term.optfixodate
							and gantt.itms_id_pare = #{handover["itms_id_trn"]} 
							and gantt.processseq_pare = #{handover["processseq_trn"]}  
							and gantt.shelfnos_id_pare = #{handover["shelfnos_id_trn"]} 
							and gantt.shelfnos_id_to_pare	= #{handover["shelfnos_id_to_trn"]}
            order by gantt.itms_id_trn,gantt.processseq_trn,gantt.duedate,
                      gantt.shelfnos_id_trn,gantt.shelfnos_id_to_trn,gantt.prjnos_id ,gantt.duedate_trn 
				&
	end			

	def get_ordqty(handover)		
		%Q&
		 select     ---tmp.id,
		 			trunc(trunc((sum(tmp.qty_handover) * tmp.chilnum / tmp.parenum) / max(tmp.consumunitqty) + 0.99999) * max(tmp.consumunitqty) +
                     max(tmp.consumchgoverqty)) qty_require,
		 			---trunc((trunc((sum(tmp.qty_handover) * tmp.chilnum / tmp.parenum) / max(tmp.consumunitqty) + 0.99999) * max(tmp.consumunitqty) + max(tmp.consumchgoverqty)
		 			---			- sum(tmp.qty) - sum(tmp.qty_stk))/max(tmp.packqty) + 0.99999) * max(tmp.packqty)  qty_handover,
            0 qty_handover,max(packqty) packqty, 
		 	   		max(tmp.tblname),min(tmp.tblid),
						tmp.itms_id_pare,tmp.processseq_pare,tmp.shelfnos_id_pare,tmp.shelfnos_id_to_pare,
						tmp.itms_id_trn,tmp.locas_id_trn,tmp.processseq_trn,tmp.shelfnos_id_trn,tmp.shelfnos_id_to_trn,
						tmp.mkprdpurords_id,tmp.prjnos_id
		 	   	from mkordtmpfs tmp
		 	   		where tmp.mkprdpurords_id = #{handover["mkprdpurords_id"]} 
		 				---and tmp.mlevel > '1'
		 	   			and tmp.itms_id_pare = #{handover["itms_id_trn"]} and tmp.processseq_pare = #{handover["processseq_trn"]}  
		 	   			and tmp.shelfnos_id_pare = #{handover["shelfnos_id_trn"]}    and  tmp.shelfnos_id_to_pare = #{handover["shelfnos_id_to_trn"]} 
		 	   			and tmp.prjnos_id = #{handover["prjnos_id"]}
		 			group by    tmp.itms_id_pare,tmp.processseq_pare,tmp.shelfnos_id_pare,tmp.shelfnos_id_to_pare,  
		 			            tmp.itms_id_trn,tmp.locas_id_trn,tmp.processseq_trn,tmp.prjnos_id,tmp.shelfnos_id_trn,tmp.shelfnos_id_to_trn,
						          tmp.packqty,tmp.consumchgoverqty,tmp.consumminqty,tmp.consumunitqty,tmp.parenum,tmp.chilnum,tmp.mkprdpurords_id
		      &
	end
	 
	def req_ord_sql(mkprdpurords_id) 
			%Q&
					select  tmp.itms_id_trn itms_id,tmp.shelfnos_id_trn shelfnos_id,tmp.locas_id_trn locas_id,
							tmp.processseq_trn processseq,tmp.prjnos_id,tmp.shelfnos_id_to_trn shelfnos_id_to,
							---term.duedate,
              max(tmp.packqty) packqty,min(tmp.duedate) duedate,
							max(tmp.tblname) tblname,max(tmp.tblid) tblid,tmp.mkprdpurords_id ,min(tmp.starttime) starttime,
							max(tmp.qty_require) qty_require,max(tmp.qty_handover) qty_handover,max(tmp.consumminqty) consumminqty,
							max(tmp.id) mkordorgs_id,min(tmp.toduedate) toduedate,max(tmp.consumchgoverqty) consumchgoverqty,
							sum(tmp.incnt) incnt,max(tmp.persons_id_upd) persons_id_upd
					   from mkordtmpfs tmp
					  ---  inner join mkordterms term on	tmp.itms_id_trn = term.itms_id and tmp.shelfnos_id_trn = term.shelfnos_id 
					  ---  							and tmp.locas_id_trn = term.locas_id and  tmp.processseq_trn = term.processseq
						--- 						and	tmp.prjnos_id = term.prjnos_id and 	tmp.shelfnos_id_to_trn  = term.shelfnos_id_to
						--- 						and tmp.mkprdpurords_id = term.mkprdpurords_id
					   where tmp.mkprdpurords_id = #{mkprdpurords_id}
						   --and tmp.itms_id_pare = {handover["itms_id_pare"]} and tmp.processseq_pare = {handover["processseq_pare"]}  
						   ---and tmp.shelfnos_id_pare = {handover["shelfnos_id_pare"]} and tmp.shelfnos_id_to_pare = {handover["shelfnos_id_to_pare"]} 
						   ---and tmp.prjnos_id = {handover["prjnos_id"]}
						and tmp.qty_sch > 0  --- ord手配済は対象外
						---and tmp.duedate >= term.duedate and tmp.duedate < term.optfixodate
						group by  tmp.itms_id_trn,tmp.shelfnos_id_trn,tmp.locas_id_trn, tmp.processseq_trn,tmp.prjnos_id,tmp.shelfnos_id_to_trn,
						          tmp.packqty,tmp.consumchgoverqty,tmp.consumminqty,tmp.consumunitqty,tmp.parenum,tmp.chilnum,
                  ---term.duedate,
                  tmp.mkprdpurords_id 
					&
	end

	def	sch_trn_strsql(sumSchs) 
		 %Q&   ---sumSchsから個別のqty_schをもとめる。
		  		select gantt.id trngantts_id,gantt.*,a.id alloctbls_id,a.qty_linkto_alloctbl from trngantts gantt
					inner join shelfnos s on s.id = gantt.shelfnos_id_trn
					inner join alloctbls a on a.trngantts_id = gantt.id
					where gantt.mkprdpurords_id_trngantt = #{sumSchs["mkprdpurords_id"]}
					and gantt.itms_id_trn = #{sumSchs["itms_id"]} 
					and s.locas_id_shelfno = #{sumSchs["locas_id"]}  ---引当はlocas_id
					and gantt.processseq_trn = #{sumSchs["processseq"]} and gantt.shelfnos_id_to_trn = #{sumSchs["shelfnos_id_to"]}
					and ((a.qty_linkto_alloctbl > 0 and a.srctblname like '%schs') 
						or (a.qty_linkto_alloctbl > 0 and a.srctblname = 'custords' and gantt.orgtblname = gantt.paretblname  
							and gantt.paretblname = gantt.tblname))  --- top custordsへの引き当て
					order by  (gantt.duedate_trn)
			&	
	end

	def	sch_trn_strsqlv1(sumSchs) 
		 %Q&   ---sumSchsから個別のqty_schをもとめる。
		  		select gantt.id trngantts_id,gantt.*,a.id alloctbls_id,a.qty_linkto_alloctbl 
          from trngantts gantt
					  inner join shelfnos s on s.id = gantt.shelfnos_id_trn
					  inner join alloctbls a on a.trngantts_id = gantt.id
					where gantt.mkprdpurords_id_trngantt = #{sumSchs["mkprdpurords_id"]}
					  and gantt.itms_id_trn = #{sumSchs["itms_id"]} 
					  and gantt.processseq_trn = #{sumSchs["processseq"]} 
					  and s.locas_id_shelfno = #{sumSchs["locas_id"]}  ---引当はlocas_id
					  and s.prjnos_id = #{sumSchs["prjnos_id"]} 
					  and ((a.qty_linkto_alloctbl > 0 and a.srctblname like '%schs') 
						  or (a.qty_linkto_alloctbl > 0 and a.srctblname = 'custords' and gantt.orgtblname = gantt.paretblname  
							  and gantt.paretblname = gantt.tblname))  --- top custordsへの引き当て
					order by  (gantt.duedate_trn)
			&	
	end

  
	def	reverse_sch_trn_strsql(cal_rec) 
    %Q&   ---cal_recから個別のqty_schをもとめる。
         select gantt.id trngantts_id,gantt.*,a.id alloctbls_id,a.qty_linkto_alloctbl from trngantts gantt
         inner join alloctbls a on a.trngantts_id = gantt.id
         where gantt.mkprdpurords_id_trngantt = #{cal_rec["mkprdpurords_id"]}
         and gantt.itms_id_trn = #{cal_rec["itms_id_trn"]} 
         and s.shelfnos_id_trn = #{cal_rec["shelfnos_id_trn"]}  ---引当はlocas_id
         and gantt.processseq_trn = #{cal_rec["processseq_trn"]} and gantt.shelfnos_id_to_trn = #{cal_rec["shelfnos_id_to"]}
         and gantt.optfixodate = '#{cal_rec["optfixodate"]}'
         and (a.qty_linkto_alloctbl > 0 and a.srctblname like '%schs') 
         order by gantt.optfixodate  desc, gantt.duedate_trn
     &	
  end


	def init_ordorg_strsql mkprdpurords_id
		%Q&
		insert into mkordorgs(id,persons_id_upd,
			mkprdpurords_id,mlevel,itms_id,
	   		processseq,
			locas_id,
			shelfnos_id,
	   		prjnos_id,
	   		shelfnos_id_to,
	   		qty_sch,qty,qty_stk,
	   		duedate,toduedate,starttime,
	   		packqty,
	   		consumchgoverqty,consumminqty,
	   		consumunitqty,
	   		qty_handover,qty_require,   --- 
	   		tblname,tblid,incnt,
	   		expiredate,created_at,updated_at)
		select nextval('mkordorgs_seq'),0 persons_id_upd, 
			gantt.mkprdpurords_id ,max(gantt.mlevel) mlevel,gantt.itms_id_trn itms_id, 
			gantt.processseq_trn processseq,
			gantt.locas_id_trn locas_id,
			gantt.shelfnos_id_trn,
			gantt.prjnos_id ,
			gantt.shelfnos_id_to_trn ,
			sum(gantt.qty_sch) qty_sch,sum(gantt.qty) qty,sum(gantt.qty_stk) qty_stk,
			min(gantt.duedate),	max(gantt.toduedate),	min(gantt.starttime),
			1 packqty,
			0 consumchgoverqty,0 consumminqty,
			1 consumunitqty,
			trunc(sum(gantt.qty_handover) / max(gantt.packqty) + 0.99999) * max(gantt.packqty)  qty_handover,
			sum(gantt.qty_require) qty_require,
			max(gantt.tblname) tblname,min(gantt.tblid) tblid,count(tblid),
			'2099/12/31',current_timestamp,current_timestamp 
			from mkordtmpfs gantt 
			inner join mkordterms term on gantt.itms_id_trn = term.itms_id  and gantt.processseq_trn = term.processseq 
						   and gantt.locas_id_trn = term.locas_id and gantt.prjnos_id = term.prjnos_id  
						   and gantt.mkprdpurords_id = term.mkprdpurords_id 
						   and gantt.shelfnos_id_trn = term.shelfnos_id and gantt.shelfnos_id_to_trn = term.shelfnos_id_to 
			where   gantt.mkprdpurords_id = #{mkprdpurords_id} ---xxx
   				and gantt.duedate >= term.duedate and gantt.duedate < term.optfixodate  --- gantt.duedate:ok
			group by gantt.mkprdpurords_id,
				gantt.itms_id_trn,gantt.processseq_trn ,
				gantt.prjnos_id,gantt.shelfnos_id_to_trn,gantt.shelfnos_id_trn,gantt.locas_id_trn,
				gantt.packqty,gantt.consumchgoverqty,gantt.consumminqty,gantt.consumunitqty,gantt.parenum,gantt.chilnum 
   				having max(gantt.mlevel) = 1
				&
	end
  
  def shsAllocToStk(mkprdpurords_id)###free ords,stkの引当
    ActiveRecord::Base.connection.select_all(
        %Q&
          select gantt.itms_id_trn itms_id_trn ,gantt.processseq_trn  processseq,gantt.prjnos_id,
              sum(gantt.qty_sch) qty_require,s.locas_id_shelfno locas_id,
              gantt.shelfnos_id_trn shelfnos_id,gantt.mkprdpurords_id_trngantt mkprdpurords_id
              from trngantts	gantt
              inner join shelfnos s on s.id = gantt.shelfnos_id_to_trn
              group by gantt.itms_id_trn,gantt.processseq_trn,gantt.prjnos_id,
                        s.locas_id_shelfno, gantt.shelfnos_id_trn、、gantt.mkprdpurords_id_trngantt
              where gantt.mkprdpurords_id_trngantt = #{mkprdpurords_id} and gantt.qty_sch  > 0
              order by gantt.itms_id_trn,gantt.processseq_trn,gantt.shelfnos_id_trn,gantt.duedate_trn
          &)
  end

  ###前払い　前受け金を含む
  def proc_create_paybilltbl(tblname,tbldata)  ###src:puracts puracts_id
        blk = RorBlkCtl::BlkClass.new("r_#{tblname}")
        command_c = blk.command_init
        command_c["#{tblname.chop}_person_id_upd"] = tbldata["persons_id_upd"]
        command_c["#{tblname.chop}_chrg_id"] = tbldata["chrgs_id"]
        command_c["#{tblname.chop}_duedate"] = tbldata["duedate"]
        command_c["#{tblname.chop}_isudate"] = tbldata["isudate"]
        command_c["#{tblname.chop}_expiredate"] =  Constants::EndDate 
        command_c["#{tblname.chop}_updated_at"] = Time.now
        case tblname
        when /^pay/
          command_c["#{tblname.chop}_payment_id"] = tbldata["payments_id"]
          command_c["#{tblname.chop}_accounttitle"] = "1"  ###仕入
        when /^bill/
          command_c["#{tblname.chop}_bill_id"] = tbldata["bills_id"]
        end
        command_c["#{tblname.chop}_amt"] = tbldata["amt_src"]
        command_c["#{tblname.chop}_tax"] = tbldata["amt_src"].to_f * tbldata["taxrate"].to_f / 100 
        command_c["#{tblname.chop}_denomination"] = tbldata["denomination"]   ###  CASH,DEPOSIT,DRAFT
        command_c["#{tblname.chop}_remark"] = "class:#{self},line:#{__LINE__},srctblname:#{tbldata["srctblname"]},srctblid:#{tbldata["srctblid"]}"
        case tblname 
        when /acts$/
          str_amt = "cash"
        when /schs$/
          str_amt = 'amt_sch'
        else
          str_amt = "amt"
        end
        strsql = %Q&
                    select * from #{tblname} 
                                  where #{if  tbldata["payments_id"] 
                                               "payments_id = " +  tbldata["payments_id"]
                                          else
                                              if tbldata["bills_id"] 
                                                 "bills_id = " + tbldata["bills_id"] 
                                              end
                                          end}
                                  and duedate = '#{tbldata["duedate"].to_date}' 
                &
        actrec = ActiveRecord::Base.connection.select_one(strsql)
        if actrec
                command_c["sio_classname"] = "_update_from_#{tbldata["srctblname"]}"
                command_c["id"] = command_c["#{tblname.chop}_id"] = actrec["id"]
                command_c["#{tblname.chop}_#{str_amt}"] = actrec[str_amt].to_f + tbldata["amt_src"].to_f
                command_c = blk.proc_create_tbldata(command_c) ##
                blk.proc_private_aud_rec({},command_c)
        else
                command_c["sio_classname"] = "_add_from_#{tbldata["srctblname"]}"
                command_c["id"] = command_c["#{tblname.chop}_id"] = ArelCtl.proc_get_nextval("#{tblname}_seq")
                command_c["#{tblname.chop}_created_at"] = Time.now
                command_c["#{tblname.chop}_sno"] = CtlFields.proc_field_sno("#{tblname.chop}",tbldata["isudate"],command_c["id"])
                command_c["#{tblname.chop}_#{str_amt}"] = tbldata["amt_src"]
                command_c["#{tblname.chop}_#{str_amt}"] = command_c["#{tblname.chop}_#{str_amt}"].to_f * tbldata["taxrate"].to_f / 1000
                command_c["#{tblname.chop}_sno"] = CtlFields.proc_field_sno(tblname.chop,tbldata["isudate"],command_c["id"])
                command_c = blk.proc_create_tbldata(command_c) ##
                blk.proc_private_aud_rec({},command_c)
        end
        src = {"tblname" => tbldata["srctblname"],"tblid" => tbldata["srctblid"]}
        base = {"tblname" => "#{tblname}","tblid" => command_c["id"],"amt_src" => command_c["#{tblname.chop}_#{str_amt}"]}
        ArelCtl.proc_insert_srctbllinks(src,base)
            ###
            # 前の状態の削除
            ##
        case tblname
        when /acts$/  ##payinsts,billinsts からｓｎｏでの消込
              strsql = %Q&
                        select * from #{src["srctblname"]} where id = #{tbldata["srctblid"]}             
              &
              prevtbldata = ActiveRecord::Base.connection.select_one(strsql)
              blk = RorBlkCtl::BlkClass.new("r_#{prevtblname}")
              command_c = blk.command_init
              command_c["sio_classname"] = "_update_from_#{tblname}"
              command_c["#{prevtblname.chop}_person_id_upd"] = tbldata["persons_id_upd"]
              command_c["id"] = command_c["#{prevtblname.chop}_id"]= tbldata["srctblid"]
              command_c["#{prevtblname.chop}_amt"] = prevtbldata["amt"].to_f 
              command_c["#{prevtblname.chop}_tax"] = prevtbldata["amt"].to_f * prevtbldata["taxrate"].to_f / 100   
              command_c = blk.proc_create_tbldata(command_c) ##
              blk.proc_private_aud_rec({},command_c)
        when /insts$/
              prevtblname = tblname.sub("inst","ord")  ###tbldata["srctblname"]--> puracts custacts
              strsql = %Q&
                    select * from #{prevtblname} where id = (
                        select tblid from srctbllinks 
                         where srctblid = #{tbldata["srctblid"]}  and srctblname = '#{tbldata["srctblname"]}'
                         and tblname = '#{prevtblname}' )       
              &
              prevtbldata = ActiveRecord::Base.connection.select_one(strsql)
              blk = RorBlkCtl::BlkClass.new("r_#{prevtblname}")
              command_c = blk.command_init
              command_c["sio_classname"] = "_update_from_#{tblname}"
              command_c["#{prevtblname.chop}_person_id_upd"] = tbldata["persons_id_upd"]
              command_c["id"] = command_c["#{prevtblname.chop}_id"]= prevtbldata["id"]
              command_c["#{prevtblname.chop}_amt"] = prevtbldata["amt"].to_f - tbldata["amt_src"].to_f
              command_c["#{prevtblname.chop}_tax"] = command_c["#{prevtblname.chop}_amt"] * tbldata["taxrate"].to_f / 100
              command_c = blk.proc_create_tbldata(command_c) ##
              blk.proc_private_aud_rec({},command_c)
        when /ords$/
              case tbldata["srctblname"] 
              when  /puracts/ #
                    strsql = %Q&
                        select ord.srctblname,ord.srctblid from linktbls ord 
                              where ord.tblname = 'puracts' and ord.tblid =  #{tbldata["srctblid"]}
                              and ord.srctblname = 'purords'
                              group by ord.srctblname,ord.srctblid 
                      union
                        select ord.srctblname,ord.srctblid from linktbls ord 
                              inner join linktbls inst on ord.tblname = inst.srctblname and ord.tblid = inst.srctblid
                              where inst.tblname = 'puracts' and inst.tblid =  #{tbldata["srctblid"]}
                              and (ord.tblname = 'purinsts' or ord.tblname = 'purreplyinputs' or ord.tblname = 'purdlvs') 
                              and ord.srctblname = 'purords'
                              group by ord.srctblname,ord.srctblid 
                      union
                        select ord.srctblname,ord.srctblid from linktbls ord 
                              inner join (select i.* from linktbls i 
                                                inner join linktbls j on i.tblname = j.srctblname and i.tblid = j.srctblid
                                                where j.tblname = 'puracts' and j.tblid =  #{tbldata["srctblid"]}
                                                and (i.tblname != j.srctblname or i.tblid != j.srctblid)
                                                and ( j.srctblname = 'purreplyinputs' or j.srctblname = 'purdlvs') ) inst
                                on ord.tblname = inst.srctblname and ord.tblid = inst.srctblid
                              where (ord.tblname = 'purinsts' or ord.tblname = 'purreplyinputs') 
                              and ord.srctblname = 'purords'
                              group by ord.srctblname,ord.srctblid 
                      union
                        select ord.srctblname,ord.srctblid from linktbls ord 
                              inner join (select i.* from linktbls i 
                                                inner join (select x.* from linktbls x
                                                                  inner join linktbls y  on x.tblname = y.srctblname and x.tblid = y.srctblid
                                                              where x.tblname = 'puracts' and x.tblid =  #{tbldata["srctblid"]}
                                                              and  y.srctblname = 'purdlvs') j
                                                on i.tblname = j.srctblname and i.tblid = j.srctblid
                                                where   j.srctblname = 'purreplyinputs' or j.srctblname = 'purinsts' ) inst
                                on ord.tblname = inst.srctblname and ord.tblid = inst.srctblid
                              where (ord.tblname = 'purinsts' or ord.tblname = 'purreplyinputs') 
                              and ord.srctblname = 'purords'
                              group by ord.srctblname,ord.srctblid 
                          &
              when /custacts/
                        strsql = %Q&
                            select ord.srctblname,ord.srctblid from linkcusts ord 
                                where ord.tblname = 'custacts' and ord.tblid =  #{tbldata["srctblid"]}
                                and ord.srctblname = 'custords'
                              group by ord.srctblname,ord.srctblid 
                          union
                            select ord.srctblname,ord.srctblid from linkcusts ord 
                                inner join linkcusts inst on ord.tblname = inst.srctblname and ord.tblid = inst.srctblid
                                where inst.tblname = 'custacts' and inst.tblid =  #{tbldata["srctblid"]}
                                and (ord.tblname = 'custinsts' or ord.tblname = 'custdlvs') 
                                and ord.srctblname = 'custords'
                              group by ord.srctblname,ord.srctblid 
                          union
                            select ord.srctblname,ord.srctblid from linkcusts ord 
                                inner join (select i.* from linkcusts i 
                                                inner join linkcusts j on i.tblname = j.srctblname and i.tblid = j.srctblid
                                                where j.tblname = 'custacts' and j.tblid =  #{tbldata["srctblid"]}
                                                and j.srctblname = 'custdlvs') inst
                                  on ord.tblname = inst.srctblname and ord.tblid = inst.srctblid
                                where ord.tblname = 'custinsts'   and ord.srctblname = 'custords'
                              group by ord.srctblname,ord.srctblid 
                            &
              end
              prevtblname = tblname.sub("ord","sch")  ###tbldata["srctblname"]--> puracts custacts
              tmp_amt =  tbldata["amt_src"].to_f
              ActiveRecord::Base.connection.select_all(strsql).each do |trnord|
                strsql = %Q&
                      select * from #{prevtblname} where id in(
                                      select tblid from srctbllinks where srctblid = #{trnord["srctblid"]}
                                                  and srctblname = '#{case tblname 
                                                                        when /payords/
                                                                              "purords"
                                                                        when  /billords/
                                                                              "custords"
                                                                        end}' and tblname = '#{prevtblname}'
                                    )
                &
                blk = RorBlkCtl::BlkClass.new("r_#{prevtblname}")
                command_c = blk.command_init
                command_c["sio_classname"] = "_update_from_#{tblname}"
                command_c["#{prevtblname.chop}_person_id_upd"] = tbldata["persons_id_upd"]
                ActiveRecord::Base.connection.select_all(strsql).each do |prevtbldata|
                  command_c["id"] = command_c["#{prevtblname.chop}_id"]= prevtbldata["id"]
                  if tmp_amt <= prevtbldata["amt_sch"].to_f 
                    command_c["#{prevtblname.chop}_amt_sch"] = prevtbldata["amt_sch"].to_f - tmp_amt
                    command_c["#{prevtblname.chop}_tax"] = command_c["#{prevtblname.chop}_amt_sch"] * prevtbldata["taxrate"].to_f / 100
                    tmp_amt -= prevtbldata["amt_sch"].to_f
                  else
                    next
                  end
                  command_c = blk.proc_create_tbldata(command_c) ##
                  blk.proc_private_aud_rec({},command_c)
                end
              end
        end
        return  
  end
end
