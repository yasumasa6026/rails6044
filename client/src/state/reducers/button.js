import {  BUTTONLIST_REQUEST, BUTTONLIST_SUCCESS, BUTTONFLG_REQUEST,GANTT_RESET,SCREENINIT_REQUEST,
  TBLFIELD_SUCCESS,GANTTCHART_SUCCESS,LOGOUT_REQUEST,MKSHPORDS_SUCCESS,MKSHPACTS_RESULT,
  SCREEN_SUCCESS7,IMPORTEXCEL_REQUEST,CONFIRMALL_SUCCESS,
  SECONDSCREEN_SUCCESS7} //RESET_REQUEST
   from '../../actions'

export let getButtonState = state => state.button
const initialValues = {
errors:[],
buttonflg:"viewtablereq7",
messages:null,
message:null, 
}

const buttonreducer =  (state= initialValues , actions) =>{
switch (actions.type) {

case BUTTONFLG_REQUEST:
return {...state,
buttonflg:actions.payload.buttonflg, 
screenCode:actions.payload.params.screenCode,
screenName:actions.payload.params.screenName,
disabled:true,  
messages:null,
message:null, 
downloadloading:"",
}


case SCREENINIT_REQUEST:
  return {...state,
    //buttonflg:actions.payload.params.req, 
    buttonflg:"search", 
    messages:actions.payload.messages,
    message:actions.payload.message,
          // editableflg:action.payload.editableflg
}

case SCREEN_SUCCESS7:
return {...state,
disabled:false,
}

case BUTTONLIST_REQUEST:
return {...state,
disabled:true,
messages:null,
message:null,}

case GANTT_RESET:
  return {...state,
    disabled:false,}


case BUTTONLIST_SUCCESS:
return {...state,
buttonListData:actions.payload,
disabled:false,
}

case TBLFIELD_SUCCESS:
return {...state,
messages:actions.payload.messages,
message:actions.payload.message,
disabled:false,
}

case GANTTCHART_SUCCESS:
return {...state,
  buttonflg:"ganttchart",
}

case MKSHPORDS_SUCCESS:
return {...state,
  buttonflg:"mkshpords",
  messages:actions.payload.messages,
  loading:false,
}

case MKSHPACTS_RESULT:
return {...state,
  buttonflg:"mkshpacts",
  loading:false,
}
case SECONDSCREEN_SUCCESS7: // payloadに統一
return {...state,
    disabled:false,
}

case IMPORTEXCEL_REQUEST:
  return {...state,
    buttonflg:"import", 
    complete:false,
          // editableflg:action.payload.editableflg
}

case CONFIRMALL_SUCCESS:
  return {...state,
   disabled:false,
}


case  LOGOUT_REQUEST:
return {}  

default:
return state
}
}

export default buttonreducer