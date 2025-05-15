
import {takeEvery} from 'redux-saga/effects'

import {LOGIN_REQUEST,SIGNUP_REQUEST,LOGOUT_REQUEST,CHANGEPASSWORD_REQUEST,
        MENU_REQUEST,FETCH_REQUEST,SECONDFETCH_REQUEST,
        SCREENINIT_REQUEST,SCREEN_REQUEST,UPLOADEXCEL_REQUEST,
        SCREEN_CONFIRM7,SECOND_CONFIRM7,SECOND_CONFIRMALL_REQUEST,SECOND_REQUEST,
        GANTTCHART_REQUEST,BUTTONLIST_REQUEST,
        DOWNLOAD_REQUEST, YUP_REQUEST,TBLFIELD_REQUEST,
        INPUTFIELDPROTECT_REQUEST, UPDATENDITM_REQUEST, UPDATEALLOC_REQUEST,
      } from  '../../actions'

// Route Sagas
import {LoginSaga} from './login'
import {ChangePasswordSaga} from './changepassword'
import {LogoutSaga} from './logout'
import {SignupSaga} from './signup'
import {MenuSaga} from './menus'
import {DownloadSaga} from './download'
import {ScreenSaga} from './screen'//
import {ButtonListSaga} from './buttonlist'
import {GanttChartSaga} from './ganttchart'
import {TblfieldSaga} from './tblfield'
import {UploadExcelSaga} from './uploadexcel'
import {ProtectSaga} from './protect'

export function * sagas () {
  yield takeEvery(LOGIN_REQUEST,LoginSaga)
  yield takeEvery(CHANGEPASSWORD_REQUEST,ChangePasswordSaga)
  yield takeEvery(LOGOUT_REQUEST,LogoutSaga)
  yield takeEvery(SIGNUP_REQUEST,SignupSaga)
  yield takeEvery(MENU_REQUEST,MenuSaga)
  yield takeEvery(SCREENINIT_REQUEST,ScreenSaga)
  yield takeEvery(SCREEN_REQUEST,ScreenSaga)
  yield takeEvery(SECOND_REQUEST,ScreenSaga)
  yield takeEvery(SCREEN_CONFIRM7,ScreenSaga)
  yield takeEvery(SECOND_CONFIRM7,ScreenSaga)
  yield takeEvery(SECOND_CONFIRMALL_REQUEST,ScreenSaga)
  yield takeEvery(FETCH_REQUEST,ScreenSaga)
  yield takeEvery(SECONDFETCH_REQUEST,ScreenSaga)
  yield takeEvery(BUTTONLIST_REQUEST,ButtonListSaga)
  yield takeEvery(DOWNLOAD_REQUEST,DownloadSaga)
  yield takeEvery(YUP_REQUEST,TblfieldSaga)  //yupの作成　Tblfieldと同じdef
  yield takeEvery(TBLFIELD_REQUEST,TblfieldSaga)
  yield takeEvery(GANTTCHART_REQUEST,GanttChartSaga)
  yield takeEvery(UPDATENDITM_REQUEST,GanttChartSaga)
  yield takeEvery(UPDATEALLOC_REQUEST,GanttChartSaga)
  yield takeEvery(UPLOADEXCEL_REQUEST,UploadExcelSaga)
  yield takeEvery(INPUTFIELDPROTECT_REQUEST,ProtectSaga)
}