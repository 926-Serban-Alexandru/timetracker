class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_manager_or_admin!, only: [ :index ]
  before_action :set_user, only: [ :update, :destroy ]
  include ActionView::RecordIdentifier

  def index
    @users = if current_user.manager?
             User.where.not(role: :admin).order(:name)
    else
             User.order(:name)
    end
    @user = User.new
    @editing_user = User.find(params[:edit_id]) if params[:edit_id]
  end

  def manual_create
    @user = User.new(user_params)

    if @user.save
      redirect_to users_path, notice: "User created."
    else
      @users = User.order(:name)
      render :index, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      redirect_to users_path, notice: "User updated."
    else
      @users = User.order(:name)
      @editing_user = @user
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, notice: "User deleted."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    permitted = [ :name, :email ]
    if params[:user][:password].present?
      permitted += [ :password, :password_confirmation ]
    end
    params.require(:user).permit(permitted)
  end
end
