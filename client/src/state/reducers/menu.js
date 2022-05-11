import {  MENU_REQUEST, MENU_SUCCESS,LOGOUT_REQUEST,MENU_FAILURE,
          SCREENINIT_REQUEST,SCREEN_SUCCESS7,SCREEN_FAILURE,  } from '../../actions'
const initialValues = {
  isSubmitting:false,
  isSignUp:false,
  errors:[],
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
    }

    case SCREEN_FAILURE:
      return {...state,
        hostError: actions.payload.message,
        loading:false,
      } 


    case  LOGOUT_REQUEST:
    return {}  

    default:
      return state
  }
}

export default menureducer