module Api
    module Categories
        class SubcategoriesController < ApplicationController
          def index
            render json: [
              {
                id: 1,
                name: "Smartphones",
                category_id: params[:category_id]
              },
              {
                id: 2,
                name: "Laptops",
                category_id: params[:category_id]
              }
            ]
          end

          def show
            render json: {
              id: params[:id],
              name: "Smartphones",
              category_id: params[:category_id]
            }
          end

          def create
            render json: {
              id: 3,
              name: "New subcategory",
              category_id: params[:category_id]
            }, status: :created
          end
        end
    end
end
