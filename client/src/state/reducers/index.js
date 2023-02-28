import { combineReducers } from 'redux'
import { routerReducer } from 'react-router-redux'

import  authreducer  from './auth'
import  menureducer  from './menu'
import  screenreducer  from './screen'
import  uploadreducer  from './upload'
import  buttonreducer  from './button'
import  ganttchartreducer  from './ganttchart'
import  secondreducer  from './second'

const reducer = combineReducers({
  auth:authreducer,
  menu:menureducer,
  screen:screenreducer,
  upload:uploadreducer,
  button:buttonreducer,
  ganttchart:ganttchartreducer,
  second:secondreducer,
  routing: routerReducer,
})

export default reducer
