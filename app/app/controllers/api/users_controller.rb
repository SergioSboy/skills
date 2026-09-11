module Api
  class UsersController < ApplicationController
    def index
      render json: {
        users: [
          { id: 1, name: "John Doe" },
          { id: 2, name: "Jane Doe" }
        ]
      }
    end

    def show
      render json: {
        id: params[:id],
        name: "John Doe"
      }
    end
  end
end