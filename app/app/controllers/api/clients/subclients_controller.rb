module Api
  module Clients
    class SubclientsController < ApplicationController
      def index
        render json: [
          {
            id: 1,
            name: "Subclient 1",
            client_id: params[:client_id]
          },
          {
            id: 2,
            name: "Subclient 2",
            client_id: params[:client_id]
          }
        ]
      end

      def show
        render json: {
          id: params[:id],
          name: "Subclient #{params[:id]}",
          client_id: params[:client_id]
        }
      end

      def create
        render json: {
          id: 3,
          name: "New subclient",
          client_id: params[:client_id]
        }, status: :created
      end
    end
  end
end
