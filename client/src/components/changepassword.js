import React from 'react'
import {connect} from 'react-redux'
import {ChangePasswordRequest} from '../actions'
import { useForm} from 'react-hook-form'

const ChangePassword = ({isSubmitting,onSubmit,token,client,uid,error}) => {
  const { register, handleSubmit, formState: { errors }, watch, } = useForm()
  return(
  <div>
  <form  onSubmit={handleSubmit(onSubmit)}>
    <h1>ChangePassword</h1>
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
        current_password:
      </label>
      <input type="password" {...register(
        "current_password",
        { required: true })}  />
    </li>
    <li>
      <label htmlFor="password">
      password:
      </label>
      <input type="password" {...register(
        "password",
        { required: true })}  />
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
          {Object.keys(errors).length > 0 &&
            'There are errors, check your console.'}
            {error}
        </div>
  </div>
  )
}

const mapDispatchToProps = dispatch => ({
  onSubmit: ({token,client,uid, current_passwword,password,password_confirmation}) => 
                  dispatch(ChangePasswordRequest(token,client,uid,current_passwword, password,password_confirmation))
})

const mapStateToProps = state =>({
  isSubmitting:state.auth.isSubmitting ,
  token:state.auth.token, 
  client:state.auth.client, 
  uid:state.auth.uid, 
  error:state.auth.error ,
})

export  default  connect(mapStateToProps,mapDispatchToProps)(ChangePassword)
