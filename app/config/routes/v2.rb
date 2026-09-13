namespace :v2 do
  resources :articles do
    resources :topics, only: [ :index ]
  end
end
