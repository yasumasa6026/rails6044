//https://github.com/reactjs/react-tabs
//import axios from 'axios'
import React from 'react'
import { connect } from 'react-redux'
import { Tab, Tabs, TabList, TabPanel, } from 'react-tabs'
import "react-tabs/style/react-tabs.css"
import {Button} from '../styles/button'
import "../index.css"

import  SignUp  from './signup'
import  Login  from './login'
import {ScreenInitRequest} from '../actions'
import ScreenGrid7 from './screengrid7'

const titleNameSet = (screenName) =>{ return (
  document.title = `${screenName}`
)
}

const Menus7 = ({ isAuthenticated ,menuListData,getScreen, params,grid_columns_info,hostError,
            isSignUp,menuChanging,uid,token,client}) =>{
    if(params){}else{params = {}}
    params["token"] = token
    params["client"] = client
    params["uid"] = uid
    if (isAuthenticated) {
      if(menuListData)
      {
      let tmpgrpscr =[]   //グルーブ化されたメニュー
      let ii = 0
      menuListData.map((cate) => {
            if(tmpgrpscr[ii-1]!==cate.grp_name){tmpgrpscr[ii]=cate.grp_name;ii=ii+1}    
          return tmpgrpscr
          })  
      return (
        <div>
            <Tabs
                  forceRenderTabPanel   selectedTabClassName="react-tabs--selected_custom_head">
              <TabList>
                { tmpgrpscr.map((grp_name,idx) => 
                  <Tab key={idx} >
                    {grp_name} 
                  </Tab>
                )
                } 
              </TabList>
              {tmpgrpscr.map((grp_name,idx) => 
                <TabPanel key={idx}  >
                <Tabs forceRenderTabPanel  selectedTabClassName="react-tabs--selected_custom_detail">
                <TabList>
                  {menuListData.map((val,index) => 
                    grp_name===val.grp_name&&
                    <Tab key={index} >
                      <Button   type="submit"
                      onClick ={() => {
                                        getScreen(val.screen_code,val.scr_name,val.view_name,params)
                                      }
                      }>
                      {val.scr_name}       
                      </Button>             
                    </Tab>)}
                </TabList>
                  {menuListData.map((val,index) => 
                    grp_name===val.grp_name&&
                    <TabPanel  key={index}> 
                      {val.contents?val.contents:" "}
                    </TabPanel>)}
                </Tabs>
                </TabPanel> 
              )}
            </Tabs>
              {(grid_columns_info&&menuChanging===false)&&<div> <ScreenGrid7 second={false} /></div>}
              {/*(grid_columns_info&&menuChanging===false)&&<div> <ButtonList second={false} /></div>*/}
              <p> {hostError?hostError:""} </p>
           </div>    
      )
    }else{
     return(
     <div>
      <p> {hostError?hostError:""} </p>
    </div>)}
    }else{
      if(isSignUp){
        return (
          <SignUp/>
        )
      }else{  
        return (
          <Login/>
        )
        }  
    }  
  }

const  mapStateToProps = (state,ownProps) =>({
  isSignUp:state.auth.isSignUp ,
  isAuthenticated:state.auth.isAuthenticated ,
  menuListData:state.menu.menuListData ,
  params:state.screen.params,
  message:state.menu.message,
  grid_columns_info:state.screen.grid_columns_info,
  screenCode:state.screen.params?state.screen.params.screenCode:"",
  hostError: state.screen.hostError,
  menuChanging:state.menu.menuChanging,
  uid:state.auth.uid ,
  token:state.auth.token ,
  client:state.auth.client ,
})

const mapDispatchToProps = (dispatch,ownProps ) => ({
      getScreen : (screenCode, screenName,view_name, params) =>{
        titleNameSet(screenName)
        params= { ...params,screenName:  (screenName||""),disableFilters:false,
                          filtered:[],where_str:"",sortBy:[],
                         screenCode:screenCode,pageIndex:0,pageSize:20,
                         req:"viewtablereq7",viewName:view_name} 
        dispatch(ScreenInitRequest(params,null))}   //data:null
          })    
export default connect(mapStateToProps,mapDispatchToProps)(Menus7)