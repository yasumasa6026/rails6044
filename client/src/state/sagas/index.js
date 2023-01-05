
import {takeEvery} from 'redux-saga/effects'

import {LOGIN_REQUEST,SIGNUP_REQUEST,MENU_REQUEST,FETCH_REQUEST,
        SCREENINIT_REQUEST,SCREEN_REQUEST,IMPORTEXCEL_REQUEST,
        SECOND_REQUEST,
        GANTTCHART_REQUEST,BUTTONLIST_REQUEST,
        DOWNLOAD_REQUEST, YUP_REQUEST,TBLFIELD_REQUEST,
        INPUTFIELDPROTECT_REQUEST, LOGOUT_REQUEST,
      } from  '../../actions'

// Route Sagas
import {LoginSaga} from './login'
import {LogoutSaga} from './logout'
import {SignupSaga} from './signup'
import {MenuSaga} from './menus'
import {DownloadSaga} from './download'
import {ScreenSaga} from './screen'//
import {ButtonListSaga} from './buttonlist'
import {GanttChartSaga} from './ganttchart'
import {TblfieldSaga} from './tblfield'
import {ImportExcelSaga} from './importexcel'
import {ProtectSaga} from './protect'

export function * sagas () {
  yield takeEvery(LOGIN_REQUEST,LoginSaga)
  yield takeEvery(LOGOUT_REQUEST,LogoutSaga)
  yield takeEvery(SIGNUP_REQUEST,SignupSaga)
  yield takeEvery(MENU_REQUEST,MenuSaga)
  yield takeEvery(SCREENINIT_REQUEST,ScreenSaga)
  yield takeEvery(SCREEN_REQUEST,ScreenSaga)
  yield takeEvery(SECOND_REQUEST,ScreenSaga)
  yield takeEvery(FETCH_REQUEST,ScreenSaga)
  yield takeEvery(BUTTONLIST_REQUEST,ButtonListSaga)
  yield takeEvery(DOWNLOAD_REQUEST,DownloadSaga)
  yield takeEvery(YUP_REQUEST,TblfieldSaga)  //yupの作成　Tblfieldと同じdef
  yield takeEvery(TBLFIELD_REQUEST,TblfieldSaga)
  yield takeEvery(GANTTCHART_REQUEST,GanttChartSaga)
  yield takeEvery(IMPORTEXCEL_REQUEST,ImportExcelSaga)
  yield takeEvery(INPUTFIELDPROTECT_REQUEST,ProtectSaga)
}