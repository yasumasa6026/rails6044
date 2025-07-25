import React from 'react'
import {connect} from 'react-redux'
import {SignUpRequest} from '../actions'
import { useForm} from 'react-hook-form'

// LOGIN FORM
// @NOTE For forms that can be reused for both create/update you would move this form to its own
// file and import it with different initialValues depending on the use-case. An over-optimization
// for this simple signup form however.
const SignUp = ({isSubmitting,onSubmit,result}) => {
  const { register, handleSubmit, formState: { errors }, watch, } = useForm()
  return(
  <div>
  <form  onSubmit={handleSubmit(onSubmit)}>
    <h1>SignUp</h1>
  <ul>
    <li>
      <label htmlFor="email">
      email:
      </label>
      <input type="email" placeholder="mail" {...register(
            "email",
            {
            required: 'this is required',
            pattern: {
              value: /^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/,
              message: 'Invalid email address',
            },
          })}/>
      {errors.email && errors.email.message}
    </li>
    <li>
      <label htmlFor="password">
      password:
      </label>
      <input type="password" {...register(
        "password",
          { required: true , minLength: { value: 8, message: 'Password must be at least 8 characters long' } })}  />
    </li>
    <li>
      <label htmlFor="password_confirmation">
      password_confirmation:
      </label>
      <input type="password" 
             {...register(
              "password_confirmation",
               {validate: (value) => value === watch('password') || "Passwords don't match."})}  />
    </li>
  </ul>
    <button type="submit" disabled={isSubmitting}>
    Submit
    </button>
  </form>
        <div style={{ color: 'red' }}>
          {errors.password &&
            ` password error.${errors.password.message}`}
          {errors.password_confirmation &&
            ` password confirmation does not match.${errors.password_confirmation.message}`}
            {result}
        </div>
  </div>
  )
}

const mapDispatchToProps = dispatch => ({
  onSubmit: ({email, password,password_confirmation}) => dispatch(SignUpRequest(email, password,password_confirmation))
})

const mapStateToProps = state =>({
  isSubmitting:state.auth.isSubmitting ,
  isSignUp:state.auth.isSignUp ,
  result:state.auth.result ,
})



export  default  connect(mapStateToProps,mapDispatchToProps)(SignUp)
