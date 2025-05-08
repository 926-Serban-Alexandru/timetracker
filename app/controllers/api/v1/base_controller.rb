module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_user_from_token!

      private

      def authenticate_user_from_token!
        auth_token = request.headers["Authorization"]&.split(" ")&.last
        Rails.logger.info("Auth token received: #{auth_token}")
        @current_user = User.find_by(authentication_token: auth_token)

        if @current_user.nil?
          Rails.logger.error("No user found with token #{auth_token}")
          render json: { error: "Unauthorized" }, status: :unauthorized
        end

        unless @current_user
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end

      def current_user
        @current_user
      end
    end
  end
end
