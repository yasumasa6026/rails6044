import { call, put,  } from 'redux-saga/effects'
import { IMPORTEXCEL_FAILURE, IMPORTEXCEL_SUCCESS,} from '../../actions'
import ExcelJS from 'exceljs'  //readはうまくいかない。
import {saveAs} from "file-saver"
import readXlsxFile from 'read-excel-file'
import axios         from 'axios'
import {yupErrCheckBatch,} from '../../components/yuperrcheckbatch'

function readExcel({excelfile}){
    let tmp = readXlsxFile(excelfile).then((results) => {
        return results
      })
    return tmp  
}

// set fields  [aa,bb]  --> {f1:aa,f2:bb} header check
function batchcheck(sheet,nameToCode,screenCode) {
    let lines = []
    let header = []
    let errHeader = []
    let formatError = false
    let lineData = {}
    let tblchop = screenCode.split("_")[1].slice(0,-1)
    header.push("confirm")
    header.push(`${tblchop}_confirm_gridmessage`)
    nameToCode["aud"] = "aud"   //追加・変更コマンドがエラーにならないため
    sheet.map((row,index)=>{
        lineData["confirm"] = true
        lineData[`${tblchop}_confirm_gridmessage`] = ""
        if(index===0){
            row.map((column,idx)=>{
                lineData[column] = column //オリジナルのヘッダー
                if(nameToCode[column]){
                    if(header.indexOf(nameToCode[column])===-1){
                              header.push(nameToCode[column])
                    }else{
                              errHeader.push(`duplicate field error ${nameToCode[column]}`)
                              formatError = true
                               }
                    }
                else{   errHeader.push(`Screen Code(${screenCode}) has not  ${column} field`)
                        formatError = true
                      }      
            })
        }else{
            if(formatError===false){
                row.map((val,idx)=>{
                        lineData[header[idx+2]] =  val
                        return lineData
                      })
                lines.push(lineData)}
            else{
                errHeader.push(`${tblchop}_confirm_gridmessage:"error can not proceed for above error"`)
            }
        }
        lineData = {}
    })
    return {importdata:lines,formatError:formatError,errHeader:errHeader}
  }

function sendExcelData({params,importexcel,auth}){      // ポイント2！
    const url = 'http://localhost:3001/api/importexcel'
    const token = auth.token       
    const client = auth.client         
    const uid = auth.uid 
    let importData = {}
    importData["importexcel"] = importexcel
    let dayoptions = { year: 'numeric', month: 'long', day: 'numeric' ,hour:'numeric',minute:'numeric',second:'numeric'}
    importData["title"] = (new Date()).toLocaleDateString('ja-JA', dayoptions).replace(/:/g,"-") + " imported"
    importData["filename"] = importexcel.name
    let xparams = {importData,email:auth.uid,screenCode:params.screenCode}
    const config = {
        headers: {
          'content-type': 'application/json',
         //"content-type": "multipart/form-data",
         'access-token':token,'client':client,'uid':uid,
        }
       }
    return(axios.post(url,xparams,config))
  }

function writeBuffer(workbook){
    const buffer = workbook.xlsx.writeBuffer()
    return buffer
  }

export function* ImportExcelSaga({ payload: {excelfile,nameToCode,params,auth} }) {
    let errMessage = "" 
    let screenCode = params.screenCode
        try{
            let sheetFirst = yield call(readExcel,{excelfile})
                let {importdata,formatError,errHeader} = batchcheck(sheetFirst,nameToCode,screenCode)
                if(formatError){
                    errHeader.push(`excel field error ${excelfile.name} Screen Code :${screenCode} `)
                    yield put({ type: IMPORTEXCEL_FAILURE, errHeader: errHeader,formatError:true,importErrorCheckMaster:false,errMessage:errMessage })
                }else{
                    let {importexcel,importErrorCheckMaster} = yupErrCheckBatch(importdata,screenCode)
                    if(importErrorCheckMaster){
                            errHeader.push(`check_master write error ${excelfile.name} Screen Code :${screenCode} `)
                            errMessage = "error => " +  JSON.stringify(importexcel[0])
                           yield put({ type: IMPORTEXCEL_FAILURE, errHeader: errHeader ,importErrorCheckMaster:true,errMessage:errMessage })
                    }//else{
                            try{
                                let res = yield call(sendExcelData,{params,importexcel,auth})
                                let importError = res.data.importError
                                let results = res.data.results
                                let sheetName
                                if(importError||importErrorCheckMaster){     
                                    sheetName = params.screenName + "_" + "_Import_Ng"
                                }
                                else{
                                    sheetName = params.screenName + "_" + "_Import_Ok"
                                }
                                const dataset = {columns:results.columns,data:results.rows}
                                let columns = []
                                Object.keys(dataset.columns).map((cate)=>{  //項目ごとのエラーチェック結果項目は除 _gridmessage
                                            if(dataset.columns[cate].accessor.search(/confirm_gridmessage/)>0){
                                                columns.push({header:dataset.columns[cate].Header
                                                                , key:dataset.columns[cate].accessor})}
                                            else{if(dataset.columns[cate].accessor.search(/_gridmessage/)>0){}
                                                    else{columns.push({
                                                            header:dataset.columns[cate].Header
                                                            , key:dataset.columns[cate].accessor
                                                            ,style:{fill:{ type: 'pattern', pattern: 'solid',
                                                                fgColor:{argb:dataset.columns[cate].className}},
                                                                alignment:{horizontal: dataset.columns[cate].style?dataset.columns[cate].style.textAlign:"left"}}})
                                                        }}
                                        })
                                let fileName = sheetName
                                    const workbook = new ExcelJS.Workbook()
                                    const sheet = workbook.addWorksheet(sheetName)
                                    sheet.columns = columns
                                   // sheet.addRows(dataset.data)
                                    if(importError){
                                        let errData = []
                                        dataset.data.map((line) =>{
                                            if(line.confirm){
                                                 line["style"] = "fill:{ type: 'pattern', pattern: 'solid',bgColor:{argb:'ffffff'}}"
                                                 errData.push(line)
                                             }else{
                                                 line["style"] = "fill:{ type: 'pattern', pattern: 'solid',bgColor:{argb:'FF0000'}}"
                                                 errData.push(line)
                                             }
                                         }
                                         )
                                             sheet.addRows(errData)
                                    }else{
                                             sheet.addRows(dataset.data)} 
                                let  buffer = yield call(writeBuffer,workbook)
                                const fileType =  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;charset=UTF-8'
                                const fileExtension = '.xlsx'
                                const blob = new Blob([buffer], {type: fileType})
                                saveAs(blob, fileName + fileExtension)
                                if(importError){ 
                                        yield put({ type: IMPORTEXCEL_FAILURE, errHeader: errHeader ,errMessage:errMessage})
                                        }
                                else{
                                    yield put({ type: IMPORTEXCEL_SUCCESS, idx:res.data.idx,params:params})
                                }
                            }  
                            catch(e){
                                errHeader.push(`err:${e}, ${excelfile.name}, Screen Code :${screenCode}`)
                                yield put({ type: IMPORTEXCEL_FAILURE, errHeader: errHeader ,errMessage:errMessage})
                            }
                    }
                //}
        }catch(e){
                    errMessage = `err:${e}, excel read error ${excelfile.name} Screen Code :${screenCode}`
                    yield put({ type: IMPORTEXCEL_FAILURE, errMessage: errMessage })
                }
    }
 