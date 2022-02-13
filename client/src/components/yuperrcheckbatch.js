//規定値はセットされない。
import {yupschema} from '../yupschema'
import {dataCheck7} from './yuperrcheck'
import {onBlurFunc7} from './onblurfunc'
export  function yupErrCheckBatch(lines,screenCode) 
{
    let Yup = require('yup')
    let screenSchema = Yup.object().shape(yupschema[screenCode])
    let importdataCheckMaster = []
    let importErrorCheckMaster = false
    let tblnamechop = screenCode.split("_")[1].slice(0, -1)
    lines.map((line,inx) => {
        if(["add","update","delete"].includes(line["aud"])){
            try{
                line[`confirm`] = true  //rb uploadで confirm=trueのみを対象としているため
                let row = {}
                Object.keys(line).map((fd)=>{
                     if(screenSchema.fields[fd]){  //対象は入力項目のみ
                         row[fd] = line[fd]
                         }
                         return null
                     }
                )
                screenSchema.validateSync(row)
                row = dataCheck7(screenSchema,row) //row:_gridmessageを含む
                Object.keys(screenSchema.fields).map((fd)=>{  // line:_gridmessageを含まない
                    if(row[`${fd}_gridmessage`] !== "ok"){
                          line[`${fd}_gridmessage`] = row[`${fd}_gridmessage`]
                          line[`${tblnamechop}_confirm_gridmessage`] = `x error ${fd}`
                          importErrorCheckMaster = true
                        }else{
                            line = onBlurFunc7(screenCode,line,fd)
                        }
                        return null
                    }
                )
            }      
            catch(err){  //jsonにはxxxx_gridmessageはない。
                line[`${tblnamechop}_confirm_gridmessage`] = `y error ${err}`
                line[`confirm`] = false
                importErrorCheckMaster = true
            }
        }else{
            if(line["aud"]==="aud"){
                }else{
                    line[`confirm`] = "missing aud--> add OR update OR delete "
                    importErrorCheckMaster = true
            }   
        }  
        importdataCheckMaster.push(line) 
        return {importdataCheckMaster,importErrorCheckMaster}
    })
    return {importdataCheckMaster,importErrorCheckMaster}
}  




  