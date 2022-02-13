export  function yupErrCheck (schema,field,linedata) {
  let mfield 
  try{schema.validateSync(linedata)
    switch(field) {
    case "confirm"  :  //1行すべてのチェック})
            linedata.confirm = null
            linedata.confirm_gridmessage = "doing"
            Object.keys(linedata).map((fd)=>{
                if(schema.fields[field]){  //対象は入力項目のみ
                  linedata = dataCheck7(schema,fd,linedata)
                  if(linedata[`${fd}_gridmessage`] !== "ok"){
                      linedata.confirm = false
                      linedata.confirm_gridmessage =  `err ${fd}　${linedata[`${fd}_gridmessage`]}　`
                    }
                }  
                return linedata
              }
            )
            return linedata
    default: 
            dataCheck7(schema,linedata) 
            return linedata
    }
  }      
  catch(err){
    switch(field){
    case "confirm"  :  //1行すべてのチェック
              linedata.confirm = false
              mfield = err.path+"_gridmessage"
              linedata[mfield] = err.errors.join(",")
              linedata.confirm_gridmessage = `error ${err.path}　${linedata[mfield]}　`
              linedata["errPath"] = err.path
              return linedata
    default:  
              mfield = field+"_gridmessage"
              linedata[mfield] = " error " + err.errors.join(",")
              return linedata
        }
  }
}  


//未実施　yupでは数値項目で　"スペース999" がエラーにならない。

// yupでは　2019/12/32等がエラーにならない。　2020/01/01になってしまう
export function dataCheck7(schema,updateRow){ 
  let confirm_gridmessage 
  Object.keys(updateRow).map((field)=>{
    if(schema.fields[field]){
      switch(schema.fields[field]["_type"]){
        case "date" :
          let moment = require('moment')
          let yyyymmdd = updateRow[field].split(/-|\/|\s/)
          if(yyyymmdd[1] === undefined){updateRow[`${field}_gridmessage`] = "error not date type yyyy/mm/dd or yyyy-mm-dd"
                                        confirm_gridmessage =  updateRow[`${field}_gridmessage`] + confirm_gridmessage}
          else
          {
              if(yyyymmdd[1].length===1){yyyymmdd[1] = "0"+yyyymmdd[1]}
              if(yyyymmdd[2] === undefined ){yyyymmdd[2] = "01"
                                            updateRow[field] = yyyymmdd[0]+"-"+yyyymmdd[1]+"-"+yyyymmdd[2]}
              //if(/(\d){4}\/|-\d+\d+\/|-\d+\d+/.test(updateRow[field])){ // "/"や2019-2-30 だとうるう年等のチェックができない。
              if(yyyymmdd.length===3){ // 
                  if(moment(yyyymmdd[0]+"-"+yyyymmdd[1]+"-"+yyyymmdd[2]).isValid()){
                    updateRow[`${field}_gridmessage`] = "ok"
                  }else{
                    updateRow[`${field}_gridmessage`] = "error not date "
                    confirm_gridmessage =  updateRow[`${field}_gridmessage`] + confirm_gridmessage
                  }
              }else
              {
                if(yyyymmdd.length===4){
                  let hhmiss = updateRow[field].split(":")
                  if(hhmiss[0].length===1){hhmiss[0] = "0"+hhmiss[0]}
                  if(/^[0-2][0-4]$/.test(hhmiss[0])){
                    if(hhmiss[1]===undefined){
                      updateRow[`${field}_gridmessage`] = "ok"
                    }else
                    {
                      if(hhmiss[1].length===1){hhmiss[1] = "0"+hhmiss[1]}
                      if(/^[0-5][0-9]$/.test(hhmiss[1])){
                        if(hhmiss[2]===undefined){
                          updateRow[`${field}_gridmessage`] = "ok"
                        }else
                        {
                          if(/^[0-5][0-9]$/.test(hhmiss[2])){
                            updateRow[`${field}_gridmessage`] = "ok"
                          }else
                          {
                            updateRow[`${field}_gridmessage`] = "error not date type ss>=00 and ss<60"
                          }
                        }
                        }else
                        {
                              updateRow[`${field}_gridmessage`] = "error not date type hh>=00 and hh<=24"
                              confirm_gridmessage =  updateRow[`${field}_gridmessage`] + confirm_gridmessage}
                    }
                  }else
                  {
                    updateRow[`${field}_gridmessage`] = "error not date type hh>=00 and hh<=24"
                    confirm_gridmessage =  updateRow[`${field}_gridmessage`] + confirm_gridmessage
                  }
                }else
                {//length>4
                      updateRow[`${field}_gridmessage`] = "error not date type yyyy/mm/dd or yyyy/mm/dd hh:mi:ss"
                      confirm_gridmessage =  updateRow[`${field}_gridmessage`] + confirm_gridmessage
                }   
              } 
           }                            
          break     
        default:
          switch(field){
            case "screen_rowlist":  //一画面に表示できる行数をセットする項目の指定が正しくできているか？
                updateRow[field].split(',').map((rowcnt)=>{
                    if(isNaN(rowcnt)){ 
                        updateRow[`${field}_gridmessage`] = "error  must be xxx,yyy,zzz :xxx-->numeric"
                        confirm_gridmessage =  updateRow[`${field}_gridmessage`] + confirm_gridmessage
                      }else{
                        if(updateRow[`${field}_gridmessage`]){
                            if(/error/.test(updateRow[`${field}_gridmessage`])){}
                            else{updateRow[`${field}_gridmessage`] = "ok"}
                             }
                        else{updateRow[`${field}_gridmessage`] = "ok"}
                      } //エラーセット
                    return updateRow
                })
              break
            case "screenfield_indisp":  //tipが機能しない。
                if(/_code/.test(updateRow["pobject_code_sfd"])&updateRow["screenfield_editable"]!=="0")
                    {if(updateRow["screenfield_indisp"]==="1")
                            {updateRow[`${field}_gridmessage`] = "ok"}
                            else{updateRow["screenfield_indisp_gridmessage"] = "error!  must be Required"
                            confirm_gridmessage =  updateRow[`${field}_gridmessage`] + confirm_gridmessage}
                          }else{
                            updateRow[`${field}_gridmessage`] = "ok"}
                break
            default:
                updateRow[`${field}_gridmessage`] = "ok"
       }
      }
    }else{  //yupに登録されてないとき
      updateRow[`${field}_gridmessage`] = `error  field:${field} not exists in yupschema. please creat 'yupschema' by yup button `
    }     
    return  updateRow  
  })
  
  updateRow["confirm_gridmessage"] = confirm_gridmessage
  return updateRow   
}   

