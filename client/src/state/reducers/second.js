import {SCREENINIT_REQUEST,LOGOUT_REQUEST,  //SECONDSCREEN_REQUEST,
        MKSHPACTS_RESULT,CONFIRMALL_SUCCESS,SECONDSCREEN_SUCCESS7,
        SECONDSCREEN_LINEEDIT,SECONDSCREEN_FAILURE, SECONDFETCH_REQUEST,
        SECONDSCREEN_PARAMS_SET,
        SECONDFETCH_FAILURE,SECONDFETCH_RESULT} from '../../actions'

        const initialValues = {data:[],
            params:{screenCode:""},
            grid_columns_info:{pageSizeList:[],
                               columns_info:[],
                               creenwidth:0,
                               dropDownList:[],
                               hiddenColumns:[]},
}

const secondreducer =  (state= initialValues , actions) =>{
  switch (actions.type) {

    case MKSHPACTS_RESULT:
       return {...state,
        loading:false,
        hostError: null,
        disabled:false,
        buttonflg:'inlineedit7',
        data: actions.payload.data.data,
        params: actions.payload.data.params,
        status: actions.payload.data.status,
        grid_columns_info:actions.payload.data.grid_columns_info,
     }

    case CONFIRMALL_SUCCESS:
        return {...state,
         loading:false,
         hostError: null,
         disabled:false,
         data: [],
         params:{screenCode:"",screenName:"",},
         grid_columns_info:{columns_info:[],},
      }

    //  case SECONDSCREEN_REQUEST:
    //     return {...state,
    //     params:actions.payload.params,
    //     loading:true,
    //     message: [{ body: 'screen loading ...', time: new Date() }],
    //     // editableflg:actions.payload.editableflg
    // }
   
    case SECONDSCREEN_SUCCESS7: // payloadに統一
        return {...state,
            loading:false,
            hostError: null,
            disabled:false,
            data: actions.payload.data.data,
            params: actions.payload.data.params,
            status: actions.payload.data.status,
            grid_columns_info:actions.payload.data.grid_columns_info,
        }

    case SECONDSCREEN_LINEEDIT:
        return {...state,
            data:actions.payload.data,
            params:actions.payload.params,
            loading:false,
            hostError:actions.payload.data[actions.payload.params.index].confirm_message
        } 

    case SECONDSCREEN_FAILURE:
        return {...state,
            hostError: actions.payload.message,
            data: actions.payload.data,
            loading:false,
        }

    case SECONDFETCH_REQUEST:
        return {...state,
            params:actions.payload.params, 
            data:actions.payload.data, 
            loading:true,
          //editableflg:false
        }
        
    case SECONDFETCH_FAILURE:
        return {...state,
            params:actions.payload.params,  
            loading:false,
            hostError: actions.payload.params.err,  
        }
        
    case SECONDFETCH_RESULT:
        return {...state,
            params:actions.payload.params,  
            loading:false,
            hostError: null,
        }
   
    case  SCREENINIT_REQUEST:
        return {data:[],
            params:{screenCode:""},
            grid_columns_info:{pageSizeList:[],
                                    columns_info:[],
                                    creenwidth:0,
                                    dropdownlist:[],
                                    hiddenColumns:[]},
        } 

    case SECONDSCREEN_PARAMS_SET:
        return {...state,
            params:actions.payload.params,
        }
       
    case  LOGOUT_REQUEST:
        return {}  

    default:
        return {...state}
  }
}

export default secondreducer