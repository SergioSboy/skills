class PrometheusMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    req = ActionDispatch::Request.new(env)
    time = Time.current
    status, header, response = @app.call(env)
    duration = Time.current - time

    path = nil
    method = nil

    Rails.application.routes.router.recognize(req) do |route, _params|
      path = route&.path&.spec.to_s.chomp('(.:format)')
      method = route&.verb.to_s.upcase
      break
    end

    request_metric = Services.metrics.register(:histogram, 'request_metric', 'Requests')
    tags = { method:, path:, response_code: status }

    request_metric.observe(duration, tags)

    [status, header, response]
  end
end
