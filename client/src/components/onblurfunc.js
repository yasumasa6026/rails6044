//import moment from 'moment'
import { yupErrCheck } from './yuperrcheck'
import { yupschema } from '../yupschema'
//yupでできなかったこと
//検索項目では　xxxx_gridmessage = in は意味がない。　検索結果がセットされるため。
// 項目の順番が制限される。

export function  onBlurFunc7(screenCode,lineData,id){  //id:field
    let starttime
    let toduedate
    let yymmdd
    let qty_case
    let gno
    let autoAddFields = {}
    let itm_code_client
    lineData["confirm_gridmessage"] = "ok"
    switch( true ){
        case /itm_code$/.test(id)://ScreenLib.proc_add_empty_dataで対応
            if(/custschs|custords/.test(screenCode)){ //受注の時はopeitmのLT(duration)は使用できない。
                itm_code_client = id.split("_")[0] + "_itm_code_client"
                if(lineData[itm_code_client]===""){
                    lineData[itm_code_client] = lineData[id] 
                    autoAddFields[itm_code_client] = lineData[itm_code_client]}
                }
            break
        //starttime 将来部署別のカレンダーでrailsで求める。 prdord_commencementdate
        case /_duedate/.test(id):
                //moment.defaultFormat = "YYYY-MM-DD HH:mm"
                starttime = id.split("_")[0] + "_starttime" 
                //if(lineData[starttime]===""||lineData[starttime]===undefined||lineData[starttime]===null){
                if(lineData[starttime]===""){
                        yymmdd = new Date(lineData[id]) 
                    if(/cust/.test(screenCode)){ //受注の時はopeitmのLT(duration)は使用できない。
                        yymmdd = new Date(yymmdd.setDate(yymmdd.getDate() - 1))
                        lineData[starttime] = yymmdd.getFullYear()+"-"+(yymmdd.getMonth()+1)+"-"+yymmdd.getDate()+" "+yymmdd.getHours()+":"+yymmdd.getMinutes()
                        autoAddFields[starttime] = lineData[starttime]
                    }
                    else{
                        yymmdd = new Date(yymmdd.setDate(yymmdd.getDate() - parseFloat(lineData["opeitm_duration"])))
                        lineData[starttime] = yymmdd.getFullYear()+"-"+(yymmdd.getMonth()+1)+"-"+yymmdd.getDate()+" "+yymmdd.getHours()+":"+yymmdd.getMinutes()
                        autoAddFields[starttime] = lineData[starttime]
                        if(lineData["prdord_commencementdate"]===""){
                            lineData["prdord_commencementdate"] = lineData[starttime] 
                            autoAddFields["prdord_commencementdate"] = lineData[starttime]                            
                        }
                    }       
                }
                toduedate = id.split("_")[0] + "_toduedate" 
                if(lineData[toduedate]===""){
                        lineData[toduedate] = lineData[id] 
                        autoAddFields[toduedate] = lineData[toduedate]
                }
            break
        case /_qty_sch$|_qty$|qty_stk$/.test(id):  //opeitmsのレコードは既に求めていること。
            qty_case = id.split("_")[0] + "_qty_case" 
            if(/cust|prd|pur|shp/.test(screenCode)&&/schs|ords/.test(screenCode)&&lineData[qty_case]===0){
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
            if(screenCode.match(/custord|custsch/)){
                if(lineData["loca_code_custrcvplc"]===""){
                    lineData["loca_code_custrcvplc"] = lineData[id]
                    autoAddFields["loca_code_custrcvplc"] = lineData["loca_code_custrcvplc"]
                }
            }
            break
        default:
             break    
        }
       
    return  lineData,autoAddFields
}


export function   onFieldValite (lineData, field, screenCode) {  // yupでは　2019/12/32等がエラーにならない
    let Yup = require('yup')    
    let fieldSchema = (field, screenCode) => {
      let tmp = {}
      tmp[field] = yupschema[screenCode][field]
      return (
        Yup.object(
          tmp
        ))
    }
    
    let schema = fieldSchema(field, screenCode)
    lineData = yupErrCheck(schema,field,lineData)
    return lineData
}


export function fetchCheck(lineData,id,fetch_check) {
    let fetchCheckFlg 
    let idKeys=[]
    //
    if(fetch_check.fetchCode[id]){
        let flg = true
        Object.keys(fetch_check.fetchCode).map((key,idx)=>{  //複数key対応
            if(fetch_check.fetchCode[id]===fetch_check.fetchCode[key]){
                if(lineData[key]===""||lineData[key]===undefined){
                    flg = false
                return  idKeys
                }
                else(idKeys.push({[key]:lineData[key]}))
            }
            return idKeys
        })
        if(flg){
        fetchCheckFlg = "fetch_request"
        }else{}//未入力keyがある。  
    }
    //else{updateLineData(index,data,autoAddFields) } //onBlurFunc7でセットされた項目を画面に反映
    else{
        if(fetch_check.checkCode[id]){
            fetchCheckFlg = "check_request"
            }else{fetchCheckFlg=""}
        }
    return {fetchCheckFlg,idKeys}
}

