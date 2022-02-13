Rails.application.routes.draw do 
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    mount_devise_token_auth_for 'User', at: 'auth', controllers: {
        registrations: 'api/auth/registrations',
        sessions: 'api/auth/sessions'
    }
  end
  namespace :api do
    resources :menus7 
    resources :uploads 
    resources :ganttcharts 
    resources :jsons
    resources :tblfields  if Rails.env == "development" ##テスト環境の時のみ
  end  
  post '/rails/active_storage/direct_uploads' => 'active_storage/direct_uploads#create'

end