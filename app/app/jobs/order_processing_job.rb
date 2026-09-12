class OrderProcessingJob
  include Sidekiq::Job

  def perform
    sleep 1

    Rails.logger.info "Order processing completed"
  end
end
