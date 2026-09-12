require_relative "boot"

require "rails/all"
Bundler.require(*Rails.groups)

Dir["./middlewares/*.rb"].each { |file| require file }

module Service
  class Application < Rails::Application
    config.load_defaults 8.1
    config.autoload_lib(ignore: %w[assets tasks])

    config.middleware.use ActionDispatch::Cookies

    config.api_only = true
    config.active_job.queue_adapter = :sidekiq

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    config.middleware.use PrometheusMiddleware
    config.middleware.use Rack::Attack
  end
end
