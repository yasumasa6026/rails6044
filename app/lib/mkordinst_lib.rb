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
										inner join  r_chrgs person_pare  on  gantt.chrgs_id_pare = person_pare.id 	%   
						add_tbl << add_tbl_pare
					when /ords$/
						add_tbl_pare = %Q$ inner join (select link.srctblid from linktbls link
															inner join #{tblxxx} p   	
																on p.id = link.tblid and link.tblname = '#{tblxxx}' and  link.srctblname like '%schs') sch
												on gantt.paretblid = sch.srctblid 
											inner join  r_chrgs person_pare  on  gantt.chrgs_id_pare = person_pare.id 	
											inner join  itms itm_pare  on  gantt.itm_id_pare = itm_pare.id 
											inner join  shelfnos shelfno_pare  on gantt.shelfnos_id_pare = loca_pare.id $   
				###	else
				###		next
					end	
					strwhere[sel] << "and paretblname = '#{tblxxx}'    "

				when "trn"   ###必須項目	
					add_tbl_trn = %Q%	inner join  itms itm_trn  on  gantt.itms_id_trn = itm_trn.id 
									inner join  shelfnos shelfno_trn  on  gantt.shelfnos_id_trn = shelfno_trn.id 	
									inner join  r_chrgs person_trn  on  gantt.chrgs_id_trn = person_trn.id 	%   
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
						strwhere[sel] << %Q% and gantt.#{field}_#{sel} <= to_date('#{val}','yyyy/mm/dd hh24:mi:ss')  
								%
					when /starttime/						
						strwhere[sel] << %Q% and gantt.#{field}_#{sel} >= to_date('#{val}','yyyy/mm/dd hh24:mi:ss')   
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
						p"MkordinstLib linr #{__LINE__} field:#{field_delm} not support"
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
		ActiveRecord::Base.connection.insert(init_ordorg_strsql(mkprdpurords_id))       ### mkordorgs 親のみ
		###員数に従って必要数を計算
		strsql = %Q&
				select max(pare.mlevel) mlevel,pare.itms_id_pare ,pare.processseq_pare ,pare.prjnos_id,
					max(pare.shelfnos_id_pare) shelfnos_id_pare,max(pare.shelfnos_id_to_pare) shelfnos_id_to_pare,
					pare.mkprdpurords_id_trngantt mkprdpurords_id
				 	from trngantts	pare
					where pare.mkprdpurords_id_trngantt = #{mkprdpurords_id}
					and (pare.qty_sch > 0 or pare.qty > 0)
					group by pare.itms_id_pare,pare.processseq_pare,pare.prjnos_id,
							---pare.shelfnos_id_pare,pare.shelfnos_id_to_pare,
							pare.mkprdpurords_id_trngantt
					having max(pare.mlevel) > 0
					order by max(pare.mlevel),pare.itms_id_pare,pare.processseq_pare,pare.prjnos_id,
							---pare.shelfnos_id_pare,pare.shelfnos_id_to_pare,
							pare.mkprdpurords_id_trngantt
				&
			###opeitm.packqtyに対応
		ActiveRecord::Base.connection.select_all(strsql).each do |handover| ###top以外の全て抽出する。
			ActiveRecord::Base.connection.insert(sum_ord_qty_strsql(handover)) ###schs.qtyから親毎の部品必要数を計算する。
			ActiveRecord::Base.connection.insert(get_ordqty(handover)) ###発注・作業単位にまとめる。
			ActiveRecord::Base.connection.select_all(req_ord_sql(handover)).each do |sumSchs|  ### xxxordsの元schs
					incnt += sumSchs["incnt"].to_f
					inqty += sumSchs["qty_require"].to_f
					### freeの確認
					sumSchs = sch_trn_alloc_to_freetrn(sumSchs)  ###schsをfreeのordsに引き当てる。shselfnosごとに引き当てている。
					# ###
					next if sumSchs["qty_require"].to_f <= 0   ###sumSchs["qty_require"].to_f free　qty引当済
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
					opeitm = {}
					env = ActiveRecord::Base.configurations["#{ENV["RAILS_ENV"]}"]["database"]
					field_check_sql = %Q& select column_name from information_schema.columns
									where 	table_catalog='#{env}' 
									and 	table_name = 'r_#{tblord}s'  and column_name like 'opeitm_%' &
					fields_opeitm = ActiveRecord::Base.connection.select_values(field_check_sql)	
					schRec.each do |key,val|   ###schRec:xxxschs
						case key
						when "id","qty_sch","price","masterprice","tax","taxrate","contractprice"
							next
						when  /sno|cno/  ###sno,cnoはschから引き継がない。
							command_c["#{tblord}_#{key}"] = ""
						when /amt_sch/  ##ordにはamt_schはない。
							if tblord == "purord"
								###command_c["#{tblord}_amt"] = schRec["price"].to_f * command_c[symqty]
								line_data = {:purord_duedate =>  sumSchs["duedate"].strftime("%Y-%m-%d %H:%M:%S"),
											:purord_isudate => Time.now.strftime("%Y-%m-%d %H:%M:%S")}
								strsql = %Q&
										select itm.taxflg from opeitms o 
															inner join itms itm on o.itms_id = itm.id
													where o.id = #{schRec["opeitms_id"]}
								&
								line_data[:itm_taxflg] = ActiveRecord::Base.connection.select_value(strsql)	
								line_data,err = CtlFields.proc_judge_check_taxrate(line_data,"purord_taxrate",0,"r_purords")
								strsql = %Q&
											select locas_id_shelfno from shelfnos where id = #{schRec["shelfnos_id"]}
										&
								command_c["shelfno_loca_id_shelfno"] = line_data[:shelfno_loca_id_shelfno] = ActiveRecord::Base.connection.select_value(strsql)
								line_data[:purord_opeitm_id] = schRec["opeitms_id"]
								line_data[:purord_qty] = command_c[symqty]
								line_data,err = CtlFields.proc_judge_check_supplierprice(line_data,"purord_price",0,"r_purords")
								command_c["purord_price"] = line_data[:purord_price]
								command_c["purord_masterprice"] = line_data[:purord_masterprice] 
								command_c["purord_amt"] = line_data[:purord_amt]  
								command_c["purord_tax"] = line_data[:purord_tax]  
								command_c["purord_taxrate"] = line_data[:purord_taxrate]  
								command_c["purord_contractprice"] = line_data[:purord_contractprice] 
							end
						when /opeitms_id/
							opeitm = ActiveRecord::Base.connection.select_one("select * from opeitms where id = #{val}")
							command_c["#{tblord}_#{key.sub("s_id","_id")}"] = val
							opeitm.each do |opekey,value|
								next if opekey.to_s =~ /_upd|_at/
								next if opekey == "id"
								###postgresql のみ
								if fields_opeitm.find{|n| n == %Q%opeitm_#{opekey.sub("s_id","_id")}%}				
                                	command_c["opeitm_#{opekey.sub("s_id","_id")}"] = value
								end
							end
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
							command_c["#{tblord}_#{key.sub("s_id","_id")}"] = val
						end
					end
					command_c["#{tblord}_gno"] = "" ### 
					command_c["#{tblord}_remark"] = "create by mkord" ### 
					command_c["#{tblord}_id"] = command_c["id"] = ArelCtl.proc_get_nextval("#{tblord}s_seq")
					command_c["sio_classname"] = "_add_proc_mkprdpurord_"
					setParams = {}  ###mkprdpurordsをリセット
					setParams["seqno"] = seqno.dup
					setParams["mkprdpurords_id"] = mkprdpurords_id 
					###
					###  xxxords作成
					###
					command_c["#{tblord}_person_id_upd"] = setParams["person_id_upd"] = params["person_id_upd"]
					command_c["#{tblord}_created_at"] = Time.now
					blk.proc_create_tbldata(command_c)
					setParams = blk.proc_private_aud_rec(setParams,command_c)
					base = {"tblname"=> tblord + "s" ,"tblid" => command_c["id"],
							 "alloctbls_id" => setParams["alloctbl_ids"][0],
							"itms_id"=>sumSchs["itms_id"],"processseq" => sumSchs["processseq"],
							"prjnos_id" => sumSchs["prjnos_id"],"starttime" => command_c["#{tblord}_duedate"] ,
							"shelfnos_id" => command_c["#{tblord}_shelfno_id_to"],
							"persons_id_upd" => setParams["person_id_upd"],
							"qty_sch" => 0,"qty" => command_c["#{tblord}_qty"] ,"qty_stk" => 0,
							"lotno" => "","packno" => "","qty_src" => command_c["#{tblord}_qty"] , "amt_src"=> 0}
					stkinout = Shipment.proc_lotstkhists_in_out("in",base)  ###在庫の更新
					stkinout["persons_id_upd"] = setParams["person_id_upd"]
					stkinout["trngantts_id"] = setParams["gantt"]["trngantts_id"]
                    ope = Operation::OpeClass.new(setParams)  ###xxxschs,xxxords
					ope.proc_update_inoutlot_and_src_stk("in","lotstkhists",stkinout)
					outcnt += 1
					outqty +=  command_c[symqty]
					gantt = setParams["gantt"].dup
					free_qty = command_c[symqty].to_f
					strsql = %Q&
			        	select gantt.id trngantts_id,gantt.*,alloc.id alloctbls_id from trngantts gantt
							inner join alloctbls alloc on gantt.id = alloc.trngantts_id
							inner join shelfnos s on s.id = gantt.shelfnos_id_trn
			            	where gantt.mkprdpurords_id_trngantt = #{mkprdpurords_id}
							and gantt.itms_id_trn = #{sumSchs["itms_id"]} 
							and s.locas_id_shelfno = #{sumSchs["locas_id"]}  ---引当はlocas_id
				        	and gantt.processseq_trn = #{sumSchs["processseq"]} and gantt.shelfnos_id_to_trn = #{sumSchs["shelfnos_id_to"]}
							and alloc.qty_linkto_alloctbl > 0 and alloc.srctblname like '%schs'
						&
					ActiveRecord::Base.connection.select_all(strsql).each do |sch_trn|   ###trngantts.qty_schの変更
						###if free_qty > 0 
							##if free_qty >=sch_trn["qty_sch"].to_f 
								###qty_sch = 0
								### alloc_qty = sch_trn["qty_sch"].to_f
							# 	free_qty -= sch_trn["qty_sch"].to_f
							# else	 
							# 	qty_sch = sch_trn["qty_sch"].to_f - free_qty
							# 	alloc_qty = free_qty
							# 	free_qty = 0
							# end
							stkinout["wh"] = "lotstkhists"
							stkinout["qty_src"] = sch_trn["qty_sch"].to_f
							sch_trn["qty_sch"] = 0
							ArelCtl.proc_add_linktbls_update_alloctbls(sch_trn,stkinout) 
							ArelCtl.proc_src_trn_stk_update(sch_trn,stkinout)
							ArelCtl.proc_base_trn_stk_update(sch_trn,stkinout)
						###else
						###	break
						###end
					end
					ord = ActiveRecord::Base.connection.select_one("select * from #{sumSchs["tblname"]} where id = #{sumSchs["tblid"]}")
					###
					###
					###
					if ord["remark"] =~ /create by mkord/ or sumSchs["qty_stk"].to_f <= 0
						###子部品を持たないfree ordsに引きあった時 
					else
						###子部品を手配済の時
						update_sql = %Q&
										 update mkordorgs set qty_handover = #{qty_handover} where id = #{sumSchs["mkordorgs_id"]}
							 &
						ActiveRecord::Base.connection.update(update_sql)
						pare_trns = []
						pare = {}
						pare["qty_sch"] = qty_handover
						pare["itms_id_trn"] = sumSchs["itms_id"]
						pare["locas_id_trn"] = sumSchs["locas_id"]
						pare["processseq_trn"] = sumSchs["processseq"]
						pare["shelfnos_id_to_trn"] = sumSchs["shelfnos_id_to"]
						pare_trns << pare
						until pare_trns.size == 0
							pare = pare_trns.shift
							strsql = %Q&
								select gantt.id trngantts_id,gantt.*,alloc.id alloctbls_id							
									from trngantts gantt
										inner join alloctbls alloc on gantt.id = alloc.trngantts_id
										where gantt.mkprdpurords_id_trngantt = #{mkprdpurords_id}
											and gantt.itms_id_pare = #{pare["itms_id_trn"]} 
											and gantt.processseq_pare = #{pare["processseq_trn"]} and gantt.shelfnos_id_to_pare = #{pare["shelfnos_id_to_trn"]}
											and alloc.qty_linkto_alloctbl > 0 and alloc.srctblname like '%schs'
								&
							ActiveRecord::Base.connection.select_all(strsql).each do |sch|   ###trngantts.qty_schの変更
								sch["new_qty_sch"] = CtlFields.proc_cal_qty_sch(pare["new_qty_sch"],pare["chilnum"],pare["parenum"],
																		pare["consumunitqty"],pare["consumminqty"],pare["consumchgoverqty"])
								sch["persons_id_upd"] = params["person_id_upd"]
								ArelCtl.proc_update_linktbls_alloctbls_inoutlotstks(sch)
								strsql = %Q&
									update trngantts set qty_sch = #{sch["new_qty_sch"]} ,qty_require = #{sch["new_qty_sch"]} ,
											remark = ' #{self} line:#{__LINE__}'|| remark,	updated_at = current_timestamp  
											where id = #{sch[["trngantts_id"]]}
									& 
								ActiveRecord::Base.connection.update(strsql)
								pare_trns << sch
							end
						end
					end 
			end
		end
		mkordparams[:incnt] = incnt
		mkordparams[:inqty] = inqty
		mkordparams[:outcnt] = outcnt
		mkordparams[:outqty] = outqty
		# ###未処理－－＞最大発注量の分割
		return mkordparams
	end	
	def proc_mkbillinsts params,mkinstparams  ###xxxschsからxxxordsを作成する。 trngantts:xxxschs= 1:1
		### mkprdpurordsではxno_xxxschはセットしない。schsをまとめたり分割したりする機能のため
		setParams = params.dup
		tbldata = params["tbldata"].dup  ###tbldata -->テーブル項目　　viewではない。
		mkbillinsts_id = params["mkbillinsts_id"]   
		strsql = "select ord.bills_id,ord.duedate,max(ord.saledate) max_saledate,min(ord.saledate) min_saledate,
								max(ord.depdate) max_depdate,min(ord.depdate)  min_depdate,
								sum(ord.amt) sum_amt,sum(ord.tax) sum_tax,ord.id ord_id,
								sum(case link.amt_src when null then 0 else link.amt_src end) sum_amt_src,
								count(cast(bills_id as character varying)||to_char(duedate,'yymmdd') incnt from billords ord "
		strjoin = " left join linktbls link on ord.ord_id = link.srctblid "
		strwhere = %Q&  where link.srctblname = "billords" and (link.amt_src is null or ord.amt > link.amt_src )   and &
		strgroupby = " group by bills_id,duedate "
		tbldata.each do |field,val|  ### mkbillinsts
			next if val == "" or val.nil?
			ftype = $ftype[field]   ###$ftype application_controllerで定義
			case field
			when /date/
				moreless = ""
				case field
				when /_fm/
					moreless = " >= "
				when /_to/
					moreless = " <= "
				else	### duedate
					moreless = " = "
				end
				case ftype
				when "date"  
					strwhere << %Q% #{field} #{moreless} to_date('#{val}','yyyy/mm/dd')   and 
								%
				when "timestamp(6)"						
					strwhere << %Q% #{field} #{moreless} to_timestamp('#{val}','yyyy/mm/dd hh24:mi:ss')   and 
								%
				end
			when /sno_billord/
				strwhere << %Q% sno = '#{val}'    and %
			when /custs_id/
				strjoin << %Q%
								inner join (select bill.id bills_id from bills bill
												inner join custs cust on bill.id = cust.bills_id ) custbill
												on ord.bills_id = custbill.bills_id
				%
			when /bills_id/
				strwhere << %Q% bills_id = #{val}    and %
			when /gno_billord/
				strwhere << %Q% gno = '#{val}'    and %
			when /gno/
				tblname = val.split("_")[1] + "s"
				strjoin << %Q%
								inner join (select bill.id bills_id from bills bill
												inner join #{tblname} cust on bill.id = cust.bills_id_#{tblname.chop} ) cust
												on ord.bills_id = cust.bills_id
				%
			end
		end  ###fields.each
		
		
		begin
		strsql = strsql + strjoin + strwhere[0..-7] + strgroupby
		blk =  RorBlkCtl::BlkClass.new("r_#{tblname}")
		command_c =blk.command_init
		command_c["sio_classname"] = "_add_billinst_by_mkbillinsts"
		ActiveRecord::Base.connection.select_all(strsql).each do |inst|
			command_c["billinst_id"] = command_c["id"] = ArelCtl.proc_get_nextval("billinsts_seq")
			command_c["billinst_isudate"] = Time.now 
			command_c["billinst_duedate"] = inst["duedate"] 
			command_c["billinst_bill_id"] = inst["bills_id"] 
			command_c["billinst_amt"] = inst["sum_amt"].to_f  -  inst["sum_amt_src"].to_f 
			command_c["billinst_tax"] = inst["sum_tax"].to_f 
			command_c["billinst_sno"] = inst["duedate"].to_date.year.to_s[2..3] +  sprintf("%6.6d",command_c["id"])
			command_c["billinst_gno"] = "" ### 
			gantt = {}
			gantt["orgtblname"] = gantt["paretblname"] = gantt["tblname"] = "billinsts"
			gantt["orgtblid"] = gantt["paretblid"] =  gantt["tblid"] = command_c["id"]
			setParams["gantt"] = gantt.dup		
			command_c["billinst_person_id_upd"] = setParams["person_id_upd"]
			command_c["id"] = ArelCtl.proc_get_nextval("billinsts_seq")
			command_c["billinst_created_at"] = Time.now
			blk.proc_create_tbldata(command_c)
			blk.proc_private_aud_rec({},command_c)
			###CreateOtherTableRecordJob.perform_later(setParams["seqno"][0])			
			mkinstarams[:incnt] += inst["incnt"].to_f
			mkinstparams[:outcnt] += 1
			billordsql = "select ord.id,ord.amt from billords ord  " +  strjoin + strwhere[0..-7]
			ActiveRecord::Base.connection.select_all(billordsql).each do |billord|
				src = {"trngantts_id" => 0,"tblname" => "billords","tblid" => billord["id"]}
				base = {"tblname"=>"billinsts","tblid"=>command_c["id"],"qty_src" => 0,"amt_src"=>billord["amt_src"],
						"remark" => "#{self} line:#{__LINE__}","persons_id_upd" => gantt["persons_id_upd"]}
				ArelCtl.proc_insert_linktbls(src,base)
			end
		end
		rescue
			ActiveRecord::Base.connection.rollback_db_transaction()
			command_c["sio_result_f"] = "9"  ##9:error
			command_c["sio_message_contents"] =  "class #{self} : LINE #{__LINE__} $!: #{$!} "[0..3999]    ###evar not defined
			command_c["sio_errline"] =  "class #{self} : LINE #{__LINE__} $@: #{$@} "[0..3999]
			Rails.logger.debug"error class #{self} : #{Time.now}: #{$@} "
		  	Rails.logger.debug"error class #{self} : $!: #{$!} "
		  	Rails.logger.debug"  command_c: #{command_c} "
  		else
			ActiveRecord::Base.connection.commit_db_transaction()
			if setParams.size > 0   ###画面からの時はperform_later(setParams["seqno"][0])　seqnoは一つのみ。次の処理がないときはsetParams["seqno"][0].nil
				if setParams["seqno"].size > 0
					if command_c["mkord_runtime"] 
						CreateOtherTableRecordJob.set(wait: command_c["mkord_runtime"].to_f.hours).perform_later(setParams["seqno"][0])
					else	
						CreateOtherTableRecordJob.perform_later(setParams["seqno"][0])
					end
				end
			end	
  		end ##begin
		# ###未処理－－＞最大発注量の分割
		return mkordparams
	end	

	def sch_trn_alloc_to_freetrn(sumSchs)   ###xxxschsをまとめて消費量を決めているので
	 	###freeを探す　
	 	required_sch_qty = sumSchs["qty_require"].to_f
	 	alloc_qty = 0
	 	alloc_qty_stk = 0
		free_qty = 0
		base = {}
		###freeのxxxordsは子部品を既に手配済が条件
		strsql = %Q&select * from func_get_free_ord_stk('#{sumSchs["duedate"]}',#{sumSchs["prjnos_id"] },#{sumSchs["itms_id"]},#{sumSchs["processseq"]})&
	 	ActiveRecord::Base.connection.select_all(strsql).each do |free|   ### 
			base = free.dup
	 		base["amt_src"] = 0
	 		base["qty_src"] = free_qty = free["qty_linkto_alloctbl"].to_f
			base["wh"] = "lotstkhists"
			strsql = %Q&select srctblid from inoutlotstks 
						where tblname = '#{free["tblname"]}' and tblid = #{free["tblid"]}
						and trngantts_id = #{free["trngantts_id"]} and srctblname = 'lotstkhists'  &
			base["srctblid"] = ActiveRecord::Base.connection.select_value(strsql)
			ActiveRecord::Base.connection.select_all(sch_trn_strsql(sumSchs)).each do |sch_trn|
				if free_qty >  sch_trn["qty_sch"].to_f ###	個別にひきあてるのでfreeは過剰に消費される
					base["qty_src"] =  sch_trn["qty_sch"].to_f
					free_qty -= sch_trn["qty_sch"].to_f
					sch_trn["qty_sch"]  = 0
				else
					sch_trn["qty_sch"] = sch_trn["qty_sch"].to_f - free_qty 
					base["qty_src"] =  free_qty
					free_qty = 0
				end

				base["wh"] = "lotstkhists"
				ArelCtl.proc_add_linktbls_update_alloctbls(sch_trn,base)
				ArelCtl.proc_src_trn_stk_update(sch_trn,base)
				required_sch_qty -= base["qty_src"]
				ArelCtl.proc_base_trn_stk_update(sch_trn,base)
				break if free_qty <= 0
			end
			break if required_sch_qty <= 0
	 	end
		###引当在庫の修正
		sumSchs["qty_require"] = required_sch_qty
	 	return sumSchs
	end	
	
	
	def set_mkprdpurords_id_in_trngantts_strsql(add_tbl,strwhere,mkprdpurords_id)   ##alocctblのxxxschsは一件のみ
		%Q&
		update trngantts bgantt set mkprdpurords_id_trngantt = #{mkprdpurords_id},
				remark = ' #{self} line:#{__LINE__}'|| remark,
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

	
	def select_schs_from_mkprdpurords_by_pare(add_tbl_pare,strwhere,handover)   ##alocctblのxxxschsは一件のみ
		%Q&
			select  1	from trngantts gantt #{add_tbl_pare} --- 親の属性による選択mkord_term
										where mkprdpurords_id_trngantt = #{handover["mkprdpurords_id"]}
											and gantt.itms_id_pare = #{handover["itms_id_pare"]} 
											and gantt.processseq_pare = #{handover["processseq_pare"]} 
											and gantt.shelfnos_id_pare = #{handover["shelfnos_id_pare"]} 
											and gantt.shelfnos_id_to_pare = #{handover["shelfnos_id_to_pare"]} 
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


	def mkord_term mkprdpurords_id
		%Q&	
			insert into mkordterms(id,prjnos_id,
				mlevel, itms_id,processseq,locas_id,
							shelfnos_id,shelfnos_id_to,
							duedate,optfixodate,persons_id_upd,created_at,updated_at,
							mkprdpurords_id)	
			select nextval('mkordterms_seq'),prjnos_id ,
				max(gantt.mlevel), gantt.itms_id_trn,gantt.processseq_trn,s.locas_id_shelfno,
				gantt.shelfnos_id_trn,gantt.shelfnos_id_to_trn,
				min(gantt.duedate_trn) duedate,
				case max(opeitm.optfixoterm)
				when 0 then
					cast('2099/12/31 23:59:59' as timestamp)
				else
					(cast(min(gantt.duedate_trn) as date) + cast(max(opeitm.optfixoterm) as integer)) 
				end optfixodate,0,current_date,current_date,
				#{mkprdpurords_id}  ---xxx
			from trngantts gantt
			inner join opeitms opeitm on gantt.itms_id_trn = opeitm.itms_id
				and gantt.processseq_trn = opeitm.processseq
				and gantt.shelfnos_id_trn = opeitm.shelfnos_id_opeitm 
			inner join shelfnos s on s.id = gantt.shelfnos_id_trn
			where mkprdpurords_id_trngantt = #{mkprdpurords_id}  ---xxx
			group by gantt.prjnos_id,gantt.itms_id_trn,gantt.processseq_trn,
						gantt.shelfnos_id_trn,gantt.shelfnos_id_to_trn,s.locas_id_shelfno
		&
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
								tblname,tblid,incnt,
								expiredate,created_at,updated_at)
				select nextval('mkordtmpfs_seq'),0 persons_id_upd, 
						gantt.mkprdpurords_id_trngantt ,'1' mlevel,gantt.itms_id_trn itms_id_trn, gantt.itms_id_pare itms_id_pare,
						gantt.processseq_trn,gantt.processseq_pare ,s.locas_id_shelfno locas_id_trn,
						gantt.prjnos_id ,
						gantt.shelfnos_id_to_trn ,gantt.shelfnos_id_trn,
						max(gantt.shelfnos_id_pare) shelfnos_id_pare,
						max(gantt.shelfnos_id_to_pare) shelfnos_id_to_pare,
						sum(gantt.qty_sch) qty_sch,sum(gantt.qty) qty,sum(gantt.qty_stk) qty_stk,
						min(gantt.duedate_trn),	max(gantt.toduedate_trn),	min(gantt.starttime_trn),
						1 packqty,
						max(gantt.consumchgoverqty),max(gantt.consumminqty),
						max(gantt.consumunitqty) consumunitqty,
						1 parenum,1 chilnum,
						sum(gantt.qty_handover) qty_handover,sum(gantt.qty_require) qty_require,
						max(gantt.tblname) tblname,min(gantt.tblid) tblid,count(tblid),
						'2099/12/31',current_date,current_date 
						from trngantts gantt 
						inner join mkordterms term on gantt.itms_id_trn = term.itms_id  and gantt.processseq_trn = term.processseq 
													and gantt.prjnos_id = term.prjnos_id  
													and gantt.mkprdpurords_id_trngantt = term.mkprdpurords_id and gantt.shelfnos_id_to_trn = term.shelfnos_id_to 
						inner join shelfnos s on s.id = gantt.shelfnos_id_trn
						where  gantt.mkprdpurords_id_trngantt = #{mkprdpurords_id} ---xxx
							and gantt.duedate_trn >= term.duedate and gantt.duedate_trn < term.optfixodate
						group by gantt.mkprdpurords_id_trngantt ,
							gantt.itms_id_trn,gantt.processseq_trn ,gantt.itms_id_pare,gantt.processseq_pare ,gantt.prjnos_id,
							s.locas_id_shelfno,gantt.shelfnos_id_to_trn,gantt.shelfnos_id_trn
							having max(gantt.mlevel) = '1'
				&
	end	
	
	def init_ordorg_strsql mkprdpurords_id
		%Q&
		insert into mkordorgs(id,persons_id_upd,
			mkprdpurords_id,mlevel,itms_id,
	   		processseq,locas_id,shelfnos_id,
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
			gantt.processseq_trn processseq,gantt.locas_id_trn locas_id,gantt.shelfnos_id_trn,
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
			'2099/12/31',current_date,current_date 
			from mkordtmpfs gantt 
			inner join mkordterms term on gantt.itms_id_trn = term.itms_id  and gantt.processseq_trn = term.processseq 
						   and gantt.locas_id_trn = term.locas_id and gantt.prjnos_id = term.prjnos_id  
						   and gantt.mkprdpurords_id = term.mkprdpurords_id 
						   and gantt.shelfnos_id_trn = term.shelfnos_id and gantt.shelfnos_id_to_trn = term.shelfnos_id_to 
			where   gantt.mkprdpurords_id = #{mkprdpurords_id} ---xxx
   				and gantt.duedate >= term.duedate and gantt.duedate < term.optfixodate  --- gantt.duedate:ok
			group by gantt.mkprdpurords_id,
				gantt.itms_id_trn,gantt.processseq_trn ,
				gantt.prjnos_id,gantt.shelfnos_id_to_trn,gantt.shelfnos_id_trn,gantt.locas_id_trn 
   				having max(gantt.mlevel) = 1
				&
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
						gantt.mkprdpurords_id_trngantt ,max(gantt.mlevel) mlevel,gantt.itms_id_trn itms_id, gantt.itms_id_pare,
						gantt.processseq_trn,gantt.processseq_pare ,s.locas_id_shelfno ,
						gantt.prjnos_id ,
						gantt.shelfnos_id_to_trn ,gantt.shelfnos_id_trn,
						(gantt.shelfnos_id_pare) shelfnos_id_pare,max(gantt.shelfnos_id_to_pare) shelfnos_id_to_pare,
						sum(gantt.qty_sch) qty_sch,sum(gantt.qty) qty,sum(gantt.qty_stk) qty_stk,
						min(gantt.duedate_trn) duedate,	min(gantt.toduedate_trn) toduedate,	min(gantt.starttime_trn) starttime,
						max(opeitm.packqty)  packqty,
						max(gantt.consumchgoverqty) consumchgoverqty,max(gantt.consumminqty) consumminqty,
						max(gantt.consumunitqty)  consumunitqty,
						gantt.parenum,gantt.chilnum,
						trunc((max(tmp.qty_handover) * gantt.chilnum / gantt.parenum) / max(gantt.consumunitqty) + 0.99999) * max(gantt.consumunitqty) + max(gantt.consumchgoverqty),
						trunc((max(tmp.qty_handover) * gantt.chilnum / gantt.parenum) / max(gantt.consumunitqty) + 0.99999) * max(gantt.consumunitqty) + max(gantt.consumchgoverqty),
						max(gantt.tblname) tblname,min(gantt.tblid) tblid,count(gantt.tblid),
						'2099/12/31',current_date,current_date 
						from trngantts gantt 
						inner join opeitms opeitm on gantt.itms_id_trn = opeitm.itms_id  and gantt.processseq_trn = opeitm.processseq 
													and gantt.shelfnos_id_trn = opeitm.shelfnos_id_opeitm  
						inner join mkordterms term on gantt.itms_id_pare = term.itms_id  and gantt.processseq_pare = term.processseq 
													and gantt.shelfnos_id_pare = term.shelfnos_id and gantt.shelfnos_id_to_pare = term.shelfnos_id_to 
													and gantt.prjnos_id = term.prjnos_id  
													and gantt.mkprdpurords_id_trngantt = term.mkprdpurords_id  
						inner join mkordorgs tmp on   gantt.prjnos_id = tmp.prjnos_id 	and gantt.mkprdpurords_id_trngantt = tmp.mkprdpurords_id 
														and gantt.itms_id_pare = tmp.itms_id and gantt.processseq_pare = tmp.processseq
														and gantt.shelfnos_id_pare = tmp.shelfnos_id and gantt.shelfnos_id_to_pare = tmp.shelfnos_id_to
						inner join shelfnos s on s.id = gantt.shelfnos_id_trn 
						where  gantt.mlevel > '1' and gantt.mkprdpurords_id_trngantt = #{handover["mkprdpurords_id"]} ---xxx
							and gantt.duedate_pare >= term.duedate and gantt.duedate_pare < term.optfixodate
							and tmp.itms_id = #{handover["itms_id_pare"]} and tmp.processseq = #{handover["processseq_pare"]}  
							---and tmp.shelfnos_id = #{handover["shelfnos_id_pare"]} 
							---and tmp.shelfnos_id_to	= #{handover["shelfnos_id_to_pare"]}	
							and (opeitm.prdpurordauto != 'M' or opeitm.prdpurordauto is null)	---prdords,purordsの自動作成はしない。
						group by gantt.mkprdpurords_id_trngantt ,gantt.itms_id_pare,gantt.processseq_pare ,
							gantt.shelfnos_id_pare,  
		 					gantt.itms_id_trn,gantt.processseq_trn ,s.locas_id_shelfno ,gantt.parenum,gantt.chilnum,
		 					gantt.prjnos_id,gantt.shelfnos_id_to_trn   ,gantt.shelfnos_id_trn
				&
	end			
	
	def get_ordqty(handover)
		%Q&
			insert into mkordorgs (
					id,mlevel    , 
					itms_id  ,locas_id,processseq,prjnos_id,shelfnos_id,shelfnos_id_to,
					consumminqty , consumchgoverqty ,consumunitqty,
					packqty ,
					starttime ,duedate , toduedate ,
					qty_sch , qty ,qty_stk,
					qty_require ,
					qty_handover ,
		 			tblname , tblid ,
					remark  ,contents ,
					expiredate  , update_ip ,
					created_at   , updated_at   ,
					persons_id_upd ,
					incnt,mkprdpurords_id )
			select  nextval('mkordorgs_seq') id,max(tmp.mlevel) mlevel,
					tmp.itms_id_trn,tmp.locas_id_trn,tmp.processseq_trn,tmp.prjnos_id,tmp.shelfnos_id_trn,tmp.shelfnos_id_to_trn,
					max(tmp.consumminqty) consumminqty, max(tmp.consumchgoverqty) consumchgoverqty,max(tmp.consumunitqty) consumunitqty,
					max(tmp.packqty) packqty,
			   		min(tmp.starttime) starttime,tmp.duedate,min(tmp.toduedate) toduedate,
			   		sum(tmp.qty_sch) qty_sch, sum(tmp.qty) qty,sum(tmp.qty_stk) qty_stk,
			   		(sum(tmp.qty_require) - sum(tmp.qty) - sum(tmp.qty_stk)) qty_require,   ---既に発注済or完成済
			   		trunc((sum(tmp.qty_require) - sum(tmp.qty_stk))/max(tmp.packqty) + 0.99999) * max(tmp.packqty)  qty_handover,  ---既に完成済
			   		max(tmp.tblname),min(tmp.tblid),
			   		'' remark,'' contents,
			   		'2099/12/31' expiredate,'' updated_ip,
			   		current_date created_at,current_date updated_at,
			   		0 persons_id_upd,
			   		sum(incnt) incnt,	#{handover["mkprdpurords_id"]} mkprdpurords_id
			   	from mkordtmpfs tmp
			   		where tmp.mkprdpurords_id = #{handover["mkprdpurords_id"]} and tmp.mlevel > '1'
			   			and tmp.itms_id_pare = #{handover["itms_id_pare"]} and tmp.processseq_pare = #{handover["processseq_pare"]}  
			   			---and tmp.shelfnos_id_pare = #{handover["shelfnos_id_pare"]}   --- and  tmp.shelfnos_id_to_pare = #{handover["shelfnos_id_to_pare"]} 
			   			and tmp.prjnos_id = #{handover["prjnos_id"]}
					group by  tmp.itms_id_trn,tmp.locas_id_trn,tmp.processseq_trn,tmp.prjnos_id,tmp.shelfnos_id_trn,tmp.shelfnos_id_to_trn,tmp.duedate
		&
	end

	 
	def req_ord_sql(handover) 
			%Q&
					select  tmp.itms_id_trn itms_id,tmp.shelfnos_id_trn shelfnos_id,tmp.locas_id_trn locas_id,
							tmp.processseq_trn processseq,tmp.prjnos_id,tmp.shelfnos_id_to_trn shelfnos_id_to,
							tmp.duedate,max(tmp.packqty) packqty,
							max(tmp.tblname) tblname,max(tmp.tblid) tblid,tmp.mkprdpurords_id ,min(tmp.starttime) starttime,
							max(tmp.qty_require) qty_require,max(tmp.qty_handover) qty_handover,max(tmp.consumminqty) consumminqty,
							max(ordorg.id) mkordorgs_id,min(tmp.toduedate) toduedate,max(tmp.consumchgoverqty) consumchgoverqty,
							sum(tmp.incnt) incnt
					   from mkordtmpfs tmp
					inner join  mkordorgs ordorg on tmp.itms_id_trn = ordorg.itms_id and tmp.shelfnos_id_trn = ordorg.shelfnos_id and 
								tmp.processseq_trn = ordorg.processseq and tmp.prjnos_id = ordorg.prjnos_id and
								tmp.shelfnos_id_to_trn = ordorg.shelfnos_id_to and tmp.mkprdpurords_id = ordorg.mkprdpurords_id 
					   where tmp.mkprdpurords_id = #{handover["mkprdpurords_id"]}
						   and tmp.itms_id_pare = #{handover["itms_id_pare"]} and tmp.processseq_pare = #{handover["processseq_pare"]}  
						   ---and tmp.shelfnos_id_pare = #{handover["shelfnos_id_pare"]} and tmp.shelfnos_id_to_pare = #{handover["shelfnos_id_to_pare"]} 
						and tmp.prjnos_id = #{handover["prjnos_id"]}
						and tmp.qty_sch > 0  --- ord手配済は対象外
						group by  tmp.itms_id_trn,tmp.shelfnos_id_trn,tmp.locas_id_trn, tmp.processseq_trn,tmp.prjnos_id,
									tmp.shelfnos_id_to_trn,tmp.duedate,tmp.mkprdpurords_id 
					&
	end

	def	sch_trn_strsql(sumSchs) 
		 %Q&   ---sumSchsから個別のqty_schをもとめる。
		   select gantt.id trngantts_id, 
				   gantt.tblname,gantt.tblid,gantt.mkprdpurords_id_trngantt,alloc.qty_linkto_alloctbl qty_sch,gantt.qty,gantt.qty_stk,
					gantt.qty_require,gantt.qty_handover, 
					gantt.duedate_trn duedate,gantt.toduedate_trn,gantt.starttime_trn starttime,
					s.locas_id_shelfno locas_id,gantt.itms_id_trn itms_id,gantt.processseq_trn processseq,
				   gantt.shelfnos_id_to_trn shelfnos_id,gantt.prjnos_id,'' lotno,''packno,
				   alloc.id alloctbls_id   ---alloctbls.qty_linkto_alloctbl == gantt.qty_sch when tblname == pur,prdschs
				from trngantts gantt
				inner join shelfnos s on s.id = gantt.shelfnos_id_trn
			   	inner join alloctbls alloc on alloc.trngantts_id = gantt.id
					where gantt.mkprdpurords_id_trngantt = #{sumSchs["mkprdpurords_id"]} 
				   and gantt.itms_id_trn = #{sumSchs["itms_id"]} and gantt.processseq_trn = #{sumSchs["processseq"]}  
					and s.locas_id_shelfno = #{sumSchs["locas_id"]} and gantt.prjnos_id = #{sumSchs["prjnos_id"]}
					and gantt.shelfnos_id_to_trn = #{sumSchs["shelfnos_id_to"]} 
					and gantt.qty_sch > 0 and alloc.srctblname like '%schs'
					order by  (gantt.duedate_trn)
		&	
	end
end
