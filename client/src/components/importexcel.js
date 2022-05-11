import React from 'react'
import { connect } from 'react-redux'
import {ImportExcelRequest, LOGIN_REQUEST} from '../actions'

const ImportExcel = ({exceltojson,excelfile,importError,formatError,errHeader,importErrorCheckMaster,errMessage,normalEnd,
                      nameToCode,params,idx}) =>{
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
                                              {exceltojson(excelfile,nameToCode,params)}  //.xlsx  は　controllers/api/uploadでも使用
                                            else{alert("please input Excel File or Csv File")
                                            }
                                          }
                                      }
                                }
               />  </label>

    </div>
    <div>
          {formatError===true&&<p>error please check  file format</p>} 
          {importErrorCheckMaster===true&&<p> error  </p> }
          {importError===true&&<p> some records have errors (skip commit all data(rollback done))  </p>}
          {normalEnd===true&&<p>  Add or Update records {idx} </p>}  
          {errHeader&&errHeader.map((err) => {if(err){return <p> Error:{err}  </p>}})}         
     </div>
           {errMessage}
     </React.Fragment>  
    )
  }

const mapDispatchToProps = dispatch => ({
  exceltojson :(excelfile,nameToCode,params)=>{
    dispatch(ImportExcelRequest({excelfile,nameToCode,params}))
    },  
  })
  
const mapStateToProps = state =>({
    excelfile:state.upload.excelfile?state.upload.excelfile:{name:""},
    message:state.upload.message,
    nameToCode:state.screen.grid_columns_info.nameToCode,
    params:state.screen.params,
    results:state.upload.results,
    importError:state.upload.importError,
    formatError:state.upload.formatError,
    errHeader:state.upload.errHeader,
    idx:state.upload.idx,
    importErrorCheckMaster:state.upload.importErrorCheckMaster,
    errMessage:state.upload.errMessage,
    normalEnd:state.upload.normalEnd,
  })

export default  connect(mapStateToProps,mapDispatchToProps)(ImportExcel)
