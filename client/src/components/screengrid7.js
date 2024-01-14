//
//  typeof(xxx)==="undefined"の対応要
//
import React, { useState, useMemo, useEffect, } from 'react'
import { connect } from 'react-redux'
import { ScreenConfirm, FetchRequest,ScreenSubForm,SecondSubForm,
            SecondConfirm, SecondFetchRequest,ScreenDataSet,SecondDataSet  } from '../actions'
//import DropDown from './dropdown'
import { yupschema } from '../yupschema'
import { yupErrCheck } from './yuperrcheck'
import Tooltip from 'react-tooltip-lite'
import { onBlurFunc7,onFieldValite ,fetchCheck} from './onblurfunc'
//import ButtonList from './buttonlist'
import {useTable, useRowSelect, useFilters, useGroupBy,useSortBy, useResizeColumns, useBlockLayout,
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
import ToSubForm from './tosubform'

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
    //setData,
     data, // This is a custom function that we supplied to our table instance
    setChangeData,
    row,params,dropDownList,fetch_check,fetchCheck,
    buttonflg,  //useTableへの登録が必要
    handleScreenRequest,handleFetchRequest,toggleSubForm,handleDataSetRequest,
    }) => {
        const setFieldsByonChange = (e) => {
            if(e.target){
                 values[id] =  e.target.value
                 updateMyData(index, id, values[id] ) //dataの内容が更新されない。但しとると、画面に入力内容が表示されない。
                 updateChangeData(index,id,values[id])
                 // handleDataSetRequest(data,params)
               }   
        } 
  
        const setFieldsByonBlur = (e) => {
            let lineData = {...values,[id]: e.target.value}  //[id] idの内容
            let msg_id = `${id}_gridmessage`
            lineData[msg_id] = "ok"
            let autoAddFields = {}
            lineData = onFieldValite(lineData, id, params.screenCode)  //clientでのチェック
            updateMyData(index, {[id]:lineData[id],[msg_id]:lineData[msg_id]})
            if(lineData[msg_id]==="ok"){
                lineData,autoAddFields = onBlurFunc7(params.screenCode, lineData, id)
            }
            updateData(index, lineData) 
            handleDataSetRequest(data,params)
            if ( lineData[msg_id] === "ok") {
              const {fetchCheckFlg,idKeys} = fetchCheck( lineData,id,fetch_check)
              params = {...params,fetchCode: JSON.stringify(idKeys),
                                      checkCode: JSON.stringify({ [id]: fetch_check.checkCode[id] }),
                                      lineData: JSON.stringify(lineData),
                                      fetchview: fetchCheckFlg==="fetch_request"?fetch_check.fetchCode[id]:"",
                                      index: index,buttonflg: fetchCheckFlg}
              if(fetchCheckFlg){handleFetchRequest(params,buttonflg)}
                  else{if(Object.keys(autoAddFields).length)
                        {handleDataSetRequest(data,params)}} //onBlurFunc7でセットされた項目を画面に反映
            }else{
              updateMyData(index, msg_id, " error " + lineData[msg_id])
              handleDataSetRequest(data,params)
            }
        }    
  

        const onLineValite = (lineData,index,params) => {
            let Yup = require('yup')
            let screenSchema = Yup.object().shape(yupschema[params.screenCode])
            let checkFields = {}
            Object.keys(screenSchema.fields).map((field) => {
                checkFields[field] = lineData[field] 
                return checkFields  //更新可能項目のみをセレクト
            })  
            checkFields = yupErrCheck(screenSchema,"confirm",checkFields)
            Object.keys(checkFields).map((field)=>lineData[field] = checkFields[field])
            if (lineData["confirm_gridmessage"] === "doing") {
                params = {...params, lineData:lineData,lineData: JSON.stringify(lineData),  index: index , buttonflg: "confirm7" }
                handleScreenRequest(params,data)
            }else{
                let msg_id = "confirm_gridmessage"
                let gridmsg_id = `${lineData["errPath"]}_gridmessage`
                updateData(index, {[msg_id]:" error " + lineData[msg_id],[gridmsg_id]: " error " + lineData[msg_id],confirm: false})
                handleDataSetRequest(data,params)
            }
        }   

        const updateMyData = (rowIndex, columnId, value) => {
            data =   data.map((row, index) => {
                if (index === rowIndex) {
                    row =  {
                      ...row,[columnId]: value,
                    }
                }
              return row
              })
        }
        const updateData = (rowIndex, line) => {
            data =   data.map((row, index) => {
                if (index === rowIndex) {
                    row =  {...row,...line,
                    }
                }
              return row
              })
        }

        
        const updateChangeData = (rowIndex, columnId, value) => {
          setChangeData(prev=>
            prev.map((row, index) => {
              if (index === rowIndex) {
                  row =  {
                    ...prev[rowIndex],
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
                <Tooltip content={data[index][id + '_gridmessage']||""}  border={true} tagName="span" arrowSize={2}>
                {(params.aud === "add"||params.aud === "edit")&&(  //
                <input value={initialValue||""}
                   //placeholder(入力されたことにならない。) defaultvale（照会内容の残像が残る。)
                   onChange={(e) => setFieldsByonChange(e)}
                     //onFocus={(e) => {setFieldsByonFocus(e)
                      //               }}
                      readOnly={setProtectFunc(id,row.values)}
                      // readOnly={row.values.fieldcode_ftype?setProtectFunc(id,row.values.fieldcode_ftype ):
                      //           row.values.screenfield_type?setProtectFunc(id,row.values.screenfield_type):false}
                      onBlur={(e) => setFieldsByonBlur(e)}
                      className={setClassFunc(id,row.values,className,params.aud)}
                      onKeyUp={(e) => {  
                           if (e.key === "Enter"&&!toggleSubForm ) 
                                 {
                                   onLineValite(row.values,index,params)
                                 }else{e.key === "Enter"&&toggleSubForm&&alert("can not use filer and sord when subForm using")}
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
          let chekboxClassName = setClassFunc(id,row.values,className,params.aud)
            return (
              <Tooltip content={data[index][`${id}_gridmessage`]||""}
              border={true} tagName="span" arrowSize={2}>
              <label   htmlFor={`${id}_${index}`} className={chekboxClassName} >
              {chekboxClassName==="checkbox"?"":"error"}
              </label> 
              <input  type="checkbox" checked={data[index][id]===true?"checked":""} 
                      id={`${id}_${index}`}
                      className={chekboxClassName}
                      readOnly />
              {/*     style={{bakground:"red"}}が有効にならない。*/}
              </Tooltip>)
        default:
            return <input value={initialValue || ""} readOnly />
        }
}


const DefaultColumnFilter = ({
    column:{ filterValue, setFilter,filter, preFilteredRows, id} ,
    dropDownList,
    }) => {
            if(filter==="includes"){  
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



// const DefaultColumnFilter = ({
//   column:{ filterValue, setFilter, preFilteredRows, id} ,
//   dropDownList,column
//   }) => {
//           if(column.filter==="includes"){  
//               return (<select
//                   value={filterValue||""}
//                   onChange={e => {
//                       setFilter(e.target.value || "")
//                   }}
//                 >
//                   {typeof(dropDownList[id])!=="undefined"&&JSON.parse(dropDownList[id]).map((option, i) => (
//                     <option key={i} value={option.value}>
//                       {option.label}
//                     </option>
//                   ))}
//                 </select>)
//           }
//           else{return (
//               <input
//               value={filterValue||""}
//               onChange={e => {  // onBlur can not use
//               setFilter(e.target.value || "")
//                   }
//               }
//               />
//           )}
// }


///
///ScreenGrid7 
///

const ScreenGrid7 = ({ 
    screenwidth, hiddenColumns,fetch_check,
    dropDownList, buttonflg, params,columnsOrg, dataOrg,screenCodeOrg,
    //buttonflg 下段のボタン：request params[:buttonflg] MenusControllerでの実行ケース
    loadingOrg, hostError, pageSizeList, 
    handleScreenRequest, handleFetchRequest,handleSubForm,toggleSubForm,message,handleDataSetRequest,
    }) => {
        const data = useMemo(
                () => (dataOrg),[dataOrg])
        const columns = useMemo(
                        () => (columnsOrg),[columnsOrg])
        const sortBy = useMemo(
                () => ([]),[screenCodeOrg])
        const groupBy = useMemo(
                        () => ([]),[screenCodeOrg])
        const [aggregated,setAggregated] = useState([]) //useState({})は動かなかった 
        const filters = useMemo(
                () => ([]),[screenCodeOrg])
        const [changeData, setChangeData] = useState([]) 
        const [loading, setLoading] = useState(false)
        const [screenCode,setScreenCode] = useState(screenCodeOrg)
       // const [columns,setColumns] = useState([])
        useEffect(()=>{setLoading(loadingOrg)},[loadingOrg])
        //useEffect(()=>{setColumns(columnsOrg)},[])
        useEffect(()=>{setScreenCode(screenCodeOrg),
                        params = {...params,clickIndex:[]}},[screenCodeOrg])          
        
        // const setInitChangeData = (data) => {
        //   setChangeData(old=>
        //     {let newChangeData = data.map((row, idx) => {
        //       return {}
        //     })
        //     return newChangeData
        //   })
        // }
    
        const nextPage = () => {
            params["pageIndex"] = params.pageIndex + 1
            handleScreenRequest(params,data) 
        } 

      const previousPage = () => {
        params["pageIndex"] = params.pageIndex - 1
        handleScreenRequest(params,data) 
      }

      const gotoPage = ((page) => {
          if(Number(page)>=0&&Number(page)<(Number(params["pageCount"]) + 1))
              {
                params["pageIndex"] = (Number(page) - 1)
                //setControlledPageIndex(page)
                handleScreenRequest(params,data) 
              }
          else{
        }}    
      ) 

      const canPreviousPage = (() => { return params.pageIndex < 1 ? 0 : 1 })
      const canNextPage = (() => { return (params.pageIndex + 1) < (Number(params["pageCount"])) ? 1 : 0 })

     // useEffect(()=>handleSubForm(params,toggleSubForm),[toggleSubForm]) //
      const toDelete = (params) => {if(params.index===null||params.index===undefined){alert("please select target record")}
                                      else{setPparams({...params,aud:"delete"})
                                            handleSubForm(params,true)
                                            }
                                  }
  
    return (
     <div>
        <TableGridStyles height={buttonflg ? "840px" : buttonflg === "download" ? "500px" : buttonflg === "import" ? "300px" : "840px"}
          screenwidth={screenwidth} >
          <GridTable  columns={columns}  screenCode={screenCode}
            data={data} dropDownList={dropDownList}
            setChangeData={setChangeData} changeData={changeData}
            //controlledPageIndex={controlledPageIndex} 
            //controlledPageSize={controlledPageSize}
             buttonflg={buttonflg} loading={loading}
            pageSizeList={pageSizeList}  fetch_check={fetch_check} fetchCheck={fetchCheck}
            params={params}
            sortBy={sortBy} filters={filters} groupBy={groupBy} 
            aggregated={aggregated} setAggregated={setAggregated} //skipReset={skipResetRef.current}
            disableFilters={params.disableFilters} toggleSubForm={toggleSubForm}
            hiddenColumns={hiddenColumns} handleScreenRequest={handleScreenRequest} 
            handleFetchRequest={handleFetchRequest} handleSubForm={handleSubForm} handleDataSetRequest={handleDataSetRequest}
            getHeaderProps={column => ({  //セルのサイズ合わせとclick　keyが重複するのを避けるため
              onClick: (e) =>{if(e.ctrlKey){ //sort時はctrlKey　keyが必須
                                switch(column.isSorted){
                                case true:
                                  switch(column.isSortedDesc){
                                    case false:
                                        column.toggleSortBy(true,true)  //sort:true desc:true
                                        return
                                    default:
                                        column.clearSortBy() //sort:false
                                        return
                                      }
                                default: 
                                        column.toggleSortBy(false,true) //sort:true desc:false
                                        return
                                        }
                               }else{if(e.altKey&&params.aud==="view"){let index = aggregated.findIndex(({columnId}) => columnId === column.id) 
                                                  switch(true){
                                                    case /_qty|_amt|_cash/.test(column.id):
                                                        if(index===-1){aggregated[0]= {columnId:column.id,value:"SUM:"}}
                                                          else{if(aggregated[index].value){aggregated[index]= {columnId:column.id,value:null}}
                                                                  else{aggregated[index]= {columnId:column.id,value:"SUM:"}}}
                                                      break
                                                    case /_price/.test(column.id):
                                                        if(index===-1){aggregated[0]= {columnId:column.id,value:"MAX:"}}
                                                          else{switch(aggregated[index].value){
                                                                  case "MAX:":
                                                                      aggregated[index]= {columnId:column.id,value:"MIN:"}
                                                                  case "MIN:":
                                                                      aggregated[index]= {columnId:column.id,value:null}
                                                                  default:
                                                                    aggregated[index]= {columnId:column.id,value:"MAX:"}                                                                    
                                                                }
                                                          }
                                                        break  
                                                    case /date$|_at$/.test(column.id):  //group by  対象
                                                        if(index===-1){aggregated[0]= {columnId:column.id,value:"MM:"}}
                                                              else{switch(aggregated[index].value){
                                                                      case "MM:":
                                                                          aggregated[index]= {columnId:column.id,value:"WW:"}
                                                                      case "WW:":
                                                                          aggregated[index]= {columnId:column.id,value:"DD:"}
                                                                      case "DD:":
                                                                              aggregated[index]= {columnId:column.id,value:null}
                                                                      default:
                                                                        aggregated[index]= {columnId:column.id,value:"MM:"}                                                                    
                                                                    }
                                                              }
                                                        break  
                                                    case /_code/.test(column.id): //group by  対象　code
                                                      column.toggleGroupBy() //
                                                      return
                                                    default: 
                                                      return
                                                  }
                              }
                            }},
             style:{fontSize:cellFontSize(column,'Header')}, 
                          })}
            getCellProps={cell=>({
              style:{fontSize:cellFontSize(cell,'Cell')}, 
            })}
          />
        </TableGridStyles>
           {params.aud !==  'add'&&<div colSpan="10000" className="td" >
               {screenCode===""?"":Number(params["totalCount"])===0?"No Record":
                `Showing ${params.pageIndex * params["pageSize"] + 1} of ~
                 ${Number(params["totalCount"]) < ((params.pageIndex + 1) * params["pageSize"])? 
                  Number(params["totalCount"]) : ((params.pageIndex + 1) * params["pageSize"])} 
                  results of  total ${Number(params["totalCount"])} records`}
          </div>}
      {(Number(params["totalCount"])>0&&!toggleSubForm)&& 
      <span className="pagination">
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
          <button onClick={() => { 
            nextPage() }} disabled={canNextPage() === 0 ? true : false}>
              {'>'}
          </button>{''}
          <button onClick={() => { gotoPage(Number(params["pageCount"])) }} disabled={canNextPage() === 0 ? true : false}>
            {'>>'}
          </button>{' '}
          <span>
            Page{' '}
            <strong>
              {params.pageIndex + 1} of {(Number(params["pageCount"]))}
            </strong>{''}
          </span>
          <span>
              | Go to page:{''}
            <input
              type="number"
              value={params.pageIndex?params.pageIndex + 1:1}
              onChange={e => {
                params.pageIndex = ((Number(e.target.value) - 1))
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
            value={Number(params["pageSize"]||0)}
            onChange={e => {
              //params["pageIndex"]= 1
              params = {...params,pageSize:(Number(e.target.value)),
                          pageIndex:(Math.floor(Number(params["totalCount"])/params["pageSize"]*params.pageIndex))}
              handleScreenRequest(params,data) 
            }}
          >
            {pageSizeList.map(pageSize => (
            <option key={pageSize} value={pageSize}>
              Show {pageSize}
            </option>
            ))  /*menuから呼ばれたときはparams["pageSizeList"]==null　*/}
          </select>
          <span> {" "}</span>
          </span>  /*nextPage等終わり*/}  
      <button onClick={()=>{if(params.index===null||params.index===undefined)
                                {params.index=0}
                                handleSubForm(params,true)
                                    } }
                                disabled={toggleSubForm?true:false}>ToSubForm</button> 
      <span> {" "}</span>
      <button onClick={()=>toDelete(toggleSubForm)} disabled={toggleSubForm?true:false}>Delete</button> 
      <span> {" "}</span>
       
      <button  onClick={()=>{handleSubForm(params,false)}} 
                                    disabled={toggleSubForm?false:true} >Close_subForm</button>
      <p>{hostError}</p>
     
      {toggleSubForm&&<ToSubForm/>}
      
      {screenCode==="r_fieldcodes"&&<p> 修正時には、再起動が必要</p>}
    </div>
    )
}

// Create a default prop getter
const defaultPropGetter = () => ({})

///
///
const GridTable = ({
    columns,
    data,
    dropDownList,setChangeData,changeData,
    fetch_check,
    params,aggregated,
    buttonflg,loading,disableFilters,
    hiddenColumns,handleScreenRequest,
    handleFetchRequest,fetchCheck,toggleSubForm,handleSubForm,handleDataSetRequest,
    setAggregated,
    getHeaderProps = defaultPropGetter,
    //getColumnProps = defaultPropGetter,
    getCellProps = defaultPropGetter,
    //skipReset,       
    }) => { 
  
    // const [dropDownList, setDropDownList] = useState(dropDownListOrg)
  
       
    // useEffect(()=>{   setDropDownList(dropDownListOrg)},
    //                       [dropDownListOrg])

               
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
    

    
  {/*    
    ### 
    ###   同一カラムによるfilter,sortの重複解消処理、filter sortの前の状態表示
    ###
*/}

      useEffect(() => {
        setAllFilters(params.filtered?params.filtered.map((filter)=>{
          return (typeof(filter)==="string"?JSON.parse(filter):filter)}):[]),
 
        setSortBy(params.sortBy?params.sortBy.map((sort)=>{
          return (typeof(sort)==="string"?JSON.parse(sort):sort)}):[])

        setGroupBy(params.groupBy?params.groupBy.map((group)=>{
          return (typeof(group)==="string"?JSON.parse(group):sort)}):[])

        setAggregated(params.aggregated?params.aggregated.map((aggregate)=>{
          return (typeof(aggregate)==="string"?JSON.parse(aggregate):aggregated)}):[])
        },[loading])    
                
    const {
        getTableProps,
        getTableBodyProps,
        headerGroups,
        rows,
        prepareRow, 
        toggleAllRowsSelected, 
        setAllFilters,setSortBy,setGroupBy,
        state:{filters,sortBy,groupBy,selectedRowIds,},  
    } = useTable(
        {
            columns,data,
            changeData, params, dropDownList,
            fetch_check,fetchCheck,
            buttonflg,setChangeData,
            defaultColumn,
            manualPagination: false,
            manualFilters: true,
            manualSortBy: true,
            manualGroupBy: true,
            disableMultiSort: false,
            autoResetSortBy: true,
            autoResetSelectedRows:true,
            autoResetFilters:true,
            disableFilters,
            initialState: {hiddenColumns:hiddenColumns,selectedRowIds:{},
                    },
            handleFetchRequest,handleScreenRequest,toggleSubForm,handleDataSetRequest
    },
    useFilters, //
    useGroupBy,
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
                       if (e.key === "Enter" &&!params.disableFilters&&!toggleSubForm)
                           { 
                             params = {...params,aud:"view",buttonflg:"viewtablereq7",filtered:filters,sortBy:sortBy,groupBy:groupBy,aggregated:aggregated,} 
                             // Apply the header cell props
                             handleScreenRequest(params,data)
                           }else{e.key==="Enter"&&toggleSubForm&&alert("can not use filer or sortBy or groupBy when subForm using")}
                       },
              onClick: (e) =>{
                              }
            })
            } className="tr">
              {headerGroup.headers.map(column => (
                <th {...column.getHeaderProps([getHeaderProps(column),
                                                ])} className="th">
                  <span style={{ backgroundColor:"red"}}>
                    {column.isGrouped ? 'Gr ' :  ''}  
                    {aggregated?aggregated[column.id]?aggregated[column.id]:"":""}
                  </span>
                  {column.render('Header')}
                  <span>
                  {/* Use column.getResizerProps to hook up the events correctly   🛅*/}
                    {column.isSorted ? column.isSortedDesc ? ' 🔽' : ' 🔼' : ''}
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
              prepareRow(row)  //select rowを使用する時必須
              return (
              <tr {...row.getRowProps({
                  style: {
                      backgroundColor: row.isSelected ? 'lime' :
                      params.index === row.index?'lime' :
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
                      if(e.ctrlKey){  //複数行選択
                          if(Object.keys(selectedRowIds).length===0){
                            toggleAllRowsSelected(true)
                            data.map((line,idx) => params["clickIndex"].push({lineId:idx,id:line["id"],
                                                    screenCode:params.screenCode,sNo:line[sNo]})
                            )  
                            params["index"] = -1
                          }else{
                            toggleAllRowsSelected(false)
                            params = {...params,clickIndex:[],index:-1}
                          }
                      }else{
                        if(row.isSelected){
                          row.toggleRowSelected(false)
                            params["clickIndex"].map((click,idx)=>{if(click["lineId"]===row.index){return params["clickIndex"][idx]={}}})
                            params["clickIndex"].map((click,idx)=>{if(click["lineId"]){return params["index"]=click["lineId"]}}
                            )                       
                          }
                        else{
                          row.toggleRowSelected(true)
                          params["clickIndex"].push({lineId:row.index,id:data[row.index]["id"],
                                                            screenCode:params.screenCode,sNo:data[row.index][sNo]})
                          params["index"] = row.index
                        }
                      }
                     // params = {...params,changeData:changeData}
                     toggleSubForm&&handleSubForm(params,toggleSubForm)
                    }
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
          buttonflg: state.second.params.buttonflg,
          loadingOrg: state.second.loading,
          dataOrg: state.second.data,
          params: state.second.params,
          screenCodeOrg:state.second.params.screenCode,
          pageSizeList: state.second.grid_columns_info.pageSizeList,
          columnsOrg: state.second.grid_columns_info.columns_info,
          screenwidth: state.second.grid_columns_info.screenwidth,
          fetch_check: state.second.grid_columns_info.fetch_check,
          dropDownList: state.second.grid_columns_info.dropDownList,
          hiddenColumns: state.second.grid_columns_info.hiddenColumns,
          toggleSubForm:state.second.toggleSubForm,
          hostError: state.second.hostError,
          message:state.second.message,
          screenFlg:ownProps.screenFlg,
       }
    }else{
        return {
          buttonflg: state.screen.params.buttonflg,
          loadingOrg: state.screen.loading,
          dataOrg: state.screen.data,
          params: state.screen.params,
          screenCodeOrg:state.screen.params.screenCode,
          pageSizeList: state.screen.grid_columns_info.pageSizeList,
          columnsOrg: state.screen.grid_columns_info.columns_info,
          screenwidth: state.screen.grid_columns_info.screenwidth,
          fetch_check: state.screen.grid_columns_info.fetch_check,
          dropDownList: state.screen.grid_columns_info.dropDownList,
          hiddenColumns: state.screen.grid_columns_info.hiddenColumns,
          toggleSubForm:state.screen.toggleSubForm,
          hostError: state.screen.hostError,
          message:state.screen.message,
          screenFlg:ownProps.screenFlg,
        }
    }      
}

const mapDispatchToProps = (dispatch, ownProps) => ({
    handleScreenRequest: (params,data) => {
        params = {...params,screenFlg:ownProps.screenFlg}
        if(params.screenFlg === "second"){
          dispatch(SecondConfirm(params,data))
        }else{
          dispatch(ScreenConfirm(params,data))}
      },
    handleFetchRequest: (params) => {
      params = {...params,screenFlg:ownProps.screenFlg}
        if(params.screenFlg === "second"){
          dispatch(SecondFetchRequest(params))
        }else{
          dispatch(FetchRequest(params))}
      },
    handleSubForm: (params,toggleSubForm) => {
      if(params.screenFlg === "second"){
         dispatch(SecondSubForm(toggleSubForm,params))
       }else{
         dispatch(ScreenSubForm(toggleSubForm,params))}      
      },
    handleDataSetRequest: (data,params) => {
        if(params.screenFlg === "second"){
           dispatch(SecondDataSet(data))
         }else{
           dispatch(ScreenDataSet(data))}      
        },
  
})
export default connect(mapStateToProps, mapDispatchToProps)(ScreenGrid7)
