import React from 'react'
import { connect } from 'react-redux'

const Download = ({screenName,filtered,totalCount,}) => {
            
          
        return(                 
        <div>
        <form  > 
           <p>DownLoad ScreenName:{screenName}</p>
           <p>select condition </p>
           {filtered.length===0?<p>all data selected </p>: filtered.map((val,idx) =>{
                                                    return <p key={idx}>{val.id} : {val.value}</p>
           })}
           <p>total record count {totalCount}</p>
        </form> 
        </div> 
        )             
}
  
    const mapStateToProps = (state,ownProps)  =>({  
      button:state.button,
      screenCode:state.screen.params.screenCode,
      screenName:state.screen.params.screenName,
      filtered:state.button.filtered?state.download.filtered:[], 
      totalCount:state.button.totalCount,
      errors:state.button.errors,
    })
    
    const mapDispatchToProps = () => ({
    })
    
export  default  connect(mapStateToProps,mapDispatchToProps)(Download)