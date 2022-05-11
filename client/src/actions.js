
export const LOGINFORM_REQUEST = 'LOGINFORM_REQUEST'
export const LOGINFORM_SUCCESS = 'LOGINFORM_SUCCESS'
export const LOGIN_REQUEST = 'LOGIN_REQUEST'
export const LOGIN_SUCCESS = 'LOGIN_SUCCESS'
export const LOGIN_FAILURE = 'LOGIN_FAILURE'

export const LOGOUT_REQUEST = 'LOGOUT_REQUEST'
export const LOGOUT_SUCCESS = 'LOGOUT_SUCCESS'

export const SIGNUPFORM_REQUEST = 'SIGNUPFORM_REQUEST'
export const SIGNUPFORM_SUCCESS = 'SIGNUPFORM_SUCCESS'
export const SIGNUP_REQUEST = 'SIGNUP_REQUEST'
export const SIGNUP_SUCCESS = 'SIGNUP_SUCCESS'
export const SIGNUP_FAILURE = 'SIGNUP_FAILURE'

export const MENU_REQUEST = 'MENU_REQUEST'
export const MENU_SUCCESS = 'MENU_SUCCESS'
export const MENU_FAILURE = 'MENU_FAILURE'

export const SCREENINIT_REQUEST = 'SCREENINIT_REQUEST'
export const SCREEN_REQUEST = 'SCREEN_REQUEST'
export const SCREEN_SUCCESS7 = 'SCREEN_SUCCESS7'
export const SCREEN_PARAMS_SET = 'SCREEN_PARAMS_SET'
export const SCREEN_LINEEDIT = 'SCREEN_LINEEDIT'

export const SCREEN_FAILURE = 'SCREEN_FAILURE'

export const BUTTONLIST_REQUEST = 'BUTTONLIST_REQUEST'
export const BUTTONLIST_SUCCESS = 'BUTTONLIST_SUCCESS'
export const BUTTONLIST_FAILFURE = 'BUTTONLIST_FAILURE'

export const BUTTONFLG_REQUEST = 'BUTTONFLG_REQUEST'
export const BUTTON_RESET = 'BUTTON_RESET'
export const GANTT_RESET = 'GANTT_RESET'

export const DOWNLOAD_REQUEST = 'DOWNLOAD_REQUEST'
export const DOWNLOAD_SUCCESS = 'DOWNLOAD_SUCCESS'
export const DOWNLOAD_FAILURE = 'DOWNLOAD_FAILURE'

export const FETCH_REQUEST = 'FETCH_REQUEST'
export const FETCH_RESULT = 'FETCH_RESULT'
export const FETCH_FAILURE = 'FETCH_FAILURE'

export const MKSHPINSTS_SUCCESS = 'MKSHPINSTS_SUCCESS'
export const MKSHPINSTS_RESULT = 'MKSHPINSTS_RESULT'
export const MKSHPACTS_RESULT = 'MKSHPACTS_RESULT'
export const CONFIRMALL_REQUEST = 'CONFIRMALL_REQUEST'
export const CONFIRMALL_SUCCESS = 'CONFIRMALL_SUCCESS'

export const SECONDSCREEN_REQUEST = 'SECONDSCREEN_REQUEST'
export const SECONDSCREEN_SUCCESS7 = 'SECONDSCREEN_SUCCESS7'
export const SECONDSCREEN_FAILURE = 'SECONDSCREEN_FAILURE'
export const SECONDFETCH_REQUEST = 'SECONDFETCH_REQUEST'
export const SECONDFETCH_RESULT = 'SECONDFETCH_RESULT'
export const SECONDFETCH_FAILURE = 'SECONDFETCH_FAILURE'
export const SECONDSCREEN_LINEEDIT = 'SECONDSCREEN_LINEEDIT'
export const SECONDSCREEN_PARAMS_SET = 'SECONDSCREEN_PARAMS_SET'

export const IMPORTEXCEL_REQUEST = 'IMPORTEXCEL_REQUEST'
export const IMPORTEXCEL_SUCCESS = 'IMPORTEXCEL_SUCCESS'
export const IMPORTEXCEL_FAILURE = 'IMPORTEXCEL_FAILURE'
export const INPUTFIELDPROTECT_REQUEST = 'INPUTFIELDPROTECT_REQUEST'
export const INPUTPROTECT_RESULT = 'INPUTPROTECT_RESULT'

export const YUP_RESULT = 'YUP_RESULT'
export const YUP_REQUEST = 'YUP_REQUEST'
export const YUP_ERR_SET = 'YUP_ERR_SET'
export const TBLFIELD_REQUEST = 'TBLFIELD_REQUEST'
export const TBLFIELD_SUCCESS = 'TBLFIELD_SUCCESS'
export const TBLFIELD_FAILURE = 'TBLFIELD_FAILFURE'
export const DROPDOWNVALUE_SET = 'DROPDOWNVALUE_SET'

export const GANTTCHART_REQUEST = 'GANTTCHART_REQUEST'
export const GANTTCHART_FAILURE = 'GANTTCHART_FAILURE'
export const GANTTCHART_SUCCESS = 'GANTTCHART_SUCCESS'
export const RESET_REQUEST = 'RESET_REQUEST'

// LOGIN
// Attach our Formik actions as meta-data to our action.

export const SignUpFormRequest =  ( isSignUp) => ({
  type:SIGNUPFORM_REQUEST,
  payload: { isSignUp }
})

export const SignUpFormSuccess =  ( isSignUp) => ({
  type:SIGNUPFORM_SUCCESS,
  payload: { isSignUp }
})

export const LoginFormRequest =  ( isSignUp) => ({
  type:LOGINFORM_REQUEST,
  payload: { isSignUp }
})

export const LoginFormSuccess =  ( isSignUp) => ({
  type:LOGINFORM_SUCCESS,
  payload: { isSignUp }
})

export const SignUpRequest =  (email, password,password_confirmation) => ({
  type:SIGNUP_REQUEST,
  payload: { email, password ,password_confirmation}
})

export const LoginRequest  = (email, password) => ({
  type: LOGIN_REQUEST,
  payload: { email, password }
})

export const LogoutRequest =  (token,client,uid) => ({
  type: LOGOUT_REQUEST,
  payload: { token,client,uid }
})

export const LogoutSuccess = () => ({
  type: LOGOUT_SUCCESS,
 // payload: {token,client,uid }
})

export const MenuRequest = (token,client,uid) => ({
  type:  MENU_REQUEST,
  payload:{token,client,uid} 
})

export const MenuFailure = (errors) => ({
  type: MENU_FAILURE,
  errors: { errors }  //
})

export const ScreenInitRequest = (params,data) => ({
  type:  SCREENINIT_REQUEST,
  payload: { params,data}  //
})

export const ScreenRequest = (params,data) => ({
  type:  SCREEN_REQUEST,
  payload: { params,data}  //
})

export const ResetRequest = (params) => ({
  type:  RESET_REQUEST,
  payload: { params}  //
})

export const ScreenParamsSet = (params) => ({
  type:  SCREEN_PARAMS_SET,
  payload: { params}  //
})

export const SecondScreenParamsSet = (params) => ({
  type:  SECONDSCREEN_PARAMS_SET,
  payload: { params}  //
})


export const SecondScreenRequest = (params,data) => ({
  type:  SECONDSCREEN_REQUEST,
  payload: { params,data}  //
})

export const YupErrSet = (data,error) => ({
  type:  YUP_ERR_SET,
  payload: {data,error}  //
})

export const DropDownValueSet = (dropDownValue) => ({
  type:  DROPDOWNVALUE_SET,
  payload: {dropDownValue}  //
})

export const ScreenFailure = (errors) => ({
  type: SCREEN_FAILURE,
  errors: { errors }  //
})

export const DownloadRequest = (params) => ({
  type: DOWNLOAD_REQUEST,
  payload: { params:params}
})

export const ButtonListRequest = (token,client,uid) => ({
  type:  BUTTONLIST_REQUEST,
  payload:{token,client,uid} 
})
export const ButtonListSuccess = (buttonListData) => ({
  type:  BUTTONLIST_SUCCESS,
  payload:{buttonListData} 
})
export const ButtonListFailure = (error) => ({
  type:  BUTTONLIST_FAILFURE,
  payload:{error} 
})

export const ButtonFlgRequest = (buttonflg,params) => ({
  type: BUTTONFLG_REQUEST,
  payload: { buttonflg,params}
})


export const FetchRequest = (params,data) => ({
  type: FETCH_REQUEST,
  payload: { params,data }
})

export const FetchResult = (params) => ({
  type: FETCH_RESULT,
  payload: { params}
})

export const FetchFailure = (params) => ({
  type: FETCH_FAILURE,
  payload: { params}
})
export const SecondFetchRequest = (params,data) => ({
  type: SECONDFETCH_REQUEST,
  payload: { params,data }
})

export const SecondFetchResult = (data,params) => ({
  type: SECONDFETCH_RESULT,
  payload: {params}
})

export const SecondFetchFailure = (data,params) => ({
  type: SECONDFETCH_FAILURE,
  payload: { data,params}
})

export const SecondScreenFailure = (errors) => ({
  type: SECONDSCREEN_FAILURE,
  errors: { errors }  //
})

export const MkShpinstsResult = (data,params) => ({
  type: MKSHPINSTS_RESULT,
  payload: { data,params}
})

export const ConfirmAllRequest = (params,data) => ({
  type: CONFIRMALL_REQUEST,
  payload:{params,data}
})

export const InputFieldProtectRequest = () => ({
  type: INPUTFIELDPROTECT_REQUEST,
})
export const InputProtectResult = () => ({
  type: INPUTPROTECT_RESULT,
})

export const YupRequest = (params) => ({
  type:  YUP_REQUEST,
  payload: { params}  //
})

export const TblfieldRequest = (params) => ({
  type:  TBLFIELD_REQUEST,
  payload: { params}  //
})

export const TblfielSuccess = (messages) => ({
  type:  TBLFIELD_SUCCESS,
  payload: { messages}  //
})

export const GanttChartRequest = (params) => ({
  type:  GANTTCHART_REQUEST,
  payload: { params}  //
})


export const ButtonReset = () => ({
  type:  BUTTON_RESET,
   //
})

export const GanttReset = () => ({
  type:  GANTT_RESET,
})


export const ImportExcelRequest = ({excelfile,nameToCode,params}) => ({
  type: IMPORTEXCEL_REQUEST,  // 
  payload: {excelfile,nameToCode,params,}
})


export const ImportExcelSuccess = (payload) => ({
  type: IMPORTEXCEL_SUCCESS,  // 
  payload: {idx:payload.idx}
})


export const ImportExcelFailure = (payload) => ({
  type: IMPORTEXCEL_FAILURE,  // 
  payload: {importError:payload.importError}
})
