Rails.application.routes.draw do
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
  end

  root "backstore/products#index"
end
