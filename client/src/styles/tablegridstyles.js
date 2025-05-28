import styled from 'styled-components'

export const TableGridStyles = styled.div`
padding: 1rem;
${'' /* These styles are suggested for the table fill all available space in its containing element */}
display: block;
${'' /* These styles are required for a horizontaly scrollable table overflow */}

.table {
  border-spacing: 0;
  border: 1px solid black;
}

  .thead {
    ${'' /* These styles are required for a scrollable body to align with the header properly */}
    width:${props => props.screenwidth}px 
  }

  .tbody {
    ${'' /* These styles are required for a scrollable table body */}
    width:${props => props.screenwidth + 25}px
    overflow-y: hidden;
    overflow-x: scroll;
    .tr{ height: 35px;
        ${ /*white-space: nowrap;折り返し禁止*/ ' '}
      }
  }

  .tr {
    :last-child {
      .td {
        border-bottom: 0;
      }
    }
    border-top: 1px solid black;
    border-bottom: 1px solid black;
  }


  .th {
    height:55px;
    width:100%;
    word-wrap: break-word;
    input { width:95%;
             height:35%;
             position: absolute;
             top: ;
             bottom: ;
             left: ;
             right: ;
             top: 50%;
             left: 0%;
     }
     select { width:95%;
              height:45%;
              position: absolute;
              top: ;
              bottom: ;
              left: ;
              right: ;
              top: 50%;
              left: 0%;
      }
  },
  .td {
    margin: 0;
    padding: 0.1rem;
    border-right: 1px solid black;
    ${''/* font-size: screengrid7.cellFontSize で決めている。　更新の時font-size無効 */}

    ${'' /* In this example we use an absolutely position resizer,
     so this is required. */}
    position: relative;

    
    select { width:95%;
             height:95%;
     }

    :last-child {
      border-right: 0;
    }

    .resizer {
      right: 0;
      background: steelblue;
      width: 1px;
      height: 50px; ${''/* 30px以下resizeが有効にならない */}
      position: absolute;
      top: 0;
      z-index: 1;
      ${'' /* prevents from scrolling while dragging on touch devices */}
      touch-action :none;

      &.isResizing {
        background-color: red;
      }
    }
  }
  .pagination {
    padding: 0.5rem;
  }

 input { width:95%;
          height:85%;  ${'' /* gotoPgageはscreengrid7で設定*/}
  }

  th {
     input { width:95%;
            height:15px;}
  }       
  
thead.subtablehead {height:15px}
tr.subtablehead {height:10px;}
td.subformtdlabel {text-align: right}

.Editable {background:lightblue}
.EditableRequire {background:skyblue}

.Numeric {text-align: right}

.error {
  background-color: red;
}


input[type="checkbox"] { width:100%;
  height:60%; 
 }

  input[type="checkbox"].error { width:1%;
    height:1%;  }

label.error {width:80%;
    background-color: #FF0000;
  }
`