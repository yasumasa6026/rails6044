import {  SCREENINIT_REQUEST,SCREEN_REQUEST,SCREEN_SUCCESS7,CONFIRMALL_SUCCESS,
  SCREEN_FAILURE,LOGOUT_REQUEST,SCREEN_CONFIRM7,SCREEN_CONFIRM7_SUCCESS,
  FETCH_REQUEST,FETCH_RESULT,FETCH_FAILURE,YUP_RESULT,
  INPUTFIELDPROTECT_REQUEST,INPUTPROTECT_RESULT,
  //SECOND_SUCCESS7,
  MKSHPORDS_SUCCESS,SCREEN_DATASET,
  YUP_ERR_SET,DROPDOWNVALUE_SET,SCREEN_SUBFORM,LOGIN_SUCCESS} 
  from '../../actions'

export let getScreenState = state => state.screen

const initialValues = {second_columns_info:{columns_info:null,},}

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
          // editableflg:actions.payload.editableflg
}


case SCREEN_SUBFORM:
return {...state,
  toggleSubForm:actions.payload.toggleSubForm,
  params:actions.payload.params,
}

case YUP_ERR_SET:
  return {...state,
    data:actions.payload.data,
    loading : false,
    error : actions.payload.error,
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
  second_columns_info:null,
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

case CONFIRMALL_SUCCESS:
  return {...state,
   loading:false,
   hostError: null,
   disabled:false,
   messages:actions.payload.messages,
}


case  DROPDOWNVALUE_SET:
    let {index,field,val} = {...actions.payload.dropDownValue}
    state.data[index][field] = val
    return {...state,
      data:state.data
  }  

// Append the error returned from our api
// set the success and requesting flags to false
case SCREEN_FAILURE:
  return {...state,
  hostError: actions.payload.message,
  loading:false,
}

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

case YUP_RESULT:
    return {...state,
      message: actions.payload.message,
    }
  

case SCREEN_DATASET:
      return {...state,
        data: actions.payload.data,
      }

case MKSHPORDS_SUCCESS:
  return {...state,
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
        loading:false,
        hostError: null,
        disabled:false,
        message:null,
    }

default:
return state
}
}

export default screenreducer
