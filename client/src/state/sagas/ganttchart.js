import { call, put, select } from 'redux-saga/effects'
import axios         from 'axios'
import { GANTTCHART_SUCCESS,GANTTCHART_FAILURE,}     from '../../actions'
import {getLoginState} from '../reducers/auth'
import {getScreenState} from '../reducers/screen'
//import { ReactReduxContext } from 'react-redux';


function GanttApi({params,token,client,uid}) {
  const url = 'http://localhost:3001/api/ganttcharts'
  const headers = {'access-token':token,'client':client,'uid':uid }
  axios.defaults.headers.post['Content-Type'] = 'application/json'


  const options ={method:'POST',
  //  data: qs.stringify(data),
        params:params,
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

export function* GanttChartSaga({ payload: {params}  }) {
  let token = params.token       
  let client = params.client         
  let uid = params.uid    
  const screenState = yield select(getScreenState) //
  if(params.clickIndex.size>1){
    yield put({ type:GANTTCHART_FAILURE, errors: "error multiple rows selected" })
    return
  }
  params["linedata"] = screenState.data[params.clickIndex[0]["lineId"]]
  let {response,error} = yield call(GanttApi,{params ,token,client,uid} )
  if(response || !error){
      switch(params.req) {
        case "ganttchart":  // create yup schema
              return yield put({ type: GANTTCHART_SUCCESS, payload: response.data} )  
        default:
          return {}
      }
  }else
     {  
      let message
      switch (true) {
          case /code.*500/.test(error): message = 'Internal Server Error'
           break
          case /code.*401/.test(error): message = 'Invalid credentials'
           break
          default: message = `Something went wrong ${error}`}
      yield put({ type:GANTTCHART_FAILURE, errors: message })
  }
 }      