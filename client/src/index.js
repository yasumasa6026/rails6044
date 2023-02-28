import React from 'react'
//import ReactDOM from 'react-dom'
import { createRoot }  from 'react-dom/client'
import {Provider} from 'react-redux'
//import { Router} from 'react-router-dom'
{/* import history from './histrory' */}
import { PersistGate } from 'redux-persist/integration/react'

import {store,persistor} from './state/store'


import GlobalNav from './globalNav'
import Main from './main'

const root = createRoot(document.getElementById('root'))

  root.render(
    <Provider store={store}>
    {/* <Router history={ history } > */}
    <PersistGate loading={null} persistor={persistor}>
      <GlobalNav />
      <Main></Main>
    </PersistGate>
    {/* </Router> */}
    </Provider>
    , )
