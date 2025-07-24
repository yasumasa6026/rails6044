##https://github.com/lynndylanhurley/devise_token_auth
module Api
  module Auth
    # class RegistrationsController < DeviseTokenAuth::RegistrationsController
    #   ###before_action :authenticate_api_user!, except: [:create,:new]
    #   before_action :authenticate_api_user!, except: [:create]
    #   ###def new  ### createを使用する。
    #   ###end  
    #   private
    #   def sign_up_params
    #       params.permit(*params_for_resource(:sign_up))
    #   end
    # end  class Users::RegistrationsController < Devise::RegistrationsController
    class Users::RegistrationsController < DeviseTokenAuth::RegistrationsController
      def create
        # 画面から送信されたメールアドレスを取得
        email = params[:email]
        strsql = "SELECT 1 FROM persons p WHERE p.email = '#{email}' and expiredate > now()"
        # SQLクエリを実行して、メールアドレスが存在するか
        # Pemailsテーブルにメールアドレスが存在するかチェック
        if ActiveRecord::Base.connection.select_value(strsql)
          # メールアドレスが存在する場合、通常のcreate処理を続行
          super
          return
        else
          # メールアドレスが存在しない場合、404を返す
          render json: { error: 'Email not found in persons table' }, status: :not_found
        end
      end
    end
  end
end
