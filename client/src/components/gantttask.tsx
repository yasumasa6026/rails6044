//https://react-redux.js.org/using-react-redux/usage-with-typescript
import React,{useEffect, useState} from "react"
import { connect,ConnectedProps} from 'react-redux'
import { Gantt, Task,  ViewMode,  } from 'gantt-task-react'
import "gantt-task-react/dist/index.css"
import  {ViewSwitcher} from "./gantttaskview"
//import {UpdateNditmRequest} from '../actions'

const GanttTask = (props:Props) => {
        const [view, setView] = useState(ViewMode.Day)
        const [tasks, setTasks] = useState(props.tasks)
        const [tLen, setTlen] = useState(props.tasks.length)
        const [updateReq, setUpdateReq] = useState(false)
        const [ausFlow, setAusFlow] = useState(0)
        useEffect(()=> {setTasks(props.tasks),
                        setTlen(props.tasks.length)},[props.loading])
        const [isChecked, setIsChecked] = useState(true)
        let columnWidth 
        switch(view){
        case ViewMode.Month:
            columnWidth = 300
            break
        case ViewMode.Week:
            columnWidth = 250
            break
        case ViewMode.Day:
            columnWidth = 65
            break
        case ViewMode.Hour:
            columnWidth = 20
            break
        }

        
        // const onDateChange = (task:Task) => {
        // //  let newTasks = tasks.map(t => (t.id === task.id ? task : t))
        // //   if (task.project) {
        // //     const [start, end] = getStartEndDateForProject(newTasks, task.project)
        // //     const project = newTasks[newTasks.findIndex(t => t.id === task.project)]
        // //     if (
        // //       project.start.getTime() !== start.getTime() ||
        // //       project.end.getTime() !== end.getTime()
        // //     ) {
        // //       const changedProject = { ...project, start, end }
        // //       newTasks = newTasks.map(t =>
        // //         t.id === task.project ? changedProject : t
        // //       )
        // //     }
        // //   }
        // //  setTasks(newTasks)
        //   alert("onDateChange")
        // }
        
        // const handleTaskDelete = (task) => {
        //     const conf = window.confirm("Are you sure about " + task.name + " ?")
        //     if (conf) {
        //         setTasks(tasks.filter(t => t.id !== task.id))
        //     }
        //     return conf
        // }

        const onClick = (task:Task) => {
            if(props.buttonflg==="reversechart")
                {alert("not support")}
            else{if(task.id)  //ganttchart_controlへ
                    {   
                        setUpdateReq(true)
                        setTlen(0) //ganttchartを絞る
                        let params = {}
                        switch (true){   
                        case /itm/.test(props.screenCode):
                            switch(ausFlow){
                            case 0:
                                params = {task:task,screenCode:props.screenCode,buttonflg:"updateNditm",
                                            aud:"update",}
                                setAusFlow(1)
                                break
                            case 1:
                                params = {task:task,screenCode:props.screenCode,buttonflg:"updateNditm",
                                            aud:"add",}
                                setAusFlow(2)
                                break
                            case 2:
                                params = {task:task,screenCode:props.screenCode,buttonflg:"updateNditm",
                                            aud:"search",}
                                setAusFlow(0)
                                break
                            }
                            props.UpdateNditmRequest(params)
                            break
                        case /ords|schs/.test(props.screenCode):
                            let contents = []
                            contents = task.name.split(",")
                            switch(true){
                            case /schs/.test(contents[0]):
                                switch(ausFlow){
                                    case 0:
                                        params = {task:task,screenCode:props.screenCode,buttonflg:"updateTrngantt",
                                                    aud:"update_trngantts",}
                                        setAusFlow(1)
                                        break
                                    case 1:
                                         params = {task:task,screenCode:props.screenCode,buttonflg:"updateTrngantt",
                                               aud:"update_free_to_alloc",}
                                         setAusFlow(2)
                                         break
                                    case 2: //add childs schs
                                        params = {task:task,screenCode:props.screenCode,buttonflg:"updateTrngantt",
                                                 aud:"insert_trngantts",}  //add chils schs
                                        setAusFlow(0)
                                        break
                                }
                                break
                            default:
                                switch(ausFlow){
                                    case 0:  //ords  ==> schs (free 作成)
                                        params = {task:task,screenCode:props.screenCode,buttonflg:"updateTrngantt",
                                            aud:"update_alloctbls",}
                                        setAusFlow(1)
                                        break
                                    case 1:   //add childs schs
                                        params = {task:task,screenCode:props.screenCode,buttonflg:"updateTrngantt",
                                                 aud:"insert_trngantts",}
                                        setAusFlow(0)
                                        break
                                }
                            }    
                            props.UpdateAllocRequest(params)
                            break
                        }
                    //second screen 専用
                    }
        }
        // const onDoubleClick = (task:Task) => {
        // }
        }
    return (
        <div>
            <ViewSwitcher
                onViewModeChange={viewMode => setView(viewMode)}
                onViewListChange={setIsChecked}
                isChecked={isChecked}/>
            <Gantt
                tasks={tasks}
                viewMode={view}
            //    onDateChange={onDateChange}
            //    onTaskDelete={onTaskDelete}
                onClick={onClick}
            //    onDoubleClick={onDoubleClick}  //onClickと共存できない。
                ganttHeight={updateReq?300:tLen>5?300+(tLen-5)*50:300}
                listCellWidth={isChecked ? "155px" : ""}
                barBackgroundSelectedColor={"#FFFF00"}
            />
        </div>
    )
 }

 interface RootState  {
    gantt :{
        tasks:Task[],
        loading:boolean,
      //  viewMode:ViewMode,
      //  isChecked:boolean,
        screenCode:string,
        buttonflg:string,
    },
}

 const mapState = (state:RootState) => ({
                 tasks: state.gantt.tasks,
                 loading: state.gantt.loading,
        //         viewMode: state.gantt.viewMode,
        //         isChecked: state.gantt.isChecked,
                 screenCode: state.gantt.screenCode,
                 buttonflg: state.gantt.buttonflg,
 })

 const  mapDispatch = { UpdateNditmRequest: (params:Object) =>
                             ({ type:'UPDATENDITM_REQUEST',payload:{params}}),
                        UpdateAllocRequest: (params:Object) =>
                             ({ type:'UPDATEALLOC_REQUEST',payload:{params}}),
}

 type PropsFromRedux = ConnectedProps<typeof connector>
 
 interface Props extends PropsFromRedux {
         tasks:Task[],
         loading:boolean,
      //   viewMode:ViewMode,
      //   isChecked:boolean,
        screenCode:string,
        buttonflg:string,
   }

   const connector = connect(mapState, mapDispatch)

export default connector(GanttTask)