Rails.application.routes.draw do
  # Excluir registrations de Devise ya que usamos UsersController para crear usuarios
  devise_for :users, skip: [:registrations]
  
  # Si necesitas rutas de registro personalizadas (opcional), puedes agregarlas así:
  # devise_scope :user do
  #   get 'sign_up', to: 'devise/registrations#new', as: :new_user_registration
  #   post 'sign_up', to: 'devise/registrations#create', as: :user_registration
  # end

  # Define el root - página de inicio que redirige según autenticación
  root to: 'application#home'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Storefront público
  # resources :products, only: [:index, :show]
  # resources :genres, only: [:index, :show]

  # Administración
  namespace :backstore do
    resources :products do
      member do
        patch :update_stock
        patch :soft_delete
        patch :restore
      end
    end

    resources :genres
    resources :users
  end
end
