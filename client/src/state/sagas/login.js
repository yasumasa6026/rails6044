//api_user_session POST /api/auth/sign_in(.:format) api/auth/sessions#create
import { call, put } from 'redux-saga/effects'
import axios         from 'axios'
//import qs            from 'qs'
import {LOGIN_SUCCESS,LOGIN_FAILURE,
        //MENU_REQUEST,
        MenuRequest,ButtonListRequest
                  } from '../../actions'

function loginApi({ email, password}) {
  const url = 'http://localhost:3001/api/auth/sign_in'
  const data =  {'email':email, 'password':password  }
  axios.defaults.headers.post['Content-Type'] = 'application/json'
  //headers:{ 'Content-Type': 'application/json'},
  const options ={method:'POST',
                //  data: qs.stringify(data),
                  data: data,
                  url,}
    return (axios(options)
    .then((response ) => {
      return  {response}  
    })
    .catch(error => (
      { error }
    )))
}

export function* LoginSaga({ payload: { email, password } }) {
    let message
    let {response,error} = yield call(loginApi, { email, password} )
    switch (response.status) {
      case 200: 
      if(response || !error){
        yield put({ type: LOGIN_SUCCESS, payload: response.headers })

        
        // const token = {token:response.headers["access-token"]}
        // const client = {client:response.headers["client"]}
        // const uid = {uid:response.headers["uid"]}
        // yield put({ type: MENU_REQUEST, action: (token,client,uid) })

        yield put(MenuRequest(response.headers) )      
        yield put(ButtonListRequest(response.headers) )
      }else{  

          switch (true) {
              case /code.*500/.test(error): message = 'Internal Server Error'
               break
              case /code.*401/.test(error): message = 'Invalid credentials or Login TimeOut'
               break
              default: message = `Something went wrong ${error}`}
        yield put({ type: LOGIN_FAILURE, payload: {error:message} })
      }
        return     
      case 500: message = `error ${response.status}: Internal Server Error`
                            return  yield put({type:LOGIN_FAILURE,payload:{error:message,}})                         
      case 401: message = `error ${response.status}: Invalid credentials or Login TimeOut ${response.statusText}`
                            return  yield put({type:LOGIN_FAILURE,payload:{error:message,}})   
      case 202:
                        return  yield put({type:LOGIN_FAILURE,payload:{error:message}})   
    }
}
