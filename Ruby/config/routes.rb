Rails.application.routes.draw do
  # Excluir registrations de Devise ya que usamos UsersController para crear usuarios
  devise_for :users, skip: [:registrations]
  
  # Si necesitas rutas de registro personalizadas (opcional), puedes agregarlas así:
  # devise_scope :user do
  #   get 'sign_up', to: 'devise/registrations#new', as: :new_user_registration
  #   post 'sign_up', to: 'devise/registrations#create', as: :user_registration
  # end

  # Define el root - redirige a usuarios si está logueado, sino a login
  root to: 'users#index'

  # luego tus recursos de usuarios
  resources :users

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
