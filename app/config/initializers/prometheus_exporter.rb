unless Rails.env.test?
  require 'prometheus_exporter/middleware'
  require 'prometheus_exporter/instrumentation/active_record'

  # HTTP/Rails metrics
  Rails.application.config.middleware.unshift PrometheusExporter::Middleware

  # ActiveRecord metrics
  PrometheusExporter::Instrumentation::ActiveRecord.start
end