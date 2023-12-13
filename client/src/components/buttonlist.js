import React from 'react'
import { connect } from 'react-redux'
import { Tab, Tabs, TabList,TabPanel , } from 'react-tabs'
//import ScreenGrid7 from './screengrid7.js'
import ImportExcel from './importexcel.js'
import Download from './download'
import GanttTask from './gantttask'
//import ToSubForm from './tosubform'
import "react-tabs/style/react-tabs.css"
import {Button} from '../styles/button'
import "../index.css"
import {ScreenRequest,DownloadRequest,GanttChartRequest,ButtonFlgRequest,ScreenFailure,
        YupRequest,TblfieldRequest,ResetRequest, } from '../actions'

 const  ButtonList = ({auth,buttonListData,doButtonFlg,buttonflg,
                        screenCode,data,params,
                        pareScreenCode, screenFlg//  editableflg,message
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
                                      doButtonFlg(val[1],params,data,pareScreenCode,auth)} // buttonflg
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
        
        {(buttonflg==="ganttchart"||buttonflg==="reversechart")&&screenFlg===params.screenFlg&&<GanttTask /> }
        {buttonflg==='import'&&<ImportExcel/>}
        {buttonflg==="export"&&<Download/>}
        {buttonflg==="createTblViewScreen"&&params.messages.map((msg,index) =>{
                                                return  <p key ={index}>{msg}</p>
                                                  }
                                               )}
      
        </div>    
      )
    }

const  mapStateToProps = (state,ownProps) =>{
  if(ownProps.screenFlg==="second"){
    return{
      auth:state.auth,
      buttonListData:state.button.buttonListData ,    //ボタンはemailで一旦全て収集
      buttonflg:state.second.params.buttonflg ,  
      params:state.second.params ,  
      data:state.second.data ,  
      screenCode:state.second.params.screenCode ,  
      screenName:state.second.params.screenName ,  
      disabled:state.second.disabled?true:false,
      pareScreenCode:state.second.params.screenCode , 
      screenFlg:ownProps.screenFlg,
      }
    }else{
      return{
        auth:state.auth,
        buttonListData:state.button.buttonListData ,  
        buttonflg:state.screen.params.buttonflg ,  
        params:state.screen.params ,  
        data:state.screen.data ,  
        screenCode:state.screen.params.screenCode ,  
        screenName:state.screen.params.screenName ,  
        disabled:state.button.disabled?true:false,
        pareScreenCode:null ,   
        screenFlg:ownProps.screenFlg,
      }
    }
 // originalreq:state.screen.originalreq,map
}

const mapDispatchToProps = (dispatch,ownProps ) => ({
  doButtonFlg : (buttonflg,    //
                    params,data,pareScreenCode,auth) =>{
        dispatch(ButtonFlgRequest(buttonflg,params)) // import export 画面用
        let screenData = []
        let newRow = {}
        switch (buttonflg) {  //buttonflg ==button_code

          case "search":
                params= { ...params,buttonflg:"viewtablereq7",disableFilters:false,screenFlg:ownProps.screenFlg,aud:"view"}
                return dispatch(ScreenRequest(params,null)) //break
        
          case "inlineedit7":
                params= { ...params,buttonflg:"inlineedit7",disableFilters:false,screenFlg:ownProps.screenFlg,aud:"edit",}
                return dispatch(ScreenRequest(params,null)) //
                
          case "inlineadd7":
                params= {...params, pages:1,buttonflg:"inlineadd7",disableFilters:true,screenFlg:ownProps.screenFlg,aud:"add"}
                return  dispatch(ScreenRequest(params,null)) //

          case "showdetail":
                let clickcnt = 0
                params["clickIndex"].map((click)=>{if(click.id){clickcnt = clickcnt + 1
                                                                params["head"] = {lineId:click["lineId"],id:click["id"],pareScreenCode:click["screenCode"]}}
                                                  }
                                        )
                if(clickcnt === 1){
                      params= { ...params,buttonflg:"showdetail",disableFilters:false,screenFlg:"second",aud:"view"}
                      return dispatch(ScreenRequest(params,null))}
                  else{return dispatch(ScreenFailure({message:"no select or duplicated select"}))}
                  //break
      
          case "confirmAll"://
              params= {...params,buttonflg:"confirmAll",disableFilters:true,screenFlg:ownProps.screenFlg}
              return  dispatch(ScreenRequest(params,null)) //
 
          case "confirmShpacts"://第二画面専用
                    params= {...params,buttonflg:"confirmShpacts",disableFilters:true,screenFlg:ownProps.screenFlg}
                    return  dispatch(ScreenRequest(params,null)) //
    

          case "confirmShpinsts":  //第二画面専用
                  params= {...params,buttonflg:"confirmShpinsts",disableFilters:true,screenFlg:ownProps.screenFlg}
                  return  dispatch(ScreenRequest(params,null)) //

          case "ganttchart":
                  if(typeof(params.index)==="number"){
                      params= { ...params,linedata:data[params.index],viewMode:"Day",buttonflg:"ganttchart",screenFlg:ownProps.screenFlg}
                      return  dispatch(GanttChartRequest(params)) }//
                  else{alert("please select")}  
                  break

          case "reversechart":
                    if(typeof(params.index)==="number"){
                              params= { ...params,linedata:data[params.index],viewMode:"Day",buttonflg:"reversechart",}
                              return  dispatch(GanttChartRequest(params,auth)) }//
                    else{alert("please select")}  
                    
          case "MkPackingListNo"://
              params= {...params,buttonflg:"MkPackingListNo",disableFilters:true,screenFlg:ownProps.screenFlg}
              return  dispatch(ScreenRequest(params,null)) //

          case "MkInvoiceNo"://
              params= {...params,buttonflg:"MkInvoiceNo",disableFilters:true,screenFlg:ownProps.screenFlg}
              return  dispatch(ScreenRequest(params,null)) //
          
          case "export":
              params= {...params,buttonflg:"download7",disableFilters:false,screenFlg:ownProps.screenFlg}
              return  dispatch(DownloadRequest(params,auth)) //
         
          case "import":
              return  //画面表示のみ

          case "mkShpords":
              params= {...params,linedata:{},buttonflg:"mkShpords",disableFilters:false,screenFlg:ownProps.screenFlg}
              return  dispatch(ScreenRequest(params,null)) //

          case "reset":
                params= { ...params, buttonflg:"reset",disableFilters:false,screenFlg:ownProps.screenFlg,aud:"",}
                return dispatch(ResetRequest(params)) //

          case "refShpords": //第一画面で選択された親より第二画面表示
              params= {...params,buttonflg:"refShpords",disableFilters:true,screenFlg:"second",pareScreenCode:pareScreenCode}
              return  dispatch(ScreenRequest(params,null)) //   

          case "refShpinsts": //第一画面で選択された親より第二画面表示
                params= {...params,buttonflg:"refShpinsts",disableFilters:true,screenFlg:"second",pareScreenCode:pareScreenCode}
                return  dispatch(ScreenRequest(params,null)) //

          case "refShpacts":  //第一画面で選択された親より第二画面表示
                params= {...params,buttonflg:"refShpacts",disableFilters:true,screenFlg:"second",pareScreenCode:pareScreenCode}
                return  dispatch(ScreenRequest(params,null)) // 

          case "crt_tbl_view_screen":
                data.map((row,index)=>{Object.keys(row).map((field,idx)=>
                        {
                          if(/_code|_expiredate/.test(field)){newRow = {...newRow,[field]:row[field]}                                                            }
                        })
                        screenData[index] = newRow
                        newRow = {}})
                params= {...params,buttonflg:"createTblViewScreen",data:screenData,messages:[],screenFlg:ownProps.screenFlg}
                    return  dispatch(TblfieldRequest(params,auth)) //

          case "unique_index":
              data.map((row,index)=>{Object.keys(row).map((field,idx)=>
                          { if(/_code|_seqno|_grp|_expiredate/.test(field)){newRow = {...newRow,[field]:row[field]}                                                              }
                          })
                          screenData[index] = newRow
                          newRow = {}
                        })
              params= {...params,buttonflg:"createUniqueIndex",data:screenData,screenFlg:ownProps.screenFlg}
              return  dispatch(TblfieldRequest(params,auth)) 

          case "yup":
                params= { ...params,buttonflg:"yup",disableFilters:true,screenFlg:ownProps.screenFlg}
                return  dispatch(YupRequest(params,auth)) //
              
          default:
            console.log(`not Supported ${buttonflg}`)
            return 
        }   
      } 
  })    

export default connect(mapStateToProps,mapDispatchToProps)(ButtonList)