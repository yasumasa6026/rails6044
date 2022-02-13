##https://github.com/lynndylanhurley/devise_token_auth
###https://github.com/heartcombo/devise
module Api
  module Auth
    class SessionsController < DeviseTokenAuth::SessionsController
     ## before_action :authenticate_api_user!, except: [:create,:destroy]
        # Prevent session parameter from being passed
        # Unpermitted parameter: session
        wrap_parameters format: []
    
    end    
  end
end
