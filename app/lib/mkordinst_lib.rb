# -*- coding: utf-8 -*-
# mkordlib
# 2099/12/31を修正する時は　2100/01/01の修正も
module MkordinstLib
	extend self
	###mkordparams-->schsからordsを作成した結果
	def proc_mkprdpurords reqparams,mkordparams  ###xxxschsからxxxordsを作成する。 trngantts:xxxschs= 1:1
		### mkprdpurordsではxno_xxxschはセットしない。schsをまとめたり分割したりする機能のため
		setParams = reqparams.dup
		tbldata = reqparams["tbldata"].dup  ###tbldata -->テーブル項目　　viewではない。
		mkprdpurords_id = reqparams["mkprdpurords_id"]   
		seqno = reqparams["seqno"].dup   
		add_tbl = "" 
		add_tbl_org = ""   ###topから必要数を計算するときの必要数抽出用
		add_tbl_pare = ""    ###topから必要数を計算するときの必要数抽出用
		strwhere = {"org"=>"","pare"=>"","trn"=>""} 
		tblxxx = ""
		command_c = nil
		["org","pare","trn"].each do |sel|  ###抽出条件のsql作成
			case sel
				when "org"
					next if tbldata["orgtblname"] == "" or tbldata["orgtblname"].nil? or tbldata["orgtblname"] == "dummy"
					tblxxx = tbldata["orgtblname"]		
					add_tbl_org = %Q%	inner join  #{tblxxx} org  on  gantt.orgtblid = org.id 	
										inner join  itms itm_org  on  gantt.itms_id_org = itm_org.id 
										inner join  locas loca_org  on  gantt.locas_id_org = loca_org.id 	
										inner join  r_chrgs person_org  on  gantt.chrgs_id_org = person_org.id 	%   
					add_tbl << add_tbl_org
					strwhere[sel] << "orgtblname = '#{tblxxx}'     and"
				when "pare"
					next if tbldata["paretblname"] == "" or tbldata["paretblname"].nil? or tbldata["paretblname"] == "dummy"
					tblxxx = tbldata["paretblname"]		
					add_tbl_pare = %Q%	inner join  #{tblxxx} pare  on  gantt.paretblid = pare.id 	
										inner join  itms itm_pare  on  gantt.itms_id_pare = itm_pare.id 
										inner join  locas loca_pare  on  gantt.locas_id_pare = loca_pare.id 	
										inner join  r_chrgs person_pare  on  gantt.chrgs_id_pare = person_pare.id 	%   
					add_tbl << add_tbl_pare
					strwhere[sel] << "paretblname = '#{tblxxx}'     and"

				when "trn"   ###必須項目	
					add_tbl = %Q%	inner join  itms itm_trn  on  gantt.itms_id_trn = itm_trn.id 
									inner join  locas loca_trn on  gantt.locas_id_trn = loca_trn.id 	
									inner join  r_chrgs person_trn  on  gantt.chrgs_id_trn = person_trn.id 	%   
					case tbldata["tblname"] 
					when 	"all"	  ###pur,prd両方抽出
						strwhere[sel] << " gantt.tblname in ('purschs','prdschs')      and"
						add_tbl << " left join  prdschs prd  on  gantt.tblid = prd.id "
						add_tbl << " left join purschs pur  on  gantt.tblid = pur.id "
					when "prdords"		
						strwhere[sel] << " gantt.tblname = 'prdschs'      and"
						add_tbl << " inner join  prdschs prd  on  gantt.tblid = prd.id "
					when "purords"
						strwhere[sel] << " gantt.tblname = 'purschs'      and"
						add_tbl << " inner join  purschs pur  on  gantt.tblid = pur.id "
					end
				else
					next	
			end

			tbldata.each do |field_delm,val|  ###field-->r_purxxxs,r_prdxxxsのfield  delm-->org,pare,trn
				next if field_delm =~ /_id/ ###画面から入力された項目のみが対象
				next if val == "" or val.nil? or val == "dummy"
				if field_delm =~ /_#{sel}/  ###sel:[org,pare,trn]のどれか
					field = field_delm.sub(/_#{sel}/,"")
					tag = field_delm.split("_")[0] + "_" + sel  ###field.split("_")[0]  --> [itm,loca,person,sno]のどれか
					case  field
					when /itm_code|loca_code/  ###itms
						strwhere[sel] << %Q% #{tag}.code  = '#{val}'   and
							%
					when /person_code_chrg/  ###r_chrgs
						strwhere[sel] << %Q% #{tag}.person_code_chrg  = '#{val}'   and
							%
					when /processseq/  ###
						if val > "0"
						    strwhere[sel] << %Q% gantt.processseq_#{sel} = '#{val}'   and
								%
						end		
					when /duedate/						
						strwhere[sel] << %Q% gantt.#{field}_#{sel} <= to_date('#{val}','yyyy/mm/dd hh24:mi:ss')   and
								%
					when /starttime/						
						strwhere[sel] << %Q% gantt.#{field}_#{sel} >= to_date('#{val}','yyyy/mm/dd hh24:mi:ss')   and
								%
					when /sno/					
						strwhere[sel] << %Q% org.sno = '#{val}'    and
								%
					else
						p"MkordinstLib linr #{__LINE__} field:#{field_delm} not support"
					end
				end	  ### case
			end  ###fields.each
		end   ### ["_org","_pare","_trn"].each do |tbl|

		###ordsは prjnos_id,itms_id,processseq,locas_id(作業場所、発注先),shelfnos_id_to(完成後、受入後)の保管場所毎に作成
		###対象データの特定
		ActiveRecord::Base.connection.update(init_set_mkprdpurords_id_strsql(add_tbl,strwhere,mkprdpurords_id))
		###上記対象データの中で期間がある品目の選定opeitm.optfixoterm
		ActiveRecord::Base.connection.insert(mkord_term(mkprdpurords_id))
		###員数に従って必要数を計算 
		ActiveRecord::Base.connection.insert(sum_ord_qty_strsql(mkprdpurords_id)) 
		strsql = %Q&
				select mlevel,itms_id_pare,processseq_pare,locas_id_pare,prjnos_id,shelfnos_id_to_pare,mkprdpurords_id
				 from
						(select max(mlevel) mlevel,itms_id_pare,processseq_pare,locas_id_pare,prjnos_id,shelfnos_id_to_pare,
								mkprdpurords_id
								from mkordtmpfs
								where mkprdpurords_id = #{mkprdpurords_id}
									#{case tbldata["tblname"] 
									when 	"all"	  ###pur,prd両方抽出
										""
									when "prdords"
										" and tblname = 'prdschs' "
									when "purords"
										" and tblname = 'purschs' "
									end}
								group by itms_id_pare,processseq_pare,locas_id_pare,prjnos_id,shelfnos_id_to_pare,
										mkprdpurords_id) ord
					order by mlevel,itms_id_pare,processseq_pare,locas_id_pare,prjnos_id,shelfnos_id_to_pare
				&
			###opeitm.packqtyに対応
		ActiveRecord::Base.connection.select_all(strsql).each do |handover|
			ActiveRecord::Base.connection.update(cal_ord_qty_strsql(handover,mkprdpurords_id))
			ActiveRecord::Base.connection.select_all(ordorg_strsql(handover)).each do |sumSchs|  ### xxxords作成
					### freeの確認
					sumSchs = schtrn_alloc_to_freetrn(sumSchs)
					next if sumSchs["qty_require"].to_f <= 0
					schRec = ActiveRecord::Base.connection.select_one(%Q& select * from #{sumSchs["tblname"]} where id = #{sumSchs["tblid"]}&)
					tblord = sumSchs["tblname"].sub("schs","ord")
					blk =  RorBlkCtl::BlkClass.new("r_#{tblord}s")
					command_c = blk.command_init
					symqty = tblord + "_qty"
					command_c[:sio_classname] = "_add_ord_by_mkordinst"
					opeitm = {}
					field_check_sql = " select column_name from information_schema.columns
									where 	table_catalog='#{ActiveRecord::Base.configurations["development"]["database"]}' 
									and 	table_name = 'r_#{tblord}s' and column_name like 'opeitm_%'"
					fields_opeitm = ActiveRecord::Base.connection.select_values(field_check_sql)	
					schRec.each do |key,val|   ###schRec:xxxschs
						case key
						when "id"
							next
						when  /qty_sch$/  ###ordsにはqty_schはない screenfields未使用
							###最低少量、段取り使用数は過剰にとっている。過剰にしないためには次工程の使用量を先に決める。
							command_c[symqty] = sumSchs["qty_handover"].to_f
						when  /sno|cno/  ###sno,cnoはschから引き継がない。
							command_c["#{tblord}_#{key}"] = ""
						when /amt_sch/  ##ordにはamt_schはない。
							if tblord == "purord"
								command_c["#{tblord}_amt"] = schRec["price"].to_f * command_c[symqty]
							end
						when /crrs_id/  ##purschsには _crrs_id_purschはない。
							if tblord == "purord"
								command_c["purord_crr_id"] = val
							else
								command_c["#{tblord}_#{key.sub("s_id","_id")}"] = val
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
						when /duedate|starttime/
							command_c["#{tblord}_#{key}"] = sumSchs[key].strftime("%Y-%m-%d %H:%M:%S")
						else	 ###xxxschsとxxxordsと項目は同一が原則　　payments_id_purord
							command_c["#{tblord}_#{key.sub("s_id","_id")}"] = val
						end
					end
					command_c["#{tblord}_gno"] = "" ### 
					command_c["#{tblord}_id"] = command_c["id"] = ArelCtl.proc_get_nextval("#{tblord}s_seq")
					command_c[:sio_classname] = "_add_proc_mkprdpurord_"
					setParams = {}  ###mkprdpurordsをリセット
					setParams["seqno"] = seqno.dup
					setParams["mkprdpurords_id"] = mkprdpurords_id 
					###
					###  xxxords作成
					###
					blk.proc_create_src_tbl(command_c)
					setParams = blk.proc_private_aud_rec(setParams,command_c)
					prdpur_tbldata = setParams["tbldata"].dup
					gantt = setParams["gantt"].dup
					# if gantt["key"] == "00000" and gantt["orgtblid"] != gantt["tblid"]
					# 	raise
					# end
					# mkordparams[:incnt] += sumSchs["incnt"].to_f
					# mkordparams[:inqty] += sumSchs["qty_sch"].to_f  ###schsのpackqtyでまとめられた数
					# mkordparams[:outcnt] += 1
					# mkordparams[:outqty] +=  command_c[symqty]  ###通常 mkordparams[:outqty] <= mkordparams[:inqty]
					# gantt["qty_require"] = sumSchs["qty_require"].to_f
					# gantt["qty_free"] = command_c[symqty] - gantt["qty_require"] 
					# gantt["qty_handover"] =  0  ### mkordinstsで作成されたxxxordsの子部品は手配しない。元のtrnganttsで要求済 
					# gantt["remark"] = " Mkprdpurords line:#{__LINE__} "
					# if gantt["key"] == "00000" and gantt["orgtblid"] != gantt["tblid"]
					# 	raise
					# end
					# ArelCtl.proc_insert_trngantts(gantt)
					# ###free のalloctbls
					# alloctbl = {"tblname" => tblord + "s","tblid" => command_c["id"],"trngantts_id" => gantt["trngantts_id"],
			        #     "qty_sch" => 0,"qty" => command_c[symqty],"qty_stk" => 0,
					#     "qty_linkto_alloctbl" => gantt["qty_require"],"remark" => "Mkordinst_lib line:#{__LINE__} ",
					#     "allocfree" => if gantt["qty_free"] > 0 then "free" else "alloc" end }
					# ArelCtl.proc_insert_alloctbls(alloctbl)
					###元のxxxschs trngantts
					qty = command_c[symqty]
					strsql = %Q&
			        	select gantt.id trngantts_id,* from trngantts gantt
			            	where gantt.mkprdpurords_id_trngantt = #{mkprdpurords_id}
							and gantt.itms_id_trn = #{sumSchs["itms_id"]} and gantt.locas_id_trn = #{sumSchs["locas_id"]}
				        	and gantt.processseq_trn = #{sumSchs["processseq"]} and gantt.shelfnos_id_to = #{sumSchs["shelfnos_id_to"]}
						&
					ActiveRecord::Base.connection.select_all(strsql).each do |schtrn|   ###trngantts.qty_schの変更
						if qty > 0
							if qty >=schtrn["qty_sch"].to_f 
								qty_sch = 0
								gantt_qty = schtrn["qty_sch"].to_f
							else	 
								qty_sch = schtrn["qty_sch"].to_f - qty
								gantt_qty = qty
							end
							update_strsql = %Q&
							update trngantts set qty_sch = #{qty_sch},qty = qty + #{gantt_qty},
												remark = 'MkordinstLib line:#{__LINE__}' 
								where id = #{schtrn["trngantts_id"]}   --- schsのtrngantts_id
							&		
							ActiveRecord::Base.connection.update(update_strsql)
							alloctbl = {"tblname" => tblord + "s","tblid" => command_c["id"],"trngantts_id" => schtrn["trngantts_id"],
			            				"qty_sch" => 0,"qty" => gantt_qty,"qty_stk" => 0,
					    				"qty_linkto_alloctbl" => 0,"remark" => "Mkordinst_lib line:#{__LINE__} ",
					    				"allocfree" => "alloc" }
							ArelCtl.proc_insert_alloctbls(alloctbl)
							update_src_alloc = %Q&
								update alloctbls set  qty_linkto_alloctbl = qty_linkto_alloctbl + #{gantt_qty},
									updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
									remark = 'MkordinstLib line #{__LINE__}'
									where trngantts_id = #{schtrn["trngantts_id"]}
									and srctblname ='#{schtrn["tblname"]}' and srctblid ='#{schtrn["tblid"]}' 
							&
							ActiveRecord::Base.connection.update(update_src_alloc)

							src = {"tblname" => schtrn["tblname"],"tblid" => schtrn["tblid"],"trngantts_id" => schtrn["trngantts_id"]}
							base = {"tblname" => gantt["tblname"],"tblid" => gantt["tblid"],"qty_src" => gantt_qty,"amt_src" => 0 }
							ArelCtl.proc_insert_linktbls(src,base)

							schrec = ActiveRecord::Base.connection.select_one(%Q&select * from #{schtrn["tblname"]} where id = #{schtrn["tblid"]}&)
							stkinout = {"itms_id" => schtrn["itms_id_trn"] , "processseq" => schtrn["processseq_trn"] ,											  
										"shelfnos_id" => schtrn["shelfnos_id_to"],"shelfnos_id_real" => schtrn["shelfnos_id_to"],
										"prjnos_id" => schtrn["prjnos_id"],"starttime" => schtrn["duedate_trn"],
										"packno" => schrec["packno"] ,"lotno" => schrec["lotno"],"remark" => "proc_mkprdpurords",
										"qty_sch" => gantt_qty,"qty" => gantt_qty,"qty_stk" => 0}
							Shipment.proc_lotstkhists_in_out("out",stkinout)
							qty -= gantt_qty
						else
							break
						end
					end
				end
			end
		# ###未処理－－＞最大発注量の分割
		return mkordparams
	end	
	
	def init_set_mkprdpurords_id_strsql(add_tbl,strwhere,mkprdpurords_id)   ##alocctblのxxxschsは一件のみ
		%Q&
		update trngantts bgantt set mkprdpurords_id_trngantt = #{mkprdpurords_id}
				from (select gantt.orgtblid 
										from trngantts gantt #{add_tbl}
										inner join alloctbls alloc on gantt.id = alloc.trngantts_id
										where #{strwhere["org"]} #{strwhere["pare"]} #{strwhere["trn"]}
											alloc.qty_sch > qty_linkto_alloctbl and gantt.qty_sch > 0
										group by gantt.orgtblid
					) target
				where 	bgantt.orgtblid = target.orgtblid     
			&
	end

	def mkord_term mkprdpurords_id
		%Q&	
			insert into mkordterms(id,prjnos_id,
				mlevel, itms_id,processseq,locas_id,shelfnos_id_to,
							duedate,optfixodate,persons_id_upd,created_at,updated_at,
							mkprdpurords_id)	
			select nextval('mkordterms_seq'),prjnos_id ,
				max(gantt.mlevel), gantt.itms_id_trn,gantt.processseq_trn,gantt.locas_id_trn,gantt.shelfnos_id_to,
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
				and gantt.locas_id_trn = opeitm.locas_id_opeitm 
			where mkprdpurords_id_trngantt = #{mkprdpurords_id}  ---xxx
			group by gantt.prjnos_id,gantt.itms_id_trn,gantt.processseq_trn,gantt.locas_id_trn,gantt.shelfnos_id_to
		&
	end	
	
	def sum_ord_qty_strsql mkprdpurords_id
		%Q&
	 	insert into mkordtmpfs(id,persons_id_upd,
			 					mkprdpurords_id,mlevel,itms_id,itms_id_pare,
								processseq,processseq_pare,locas_id,locas_id_pare,
								prjnos_id,
								shelfnos_id_to,shelfnos_id_to_pare,
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
						gantt.mkprdpurords_id_trngantt ,max(gantt.mlevel) mlevel,gantt.itms_id_trn itms_id, gantt.itms_id_pare,
						gantt.processseq_trn,gantt.processseq_pare ,gantt.locas_id_trn locas_id,gantt.locas_id_pare,
						gantt.prjnos_id ,
						gantt.shelfnos_id_to ,gantt.shelfnos_id_to_pare,
						sum(gantt.qty_sch) qty_sch,sum(gantt.qty) qty,sum(gantt.qty_stk) qty_stk,
						min(gantt.duedate_trn),	max(gantt.toduedate_trn),	min(gantt.starttime_trn),
						case max(opeitm.packqty) when 0 then 1 when null then 0 else max(opeitm.packqty) end packqty,
						max(gantt.consumchgoverqty),max(gantt.consumminqty),
						case max(gantt.consumunitqty) when 0 then 1 else max(gantt.consumunitqty) end consumunitqty,
						gantt.parenum,gantt.chilnum,
						sum(gantt.qty_handover) qty_handover,sum(gantt.qty_require) qty_require,
						max(gantt.tblname) tblname,min(gantt.tblid) tblid,count(tblid),
						'2099/12/31',current_date,current_date 
						from trngantts gantt 
						inner join opeitms opeitm on gantt.itms_id_trn = opeitm.itms_id  and gantt.processseq_trn = opeitm.processseq 
													and gantt.locas_id_trn = opeitm.locas_id_opeitm  
						inner join mkordterms term on gantt.itms_id_trn = term.itms_id  and gantt.processseq_trn = term.processseq 
													and gantt.locas_id_trn = term.locas_id and gantt.prjnos_id = term.prjnos_id  
													and gantt.mkprdpurords_id_trngantt = term.mkprdpurords_id and gantt.shelfnos_id_to = term.shelfnos_id_to 
						where  gantt.key > '00000' and gantt.mkprdpurords_id_trngantt = #{mkprdpurords_id} ---xxx
							and gantt.duedate_trn >= term.duedate and gantt.duedate_trn < term.optfixodate
						group by gantt.mkprdpurords_id_trngantt ,gantt.itms_id_pare,gantt.processseq_pare ,gantt.locas_id_pare,
		 					gantt.itms_id_trn,gantt.processseq_trn ,gantt.locas_id_trn ,gantt.parenum,gantt.chilnum,
		 					gantt.prjnos_id,gantt.shelfnos_id_to   ,gantt.shelfnos_id_to_pare
				&
	end			

	def cal_ord_qty_strsql(handover,mkprdpurords_id)
		%Q&
			update mkordtmpfs tmp set 	qty_require = cal.qty_require,
										qty_handover = 	trunc(cal.qty_require / cal.packqty + 0.99999) * cal.packqty 
							from (select mk.id,mk.packqty,
									case 
									when (trunc(pare_mk.pare_qty_handover * mk.chilnum / mk.parenum / mk.consumunitqty + 0.99999) * mk.consumunitqty + mk.consumchgoverqty) > mk.consumminqty  then 
										(trunc(pare_mk.pare_qty_handover * mk.chilnum / mk.parenum / mk.consumunitqty + 0.99999) * mk.consumunitqty + mk.consumchgoverqty)
									else 
										mk.consumminqty
									end qty_require
									from mkordtmpfs mk 
									inner join (select itms_id,processseq,prjnos_id,locas_id,shelfnos_id_to,
													sum(qty_handover) pare_qty_handover from mkordtmpfs
													where mkprdpurords_id = #{mkprdpurords_id}  
													and itms_id = #{handover["itms_id_pare"]} and processseq = #{handover["processseq_pare"]}  
													and locas_id = #{handover["locas_id_pare"]} and prjnos_id = #{handover["prjnos_id"]}
													and shelfnos_id_to = #{handover["shelfnos_id_to_pare"]} 
													group by itms_id,processseq,locas_id,prjnos_id,shelfnos_id_to) pare_mk
											on mk.itms_id_pare = pare_mk.itms_id and mk.processseq_pare = pare_mk.processseq
												and mk.locas_id_pare = pare_mk.locas_id and mk.prjnos_id = pare_mk.prjnos_id
												and mk.shelfnos_id_to_pare = pare_mk.shelfnos_id_to
												) cal
							where tmp.id = cal.id											
   	  	&			
	end

	def ordorg_strsql(handover)
		%Q&
			select 
				mk.mkprdpurords_id,mk.itms_id,mk.processseq,mk.locas_id,
				mk.prjnos_id,mk.shelfnos_id_to,
				sum(mk.qty_sch) qty_sch,max(opeitm.packqty) packqty,
				max(mk.tblname) tblname,min(mk.tblid) tblid,
				min(mk.duedate) duedate,max(mk.toduedate) toduedate,min(mk.starttime) starttime,
				max(consumchgoverqty) consumchgoverqty,max(consumminqty) consumminqty,max(consumunitqty) consumunitqty,
				sum(mk.qty_handover) qty_handover,sum(mk.qty_require) qty_require,sum(mk.incnt) incnt
				from mkordtmpfs mk
				inner join opeitms opeitm on opeitm.itms_id = mk.itms_id and opeitm.processseq = mk.processseq
					and mk.locas_id = opeitm.locas_id_opeitm
				where mkprdpurords_id = #{handover["mkprdpurords_id"]}
				and itms_id_pare = #{handover["itms_id_pare"]} and processseq_pare = #{handover["processseq_pare"]}  
				and shelfnos_id_to_pare = #{handover["shelfnos_id_to_pare"]} 
				and locas_id_pare = #{handover["locas_id_pare"]} and prjnos_id = #{handover["prjnos_id"]}
				group by mk.prjnos_id,mk.locas_id,mk.itms_id,mk.processseq,mk.shelfnos_id_to,mkprdpurords_id
		&
	end

	def proc_mkbillinsts reqparams,mkinstparams  ###xxxschsからxxxordsを作成する。 trngantts:xxxschs= 1:1
		### mkprdpurordsではxno_xxxschはセットしない。schsをまとめたり分割したりする機能のため
		setParams = reqparams.dup
		tbldata = reqparams["tbldata"].dup  ###tbldata -->テーブル項目　　viewではない。
		mkbillinsts_id = reqparams["mkbillinsts_id"]   
		add_tbl = "" 
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
					strwhere << %Q% #{field} #{moreless} to_date('#{val}','yyyy/mm/dd hh24:mi:ss')   and 
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
		command_c[:sio_classname] = "_add_billinst_by_mkbillinsts"
		###ActiveRecord::Base.connection.begin_db_transaction()
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
			blk.proc_create_src_tbl(command_c)
			blk.proc_private_aud_rec({},command_c)
			###CreateOtherTableRecordJob.perform_later(setParams["seqno"][0])			
			mkinstarams[:incnt] += inst["incnt"].to_f
			mkinstparams[:outcnt] += 1
			billordsql = "select ord.id,ord.amt from billords ord  " +  strjoin + strwhere[0..-7]
			ActiveRecord::Base.connection.select_all(billordsql).each do |billord|
				src = {"trngantts_id" => 0,"tblname" => "billords","tblid" => billord["id"]}
				base = {"tblname"=>"billinsts","tblid"=>command_c["id"],"qty_src" => 0,"amt_src"=>billord["amt_src"]}
				ArelCtl.proc_insert_linktbls(src,base)
			end
		end
		rescue
			ActiveRecord::Base.connection.rollback_db_transaction()
			command_c[:sio_result_f] = "9"  ##9:error
			command_c[:sio_message_contents] =  "class #{self} : LINE #{__LINE__} $!: #{$!} "[0..3999]    ###evar not defined
			command_c[:sio_errline] =  "class #{self} : LINE #{__LINE__} $@: #{$@} "[0..3999]
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

	def schtrn_alloc_to_freetrn(sumSchs)   ###xxxschsをまとめて消費量を決めているので
	 	###freeを探す　
	 	required_sch_qty = sumSchs["qty_require"].to_f
	 	alloc_qty = 0
	 	alloc_qty_stk = 0
		base = {}
		###freeのxxxordsは子部品を既に手配済が条件
	 	ActiveRecord::Base.connection.select_all(getFreeOrdStk(sumSchs)).each do |free|   ### 
	 		qty_src = 0
	 		base = ArelCtl.proc_set_stkinout(free)
	 		base["trngantts_id"] = free["trngantts_id"] ####schsの@trngantts_idを変更
	 		if (free["alloc_qty"].to_f - free["alloc_qty_linkto_alloctbl"].to_f) >= required_sch_qty
	 			qty_src = required_sch_qty 
	 			base["qty"] = alloc_qty = required_sch_qty
	 			base["qty_stk"] = 0
	 			required_sch_qty = 0
	 		else
	 			if (free["alloc_qty_stkj"].to_f - free["alloc_qty_linkto_alloctbl"].to_f) >= required_sch_qty
	 				qty_src = required_sch_qty 
	 				base["qty_stk"] = alloc_qty_stk = required_sch_qty
	 				base["qty"] = 0
	 				required_sch_qty = 0
	 			else		
	 				if (free["alloc_qty"].to_f > free["alloc_qty_linkto_alloctbl"].to_f) 
	 					qty_src = (free["alloc_qty"].to_f - free["alloc_qty_linkto_alloctbl"].to_f) 
	 					required_sch_qty -=  (free["alloc_qty"].to_f - free["alloc_qty_linkto_alloctbl"].to_f)
	 					base["qty"] = qty_src
	 					base["qty_stk"] = 0
	 					alloc_qty += qty_src 
	 				else		
	 					if (free["alloc_qty_stk"].to_f > free["alloc_qty_linkto_alloctbl"].to_f) 
	 						qty_src = (free["alloc_qty_stk"].to_f - free["alloc_qty_linkto_alloctbl"].to_f) 
	 						required_sch_qty -=  (free["alloc_qty_stk"].to_f - free["alloc_qty_linkto_alloctbl"].to_f)
	 						base["qty_stk"] = qty_src
	 						base["qty"] = 0
	 						alloc_qty_stk += qty_src 
	 					end
	 				end
	 			end
	 		end		
			
			 ###freeの減
	 		update_strsql = %Q&
	 					update trngantts set qty_free = qty_free - #{qty_src},
						 						qty = #{base["qty"]},qty_stk = #{base["qty_stk"]},
	 											remark = 'Operation line:#{__LINE__} update qty_free' 
	 					where id = #{free["trngantts_id"]}
	 					&
	 		ActiveRecord::Base.connection.update(update_strsql)
	 		base["amt_src"] = 0
	 		base["qty_src"] = qty_src
	 		schtrn_strsql = %Q&
				select mk.tblname,mk.tblid,mk.trngantts_id,mk.qty_sch,mk.qty,mk.qty_stk,
			 		mk.qty_require,mk.qty_handover,mk.packqty,
				 	mk.duedate,mk.toduedate,mk.starttime,
				 	mk.locas_id,mk.itms_id,mk.processseq,mk.shelfnos_id_to
				 	from mkordtmpfs mk
				 	where mkprdpurords_id = #{sumSchs["mkprdpurords_id"]} 
					 and itms_id = #{sumSchs["itms_id"]} and processseq = #{sumSchs["processseq"]}  
					 and locas_id = #{sumSchs["locas_id"]} and prjnos_id = #{sumSchs["prjnos_id"]}
					 and shelfnos_id_to = #{sumSchs["shelfnos_id_to"]} 
					 order by  (mk.duedate)
 			&
	 		####lotstkhists_idを求める。
	 		rec = ActiveRecord::Base.connection.select_one(ArelCtl.proc_sql_get_lotstkhists_id(free))
			base["lotstkhists_id"] = rec["id"] 
			Shipment.proc_check_inoutlotstk("out",base)   ###ordsの在庫内訳数変更
			ActiveRecord::Base.connection.select_all(schtrn_strsql).each do |sch_trn|
				qty_sch = sch_trn["qty_sch"].to_f
				if qty_src >  sch_trn["qty_sch"].to_f
					qty_src -=  sch_trn["qty_sch"].to_f
					sch_trn["qty_sch"] = 0
				else
					sch_trn["qty_sch"] = sch_trn["qty_sch"].to_f - qty_src
					qty_src = 0
				end
				if base["qty"].to_f > base["qty_stk"].to_f
					sch_trn["qty"] = sch_trn["qty"].to_f +  qty_sch - sch_trn["qty_sch"] ### qty_sch saveしたqty_sch
					sch_trn["qty_stk"] = 0 
				else
					sch_trn["qty_stk"] = sch_trn["qty_stk"].to_f +  qty_sch - sch_trn["qty_sch"] 
					sch_trn["qty"] = 0
				end
				
				update_schsql = %Q&
							update trngantts set qty_sch = #{sch_trn["qty_sch"]},qty = #{sch_trn["qty"]},qty_stk = #{sch_trn["qty_stk"]},
													remark = 'Operation line:#{__LINE__} update qty_free' 
							where id = #{sch_trn["trngantts_id"]}
							&
				ActiveRecord::Base.connection.update(update_schsql)
				ArelCtl.proc_prev_link_alloc_update("add",base,sch_trn)
				Shipment.proc_check_inoutlotstk("in",sch_trn)   ###ordsの在庫数変更
				break if qty_src <= 0
			end
	 		break if required_sch_qty <= 0
	 	end
	 	return sumSchs
	end	
	 
	def getFreeOrdStk(sumSchs)	
	 	%Q&select   ---  free　を求めるsql
	 	 				case
	 	 				when alloc.qty_stk > 0
	 	 					then '02' 
	 	 				when  gantt.duedate_trn <= to_date('#{sumSchs["duedate"]}','yyyy-mm-/dd')
	 	 					then '01'	
	 	 				else
	 	 					'03' end  priority,
	 	 				to_number(to_char(gantt.duedate_trn,'yyyymmdd'),'99999999')*-1 due,
	 	 				gantt.duedate_trn duedate,
	 	 				gantt.processseq_trn processseq,gantt.mlevel mlevel,
	 	 				gantt.itms_id_trn itms_id,gantt.prjnos_id,
	 	 				alloc.srctblname tblname,alloc.srctblid tblid,alloc.trngantts_id trngantts_id,
	 	 				alloc.id alloctbls_id	,gantt.qty_free	,gantt.qty_handover,
	 	 				alloc.qty alloc_qty,alloc.qty_stk alloc_qty_stk,alloc.qty_linkto_alloctbl alloc_qty_linkto_alloctbl	
	 	 				from trngantts gantt
	 	 				inner join alloctbls alloc on gantt.id = alloc.trngantts_id and gantt.orgtblname = alloc.srctblname 
	 	 												and gantt.orgtblid = alloc.srctblid
	 	 				where gantt.prjnos_id =  #{sumSchs["prjnos_id"]} and gantt.qty_free > 0
	 	 					and gantt.orgtblname = gantt.paretblname and gantt.paretblname = gantt.tblname
	 	 					and gantt.orgtblid = gantt.paretblid  and gantt.paretblid = gantt.tblid
	 	 					and  gantt.itms_id_trn = #{sumSchs["itms_id"]} and gantt.processseq_trn = #{sumSchs["processseq"]}
	 	 					and  gantt.shelfnos_id_to = #{sumSchs["shelfnos_id_to"]} ---作成場所、購入先にはこだわらない。
	 	 					and (gantt.tblname = 'prdords' or gantt.tblname = 'purords'  or gantt.tblname = 'lotstkhists' )
	 	 					--- freeの在庫　　未定 仮に"lotstkhists"にした。要確認
	 	 					and gantt.qty_free > 0 and (alloc.qty + alloc.qty_stk) > alloc.qty_linkto_alloctbl
	 	 					order by priority,due
	 	 					---for update
	 	 				& ### xxxacts等を登録するときは必ずxxxordsを前に登録すること。
	end
end