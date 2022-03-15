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
  try{
      let response   = yield call(MenuGetApi, ({token,client,uid} ) )
      yield put({ type: MENU_SUCCESS, action: response.data })
      yield call(history.push,'/menus7')}
  catch(e){
      let message 
      switch (true) {
        case /code.*500/.test(e): message = `${e}: Internal Server Error `
            if(params.second===true){
              return  yield put({type:SECONDSCREEN_FAILURE, payload:{message:message,data}})   
            }else{  
              return  yield put({type:SCREEN_FAILURE, payload:{message:message,data}})   
            }
        case /code.*401/.test(e): message = ` Invalid credentials  Unauthorized  ${e}`
            if(params.second===true){
                return  yield put({type:SECONDSCREEN_FAILURE, payload:{message:message,data}})   
            }else{  
                return  yield put({type:SCREEN_FAILURE, payload:{message:message,data}})   
            }
        default:
            message = `Menu  Something went wrong ${e} `
              if(params.second===true){
                  return  yield put({type:SECONDSCREEN_FAILURE, payload:{message:message,data}})   
              }else{  
                  return  yield put({type:SCREEN_FAILURE, payload:{message:message,data}})   
            }
        }
  }  
}      
