
  
module YupSchema
extend self

    def proc_create_schema   ### 全画面対象
        yupschema = "let Yup = require('yup')\n"
        yupschema << "export const yupschema = {\n"
        screenCode = ""
        ActiveRecord::Base.connection.select_all(strsql_atr(nil)).each do |rec|   
            if screenCode != rec["pobject_code_scr"]
                if screenCode != ""
                    yupschema <<"           },\n"
                end 
                yupschema << "          #{rec["pobject_code_scr"]}:{\n"
                screenCode = rec["pobject_code_scr"]
            end         
            str = "Yup."
            case rec["screenfield_type"] 
            when "timestamp", "timestamp(6)","date"
                str<< %Q%date().min('1900/01/01').max('2100/01/01')%
                #case rec["pobject_code_sfd"] 
                #when /_expiredate/
                #    str<< %Q%.default('2099-12-31')%
                #when /_isudate/
                #    str<< %Q%
                #    .default(function() {
                #        let today = new Date()
                #        return today.getFullYear() + "/" + today.getMonth() + "/" +  today.getDate()
                #      })%
                #end    
            when "varchar", "textarea","char"
                str<< %Q%string()%
                if rec["screenfield_edoptmaxlength"].to_i > 0  ###入力最大バイト数
                    str<< %Q%.max(#{rec["screenfield_edoptmaxlength"].to_i})%
                end   
                case rec["pobject_code_sfd"]
                  when "loca_zip"
                    str<< %Q%.matches(/[0-9]{3}\-[0-9]{4}/, { message: 'post code error --> xxx-xxxx' })%
                  else 
                    if rec["screenfield_indisp"] == '0'
                      str << %Q%.nullable()% 
                    end
                end   
            when "select"
                str<< %Q%string()%
            when "check"
                str<< %Q%string()%
            when "numeric"
                if rec["screenfield_dataprecision"].to_i > 0 or  rec["screenfield_datascale"].to_i > 0 
                  if rec["screenfield_dataprecision"].to_i >  rec["screenfield_datascale"].to_i 
                      str<< %Q%number(#{rec["screenfield_dataprecision"].to_i - rec["screenfield_datascale"].to_i},#{rec["screenfield_datascale"]})%
                  else
                      str<< %Q%number(0,#{rec["screenfield_datascale"]})%
                  end
                else
                  str<< %Q%number()%
                end
                if rec["screenfield_minvalue"].to_f > 0 
                    str<< %Q%.min(#{rec["screenfield_minvalue"]})%
                end         
                if rec["screenfield_maxvalue"].to_f > 0
                    str<< %Q%.max(#{rec["screenfield_maxvalue"]})%
                else
                    if rec["screenfield_dataprecision"].to_i > 0
                        nsize = rec["screenfield_dataprecision"].to_i - rec["screenfield_datascale"].to_i 
                        if nsize > 16
                            nsize = 16
                        end
                        maxval = (10 ** nsize) - 1
                        str<< %Q%.max(#{maxval})% 
                    end
                end 
            end  
            if rec["screenfield_indisp"] != '0' or rec["screenfield_type"] == "numeric"
                str << %Q%.required()% 
            end   
            yupschema << "                  #{rec["pobject_code_sfd"]}:" + str + ",\n"
        end 
        yupschema <<  "         }\n"
        yupschema <<  "     }"
        return {:yupschema=>yupschema}           
    end 
    def proc_create_fetchCode screenCode       
        fetchCode ={}
        ActiveRecord::Base.connection.select_all(fetchCodesql(screenCode)).each do |rec|   
            if rec["screenfield_paragraph"]  
                fetchCode[rec["pobject_code_sfd"]] = rec["screenfield_paragraph"]
            end    
        end 

        return fetchCode           
    end  
    def proc_create_checkCode screenCode       
        checkCode ={}
        ActiveRecord::Base.connection.select_all(checkCodesql(screenCode)).each do |rec|   
            if rec["screenfield_subindisp"]  
                checkCode[rec["pobject_code_sfd"]] = rec["screenfield_subindisp"] 
            end    
        end 
        return checkCode           
    end 
    private
    def strsql_atr screenCode
         %Q%select pobject_code_sfd,screenfield_type,screenfield_indisp,screenfield_maxvalue,
                    screenfield_minvalue,screenfield_formatter,	pobject_code_scr ,screenfield_edoptmaxlength,
                    max(screenfield_updated_at) screenfield_updated_at,screenfield_paragraph,
                    screenfield_dataprecision,screenfield_datascale
                    from r_screenfields
                    where screenfield_editable !=0 and screenfield_selection != '0' and screenfield_hideflg != '1' and  
                    screenfield_expiredate > current_date
                    #{if screenCode then " and pobject_code_scr = '#{screenCode}' " else "" end }
                    group by pobject_code_sfd,screenfield_type,screenfield_indisp,screenfield_maxvalue,screenfield_edoptmaxlength,
                    screenfield_minvalue,screenfield_formatter,screenfield_paragraph,pobject_code_scr,
                    screenfield_dataprecision,screenfield_datascale
                    order by 	pobject_code_scr,pobject_code_sfd%
    end    
    def fetchCodesql screenCode
         %Q%select pobject_code_sfd,screenfield_paragraph
                    from r_screenfields
                    where trim(screenfield_paragraph) != '' and screenfield_paragraph is not null and
                    screenfield_expiredate > current_date
                    #{if screenCode then " and pobject_code_scr = '#{screenCode}' " else "" end }%
    end     
    def checkCodesql screenCode
         %Q%select pobject_code_sfd,screenfield_subindisp
                    from r_screenfields
                    where trim(screenfield_subindisp) != '' and screenfield_subindisp is not null and
                    screenfield_expiredate > current_date
                    #{if screenCode then " and pobject_code_scr = '#{screenCode}' " else "" end }%
    end  
end