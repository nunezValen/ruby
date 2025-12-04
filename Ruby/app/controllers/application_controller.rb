class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nombre, :apellido, :rol])
    devise_parameter_sanitizer.permit(:account_update, keys: [:nombre, :apellido, :rol])
  end
  def user_params
    if current_user.administrador?
      params.require(:user).permit(:nombre, :apellido, :email, :role)
    else
      params.require(:user).permit(:nombre, :apellido, :email) # sin role
    end 
  end

end
