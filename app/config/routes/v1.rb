namespace :v1 do
  namespace :users do
    post "login", to: "login#create"
    post "registrations", to: "registrations#create"
  end

  resources :articles do
    resources :topics, only: [ :index ]
  end
end
