import {LOGIN_REQUEST,LOGOUT_REQUEST,LOGIN_SUCCESS,  //SECONDSCREEN_REQUEST,
        //MKSHPACTS_RESULT,
        SECOND_CONFIRMALL_SUCCESS,SECOND_SUCCESS7,SECOND_DATASET,
        SECOND_CONFIRM7,SECOND_CONFIRM7_SUCCESS,SECOND_FAILURE, SECONDFETCH_REQUEST,SECOND_SUBFORM,
        SECOND_REQUEST,SECONDFETCH_FAILURE,SECONDFETCH_RESULT, CHANGE_SHOW_SCREEN,
        SCREENINIT_REQUEST, SCREEN_SUCCESS7,SCREEN_REQUEST,} from '../../actions'

        const initialValues = {data:[],
            params:{screenCode:null,screenName:null},
            grid_columns_info:{pageSizeList:[],
                               columns_info:[],
                               creenwidth:0,
                               dropDownList:[],
                               hiddenColumns:[]},
}

const secondreducer =  (state = initialValues , actions) =>{
    let data
    let date = new Date()
  switch (actions.type) {

    case SECOND_CONFIRMALL_SUCCESS:
        return {...state,
             loading:false,
             hostError: null,
             disabled:false,
            messages:actions.payload.messages,
      }

    case SECOND_REQUEST:
        return {...state,
        screenFlg:"second",
        loading:true,
         // editableflg:actions.payload.editableflg
     }

     case SECOND_CONFIRM7:
        return {...state,
            data:actions.payload.data,
            screenFlg:"second",
            loading:true,
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
            loading:false,
        }

    case SECOND_CONFIRM7_SUCCESS:
        data = state.data.map((row,idx)=>{if(actions.payload.index===idx){row = {...row,...actions.payload.lineData}}
                                              return row }) 
        return {...state,
            data:actions.payload.data,
            params:actions.payload.params,
            loading:false,
            hostError:actions.payload.data[actions.payload.params.index].confirm_message,
            message:`${date.toJSON()} confirmed line ${actions.payload.params.index}`,
        } 

    case SECOND_FAILURE:
        data = state.data.map((row,idx)=>{if(actions.payload.index===idx){row = {...row,...actions.payload.lineData}}
                                              return row }) 
        return {...state,
            hostError: actions.payload.message,
            data: actions.payload.data,
            loading:false,
        }

    case SECONDFETCH_REQUEST:
        return {...state,
            params:actions.payload.params, 
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
        data = state.data.map((row,idx)=>{if(actions.payload.index===idx){row = {...row,...actions.payload.lineData}}
                                              return row }) 
        return {...state,
            params:actions.payload.params,  
            data:data,
            loading:false,
            hostError: null,
        }


    case SECOND_DATASET:
            return {...state,
                        data: actions.payload.data,
                }
           
   
    case SECOND_SUBFORM:
        return {...state,
            toggleSubForm:actions.payload.toggleSubForm,
        }

    case SCREENINIT_REQUEST:
    case SCREEN_SUCCESS7:
    case SCREEN_REQUEST:
    case CHANGE_SHOW_SCREEN:
        return {data:[],
            params:{screenCode:"",
                    parse_linedata:{},
                    filtered:[],where_str:"",sortBy:[],screenFlg:"second",
                    screenCode:"",pageIndex:0,pageSize:20,totalCount:0,
                    index:0,clickIndex:[],err:null,},
            grid_columns_info:{pageSizeList:[],
                    columns_info:[],
                    creenwidth:0,
                    dropDownList:[],
                    hiddenColumns:[]},}

    
  case  LOGIN_REQUEST:
  case  LOGIN_SUCCESS:
    return {
        ...state,
    }
               
    case  LOGOUT_REQUEST:
            return {data:[],
                params:{screenCode:null,screenName:null},
                grid_columns_info:{pageSizeList:[],
                                   columns_info:[],
                                   creenwidth:0,
                                   dropDownList:[],
                                   hiddenColumns:[]},}  
                           
     default:
        return {...state}
  }
}

export default secondreducer