import React from 'react'
import { connect } from 'react-redux'
import AppBar from '@material-ui/core/AppBar'
import Toolbar from '@material-ui/core/Toolbar'
import Typography from '@material-ui/core/Typography'
import { withStyles } from '@material-ui/core/styles'
import {Button} from './styles/button'
import { LogoutRequest, SignUpFormRequest,LoginFormRequest,} from './actions'

class GlobalNav extends React.Component {
  render() {
    const { isAuthenticated, isSubmitting,token,client,uid,
              isSignUp,LogoutClick,SignUpClick, LoginClick,} = this.props
    return (
      <div>
      <StyledAppBar title="RRRP" position='static'>
         <Toolbar  position='static'>
          <Typography variant="h5" color="inherit" position='static' >
            RRRP...
          </Typography>
          <Typography variant="h5"  gutterBottom = {true}>
          { isAuthenticated ? <Button variant="outlined" color="secondary" 
              type='submit' disabled={false}
              onClick ={() => LogoutClick(token,client,uid)}>
              Logout{isSubmitting && <i className='fa fa-spinner fa-spin' />}</Button>
            :isSignUp?<Button variant="outlined" color="secondary" 
              type='submit' disabled={false}
              onClick ={() => LoginClick()}>
              {isSubmitting && <i className='fa fa-spinner fa-spin' />}Login</Button>
            :<Button variant="outlined"
              type='submit' disabled={false}
              onClick ={( isSignUp) => SignUpClick( isSignUp)}>SignUp</Button>}
          </Typography>
          </Toolbar>
      </StyledAppBar>
      </div>
    )
  }
}

//this.ownProps.history.replace(`/login`),
const mapDispatchToProps = (dispatch,ownProps ) => {
  return{
        LogoutClick: (token,client,uid) => dispatch(LogoutRequest(token,client,uid),
                          ),
        LoginClick: ( isSignUp) => dispatch(LoginFormRequest( isSignUp),
                          ),
        SignUpClick: ( isSignUp) => dispatch(SignUpFormRequest( isSignUp),
                          ),
        }
}
const  mapStateToProps = (state) => {
  const { isSubmitting ,isAuthenticated,client,uid,isSignUp,token} = state.auth
  return { isSubmitting ,isAuthenticated, token,client,uid,isSignUp}
}

const StyledAppBar = withStyles({
  root: {
    //background: 'linear-gradient(45deg, #FE6B8B 30%, #FF8E53 90%)',
    height: 45,
  },
})(AppBar)

export default connect(mapStateToProps, mapDispatchToProps )(GlobalNav)