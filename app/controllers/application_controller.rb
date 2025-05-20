class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  def authorize_manager_or_admin!
    unless current_user.manager? || current_user.admin?
      redirect_to root_path, alert: "You don't have permission to access this page."
    end
  end

def authorize_manager_or_adminAPI!
  unless current_user.manager? || current_user.admin?
    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end


  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end
end
