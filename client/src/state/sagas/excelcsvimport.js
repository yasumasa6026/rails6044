import { call, put, select } from 'redux-saga/effects'
import { SETRESULTS_SUCCESS, MENU_FAILURE, } from '../../actions'
import {getScreenState} from '../reducers/screen'
import ExcelJS from 'exceljs'

import {yupErrCheckBatch,} from '../../components/yuperrcheckbatch'

function readExcel({excelfile}){
    const workbook = new ExcelJS.Workbook();
    workbook.xlsx.readFile(excelfile)
    return workbook.worksheets //最初のシートのみ処理対象
}

// set fields  [aa,bbb]  --> {f1:aa,f2:bb}
function batchcheck(sheet,nameToCode) {
    let lines = []
    let header = []
    let orgheader = []
    let errorheader = false
    let linedata
    let importdata = []
    let importError = false
    header.push("confirm")
    orgheader.push("confirm")
    nameToCode["aud"] = "aud"
    sheet.map((row,index)=>{
        linedata = {}
        if(index===0){
            row.map((colunm,idx)=>{
                orgheader.push(colunm)
                if(nameToCode[colunm]){
                    if(header.indexOf(nameToCode[colunm])===-1){
                              header.push(nameToCode[colunm])
                    }else{
                              header.push(`duplicate field error ${idx+1}`)
                              errorheader = true
                               }
                    }
                else{header.push(`field error ${idx+1}`)
                          errorheader = true}      
                    return header
                })
                header.map((colunm,idx)=>{
                  linedata[colunm] = orgheader[idx]
                  return linedata
                })  
        }else{
            row.map((colunm,idx)=>{
                        linedata[header[idx+1]] =  colunm
                        return linedata
                      })
            }
            lines.push(linedata)
            return lines
          })
    if(errorheader){
        lines[0]["confirm"] = "field error"
        importError = true
        importdata = Array.from(lines)
    }else{
          importdata = Array.from(lines)
    } 
    return {importdata,importError}
  }


export function* ExcelCsvImportSaga({ payload: {excelfile,nameToCode,screenCode} }) {
    let message 
        try{
            let sheets = yield call(readExcel,{excelfile})
            if(sheets[screenCode]===sheets[0]){
                let tmpJson = []
                let sheetFirst = sheets[0]
                sheetFirst.eachRow(function(row, rowNumber) {
                    tmpJson.push(JSON.stringify(row.values)
                )})
                let {importdata,batchcheckError} = batchcheck(tmpJson,nameToCode)
                if(batchcheckError){
                    message = `excel read error ${excelfile} Screen Code :${screenCode}
                                errCode:${batchcheckError}`
                    yield put({ type: MENU_FAILURE, errors: message })
                }else{
                    let {importdataCheckMaster,importErrorCheckMaster} = yupErrCheckBatch(importdata,screenCode)
                    if(importErrorCheckMaster){
                            message = `check_master write error ${excelfile.name} Screen Code :${screenCode}`
                            yield put({ type: MENU_FAILURE, errors: message  ,importError:true })
                        }else{
                            try{
                                yield call(exportFromJSON,{importdata:importdataCheckMaster,excelfile,screenCode })
                                payload ={results:importdataCheckMaster,complete:false,importError:importError}
                                yield put({ type: SETRESULTS_SUCCESS,payload:payload})
                                }   
                                catch(e){
                                    let message 
                                message = `excel read error ${excelfile.name} Screen Code :${screenCode}`
                                yield put({ type: MENU_FAILURE, errors: message  ,importError:true})
                                }
                            }
                }
            }else{
                message = `excel sheetName error ${excelfile} Screen Code :${screenCode}`
                yield put({ type: MENU_FAILURE, errors: message })}    
        }catch(e){
                    message = `excel read error ${excelfile} Screen Code :${screenCode}`
                    yield put({ type: MENU_FAILURE, errors: message })
                }
        try{                                                    
                    yield call(exportFromJSON,{importdata:results,excelfile,screenCode })
                    payload = {results:results,complete:false,importError:importError}  //importError:データチェック等のエラー
                    yield put({type:SETRESULTS_SUCCESS,payload:payload}) 
                    }
                    catch(e){  //network等のエラー
                        let message 
                        message = `add_update file write error ${excelfile.name} Screen Code :${screenCode}`
                        yield put({ type: MENU_FAILURE, errors: message , importError:true})
                        }   
             try{
                 payload ={results,complete:true,importError:importError}
                 yield put({type:SETRESULTS_SUCCESS, payload:payload})
             }
             catch(e){
                 message = ` add update error ${excelfile.name} Screen Code :${screenCode}`
                 yield put({ type: MENU_FAILURE, errors:message, importError:true})
             }
    }
 