import { combineReducers } from 'redux'
import { routerReducer } from 'react-router-redux'

//import  loginreducer  from './login'
//import  signupreducer  from './signup'
import  authreducer  from './auth'
import  menureducer  from './menu'
import  screenreducer  from './screen'
import  uploadreducer  from './upload'
import  buttonreducer  from './button'
import  downloadreducer  from './download'
import  ganttchartreducer  from './ganttchart'
import  secondreducer  from './second'

const reducer = combineReducers({
  //login:loginreducer,
  //signup:signupreducer,
  auth:authreducer,
  menu:menureducer,
  screen:screenreducer,
  upload:uploadreducer,
  button:buttonreducer,
  download:downloadreducer,
  ganttchart:ganttchartreducer,
  second:secondreducer,
  routing: routerReducer,
})

export default reducer
