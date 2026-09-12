require "prometheus_exporter/instrumentation/sidekiq"
require "prometheus_exporter/instrumentation/periodic_stats"
require "prometheus_exporter/instrumentation/process"
require "prometheus_exporter/instrumentation/sidekiq_queue"
require "prometheus_exporter/instrumentation/sidekiq_stats"
require "sidekiq/api"


Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }

  unless Rails.env.test?
    # 1. Метрики выполнения самих джобов (время выполнения, ошибки)
    config.server_middleware do |chain|
      chain.add PrometheusExporter::Instrumentation::Sidekiq
    end

    # 2. Трекинг задач, которые "убили" процесс или исчерпали лимит попыток (retries)
    config.death_handlers << PrometheusExporter::Instrumentation::Sidekiq.death_handler

    config.on :startup do
      # 3. Метрики самого процесса Sidekiq (потребление RAM, CPU, сборка мусора)
      PrometheusExporter::Instrumentation::Process.start(type: "sidekiq")

      # 4. Метрики задержек очередей (latency) и их размеров
      PrometheusExporter::Instrumentation::SidekiqQueue.start

      # 5. Общая статистика Sidekiq (processed, failed и т.д.)
      PrometheusExporter::Instrumentation::SidekiqStats.start
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
end
