import { call, put, select } from 'redux-saga/effects'
import axios         from 'axios'
import {TBLFIELD_SUCCESS, TBLFIELD_FAILURE,
        }     from '../../actions'
import {getLoginState} from '../reducers/auth'
import {getScreenState} from '../reducers/screen'
//import { isValidElement } from 'react';
//import { ReactReduxContext } from 'react-redux';


function screenApi({params,token,client,uid}) {
  const url = 'http://localhost:3001/api/tblfields'
  const headers = {'access-token':token,'client':client,'uid':uid }

  let postApi = (url, params, headers) => {
    return axios({
        method: "POST",
        url: url,
        contentType: "application/json",
        params:params,
        headers:headers,
    })
  }
  return postApi(url, params, headers)
}

export function* TblfieldSaga({ payload: {params}  }) {
  let token = params.token       
  let client = params.client         
  let uid = params.uid   
  const screenState = yield select(getScreenState) //
  let data =[]
  switch(params.req) {
      case "yup":
          break
      case  "createTblViewScreen":
              screenState.data.map((val,index) =>{ 
              return data.push({pobject_code_tbl:val.pobject_code_tbl,                      
                  pobject_code_fld:val.pobject_code_fld, })
               })
              params["data"] = data
            break
      case "createUniqueIndex": 
          screenState.data.map((val,index) =>{ 
          return data.push({pobject_code_tbl:val.pobject_code_tbl,                      
                      pobject_code_fld:val.pobject_code_fld,  // blkuky用
                      blkuky_grp:val.blkuky_grp,
                      blkuky_seqno:val.blkuky_seqno,
                      blkuky_expiredate:val.blkuky_expiredate,})
           }) 
           params["data"] = data
           break
      default:
         return {}
  }
  try{
    let response  = yield call(screenApi,{params ,token,client,uid} )
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
  }catch(response) {   
        let message
        switch (response.status) {
              case 500: message = 'Internal Server Error'
               break
              case 401: message = 'Invalid credentials'
               break
              default: message = `Something went wrong ${response.error}` }
      yield put({ type: TBLFIELD_FAILURE, errors: message })
      }
 }      