import { call, put, } from 'redux-saga/effects'
import axios         from 'axios'
import {TBLFIELD_SUCCESS, SECONDTBLFIELD_SUCCESS, SCREEN_FAILURE,SECOND_FAILURE,
        }     from '../../actions'

function screenApi({params,auth}) {
  //const url = 'http://localhost:3001/api/tblfields'
  const url = `${process.env.REACT_APP_API_URL}/tblfields`
  const headers = {'access-token':auth.token,'client':auth.client,'uid':auth.uid }

    return axios({
        method: "POST",
        url: url,
        contentType: "application/json",
        params:params,
        headers:headers,
    })
}

export function* TblfieldSaga({ payload: {params,auth}  }) {
  
  let message
  try{
    let response  = yield call(screenApi,{params ,auth} )
      switch(response.status){
        case 200:
          if(params.screenFlg==="second"){
            switch(params.buttonflg) {
              case "yup":  // create yup schema
                return yield put({ type: SECONDTBLFIELD_SUCCESS, payload: {message:response.data.params.message} })   
              case  "createTblViewScreen":  // create  or add field table and create or replacr view  and create screen
                return yield put({ type: SECONDTBLFIELD_SUCCESS, payload: {messages:response.data.params.message} })  
              case "createUniqueIndex":  // create  or add field table and create or replacr view  and create screen
                return yield put({ type: SECONDTBLFIELD_SUCCESS, payload: {messages:response.data.params.message} })        
              default:
                return {}
            }  
          }
          else{
            switch(params.buttonflg) {
              case "yup":  // create yup schema
                return yield put({ type: TBLFIELD_SUCCESS, payload: {message:response.data.params.message} })   
              case  "createTblViewScreen":  // create  or add field table and create or replacr view  and create screen
                return yield put({ type: TBLFIELD_SUCCESS, payload: {message:response.data.params.message} })  
              case "createUniqueIndex":  // create  or add field table and create or replacr view  and create screen
                return yield put({ type: TBLFIELD_SUCCESS, payload: {message:response.data.params.message} })        
              default:
                return {}
            }  
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
                return  yield put({type:SECOND_FAILURE, payload:{message:message,data:[]}})   
              }else{  
                return  yield put({type:SCREEN_FAILURE, payload:{message:message,data:[]}})   
              }
          case /code.*401/.test(e): message = ` Invalid credentials  Unauthorized or Login TimeOut ${e}`
              if(params.screenFlg==="second"){
                  return  yield put({type:SECOND_FAILURE, payload:{message:message,data:[]}})   
              }else{  
                  return  yield put({type:SCREEN_FAILURE, payload:{message:message,data:[]}})   
              }
          default:
              message = ` TblFields Something went wrong ${e} `
                if(params.screenFlg==="second"){
                    return  yield put({type:SECOND_FAILURE, payload:{message:message,data:[]}})   
                }else{  
                    return  yield put({type:SCREEN_FAILURE, payload:{message:message,data:[]}})   
              }
        }
      }
 }      