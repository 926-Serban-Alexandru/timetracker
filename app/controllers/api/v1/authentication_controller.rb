module Api
  module V1
    class AuthenticationController < BaseController
      skip_before_action :authenticate_user_from_token!, only: [ :login ]

      def login
        user = User.find_by(email: params[:email])
        if user&.valid_password?(params[:password])
          user.generate_authentication_token unless user.authentication_token
          user.save!
          render json: { token: user.authentication_token, user: user.as_json(only: [ :id, :name, :email, :role ]) }
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      def logout
        auth_token = request.headers["Authorization"]&.split(" ")&.last
        user = User.find_by(authentication_token: auth_token)

        if user
          user.invalidate_token
          user.save!
          head :no_content
        else
          render json: { error: "Invalid token" }, status: :unauthorized
        end
      end
    end
  end
end
