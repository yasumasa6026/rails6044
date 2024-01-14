import {  SCREENINIT_REQUEST,SCREEN_REQUEST,SCREEN_SUCCESS7,CONFIRMALL_SUCCESS,
  LOGOUT_REQUEST,SCREEN_CONFIRM7,SCREEN_CONFIRM7_SUCCESS,SCREEN_FAILURE,
  FETCH_REQUEST,FETCH_RESULT,FETCH_FAILURE,
  INPUTFIELDPROTECT_REQUEST,INPUTPROTECT_RESULT,
  SECOND_SUCCESS7,SECOND_CONFIRM7_SUCCESS,
  MKSHPORDS_SUCCESS,SCREEN_DATASET,CHANGE_SHOW_SCREEN,
  TBLFIELD_REQUEST,TBLFIELD_SUCCESS,
  GANTTCHART_REQUEST,GANTTCHART_SUCCESS, UPLOADEXCEL_INIT,
  DROPDOWNVALUE_SET,SCREEN_SUBFORM,LOGIN_SUCCESS,LOGOUT_SUCCESS} 
  from '../../actions'

export let getScreenState = state => state.screen

const initialValues = {loading : false,second_columns_info:{columns_info:null,},}

const screenreducer =  ( state = initialValues , actions) =>{
let data
let date = new Date()
switch (actions.type) {
// Set the requesting flag and append a message to be shown

case SCREENINIT_REQUEST:
  return {...state,
          params:actions.payload.params,
          loading:true,
          toggleSubForm:false,
          data: [],
          status: {},
          grid_columns_info:{columns_info:[],pageSizeList:[],dropDownList:[]},
          // editableflg:actions.payload.editableflg
}


case SCREEN_SUBFORM:
return {...state,
  toggleSubForm:actions.payload.toggleSubForm,
  params:actions.payload.params,
}

  
case SCREEN_REQUEST:
return {...state,
        loading:true,
        screenFlg:"first",
        // editableflg:actions.payload.editableflg
}


case SCREEN_CONFIRM7:  //confirm request
return {...state,
        loading:true,
        params:actions.payload.params,
        data:actions.payload.data,
        screenFlg:"first",
        // editableflg:actions.payload.editableflg
}

case SCREEN_SUCCESS7: // payloadに統一
return {...state,
  loading:false,
  hostError: null,
  disabled:false,
  data: actions.payload.data.data,
  params: actions.payload.params,
  status: actions.payload.data.status,
  grid_columns_info:actions.payload.data.grid_columns_info,
  screenFlg:"first",
  message:"",
  toggleSubForm:false,
}

case SCREEN_CONFIRM7_SUCCESS:
  data = state.data.map((row,idx)=>{if(actions.payload.index===idx){row = {...row,...actions.payload.lineData}}
                                        return row }) 
  return {...state,
    params:actions.payload.params,
    data:data,
    loading:false,
    screenFlg:"first",
    hostError:actions.payload.params.err,
    message:`${date.toJSON()} confirmed line ${actions.payload.params.index}`,
  }


case SECOND_CONFIRM7_SUCCESS:
    if(/heads$/.test(actions.payload.params.head.pareScreenCode)){
        let lineData  = actions.payload.params.lineData
        data = state.data.map((row,idx)=>{if(actions.payload.index===idx){row = {...row,...lineData}}
                                          return row }) 
        return {...state,
            data:data,
        } 
    }
    else{
        return {...state,
        } 
    }


case CONFIRMALL_SUCCESS:
  return {...state,
   loading:false,
   hostError: null,
   disabled:false,
   messages:actions.payload.messages,
}


case SCREEN_FAILURE:
  return {...state,
    loading:false,
  }



case  DROPDOWNVALUE_SET:
    let {index,field,val} = {...actions.payload.dropDownValue}
    state.data[index][field] = val
    return {...state,
      data:state.data
  }  

  

case UPLOADEXCEL_INIT:
  return {...state,
            params:actions.payload.params,
            loading:false
  }


// Append the error returned from our api
// set the success and requesting flags to false
case FETCH_REQUEST:
return {...state,
  params:actions.payload.params, 
  loading:true,
  //editableflg:false
}

case FETCH_FAILURE:
  data = state.data.map((row,idx)=>{if(actions.payload.index===idx){row = {...row,...actions.payload.lineData}}
                                        return row }) 
    return {...state, 
      params:actions.payload.params,  
      data:data,
      loading:false,
      hostError: actions.payload.params.err,  
    }

case FETCH_RESULT:
  data = state.data.map((row,idx)=>{if(actions.payload.index===idx){row = {...row,...actions.payload.lineData}}
                                        return row }) 
          return {...state,
            params:actions.payload.params,  
            data:data,
            loading:false,
            hostError: null,
    }

case INPUTFIELDPROTECT_REQUEST:
  return {...state,
            }
case INPUTPROTECT_RESULT:
  return {...state,
          }

case SCREEN_DATASET:
      return {...state,
        data: actions.payload.data,
      }

case MKSHPORDS_SUCCESS:
  return {...state,
      loading:false,
  }    

  case SECOND_SUCCESS7: // payloadに統一
  return {...state,
    loading:false,
    disabled:false,
    message:"",
    toggleSubForm:false,
    hostError:null,
  }


case GANTTCHART_REQUEST:
case TBLFIELD_REQUEST:
    return {...state,
     params:actions.payload.params, 
     loading:true,
  }  
  
case GANTTCHART_SUCCESS:
  if(actions.payload.screenFlg==="first")
      {return {...state,
                params:{...state.params,buttonflg:actions.payload.buttonflg,},
                loading:false,
                  message:null,}
      }else{return {...state,
          loading:false,
          message:null,}}


case TBLFIELD_SUCCESS:
            return {...state,
            params: {...state.params,messages:actions.payload.messages},
            disabled:false,
            loading:false,
            }
            


  case  LOGIN_SUCCESS:
  return {
      toggleSubForm:true,
      hostError: null,
      disabled:false,
      message:null,
  }

  case  LOGOUT_REQUEST:
    return {
        ...state,
        loading:false,
        hostError: null,
        disabled:false,
        message:null,
    }

  
    case  LOGOUT_SUCCESS:
      return {
      }
      

  case CHANGE_SHOW_SCREEN:
      return {}

    //  ※Uncaught Error: Reducer "screen" returned undefined during initialization. 
    //  If the state passed to the reducer is undefined, you must explicitly return the initial state. 
    //  The initial state may not be undefined.
    //   If you don't want to set a value for this reducer, you can use null instead of undefined.
    //     at combineReducers.js:43:1※
  default:  //カットすると※のerrが発生
    return state
  }
}

export default screenreducer
