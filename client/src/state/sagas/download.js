import { call, put, } from 'redux-saga/effects'
import axios         from 'axios'
import {DOWNLOAD_SUCCESS,DOWNLOAD_FAILURE,}  from '../../actions'

import ExcelJS from 'exceljs'
import {saveAs} from "file-saver"


function screenApi({params}) {
  let token = params.token       
  let client = params.client         
  let uid = params.uid 
  let url = 'http://localhost:3001/api/menus7'
  const headers = {'access-token':token,'client':client,'uid':uid }

  const options ={method:'POST',
  //  data: qs.stringify(data),
    params: params,
    headers:headers,
    url,}
    return (axios(options))
}

function writeBuffer(workbook) {
  const buffer = workbook.xlsx.writeBuffer()
  return buffer
}

export function* DownloadSaga({ payload: {params}}) {

  let response  = yield call(screenApi,{params } )
  let message
  switch (response.status) {
    case 200:  
          yield put({ type: DOWNLOAD_SUCCESS, payload:response})   
          let dayoptions = { year: 'numeric', month: 'long', day: 'numeric' ,hour:'numeric',minute:'numeric',second:'numeric'}
          let wtime = (new Date()).toLocaleDateString('ja-JA', dayoptions).replace(/:/g,"-")
          const dataset = {columns:JSON.parse(response.data.excelData.columns),data:JSON.parse(response.data.excelData.data)}
          let columns = []
          Object.keys(dataset.columns).map((cate)=>{columns.push({
                                              header:dataset.columns[cate][1]
                                             , key:dataset.columns[cate][0]
                                             ,style:{fill:{ type: 'pattern', pattern: 'solid',bgColor:{argb:dataset.columns[cate][2]}}
                                                    ,alignment:{horizontal: dataset.columns[cate][3]}}
                                                    })})
          let fileName = params.screenName + "_" + wtime + "_Export"
          const workbook = new ExcelJS.Workbook()
          const sheet = workbook.addWorksheet(params.screenName)
          sheet.columns = columns
          sheet.addRows(dataset.data)
          
          let  buffer = yield call(writeBuffer,workbook)
          const fileType =  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;charset=UTF-8'

          const fileExtension = '.xlsx'
          
          const blob = new Blob([buffer], {type: fileType})
          saveAs(blob, fileName + fileExtension)
          break
    case 500:
           message = 'Internal Server Error'
           yield put({ type: DOWNLOAD_FAILURE, errors: message })
           break
    case 401:
            message = 'Invalid credentials'
            yield put({ type: DOWNLOAD_FAILURE, errors: message })
            break
    default:
           message = `${response.status} :downLoad Something went wrong ${response.statusText}`}
           yield put({ type: DOWNLOAD_FAILURE, errors: message })
 }
 