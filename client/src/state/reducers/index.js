import { combineReducers } from 'redux'

import  authreducer  from './auth'
import  menureducer  from './menu'
import  screenreducer  from './screen'
import  uploadreducer  from './upload'
import  buttonreducer  from './button'
import  ganttreducer  from './gantt'
import  secondreducer  from './second'

const reducer = combineReducers({
  auth:authreducer,
  menu:menureducer,
  screen:screenreducer,
  upload:uploadreducer,
  button:buttonreducer,
  gantt:ganttreducer,
  second:secondreducer,
})

export default reducer
