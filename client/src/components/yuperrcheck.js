export  function yupErrCheck (schema,field,linedata) {
  let mfield 
  mfield = field+"_gridmessage"
  try{
      if(field==="confirm"){schema.validateSync(linedata)
            linedata.confirm_gridmessage = "doing"}
      else{schema.validateSync({[field]:linedata[field]})
            linedata[mfield] = "ok"
            linedata.confirm_gridmessage = "ok"}  
      if(linedata.confirm_gridmessage === "ok"){
                      dataCheck7(schema,field,linedata) 
            }
      if(linedata.confirm_gridmessage === "doing"){
                      Object.keys(linedata).map((fd)=>{
                        dataCheck7(schema,fd,{[fd]:linedata[fd]})             }
                      ) 
            }    
      return linedata
  }      
  catch(err){
    linedata.confirm = false
              linedata[mfield] = err.errors.join(",")
              linedata["confirm_gridmessage"] = " error " + err.errors.join(",")
              return linedata
  }
} 

//未実施　yupでは数値項目で　"スペース999" がエラーにならない。

// yupでは　2019/12/32等がエラーにならない。　2020/01/01になってしまう
export function dataCheck7(schema,field,linedata){ 
    if(schema.fields[field]){
      linedata[`${field}_gridmessage`] = "ok"
      if(schema.fields[field]["_type"]==="date"){
          let yyyymmdd = []
          let stryyyymmdd = linedata[field]
          try{yyyymmdd = stryyyymmdd?.split(/\/|-|\s|T|:|\./)
          }catch(e) //tryを使用しないとTypeError: Cannot read properties of undefined (reading 'map')が発生する。
            {console.log(" dataCheck7 " &&e)}
          [3,4,5].map((val,idx)=>{if(yyyymmdd[val]===undefined){yyyymmdd[val] = "0"}})  //[3,4,5] 時間:分:秒
          if(checkDate(Number(yyyymmdd[0]), Number(yyyymmdd[1]), Number(yyyymmdd[2]))){
            if(Number(yyyymmdd[3])>=0&&Number(yyyymmdd[3])<=24){
              if(Number(yyyymmdd[4])>=0&&Number(yyyymmdd[4])<=59&&yyyymmdd[5]>=0&&Number(yyyymmdd[5])<=59){
                    linedata[`${field}_gridmessage`] = "ok"
                    linedata[field] = yyyymmdd[0]+"/"+yyyymmdd[1]+"/"+yyyymmdd[2]+" "+yyyymmdd[3]+":"+yyyymmdd[4]+":"+yyyymmdd[5]
                }else{
                      linedata[`${field}_gridmessage`] = "  mi:ss: 0:0<= mi:ss <= 59:59"
                      }
            }else{
                  linedata[`${field}_gridmessage`] = " hour:  0<= hh24 <= 24"
                } 
          }else{
                linedata[`${field}_gridmessage`] = " not date type yyyy/mm/dd  or yyyy-mm-dd"
          }       
      }else{
          switch(field){
            case "screen_rowlist":  //一画面に表示できる行数をセットする項目の指定が正しくできているか？
                linedata[field].split(',').map((rowcnt)=>{
                    if(isNaN(rowcnt)){ 
                        linedata[`${field}_gridmessage`] = " must be xxx,yyy,zzz :xxx-->numeric"
                      }else{
                        if(linedata[`${field}_gridmessage`]){
                            if(/error/.test(linedata[`${field}_gridmessage`])){}
                            else{linedata[`${field}_gridmessage`] = "ok"}
                             }
                        else{linedata[`${field}_gridmessage`] = "ok"}
                      } //エラーセット
                    return linedata
                })
              break
            case "screenfield_indisp":  //変更可能な　/_code/は必須項目。tipが機能しない。
                if(/_code/.test(linedata["pobject_code_sfd"])&&String(linedata["screenfield_editable"])==="1")
                    {if(String(linedata["screenfield_indisp"])==="1") //excelが数字を自動変換してしまう
                            {linedata[`${field}_gridmessage`] = "ok"}
                      else{linedata["screenfield_indisp_gridmessage"] = ` must be Required(indisp===1) `
                            }
                }else{
                            linedata[`${field}_gridmessage`] = "ok"}
              break
            default:
              break
          }
         }
       return linedata
    }else{  //yupに登録されてないとき
      linedata[`${field}_gridmessage`] = ` field:${field} not exists in yupschema. please creat 'yupschema' by yup button `
    }
}

function checkDate(year, month, day) {
	if (!year || !month || !day) return false
	if (!String(year).match(/^[0-9]{4}$/) || !String(month).match(/^[0-9]{1,2}$/) || !String(day).match(/^[0-9]{1,2}$/)) return false

	let dateObj      = new Date(year, month - 1, day),
	    dateObjStr   = dateObj.getFullYear() + '' + (dateObj.getMonth() + 1) + '' + dateObj.getDate(),
	    checkDateStr = year + '' + month + '' + day

	if (dateObjStr === checkDateStr) return true

	return false
}
