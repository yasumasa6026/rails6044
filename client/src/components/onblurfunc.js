import moment from 'moment'
import { yupErrCheck } from './yuperrcheck'
import { yupschema } from '../yupschema'
//yupでできなかったこと
//検索項目では　xxxx_gridmessage = in は意味がない。　検索結果がセットされるため。
// 項目の順番が制限される。

export function  onBlurFunc7(screenCode,lineData,id){  //id:field
    let starttime
    let toduedate
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
        default:
             break    
        }
       
    return  lineData,autoAddFields
}


export function   onFieldValite (linedata, field, screenCode) {  // yupでは　2019/12/32等がエラーにならない
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
    linedata = yupErrCheck(schema,field,linedata)
    return linedata
}


export function fetchCheck(linedata,id,fetch_check) {
    let fetchCheckFlg 
    let idKeys=[]
    let newRow = {}
    //
    if(fetch_check.fetchCode[id]){
        let flg = true
        Object.keys(fetch_check.fetchCode).map((key,idx)=>{  //複数key対応
            if(fetch_check.fetchCode[id]===fetch_check.fetchCode[key]){
                if(linedata[key]===""||linedata[key]===undefined){
                    flg = false
                return  idKeys
                }
                else(idKeys.push({[key]:linedata[key]}))
            }
            return idKeys
        })
        if(flg){
            Object.keys(linedata).map((key,idx)=>{  //複数key対応
                if(/_gridmessage/.test(key)){}
                else{newRow[key]=linedata[key]}
                return ""
            })
            // params = {...params,fetchCode: JSON.stringify(idKeys),linedata: JSON.stringify(row),
            //                                      index: index,fetchview: fetch_check.fetchCode[id],buttonflg: "fetch_request"}
        //handleFetchRequest(params,data) //onBlurFunc7でセットされた項目はfetchでまとめて更新
        fetchCheckFlg = "fetch_request"
        }else{}//未入力keyがある。  
    }
    //else{updateLineData(index,data,autoAddFields) } //onBlurFunc7でセットされた項目を画面に反映
    
    if(fetch_check.checkCode[id]){
     let chkcondtion = fetch_check.checkCode[id].split(",")[1]
     if (chkcondtion === undefined || (chkcondtion === "add" & linedata[id] === "") ||
         (chkcondtion === "update" & linedata[id] !== "")) {
        //  params = {...params,
        //                        checkCode: JSON.stringify({ [id]: fetch_check.checkCode[id] }),
        //                        linedata: JSON.stringify(linedata),
        //                        index: index,buttonflg: "check_request"}
     //handleFetchRequest(params)
     //break
     fetchCheckFlg = "check_request"
     }
    }
    //if(fetchCheckFlg){handleFetchRequest(params,data)}
    return {fetchCheckFlg,idKeys,newRow}
}

