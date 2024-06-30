//https://github.com/reactjs/react-tabs
//import axios from 'axios'
import React ,{useState,useMemo} from 'react'
import { connect } from 'react-redux'
import { Tab, Tabs, TabList, TabPanel, } from 'react-tabs'
import "react-tabs/style/react-tabs.css"
import {Button} from '../styles/button'
import "../index.css"

import  SignUp  from './signup'
import  Login  from './login'
import {ScreenInitRequest,changeShowScreen} from '../actions'
import ScreenGrid7 from './screengrid7'
import ButtonList from './buttonlist'

const titleNameSet = (screenName) =>{ return (
  document.title = `${screenName}`
)
}

const Menus7 = ({ isAuthenticated ,menuListData,getScreen, hostError,loadingOrg,loadingOrgSecond,
          toggleSubForm,toggleSubFormSecond,showScreen,changeShowScreen,screenNameSecond,
            isSignUp,screenFlg,auth}) =>{
    const [tabIndex, setTabIndex] = useState(0)
    const [subTabIndex, setSubTabIndex] = useState(0)
    const loading = useMemo(()=>loadingOrg,[loadingOrg])
    const loadingSecond = useMemo(()=>loadingOrgSecond,[loadingOrgSecond])
    //useEffect(()=>{   setLoading(loadingOrg)},[loadingOrg])
    if (isAuthenticated) {
      if(menuListData)
        {
        let tmpgrpscr =[]   //グルーブ化されたメニュー
        let ii = 0    
        let lastGrp_name = ""
        menuListData.map((cate,idx) => {
             if(lastGrp_name!==cate.grp_name){tmpgrpscr[ii]=cate.grp_name
                                                  lastGrp_name = cate.grp_name
                                                  ii += 1
           }})  
      
        //titleNameSet(tmpgrpscr[tabIndex])
        return (
          <div>
            <Tabs  selectedIndex={tabIndex}  onSelect={(changeTabIndex) => {setTabIndex(changeTabIndex)
                                                                            changeShowScreen(false) //別のメニューの残存を消去する。
                                                                            setSubTabIndex(-1)}}
                    selectedTabClassName="react-tabs--selected_custom_head">
              <TabList>
                { tmpgrpscr.map((val,idx) =>{ 
                                                            return( <Tab key={idx} >
                                                                      {val}
                                                                    </Tab>) }  
               )}
              </TabList>
                  {tmpgrpscr.map((val,idx) => 
                    <TabPanel  key={idx}> 
                    </TabPanel>)}
              </Tabs>
                <Tabs forceRenderTabPanel  selectedTabClassName="react-tabs--selected_custom_detail" 
                      selectedIndex={subTabIndex}  onSelect={(changeTabIndex) => {setSubTabIndex(changeTabIndex)
                                                                                
                                                                                   }}  >
                <TabList>
                  {menuListData.map((val,idx) => 
                    tmpgrpscr[tabIndex]===val.grp_name&&
                    <Tab key={idx} >
                      <Button   type="submit"
                      onClick ={() => { 
                                        titleNameSet(val.scr_name)   // cromeのtab表示
                                        getScreen(val.screen_code,val.scr_name,val.view_name,auth)
                                      }
                      }>
                      {val.scr_name}       
                      </Button>             
                    </Tab>)}
                </TabList>
                  {menuListData.map((val,idx) => 
                    tmpgrpscr[tabIndex]===val.grp_name&&
                    <TabPanel  key={idx}> 
                      {val.contents?val.contents:" "}
                    </TabPanel>)}
                </Tabs>
              {showScreen&&screenFlg=="first"&&<div> <ScreenGrid7 screenFlg = "first" /></div>}
              { 
                  //  第一画面  
               }  
              {showScreen&&!toggleSubForm&&<div> <ButtonList screenFlg = "first" /></div>}
              {loading && ( <div colSpan="10000">
            	              Loading...
          	              </div>)}
              {screenFlg==="first"&&hostError&& ( <div colSpan="10000">
                                  {hostError}
          	              </div>)}
              {  
                  //第二画 
              }
              {showScreen&&screenFlg==="second"&&<p> {screenNameSecond} </p>  }
              <div> {showScreen&&screenFlg==="second"?<ScreenGrid7 screenFlg = "second" />:""}</div>
              {showScreen&&screenFlg==="second"&&!toggleSubFormSecond&&<div> <ButtonList screenFlg = "second" /></div>}
              {loadingSecond && ( <div colSpan="10000">
            	              Loading.....
          	              </div>)}
              {screenFlg==="second"&&hostError&& ( <div colSpan="10000">
                                  {hostError}
          	              </div>)}
          </div>
        )
        }else{
          return(
            <div>
              <p> doing{hostError?hostError:""} </p>
            </div>)}
    }else{
      if(isSignUp){
        return (
          <SignUp/>
        )
      }else{  
        return (
          <div>
          <p> {hostError?hostError:""} </p>
          <Login/>
          </div>
        )
        }  
    }  
  }

const  mapStateToProps = (state,ownProps) =>({
  isSignUp:state.auth.isSignUp ,
  isAuthenticated:state.auth.isAuthenticated ,
  auth:state.auth ,
  showScreen:state.menu.showScreen,//screen bottunが押された時
  menuListData:state.menu.menuListData ,
  screenNameSecond:state.second.params.screenName,
  grid_columns_info:state.screen.grid_columns_info,
  hostError: state.menu.hostError,
  second_columns_info:state.screen.second_columns_info,
  screenFlg:state.menu.screenFlg,
  loadingOrg:state.screen.loading,
  loadingOrgSecond:state.second.loading,
  toggleSubForm:state.screen.toggleSubForm,
  toggleSubFormSecond:state.second.toggleSubForm,
})

const mapDispatchToProps = (dispatch,ownProps ) => ({
      getScreen : (screenCode, screenName,view_name, auth) =>{
        let params
        switch(screenCode){
        //   case "fmcustord_custinsts":
        //   case "fmcustinst_custdlvs":
        //     params = { screenName:  (screenName||""),disableFilters:false,
        //                 parse_linedata:{},aud:"view",
        //                 filtered:[],where_str:"",sortBy:[],screenFlg:"first",
        //                 screenCode:screenCode,pageIndex:0,pageSize:20,
        //                 index:-1,err:null,clickIndex:[],
        //                 buttonflg:"inlineedit7",viewName:view_name} 
        //     break
        // case "linechart_payalls":
        // case "linechart_billalls":
        //      params = { screenName:  (screenName||""),disableFilters:false,
        //                  parse_linedata:{},aud:"view",
        //                  filtered:[],where_str:"",sortBy:[],screenFlg:"first",
        //                  screenCode:screenCode,pageIndex:0,pageSize:20,
        //                  index:-1,err:null,clickIndex:[],
        //                  buttonflg:"linechart",viewName:view_name} 
        //      break
        default:
            params = { screenName:  (screenName||""),disableFilters:false,
                        parse_linedata:{},aud:"view",
                        filtered:[],where_str:"",
                        sortBy:[],groupBy:[],aggregated:[],
                        screenFlg:"first",screenCode:screenCode,pageIndex:0,pageSize:20,
                        index:-1,clickIndex:[],err:null,
                        buttonflg:"viewtablereq7",viewName:view_name} 
         }
        dispatch(ScreenInitRequest(params,auth))}   //data:null
        ,
      changeShowScreen:(showScreen)=>{dispatch(changeShowScreen(showScreen))}
          })    
export default connect(mapStateToProps,mapDispatchToProps)(Menus7)