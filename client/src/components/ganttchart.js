import React from 'react'
import { connect } from 'react-redux'
import Chart from "react-google-charts"
//import {ChangeUploadableRequest,ChangeUnUploadRequest} from '../actions'

const GanttChart = ({ ganttChartData,loading,message}) => {

  const columns = [
    { type: "string", label: "Task ID" },
    { type: "string", label: "Task Name" },
    { type: "date", label: "Start Date" },
    { type: "date", label: "End Date" },
    { type: "number", label: "Duration" },
    { type: "number", label: "Percent Complete" },
    { type: "string", label: "Dependencies" },
  ]

  return(     
    <div style={{ display: 'flex', maxWidth: 900 }}>
    {loading?
       <p> please wait {message}</p> 
       :
       <Chart
          chartType="Gantt"
         //data={[columns,parseTime(ganttChartData)]}
         data={[columns,...ganttChartData]}
          width="100%"
          height="200%"
          legendToggle
          options={{
              height: 1000,
              gantt: {
                      defaultStartDateMillis: new Date(2019,6,1),
                      arrow:{spaceAfter:5,
                              //color:"#58f",
                              width:1,
                              angle:45,
                              radius:180,
                      }
                    },
                }}
        />
    } 
     </div>   
    )
  }


//const mapDispatchToProps = dispatch => ({
//  })
  
const mapStateToProps = state =>({
      ganttChartData:state.ganttchart.ganttChartData,
      loading:state.ganttchart.loading,
      message:state.ganttchart.message,    
  })
  

export default  connect(mapStateToProps,null)(GanttChart)