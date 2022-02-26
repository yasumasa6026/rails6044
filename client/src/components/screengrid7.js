import React, { useState, useMemo, useEffect,useRef, } from 'react'
import { connect } from 'react-redux'
import { ScreenRequest, FetchRequest,ScreenParamsSet, 
          SecondScreenRequest, SecondFetchRequest,SecondScreenParamsSet, } from '../actions'
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
//import styled from 'styled-components'
import {setClassFunc,setProtectFunc,setInitailValueForAddFunc} from './functions7'

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
    row,params, updateParams,dropDownList,yup,handleScreenRequest,handleFetchRequest,
    params:{req},buttonflg,loading,  //useTableへの登録が必要
    }) => {
        const [value, setValue] = useState(initialValue)
        const [newClassName, setNewClassName] = useState(className)
        const [newReadOnly, setNewReadOnly] = useState(false)
        const inputRef = useRef()
        const setFieldsByonChange = (e) => {
            if(e.target){
                //initialValue = (e.target.value||"")  他の項目に移動すると、入力内容が消える。
                setValue(e.target.value)
                updateMyData(index, id, e.target.value ) //dataの内容が更新されない。但しとると、画面に入力内容が表示されない。
                inputRef.current = true
            }   
        } 
    const setFieldsByonFocus = (e) => {//
        inputRef.current = false
        if(e.target){
            if(e.target.value===null||e.target.value===""||e.target.value===undefined){
                //initialValue = setInitailValueForAddFunc(id,row,・・・　画面表示されない。
                values[id] = setInitailValueForAddFunc(id,row,className,params.screenCode)
            }else{
                values[id] = e.target.value
            }
            if(values[id]){
                //setValue(values[id])
                updateMyData(index, id, values[id])
                fetch_check(id,index, yup, data, updateParams, params, handleFetchRequest,loading,updateMyData)
            }
         // e.target.value||undefinedにすると日付チェックの時splitでエラーが発生
       }  
    }
  
    const setFieldsByonBlur = (e) => {
        if(inputRef.current === false&&buttonflg === "inlineedit7"){
            let updateRow = { [id]: e.target.value}
            onFieldValite(updateRow, id, params.screenCode)  //clientでのチェック
            let msg_id = `${id}_gridmessage`
            updateMyData(index, msg_id, updateRow[msg_id])}
        else{
            let updateRow = { [id]: e.target.value}
            onFieldValite(updateRow, id, params.screenCode)  //clientでのチェック
            let msg_id = `${id}_gridmessage`
            if ( updateRow[msg_id] === "ok") {
                fetch_check(id,index, yup, data, updateParams, params, handleFetchRequest,loading,updateMyData)
            }else{
              updateMyData(index, msg_id, updateRow[msg_id])}
            }    
    }
  
    useEffect(() => {
        setValue(initialValue)
        }, [initialValue])

    let onFieldValite = (updateRow, field, screenCode) =>{  // yupでは　2019/12/32等がエラーにならない
        let schema = fieldSchema(field, screenCode)
        yupErrCheck(schema,field,updateRow)
        if(updateRow[field+"_gridmessage"]==="ok"){
            onBlurFunc7(screenCode, updateRow, field)
          }
        return updateRow
    }

    const onLineValite = (tgrow,index,data,params) => {
        let screenSchema = Yup.object().shape(yupschema[params.screenCode])
        let updateRow = {}
        Object.keys(screenSchema.fields).map((field) => {
        updateRow[field] = tgrow[field] 
        return updateRow  //更新可能項目のみをセレクト
        })  
        yupErrCheck(screenSchema,"confirm",updateRow)
        if (updateRow["confirm_gridmessage"] === "doing") {
            let newrow = {}
            Object.keys(data[index]).map((key,idx)=>{  //複数key対応
            if(/_gridmessage/.test(key)){}
            else{newrow[key]=data[index][key]}
            return null
            }
            ) 
            updateParams([{ linedata: JSON.stringify(newrow)}, { index: index },
                        { req: "confirm7" }])
            handleScreenRequest(params,data)
        }else{
            let msg_id = "confirm_gridmessage"
            updateMyData(index, msg_id, " error " + updateRow[msg_id])
            msg_id = `${updateRow["errPath"]}_gridmessage`
            updateMyData(index, msg_id, " error " + updateRow[msg_id])
            setClassFunc(updateRow["errPath"],row,className,req)
            updateMyData(index, "confirm", false)
        }
    }
  //id,row,className,req  autocellで指定が必要
   useEffect(()=>setNewClassName(()=>row.values&&setClassFunc(id,row,className,req)),
                                    [row.values[id+"_gridmessage"]])
   useEffect(()=>setNewReadOnly(()=>loading===false?setProtectFunc(id,row):true),[loading])

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

  switch (true){   
    case /^Editable/.test(className):
      return (
        <Tooltip content={data[index][id + '_gridmessage']||""}
          border={true} tagName="span" arrowSize={2}>
          {buttonflg === "inlineadd7"&&(  //params["req"] === "inlineadd7"?a:b  だとa,b両方処理した。
          //buttonflg:画面のコントロール　params.req ScreenLibでcolumnsのclassName等をセット
            <input value={value||""}
                   //placeholder(入力されたことにならない。) defaultvale（照会内容の残像が残る。)
                    onFocus={(e) => { setFieldsByonFocus(e)
                                    setProtectFunc(id,row)}}
                    onChange={(e) => setFieldsByonChange(e)}
                    onBlur={(e) => setFieldsByonBlur(e)}
                    className={newClassName}
                    readOnly={newReadOnly}
                    onKeyUp={(e) => {  
                        if (e.key === "Enter" ) 
                              {
                                onLineValite(data[index],index,data,params)
                              }
                      }}        
                    />)}
           {buttonflg === "inlineedit7"&&(//buttonflg:画面のコントロール　params.req ScreenLibでcolumnsのclassName等をセット
            <input  value={value||""} 
                  //  onFocus={(e) =>  setProtectFunc(id,row)} //numeric-->varchar等うまくいかない
                    onChange={(e) => setFieldsByonChange(e)}
                    onBlur={(e) => setFieldsByonBlur(e)}
                    className={newClassName}
                    readOnly={newReadOnly}
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
          value={value||""}
          onChange={e => {
            setFieldsByonChange(e)
          }}
        >
          {JSON.parse(dropDownList[id]).map((option, i) => (
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
        {JSON.parse(dropDownList[id]).map((option, i) => (
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
              <input  type="checkbox" checked={data[index]['confirm']===true?"checked":""} 
                      className={newClassName} readOnly />
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
            if(dropDownList&&column.filter==="includes"){  
                return (<select
                    value={filterValue||""}
                    onChange={e => {
                        setFilter(e.target.value || "")
                    }}
                  >
                    {JSON.parse(dropDownList[id]).map((option, i) => (
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
 
//serverデータとのチェック又はserverデータの検索
const fetch_check = (id, index, yup, data, updateParams, params,handleFetchRequest,loading,updateMyData) => {
    switch (true) {
      case /confirm$/.test(id):
        break
      default:
        if(yup.yupcheckcode[id]){
          let chkcondtion = yup.yupcheckcode[id].split(",")[1]
          if (chkcondtion === undefined || (chkcondtion === "add" & data[index][id] === "") ||
            (chkcondtion === "update" & data[index][id] !== "")) {
            updateParams([
              {"checkcode": JSON.stringify({ [id]: yup.yupcheckcode[id] })},
              {"linedata": JSON.stringify(data[index])},
              {"index": index},
              {"req": "check_request"},
            ])
            handleFetchRequest(params,data,loading)
          }
        }
        //チェック項目と検索項目は兼用できない。
        if(yup.yupfetchcode[id]){
            let idKeys=[]
            let flg = true
            Object.keys(yup.yupfetchcode).map((key,idx)=>{  //複数key対応
              if(yup.yupfetchcode[id]===yup.yupfetchcode[key]){
                if(data[index][key]===""||data[index][key]===undefined){
                  flg = false
                  return  idKeys
                }
                else(idKeys.push({[key]:data[index][key]}))
              }
            return idKeys
            })
          if(flg){
            let row = {}
             Object.keys(data[index]).map((key,idx)=>{  //複数key対応
              if(/_gridmessage/.test(key)){}
                else{row[key]=data[index][key]}
                return null
              }
             )
            updateParams([
              {"fetchcode": JSON.stringify(idKeys)},
              {"linedata": JSON.stringify(row)},
              {"index": index},
              {"fetchview": yup.yupfetchcode[id]},
              {"req": "fetch_request"},
            ])
            handleFetchRequest(params,data,loading)
          }else{}//未入力keyがある。  
        }else{
          updateMyData(index, `${id}_gridmessage`,"ok" )}
        break
    }
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
  screenCode, screenwidth, hiddenColumns,yup,
  dropDownListOrg, buttonflgOrg, paramsOrg,columnsOrg, dataOrg,
    //buttonflg 下段のボタン：request params[:req] MenusControllerでの実行ケース
  loading, hostError, pageSizeList, 
  handleScreenRequest, handleFetchRequest,handleScreenParamsSet,second,
  }) => {

  const columns = useMemo(
    () => (columnsOrg))
  const [params, setParams] = useState({})
  const updateParams = (changeParams) => {
         changeParams.map((ary,index)=>{
           let key = Object.keys(ary)[0]
           params[key] = ary[key]
           return null
         })}

  const [controlledPageIndex, setControlledPageIndex] = useState(0)  //独自のものを用意  
  useEffect(()=>{setControlledPageIndex(()=>Number(params["pageIndex"]))},[(params["pageIndex"])])
  const [controlledPageSize, setControlledPageSize] = useState(0)  //独自のものを用意  
  useEffect(()=>{setControlledPageSize(()=>Number(params["pageSize"]))},[(params["pageSize"])])
  //useEffect(() => { skipResetRef.current = false}, [dataOrg])

  const [data, setData] = useState([]) 

  const [buttonflg, setButtonflg] = useState()
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
            dataOrg={dataOrg} data={data} setData={setData} dropDownListOrg={dropDownListOrg}
            loading={loading} handleScreenParamsSet={handleScreenParamsSet}
            controlledPageIndex={controlledPageIndex}  controlledPageSize={controlledPageSize} buttonflg={buttonflg}
            pageSizeList={pageSizeList}  yup={yup}
            paramsOrg={paramsOrg} params={params} setParams={setParams}  updateParams={updateParams} 
            //skipReset={skipResetRef.current}
            disableFilters={params.disableFilters}
            hiddenColumns={hiddenColumns} handleScreenRequest={handleScreenRequest} 
            handleFetchRequest={handleFetchRequest}
            getHeaderProps={column => ({  //セルのサイズ合わせとclick　keyが重複するのを避けるため
              onClick: (e) =>{if(e.shiftKey){  //sort時はshift　keyが必須
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
        ) : ((params["req"]!=="viewtablereq7"||params["req"]==="inlineedit7")?<div colSpan="10000" className="td" ></div>:
            <div colSpan="10000" className="td" >
               {Number(params["totalCount"])===0?"No Record":
                `Showing ${controlledPageIndex * controlledPageSize + 1} of ~
                 ${Number(params["totalCount"]) < ((controlledPageIndex + 1) * controlledPageSize)? 
                  Number(params["totalCount"]) : ((controlledPageIndex + 1) * controlledPageSize)} 
                  results of  total ${Number(params["totalCount"])} records`}
            </div>
          )}
      </div>
      {(params["req"]==="viewtablereq7"||params["req"]==="inlineedit7")&& 
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
     
       { columns&&<div> <ButtonList second={second} /></div>}
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
        dataOrg, data,setData, dropDownListOrg,
        loading,yup,
        //controlledPageIndex, controlledPageSize,pageSizeList,
        paramsOrg,params, setParams, updateParams,buttonflg,
        disableFilters,
        hiddenColumns,handleScreenRequest,
        handleFetchRequest,handleScreenParamsSet,
        getHeaderProps = defaultPropGetter,
        getColumnProps = defaultPropGetter,
        getCellProps = defaultPropGetter,
        //skipReset,       
      }) => {
        
 
  const [dropDownList, setDropDownList] = useState()
  
  useEffect(() => {
                   updateParams([{sortBy:"[]"},{filtered:"[]"}])},
                    [screenCode]) 

  useEffect(()=>{   setData(dataOrg)},
                          [dataOrg])
  useEffect(()=>{   setDropDownList(dropDownListOrg)},
                          [dropDownListOrg])

  useEffect(() => {
          setAllFilters(params.filtered===undefined?[]:JSON.parse(params.filtered).map((filter)=>{
                  return filter}))},[params.filtered])  
                  
  useEffect(() => {
              setSortBy(params.sortBy===undefined?
                       []:JSON.parse(params.sortBy).map((sort)=>{
                  return sort}))},[params.sortBy])  
             
  useEffect(()=>{setParams(paramsOrg)},[paramsOrg])  

  

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
    //setHiddenColumns,// to set the `hiddenColumns` state for the entire table.
    //setHiddenColumns,   //pageCount,//page,
    //canPreviousPage, canNextPage,
    //setPageIndex,
    //previousPage,nextPage,
    //setPageSize, //Instance Properties This function sets state.pageSize to the new value. already prepare
    //gotoPage,//toggleSortBy,
    //clearSortBy,
        state:{filters,sortBy}  //:{controlledPageIndex,controlledPageSize},  //hiddenColumns,}
    } = useTable(
        {
            columns,
            data,
            params,updateParams,dropDownList,yup,buttonflg,loading,setData,
            defaultColumn,
            manualPagination: false,
            manualFilters: true,
            manualSortBy: true,
            disableMultiSort: false,
            autoResetSortBy: true,
            disableFilters,
            initialState: {hiddenColumns:hiddenColumns,
                      sortBy:params.sortBy===undefined?[]:JSON.parse(params.sortBy).map((sort)=>{return sort})
                    },
    //  autoResetPage: !skipReset,
    //  autoResetSelectedRows: !skipReset,
    //  updateMyData,   //pageCount: controlledPageCount,
    //        filterTypes,
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
                            updateParams([{filtered:JSON.stringify(filters)},{sortBy:JSON.stringify(sortBy)}])
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
                  {column.canFilter&&<span>
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
                      toggleAllRowsSelected(false)
                      updateParams([{clickIndex:[]}])
                      row.toggleRowSelected()
                      let starttime = params.screenCode.split("_")[1].slice(0,-1)+"_starttime" //outstksで使用
                      updateParams([{clickIndex:[{lineId:row.index,id:data[row.index]["id"],starttime:data[row.index][starttime]}]},
                                    {index:row.index}])
                      handleScreenParamsSet(params)  
                    },
                  })
                  }
                    className="tr">
                {row.cells.map(cell => {  //cell.column.className  壱階層目の見出しを想定
                  return <td {...cell.getCellProps([{className:cell.column.className+" td "},
                                      getCellProps(cell) //font-sizeの調整
                  ])} >
                    {cell.render('Cell') }
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
  if(ownProps.second===true){
    return {
        buttonflgOrg: state.second.buttonflg,
        loading: state.second.loading,
        dataOrg: state.second.data,
        paramsOrg: state.second.params,
        screenCode: state.second.params.screenCode,
        pageSizeList: state.second.grid_columns_info.pageSizeList,
        columnsOrg: state.second.grid_columns_info.columns_info,
        screenwidth: state.second.grid_columns_info.screenwidth,
        yup: state.second.grid_columns_info.yup,
        dropDownListOrg: state.second.grid_columns_info.dropdownlist,
        hiddenColumns: state.second.grid_columns_info.hiddenColumns,
        hostError: state.second.hostError,
        second:ownProps.second,
       }
    }else{
      return {
        buttonflgOrg: state.button.buttonflg,
        loading: state.screen.loading,
        dataOrg: state.screen.data,
        paramsOrg: state.screen.params,
        screenCode: state.screen.params.screenCode,
        pageSizeList: state.screen.grid_columns_info.pageSizeList,
        columnsOrg: state.screen.grid_columns_info.columns_info,
        screenwidth: state.screen.grid_columns_info.screenwidth,
        yup: state.screen.grid_columns_info.yup,
        dropDownListOrg: state.screen.grid_columns_info.dropdownlist,
        hiddenColumns: state.screen.grid_columns_info.hiddenColumns,
        hostError: state.screen.hostError,
        second:ownProps.second,
        }
  }      
}

const mapDispatchToProps = (dispatch, ownProps) => ({
    handleScreenRequest: (params,data) => {
      params.second = ownProps.second
    if( ownProps.second===true){ 
      dispatch(SecondScreenRequest(params,data))
      }else{  
    dispatch(ScreenRequest(params,data))
    }
  },
  handleFetchRequest: (params,data,loading) => {
    params.second = ownProps.second
    if( ownProps.second===true){ 
      dispatch(SecondFetchRequest(params,data,loading))
      }else{  
    dispatch(FetchRequest(params,data,loading))
    }
  },
  handleScreenParamsSet: (params) => {
    params.second = ownProps.second
    if( ownProps.second===true){ 
      dispatch(SecondScreenParamsSet(params))
      }else{  
    dispatch(ScreenParamsSet(params))
    }
  },
})
export default connect(mapStateToProps, mapDispatchToProps)(ScreenGrid7)
