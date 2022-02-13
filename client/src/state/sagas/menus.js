import { call, put} from 'redux-saga/effects'
import axios         from 'axios'

import { MENU_SUCCESS, MENU_FAILURE, } from '../../actions'
import history from '../../histrory'

function MenuGetApi({token,client,uid}) {
  const url = 'http://localhost:3001/api/menus7'
  const headers =  { 'access-token':token.token, 
                    client:client.client,
                    uid:uid.uid,}
  const params =  {uid:uid.uid,req:"menureq"}

  let getApi = (url, params,headers) => {
    return axios({
      method: "POST",
      url: url,
      params,headers,
    })
  }
  return getApi(url, params,headers)
}

// MenuSaga({ payload: { token,client,uid} })  出し手と合わすこと
export function* MenuSaga({ payload: {token,client,uid} }) {
  let response   = yield call(MenuGetApi, ({token,client,uid} ) )
  if(response.data){
      yield put({ type: MENU_SUCCESS, action: response.data })
      yield call(history.push,'/menus7')}
  else{    
      let message = `error ${response}`
      if(response.error){
      switch (response.status) {
              case 500: message = 'Menu Internal Server Error'
               break
              case 401: message = 'Menu Invalid credentials'
               break
              default: message = `error status ${response.status}`}
      yield put({ type: MENU_FAILURE, errors: message })
      }  
    }
 }      
