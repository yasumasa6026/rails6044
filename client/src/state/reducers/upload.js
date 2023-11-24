import {  IMPORTEXCEL_REQUEST,IMPORTEXCEL_FAILURE,IMPORTEXCEL_SUCCESS,LOGOUT_REQUEST} from '../../actions'
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
            importErrorCheckMaster:false,
            normalEnd:false,
            loading : true,
            idx:null,
        }
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
                importErrorCheckMaster:true,
                normalEnd:false
            }    

                      
    case  LOGOUT_REQUEST:
        return {}  
             
        
    default:
        return {...state,
            errHeader:"",
            importError:null,
            formatError:null,
            errMessage:"",
            importErrorCheckMaster:false,
            normalEnd:false
        }
    }
}

export default uploadreducer
