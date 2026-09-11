class MetricsJob
  include Sidekiq::Job

  def perform
    Rails.logger.info "MetricsJob executed at #{Time.current}"

    sleep 1
  end
end