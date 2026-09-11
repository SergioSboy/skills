Rails.application.routes.draw do
  namespace :api do
    get "health", to: "health#show"

    resources :users, only: [:index, :show]
    resources :products, only: [:index, :show]
    resources :orders, only: [:index, :show, :create]

    post "jobs", to: "jobs#create"
  end

  post "users/registrations", to: "users/registrations#create"
end