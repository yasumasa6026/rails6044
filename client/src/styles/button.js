import styled from 'styled-components'

export const Button = styled.button`
  color:white;
  background:light-blue;
  min-width: 80px;
  font-size: 1em;
  margin: 0.1em;
  padding: 0.25em 0.5em;
  border: 0.25em ;
  border-radius: 0.5px;
  :hover {
    color: black;
  }
  .react-tabs--selected_custom_footer & {
    background: rgb(30, 221, 116);
  }
  
  .react-tabs--selected_custom_detail & {
    background: rgb(30, 221, 116);
  }
  
`
