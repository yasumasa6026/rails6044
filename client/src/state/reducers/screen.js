import {  SCREENINIT_REQUEST,SCREEN_REQUEST,SCREEN_SUCCESS7,CONFIRMALL_SUCCESS,
  LOGOUT_REQUEST,SCREEN_CONFIRM7,SCREEN_CONFIRM7_SUCCESS,
  FETCH_REQUEST,FETCH_RESULT,
  INPUTFIELDPROTECT_REQUEST,INPUTPROTECT_RESULT,
  SECOND_SUCCESS7,SECOND_CONFIRM7_SUCCESS,
  MKSHPORDS_SUCCESS,SCREEN_DATASET,
  TBLFIELD_REQUEST,
  GANTTCHART_REQUEST,GANTTCHART_SUCCESS,TBLFIELD_SUCCESS,
  AREACHART_REQUEST,
  UPLOADEXCEL_INIT, DROPDOWNVALUE_SET,SCREEN_FAILURE,
  SCREEN_SUBFORM,LOGIN_SUCCESS,LOGOUT_SUCCESS} 
  from '../../actions'

const initialValues = {loading : false,second_columns_info:{columns_info:null,},}

const screenreducer =  ( state = initialValues , actions) =>{
let data
/*
SCREENINIT_REQUEST: A request to initialize the screen.
SCREEN_REQUEST: A general request for screen data.
SCREEN_SUCCESS7: Successfully retrieved screen data.
SCREEN_CONFIRM7: request to confirm a record.
SCREEN_CONFIRM7_SUCCESS: confirm of record is ok.
SECOND_CONFIRM7_SUCCESS: confirm of the sub record.
FETCH_REQUEST: A request to fetch data.
FETCH_RESULT: Data has been fetched.
INPUTFIELDPROTECT_REQUEST: request to set the inputfield protect.
INPUTPROTECT_RESULT: inputfield is protected.
SCREEN_DATASET: set the data of the screen.
MKSHPORDS_SUCCESS: process of the creation of the prdords and purords is ok.
TBLFIELD_REQUEST: request to update the table field.
GANTTCHART_REQUEST: request to update the gantt chart.
GANTTCHART_SUCCESS: update of the gantt chart is ok.
TBLFIELD_SUCCESS: update of the table field is ok.
AREACHART_REQUEST: a request to update the area chart.
UPLOADEXCEL_INIT: initialize upload of an excel file.
DROPDOWNVALUE_SET: set the value of the dropdown list.
SCREEN_FAILURE: An error occurred fetching screen data.
SCREEN_SUBFORM: set the display of the subform.
LOGIN_SUCCESS: Login has been successful.
LOGOUT_REQUEST: A request to logout.
LOGOUT_SUCCESS: Logout has been successful.
*/
switch (actions.type) {

case SCREENINIT_REQUEST:
  return {...state,
          params:actions.payload.params,
          loading:true,
          toggleSubForm:false,
          toggleAreaChart:false,
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

case AREACHART_REQUEST:
return {...state,
  toggleAreaChart:actions.payload.toggleAreaChart,
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
        baseData:actions.payload.data,
        screenFlg:"first",
        // editableflg:actions.payload.editableflg
}

case SCREEN_SUCCESS7: // payloadに統一
return {...state,
  loading:false,
  disabled:false,
  data: actions.payload.data.data,
  baseData: actions.payload.data.data,
  params: actions.payload.params,
  status: actions.payload.data.status,
  grid_columns_info:actions.payload.data.grid_columns_info,
  screenFlg:"first",
  toggleSubForm:false,
}

case SCREEN_CONFIRM7_SUCCESS:
  data = state.data.map((row,idx)=>{if(actions.payload.index===idx){row = {...row,...actions.payload.lineData}}
                                        return row }) 
  return {...state,
        params:actions.payload.params,
        data:data,
        baseData:data,
        loading:false,
        screenFlg:"first",
      }
  

case SECOND_CONFIRM7_SUCCESS:
    if(/heads$/.test(actions.payload.params.head.pareScreenCode)){
        let lineData  = actions.payload.params.lineData
        data = state.data.map((row,idx)=>{if(actions.payload.index===idx){row = {...row,...lineData}}
                                          return row }) 
        return {...state,
            data:data,baseData:data
        } 
    }
    else{
        return {...state,
        } 
    }


case CONFIRMALL_SUCCESS:
  return {...state,
   loading:false,
   disabled:false,
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

case FETCH_RESULT:
  data = state.data.map((row,idx)=>{if(actions.payload.index===idx){
                                        Object.keys(actions.payload.lineData).map((field)=>row[field] = actions.payload.lineData[field])
                                                      return row }
                                     else{return row} }
                            ) 
          return {...state,
            params:actions.payload.params,  
            data:data,
            baseData:data,
            loading:false,
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
        params: actions.payload.params,
      }

case MKSHPORDS_SUCCESS:
  return {...state,
      loading:false,
  }    

  case SECOND_SUCCESS7: // payloadに統一
  return {...state,
    loading:false,
    disabled:false,
    toggleSubForm:false,
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
                  }
      }else{return {...state,
          loading:false,
          }}

  case TBLFIELD_SUCCESS:
            return {...state,
            loading:false,
            }  
        
  
  case SCREEN_FAILURE:
          return {...state,
              loading:false,
            }

  case  LOGIN_SUCCESS:
  return {
      toggleSubForm:true,
      disabled:false,
      params:{},
  }

  case  LOGOUT_REQUEST:
    return {
    }

  
    case  LOGOUT_SUCCESS:
      return {
      }
      

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
