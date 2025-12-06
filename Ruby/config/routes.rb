Rails.application.routes.draw do
  # Excluir registrations de Devise, usamos UsersController para crear usuarios
  devise_for :users, skip: [:registrations]

  # Define el root - página de inicio que redirige según autenticación
  root to: 'backstore/products#index' # Corregir cuando esté el storefront

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Storefront público
  # resources :products, only: [:index, :show]
  # resources :genres, only: [:index]

  # Administración
  namespace :backstore do
    resources :products do
      member do
        patch :update_stock
        patch :soft_delete
      end
    end

    resources :genres, only: [:index, :new, :create, :destroy]
    resources :users
    resources :sales, only: [:index, :new, :create, :show] do
      collection do
        get :search_products
      end
    end
  end
end
