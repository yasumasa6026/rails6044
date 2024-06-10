import React, { useEffect, useState, } from 'react'
import {connect} from 'react-redux'
import { useForm } from 'react-hook-form'
import {setClassFunc,setProtectFunc} from './functions7'
import { onBlurFunc7,onFieldValite ,fetchCheck} from './onblurfunc'
import { yupschema } from '../yupschema'
import { ScreenConfirm, FetchRequest, } from '../actions'
import { yupErrCheck } from './yuperrcheck'
import "../index.css"
import { TableGridStyles } from '../styles/tablegridstyles'
const ToSubForm  = ({params, data, subFormInfo,dropDownList,screenCode,index,
                    handleScreenRequest, handleFetchRequest,fetch_check}) => {
        //const {  handleSubmit,register, getValues} = useForm({resolver: yupResolver(yupschema), })
    const {  handleSubmit,register, getValues,setValue} = useForm()
        
    const [lineNo,setLineNo] =  useState(index<0?0:index)
    useEffect(()=>setLineNo((index) => index<0?0:index ))
    const [linedata,setLinedata] = useState(data[lineNo])
    useEffect(()=>{setLinedata(lineNo)
                    pageChange(lineNo)})
    const pageChange = ((cnt) =>{
        setLinedata(data[cnt])
        subFormInfo.map((sub)=>{
            sub.map((fld) =>
                {setValue(fld.id, data[cnt][fld.id])}
                    )
            })}
    )
    let errormsg
          
    const TdInput = ({linedata,fld,}) => {
            const ftypeValue = getValues("fieldcode_ftype") 
            const typeValue = getValues("screenfield_type")
            switch(true){   
                case /^Editable/.test(fld.className):
                            return(<input  {...register(fld.id , {onBlur: (e) => setFormFieldByonBlur(e,fld),value:linedata[fld.id] })}
                                    className={setClassFunc(fld.id,linedata,fld.className,params.buttonflg)}
                                    readOnly={ftypeValue?(setProtectFunc(fld.id,ftypeValue)):
                                                typeValue?(setProtectFunc(fld.id,typeValue)):false}
                                />)
                case /SelectEditable/.test(fld.className):
                           return(<select   {...register(fld.id,{value:linedata[fld.id]})}   > 
                                {typeof(dropDownList[fld.id])!=="undefined"&&JSON.parse(dropDownList[fld.id]).map((option, i) => (
                                    <option key={i+"op1"} value={option.value}>
                                            {option.label}
                                    </option>
                                ))}
                            </select>) 
                case /CheckEditable/.test(fld.className):
                            return(<input  type="checkbox"   {...register(fld.id,{value:linedata[fld.id]})}  />)
                case /^NonEditable/.test(fld.className):
                            return(<input    {...register(fld.id ,{value:linedata[fld.id]})}  readOnly style={{ visibility: fld.hideflg}} />)
                case /SelectNonEditable/.test(fld.className):
                            return(<select  value={linedata[fld.id]} disabled >
                                {
                                    typeof(dropDownList[fld.id])!=="undefined"&&JSON.parse(dropDownList[fld.id]).map((option, i) => (
                                        <option key={i+"op2"} value={option.value} >
                                                        {option.label} 
                                        </option>
                                ))
                                }
                            </select>)
                case /CheckNonEditable/.test(fld.className):
                            return(<input  value={linedata[fld.id]}  type="checkbox" readOnly />)
                default:
                            return(<input  value={linedata[fld.id]}  style={{ visibility: fld.hideflg}} readOnly />)
            }    
        }
      
        const setFormFieldByonBlur = (e,fld) => {
            let tmpline = {...linedata,[fld.id]: e.target.value}  //[id] idの内容
            let msg_id = `${linedata[fld.id]}_gridmessage`
            tmpline[`${linedata[fld.id]}_gridmessage`] = "ok"
            let autoAddFields = {}
            tmpline = onFieldValite(tmpline, fld.id, screenCode)  //clientでのチェック
            if(tmpline[msg_id]==="ok"){
                tmpline,autoAddFields = onBlurFunc7(screenCode, tmpline, linedata[fld.id])
            }
            if ( tmpline[msg_id] === "ok") {
                const {fetchCheckFlg,idKeys} = fetchCheck( tmpline,autoAddFields,fetch_check)
                params = {...params,fetchCode: JSON.stringify(idKeys),
                                        checkCode: JSON.stringify({ [fld.id]: fetch_check.checkCode[fld.id] }),
                                        linedata: JSON.stringify(newRow),
                                        fetchview: fetchCheckFlg==="fetch_request"?fetch_check.fetchCode[fld.id]:"",
                                        index: lineNo,buttonflg: fetchCheckFlg}
                
              if(fetchCheckFlg){handleFetchRequest(params)}
                     else{Object.keys(autoAddFields).map((field)=>{if(tmpline[field]===""||tmpline[field]===undefined)
                                                              { tmpline[field] =  autoAddFields[field]}
                                                            }
                                                  )
                        setLinedata({...tmpline}) }
            }else{return(errormsg=tmpline[msg_id])
            }
            data[lineNo] = {...linedata}
        }    
    
        const onFormValite = () => {
            let Yup = require('yup')
            let screenSchema = Yup.object().shape(yupschema[params.screenCode])
            let checkFields = {}
            Object.keys(screenSchema.fields).map((field) => {
                checkFields[field] = linedata[field] 
                return checkFields  //更新可能項目のみをセレクト
            })  
            checkFields = yupErrCheck(screenSchema,"confirm",checkFields)
            Object.keys(checkFields).map((field)=>linedata[field] = checkFields[field])
            if (linedata["confirm_gridmessage"] === "doing") {
                params = {...params,linedata: JSON.stringify(linedata),  index: lineNo ,
                         buttonflg: "confirm7" }
                data[lineNo] = {...linedata}
                handleScreenRequest(params,data)
            }
        }
        
        const buttonTitle = (params) =>{switch(params.aud){
                                            case 'edit': 
                                                    return("Edit Confirm")
                                            case 'add': 
                                                    return("Add Confirm")
                                            case 'delete': 
                                                    return("Delete Confirm")
                                            default: 
                                                    return("")
                                }
        }
        return(
        <div>
        <h3>{params.screenName}</h3>
        <form onSubmit={handleSubmit(()=>onFormValite())}>
            <button  type="button" onClick={() => {
                pageChange(lineNo - 1) //lineNoは使用できない。React の仕様で state は次のレンダリングされるタイミングまで反映しない
                setLineNo(lineNo - 1)
            }} disabled={lineNo=== 0 ? true : false}>
                {'<'}
            </button>
            <button  type="button" onClick={() => { 
                                            pageChange(lineNo+1)
                                            setLineNo(lineNo + 1)
                }} disabled={lineNo > (data.length - 2) ? true : false}>
                {'>'}
            </button>
            <TableGridStyles  >
            <table width="100%" border-spacing="1">
            <thead  className="subtablehead">
            <tr  className="subtablehead" >
               <p>{[...Array(30)].map((dummyLow,didx) =>(<th width="9%" key={didx+"th"} ></th> ))}</p>
            </tr>
            </thead>
            <tbody>
            {subFormInfo.map((sub,trid)=> {
                return(
                    <tr key={trid+"tr"}>
                        {sub.map((fld,idx) => {
                            return(
                                <React.Fragment>  
                                <td  key={idx+"td1"} className="subformtdlabel" style={{ visibility: fld.hideflg}} >{fld.label}</td>
                                <td rowSpan={fld.edoptrow}  key={idx+"td2"}>
                                    <TdInput linedata={linedata} fld={fld}  />  
                                </td>  
                                </React.Fragment> 
                            )
                        })}   
                    </tr>
                 )})
            }
            </tbody>
            </table>
            </TableGridStyles>
            {buttonTitle(params).length>1&&<button  >{buttonTitle(params)}</button>}<span>{" "}</span><span>{errormsg}</span>
        </form>
        </div>)
    }
    
    
const mapDispatchToProps = dispatch => ({

    handleFetchRequest: (params) => {
        dispatch(FetchRequest(params))
        },

    handleScreenRequest: (params,data) => {
        dispatch(ScreenConfirm(params,data))
      },
  })
  
  const mapStateToProps = state =>({
    data: state.screen.data,
    params:state.screen.params,
    index:state.screen.params.index,  //params.indexではuseEffectが効かない。
    screenCode: state.screen.params.screenCode,
    fetch_check: state.screen.grid_columns_info.fetch_check,
    dropDownList: state.screen.grid_columns_info.dropDownList, 
    subFormInfo: state.screen.grid_columns_info.subform_info,   
  })
  
  export default connect(mapStateToProps,mapDispatchToProps)(ToSubForm)
  