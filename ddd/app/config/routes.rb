Rails.application.routes.draw do
  post "orders/:id/confirm", to: "orders#confirm", as: :confirm_order
  post "products/:id/publish", to: "products#publish", as: :publish_product
  get "up", to: "rails/health#show"
end
