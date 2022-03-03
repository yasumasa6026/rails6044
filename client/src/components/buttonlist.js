import React from 'react'
import { connect } from 'react-redux'
import { Tab, Tabs, TabList,TabPanel , } from 'react-tabs'
import ScreenGrid7 from './screengrid7.js'
import ImportExcel from './importexcel.js'
import Download from './download'
import GanttChart from './ganttchart'
import "react-tabs/style/react-tabs.css"
import {Button} from '../styles/button'
import "../index.css"
import {ScreenRequest,DownloadRequest,GanttChartRequest,GanttReset,
        //ScreenInitRequest,
        ButtonFlgRequest,
        YupRequest,TblfieldRequest,ResetRequest, //MkShpinstsResult,
        ConfirmAllRequest, } from '../actions'

 const  ButtonList = ({buttonListData,setButtonFlg,buttonflg,
                        screenCode,data,params,downloadloading,
                        second_columns_info,pareScreenCode,
                        message,messages //  editableflg,message
                      }) =>{
      let tmpbuttonlist = {}
      if(buttonListData){
         buttonListData.map((cate) => {
            if(tmpbuttonlist[cate.screen_code]){tmpbuttonlist[cate.screen_code].push([cate.button_title,cate.button_code])}
            else{tmpbuttonlist[cate.screen_code]=[]
                 tmpbuttonlist[cate.screen_code].push([cate.button_title,cate.button_code])}   
             return tmpbuttonlist
          })  
        } 
      return (
        <div>
        {tmpbuttonlist[screenCode]&&   //画面のボタンが用意されてないときはskip
            <Tabs   forceRenderTabPanel defaultIndex={0}  selectedTabClassName="react-tabs--selected_custom_footer">
                <TabList>
                  {tmpbuttonlist[screenCode].map((val,index) => 
                    <Tab key={index} >
                      <Button  
                      type={val[1]==='inlineedit7'||'inlineadd7'||'yup'||'ganttchart'?"submit":"button"}
                      onClick ={() =>{
                                      setButtonFlg(val[1],params,data,second_columns_info,pareScreenCode)} // buttonflg
                                     }>
                      {val[0]}       
                      </Button>             
                    </Tab>
                    )} 
                </TabList>
                  {tmpbuttonlist[screenCode].map((val,index) => 
                     <TabPanel key={index} >
                      {val[2]}
                    </TabPanel>
                    )} 
            </Tabs>
        }
        
        {buttonflg==="ganttchart"&&<GanttChart second={false} />}
        {buttonflg==='import'&&<ImportExcel/>}
        {(buttonflg==='mkshpacts'||buttonflg==='refshpacts')&&second_columns_info&&
                                  <div><ScreenGrid7 second={true} /></div> }
        {buttonflg==="export"&&downloadloading==="done"?<Download/>:downloadloading==="doing"?<p>please wait </p>:""}
        {buttonflg==="createTblViewScreen"&&params.messages.map((msg,index) =>{
                                                return  <p key ={index}>{msg}</p>
                                                  }
                                               )}
        <p>{message}</p>
        {messages&&messages.map((val,index) => 
                     <p key={index} > {val}</p>
                    )}
        <React.Fragment> </React.Fragment>
        </div>    
      )
    }

const  mapStateToProps = (state,ownProps) =>{
  if(ownProps.second===true){
    return{
      buttonListData:state.button.buttonListData ,  
      buttonflg:state.second.buttonflg ,  
      params:state.second.params ,  
      data:state.second.data ,  
      screenCode:state.second.params.screenCode ,  
      screenName:state.second.params.screenName ,  
      uid:state.auth.uid,
      message:state.second.message,
      messages:state.second.messages,
      disabled:state.second.disabled?true:false,
      second_columns_info:state.second.grid_columns_info.columns_info,
      pareScreenCode:state.screen.params.screenCode ,  
      }
    }else{
      return{
        buttonListData:state.button.buttonListData ,  
        buttonflg:state.button.buttonflg ,  
        params:state.screen.params ,  
        data:state.screen.data ,  
        screenCode:state.screen.params.screenCode ,  
        screenName:state.screen.params.screenName ,  
        uid:state.auth.uid,
        message:state.button.message,
        messages:state.button.messages,
        downloadloading:state.download.downloadloading,
        disabled:state.button.disabled?true:false,
        second_columns_info:[],
        pareScreenCode:state.screen.params.screenCode ,  
      }
    }
 // originalreq:state.screen.originalreq,
}

const mapDispatchToProps = (dispatch,ownProps ) => ({
  setButtonFlg : (buttonflg,    //editableflg,screenCode,uid,screenName,search
                    params,data,second_columns_info,pareScreenCode) =>{
        dispatch(ButtonFlgRequest(buttonflg,params)) // import export 画面用
        switch (buttonflg) {  //buttonflg ==button_code
          case "reset":
            params= { ...params, req:"reset",disableFilters:false}
            return dispatch(ResetRequest(params)) //

          case "search":
              params= { ...params,req:"viewtablereq7",disableFilters:false}
              return dispatch(ScreenRequest(params,null)) //data=null　再度もとめ直し
        
          case "inlineedit7":
              params= { ...params,req:"inlineedit7",disableFilters:false}
              return dispatch(ScreenRequest(params,null)) //data=null　再度もとめ直し
          
          case "inlineadd7":
              params= {...params, pages:1,req:"inlineadd7",disableFilters:true}
              return  dispatch(ScreenRequest(params,null)) //data=null　空白を表示
          
          case "export":
              params= {...params,req:"download7",disableFilters:false}
              return  dispatch(DownloadRequest(params)) //
         
          case "import":
              return   //画面表示のみ

          case "mkshpinsts":
              params= {...params,req:"mkshpinsts",disableFilters:false}
              params.linedata = {}    
              return  dispatch(ScreenRequest(params,data)) //

          case "mkshpacts":
              params= {...params,req:"mkshpacts",pareScreenCode:pareScreenCode,disableFilters:false}
              params.linedata = {}    
              return  dispatch(ScreenRequest(params,data)) //

          case "confirm_all":
              params= {...params,req:"confirm_all",disableFilters:true}
              params.linedata = {}   
              let editcolums = second_columns_info.map((column,indx)=>{
                if(/edit/.test(column["className"])){
                   return column["accessor"]
                }else{return null}
              })
              let confirm_data = data.map((line,indx)=>{
                let editdata = {}
                editcolums.map((col,i)=>{
                  editdata[col] = line[col] 
                  return null
                })
                editdata["id"] = line["id"]
                return editdata
              })
              params.confirm_data = JSON.stringify(confirm_data)   
              return  dispatch(ConfirmAllRequest(params,data)) //

          case "refshpacts":
              params= {...params,req:"refshpacts",pareScreenCode:pareScreenCode,disableFilters:false}
              params.linedata = {}    
              return  dispatch(ScreenRequest(params,data)) //
    
               
          case "yup":
              params= { ...params,req:"yup",disableFilters:true}
              return  dispatch(YupRequest(params)) //

          case "ganttchart":
              if(params["clickIndex"]){
                 params= { ...params,req:"ganttchart"}
                return  dispatch(GanttChartRequest(params)) }//
              else{dispatch(GanttReset())}  
              break

          case "crt_tbl_view_screen":
              params = {...params,req:"createTblViewScreen",data:data}
              return  dispatch(TblfieldRequest(params)) //

          case "unique_index":
              params= {...params,req:"createUniqueIndex",data:data}
              return  dispatch(TblfieldRequest(params)) 
          default:
            return 
        }   
      } 
  })    

export default connect(mapStateToProps,mapDispatchToProps)(ButtonList)