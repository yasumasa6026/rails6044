import React from 'react'
import { connect } from 'react-redux'
import {Routes, Route,useNavigate,} from 'react-router-dom'
import AppBar from '@mui/material/AppBar'
import Toolbar from '@mui/material/Toolbar'
import Typography from '@mui/material/Typography'
import Button from '@mui/material/Button'
import { ThemeProvider, createTheme } from '@mui/material/styles'
import { withStyles } from '@mui/styles'
import { LogoutRequest,SignupFormRequest,ChangePasswordFormRequest} from './actions'
import Login from './components/login'
import Signup from './components/signup'
import ChangePassword from './components/changepassword'

const GlobalNav  = ( { isAuthenticated, isSubmitting,isSignUp,isLogin,
                    token,client,uid,
                    LogoutClick,SignupFormClick,ChangePasswordFormClick}) => {
               const navigate = useNavigate()
                const changepasswordform = () => {navigate('/changepassword')}
                const loginform = () => {navigate('/login')}
                const signupform = () => {navigate('/signup')}
              
    return (
      <div>
      <ThemeProvider theme={theme}>
         <StyledAppBar title="RRRP" position='static' color="primary">
         <Toolbar  position='static'>
          <Typography variant="h5" color={theme.palette.ochre.cntrastText} position='static' >
            RRRP...
          </Typography>
          <Typography variant="h5"  gutterBottom = {true}  >
            { isAuthenticated && <Button variant="contained" color='success'
              type='submit' disabled={false}
              onClick ={() => {loginform(),LogoutClick(token,client,uid)}}>
              Logout{isSubmitting && <i className='fa fa-spinner fa-spin' />}</Button>}
          </Typography>
          <Typography variant="h5"  gutterBottom = {true}  >
            { isAuthenticated && <Button variant="contained" color='success'
              type='submit' disabled={false} style={{position: 'absolute',right: 0}}
              //onClick ={() =>{ChangePasswordFormClick(),changepasswordform()}}>
              onClick ={() =>{changepasswordform()}}>
              ChangePassword{isSubmitting && <i className='fa fa-spinner fa-spin' />}</Button>}
          </Typography>
          <Typography variant="h5"  gutterBottom = {true}  >
            {!isAuthenticated && !isLogin && <Button variant="contained" color='success' 
              type='submit' disabled={false}
              onClick ={loginform}>
              {isSubmitting && <i className='fa fa-spinner fa-spin' />}Login</Button>}
           </Typography>
           <Typography variant="h5"  gutterBottom = {true}  >
            {!isAuthenticated && !isSignUp && <Button variant="contained" color='success'
              type='submit' disabled={false}
              /*onClick ={() =>{SignupFormClick(),signupform()}}>SignUp</Button>}*/
              onClick ={() =>{signupform()}}>SignUp</Button>}
          </Typography>
          </Toolbar>
      </StyledAppBar>
      </ThemeProvider>
            <Routes>
              <Route exact path="/" element={<Login/>} /> 
              <Route path="/signup" element={<Signup/>} />
              <Route path="/login" element={<Login/>} />
              <Route path="/changepassword" element={<ChangePassword/>} /> 
            </Routes>
      </div>
    )
  }

const theme = createTheme( {palette: {
  ochre: {
    main: '#E3D026',  //'#E3D026'
    light: '#E9DB5D',
    dark: '#A29415',
    contrastText: '#242105',}   //'#242105'
  }  
  })
const StyledAppBar = withStyles({
  root: {
    //background: 'linear-gradient(45deg, #FE6B8B 30%, #FF8E53 90%)',
    height: 45,
  },
})(AppBar)
const mapDispatchToProps = (dispatch,ownProps ) => {
  return{
        LogoutClick: (token,client,uid) => dispatch(LogoutRequest(token,client,uid),
                          ),
       // SignupFormClick: () => {dispatch(SignupFormRequest())},
       // ChangePasswordFormClick: () => {dispatch(ChangePasswordFormRequest())},
        }
}
const  mapStateToProps = (state) => {
  const { isSubmitting ,isAuthenticated,client,uid,token,isSignUp,isLogin} = state.auth
  return { isSubmitting ,isAuthenticated, token,client,uid,isSignUp,isLogin}
}

export default connect(mapStateToProps, mapDispatchToProps )(GlobalNav)