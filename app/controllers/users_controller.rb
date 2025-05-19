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

    respond_to do |format|
      if @user.save
        format.turbo_stream
        format.html { redirect_to users_path, notice: "User created." }
      else
         render turbo_stream: turbo_stream.replace("user_form", partial: "form", locals: { user: @user })
        format.html do
          @users = User.order(:name)
          render :index, status: :unprocessable_entity
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.turbo_stream
        format.html { redirect_to users_path, notice: "User updated." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@user), partial: "edit_row", locals: { user: @user }) }
        format.html do
          @users = User.order(:name)
          @editing_user = @user
          render :index, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@user) }
      format.html { redirect_to users_path, notice: "User deleted." }
    end
  end

  def edit
  @user = User.find(params[:id])
  respond_to do |format|
    format.html { redirect_to users_path(edit_id: @user.id) } # Fallback
    format.turbo_stream do
      render turbo_stream: [
        turbo_stream.replace(
          dom_id(@user),
          partial: "edit_row",
          locals: { user: @user }
        ),
        turbo_stream.replace(
          "user_form",
          partial: "form",
          locals: { user: User.new }
        )
      ]
    end
  end
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
