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

    def create
      user = User.new(user_params)

      if user.save
        render json: {
          data: {
            id: user.id,
            name: user.name,
            email: user.email
          }
        }, status: :created
      else
        render_validation_errors(user)
      end
    end

    def show
      render json: {
        id: params[:id],
        name: "John Doe"
      }
    end
  end
end
