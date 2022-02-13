import { call, put, select } from 'redux-saga/effects'
import axios         from 'axios'
import {SCREEN_SUCCESS7,SCREEN_FAILURE,SCREEN_LINEEDIT, FETCH_RESULT, FETCH_FAILURE,
        SECONDSCREEN_SUCCESS7,SECONDSCREEN_FAILURE,SECONDSCREEN_LINEEDIT, SECONDFETCH_RESULT,
        SECONDFETCH_FAILURE,MKSHPINSTS_SUCCESS,MKSHPACTS_RESULT,CONFIRMALL_SUCCESS,
        }
         from '../../actions'
import {getLoginState} from '../reducers/auth'
import {getButtonState} from '../reducers/button'
//import { ReactReduxContext } from 'react-redux';

function screenApi({params ,url,headers} ) {
  
    return axios({
        method: "POST",
        url: url,
        contentType: "application/json",
        params:params,
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
    params["fetch_data"] = ""  //net error 対策　1024*10 送信時は不要
    try{
      let response  = yield call(screenApi,{params ,url,headers} )
      console.log(response)
      switch (response.status) {
        case 200:  
          switch(params.req) {
            case 'viewtablereq7':
            case 'inlineedit7':
            case 'inlineadd7':
              if(params.second===true){
                return yield put({ type:SECONDSCREEN_SUCCESS7, payload:response})}
              else{
                return yield put({ type:SCREEN_SUCCESS7, payload: response })   
              }      
            case "confirm7":
              data[params.index] = {...response.data.linedata}
              params.req = buttonState.buttonflg
              if(params.second===true){
                  return yield put({type:SECONDSCREEN_LINEEDIT,payload:{data:data,params:params}})}
              else{
                  return yield put({type:SCREEN_LINEEDIT,payload:{data:data,params:params} })   
              }      

            case "mkshpinsts":  //second画面専用
              params.req =  "mkshpinsts"
              messages[0] = "out count : " + response.data.outcnt
              messages[1] = "shortage count : " + response.data.shortcnt
              return yield put({ type: MKSHPINSTS_SUCCESS, payload:{messages:messages}})       
           
            case "mkshpacts":  //second画面専用
              params.req = "mkshpacts"
              return yield put({ type: MKSHPACTS_RESULT, payload:response})    
              
            case "confirm_all":  //second画面専用
              messages[0] = "out count : " + response.data.outcnt
              return yield put({ type: CONFIRMALL_SUCCESS, payload:{messages:messages}})     
           
            case "refshpacts":  //second画面専用
                params.req = "refshpacts"
                return yield put({ type: SECONDSCREEN_SUCCESS7, payload:response})       

            case "fetch_request":  //viewによる存在チェック内容表示
              let tmp 
              xparams = {...response.data.params}
              xparams.req = buttonState.buttonflg
              data[params.index].confirm_gridmessage =  "ok"
              if(response.data.params.err){
                  tmp =  JSON.parse(response.data.params.fetchcode) //javascript -->rails hush で渡せず
                  tmp.map((idx)=>{
                    data[params.index][`${Object.keys(idx)[0]}_gridmessage`] = response.data.params.err
                    data[params.index].confirm_gridmessage =  response.data.params.err
                  return null
                 })
                }
                else{
                  //tmp =  JSON.parse(response.data.params.fetch_data)
                   Object.keys(response.data.params.fetch_data).map((idx)=>{
                             data[params.index][idx]= response.data.params.fetch_data[idx]
                             if(response.data.params.fetch_data[idx]==="")
                                         {data[params.index][`${idx}_gridmessage`] = "on the way"}
                                     else{data[params.index][`${idx}_gridmessage`] = "detected"}
                     return null
                   })
              }    
              break
            case "check_request":   //項目毎のチェック帰りはfetchと同じ
                  xparams = {...response.data.params}
                //  xparams.req = buttonState.buttonflg
                  data[params.index].confirm_gridmessage =  "ok"
                  if(response.data.params.err){
                       tmp =  JSON.parse(response.data.params.checkcode)
                       Object.keys(tmp).map((idx)=>{
                         data[params.index][`${idx}_gridmessage`] = response.data.params.err
                         data[params.index].confirm_gridmessage =  response.data.params.err
                       return null
                      })
                  }
                  else{
                       tmp =  JSON.parse(response.data.params.checkcode)
                       Object.keys(tmp).map((idx)=>{
                         data[params.index][`${idx}_gridmessage`] = "ok check"
                       return data
                       })
                      //  tmp = response.data.params.linedata
                      //  Object.keys(tmp).map((idx)=>{
                      //    data[params.index][idx] = tmp[idx]
                      //  return null
                      //  })
                    }
                  break      
              // case "yup":  // create yup schema
              //       return yield put({ type: YUP_RESULT, payload: {message:response.data.params.message} })    
              default:
                return {}
            }
            if(response.data.params.err){
                if(params.second===true){
                    yield put({ type: SECONDFETCH_FAILURE,payload:{data:data,params:xparams}}) 
                }else{
                    yield put({ type: FETCH_FAILURE, payload:{data:data,params:xparams}}) 
                }
            }else{
                if(params.second===true){
                    yield put({type: SECONDFETCH_RESULT, payload:{data:data,params:xparams}}) 
                }else{  
                    yield put({type: FETCH_RESULT, payload:{data:data,params:xparams}}) 
                }  
            }  
            break  
            case 500: message = `${response.status}: Internal Server Error ${response.statusText},${response.errore}`
                    data[params.index]["confirm_gridmessage"] = message
                    break
            case 401: message = `${response.status}: Invalid credentials ${response.statusText},${response.errore}`
                    data[params.index]["confirm_gridmessage"] = message
                    break
            default:
                    data[params.index]["confirm_gridmessage"] = message
                    message = `${response.status}: Something went wrong ${response.statusText},${response.errore}`
      }
      if(params.second===true){
            return  yield put({type:SECONDSCREEN_FAILURE,payload:{message:message,data}})   
      }else{  
            return  yield put({type:SCREEN_FAILURE,payload:{message:message,data}})   
      }
    }
    catch(e){
      message = ` Something went wrong ${e} `
      if(params.index){data[params.index]["confirm_gridmessage"] = message}
        else{}      
      if(params.second===true){
            return  yield put({type:SECONDSCREEN_FAILURE, payload:{message:message,data}})   
      }else{  
            return  yield put({type:SCREEN_FAILURE, payload:{message:message,data}})   
      }
    }
  }
