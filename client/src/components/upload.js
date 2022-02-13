import React from 'react'
import { connect } from 'react-redux'
import {ExcelCsvImportRequest} from '../actions'

const Upload = ({message,exceltojson,results,excelfile,complete,importError,nameToCode,screenCode}) =>{
  return (   
    <React.Fragment>
          <div className="has-text-right buttons-padding">
              <label htmlFor='inputExcel'> 登録・変更用 EXCELをJSONに変更
              <input
                      type="file" id="inputExcel" 
                      /* disabled={!ready} */
                      placeholder="Excel File or Csv File"
                      onChange={ev =>{if( ev.currentTarget.files[0])
                                          {excelfile =  ev.currentTarget.files[0]
                                            let excelfilename =  excelfile.name
                                            if(excelfilename.search(/\.xlsx$|\.csv$/))
                                              {exceltojson(excelfile,nameToCode,screenCode)}  //.xlsx  は　controllers/api/uploadでも使用
                                            else{alert("please input Excel File or Csv File")
                                            }
                                          }
                                      }
                                }
               />  </label>

          {results&&complete===true&&importError===true?
            <p>error please check  file </p>
          :results&&complete===true&&importError===false&&  <p>completed </p>
          }   
    </div>
          {message}
     </React.Fragment>  
    )
  }

const mapDispatchToProps = dispatch => ({
  exceltojson :(excelfile,nameToCode,screenCode)=>{
    dispatch(ExcelCsvImportRequest({excelfile,nameToCode,screenCode}))
    },  
  })
  
const mapStateToProps = state =>({
    excelfile:state.upload.excelfile?state.upload.excelfile:{name:""},
    message:state.upload.message,
    errors:state.menu.message,
    yup:state.screen.yup,
    nameToCode:state.screen.grid_columns_info.nameToCode,
    screenCode:state.screen.params.screenCode,
    results:state.upload.results,
    complete:state.upload.complete,
    importError:state.upload.importError,
  })

export default  connect(mapStateToProps,mapDispatchToProps)(Upload)
