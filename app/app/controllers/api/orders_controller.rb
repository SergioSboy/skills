module Api
  class OrdersController < ApplicationController
    def index
      render json: {
        orders: [
          { id: 1, user_id: 1, status: "completed" },
          { id: 2, user_id: 2, status: "processing" }
        ]
      }
    end

    def show
      render json: {
        id: params[:id],
        user_id: 1,
        status: "completed"
      }
    end

    def create
      if rand < 0.05
        Services.metrics
          .register(:counter, "payments_failed", "Failed payments")
          .observe(1)

        render json: { status: "failed" }, status: :payment_required
      else
        Services.metrics
          .register(:counter, "payments_success", "Successful payments")
          .observe(1)

        render json: { status: "ok" }, status: :created
      end
    end
  end
end
