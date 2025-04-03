import {LOGIN_REQUEST,LOGOUT_REQUEST,LOGIN_SUCCESS,  //SECONDSCREEN_REQUEST,
        //MKSHPACTS_RESULT,
        SECOND_CONFIRMALL_REQUEST,SECOND_CONFIRMALL_SUCCESS,SECOND_SUCCESS7,SECOND_DATASET,
        SECOND_CONFIRM7,SECOND_CONFIRM7_SUCCESS,
        SECOND_FAILURE, SECONDFETCH_REQUEST,SECOND_SUBFORM,
        SECOND_REQUEST,SECONDFETCH_RESULT,
        GANTTCHART_REQUEST,GANTTCHART_SUCCESS,
        TBLFIELD_REQUEST,TBLFIELD_SUCCESS, UPLOADEXCEL_INIT,
        SECONDTBLFIELD_REQUEST,SECONDTBLFIELD_SUCCESS,SCREEN_CONFIRM7_SUCCESS,
        SCREENINIT_REQUEST, SCREEN_SUCCESS7,SCREEN_REQUEST,} from '../../actions'

        const initialValues = {data:[],
            params:{screenCode:null,screenName:null},
            grid_columns_info:{pageSizeList:[],
                               columns_info:[],
                               creenwidth:0,
                               dropDownList:[],
                               hiddenColumns:[]},
            loading : false,
}

const secondreducer =  (state = initialValues , actions) =>{
    let data
    let date = new Date()
  switch (actions.type) {
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
            baseData:actions.payload.data,
             // editableflg:actions.payload.editableflg
         }

    case SECOND_CONFIRMALL_REQUEST:
        return {...state,
            params:actions.payload.params,
            screenFlg:"second",
            loading:true,
             // editableflg:actions.payload.editableflg
         }

    case SECOND_CONFIRMALL_SUCCESS:
        return {...state,
                  loading:false,
                  disabled:false,
                 message:actions.payload.message,
        }
     
         
   
    case SECOND_SUCCESS7: // payloadに統一
        return {...state,
            loading:false,
            disabled:false,
            data: actions.payload.data.data,
            baseData: actions.payload.data.data,
            params: actions.payload.params,
            status: actions.payload.data.status,
            grid_columns_info:actions.payload.data.grid_columns_info,
            loading:false,
        }

    case SECOND_CONFIRM7_SUCCESS:
        data = state.data.map((row,idx)=>{if(actions.payload.index===idx){row = {...row,...actions.payload.lineData}}
                                              return row }) 
        return {...state,
            data:data,
            baseData:data,
            params:actions.payload.params,
            loading:false,
            message:data[actions.payload.index].confirm_message&&`${date.toJSON()} confirmed line ${actions.payload.index}`,
        } 

    case SECOND_FAILURE:
        data = state.data.map((row,idx)=>{if(actions.payload.index===idx){row = {...row,...actions.payload.lineData}}
                                              return row }) 
        return {...state,
            data: data,
            loading:false,
        }

    case SECONDFETCH_REQUEST:
        return {...state,
            params:actions.payload.params, 
            loading:true,
          //editableflg:false
        }
        
        
    case SECONDFETCH_RESULT:
        data = state.data.map((row,idx)=>{if(actions.payload.index===idx){row = {...row,...actions.payload.lineData}}
                                              return row }) 
        return {...state,
            params:actions.payload.params,  
            data:data,
            baseData:data,
            loading:false,
        }


    case SECOND_DATASET:
            return {...state,
                        data: actions.payload.data,
                        params: actions.payload.params,
                }
           
   
    case SECOND_SUBFORM:
        return {...state,
            toggleSubForm:actions.payload.toggleSubForm,
        }

    case SCREENINIT_REQUEST:
    case SCREEN_SUCCESS7:
    case SCREEN_REQUEST:
    case SCREEN_CONFIRM7_SUCCESS:
        return {data:[],
            params:{screenCode:"",
                    parse_linedata:{},buttonflg:"viewtablereq7",
                    filtered:[],where_str:"",sortBy:[],screenFlg:"second",
                    screenCode:"",pageIndex:0,pageSize:20,totalCount:0,
                    index:0,clickIndex:[],err:null,},
            grid_columns_info:{pageSizeList:[],
                    columns_info:[],
                    creenwidth:0,
                    dropDownList:[],
                    hiddenColumns:[]},}
    
    case GANTTCHART_REQUEST:
    case SECONDTBLFIELD_REQUEST:
        return {...state,
            params:actions.payload.params, 
            loading:true,
    }  

    
    case GANTTCHART_REQUEST:
    case TBLFIELD_REQUEST:
    case TBLFIELD_SUCCESS:
        return {...state,
         loading:false,
      }  

    
    case UPLOADEXCEL_INIT:
        return {...state,
              params:actions.payload.params,
              loading:false,
    }
  

    case GANTTCHART_SUCCESS: 
    if(actions.payload.screenFlg==="second")
        {return {...state,
                  params:{...state.params,buttonflg:actions.payload.buttonflg,},
                  loading:false,
                    message:null,}
        }else{return {...state,
            loading:false,
            message:null,}}

    case SECONDTBLFIELD_SUCCESS:
            return {...state,
                params: {...state.params,messages:actions.payload.messages},
                message:actions.payload.message,
                disabled:false,
                loading:false,
                }

  case  LOGIN_REQUEST:
  case  LOGIN_SUCCESS:
    return {
        ...state,
        params:{screenMame:null,screenCode:null},
    }
               
    case  LOGOUT_REQUEST:
            return {}  
                           
     default:
        return {...state}
  }
}

export default secondreducer