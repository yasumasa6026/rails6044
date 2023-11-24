//sigin_in(login) & sign_up

import { SIGNUPFORM_REQUEST,SIGNUPFORM_SUCCESS,          
          SIGNUP_REQUEST,SIGNUP_SUCCESS,SIGNUP_FAILURE,
          LOGIN_REQUEST,LOGIN_SUCCESS,LOGIN_FAILURE,
          LOGOUT_REQUEST, LOGOUT_SUCCESS, } from '../../actions'

          
export let getAuthState = state => state.auth
const initialValues = {
  isSubmitting:false,
  errors:[],
  isAuthenticated:false,
  isSignUp:false,
  email:"",
  auth:{},
}

const authreducer =  (state= initialValues , actions) =>{
  switch (actions.type) {

    case SIGNUPFORM_REQUEST:
      return {...state,
        isSubmitting:false,
        isSignUp:true,
      }

    case SIGNUPFORM_SUCCESS:
        return {...state,
          isSubmitting:false,
          isSignUp:true,
        }
  
    case SIGNUP_REQUEST:
      return {
        isSubmitting:true,
        isSignUp:true,
        message: "signining in...",
      }

    // Successful?  Reset the signup state.
    case SIGNUP_SUCCESS:
      return {...state,
        isSubmitting:false,
        isSignUp:true,
        error: "ok"
      }

    // Append the error returned from our api
    // set the success and requesting flags to false
    case SIGNUP_FAILURE:
      return {
          time: new Date(),
          isSubmitting:false,
          isSignUp:true,
          error: actions.payload   /// payloadに統一
      }
    // Set the requesting flag and append a message to be shown
    case LOGIN_REQUEST:
      return {
        isSubmitting:true,
        isAuthenticated:false,
        error:"",
      }

    // Successful?  Reset the login state.
    case LOGIN_SUCCESS:
      return {...state,
        message: [],
        isAuthenticated:true,
        token:actions.payload["access-token"], 
        client:actions.payload.client, 
        uid:actions.payload.uid,
        isSubmitting:false,
      }

 
    // Append the error returned from our api
    // set the success and requesting flags to false
    case LOGIN_FAILURE:
      return {...state,
        isAuthenticated:false,
        isSubmitting:false,
        error:actions.payload,
    }

    case LOGOUT_REQUEST:
    return {
      token:actions.payload.token, 
      client:actions.payload.client, 
      uid:actions.payload.uid, }

    case LOGOUT_SUCCESS:
      return {
        isSignUp:false,
        isAuthenticated:false,
      }
 

    default:
      return state
  }
}

export default authreducer
