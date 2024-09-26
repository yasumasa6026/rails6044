import React from 'react'
import { connect } from 'react-redux'
import AppBar from '@mui/material/AppBar'
import Toolbar from '@mui/material/Toolbar'
import Typography from '@mui/material/Typography'
import Button from '@mui/material/Button'
import { ThemeProvider, createTheme } from '@mui/material/styles'
import { createStyles, makeStyles ,withStyles } from '@mui/styles'
//import {Button} from './styles/button'
import { LogoutRequest, SignUpFormRequest,LoginRequest,} from './actions'

class GlobalNav extends React.Component {
  render() {
    const { isAuthenticated, isSubmitting,token,client,uid,
              isSignUp,LogoutClick,SignUpClick, LoginClick,} = this.props
    return (
      <div>
      <ThemeProvider theme={theme}>
         <StyledAppBar title="RRRP" position='static' color="primary">
         <Toolbar  position='static'>
          <Typography variant="h5" color={theme.palette.ochre.cntrastText} position='static' >
            RRRP...
          </Typography>
          <Typography variant="h5"  gutterBottom = {true}  >
          { isAuthenticated ? <Button variant="contained" color='success'
              type='submit' disabled={false}
              onClick ={() => LogoutClick(token,client,uid)}>
              Logout{isSubmitting && <i className='fa fa-spinner fa-spin' />}</Button>
            :isSignUp?<Button variant="contained" color='success' 
              type='submit' disabled={false}
              onClick ={() => LoginClick()}>
              {isSubmitting && <i className='fa fa-spinner fa-spin' />}Login</Button>
            :<Button variant="contained" color='success'
              type='submit' disabled={false}
              onClick ={( isSignUp) => SignUpClick( isSignUp)}>SignUp</Button>}
          </Typography>
          </Toolbar>
      </StyledAppBar>
      </ThemeProvider>
      </div>
    )
  }
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
// const StyledAppBar = withTheme(({ theme }) => {
//        theme.GlobalNav
//      })
//this.ownProps.history.replace(`/login`),
const mapDispatchToProps = (dispatch,ownProps ) => {
  return{
        LogoutClick: (token,client,uid) => dispatch(LogoutRequest(token,client,uid),
                          ),
        LoginClick: ( isSignUp) => dispatch(LoginRequest( isSignUp),
                          ),
        SignUpClick: ( isSignUp) => dispatch(SignUpFormRequest( isSignUp),
                          ),
        }
}
const  mapStateToProps = (state) => {
  const { isSubmitting ,isAuthenticated,client,uid,isSignUp,token} = state.auth
  return { isSubmitting ,isAuthenticated, token,client,uid,isSignUp}
}


// const MyAnchorStyled = withStyles("a", (theme, { href }) => ({
//   root: {
//       border: "1px solid black",
//       backgroundColor: href?.startsWith("https")
//           ? theme.palette.primary.main
//           : "red"
//   }
// }))

export default connect(mapStateToProps, mapDispatchToProps )(GlobalNav)