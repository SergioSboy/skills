Rails.application.routes.draw do
  namespace :api do
    get "health", to: "health#show"

    namespace :admin do
      resources :users, only: [ :index, :show ]
    end

    namespace :users do
        post "login", to: "login#create"
    end

    resources :users, only: [ :index, :show ]
    resources :products, only: [ :index, :show ]
    resources :orders, only: [ :index, :show, :create ]

    resources :articles, only: [ :index, :show, :create, :update, :delete ]

    resources :categories, only: [ :index, :show, :create, :update, :destroy ] do
      scope module: :categories do
        resources :products, only: [ :index, :show ]
        resources :subcategories, only: [ :index, :show, :create ]
      end
    end

    resources :clients, only: [ :index, :show, :create, :update, :destroy ] do
      scope module: :clients do
        resources :subclients, only: [ :index, :show, :create ]
      end
    end

    post "jobs", to: "jobs#create"
  end

  post "users/registrations", to: "users/registrations#create"
end
