import React from 'react'
import { connect } from 'react-redux'
import {UploadExcelRequest,} from '../actions'

const UploadExcel = ({exceltojson,excelfile,uploadError,formatError,errHeader,uploadErrorCheckMaster,errMessage,normalEnd,
                      nameToCode,params,idx,auth}) =>{
  return (   
    <React.Fragment>
          <div className="has-text-right buttons-padding">
              <label htmlFor='inputExcel'> 
              <input
                      type="file" id="inputExcel" 
                      accept="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                      /* disabled={!ready} */
                      placeholder="Excel File or Csv File"
                      onChange={ev =>{if( ev.currentTarget.files[0])
                                          {excelfile =  ev.currentTarget.files[0]
                                            let excelfilename =  excelfile.name
                                            if(excelfilename.search(/\.xlsx$|\.csv$/))
                                              {exceltojson(excelfile,nameToCode,params,auth)}  //.xlsx  は　controllers/api/uploadでも使用
                                            else{alert("please input Excel File or Csv File")
                                            }
                                          }
                                      }
                                }
               />  </label>

    </div>
    <div>
          {formatError===true&&<p>error please check  file format</p>} 
          {uploadErrorCheckMaster===true&&<p> error  </p> }
          {uploadError===true&&<p> some records have errors (skiped  all data(rollback done))  </p>}
          {normalEnd===true&&<p>  Add or Update records {idx} </p>}  
          {errHeader&&errHeader.map((err) => {if(err){return <p> Error:{err}  </p>}})}         
     </div>
           {errMessage}
     </React.Fragment>  
    )
  }

const mapDispatchToProps = dispatch => ({
  exceltojson :(excelfile,nameToCode,params,auth)=>{
    dispatch(UploadExcelRequest({excelfile,nameToCode,params,auth}))
    },  
  })
  
const mapStateToProps = state =>({
    excelfile:state.upload.excelfile?state.upload.excelfile:{name:""},
    message:state.upload.message,
    nameToCode:state.screen.grid_columns_info.nameToCode,
    params:state.screen.params,
    results:state.upload.results,
    uploadError:state.upload.uploadError,
    formatError:state.upload.formatError,
    errHeader:state.upload.errHeader,
    idx:state.upload.idx,
    uploadErrorCheckMaster:state.upload.uploadErrorCheckMaster,
    errMessage:state.upload.errMessage,
    normalEnd:state.upload.normalEnd,
    auth:state.auth,
  })

export default  connect(mapStateToProps,mapDispatchToProps)(UploadExcel)
