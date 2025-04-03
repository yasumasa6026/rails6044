import {MENU_REQUEST,MENU_SUCCESS,MENU_FAILURE,
          LOGOUT_REQUEST,LOGIN_FAILURE,LOGIN_SUCCESS,LOGOUT_SUCCESS,
          SCREENINIT_REQUEST,SCREEN_REQUEST,SCREEN_SUCCESS7,SCREEN_FAILURE,
          SECONDFETCH_RESULT,FETCH_RESULT,TBLFIELD_SUCCESS,
          SCREEN_CONFIRM7, SCREEN_CONFIRM7_SUCCESS,CONFIRMALL_SUCCESS,
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
/*
MENU_REQUEST firstView と secondView を false に設定した新しい状態を返します。
MENU_SUCCESS  menuListData をアクションのデータで更新し、firstView と secondView を false に設定し、hostError を null に設定した新しい状態を返します。
MENU_FAILURE  hostError をアクションのペイロードから取得し、新しい状態を返します。
SCREEN_FAILURE  screenFlg を "first" に設定し、secondView を false に設定し、hostError と message をアクションのペイロードから取得し、loading を false に設定した新しい状態を返します。
FETCH_RESULT  message をアクションのペイロードから取得し、loading を false に設定し、hostError を null に設定し、firstView を true に設定し、secondView を false に設定した新しい状態を返します。
SECONDFETCH_RESULT  message をアクションのペイロードから取得し、loading を false に設定し、hostError を null に設定し、firstView を true に設定し、secondView を true に設定した新しい状態を返します。
SCREENINIT_REQUEST  params をアクションのペイロードから取得した新しい状態を返します。
*/

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
        hostError:actions.payload.hostError,
    }    

    
    case SCREEN_FAILURE:  //gridtable が利用できないとき 
      return {...state,
        screenFlg:"first",
        secondView:false,
        hostError:actions.payload.hostError,
        message:actions.payload.message,
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
        message: actions.payload.params.message,
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

      case CONFIRMALL_SUCCESS:
          return {...state,
            screenFlg:"first",
            loading:false,
            firstView:true,
            message:actions.payload.message,
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
          message: actions.payload.params.message,
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
        hostError:actions.payload.error,
      }

    case  LOGOUT_SUCCESS:
            return {
              isAuthenticated:false,
            }

    default:
      return  {...state,
      }   
  }
}

export default menureducer