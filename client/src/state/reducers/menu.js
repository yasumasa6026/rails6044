import {  MENU_REQUEST, MENU_SUCCESS,LOGOUT_REQUEST,MENU_FAILURE,
          SCREENINIT_REQUEST,SCREEN_SUCCESS7, 
          //MKSHPACTS_RESULT,
           SECOND_CONFIRMALL_SUCCESS,SECOND_REQUEST,SECOND_SUCCESS7,SECOND_CONFIRM7,
          SECOND_FAILURE,SECONDFETCH_REQUEST,SECONDFETCH_FAILURE,SECONDFETCH_RESULT,
              } from '../../actions'
const initialValues = {
  isSubmitting:false,
  isSignUp:false,
  errors:[],
  screenFlg:"first",
}

const menureducer =  (state= initialValues , actions) =>{
  switch (actions.type) {
    
    case MENU_REQUEST:
      return {...state,
        token:actions.payload.token,
        client:actions.payload.client,
        uid:actions.payload.uid,}

    case MENU_SUCCESS:
      return {...state,
        hostError: null,
        message:null,
        menuListData:actions.action,
      }

    case MENU_FAILURE:
      return {...state,
        message:actions.errors,
    }    
    
    case SCREENINIT_REQUEST:
      return {...state,
        menuChanging:true,
      }

    case SCREEN_SUCCESS7:
          return {...state,
            hostError: null,
            message:null,
            menuChanging:false,
            screenFlg:"first",
    }


  //  case MKSHPACTS_RESULT:
    case SECOND_CONFIRMALL_SUCCESS:
    case SECOND_REQUEST:
    case SECOND_SUCCESS7: 
    case SECOND_CONFIRM7:
    case SECOND_FAILURE:
    case SECONDFETCH_REQUEST:
    case SECONDFETCH_FAILURE:
    case SECONDFETCH_RESULT:
        return {...state,
          screenFlg:"second",
        }   

    case  LOGOUT_REQUEST:
    return {}  

    default:
      return state
  }
}

export default menureducer