class ApplicationController < ActionController::API
        include DeviseTokenAuth::Concerns::SetUserByToken
        before_action :authenticate_api_user!,except:[:create,:show]
        
end
