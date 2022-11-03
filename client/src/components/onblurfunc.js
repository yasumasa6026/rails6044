import moment from 'moment'
//yupでできなかったこと
//検索項目では　xxxx_gridmessage = in は意味がない。　検索結果がセットされるため。
// 項目の順番が制限される。

export function  onBlurFunc7(screenCode,lineData,id){  //id:field
    let starttime
    let toduedate
    let qty_case
    let gno
    let autoAddFields = {}
    lineData["confirm_gridmessage"] = "ok"
    switch( true ){
        // case /itm_code$/.test(id):　　　//ScreenLib.proc_add_empty_dataで対応
        //     if(/schs$|ords$/.test(screenCode)){
        //         if(lineData["opeitm_processseq"]===""||lineData["opeitm_processseq"]===null||lineData["opeitm_processseq"]===undefined){
        //             lineData["opeitm_processseq"] = "999"
        //         }
        //         if(lineData["opeitm_processseq"]===""||lineData["opeitm_processseq"]===null||lineData["opeitm_processseq"]===undefined){
        //             lineData["opeitm_priority"] = "999"
        //         }
        //     }
        //     break
        case /_duedate/.test(id):
                moment.defaultFormat = "YYYY-MM-DD HH:mm"
                starttime = id.split("_")[0] + "_starttime" 
                //if(lineData[starttime]===""||lineData[starttime]===undefined||lineData[starttime]===null){
                if(lineData[starttime]===""){
                    if(/cust/.test(screenCode)){ //受注の時はopeitmのLT(duration)は使用できない。
                        lineData[starttime] = moment(lineData[id]).add(- "1",'d').format() 
                        autoAddFields[starttime] = lineData[starttime]
                    }
                    else{
                        lineData[starttime] = moment((lineData[id]).add(- lineData["opeitm_duration"],'d'),moment.defaultFormat)
                        autoAddFields[starttime] = lineData[starttime]
                    }       
                }
                toduedate = id.split("_")[0] + "_toduedate" 
                if(lineData[toduedate]===""){
                        lineData[toduedate] = lineData[id] 
                        autoAddFields[toduedate] = lineData[toduedate]
                }
            break
        case /_qty_sch|_qty$/.test(id):  //opeitmsのレコードは既に求めていること。
            if(/cust|prd|pur|shp/.test(screenCode)&&/schs|ords/.test(screenCode)&&lineData[qty_case]===""){
                qty_case = id.split("_")[0] + "_qty_case" 
                    if(Number(lineData["opeitm_packqty"])===0){  //opeitm_packqtyは購入時・作成後の完成時の単位
                        lineData[qty_case] = lineData[id] 
                        autoAddFields[qty_case] = lineData[qty_case]
                        
                    }else{
                        lineData[id]  = String(Math.ceil(lineData[id]/lineData["opeitm_packqty"])*lineData["opeitm_packqty"])
                        lineData[qty_case] =  String(Math.ceil(lineData[id]/lineData["opeitm_packqty"]))}
                        autoAddFields[qty_case] = lineData[qty_case]
            }
                //
            break

        case /_invoiceno/.test(id):
            if(lineData[gno]!==""){
                gno = id.split("_")[0] + "_gno"
                //opeitm_packqtyは購入時・作成後の完成時の単位
                lineData[gno] = lineData[id] 
                autoAddFields[gno] = lineData[gno]
            } 
            break
        case /^loca_code_cust$/.test(id):
            if(screenCode.match(/custords|custschs/)){
                if(lineData["loca_code_custrcvplc"]===""){
                    lineData["loca_code_custrcvplc"] = lineData[id]
                    autoAddFields["loca_code_custrcvplc"] = lineData["loca_code_custrcvplc"]
                }
            }
            break
        // case /locas_code_shelfno_to_opeitm/.test(id):
        //     if(screenCode.match(/custords|custschs/)&&lineData["loca_code_shelfno_fm"] ===""){
        //                 lineData["loca_code_shelfno_fm"] = lineData[id]
        //                 autoAddFields["loca_code_shelfno_fm"] = lineData["loca_code_shelfno_fm"]
        //     }
        //     break
        // case /shelfno_code_fm_opeitm/.test(id):
        //         if(screenCode.match(/custords|custschs/)&&lineData["shelfno_code_fm"] ===""){
        //             lineData["shelfno_code_fm"] = lineData[id]
        //             autoAddFields["shelfno_code_fm"] = lineData["shelfno_code_fm"]
        //         }
        //     break
        default:
             break    
        }
       
    return  lineData,autoAddFields
}