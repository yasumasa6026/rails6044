import { call, put} from 'redux-saga/effects'
import axios         from 'axios'

import { BUTTONLIST_SUCCESS, MENU_FAILURE} from '../../actions'

function ButtonListGetApi({token,client,uid}) {
  let url = 'http://localhost:3001/api/menus7'

  const headers =  { 'access-token':token.token, 
                    client:client.client,uid:uid.uid}
  const params =  {uid:uid.uid,req:'bottunlistreq'}

  const options ={method:'POST',
                  params: params,
                  headers:headers,
                  url,}
    return (axios(options)
    .then((response ) => {
      return  {response}  
    })
    .catch(error => (
      { error }
    )))
}

// MenuSaga({ payload: { token,client,uid} })  出し手と合わすこと
export function* ButtonListSaga({ payload: {token,client,uid} }) {
  let  {response,error}   = yield call(ButtonListGetApi, ({token,client,uid} ) )
  if(response || !error){
      yield put({ type: BUTTONLIST_SUCCESS, payload: response.data })}
  else{   
    let message
     switch (true) {
         case /code.*500/.test(error): message = 'Internal Server Error'
          break
         case /code.*401/.test(error): message = 'Invalid credentials'
          break
         default: message = `buttonList Something went wrong ${error}`}
      yield put({ type: MENU_FAILURE, errors: message })
      }  
}
      
