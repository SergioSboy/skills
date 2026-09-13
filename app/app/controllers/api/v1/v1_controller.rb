module Api
  module V1
    class V1Controller < ApplicationController
      before_action :set_deprecation_headers

      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity

      private

      def set_deprecation_headers
        response.headers["Deprecation"] = "true"
        response.headers["Sunset"] = "Wed, 31 Dec 2026 23:59:59 GMT"
      end

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
