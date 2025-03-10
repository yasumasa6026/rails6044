import {  GANTTCHART_REQUEST,GANTTCHART_SUCCESS,
          UPDATENDITM_REQUEST,UPDATEALLOC_REQUEST,LOGOUT_REQUEST,} from '../../actions'

const today = new Date() // 今日の日付
const tomorrow = new Date(today) // 今日の日付をコピー
tomorrow.setDate(today.getDate() + 1) // 日付を1日進める
const initialValues = {tasks:[{id:"",name:"",type:"proect",progress:0,dependencies:[],
                        start:new Date,end:tomorrow}],
                        loading:true,isChecked:true}

const ganttreducer =  (state= initialValues , actions) =>{
  switch (actions.type) {

    case GANTTCHART_REQUEST:
     return {...state,
      tasks:[{id:"",name:"",type:"proect",progress:50,dependencies:[],
              start:new Date,end:tomorrow}],
      loading:true,
      message:null,
   }

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
       tasks:[{id:"",name:"",type:"proect",progress:100,dependencies:[],
                start:new Date,end:tomorrow}],
    }
  }
}

export default ganttreducer