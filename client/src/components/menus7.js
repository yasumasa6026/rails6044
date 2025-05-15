//https://github.com/reactjs/react-tabs
//import axios from 'axios'
import React ,{useState,useMemo} from 'react'
import { connect } from 'react-redux'
import { Tab, Tabs, TabList, TabPanel, } from 'react-tabs'
import "react-tabs/style/react-tabs.css"
import {Button} from '../styles/button'
import "../index.css"

import  Login  from './login'
import {ScreenInitRequest,} from '../actions'
import ScreenGrid7 from './screengrid7'
import ButtonList from './buttonlist'

const titleNameSet = (screenName) =>{ return (
  document.title = `${screenName}`
)
}

const Menus7 = ({ isAuthenticated ,menuListData,getScreen,loadingOrg,loadingOrgSecond,
          toggleSubForm,toggleSubFormSecond,screenNameSecond,
          hostError,message,firstView,secondView,auth}) =>{
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
                                                                             //別のメニューの残存を消去する。
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
              {firstView&&<div> <ScreenGrid7 screenFlg = "first" /></div>}
              { 
                  //  第一画面  
               }  
              {!toggleSubForm&&<div> <ButtonList screenFlg = "first" /></div>}
              {firstView&&loading && ( <div colSpan="10000">
            	              Loading...
          	              </div>)}
              {firstView&&message&& ( <div colSpan="10000">
                                  {message}
          	              </div>)}
              {hostError&& ( <div colSpan="10000">
                                  {hostError}
          	              </div>)}
              {  
                  //第二画 
              }
              {secondView&&<p> {screenNameSecond} </p>  }
              <div> {secondView?<ScreenGrid7 screenFlg = "second" />:""}</div>
              {secondView&&!toggleSubFormSecond&&<div> <ButtonList screenFlg = "second" /></div>}
              {loadingSecond && ( <div colSpan="10000">
            	              Loading.....
          	              </div>)}
              {secondView&&message&& ( <div colSpan="10000">
                                  {message}
                                  </div>)}
              {hostError&& ( <div colSpan="10000">
                                  {hostError}
          	              </div>)}
          </div>
        )
        }else{
          return(
            <div>
              {loading?<p> doing{hostError?hostError:""} </p>:<p> please logout because no data </p>}
            </div>)}
    }else{
      return (
        <div>
        <p> {hostError?hostError:""} </p>
        <Login/>
        </div>
      )
    }  
  }

const  mapStateToProps = (state,ownProps) =>({
  isAuthenticated:state.auth.isAuthenticated ,
  auth:state.auth ,
  menuListData:state.menu.menuListData ,
  screenNameSecond:state.second.params.screenName,
  grid_columns_info:state.screen.grid_columns_info,
  second_columns_info:state.screen.second_columns_info,
  screenFlg:state.menu.screenFlg,
  firstView:state.menu.firstView,
  secondView:state.menu.secondView,
  loadingOrg:state.screen.loading,
  loadingOrgSecond:state.second.loading,
  toggleSubForm:state.screen.toggleSubForm,
  toggleSubFormSecond:state.second.toggleSubForm,
  hostError: state.menu.hostError,
  message: state.menu.message,
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
          })    
export default connect(mapStateToProps,mapDispatchToProps)(Menus7)