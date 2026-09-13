Rails.application.routes.draw do
  namespace :api do
    get "health", to: "health#show"

    draw :admin
    draw :v1
    draw :v2

    post "jobs", to: "jobs#create"
  end
end
