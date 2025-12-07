class ApplicationController < ActionController::Base

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to backstore_products_path, alert: "No estás autorizado para acceder a esta página."
  end
  
  protected

  def home
    if user_signed_in?
      redirect_to backstore_products_path
    else
      redirect_to new_user_session_path
    end
  end

  # Redirigir al backstore luego de iniciar sesión
  def after_sign_in_path_for(resource)
    backstore_products_path
  end

end
