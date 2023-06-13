import {  BUTTONLIST_REQUEST, BUTTONLIST_SUCCESS, BUTTONFLG_REQUEST,GANTT_RESET,SCREENINIT_REQUEST,
  TBLFIELD_SUCCESS,GANTTCHART_SUCCESS,MKSHPORDS_SUCCESS, DOWNLOAD_REQUEST,
  DOWNLOAD_SUCCESS,LOGOUT_REQUEST,RESET_REQUEST, DOWNLOAD_FAILURE,
    //MKSHPACTS_RESULT,
  SCREEN_REQUEST,
  SCREEN_SUCCESS7,CONFIRMALL_SUCCESS,IMPORTEXCEL_REQUEST,SECOND_CONFIRMALL_SUCCESS, SECOND_SUCCESS7,} //
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
    buttonflg:actions.payload.params.buttonflg, 
    messages:actions.payload.messages,
    message:actions.payload.message,
          // editableflg:action.payload.editableflg
}


case SCREEN_REQUEST:
  return {...state,
    loading:true,
}

case SCREEN_SUCCESS7:
return {...state,
disabled:false,
loading:false,
}


case CONFIRMALL_SUCCESS:
return {...state,
disabled:false,
loading:false,
}

// case SECOND_SUCCESS7:
// return {...state,
// disabled:false,
// buttonflg:"inlineedit7",
// loading:false,
// }


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
  buttonflg:"mkShpords",
  messages:actions.payload.messages,
  loading:false,
}

// case MKSHPACTS_RESULT:
// return {...state,
//   buttonflg:"mkshpacts",
//   loading:false,
// }
case SECOND_SUCCESS7: // payloadに統一
return {...state,
    disabled:false,
}

case IMPORTEXCEL_REQUEST:
  return {...state,
    buttonflg:"import", 
    complete:false,
          // editableflg:action.payload.editableflg
}

case SECOND_SUCCESS7: // payloadに統一
return {...state,
  loading:false,
  disabled:false,
  message:"",
  toggleSubForm:false,
}

case SECOND_CONFIRMALL_SUCCESS:
  return {...state,
   disabled:false,
}


case DOWNLOAD_REQUEST:
return {...state,
excelData:null,
totalCount:null,
params:actions.payload.params,
downloadloading:"doing",
messages:null,
message:null,
errors:null,
}

case DOWNLOAD_SUCCESS:
return {...state,
excelData:actions.payload.data.excelData,
totalCount:actions.payload.data.totalCount,
fillered:actions.payload.data.fillered,
downloadloading:"done",
errors:null,
}

case  DOWNLOAD_FAILURE:
return {...state,
errors:actions.errors,
disabled:false,
messages:null,
message:null,
}


case GANTTCHART_SUCCESS:
return {...state,
disabled:false,
messages:null,
message:null,
}


case  LOGOUT_REQUEST:
return {}  

case RESET_REQUEST:
return {...state,
  excelData:null,
  totalCount:null,
  buttonflg:null,
  downloadloading:"",
  disabled:false,
}


default:
return state
}
}

export default buttonreducer