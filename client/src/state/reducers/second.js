import {LOGOUT_REQUEST,  //SECONDSCREEN_REQUEST,
        //MKSHPACTS_RESULT,
        SECOND_CONFIRMALL_SUCCESS,SECOND_SUCCESS7,SCREEN_SUCCESS7,
        SECOND_CONFIRM7,SECOND_CONFIRM7_SUCCESS,SECOND_FAILURE, SECONDFETCH_REQUEST,SECOND_SUBFORM,
        SECOND_REQUEST,SECONDFETCH_FAILURE,SECONDFETCH_RESULT} from '../../actions'

        const initialValues = {data:[],
            params:{screenCode:""},
            grid_columns_info:{pageSizeList:[],
                               columns_info:null,
                               creenwidth:0,
                               dropDownList:[],
                               hiddenColumns:[]},
}

const secondreducer =  (state = initialValues , actions) =>{
    let data
    let date = new Date()
  switch (actions.type) {

    // case MKSHPACTS_RESULT:
    //    return {...state,
    //     loading:false,
    //     hostError: null,
    //     disabled:false,
    //     buttonflg:'inlineedit7',
    //     data: actions.payload.data.data,
    //     params: actions.payload.data.params,
    //     status: actions.payload.data.status,
    //     grid_columns_info:actions.payload.data.grid_columns_info,
    //  }

    case SECOND_CONFIRMALL_SUCCESS:
        return {...state,
             secondloading:false,
             hostError: null,
             disabled:false,
            messages:actions.payload.messages,
      }

    case SECOND_REQUEST:
    case SECOND_CONFIRM7:
        return {...state,
        params:actions.payload.params,
        auth:actions.payload.auth,
        screenFlg:"second",
        secondloading:true,
         // editableflg:actions.payload.editableflg
     }
   
    case SECOND_SUCCESS7: // payloadに統一
        return {...state,
            loading:false,
            hostError: null,
            disabled:false,
            data: actions.payload.data.data,
            params: actions.payload.params,
            status: actions.payload.data.status,
            grid_columns_info:actions.payload.data.grid_columns_info,
            buttonflg:"inlineedit7",
            secondloading:false,
        }

    case SECOND_CONFIRM7_SUCCESS:
        data = state.data
        data[actions.payload.params.index] = actions.payload.linedata
        return {...state,
            data:actions.payload.data,
            params:actions.payload.params,
            secondloading:false,
            hostError:actions.payload.data[actions.payload.params.index].confirm_message,
            message:`${date.toJSON()} confirmed line ${actions.payload.params.index}`,
        } 

    case SECOND_FAILURE:
        return {...state,
            hostError: actions.payload.message,
            data: actions.payload.data,
            secondloading:false,
        }

    case SECONDFETCH_REQUEST:
        return {...state,
            params:actions.payload.params, 
            data:actions.payload.data, 
            secondloading:true,
          //editableflg:false
        }
        
    case SECONDFETCH_FAILURE:
        return {...state,
            params:actions.payload.params, 
            secondloading:false,
            hostError: actions.payload.params.err,  
        }
        
    case SECONDFETCH_RESULT:
        return {...state,
            params:actions.payload.params,  
            secondloading:false,
            hostError: null,
        }
   
    case SECOND_SUBFORM:
        return {...state,
            toggleSubForm:actions.payload.toggleSubForm,
        }

    case SCREEN_SUCCESS7: // payloadに統一
        return {...state,
                pareScreenCode: actions.payload.data.params.screenCode,
        }
       
    case  LOGOUT_REQUEST:
        return {}  

    default:
        return {...state}
  }
}

export default secondreducer