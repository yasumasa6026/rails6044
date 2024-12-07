import {MENU_REQUEST,MENU_SUCCESS,LOGOUT_REQUEST,MENU_FAILURE,LOGIN_FAILURE,
          SCREENINIT_REQUEST,SCREEN_REQUEST,SCREEN_SUCCESS7,SCREEN_FAILURE,SCREEN_CONFIRM7_SUCCESS,
          SCREEN_CONFIRM7,LOGIN_SUCCESS,
          SECOND_CONFIRMALL_REQUEST,SECOND_CONFIRMALL_SUCCESS,SECOND_REQUEST,SECOND_SUCCESS7,SECOND_CONFIRM7,
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
        }

    case MENU_FAILURE:
      return {...state,
        message:actions.errors,
    }    

    
    case SCREEN_FAILURE:
      return {...state,
        screenFlg:"first",
        firstView:true,
        secondView:false,
      loading:false,
    }

    
    case SCREENINIT_REQUEST:
      return {...state,
        params:actions.payload.params,
        loading:true,
        firstView:false,
        secondView:false,
      }

    
    case SCREEN_SUCCESS7: // payloadに統一
      return {...state,
        firstView:true,
        secondView:false,
      }  
      
    case SCREEN_REQUEST:
      return {...state,
        loading:true,
        screenFlg:null,
      }
         
    case SCREEN_CONFIRM7:
    case SECOND_CONFIRM7:
    case SECOND_CONFIRMALL_REQUEST:  
          return {...state,
                    loading:true,
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
        }   

    
   
      case SECOND_SUCCESS7: // payloadに統一
        return {...state,
          secondView:true,
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