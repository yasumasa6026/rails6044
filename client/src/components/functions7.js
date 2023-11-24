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
            if (/_amt$|purord_price|purdlv_price|custord_price|custdlv_price|puract_price|custact_price/.test(id)) {
                switch(values.purord_contractprice){
                case "1":
                case "2": 
                case "3": 
                    readOnly = true
                     break
                }
                switch(values.purdlv_contractrice){
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

