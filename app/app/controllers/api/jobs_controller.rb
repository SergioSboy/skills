module Api
  class JobsController < ApplicationController
    def create
      job_id = OrderProcessingJob.perform_async

      render json: {
        status: "queued",
        job_id: job_id
      }, status: :accepted
    end
  end
end