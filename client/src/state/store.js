
import {applyMiddleware,  createStore} from 'redux'
import createSagaMiddleware from 'redux-saga'
//import {composeWithDevTools} from 'redux-devtools-extension'
import { routerMiddleware } from 'react-router-redux'
import history from '../histrory'
import { persistStore, persistReducer } from 'redux-persist'
import storage from 'redux-persist/lib/storage' // defaults to localStorage for web and AsyncStorage for react-native
 
import {sagas} from './sagas'
import reducer from './reducers'

const persistConfig = {
  key: 'root',
  storage,
}
 
const sagasMiddleware = createSagaMiddleware()
const persistedReducer = persistReducer(persistConfig, reducer)
// Use Redux DevTools Extension in development.
//const composeEnhancers = (middlewares) =>(
//  typeof window !== 'undefined'
//    ? composeWithDevTools(middlewares)
//    : compose(middlewares)
//)  
const middleware = applyMiddleware(
  routerMiddleware(history),
  sagasMiddleware
)

export let store = createStore(
  persistedReducer, // new root reducer with router state
  middleware)
export let persistor = persistStore(store)

// Boot up saga middleware and our routing.
sagasMiddleware.run(sagas)
