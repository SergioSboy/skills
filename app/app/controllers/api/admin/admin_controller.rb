module Api
  class AdminController < ApplicationController
    before_action :check_admin_access

    private

    def check_admin_access
      render json: {
        data: nil,
        errors: [
          {
            code: "forbidden",
            field: nil,
            message: "Admin access required"
          }
        ],
        meta: {
          request_id: request.request_id
        }
      }, status: :forbidden
    end
  end
end
