//api_user_session POST /api/auth/sign_in(.:format) api/auth/sessions#create
import {put} from 'redux-saga/effects'
import {INPUTPROTECT_RESULT} from '../../actions'


const delay = (ms) => new Promise(res => setTimeout(res, ms))

export function* ProtectSaga() {
        yield delay(100)
        yield put({ type:INPUTPROTECT_RESULT })
}