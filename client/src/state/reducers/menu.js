import {MENU_REQUEST,MENU_SUCCESS,MENU_FAILURE,
          LOGOUT_REQUEST,LOGIN_FAILURE,LOGIN_SUCCESS,
          SCREENINIT_REQUEST,SCREEN_REQUEST,SCREEN_SUCCESS7,SCREEN_FAILURE,
          SECONDFETCH_RESULT,FETCH_RESULT,TBLFIELD_SUCCESS,
          SCREEN_CONFIRM7, SCREEN_CONFIRM7_SUCCESS,
          SECOND_CONFIRMALL_REQUEST,SECOND_CONFIRMALL_SUCCESS,
          SECOND_REQUEST,SECOND_SUCCESS7,SECOND_CONFIRM7,MKSHPORDS_SUCCESS,
          SECOND_FAILURE, } from '../../actions'
const initialValues = {
  isSubmitting:false,
  isSignUp:false,
  errors:[],
  screenFlg:"first",
  firstView:true,
  secondView:false,
  params:{screenCode:null,screenName:null,buttonflg:"viewtablereq7"},
}

const menureducer =  (state= initialValues , actions) =>{
  switch (actions.type) {
    
    case MENU_REQUEST:
      return {...state,
        firstView:false,
        secondView:false,
      }

    case MENU_SUCCESS:
        return {...state,
          menuListData:actions.action,
          firstView:false,
          secondView:false,
          hostError:null,
        }

    case MENU_FAILURE:
      return {...state,
        hostError:actions.error,
    }    

    
    case SCREEN_FAILURE:  //gridtable が利用できないとき 
      return {...state,
        screenFlg:"first",
        firstView:false,
        secondView:false,
        hostError:actions.payload.message,
      loading:false,
    }  

    case FETCH_RESULT:
      return {...state,
      message:actions.payload.params.err,
      loading:false,
      hostError:null,
      firstView:true,
      secondView:false,
    }


    case SECONDFETCH_RESULT:
      return {...state,
      message:actions.payload.params.err,
      loading:false,
      hostError:null,
      firstView:true,
      secondView:true,
    }

    
    case SCREENINIT_REQUEST:
      return {...state,
        params:actions.payload.params,
        loading:true,
        firstView:false,
        secondView:false,
        hostError:null,
        message:null,
      }

    
    case SCREEN_SUCCESS7: // payloadに統一
      return {...state,
        firstView:true,
        secondView:false,
        hostError:null,
      }  
      
    case SCREEN_REQUEST:
      return {...state,
        loading:true,
        screenFlg:null,
        secondView:false,
        hostError:null,
        message:null,
      }
         
    

  case TBLFIELD_SUCCESS:
    return {...state,
    params: {...state.params},
    message:actions.payload.message,
    disabled:false,
    loading:false,
    firstView:true,
    secondView:false,
    }  


    case SECOND_CONFIRM7:
    case SECOND_CONFIRMALL_REQUEST:  
          return {...state,
                    loading:true,
                    firstView:true,
                    hostError:null,
                    message:actions.payload.message,
      }

    
      case  SCREEN_CONFIRM7_SUCCESS:
              return {...state,
                        loading:false,
                        firstView:true,
                        secondView:false,
                        message:actions.payload.message,
                        hostError:actions.payload.params.err,
          }
          
      
      case SCREEN_CONFIRM7:
            return {...state,
                      loading:true,
                      secondView:false,
                      hostError:null,
        }      

    
      case MKSHPORDS_SUCCESS:
          return {...state,
          message:actions.payload.message, 
          loading:false,
      }    

      case LOGIN_SUCCESS:
            return {...state,
              firstView:false,
              secondView:false,
      }


  //  case MKSHPACTS_RESULT:
    case SECOND_REQUEST:
        return {...state,
          screenFlg:"second",
          secondView:true,
          loading:true,
          hostError:null,
        }   

    
   
      case SECOND_SUCCESS7: // payloadに統一
        return {...state,
          secondView:true,
          hostError:null,
        }
        
    case SECOND_CONFIRMALL_SUCCESS:
      return {...state,
        screenFlg:"second",
        secondView:true,
        loading:false,
      }   

    case SECOND_FAILURE:
          return {...state,
            screenFlg:"second",
            secondView:true,
            loading:false,
          }   


    case  LOGOUT_REQUEST:
    return {}  

      
    case  LOGIN_FAILURE:
      return {
        firstView:false,
        secondView:false,
        hostError:actions.payload.message,
}

    default:
      return  {...state,
      }   
  }
}

export default menureducer