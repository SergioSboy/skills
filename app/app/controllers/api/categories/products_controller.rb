module Api
    module Categories
        class ProductsController < ApplicationController
          def index
            render json: [
              {
                id: 1,
                name: "iPhone",
                category_id: params[:category_id]
              },
              {
                id: 2,
                name: "MacBook",
                category_id: params[:category_id]
              }
            ]
          end

          def show
            render json: {
              id: params[:id],
              name: "iPhone",
              category_id: params[:category_id]
            }
          end
        end
    end
end
