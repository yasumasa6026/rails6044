//
//  typeof(xxx)==="undefined"の対応要
//
import React, { useState, useMemo, useEffect, } from 'react'
import { connect } from 'react-redux'
import { ScreenRequest, FetchRequest,ScreenParamsSet,SecondParamsSet,
            SecondRequest, SecondFetchRequest,  } from '../actions'
//import DropDown from './dropdown'
import { yupschema } from '../yupschema'
import Tooltip from 'react-tooltip-lite'
import { onBlurFunc7 } from './onblurfunc'
import { yupErrCheck } from './yuperrcheck'
import ButtonList from './buttonlist'
import {useTable, useRowSelect, useFilters, useSortBy, useResizeColumns, useBlockLayout,
        useExpanded,
        //useTokenPagination,  //usePagination,
        } from 'react-table'
//  useTokenPagination   ---> undefined pluginが発生
// Some server-side pagination implementations do not use page index
// and instead use token based pagination! If that's the case,
// please use the useTokenPagination plugin instead
import { TableGridStyles } from '../styles/tablegridstyles'
import "../index.css"
import {setClassFunc,setProtectFunc,} from './functions7'

const cellFontSize = (column,para) =>{
  let length
  let width
  let fontSize
  switch(para){
    case 'Header':
      width = column.width
      length = column.Header.length
      if(typeof(column.Header)==="string"){
                length = column.Header.match(/^[0-9a-zA-Z\-_:\s.]*$/)?length*1:length*1.8}
      else{length = 1}
      break
    default:
      width = column.column.width
      if(typeof(column.value)==="string"){
              length = column.value.length
              length = column.value.match(/^[0-9a-zA-Z\-_:\s.@#;()%]*$/)?length*1:length*1.5}
      else{length = 1}
  }
  let checkFontSize = Math.ceil( width / length ) 
  if(checkFontSize>10){fontSize = 15}
      else{fontSize = Math.ceil( width / length * 1.5) }
 return `${fontSize}px`
 //return '100%'
}

const AutoCell = ({
    value: initialValue,
    row: { index,values },
    column: { id, className },  //id field_code
    setData, data, // This is a custom function that we supplied to our table instance
    setChangeData,changeData,
    row,params, updateParams,dropDownList,fetch_check,
    buttonflg,loading,  //useTableへの登録が必要
    handleScreenRequest,handleFetchRequest,
    }) => {
        // const [newClassName, setNewClassName] = useState(className)
        //const [newReadOnly, setNewReadOnly] = useState(false)
        const setFieldsByonChange = (e) => {
            if(e.target){
                 values[id] =  e.target.value
                 updateMyData(index, id, values[id] ) //dataの内容が更新されない。但しとると、画面に入力内容が表示されない。
                 updateChangeData(index,id,values[id])
               }   
        } 
        // const setFieldsByonFocus = (e) => {//
        //     if(e.target){
        //         if(e.target.value===null||e.target.value===""||e.target.value===undefined){
        //            //initialValue = setInitailValueForAddFunc(id,row,・・・　画面表示されない。
        //            values[id] = setInitailValueForAddFunc(id,row,params.screenCode)
        //            if(values[id]!==""){ updateMyData(index, id,  values[id])
        //            }
        //          }
        //          //e.target.value||undefinedにすると日付チェックの時splitでエラーが発生
        //     }  
        // }
  
        const setFieldsByonBlur = (e) => {
            let linedata = {...data[index],[id]: e.target.value}  //[id] idの内容
            let msg_id = `${id}_gridmessage`
            linedata[`${id}_gridmessage`] = "ok"
            let autoAddFields = {}
            linedata = onFieldValite(linedata, id, params.screenCode)  //clientでのチェック
            if(linedata[msg_id]==="ok"){
                updateMyData(index, id,linedata[id])
                updateMyData(index, msg_id,linedata[msg_id])
                linedata,autoAddFields = onBlurFunc7(params.screenCode, linedata, id)
            }
            //updateLineData(index,linedata)  //dataの更新
            if ( linedata[msg_id] === "ok") {
                fetchCheck( linedata,autoAddFields)
            }else{
              updateMyData(index, msg_id, " error " + linedata[msg_id])
            }
        }    
  
        const onFieldValite = (linedata, field, screenCode) =>{  // yupでは　2019/12/32等がエラーにならない
            let schema = fieldSchema(field, screenCode)
            linedata = yupErrCheck(schema,field,linedata)
            return linedata
        }

        const onLineValite = (linedata,index,data,params) => {
            let screenSchema = Yup.object().shape(yupschema[params.screenCode])
            let checkFields = {}
            Object.keys(screenSchema.fields).map((field) => {
                checkFields[field] = linedata[field] 
                return checkFields  //更新可能項目のみをセレクト
            })  
            checkFields = yupErrCheck(screenSchema,"confirm",checkFields)
            Object.keys(checkFields).map((field)=>linedata[field] = checkFields[field])
            if (linedata["confirm_gridmessage"] === "doing") {
                updateParams([{ linedata: JSON.stringify(linedata)}, { index: index },
                        { buttonflg: "confirm7" }])
                handleScreenRequest(params,data)
            }else{
                let msg_id = "confirm_gridmessage"
                updateMyData(index, msg_id, " error " + linedata[msg_id])
                msg_id = `${linedata["errPath"]}_gridmessage`
                updateMyData(index, msg_id, " error " + linedata[msg_id])
                setClassFunc(linedata["errPath"],row,className,buttonflg)
                updateMyData(index, "confirm", false)
            }
        }   

        const updateMyData = (rowIndex, columnId, value) => {
            setData(old=>
              old.map((row, index) => {
                if (index === rowIndex) {
                    row =  {
                      ...old[rowIndex],
                    [columnId]: value,
                    }
                }
              return row
              })
            )
        }

        
        const updateChangeData = (rowIndex, columnId, value) => {
          setChangeData(old=>
            old.map((row, index) => {
              if (index === rowIndex) {
                  row =  {
                    ...old[rowIndex],
                  [columnId]: value,
                  }
              }
            return row
            })
          )
      }

        const updateLineData = (index, data,autoAddFields) => {
          Object.keys(autoAddFields).map((field)=>{if(data[field]===""||data[field]===undefined)
                                                { updateMyData(index, field, autoAddFields[field])}
                                              }
                                    )
        }
        
         //serverデータとのチェック又はserverデータの検索
        const fetchCheck = (linedata,autoAddFields) => {
          switch (true) {
          case /confirm$/.test(id):
            break
          default:
             let fetchCheckFlg = false
             //
             if(fetch_check.fetchCode[id]){
                 let idKeys=[]
                 let flg = true
                 Object.keys(fetch_check.fetchCode).map((key,idx)=>{  //複数key対応
                     if(fetch_check.fetchCode[id]===fetch_check.fetchCode[key]){
                         if(linedata[key]===""||linedata[key]===undefined){
                             flg = false
                         return  idKeys
                         }
                         else(idKeys.push({[key]:linedata[key]}))
                     }
                     return idKeys
                 })
                 if(flg){
                     let row = {}
                     Object.keys(linedata).map((key,idx)=>{  //複数key対応
                         if(/_gridmessage/.test(key)){}
                         else{row[key]=linedata[key]}
                         return ""
                     })
                     updateParams([
                         {"fetchCode": JSON.stringify(idKeys)},
                         {"linedata": JSON.stringify(row)},
                         {"index": index},
                         {"fetchview": fetch_check.fetchCode[id]},
                         {"buttonflg": "fetch_request"},
                 ])
                 //handleFetchRequest(params,data) //onBlurFunc7でセットされた項目はfetchでまとめて更新
                 fetchCheckFlg = true
                 }else{}//未入力keyがある。  
             }
             else{updateLineData(index,data,autoAddFields) } //onBlurFunc7でセットされた項目を画面に反映
             
             if(fetch_check.checkCode[id]){
              let chkcondtion = fetch_check.checkCode[id].split(",")[1]
              if (chkcondtion === undefined || (chkcondtion === "add" & linedata[id] === "") ||
                  (chkcondtion === "update" & linedata[id] !== "")) {
                  updateParams([
                  {"checkCode": JSON.stringify({ [id]: fetch_check.checkCode[id] })},
                  {"linedata": JSON.stringify(linedata)},
                  {"index": index},
                  {"buttonflg": "check_request"},
              ])
              //handleFetchRequest(params)
              //break
              fetchCheckFlg = true
              }
          }
             if(fetchCheckFlg){handleFetchRequest(params,data)}
           break
          }
        }

        switch (true){   
        case /^Editable/.test(className):
            return (
                <Tooltip content={data[index][id + '_gridmessage']||""}
                border={true} tagName="span" arrowSize={2}>
                {buttonflg === "inlineadd7"&&(  //params["buttonflg"] === "inlineadd7"?a:b  だとa,b両方処理した。
                //buttonflg:画面のコントロール　params.buttonflg ScreenLibでcolumnsのclassName等をセット
                <input value={initialValue}
                   //placeholder(入力されたことにならない。) defaultvale（照会内容の残像が残る。)
                   onChange={(e) => setFieldsByonChange(e)}
                    // onFocus={(e) => { setFieldsByonFocus(e)
                    //                 setProtectFunc(id,row)}}
                      onBlur={(e) => setFieldsByonBlur(e)}
                      className={setClassFunc(id,row,className,buttonflg)}
                      //readOnly={typeof(newReadOnly[id])==="undefined"?false:setNewReadOnly(()=>loading===false?setProtectFunc(id,row):true)}
                      readOnly={loading?true:false}
                      onKeyUp={(e) => {  
                          if (e.key === "Enter" ) 
                                {
                                  onLineValite(data[index],index,data,params)
                                }
                        }}        
                    />)}
                  {buttonflg === "inlineedit7"&&(//buttonflg:画面のコントロール　params.buttonflg ScreenLibでcolumnsのclassName等をセット
                <input  value={initialValue} 
                    onChange={(e) => setFieldsByonChange(e)}
                    onBlur={(e) => setFieldsByonBlur(e)}
                    className={setClassFunc(id,row,className,buttonflg)}
                    //readOnly={typeof(newReadOnly[id])==="undefined"?false:newReadOnly[id]}
                      readOnly={loading?true:false}
                    onKeyUp={(e) => {  
                      if (e.key === "Enter" ) 
                          {
                            onLineValite(data[index],index,data,params)
                    }
                  }}
                  />)}
                </Tooltip>)
        case /SelectEditable/.test(className):
            return (<select
                value={initialValue ||""}
                    onChange={e => {
                    setFieldsByonChange(e)
                    }}
                > 
          {typeof(dropDownList[id])!=="undefined"&&JSON.parse(dropDownList[id]).map((option, i) => (
            <option key={i} value={option.value}>
              {option.label}
            </option>
          ))}
        </select>
        )

        case /CheckEditable/.test(className):
          return <input  type="checkbox" 
              onChange={e => {
                setFieldsByonChange(e)
              }}/>
        case /^NonEditable/.test(className):
            return <span> {initialValue||""} </span>

        case /SelectNonEditable/.test(className):
            return (
            <select value={initialValue||""} disabled >
            {
              typeof(dropDownList[id])!=="undefined"&&JSON.parse(dropDownList[id]).map((option, i) => (
                <option key={i} value={option.value} >
                {option.label} 
                </option>
            ))}</select>
          )

        case /CheckNonEditable/.test(className):
            return <input value={initialValue || ""} type="checkbox" readOnly />
    
        case /checkbox/.test(className):
            return (
              <Tooltip content={data[index]['confirm_gridmessage']||""}
              border={true} tagName="span" arrowSize={2}>
              <label   htmlFor={`confirm${index}`} className={setClassFunc(id,row,className,buttonflg)} >
              {setClassFunc(id,row,className,buttonflg)==="checkbox"?"":"error"}
              </label> 
              <input  type="checkbox" checked={data[index]['confirm']===true?"checked":""} 
                      id={`confirm${index}`}
                      className={setClassFunc(id,row,className,buttonflg)}
                      readOnly />
              {/*     style={{bakground:"red"}}が有効にならない。*/}
          </Tooltip>)
        default:
            return <input value={initialValue || ""} readOnly />
        }
}


const DefaultColumnFilter = ({
    column:{ filterValue, setFilter, preFilteredRows, id} ,
    dropDownList,column
    }) => {
            if(column.filter==="includes"){  
                return (<select
                    value={filterValue||""}
                    onChange={e => {
                        setFilter(e.target.value || "")
                    }}
                  >
                    {typeof(dropDownList[id])!=="undefined"&&JSON.parse(dropDownList[id]).map((option, i) => (
                      <option key={i} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </select>)
            }
            else{return (
                <input
                value={filterValue||""}
                onChange={e => {  // onBlur can not use
                setFilter(e.target.value || "")
                    }
                }
                />
            )}
}
 
let Yup = require('yup')

let fieldSchema = (field, screenCode) => {
  let tmp = {}
  tmp[field] = yupschema[screenCode][field]
  return (
    Yup.object(
      tmp
    ))
}

///
///ScreenGrid7 
///

const ScreenGrid7 = ({ 
    screenCode, screenwidth, hiddenColumns,fetch_check,
    dropDownListOrg, buttonflgOrg, paramsOrg,columnsOrg, dataOrg,screenFlg,
    //buttonflg 下段のボタン：request params[:buttonflg] MenusControllerでの実行ケース
    loading, hostError, pageSizeList, 
    handleScreenRequest, handleFetchRequest,handleScreenParamsSet,message,
    }) => {
        const columns = useMemo(
            () => (columnsOrg))
        const updateParams = (changeParams) => {
           changeParams.map((ary,index)=>{
           let key = Object.keys(ary)[0]
           params[key] = ary[key]
           return ""
            })}
        const [data, setData] = useState(dataOrg) 
        const [changeData, setChangeData] = useState([]) 
        useEffect(()=>{setData(dataOrg)},[dataOrg])
        useEffect(()=>{setInitChangeData(dataOrg)},[dataOrg])
        useEffect(()=>{setFetchData(Number(paramsOrg.index),paramsOrg.parse_linedata)},[paramsOrg.parse_linedata])
        const setFetchData = (index, fetch_data) => {
          setData(old=>
            {let newData = old.map((row, idx) => {
              if (index === idx) {
                      Object.keys(fetch_data).map((field)=>row = {...row,[field]:fetch_data[field]})
                  }
              return row
            })
            return newData
          })
        }

        
        const setInitChangeData = (dataOrg) => {
          setChangeData(old=>
            {let newChangeData = dataOrg.map((row, idx) => {
              return {}
            })
            return newChangeData
          })
        }

        useEffect(()=>{setFetchCheckErr(Number(paramsOrg.index),paramsOrg.parse_linedata)},[paramsOrg.err])
        const setFetchCheckErr = (index, fetch_data) => {
          setData(old=>
            {let newData = old.map((row, idx) => {
              if (index === idx) {
                      row = {...row,[paramsOrg.parse_linedata.errPath]:fetch_data[paramsOrg.parse_linedata.errPath],
                                    confirm_gridmessage:fetch_data[paramsOrg.parse_linedata.errPath]}
                  }
              return row
            })
            return newData
          })
        }
        
       const [params, setParams] = useState({})
       useEffect(()=>{setParams(paramsOrg)},[paramsOrg])               
        
        const [controlledPageIndex, setControlledPageIndex] = useState(0)  //独自のものを用意  
        useEffect(()=>{setControlledPageIndex(()=>Number(params["pageIndex"]))},[(params["pageIndex"])])
        const [controlledPageSize, setControlledPageSize] = useState(0)  //独自のものを用意  
        useEffect(()=>{setControlledPageSize(()=>Number(params["pageSize"]))},[(params["pageSize"])])

        const [buttonflg, setButtonflg] = useState("")
        useEffect(()=>{setButtonflg(buttonflgOrg)},[buttonflgOrg])

        const nextPage = () => {
            updateParams([{pageIndex:(controlledPageIndex + 1)}])
            handleScreenRequest(params,data) 
        } 

      const previousPage = () => {
          updateParams([{pageIndex:(controlledPageIndex - 1)}])
          handleScreenRequest(params,data) 
      }

      const gotoPage = ((page) => {
          if(Number(page)>=0&&Number(page)<(Number(params["pageCount"]) + 1))
              {
                updateParams([{pageIndex:((Number(page) - 1))}])
                //setControlledPageIndex(page)
                handleScreenRequest(params,data) 
              }
          else{
        }}    
      ) 

      const canPreviousPage = (() => { return controlledPageIndex < 1 ? 0 : 1 })
      const canNextPage = (() => { return (controlledPageIndex + 1) < (Number(params["pageCount"])) ? 1 : 0 })
  
    return (
      <div>
        <TableGridStyles height={buttonflg ? "840px" : buttonflg === "export" ? "500px" : buttonflg === "import" ? "300px" : "840px"}
          screenwidth={screenwidth} >
          <GridTable  columns={columns}  screenCode={screenCode}
            data={data} setData={setData} dropDownListOrg={dropDownListOrg}
            setChangeData={setChangeData} changeData={changeData}
            loading={loading} handleScreenParamsSet={handleScreenParamsSet}
            controlledPageIndex={controlledPageIndex}  controlledPageSize={controlledPageSize} buttonflg={buttonflg}
            pageSizeList={pageSizeList}  fetch_check={fetch_check}
            paramsOrg={paramsOrg} params={params}  updateParams={updateParams} 
            //skipReset={skipResetRef.current}
            disableFilters={params.disableFilters}
            hiddenColumns={hiddenColumns} handleScreenRequest={handleScreenRequest} 
            handleFetchRequest={handleFetchRequest}
            getHeaderProps={column => ({  //セルのサイズ合わせとclick　keyが重複するのを避けるため
              onClick: (e) =>{if(e.ctrlKey){  //sort時はctrlKey　keyが必須
                                switch(column.isSorted){
                                case true:
                                  switch(column.isSortedDesc){
                                    case false:
                                        column.toggleSortBy(true,true)
                                        return
                                    default:
                                        column.clearSortBy()
                                        return
                                      }
                                default: 
                                        column.toggleSortBy(false,true)
                                        return
                                        }}
                              },
             style:{fontSize:cellFontSize(column,'Header')}, 
            })}
            getCellProps={cell=>({
              style:{fontSize:cellFontSize(cell,'Cell')}, 
            })}
          />
        </TableGridStyles>
      <div>
        {loading ? (
          <div colSpan="10000">
            Loading...
          </div>
        ) : (
          //(params["buttonflg"]!=="viewtablereq7"||params["buttonflg"]==="cinlineedit7")?<div colSpan="10000" className="td" ></div>:
            <div colSpan="10000" className="td" >
               {Number(params["totalCount"])===0?"No Record":
                `Showing ${controlledPageIndex * controlledPageSize + 1} of ~
                 ${Number(params["totalCount"]) < ((controlledPageIndex + 1) * controlledPageSize)? 
                  Number(params["totalCount"]) : ((controlledPageIndex + 1) * controlledPageSize)} 
                  results of  total ${Number(params["totalCount"])} records`}
            </div>
          )}
      </div>
      {(Number(params["totalCount"])>0)&& 
      <div className="pagination">
        <button onClick={() => {
          gotoPage(1)
        }} disabled={canPreviousPage() === 0 ? true : false}>
          {'<<'}
        </button>{''}
        <button onClick={() => {
          previousPage()
        }} disabled={canPreviousPage() === 0 ? true : false}>
          {'<'}
        </button>{''}
        <button onClick={() => { nextPage() }} disabled={canNextPage() === 0 ? true : false}>
          {'>'}
        </button>{''}
        <button onClick={() => { gotoPage(Number(params["pageCount"])) }} disabled={canNextPage() === 0 ? true : false}>
          {'>>'}
        </button>{' '}
        <span>
          Page{' '}
          <strong>
            {controlledPageIndex + 1} of {(Number(params["pageCount"]))}
          </strong>{''}
        </span>
        <span>
          | Go to page:{''}
          <input
            type="number"
            value={controlledPageIndex?controlledPageIndex + 1:1}
            onChange={e => {
              setControlledPageIndex((Number(e.target.value) - 1))
            }}
            onBlur={e => {
              gotoPage(e.target.value)
            }}
            onKeyUp={(e) => {  
                if (e.key === "Enter" )
                 { 
                  gotoPage(e.target.value)
                 }
            }}
            style={{width: '80px',
                    height:'23px',
                    textAlign: 'right'}}
          />
        </span>{' '}
        <select
          value={Number(controlledPageSize||0)}
          onChange={e => {
            //params["pageIndex"]= 1
             let pageIndex=Math.floor(controlledPageSize*controlledPageIndex/
                                                             Number(e.target.value))
            updateParams([{pageIndex:pageIndex},{pageSize:Number(e.target.value)}])
            handleScreenRequest(params,data) 
          }}
        >
          {pageSizeList.map(pageSize => (
            <option key={pageSize} value={pageSize}>
              Show {pageSize}
            </option>
          ))  /*menuから呼ばれたときはparams["pageSizeList"]==null　*/}
        </select>
      </div>  /*nextPage等終わり*/}  
      <p>{hostError}</p>
     
       { columns&&<div> <ButtonList screenFlg={screenFlg} /></div>}
       {loading&&<p>{message}</p>}
      </div>
    )
}

// Create a default prop getter
const defaultPropGetter = () => ({})

///
///gridtable
///
const GridTable = ({
    columns,screenCode,
    data,setData, dropDownListOrg,setChangeData,changeData,
    loading,fetch_check,
    //controlledPageIndex, controlledPageSize,pageSizeList,
    params, updateParams,
    buttonflg,
    disableFilters,
    hiddenColumns,handleScreenRequest,
    handleFetchRequest,handleScreenParamsSet,
    getHeaderProps = defaultPropGetter,
    getColumnProps = defaultPropGetter,
    getCellProps = defaultPropGetter,
    //skipReset,       
    }) => { 
  
    const [dropDownList, setDropDownList] = useState(dropDownListOrg)
  
    useEffect(() => {
                  params = {...params,sortBy:[],filtered:[],clickIndex:[]}},
                    [screenCode]) 

    useEffect(()=>{   setDropDownList(dropDownListOrg)},
                          [dropDownListOrg])

    useEffect(() => {
          setAllFilters(params.filtered.length===0?[]:params.filtered.map((filter)=>{
                  return (typeof(filter)==="string"?JSON.parse(filter):filter)}))},[params.filtered])  
                  
    useEffect(() => {
              setSortBy(params.sortBy.length===0?[]:params.sortBy.map((sort)=>{
                  return (typeof(sort)==="string"?JSON.parse(sort):sort)}))},[params.sortBy])  
               
    const ColumnHeader = ({
        column ,
        }) => {
        return (
            <span></span>
        )
    }

    const defaultColumn = useMemo(
        () => ({
        Header: ColumnHeader,
        Filter: DefaultColumnFilter,
        Cell: AutoCell,
        }),
        []
    )
 
    const {
        getTableProps,
        getTableBodyProps,
        headerGroups,
        rows,
        prepareRow, 
        toggleAllRowsSelected,   
        setAllFilters,setSortBy,
        state:{filters,sortBy,selectedRowIds}  //:{controlledPageIndex,controlledPageSize},  //hiddenColumns,}
    } = useTable(
        {
            columns,
            data,changeData,
            params,updateParams,
            dropDownList,fetch_check,buttonflg,loading,setData,setChangeData,
            defaultColumn,
            manualPagination: false,
            manualFilters: true,
            manualSortBy: true,
            disableMultiSort: false,
            autoResetSortBy: true,
            disableFilters,
            initialState: {hiddenColumns:hiddenColumns,
                      sortBy:params.sortBy===undefined?[]:params.sortBy.map((sort)=>{return sort})
                    },
            handleFetchRequest,handleScreenRequest,
     // initialState: { controlledPageIndex: 0, controlledPageSize: 0, },
    },
    useFilters, //
    useSortBy,  //The useSortBy plugin hook must be placed after the useFilters plugin hook!
    useBlockLayout,
    useResizeColumns,
    useExpanded,
    //usePagination,
    //useTokenPagination, //The usePagination plugin hook must be placed after the useSortBy plugin hook!
    useRowSelect,
  )
  //

    return (
    <div>
      <table {...getTableProps({
              onClick: (e) =>{}
                     })} className="table">
        <thead className="thead">
          {headerGroups.map(headerGroup => (
            <tr {...headerGroup.getHeaderGroupProps({
              style: {
                      backgroundColor: 'gray'
                     },
              onKeyUp: (e) =>  //
                     {  // filter sortでの検索しなおし
                      if (e.key === "Enter" &&(params.disableFilters===false) )
                          { 
                            updateParams([{filtered:filters},{sortBy:sortBy}])
                            // Apply the header cell props
                            handleScreenRequest(params,data)
                          }
                      },
              onClick: (e) =>{
                              }
            })
            } className="tr">
              {headerGroup.headers.map(column => (
                <th {...column.getHeaderProps([getHeaderProps(column),
                                                ])} className="th">
                  {/* Use column.getResizerProps to hook up the events correctly */}
                  {column.render('Header')}
                  <span>
                    {column.isSorted ? column.isSortedDesc ? '↓' : '↑' : ''}
                  </span>
                  {typeof(dropDownList)!=="undefined"&&column.canFilter&&<span>
                   {column.render('Filter') }
                  </span> }
                  <span {...column.getResizerProps()}   className={`resizer ${column.isResizing ? 'isResizing' : ''}`}> 
                  </span>
                </th>
              ))}
            </tr> 
          ))}
        </thead>
          <tbody {...getTableBodyProps()} className="tbody"  >
            {rows.map((row, i) => {
              prepareRow(row)
              return (
              <tr {...row.getRowProps({
                  style: {
                      backgroundColor: row.isSelected ? 'lime' :
                      row.index % 2 === 0 ? 'ivory' : 'lightgray',
                      },
                  onClick: e => {
                      // let result = -1
                      let sNo
                      switch(params.screenCode){
                        case 'fmcustord_custinsts':
                          sNo = "custinst_sno_custord"
                          break
                        case 'fmcustinst_custdlvs':
                          sNo = "custdlv_sno_custinst"
                          break
                        default:
                          sNo = "sno"
                      }
                      // if(params.clickIndex){
                      //       switch(params.screenCode){
                      //         case "fmcustord_custinsts":
                      //           params.clickIndex.map((clickRow,index) => 
                      //                 {if(clickRow.custord_id===data[row.index]["custord_id"])
                      //                       {result = index}
                      //                 })
                      //           break
                      //         default:
                      //           params.clickIndex.map((clickRow,index) => 
                      //                 {if(clickRow.id===data[row.index]["id"])
                      //                       {result = index}
                      //                 })}
                      // }
                      // else{ params = { ...params,clickIndex:[]}}
                      if(e.ctrlKey){
                          if(Object.keys(selectedRowIds).length===0){
                            toggleAllRowsSelected(true)
                            let tmpClicks = []
                            data.map((line,idx) => tmpClicks.push({lineId:idx,id:line["id"],
                                                    screenCode:params.screenCode,sNo:line[sNo]})
                            )
                            updateParams([{clickIndex:tmpClicks},])
                          }else{
                            toggleAllRowsSelected(false)
                            updateParams([{clickIndex:[]},])  //変更内容は変化しない
                          }
                      }else{
                        if(row.isSelected){
                          params.clickIndex[row.index] = {}
                          row.toggleRowSelected(false)
                          }
                        else{
                          row.toggleRowSelected(true)
                          params.clickIndex[row.index] = {lineId:row.index,id:data[row.index]["id"],
                                                            screenCode:params.screenCode,sNo:data[row.index][sNo]}}
                      }
                      params = {...params,changeData:changeData}
                      handleScreenParamsSet(params)  
                    },
                  })
                  }
                    className="tr">
                {row.cells.map(cell => {  //cell.column.className  壱階層目の見出しを想定
                  return <td {...cell.getCellProps([{className:cell.column.className+" td "},
                                      getCellProps(cell) //font-sizeの調整
                  ])} >
                    {typeof(dropDownList)!=="undefined"&&cell.render('Cell') }
                    </td>
                })}
              </tr>
            )
          })}
        </tbody>
      </table>
      </div>
    )
}

const mapStateToProps = (state,ownProps) => {
    if(ownProps.screenFlg==="second"){
        return {
          buttonflgOrg: state.second.buttonflg,
          loading: state.second.loading,
          message: state.second.message,
          dataOrg: state.second.data,
          paramsOrg: state.second.params,
          screenCode: state.second.params.screenCode,
          pageSizeList: state.second.grid_columns_info.pageSizeList,
          columnsOrg: state.second.grid_columns_info.columns_info,
          screenwidth: state.second.grid_columns_info.screenwidth,
          fetch_check: state.second.grid_columns_info.fetch_check,
          dropDownListOrg: state.second.grid_columns_info.dropdownlist,
          hiddenColumns: state.second.grid_columns_info.hiddenColumns,
          hostError: state.second.hostError,
          screenFlg:ownProps.screenFlg,
       }
    }else{
        return {
          buttonflgOrg: state.button.buttonflg,
          loading: state.screen.loading,
          message: state.screen.message,
          dataOrg: state.screen.data,
          paramsOrg: state.screen.params,
          screenCode: state.screen.params.screenCode,
          pageSizeList: state.screen.grid_columns_info.pageSizeList,
          columnsOrg: state.screen.grid_columns_info.columns_info,
          screenwidth: state.screen.grid_columns_info.screenwidth,
          fetch_check: state.screen.grid_columns_info.fetch_check,
          dropDownListOrg: state.screen.grid_columns_info.dropdownlist,
          hiddenColumns: state.screen.grid_columns_info.hiddenColumns,
          hostError: state.screen.hostError,
          screenFlg:ownProps.screenFlg,
        }
    }      
}

const mapDispatchToProps = (dispatch, ownProps) => ({
    handleScreenRequest: (params,data) => {
        params = {...params,screenFlg:ownProps.screenFlg}
        if(params.screenFlg === "second"){
          dispatch(SecondRequest(params,data))
        }else{
          dispatch(ScreenRequest(params,data))}
  },
    handleFetchRequest: (params,data) => {
      params = {...params,screenFlg:ownProps.screenFlg}
        if(params.screenFlg === "second"){
          dispatch(SecondFetchRequest(params,data))
        }else{
          dispatch(FetchRequest(params,data))}
  },
    handleScreenParamsSet: (params) => {
      params = {...params,screenFlg:ownProps.screenFlg}
        if(params.screenFlg === "second"){
            dispatch(SecondParamsSet(params))
          }else{
            dispatch(ScreenParamsSet(params))}
  },
  
})
export default connect(mapStateToProps, mapDispatchToProps)(ScreenGrid7)
