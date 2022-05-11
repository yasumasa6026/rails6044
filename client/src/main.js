import React from 'react'
import { BrowserRouter as Router,Routes, Route,} from 'react-router-dom'
import Login from './components/login'
import Signup from './components/signup'
import Menus7 from './components/menus7'


class Main extends React.Component {
 render(){
    return( 
    <main>
    <Router>
      <Routes>
        <Route exact path="/" element={<Login/>} /> 
        <Route path="/menus7" element={<Menus7/>} />
        <Route path="/signup" element={<Signup/>} />
        <Route path="/login" element={<Login/>} />
      </Routes>
    </Router>
    </main>)}
}

export default (Main)