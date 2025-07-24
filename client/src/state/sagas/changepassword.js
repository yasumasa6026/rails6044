
import axios         from 'axios'
import { call, put ,select } from 'redux-saga/effects'
import {CHANGEPASSWORD_FAILURE, CHANGEPASSWORD_SUCCESS, } from '../../actions'
import {getAuthState} from '../reducers/auth'

function changePasswordApi({token,client,uid, current_password,password,password_confirmation}) {
  //const url = 'http://localhost:3001/api/auth/password'
  const url = `${process.env.REACT_APP_API_URL}/auth/password` 
  //auth.uid=mail
  const data =  {'email':uid,'password':password,'password_confirmation':password_confirmation  }
 //axios.defaults.headers.post['Content-Type'] = 'application/json'
 // axios.defaults.headers.post['access-token'] = token
 // axios.defaults.headers.post['client'] = client
 // axios.defaults.headers.post['uid'] = uid
 const headers = {
    'Content-Type': 'application/json',
    'access-token': token,
    'client': client,
    'uid': uid,
  }
  const options ={method:'PUT',
                  data: data,
                  headers:headers,
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
      default:hostError = `error : Something went wrong ${e}` 
       }
       return {error:hostError}}
    )
  )
}

export function* ChangePasswordSaga({ payload: { current_password,password,password_confirmation} }) {
      const auth = yield select(getAuthState) //
      let {response,error} = yield call(changePasswordApi, { token: auth.token, client: auth.client, uid: auth.uid,
                                                             current_password,password,password_confirmation} )
      if(response){
        yield put({ type: CHANGEPASSWORD_SUCCESS, payload: {}})

        return }
      if(error){ 
             return  yield put({type:CHANGEPASSWORD_FAILURE,payload:{error:error,}})     
        }
}