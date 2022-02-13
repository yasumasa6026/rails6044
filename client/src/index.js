import React from 'react'
import ReactDOM from 'react-dom'
import {Provider} from 'react-redux'
import { Router} from 'react-router-dom'
{/* import history from './histrory' */}
import { PersistGate } from 'redux-persist/integration/react'

import {store,persistor} from './state/store'


import GlobalNav from './globalNav'
import Main from './main'

ReactDOM.render(
  <Provider store={store}>
  {/* <Router history={ history } > */}
  <PersistGate loading={null} persistor={persistor}>
    <GlobalNav />
    <Main></Main>
  </PersistGate>
  {/* </Router> */}
  </Provider>
  , document.getElementById('root'))
