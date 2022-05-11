import React from 'react'
import { connect } from 'react-redux'

const Download = ({screenName,filtered,totalCount,}) => {
            
          
        return(                 
        <div>
        <form  > 
           <p>export Table:{screenName}</p>
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
      filtered:state.download.filtered?state.download.filtered:[], 
      totalCount:state.download.totalCount,
      errors:state.download.errors,
    })
    
    const mapDispatchToProps = () => ({
    })
    
export  default  connect(mapStateToProps,mapDispatchToProps)(Download)