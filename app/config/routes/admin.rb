namespace :admin do
  resources :users, only: [ :index, :show ]
end
