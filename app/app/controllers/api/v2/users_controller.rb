module Api
  module V2
    class UsersController < ApplicationController
      def index
        limit = params.fetch(:limit, 20).to_i
        cursor = params[:cursor]

        users = User.order(:id).limit(limit)

        users = users.where("id > ?", cursor.to_i) if cursor.present?

        render json: {
          data: users.map { |user|
            {
              id: user.id,
              name: user.name
            }
          },
          meta: {
            next_cursor: users.last&.id
          }
        }
      end

      def show
        render json: {
          id: 42,
          first_name: "John",
          last_name: "Smith"
        }
      end
    end
  end
end
