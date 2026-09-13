module Api
  module V1
    class V2Controller < ApplicationController
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity

      private

      def render_not_found(error)
        render json: {
          data: nil,
          errors: [
            {
              code: "not_found",
              message: error.message
            }
          ]
        }, status: :not_found
      end

      def render_unprocessable_entity(error)
        render json: {
          data: nil,
          errors: error.record.errors.map do |field, message|
            {
              field: field,
              message: message
            }
          end
        }, status: :unprocessable_entity
      end
    end
  end
end
