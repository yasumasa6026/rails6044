import moment from 'moment'
//yupでできなかったこと
//検索項目では　xxxx_gridmessage = in は意味がない。　検索結果がセットされるため。
// 項目の順番が制限される。

export function  onBlurFunc7(screenCode,lineData,id){  //id:field
    let starttime
    let toduedate
    let qty_case
    let gno
    switch( true ){
        case /itm_code$/.test(id):
            if(/schs$|ords$/.test(screenCode)){
                if(lineData["opeitm_processseq"]===""){
                    lineData["opeitm_processseq"] = "999"
                    lineData["opeitm_processseq_gridmessage"] = "in"
                }
                if(lineData["opeitm_priority"]===""){
                    lineData["opeitm_priority"] = "999"
                    lineData["opeitm_priority_gridmessage"] = "in"
                }
            }
            break
        case /_duedate/.test(id):
                starttime = id.split("_")[0] + "_starttime" 
                if(lineData[starttime]===""){
                    if(/cust/.test(screenCode)){ //受注の時はopeitmのLT(duration)は使用できない。
                        lineData[starttime] = moment(lineData[id]).add(- "1",'d').format() 
                    }
                    else{
                        lineData[starttime] = moment(lineData[id]).add(- lineData["opeitm_duration"],'d').format() 
                    }       
                    lineData[`${starttime}_gridmessage`] = "in"
                }
                toduedate = id.split("_")[0] + "_toduedate" 
                if(lineData[toduedate]===""){
                        lineData[toduedate] = lineData[id]
                        lineData[`${toduedate}_gridmessage`] = "in"
                }
                if(/^purords$/.test(screenCode)){
                    if(lineData["opeitm_priority"] === "999")
                            {
                                lineData["loca_code_supplier"] = lineData["loca_code"]  //lineData["loca_code"] -->opeitmsのlocas_id
                                lineData["shelfno_code_to"] = lineData["shelfno_code"]
                                lineData["loca_code_supplier_gridmessage"] = "in"
                                lineData["shelfno_code_to_gridmessage"] = "in"
                     }
                 }
                if(/^prdords$/.test(screenCode)){
                    if(lineData["opeitm_priority"] === "999")
                             {
                                lineData["loca_code_workplace"] = lineData["loca_code"]   //lineData["loca_code"] -->opeitmsのlocas_id
                                lineData["shelfno_code_to"] = lineData["shelfno_code"]
                                lineData["loca_code_workplace_gridmessage"] = "in"
                                lineData["shelfno_code_to_gridmessage"] = "in"
                    }
                }
                if(/^custords$/.test(screenCode)){  //custrordsでは棚まで指定しない。
                        if(lineData["loca_code_fm"]===""){
                            lineData["loca_code_fm"] = lineData["loca_code_shelfno"]
                            lineData["custord_loca_id_fm"] = lineData["shelfno_loca_id_shelfno"]
                            lineData["loca_code_fm_gridmessage"] = "in"
                        }
                }
            break
        /*case /loca_code_supplier/.test(id):
                lineData["loca_code"] = lineData[id]
            break */
        case /_qty$/.test(id):
            switch( true ){
            case /_pur/.test(screenCode):
                qty_case = id.split("_")[0] + "_qty_case" 
                    if(Number(lineData["opeitm_packqty"])===0){  //opeitm_packqtyは購入時・作成後の完成時の単位
                        lineData[qty_case] = lineData[id] 
                    }else{
                        lineData[id]  = String(Math.ceil(lineData[id]/lineData["opeitm_packqty"])*lineData["opeitm_packqty"])
                        lineData[qty_case] =  String(Math.ceil(lineData[id]/lineData["opeitm_packqty"]))}
                //
                if( lineData["crr_code_pur"] ){}
                else{        
                    lineData["crr_code_pur"] = lineData["crr_code_supplier"] 
                    lineData["crr_code_pur_gridmessage"] = "in"}
                break 
            case /_prd/.test(screenCode):
                qty_case = id.split("_")[0] + "_qty_case" 
                    if(Number(lineData["opeitm_packqty"])===0){  //opeitm_packqtyは購入時・作成後の完成時の単位
                        lineData[qty_case] = lineData[id] 
                    }else{
                        lineData[id]  = String(Math.ceil(lineData[id]/lineData["opeitm_packqty"])*lineData["opeitm_packqty"])
                        lineData[qty_case] =  String(Math.ceil(lineData[id]/lineData["opeitm_packqty"]))}
                break 
            default:
                lineData["confirm_gridmessage"] = "ok"
                break    
            }        
            break
        case /_invoiceno/.test(id):
            gno = id.split("_")[0] + "_gno"
            if(lineData[gno]){}
            else{  //opeitm_packqtyは購入時・作成後の完成時の単位
                lineData[gno] = lineData[id] 
            } 
            break
        default:
            lineData["confirm_gridmessage"] = "ok"
             break    
        }
       
    return  lineData
}