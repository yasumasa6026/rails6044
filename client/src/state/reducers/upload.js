import {  IMPORT_REQUEST,
        UPLOAD_SUCCESS,EXCELTOJSON_SUCCESS,UPLOADFORFIELDSET_REQUEST,
        EXCELCSVIMPORT_REQUEST,SETRESULTS_SUCCESS,MENU_FAILURE,
        // CHANGEUPLOADTITLEEDITABLE_REQUEST,
        LOGOUT_REQUEST} from '../../actions'
const initialValues = {
isEditable:false,
isUpload:false,
isSubmitting:false,
errors:[],
message:null,
importError:false,
}

const uploadreducer =  (state= initialValues , actions) =>{
switch (actions.type) {
  
  case IMPORT_REQUEST:
    return {...state,
        message:null,
        importError:false,
            }
   
   case MENU_FAILURE:
      return {...state,
                 message:actions.errors,
                 importError:actions.importError,
             }               
  
  case UPLOAD_SUCCESS:
    return {...state,
            imageFromController:actions.payload.imageFromController}       

  case EXCELTOJSON_SUCCESS:
      return {...state,
                //newFileName:actions.payload.newFileName, 
                //jsonURL:actions.payload.jsonURL,  
                //data:actions.payload.data, 
          }
case UPLOADFORFIELDSET_REQUEST:  //uploadしrailsで処理した結果
        return {...state,
                jsonfilename: actions.payload.jsonfilename,
                screenCode: actions.payload.screenCode,
    }
    

case EXCELCSVIMPORT_REQUEST:
        return {...state,
          results: actions.payload.results,
          excelfile: actions.payload.excelfile,
          screenCode: actions.payload.screenCode,
          nameToCode: actions.payload.nameToCode,
          importError: actions.payload.importError,
    }    

case SETRESULTS_SUCCESS:
        return {...state,
                results: actions.payload.results,
                complete: actions.payload.complete,
                importError: actions.payload.importError,
           }
                       
  case  LOGOUT_REQUEST:
  return {}  

  default:
    return {...state}
        }
}

export default uploadreducer
