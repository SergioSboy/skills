module Api
    class CategoriesController < ApplicationController
      def index
        render json: [
          { id: 1, name: "Electronics" },
          { id: 2, name: "Books" }
        ]
      end

      def show
        render json: {
          id: params[:id],
          name: "Electronics"
        }
      end

      def create
        render json: {
          id: 3,
          name: "New category"
        }, status: :created
      end

      def update
        render json: {
          id: params[:id],
          name: "Updated category"
        }
      end

      def destroy
        head :no_content
      end
    end
end
