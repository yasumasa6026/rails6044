import {  SCREENINIT_REQUEST,SCREEN_REQUEST,SCREEN_SUCCESS7,
  SCREEN_FAILURE,LOGOUT_REQUEST,SCREEN_CONFIRM7,
  FETCH_REQUEST,FETCH_RESULT,FETCH_FAILURE,YUP_RESULT,
  INPUTFIELDPROTECT_REQUEST,INPUTPROTECT_RESULT,SECOND_SUCCESS7,
  YUP_ERR_SET,DROPDOWNVALUE_SET,SCREEN_PARAMS_SET, CONFIRMALL_SUCCESS,} 
  from '../../actions'

export let getScreenState = state => state.screen

const initialValues = {second_columns_info:{columns_info:null,},}

const screenreducer =  ( state = initialValues , actions) =>{
switch (actions.type) {
// Set the requesting flag and append a message to be shown

case SCREENINIT_REQUEST:
  return {...state,
    //      params:actions.payload.params,
          loading:true,
          message: " screen loading ...",
          // editableflg:actions.payload.editableflg
}


case SCREEN_PARAMS_SET:
return {...state,
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
        params:actions.payload.params,
        loading:true,
        message: "screen loading ...",
        // editableflg:actions.payload.editableflg
}

case SCREEN_SUCCESS7: // payloadに統一
return {...state,
  loading:false,
  hostError: null,
  disabled:false,
  data: actions.payload.data.data,
  params: actions.payload.data.params,
  status: actions.payload.data.status,
  grid_columns_info:actions.payload.data.grid_columns_info,
  second_columns_info:null,
}

case SCREEN_CONFIRM7:
return {...state,
  params:actions.payload.params,
  loading:false,
  hostError:actions.payload.data[actions.payload.params.index].confirm_message
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
    return {...state, 
      params:actions.payload.params,  
      loading:false,
      hostError: actions.payload.params.err,  
    }

case FETCH_RESULT:
          return {...state,
            params:actions.payload.params,  
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



case CONFIRMALL_SUCCESS:
  return {...state,
   loading:false,
   hostError: actions.payload.messages,
   disabled:false,
}


case SECOND_SUCCESS7: // 第一画面から移るときの受け渡し
return {...state,
    loading:false,
    second_columns_info:actions.payload.data.grid_columns_info, //第一画面の内容
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
