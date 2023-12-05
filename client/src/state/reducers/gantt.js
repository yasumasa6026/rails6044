import {  GANTTCHART_SUCCESS,
          UPDATENDITM_REQUEST,UPDATEALLOC_REQUEST,LOGOUT_REQUEST,} from '../../actions'
const initialValues = {tasks:[],loading:true,isChecked:true}

const ganttreducer =  (state= initialValues , actions) =>{
  switch (actions.type) {

    case GANTTCHART_SUCCESS:
     return {...state,
      tasks:actions.payload.tasks,
     // viewMode:actions.payload.viewMode,
      screenCode:actions.payload.screenCode,
      buttonflg:actions.payload.buttonflg,
      loading:false,
      message:null,
   }

   
  case UPDATENDITM_REQUEST:
     return {...state,
       loading:true,
     }

  case UPDATEALLOC_REQUEST:
        return {...state,
          loading:true,
        }

    case  LOGOUT_REQUEST:
    return {}  

    default:
      return {...state,
       loading:true,
       tasks:[{start:new Date,end:new Date}],
    }
  }
}

export default ganttreducer