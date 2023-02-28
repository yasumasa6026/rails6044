//yupでできなかったこと
export function  setProtectFunc(id,type){
    let readOnly = false  //row.values.fieldcode_ftype 
    switch (type){ 
        case "numeric":
            switch (id) {
                case "fieldcode_fieldlength":
                    readOnly = true
                    break  
                case "screenfield_edoptmaxlength": 
                    readOnly = true
                     break
                }
             break   
        case "char":   
        case "varchar":
            switch (id) {
                case "fieldcode_dataprecision":
                    readOnly = true
                    break   
                case "fieldcode_datascale":       
                    readOnly = true
                    break
                case "screenfield_dataprecision":
                         readOnly = true
                         break
                case "screenfield_datascale":
                         readOnly = true
                         break
            } 
            break
        case "date":
        case "timestamp(6)":
               switch (id) {
                    case "fieldcode_fieldlength":
                        readOnly = true
                        break
                    case "fieldcode_dataprecision":
                       readOnly = true
                       break   
                    case "fieldcode_datascale":       
                       readOnly = true
                       break
                    case "screenfield_edoptmaxlength": 
                           readOnly = true
                           break
                    case "screenfield_dataprecision":
                            readOnly = true
                            break
                    case "screenfield_datascale":
                            readOnly = true
                            break
               }
             break  
         default:  
         }
    return readOnly    
}


export function  setClassFunc(field,values,className,buttonflg){  //error処理

                if(buttonflg==="viewtablereq7"){return(className)}
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

