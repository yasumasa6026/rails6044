import React from 'react'
import { createRoot }  from 'react-dom/client'
import {Provider} from 'react-redux'
import { PersistGate } from 'redux-persist/integration/react'

import {store,persistor} from './state/store'
import {BrowserRouter } from 'react-router-dom'
import history from './histrory'



import GlobalNav from './globalNav'

const root = createRoot(document.getElementById('root'))

  root.render(
    <Provider store={store}>
    <PersistGate loading={null} persistor={persistor}>
         <BrowserRouter navigator={history} location={history.location}>
        <GlobalNav />
        </BrowserRouter>
    </PersistGate>
    </Provider>
    , )
