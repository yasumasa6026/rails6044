import {  GANTTCHART_REQUEST,GANTTCHART_SUCCESS,LOGOUT_REQUEST} from '../../actions'
const initialValues = {
}

const ganttchartreducer =  (state= initialValues , actions) =>{
  switch (actions.type) {


    case GANTTCHART_REQUEST:
       return {...state,
        params:actions.payload.params,
        ganttChartData:null,
        message:"loading",
        loading:true,
     }

    case GANTTCHART_SUCCESS:
     return {...state,
      ganttChartData:actions.payload.ganttChartData,
      loading:false,
      message:null,
   }
    case  LOGOUT_REQUEST:
    return {}  

    default:
      return state
  }
}

export default ganttchartreducer