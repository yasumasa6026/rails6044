import { call, put, select } from 'redux-saga/effects'
import axios         from 'axios'
import {SCREEN_SUCCESS7,SCREEN_FAILURE,SCREEN_CONFIRM7_SUCCESS, FETCH_RESULT, FETCH_FAILURE,
        SECOND_SUCCESS7,SECOND_FAILURE,SECOND_CONFIRM7_SUCCESS, SECONDFETCH_RESULT,
        SECONDFETCH_FAILURE,MKSHPORDS_SUCCESS,CONFIRMALL_SUCCESS,SECOND_CONFIRMALL_SUCCESS,
        //MKSHPACTS_RESULT,
        }
         from '../../actions'
import {getAuthState} from '../reducers/auth'

function screenApi({params ,url,headers} ) {
  
    return axios({
        method: "POST",
        url: url,
        contentType: "application/json",
        params:{...params,data:[],parse_linedata:{}},  //railsではscreen全ての情報を送れない。send lenggth max errorになる。(1024*・・・
        headers:headers,
    })
  }

 // const delay = (ms) => new Promise(res => setTimeout(res, ms)) 
export function* ScreenSaga({ payload: {params}  }) {
  const auth = yield select(getAuthState) //
  let url = ""
  let tmp 
  // let sagaCallTime = new Date()
  // let callTime =  sagaCallTime.getHours() + ":" + sagaCallTime.getMinutes() + ":" + 
  //             
  url = 'http://localhost:3001/api/menus7'

  const headers = {'access-token':auth.token,'client':auth.client,'uid':auth.uid }
    let message
    let messages = []
    let lineData
    // while (loading===true) {
    //   console.log("delay")
    //   yield delay(100)
    // }
    //params["fetch_data"] = ""  //net error 対策　1024*10 送信時は不要
    try{
      let response  = yield call(screenApi,{params ,url,headers} )
      // params.sortBy === [] だとrailsに取り込められない　paramsからsortByが
      switch (response.status) {
        case 200: 
          switch(response.data.params.buttonflg) {
            case 'viewtablereq7':
            case 'inlineedit7':   //第一画面又は第二画面のみ　両方修正は不可  更新画面要求
            case 'inlineadd7':  //追加画面要求
              params = {...response.data.params,err:null,parse_linedata:{},index:0,clickIndex:[]}
              if(params.screenFlg==="second")
                  {return yield put({type:SECOND_SUCCESS7,payload:{data:response.data,params:{...params,index:-1}} })}
              else
                  {return yield put({ type:SCREEN_SUCCESS7, payload:{data:response.data,params:{...params,index:-1}}})}
            case "confirm7":  //データ更新時のEnteのbuttonflgはinlineedit7やinlineadd7ではなくてconfirm7になる。更新実行
              lineData  = response.data.params.parse_linedata
              params = {...params,screenFlg:response.data.params.screenFlg,
                          screenCode:response.data.params.screenCode,err:response.data.params.err,index:parseInt(params.index)}
              if(params.screenFlg==="second")
                {  params = {...params,lineData:response.data.params.pareLineData,head:response.data.params.head}
                   yield put({type:SECOND_CONFIRM7_SUCCESS,payload:{lineData:lineData,index:parseInt(params.index),params:params} })
                }
              else
                {yield put({type:SCREEN_CONFIRM7_SUCCESS,payload:{lineData:lineData,index:parseInt(params.index),params:params} })}
              return   
            case "fetch_request":  //viewによる存在チェック内容表示
            case "check_request":   //項目毎のチェック帰りはfetchと同じ
                    lineData = response.data.params.parse_linedata
                     params = {...params,...response.data.params,screenFlg:response.data.params.screenFlg,
                                 screenCode:response.data.params.screenCode,err:response.data.params.err} 
                     if(response.data.params.err){
                                 if(params.screenFlg==="second"){
                                    yield put({ type: SECONDFETCH_FAILURE,payload:{params:params,index:parseInt(params.index),lineData:lineData}}) 
                                 }else{
                                    yield put({ type: FETCH_FAILURE, payload:{params:params,index:parseInt(params.index),lineData:lineData}}) 
                                 }
                     }else{
                                 if(params.screenFlg==="second"){
                                     yield put({type: SECONDFETCH_RESULT, payload:{params:params,index:parseInt(params.index),lineData:lineData}}) 
                                 }else{  
                                     yield put({type: FETCH_RESULT, payload:{params:params,index:parseInt(params.index),lineData:lineData}}) 
                                 }  
                               }
                    return  
            case "delete":
                  data[parseInt(params.index)] = {...response.data.params.parse_linedata}
                  params = {...params,buttonflg:response.data.params.buttonflg,screenFlg:response.data.params.screenFlg,screenCode:response.data.params.screenCode}
                  if(params.screenFlg==="second")
                    {return yield put({type:SECOND_CONFIRM7_SUCCESS,payload:{data:data,params:params} })}
                  else
                    {return yield put({type:SCREEN_CONFIRM7_SUCCESS,payload:{data:data,params:params} })} 
            case "mkShpords":  //
              messages[0] = "out count : " + response.data.outcnt
              messages[1] = "shortage count : " + response.data.shortcnt
              return yield put({ type: MKSHPORDS_SUCCESS, payload:{messages:messages}})       
           
            // case "mkShpinsts":  //second画面出力専用　第一画面の修正、追加は不可
            //      return yield put({ type:SECOND_SUCCESS7, payload:response})
                
            // case "mkshpacts":  //second画面専用
            //   return yield put({ type: MKSHPACTS_RESULT, payload:response})    
              
           case "confirmAll":  //
           case "MkPackingListNo":  //
               messages[0] = "out count : " + response.data.outcnt
               messages[1] = "out qty : " + response.data.outqty
               messages[2] = "out amt : " + response.data.outamt
                return yield put({ type: CONFIRMALL_SUCCESS, payload:{messages:messages}})     
              
            case "confirmSecond":  //second画面専用
              messages[0] = "out count : " + response.data.outcnt
              return yield put({ type: SECOND_CONFIRMALL_SUCCESS, payload:{messages:messages}})     
            default:
                            }
            break       
       
        case 500: message = `error ${response.status}: Internal Server Error ${response.statusText}`
                    break
        case 401: message = `error ${response.status}: Invalid credentials or Login TimeOut ${response.statusText}`
                    break
        case 202:
              params = response.data.params
              if(params.screenFlg==="second"){
                  return  yield put({type:SECOND_FAILURE,payload:{message: response.data.err,}})   
              }else{  
                  return  yield put({type:SCREEN_FAILURE,payload:{message:response.data.err,}})   
              }
        default:
                  message = `error ${response.status}: Screen Something went wrong ${response.statusText} `
                    break      
      }
      if(params.screenFlg==="second"){
            return  yield put({type:SECOND_FAILURE,payload:{message:message,}})   
      }else{  
            return  yield put({type:SCREEN_FAILURE,payload:{message:message,}})   
      }
    }
    catch(e){
        switch (true) {
            case /code.*500/.test(e): message = `${e}: Internal Server Error `
                  return  yield put({type:SCREEN_FAILURE, payload:{message:message,params}})   
            case /code.*401/.test(e): message = ` Invalid credentials  Unauthorized or Login TimeOut ${e}`
                    return  yield put({type:SCREEN_FAILURE, payload:{message:message,params}})   
            default:
                message = `catch  Screen Something went wrong ${e} `
                      return  yield put({type:SCREEN_FAILURE, payload:{message:message,params}})   
      }
    }
  }
