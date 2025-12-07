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
      member do
        patch :cancel
      end
      collection do
        get :search_products
      end
    end

    # Reportes
    get "reports", to: "reports#index", as: :reports
    get "reports/sales_over_time", to: "reports#sales_over_time", as: :reports_sales_over_time
    get "reports/sales_by_product", to: "reports#sales_by_product", as: :reports_sales_by_product
    get "reports/sales_by_employee", to: "reports#sales_by_employee", as: :reports_sales_by_employee
    get "reports/export_pdf", to: "reports#export_pdf", as: :reports_export_pdf
  end
end
