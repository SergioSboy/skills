module Api
  module V1
    class UsersController < ApplicationController
      def index
        page = params.fetch(:page, 1).to_i
        per_page = params.fetch(:per_page, 20).to_i

        users = User.offset((page - 1) * per_page).limit(per_page)
        render json: {
            data: users.map { |user|
              {
                id: user.id,
                name: user.name
              }
            },
            meta: {
              page: page,
              per_page: per_page,
              total: User.count
            }
          }
      end

      def show
        headers["Deprecation"] = "true"
        headers["Sunset"] = "Wed, 31 Dec 2026 23:59:59 GMT"

        user = User.find(params[:id])

        authorize user

        render json: {
          data: {
            id: user.id,
            name: user.name
          }
        }
      end
    end
  end
end
