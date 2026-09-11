class UpdateActiveUsersJob < ApplicationJob
  queue_as :default

  @@active_users = 10

  def perform
    @@active_users += rand(1..10)

    Services.metrics
          .register(:gauge, "active_users", "Number of active users")
          .observe(@@active_users)
  end
end