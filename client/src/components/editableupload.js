
import React, { useCallback }  from 'react'
import {useDispatch,useSelector} from 'react-redux'
import ActiveStorageProvider from 'react-activestorage-provider'
import {EXCELCSVIMPORT_REQUEST} from '../actions'

export const EditableUpload = ({excelfile,})  =>{
  const dispatch = useDispatch()
  const auth = useSelector(state => state.auth)
  const token = auth.token
  const client = auth.client
  const uid = auth.uid
  let fileName
  const setResults = useCallback(
          (results,importError) =>{dispatch({type:EXCELCSVIMPORT_REQUEST,payload:{results,excelfile,importError}})}, [])
    return( 
    <React.Fragment>
        <div className="form-group">
        <ActiveStorageProvider
            endpoint={{
                          path: 'http://localhost:3001/api/uploads',
                          model: 'Upload',
                          attribute: 'excel',
                          method: 'post',
                          host: 'localhost',
                          port: '9292',
                          }}
            headers={{"access-token":token,client:client,uid:uid}}
            onSubmit={e =>setResults(e.results,e.importError)}
            render={({ uploads, ready,handleUpload}) => (
                  <div>
                  
                      <label htmlFor='check_master' > マスターチェック用JSONを入力(check_master) 
                      <input
                        type="file" id="check_master"
                         // disabled={!ready} 
                        placeholder="Json File"  disabled={ready?false:true}
                        onChange={ev => {if(ev.currentTarget.files[0])
                                            {fileName =  ev.currentTarget.files[0].name
                                            if(fileName.search(/\.json$|\.JSON$/>1)&&fileName.search(/@check_master@/>1))
                                                {handleUpload(ev.currentTarget.files)
                                                 }
                                            else{alert("please input check_master JSON File")
                                                }
                                              }    
                                         }}
                      /></label>
                 
                      <label > 更新用jsonを入力(add_update)
                      <input
                        type="file" id="add_update"
                        // disabled={!ready} 
                        placeholder="Json File"  disabled={ready?false:true}
                        onChange={ev => {if(ev.currentTarget.files[0])
                                            {fileName =  ev.currentTarget.files[0].name
                                            if(fileName.search(/\.json$|\.JSON$/>1)&&fileName.search(/@add_update@/>1))
                                                  {handleUpload(ev.currentTarget.files)
                                                   }
                                            else{alert("please input add_update JSON File")
                                                  }
                                                }      
                                        }}
                      />  </label>
                  
                {uploads.map(file => {
                  switch (file.state) {
                    case 'waiting':
                      return <p key={file.id}>Waiting to upload {file.file.name}</p>
                    case 'uploading':
                      return ( <p key={file.id}>
                                Uploading {file.file.name}: {file.progress}%
                              </p>
                      )
                    case 'error':
                      return (
                        <p key={file.id}>
                          Error uploading {file.file.name}: {file.error}
                        </p>
                      )   
                    case 'finished':
                      return (
                        <p key={file.id}>Finished uploading {file.file.name}</p>
                      )
                    default:
                      return (<p>.....</p>)    
                  }     
                })}
                </div>  
              )}
            />

          </div>  
       
      </React.Fragment>
    )}
/*
  Error uploading {file}: Error creating Blob for "{file}". Status: 0
  console上のエラー
  　POST https://localhost:9292/rails/active_storage/direct_uploads net::ERR_CERT_AUTHORITY_INVALID
  が発生した時
  　http://localhost:9292/でHPのACCESSを許可する。
*/

