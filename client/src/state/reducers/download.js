import {  DOWNLOAD_REQUEST,DOWNLOAD_SUCCESS,LOGOUT_REQUEST,RESET_REQUEST,
            GANTTCHART_SUCCESS,DOWNLOAD_FAILURE } from '../../actions'
const initialValues = {
errors:[],
buttonflg:""
}

const downloadreducer =  (state= initialValues , actions) =>{
switch (actions.type) {

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

export default downloadreducer