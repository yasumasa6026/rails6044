import {  IMPORTEXCEL_REQUEST,IMPORTEXCEL_FAILURE,IMPORTEXCEL_SUCCESS,INITIMPORT_REQUEST,
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
   

    case IMPORTEXCEL_REQUEST:
        return {...state,
            excelfile: actions.payload.excelfile,
            params: actions.payload.params,
            nameToCode: actions.payload.nameToCode,
            errMessage:"",
            formatError:null,
            importErrorCheckMaster:null,
            normalEnd:false,
            idx:null,
        }    

                      
    case  LOGOUT_REQUEST:
            return {}  

    case IMPORTEXCEL_SUCCESS:
        return {...state,
                    params:{token:actions.params.token,
                            client:actions.params.client,
                            uid:actions.params.uid},
                            idx:actions.idx,
                            errHeader:null,
                            importError:false,
                            errMessage:"",
                            normalEnd:true,
            }                

    case IMPORTEXCEL_FAILURE:
        return {...state,
                errHeader:actions.errHeader,
                importError:true,
                formatError:actions.formatError,
                errMessage:actions.errMessage,
                importErrorCheckMaster:actions.importErrorCheckMaster,
                normalEnd:false
            }                
            
        
    default:
        return {...state,
            errHeader:"",
            importError:null,
            formatError:null,
            errMessage:"",
            importErrorCheckMaster:null,
            normalEnd:false
        }
    }
}

export default uploadreducer
