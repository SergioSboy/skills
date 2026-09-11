module Api
  class ProductsController < ApplicationController
    def index
      render json: {
        products: [
          { id: 1, name: "Laptop", price: 1200 },
          { id: 2, name: "Keyboard", price: 100 }
        ]
      }
    end

    def show
      render json: {
        id: params[:id],
        name: "Laptop",
        price: 1200
      }
    end
  end
end