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
        YupRequest,TblfieldRequest,ResetRequest, 
        ConfirmAllRequest, } from '../actions'

 const  ButtonList = ({buttonListData,setButtonFlg,buttonflg,
                        screenCode,data,params,downloadloading,
                        pareScreenCode,message,messages, //  editableflg,message
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
                      type={val[1]==='inlineedit7'||'inlineadd7'||'yup'||'ganttchart'||'import'?"submit":"button"}
                      onClick ={() =>{
                                      setButtonFlg(val[1],params,data,pareScreenCode)} // buttonflg
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
        
        {buttonflg==="ganttchart"&&<GanttChart />}
        {buttonflg==='import'&&<ImportExcel/>}
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
  if(ownProps.screenFlg==="second"){
    return{
      buttonListData:state.button.buttonListData ,    //ボタンはemailで一旦全て収集
      buttonflg:state.second.buttonflg ,  
      params:state.second.params ,  
      data:state.second.data ,  
      screenCode:state.second.params.screenCode ,  
      screenName:state.second.params.screenName ,  
      uid:state.auth.uid,
      message:state.button.message,
      messages:state.button.messages,
      disabled:state.second.disabled?true:false,
      pareScreenCode:state.second.params.screenCode ,  
      loading:state.second.loading,
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
        pareScreenCode:state.screen.params.screenCode ,  
        loading:state.screen.loading,  
      }
    }
 // originalreq:state.screen.originalreq,
}

const mapDispatchToProps = (dispatch,ownProps ) => ({
  setButtonFlg : (buttonflg,    //editableflg,screenCode,uid,screenName,search
                    params,data,pareScreenCode) =>{
        dispatch(ButtonFlgRequest(buttonflg,params)) // import export 画面用
        let screenData = []
        let newRow = {}
        let linedata = {}
        switch (buttonflg) {  //buttonflg ==button_code
          case "reset":
            params= { ...params, req:"reset",disableFilters:false,screenFlg:ownProps.screenFlg}
            return dispatch(ResetRequest(params)) //

          case "search":
              params= { ...params,req:"viewtablereq7",disableFilters:false,screenFlg:ownProps.screenFlg}
              return dispatch(ScreenRequest(params,null)) //data=null　再度もとめ直し
        
          case "inlineedit7":
              params= { ...params,req:"inlineedit7",disableFilters:false,screenFlg:ownProps.screenFlg,}
              return dispatch(ScreenRequest(params,null)) //data=null　再度もとめ直し
          
          case "inlineadd7":
              params= {...params, pages:1,req:"inlineadd7",disableFilters:true,screenFlg:ownProps.screenFlg}
              return  dispatch(ScreenRequest(params,null)) //data=null　空白を表示
          
          case "export":
              params= {...params,req:"download7",disableFilters:false,screenFlg:ownProps.screenFlg}
              return  dispatch(DownloadRequest(params)) //
         
          case "import":
              return  //画面表示のみ

          case "mkShpords":
              params= {...params,req:"mkShpords",disableFilters:false,screenFlg:ownProps.screenFlg}
              params.linedata = {}    
              return  dispatch(ScreenRequest(params,null)) //

          case "refShpords": //第一画面で選択された親より第二画面表示
              //linedata = data.map((line) => {return {tblid : line["id"],}})
              params= {...params,req:"refShpords",disableFilters:true,screenFlg:ownProps.screenFlg}
              return  dispatch(ScreenRequest(params,null)) //   

          case "confirmShpinsts":  //第二画面専用
              //linedata = data.map((line) => {return {tblid : line["id"],shpord_qty:line["shpord_qty"],}})
              params= {...params,req:"confirmShpinsts",disableFilters:true,screenFlg:ownProps.screenFlg}
              return  dispatch(ScreenRequest(params,null)) //

          case "refShpinsts": //第一画面で選択された親より第二画面表示
                //linedata = data.map((line) => {return {tblid : line["id"],}})
                params= {...params,req:"refShpinsts",disableFilters:true,screenFlg:ownProps.screenFlg}
                return  dispatch(ScreenRequest(params,null)) //
 
          case "confirmShpacts"://第二画面専用
                // linedata = data.map((line) => {return {tblid : line["id"],shpinst_qty_stk:line["shpinst_qty_stk"],}})
                params= {...params,req:"confirmShpacts",disableFilters:true,screenFlg:ownProps.screenFlg}
                return  dispatch(ScreenRequest(params,null)) //

          case "refShpacts":  //第一画面で選択された親より第二画面表示
                // linedata = data.map((line) => {return {tblid : line["id"],}})
                params= {...params,req:"refShpinsts",disableFilters:true,screenFlg:ownProps.screenFlg}
                return  dispatch(ScreenRequest(params,null)) //
               
          case "yup":
                params= { ...params,req:"yup",disableFilters:true,screenFlg:ownProps.screenFlg}
                return  dispatch(YupRequest(params)) //

          case "ganttchart":
              if(params["clickIndex"]){
                  params= { ...params,req:"ganttchart"}
                  return  dispatch(GanttChartRequest(params)) }//
              else{dispatch(GanttReset())}  
              break

          case "crt_tbl_view_screen":
                data.map((row,index)=>{Object.keys(row).map((field,idx)=>
                        {
                          if(/_code|_expiredate/.test(field)){newRow = {...newRow,[field]:row[field]}                                                            }
                        })
                        screenData[index] = newRow
                        newRow = {}})
            params= {...params,req:"createTblViewScreen",data:screenData,screenFlg:ownProps.screenFlg}
              return  dispatch(TblfieldRequest(params)) //

          case "unique_index":
              data.map((row,index)=>{Object.keys(row).map((field,idx)=>
                          { if(/_code|_seqno|_grp|_expiredate/.test(field)){newRow = {...newRow,[field]:row[field]}                                                              }
                          })
                          screenData[index] = newRow
                          newRow = {}
                        })
              params= {...params,req:"createUniqueIndex",data:screenData,screenFlg:ownProps.screenFlg}
              return  dispatch(TblfieldRequest(params)) 
          default:
            console.log(`not Supported ${buttonflg}`)
            return 
        }   
      } 
  })    

export default connect(mapStateToProps,mapDispatchToProps)(ButtonList)