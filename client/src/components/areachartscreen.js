
import React, { useMemo } from "react"
import { connect} from 'react-redux'
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts'

// const data1 = [
//   {
//     name: 'Page A',
//     uv: 4000,
//     pv: 2400,
//     amt: 2400,
//   },
//   {
//     name: 'Page B',
//     uv: 3000,
//     pv: 1398,
//     amt: 2210,
//   },
//   {
//     name: 'Page C',
//     uv: 2000,
//     pv: 9800,
//     amt: 2290,
//   },
//   {
//     name: 'Page D',
//     uv: 2780,
//     pv: 3908,
//     amt: 2000,
//   },
//   {
//     name: 'Page E',
//     uv: 1890,
//     pv: 4800,
//     amt: 2181,
//   },
//   {
//     name: 'Page F',
//     uv: 2390,
//     pv: 3800,
//     amt: 2500,
//   },
//   {
//     name: 'Page G',
//     uv: 3490,
//     pv: 4300,
//     amt: 2100,
//   },
// ];

const AreaChartScreen = ({data,screenCode}) => {
    const areadata  = useMemo(() => [])
    let nameKeyDuedate = screenCode.split("_")[1].slice(0,-1) + "_duedate"
    let sch 
    let ord 
    let act 
    switch (true) {
            case /payalls/.test(screenCode): 
              sch = screenCode.split("_")[1].slice(0,-1) + "_amt_sch"
              ord = screenCode.split("_")[1].slice(0,-1) + "_amt"
              act = screenCode.split("_")[1].slice(0,-1) + "_cash"
              break   
            case /billalls/.test(screenCode):
              sch = screenCode.split("_")[1].slice(0,-1) + "_amt_sch"
              ord = screenCode.split("_")[1].slice(0,-1) + "_amt"
              act = screenCode.split("_")[1].slice(0,-1) + "_cash"
              break   
            default:
              nameKeyLocaode = ""   
      }
      data.map((rec,idx) => {
           return areadata[idx] = {name:rec[nameKeyDuedate] ,
                        sch:parseInt(rec[sch].replace(/,/g, "")),ord:parseInt(rec[ord].replace(/,/g, "")),act:parseInt(rec[act].replace(/,/g, ""))}
    })  
    return (
      <div>
        AreaChartScreen
  {/*<ResponsiveContainer width="100%" height="100%">  これがあると、なぜかひょうじされない。*/}
        <AreaChart
          width={1000}
          height={400}
          data={areadata}
          margin={{
            top: 10,
            right: 30,
            left: 100,
            bottom: 0,
          }}
        >
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="name" />
          <YAxis />
          <Tooltip />
          <Area type="monotone" dataKey="sch" stackId="1" stroke="#8884d8" fill="#8884d8" />
          <Area type="monotone" dataKey="ord" stackId="1" stroke="#82ca9d" fill="#82ca9d" />
          <Area type="monotone" dataKey="act" stackId="1" stroke="#ffc658" fill="#ffc658" />
        </AreaChart>
     {/* </ResponsiveContainer> */}
      </div>
    )
  }

  const  mapStateToProps = (state,ownProps) =>{
        return{
          screenCode:state.screen.params.screenCode,
          data:state.screen.data ,
        }
   // originalreq:state.screen.originalreq,map
  }
  
  export default connect(mapStateToProps,)(AreaChartScreen)