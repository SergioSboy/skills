module Api
    module Users
      class RegistrationsController < ApplicationController
        def create
          started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)

          sleep(rand(0.01..0.5))

          if rand < 0.1
            Services.metrics
              .register(
                :counter,
                "registrations_total",
                "Total registrations",
                labels: [ :status ]
              )
              .observe(1, { status: "failed" })

            render json: { status: "failed" }, status: :internal_server_error
          else
            Services.metrics
              .register(
                :counter,
                "registrations_total",
                "Total registrations",
                labels: [ :status ]
              )
              .observe(1, { status: "success" })

            render json: { status: "ok" }, status: :created
          end
        ensure
          latency = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at

          Services.metrics
            .register(
              :histogram,
              "registrations_latency",
              "Registration request latency in seconds",
              buckets: [ 0.01, 0.05, 0.1, 0.25, 0.5, 1, 2 ]
            )
            .observe(latency)
        end
      end
    end
end
