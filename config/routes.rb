Rails.application.routes.draw do 
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    mount_devise_token_auth_for 'User', at: 'auth', controllers: {
        registrations: 'api/auth/users/registrations',
        sessions: 'api/auth/sessions',
        passwords: 'api/auth/passwords'
    }
  end
  namespace :api do
    resources :menus7 
    resources :ganttcharts 
    resources :uploadexcel
    resources :tblfields  if Rails.env == "development" ##テスト環境の時のみ
  end  

end