Rails.application.routes.draw do
  # Excluir registrations de Devise, usamos UsersController para crear usuarios
  devise_for :users, skip: [:registrations]

  # ROOT = Storefront público
  root to: 'storefront#index'

  # Define el root - página de inicio que redirige según autenticación
  #root to: 'backstore/products#index' # Corregir cuando esté el storefront

  # Storefront público (sin autenticación)
  get 'tienda', to: 'storefront#index', as: :storefront
  get 'tienda/:id', to: 'storefront#show', as: :storefront_product

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

    resources :genres
    resources :users
  end
end
