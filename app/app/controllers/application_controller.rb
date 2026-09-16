class ApplicationController < ActionController::API
    before_action :page_validation

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from Pundit::NotAuthorizedError, with: :render_forbidden


    def render_validation_errors(record)
      render json: {
        data: nil,
        errors: record.errors.map do |error|
          {
            code: "validation_error",
            field: error.attribute,
            message: error.full_message
          }
        end
      }, status: :unprocessable_content
    end

    def render_forbidden
    render json: {
      data: nil,
      errors: [
        {
          code: "forbidden",
          field: nil,
          message: "You are not allowed to perform this action"
        }
      ],
      meta: {
        request_id: request.request_id
      }
    }, status: :forbidden
    end

    def render_unauthorized(message)
        render json: {
          data: nil,
          errors: [
            {
              code: "unauthorized",
              field: nil,
              message: message
            }
          ],
          meta: {
            request_id: request.request_id
          }
        }, status: :unauthorized
    end

    def page_validation
        return unless params[:page].present?

        page = Integer(params[:page], exception: false)

        if page.nil? || page < 1
          render json: {
            data: nil,
            errors: [
              {
                code: "invalid_parameter",
                field: "page",
                message: "page must be a positive integer"
              }
            ]
          }, status: :bad_request
        end
    end

    def render_not_found
        render json: {
          data: nil,
          errors: [
            {
              code: "not_found",
              field: nil,
              message: "Resource not found"
            }
          ],
          meta: {
            request_id: request.request_id
          }
        }, status: :not_found
    end
end
