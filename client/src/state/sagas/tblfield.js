import { call, put, } from 'redux-saga/effects'
import axios         from 'axios'
import {TBLFIELD_SUCCESS, SCREEN_FAILURE,SECOND_FAILURE,
        }     from '../../actions'

function screenApi({params,token,client,uid}) {
  const url = 'http://localhost:3001/api/tblfields'
  const headers = {'access-token':token,'client':client,'uid':uid }

    return axios({
        method: "POST",
        url: url,
        contentType: "application/json",
        params:params,
        headers:headers,
    })
}

export function* TblfieldSaga({ payload: {params}  }) {
  let token = params.token       
  let client = params.client         
  let uid = params.uid   
  
  let message
  try{
    let response  = yield call(screenApi,{params ,token,client,uid} )
      switch(response.status){
        case 200:
          switch(params.req) {
            case "yup":  // create yup schema
              return yield put({ type: TBLFIELD_SUCCESS, payload: {message:response.data.params.message} })   
            case  "createTblViewScreen":  // create  or add field table and create or replacr view  and create screen
              return yield put({ type: TBLFIELD_SUCCESS, payload: {messages:response.data.params.messages} })  
            case "createUniqueIndex":  // create  or add field table and create or replacr view  and create screen
              return yield put({ type: TBLFIELD_SUCCESS, payload: {messages:response.data.params.messages} })        
            default:
              return {}
          }
        case 500:
              message = `Internal Server Error ${response.data.params.errmsg} `
              if(params.screenFlg==="second"){
                return  yield put({type:SECOND_FAILURE, payload:{message:message,data}})   
              }else{  
                return  yield put({type:SCREEN_FAILURE, payload:{message:message,data}})   
              }   
        default:
              return {}
        }    
  }catch(e) {   
        switch (true) {
          case /code.*500/.test(e): message = `${e}: Internal Server Error `
              if(params.screenFlg==="second"){
                return  yield put({type:SECOND_FAILURE, payload:{message:message,data}})   
              }else{  
                return  yield put({type:SCREEN_FAILURE, payload:{message:message,data}})   
              }
          case /code.*401/.test(e): message = ` Invalid credentials  Unauthorized or Login TimeOut ${e}`
              if(params.screenFlg==="second"){
                  return  yield put({type:SECOND_FAILURE, payload:{message:message,data}})   
              }else{  
                  return  yield put({type:SCREEN_FAILURE, payload:{message:message,data}})   
              }
          default:
              message = ` TblFields Something went wrong ${e} `
                if(params.screenFlg==="second"){
                    return  yield put({type:SECOND_FAILURE, payload:{message:message,data}})   
                }else{  
                    return  yield put({type:SCREEN_FAILURE, payload:{message:message,data}})   
              }
        }
      }
 }      