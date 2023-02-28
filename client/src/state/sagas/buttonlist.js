import { call, put} from 'redux-saga/effects'
import axios         from 'axios'

import { BUTTONLIST_SUCCESS, MENU_FAILURE} from '../../actions'

function ButtonListGetApi({auth}) {
  let url = 'http://localhost:3001/api/menus7'

  const headers =  { 'access-token':auth["access-token"] ,
                    client:auth.client,uid:auth.uid}
  const params =  {uid:auth.uid,buttonflg:'bottunlistreq'}

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

export function* ButtonListSaga({ payload: {auth} }) {
  let  {response,error}   = yield call(ButtonListGetApi, ({auth} ) )
  if(response || !error){
      yield put({ type: BUTTONLIST_SUCCESS, payload: response.data })}
  else{   
    let message
     switch (true) {
         case /code.*500/.test(error): message = 'Internal Server Error'
          break
         case /code.*401/.test(error): message = 'Invalid credentials or Login TimeOut'
          break
         default: message = `buttonList Something went wrong ${error}`}
      yield put({ type: MENU_FAILURE, errors: message })
      }  
}
      
