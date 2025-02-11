//yupでできなかったこと
export function  setProtectFunc(id,values){
    let readOnly = false  //type = row.values.fieldcode_ftype 
    if(values.fieldcode_ftype)
        {switch (values.fieldcode_ftype){ 
            case "numeric":
            switch (id) {
                case "fieldcode_fieldlength":
                case "screenfield_edoptmaxlength": 
                    readOnly = true
                     break
                }
             break   
            case "char":   
            case "varchar":
            switch (id) {
                case "fieldcode_dataprecision":
                case "fieldcode_datascale":      
                case "screenfield_dataprecision":
                case "screenfield_datascale":
                         readOnly = true
                         break
            } 
            break
            case "date":
            case "timestamp(6)":
               switch (id) {
                    case "fieldcode_fieldlength":
                    case "fieldcode_dataprecision":
                    case "fieldcode_datascale":       
                    case "screenfield_edoptmaxlength": 
                    case "screenfield_dataprecision":
                    case "screenfield_datascale":
                            readOnly = true
                    break
               }
             break  
         default:  
         }
        }else{
            /*1:発注日ベース　2:納期ベース　5:検収ベース A:マター単価を変更 B:マスター無確定単価 C:マスター単価無 Z:仮単価 */
            if (/_amt$|purord_price|purdlv_price|custord_price|custdlv_price|puract_price|custact_price/.test(id)) {
                switch(values.purord_contractprice){
                case "1":
                case "2": 
                case "3": 
                    readOnly = true
                     break
                }
                switch(values.purdlv_contractprice){
                case "1":
                case "2": 
                case "3": 
                    readOnly = true
                     break
                }
                switch(values.puract_contractprice){
                case "1":
                case "2": 
                case "3": 
                    readOnly = true
                     break
                }
                switch(values.custord_contractprice){
                case "1":
                case "2": 
                case "3": 
                    readOnly = true
                     break
                }
                switch(values.custdlv_contractprice){
                case "1":
                case "2": 
                case "3": 
                    readOnly = true
                     break
                }
                switch(values.custact_contractprice){
                case "1":
                case "2": 
                case "3": 
                    readOnly = true
                     break
                }
                }
        }
    return readOnly    
}

export function  setClassFunc(field,values,className,aud){  //error処理

                if(aud==="view"){return(className)}
                else{
                    let msgid = field + "_gridmessage"
                    if(/error/.test(values[msgid])){  // "!"はjavascriptでは正規化の判定がわからない。
                                                            return(className + " error" ) 
                                                        }
                    else{return(className)}
                }    
}


export function  setYyyymmddFunc(filters){  //  ex. 2024/8/8-->2024/08/08

    filters = filters.map((fld,idx) => {
             switch (true){   
                case /date$/.test(fld.id):   
                case /starttime$/.test(fld.id):   
                case /created_at$/.test(fld.id):   
                case /updateed_at$/.test(fld.id):
                    let yyyymmddhhmm = fld.value.split(" ")
                    let yyyymmdd = yyyymmddhhmm[0]&&yyyymmddhhmm[0].split(/\/|-/)
                    if(yyyymmdd[1]&&yyyymmdd[1].length===1){yyyymmdd[1] = "0" + yyyymmdd[1]}
                    if(yyyymmdd[2]&&yyyymmdd[2].length===1){yyyymmdd[2] = "0" + yyyymmdd[2]}
                    let hhmm = []
                    hhmm = yyyymmddhhmm[1]?yyyymmddhhmm[1].split(":"):[]
                    if(hhmm[0]&&hhmm[0].length===1){hhmm[0] = "0" + hhmm[0]}
                    if(hhmm[1]&&hhmm[1].length===1){hhmm[1] = "0" + hhmm[1]}
                    if(yyyymmdd[0]){fld.value = yyyymmdd[0]
                                    if(yyyymmdd[1]){
                                        fld.value = fld.value + "/" + yyyymmdd[1]
                                        if(yyyymmdd[2]){
                                            fld.value = fld.value + "/" + yyyymmdd[2]
                                            if(hhmm[0]){fld.value = fld.value + " " + hhmm[0]
                                                if(hhmm[1]){fld.value = fld.value + ":" + hhmm[1]}
                                            }
                                        }
                                    }
                    }
                    return fld
                default:
                    return fld
             }   
           }) 
    return filters
}


// export function  setInitailValueForAddFunc(field,row,screenCode){    //screenCode未使用
//     //let today = new Date();
//     let val = ""
//     let duedateField
//     if(row.values[field]&&row.values[field]!==""){val = row.values[field]}
//         else{  //コメントの内容はホストで対応
//         //     if(/Numeric/.test(className)){val = "0"}
//             switch( true ){ //初期値 全画面共通
//                 // case /_expiredate/.test(field):
//                 //     val = "2099-12-31"
//                 // break
//                 // case /_isudate|_rcptdate|_cmpldate/.test(field):  //   mkord_cmpldateでもセットしている。
//                 //     val = today.getFullYear() + "-" + (today.getMonth() + 1) + "-" +  today.getDate()  
//                 // break
//                 case /_starttime|_toduedate/.test(field):  //   mkord_cmpldateでもセットしている。
//                     duedateField = field.split("_")[0] + "_duedate"
//                     val = row.values[duedateField] 
//                 break
//                 case /loca_code_custrcvplc/.test(field):  //   
//                     val = row.values["loca_code_cust"] 
//                 break
//                 default: break 
//             }
//         }
//     return val    
// }

