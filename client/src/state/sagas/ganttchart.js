import { call, put, select } from 'redux-saga/effects'
import axios         from 'axios'
import { GANTTCHART_SUCCESS,GANTTCHART_FAILURE,SECOND_SUCCESS7,}     from '../../actions'
//import { ReactReduxContext } from 'react-redux';
import {getAuthState} from '../reducers/auth'


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
    const auth = yield select(getAuthState) //
    let token = auth.token       
    let client = auth.client         
    let uid = auth.uid   
    let {response,error} = yield call(GanttApi,{params ,token,client,uid} )
    if(response || !error){
        switch (params.buttonflg){
            case "ganttchart":
            case "reversechart":
                let tasks = []
                tasks = response.data.tasks.map((task,idx)=>
                                 tasks[idx] = {...task,start:new Date(task.start),end:new Date(task.end),}
                                 )
                return yield put({ type: GANTTCHART_SUCCESS, payload:{ tasks:tasks,viewMode:params.viewMode,
                                                                                screenCode:params.screenCode,
                                                                                buttonflg:params.buttonflg,}} )  
            case "updateNditm":
                params = {...response.data.params,err:null,parse_linedata:{},index:0,clickIndex:[]}
                return yield put({type:SECOND_SUCCESS7,payload:{data:response.data,params:params} })
        }}else
        {  
        let message
        switch (true) {
          case /code.*500/.test(error): message = 'Internal Server Error'
           break
          case /code.*401/.test(error): message = 'Invalid credentials or Login TimeOut'
           break
          default: message = `Something went wrong ${error}`}
        yield put({ type:GANTTCHART_FAILURE, errors: message })
        }
 }      