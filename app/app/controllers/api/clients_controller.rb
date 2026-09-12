module Api
  class ClientsController < ApplicationController
    def index
      render json: [
        {
          id: 1,
          name: "Client 1",
          email: "client1@example.com"
        },
        {
          id: 2,
          name: "Client 2",
          email: "client2@example.com"
        }
      ]
    end

    def show
      render json: {
        id: 42,
        name: "Acme",
        email: "acme@example.com"
      }, status: :ok
    end

    def create
      render json: {
        id: 3,
        name: "New client",
        email: "newclient@example.com"
      }, status: :created
    end

    def update
      render json: {
        id: params[:id],
        name: "Updated Client #{params[:id]}",
        email: "updated@example.com"
      }
    end

    def destroy
      head :no_content
    end
  end
end
