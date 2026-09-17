namespace :v1 do
  namespace :users do
    post "login", to: "login#create"
    post "registrations", to: "registrations#create"
  end

  get "me", to: "me#show"
  get "/login", to: "oidc#login"
  get "/logout", to: "oidc#logout"
  get "/logout/callback", to: "oidc#logout_callback"
  get "/auth/keycloak/callback", to: "oidc#callback"

  resources :articles do
    resources :topics, only: [ :index ]
  end
end
