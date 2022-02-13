# -*- coding: utf-8 -*-
# RorBlk
# 2099/12/31を修正する時は　2100/01/01の修正も
module PriceLib
	def proc_price_amt command_c
		tblnamechop = (command_c[:sio_viewname].split("_",2)[1].chop)
		qty = command_c[("#{tblnamechop}_qty").to_sym]
		case tblnamechop
			when /^cust/
				pricetbl = "custs"
				loca_code = command_c[:loca_code_cust]
			when /^pur/
				pricetbl = "dealers"
				loca_code = command_c[:loca_code]   ###入力でdealerを保証する。
			when /^prd/
				pricetbl = "asstwhs"
				loca_code = command_c[:loca_code_asstwh]
			when /^shp/
				loca_code = command_c[:loca_code_to]
				case command_c[:opeitm_oparation]
					when "shp:delivered_goods"
							pricetbl = "custs"
					when "shp:feepayment"
							pricetbl = "feepayms"
					when "shp:shipment"
							pricetbl = "asstwhs"
					else
							pricetbl = "asstwhs"
				end
				loca_code = command_c[:loca_code_to]
			when /mkact/
				case command_c[:mkact_prdpur]
					when "pur"
						pricetbl = "dealers"
						if command_c[:mkact_sno_inst]
							strsql = "select * from r_purinsts where purinst_sno = '#{command_c[:mkact_sno_inst]}'"
							loca_code = ActiveRecord::Base.connection.select_one(strsql)["loca_code"]
						else
							if command_c[:mkact_sno_act]
								strsql = "select * from r_puracts where purinst_sno = '#{command_c[:mkact_sno_act]}'"
								loca_code = ActiveRecord::Base.connection.select_one(strsql)["loca_code"]
							else
								return {}
							end
						end
					else
						return {}
				end
			else
				return {}
		end
		strsql = "select *
				from r_pricemsts 	/*同一品目内ではcontract_price<pricemst_amtroundは有効日内で同一であること*/
				where pricemst_tblname =  '#{pricetbl}' and pricemst_expiredate >= current_date and
				itm_code = '#{command_c[:itm_code]}' AND loca_code = '#{loca_code}' "
		rec_contract = ActiveRecord::Base.connection.select_one(strsql)   ###画面のfield
		command_c[("#{tblnamechop}_contract_price").to_sym]||=""
		if command_c[("#{tblnamechop}_contract_price").to_sym]  != "" ###変更の時
			contract = command_c[("#{tblnamechop}_contract_price").to_sym]
			price = (command_c[("#{tblnamechop}_price").to_sym]||=0).to_f
			amtround = rec_contract["pricemst_amtround"] if rec_contract
			amtdecimal = rec_contract["pricemst_amtdecimal"] if rec_contract
		else   ###新規登録の時の単価
			if rec_contract.nil?
				contract = ""
				case tblnamechop
					when /^cust/
						contract= "C"
					when /^pur/
						contract = "D"
					when /^prd/
						contract = "X"  ###単価未定
						expiredate = ""
						return {:price=>"0",:amt=>"0",:tax=>"0",:amtf=>"0",:contract_price => contract}   ##
					when /^shp/
						case command_c[:opeitm_oparation]
							when "shp:delivered_goods"
								contract= "C"
							when "shp:feepayment"
								contract = "F"
							when "shp:shipment"
								contract = "X"  ###単価未定
								expiredate = ""
								return {:price=>"0",:amt=>"0",:tax=>"0",:amtf=>"0",:contract_price => contract}   ##
							else
								contract = "X"  ###単価未定
								expiredate = ""
								return {:price=>"0",:amt=>"0",:tax=>"0",:amtf=>"0",:contract_price => contract}   ##
					end
				end
			else
				contract = rec_contract["pricemst_contract_price"]
				amtround = rec_contract["pricemst_amtround"]
				amtdecimal = rec_contract["pricemst_amtdecimal"]
			end
		end
		##7:出荷日までに決定する単価
		##　8:受入日までに決定する単価　
		##9:単価決定=検収
		expiredate = nil
		case contract
			when "1" ###発注日ベース　　発注日　== String 以下同様
				if tblnamechop =~ /ord|sch/
					expiredate = vproc_price_expiredate_set(contract,command_c)
				else
					return {:pricef=>true,:amtf=>true}
				end
			when "2"	###納期ベース
				if tblnamechop =~ /inst|ord|sch/
					expiredate = vproc_price_expiredate_set(contract,command_c)
				else
					return {:pricef=>true,:amtf=>true}
				end
			when "3","4"
				expiredate = vproc_price_expiredate_set(contract,command_c)
			when "C","D","F" ##C : custs テーブルに従う D:dealersテーブルに従う
				case  pricetbl
					when  "custs"
						strsql = "select  * from r_custs
								where loca_code_cust =  '#{loca_code}' and cust_expiredate > current_date "
						pare_contract = ActiveRecord::Base.connection.select_one(strsql)   ###画面のfield
						if pare_contract
							expiredate = vproc_price_expiredate_set(pare_contract["cust_contract_price"],command_c)
							if expiredate.nil?
								logger.debug "line #{__LINE__} strsql #{strsql}"
								raise
							end
							pare_rule_price = pare_contract["cust_rule_price"]
							amtround = pare_contract["pricemst_amtround"]
							amtdecimal = pare_contract["pricemst_amtdecimal"]
						end
					when  "dealers"
						strsql = "select  * from r_dealers
									where loca_code_dealer =  '#{loca_code}' and dealer_expiredate > current_date "
						pare_contract = ActiveRecord::Base.connection.select_one(strsql)   ###画面のfield
						expiredate = vproc_price_expiredate_set(pare_contract["dealer_contract_price"],command_c)
						if expiredate.nil?
							logger.debug "line #{__LINE__} strsql #{strsql}"
							raise
						end
						pare_rule_price = pare_contract["dealer_rule_price"]
						amtround = pare_contract["pricemst_amtround"]
						amtdecimal = pare_contract["pricemst_amtdecimal"]
					when  "feepayms"
						strsql = "select  * from r_feepayms
									where loca_code_dealer_fee =  '#{loca_code}' and feepaym_expiredate > current_date "
						pare_contract = ActiveRecord::Base.connection.select_one(strsql)   ###画面のfield
						expiredate = vproc_price_expiredate_set(pare_contract["feepaym_contract_price"],command_c)
						if expiredate.nil?
							logger.debug "line #{__LINE__} strsql #{strsql}"
							raise
						end
						pare_rule_price = pare_contract["feepaym_rule_price"]
						amtround = pare_contract["pricemst_amtround"]
						amtdecimal = pare_contract["pricemst_amtdecimal"]
				end
			when "Z"
				expiredate = ""
		end
		if expiredate.nil?
			logger.debug "line #{__LINE__} proc_price_amt :master error ???"
		end
		strsql = %Q& select * from r_pricemsts
					where pricemst_tblname =  '#{pricetbl}' and
						itm_code = '#{command_c[:itm_code]}' AND loca_code = '#{loca_code}' and
						pricemst_maxqty >= #{qty} and
						pricemst_expiredate >= to_date('#{expiredate}','yyyy/mm/dd') and
						pricemst_contract_price = '#{contract}'
						order by pricemst_expiredate ,pricemst_maxqty  &
		price_rec = ActiveRecord::Base.connection.select_one(strsql)   ###画面のfield
		if price_rec
			amtf = true
			contract = price_rec["pricemst_contract_price"]
			amtround = price_rec["pricemst_amtround"]
			amtdecimal = price_rec["pricemst_amtdecimal"]
			if price_rec["pricemst_rule_price"] == "0"
				pricef = true
				price =  price_rec["pricemst_price"]
			else
				if contract == "Z"
					price = command_c[("#{tblnamechop}_price").to_sym].to_f
					contract = "Z" if price_rec["pricemst_price"] != price
				else
					price =  price_rec["pricemst_price"]
				end
			end
		else
			if pare_rule_price  == "0" and @pare_class != "batch"
				price = proc_blkgetpobj("単価マスタなし","err_msg")
				return {:price=>price.to_s,:amt=>"",:tax=>"",:pricef=>true,:amtf=>true,:contract_price => contract}
			end
			if @pare_class == "batch"
				@errmsg = proc_blkgetpobj("単価マスタなし","err_msg")
				return {:price=>"0",:amt=>"0",:tax=>"0",:pricef=>false,:amtf=>false,:contract_price => "X"}
			end
            ###画面から単価入力された時
		end
		amt = qty.to_f * price
		case amtround
			when "-1"  ###切り捨て
				amt = amt.floor2(amtdecimal)
			when "0"
				amt = amt.round(amtdecimal)
			when "1"  ###切り上げ
				amt = amt.ceil2(amtdecimal)
			else
				raise  ###該当レコードのremarkに
		end
		tax = vproc_get_tax(amt,loca_code)    ###作成中
		return {:price=>price.to_s,:amt=>amt.to_s,:tax=>tax.to_s,:pricef=>true,:amtf=>true,:contract_price => contract}
	end
	def vproc_get_tax(amt,loca_code)  ###作成中
		0
	end
	def vproc_price_expiredate_set(contract,command_c)
		tblnamechop = command_c[:sio_viewname].split("_",2)[1].chop
		case contract  ###
			when "1"   ###発注日ベース
				expiredate = command_c[(tblnamechop+"_isudate").to_sym].strftime("%Y/%m/%d")
			when "2" ###納期ベース
				expiredate = command_c[(tblnamechop+"_duedate").to_sym].strftime("%Y/%m/%d")
			when "3" ###:受入日ベース
				if tblnamechop =~ /acts$/
					expiredate = command_c[(tblnamechop+"_rcptdate").to_sym].strftime("%Y/%m/%d")
				else
					expiredate = command_c[(tblnamechop+"_duedate").to_sym].strftime("%Y/%m/%d")
				end
			when "4" ###:出荷日ベース　
				expiredate = command_c[(tblnamechop+"_depdate").to_sym].strftime("%Y/%m/%d")
			when "5" #####:検収ベース
				expiredate = command_c[(tblnamechop+"acpdate").to_sym].strftime("%Y/%m/%d")
		end
	end
end   ##module
