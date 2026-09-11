require 'prometheus_exporter/client'

module PrometheusExporter
  class StubClient
    delegate :logger, to: Rails

    def self.default
      new
    end

    def register(type, name, help)
      logger.info "Created metric type: #{type}, name: #{name}, help: #{help}"
      self
    end

    def observe(value, labels = {})
      logger.info "Parameters of metric: #{value}, labels: #{labels}"
      true
    end
  end
end

class Services
  def metrics
    if Rails.env.test?
      PrometheusExporter::StubClient.default
    else
      PrometheusExporter::Client.default
    end
  end

  cattr_reader :metrics, instance_reader: false, default: new.metrics
end
