##https://github.com/lynndylanhurley/devise_token_auth
module Api
  module Auth
    class PasswordsController < DeviseTokenAuth::PasswordsController
      ###before_action :authenticate_api_user!, except: [:create,:new]
      private
      def resource_params
        params.permit(:email, :password, :password_confirmation)
      end
    
    end  
  end
end
