export  function yupErrCheck (schema,field,linedata) {
  let mfield 
  try{
      if(field==="confirm"){schema.validateSync(linedata)
            linedata["confirm_gridmessage"] = "doing"
            let dclinedata = {}
            Object.keys(linedata).map((fd)=>{
                mfield = fd+"_gridmessage"
                if(fd!=="confirm_gridmessage"){
                    dclinedata = dataCheck7(schema,fd,{[fd]:linedata[fd]})
                    linedata["confirm_gridmessage"] = (linedata["confirm_gridmessage"] === "doing" ? dclinedata[mfield]:
                            linedata["confirm_gridmessage"] === "ok" ?  dclinedata[mfield] : linedata["confirm_gridmessage"] + dclinedata[mfield]) 
                    linedata[mfield] = dclinedata[mfield]
                }
             })
      }
      else{schema.validateSync({[field]:linedata[field]})
            if(linedata.confirm_gridmessage === "ok"){
                       dataCheck7(schema,field,linedata) 
                }
         }  
      // if(linedata.confirm_gridmessage === "doing"){
      //                 Object.keys(linedata).map((fd)=>{
      //                  dataCheck7(schema,fd,{[fd]:linedata[fd]})             }
      //                 ) 
      //       }    
      return linedata
   }      
    catch(err){
      linedata.confirm = false
                linedata[`${field}_gridmessage`] =  err.errors?" error " + err.errors.join(","):" error yupErrCheck"
                linedata["confirm_gridmessage"] = err.errors?" error " + err.errors.join(","):" error yupErrCheck"
                linedata["errPath"] = field
                return linedata
    }
} 

//未実施　yupでは数値項目で　"スペース999" がエラーにならない。

// yupでは　2019/12/32等がエラーにならない。　2020/01/01になってしまう
export function dataCheck7(schema,field,linedata){ 
    let  mfield = field+"_gridmessage"
    let yyyymmdd = []
    if(schema.fields[field]){
      linedata[mfield] = "ok"
      if(schema.fields[field]["_type"]==="date"){
          let nval
          yyyymmdd =  linedata[field].split(/\/|-|\s|T|:|\./)
          yyyymmdd = [0,1,2,3,4,5].map((val,idx)=>{  //[3,4,5] 時間:分:秒
          nval =  (yyyymmdd[idx]   === undefined ? 0 : Number(yyyymmdd[idx] ) )
            switch(idx){
              case 0:  ///yyyy
                  linedata[field]=String(nval)+"-"
                  linedata[mfield] = "ok"
                  linedata[mfield] =  (isNaN(nval) ? "1 error yyyy:20xx":nval>2099||nval< 2000 ? "2 error yyyy:20xx" : linedata[mfield] )
                  break
              case 1:  ///mm
                  linedata[field]= linedata[field]+String(nval)+"-"
                  linedata[mfield] = (isNaN(nval) ?  " error MM:1-12":nval>12||nval<1 ? " error MM:1-12":linedata[mfield])
                  break
              case 2:   ///Day
                 let daysInMonth = [31, isLeapYear(Number(yyyymmdd[0])) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
                 linedata[field]=linedata[field]+String(nval)+" "
                 linedata[mfield] = (isNaN(nval) ? " error DD:1-31":nval>daysInMonth[yyyymmdd[1] - 1]||nval<1 ? ` error DD:1-${daysInMonth[yyyymmdd[1] - 1]}`: linedata[mfield])
                 break
              case 3:  ///Hour
                  linedata[field]=linedata[field]+String(nval)+":"
                  linedata[mfield] = (isNaN(nval)?" error hour:  0-24":nval>24||nval<0?" error hour: 0-24":linedata[mfield])
                  break
              case 4:  ///minitus
                  linedata[field]=linedata[field]+String(nval)+":"
                  linedata[mfield] = (isNaN(nval)? " error min:  0-59":nval>59||nval<0?" error min: 0-59":linedata[mfield] )
                  break
              case 5:  ///second
                  linedata[field]=linedata[field]+String(nval)
                  linedata[mfield] = (isNaN(nval)? " error second:  0-59":nval>59||nval<0?" error second: 0-59":linedata[mfield] )
                  break}})
              linedata[field] = linedata[field].replace(" 0:0:0","")
      }else{
          switch(field){
            case "screen_rowlist":  //一画面に表示できる行数をセットする項目の指定が正しくできているか？
                linedata[field].split(',').map((rowcnt)=>{
                    if(isNaN(rowcnt)){ 
                        linedata[mfield] = " must be xxx,yyy,zzz :xxx-->numeric"
                      }else{
                        if(linedata[mfield]){
                            if(/error/.test(linedata[mfield])){linedata[mfield] = " not numeric"}
                            else{linedata[mfield] = "ok"}
                             }
                        else{linedata[mfield] = "ok"}
                      } //エラーセット
                    return linedata
                })
              break
            case "screenfield_indisp":  //変更可能な　/_code/は必須項目。tipが機能しない。
                if(/_code/.test(linedata["pobject_code_sfd"])&&String(linedata["screenfield_editable"])==="1")
                    {if(String(linedata["screenfield_indisp"])==="1") //excelが数字を自動変換してしまう
                            {linedata[mfield] = "ok"}
                      else{linedata[mfield] = ` must be Required(indisp===1) `
                            }
                }else{
                            linedata[mfield] = "ok"}
              break
            default:
              linedata[mfield] = "ok"
              break
          }
         }
    }else{  //yupに登録されてないとき
      linedata[mfield] = ` field:${field} not exists in yupschema. please creat 'yupschema' by yup button `
    }
    return linedata
}

// function checkDate(year, month, day) {// 月ごとの最大日数
// 	if (!year || !month || !day){return false}
//   const daysInMonth = [31, isLeapYear(year) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
//   if (year < 2000 || year > 2099 || day < 0 || day >  daysInMonth[month - 1] ){return false} 
// 	//if (!String(year).match(/^[0-9]{4}$/) || !String(month).match(/^[0-9]{1,2}$/) || !String(day).match(/^[0-9]{1,2}$/)) return false

// 	let dateObj      = new Date(year, month - 1, day),
// 	    dateObjStr   = dateObj.getFullYear() + '' + (dateObj.getMonth() + 1) + '' + dateObj.getDate(),
// 	    checkDateStr = year + '' + month + '' + day

// 	if (dateObjStr === checkDateStr){return true}else{return false}
// }

// うるう年の判定
function isLeapYear(year) {
  return (year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0)
}
