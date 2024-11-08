import {MENU_REQUEST,MENU_SUCCESS,LOGOUT_REQUEST,MENU_FAILURE,LOGIN_FAILURE,
          SCREENINIT_REQUEST,SCREEN_REQUEST,SCREEN_SUCCESS7,SCREEN_FAILURE,SCREEN_CONFIRM7_SUCCESS,
          SCREEN_CONFIRM7,LOGIN_SUCCESS,CHANGE_SHOW_SCREEN,
          SECOND_CONFIRMALL_REQUEST,SECOND_CONFIRMALL_SUCCESS,SECOND_REQUEST,SECOND_SUCCESS7,SECOND_CONFIRM7,
          SECOND_FAILURE, } from '../../actions'
const initialValues = {
  isSubmitting:false,
  isSignUp:false,
  errors:[],
  screenFlg:"first",
  params:{screenCode:null,screenName:null,buttonflg:"viewtablereq7"},
}

const menureducer =  (state= initialValues , actions) =>{
  switch (actions.type) {
    
    case MENU_REQUEST:
      return {...state,
        showScreen:false,
      }

    case MENU_SUCCESS:
        return {...state,
          hostError: null,
          message:null,
          menuListData:actions.action,
          showScreen:false,
        }

    case MENU_FAILURE:
      return {...state,
        message:actions.errors,
    }    

    
    case SCREEN_FAILURE:
      return {...state,
        screenFlg:"first",
        hostError: actions.payload.message,
      loading:false,
    }


    case CHANGE_SHOW_SCREEN:
      return { ...state,
              showScreen:actions.payload.showScreen}
    
    case SCREENINIT_REQUEST:
      return {...state,
        params:actions.payload.params,
        loading:true,
        showScreen:false,
      }

      
    case SCREEN_REQUEST:
      return {...state,
        loading:true,
        screenFlg:null,
        showScreen:false,
       // showScreen:false,
      }

    case SCREEN_SUCCESS7:
    case SCREEN_CONFIRM7_SUCCESS:  
          return {...state,
            showScreen:true,
            hostError: null,
            message:null,
            screenFlg:"first",
            loading:false,
    }
    
    case SECOND_SUCCESS7:
          return {...state,
            hostError: null,
            message:null,
            screenFlg:"second",
            loading:false,
            showScreen:true,
    }
      
    case SCREEN_CONFIRM7:
    case SECOND_CONFIRM7:
    case SECOND_CONFIRMALL_REQUEST:  
          return {...state,
                    loading:true,
      }

      case LOGIN_SUCCESS:
            return {...state,
              showScreen:false,
      }


  //  case MKSHPACTS_RESULT:
    case SECOND_REQUEST:
        return {...state,
          screenFlg:"second",
          loading:true,
        }   
        
    case SECOND_CONFIRMALL_SUCCESS:
      return {...state,
        screenFlg:"second",
        loading:false,
      }   

    case SECOND_FAILURE:
          return {...state,
            screenFlg:"second",
            loading:false,
            hostError: actions.payload.message
          }   


    case  LOGOUT_REQUEST:
    return {}  

      
    case  LOGIN_FAILURE:
      return {
        showScreen:false,
        hostError:actions.payload.message
}

    default:
      return  {...state,
        showScreen:true,
      }   
  }
}

export default menureducer