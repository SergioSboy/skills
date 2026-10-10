module ErrorsCommon
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid do |error|
      render_api_error("invalid_input", error.record.errors.full_messages.join(", "), 422)
    end
    rescue_from ActionController::ParameterMissing do |error|
      render_api_error("missing_parameter", error.message, 400)
    end
    rescue_from ActionDispatch::Http::Parameters::ParseError do
      render_api_error("invalid_json", "Request body must be valid JSON", 400)
    end
    rescue_from Orders::Errors::InvalidInput do |error|
      render_api_error("invalid_input", error.message, 422)
    end
    rescue_from Orders::Errors::OrderNotFound, ActiveRecord::RecordNotFound do |error|
      render_api_error("not_found", error.message, 404)
    end
    rescue_from Orders::Errors::InvalidState, Product::InvalidState do |error|
      render_api_error("invalid_state", error.message, 409)
    end
    rescue_from Orders::Errors::EmptyOrder do |error|
      render_api_error("empty_order", error.message, 422)
    end
  end

  private

  def render_api_error(code, message, status)
    render "shared/error", formats: [:json],
      locals: { code: code, message: message }, status: status
  end
end
