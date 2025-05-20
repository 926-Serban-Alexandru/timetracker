module Api
  module V1
    class UsersController < BaseController
      before_action :authorize_manager_or_adminAPI!
      before_action :set_user, only: [ :update, :destroy ]

      def index
        @users = User.order(:name)
        render json: @users.as_json(only: [ :id, :name, :email, :role ])
      end

      def create
        @user = User.new(user_params)
        if @user.save
          render json: @user.as_json(only: [ :id, :name, :email, :role ]), status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @user.update(user_params)
          render json: @user.as_json(only: [ :id, :name, :email, :role ])
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @user.destroy
        head :no_content
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
      end

      def authorize_manager_or_admin!
        unless current_user.manager? || current_user.admin?
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end
    end
  end
end
