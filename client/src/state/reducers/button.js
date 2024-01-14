import { BUTTONLIST_SUCCESS, BUTTONFLG_REQUEST,SCREENINIT_REQUEST,  
   DOWNLOAD_REQUEST, DOWNLOAD_SUCCESS,LOGOUT_REQUEST,RESET_REQUEST, DOWNLOAD_FAILURE,
    //MKSHPACTS_RESULT,
  UPLOADEXCEL_REQUEST,} //
   from '../../actions'

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
loading:true,
}


case SCREENINIT_REQUEST:
  return {...state,
    buttonflg:actions.payload.params.buttonflg, 
    messages:actions.payload.messages,
    message:actions.payload.message,
          // editableflg:action.payload.editableflg
}


case BUTTONLIST_SUCCESS:
return {...state,
buttonListData:actions.payload,
disabled:false,
loading:false,
}

case UPLOADEXCEL_REQUEST:
  return {...state,
    buttonflg:"upload", 
    complete:false,
          // editableflg:action.payload.editableflg
}

case DOWNLOAD_REQUEST:
return {...state,
excelData:null,
totalCount:null,
params:actions.payload.params,
loading:true,
messages:null,
message:null,
errors:null,
}

case DOWNLOAD_SUCCESS:
return {...state,
excelData:actions.payload.data.excelData,
totalCount:actions.payload.data.totalCount,
fillered:actions.payload.data.fillered,
loading:false,
errors:null,
}

case  DOWNLOAD_FAILURE:
return {...state,
errors:actions.errors,
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
  loading:false,
  disabled:false,
}


default:
return {...state,
disabled:false,
loading:false,
}
}
}

export default buttonreducer