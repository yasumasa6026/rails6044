//yupでできなかったこと
export function  setProtectFunc(field,row){
    let readOnly = {}
    switch (row.values.fieldcode_ftype) 
        // {
        // case "fieldcode_dataprecision":
        //     if(row.values.fieldcode_ftype==="numeric") {readOnly=false}
        //     else{readOnly=true}     
        //     break   
        // case "screenfield_dataprecision":
        //     if(row.values.screenfield_type==="numeric") {readOnly=false}
        //     else{readOnly=true}      
        //     break      
        // case "fieldcode_datascale":
        //     if(row.values.fieldcode_ftype==="numeric") {readOnly=false}
        //     else{readOnly=true}        
        //     break    
        // case "screenfield_datascale":
        //     if(row.values.screenfield_type==="numeric") {readOnly=false}
        //     else{readOnly=true}         
        //     break   
        // case "fieldcode_fieldlength":
        //     if(row.values.fieldcode_ftype==="char"||row.values.fieldcode_ftype==="varchar") {readOnly=false}
        //     else{readOnly=true}         
        //     break   
        // case "screenfield_edoptmaxlength":
        //     if(row.values.screenfield_type==="varchar"||row.values.screenfield_ftype==="char"){readOnly=false}
        //     else{readOnly=true}      
        //     break      
        // default:  readOnly = false
        // }
        
         {
         case "numeric":
             readOnly["fieldcode_fieldlength"] = true   
             readOnly["screenfield_edoptmaxlength"] = true   
             break   
         case "char":
            readOnly["fieldcode_dataprecision"] = true   
            readOnly["screenfield_dataprecision"] = true   
            readOnly["fieldcode_datascale"] = true     
            readOnly["screenfield_datascale"] = true   
             break      
         case "varchar":
            readOnly["fieldcode_dataprecision"] = true   
            readOnly["screenfield_dataprecision"] = true   
            readOnly["fieldcode_datascale"] = true     
            readOnly["screenfield_datascale"] = true   
             break    
         default:  
         }
    return readOnly    
}


export function  setClassFunc(field,row,className,req){  //error処理

                if(req==="viewtablereq7"){return(className)}
                else{
                    let msgid = field + "_gridmessage"
                    if(/error/.test(row.values[msgid])){  // "!"はjavascriptでは正規化の判定がわからない。
                                                            return(className + " error" ) 
                                                        }
                    else{return(className)}
                }    
}

export function  setInitailValueForAddFunc(field,row,className,screenCode){    
    //let today = new Date();
    let val = ""
    let duedateField
    if(row.values[field]&&row.values[field]!==""){val = row.values[field]}
        else{  //コメントの内容はホストで対応
        //     if(/Numeric/.test(className)){val = "0"}
            switch( true ){ //初期値 全画面共通
                // case /_expiredate/.test(field):
                //     val = "2099-12-31"
                // break
                // case /_isudate|_rcptdate|_cmpldate/.test(field):  //   mkord_cmpldateでもセットしている。
                //     val = today.getFullYear() + "-" + (today.getMonth() + 1) + "-" +  today.getDate()  
                // break
                case /_starttime|_toduedate/.test(field):  //   mkord_cmpldateでもセットしている。
                    duedateField = field.split("_")[0] + "_duedate"
                    val = row.values[duedateField] 
                break
                case /loca_code_cust_custrcvplc/.test(field):  //   
                    val = row.values["loca_code_cust"] 
                break
                default: break 
            }
        }
    return val    
}

