import { call, put, select } from 'redux-saga/effects'
import axios         from 'axios'
import {SCREEN_SUCCESS7,SCREEN_FAILURE,SCREEN_CONFIRM7, FETCH_RESULT, FETCH_FAILURE,
        SECOND_SUCCESS7,SECOND_FAILURE,SECOND_CONFIRM7, SECONDFETCH_RESULT,
        SECONDFETCH_FAILURE,MKSHPORDS_SUCCESS,MKSHPACTS_RESULT,CONFIRMALL_SUCCESS,
        }
         from '../../actions'
import {getButtonState} from '../reducers/button'

function screenApi({params ,url,headers} ) {
  
    return axios({
        method: "POST",
        url: url,
        contentType: "application/json",
        params:{...params,data:[]},
        headers:headers,
    })
  }

 // const delay = (ms) => new Promise(res => setTimeout(res, ms)) 
export function* ScreenSaga({ payload: {params,data,}  }) {
  const buttonState = yield select(getButtonState) //buttonStateの変更は不可　思わぬことが発生。
  let token = params.token       
  let client = params.client         
  let uid = params.uid
  let url = ""
  let tmp 
  // let sagaCallTime = new Date()
  // let callTime =  sagaCallTime.getHours() + ":" + sagaCallTime.getMinutes() + ":" + 
  //             
  url = 'http://localhost:3001/api/menus7'

  const headers = {'access-token':token,'client':client,'uid':uid }
    let message
    let messages = []
    // while (loading===true) {
    //   console.log("delay")
    //   yield delay(100)
    // }
    let xparams = {}
    //params["fetch_data"] = ""  //net error 対策　1024*10 送信時は不要
    try{
      let response  = yield call(screenApi,{params ,url,headers} )
      // params.sortBy === [] だとrailsに取り込められない　paramsからsortByが
      params = {...params,req:response.data.params.req,screenFlg:response.data.params.screenFlg,screenCode:response.data.params.screenCode}
      switch (response.status) {
        case 200:  
          switch(params.req) {
            case 'viewtablereq7':
            case 'inlineedit7':   //第一画面又は第二画面のみ　両方修正は不可
            case 'inlineadd7':
              if(params.screenFlg==="second")
                  {return yield put({type:SECOND_SUCCESS7,payload:response })}
              else
                  {return yield put({ type:SCREEN_SUCCESS7, payload: response })}
            case "confirm7":
              data[params.index] = {...response.data.linedata}
              params.req = buttonState.buttonflg
              if(params.screenFlg==="second")
                {return yield put({type:SECOND_CONFIRM7,payload:{data:data,params:params} })}
              else
                {return yield put({type:SCREEN_CONFIRM7,payload:{data:data,params:params} })} 
            case "mkShpords":  //
              messages[0] = "out count : " + response.data.outcnt
              messages[1] = "shortage count : " + response.data.shortcnt
              return yield put({ type: MKSHPORDS_SUCCESS, payload:{messages:messages}})       
           
            case "mkShpinsts":  //second画面出力専用　第一画面の修正、追加は不可
                return yield put({ type:SECOND_SUCCESS7, payload:response})
                
            case "mkshpacts":  //second画面専用
              return yield put({ type: MKSHPACTS_RESULT, payload:response})    
              
            case "confirm_all":  //second画面専用
              messages[0] = "out count : " + response.data.outcnt
              return yield put({ type: CONFIRMALL_SUCCESS, payload:{messages:messages}})     
       
           case "fetch_request":  //viewによる存在チェック内容表示
                xparams = {...params,...response.data.params}
                xparams.req = buttonState.buttonflg
                break
            case "check_request":   //項目毎のチェック帰りはfetchと同じ
                xparams = {...params,...response.data.params}
                break      
            default:
                return {}
            }
          if(response.data.params.err){
                if(params.screenFlg==="second"){
                    yield put({ type: SECONDFETCH_FAILURE,payload:{params:xparams}}) 
                }else{
                    yield put({ type: FETCH_FAILURE, payload:{params:xparams}}) 
                }
          }else{
                if(params.screenFlg==="second"){
                    yield put({type: SECONDFETCH_RESULT, payload:{params:xparams}}) 
                }else{  
                    yield put({type: FETCH_RESULT, payload:{params:xparams}}) 
                }  
          }  
          break  
        case 500: message = `${response.status}: Internal Server Error ${response.statusText}`
                    data[params.index]["confirm_gridmessage"] = message
                    break
        case 401: message = `${response.status}: Invalid credentials or Login TimeOut ${response.statusText}`
                    data[params.index]["confirm_gridmessage"] = message
                    break
        default:
                    data[params.index]["confirm_gridmessage"] = message
                    message = `${response.status}: Screen Something went wrong ${response.statusText} `
      }
      if(params.screenFlg==="second"){
            return  yield put({type:SECOND_FAILURE,payload:{message:message,data}})   
      }else{  
            return  yield put({type:SCREEN_FAILURE,payload:{message:message,data}})   
      }
    }
    catch(e){
        switch (true) {
            case /code.*500/.test(e): message = `${e}: Internal Server Error `
                  return  yield put({type:SCREEN_FAILURE, payload:{message:message,data}})   
            case /code.*401/.test(e): message = ` Invalid credentials  Unauthorized or Login TimeOut ${e}`
                    return  yield put({type:SCREEN_FAILURE, payload:{message:message,data}})   
            default:
                message = ` Screen Something went wrong ${e} `
                      return  yield put({type:SCREEN_FAILURE, payload:{message:message,data}})   
      }
    }
  }
