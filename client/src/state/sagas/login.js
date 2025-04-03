//api_user_session POST /api/auth/sign_in(.:format) api/auth/sessions#create
import { call, put } from 'redux-saga/effects'
import axios         from 'axios'
//import qs            from 'qs'
import {LOGIN_FAILURE,
        //MENU_REQUEST,
        LOGIN_SUCCESS,MenuRequest,
        ButtonListRequest
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
    .catch(e => {     
      let hostError 
      switch (true) {
      case /code.*500/.test(e): hostError = `error ${e}: Internal Server Error`                  
      case /code.*401/.test(e): hostError = `error ${e}: Invalid credentials or Login TimeOut `
      default:          hostError = `error : Something went wrong ${e}` 
       }
       return {error:hostError}}
    )
  )
}

export function* LoginSaga({ payload: { email, password } }) {
      let {response,error} = yield call(loginApi, { email, password} )
      if(response){
        yield put({ type: LOGIN_SUCCESS, payload: response.headers })

        
        //  const token = {token:response.headers["access-token"]}
        //  const client = {client:response.headers["client"]}
        //  const uid = {uid:response.headers["uid"]}
        //  yield put({ type: MENU_REQUEST, action: (token,client,uid) })

        yield put(MenuRequest(response.headers) )      
        yield put(ButtonListRequest(response.headers) )
        return }
      if(error){ 
             return  yield put({type:LOGIN_FAILURE,payload:{error:error,}})     
        }
}