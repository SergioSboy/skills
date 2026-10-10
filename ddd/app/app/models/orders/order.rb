require "securerandom"
require_relative "line_item"
require_relative "events/order_confirmed"

module Orders
  # Доменная сущность, независимая от ORM. Единственная команда — confirm!.
  class Order
    attr_reader :id, :status

    def initialize(id: SecureRandom.uuid, items: [])
      raise Errors::InvalidInput, "id must be a non-empty string" unless id.is_a?(String) && !id.strip.empty?
      unless items.all? { |item| item.is_a?(LineItem) } && items.map(&:id).uniq.size == items.size
        raise Errors::InvalidInput, "items must be unique LineItems"
      end
      raise Errors::InvalidInput, "all items must use the same currency" if items.map { |item| item.price.currency }.uniq.size > 1
      @id = id.dup.freeze
      @items = items.dup.freeze
      @status = :draft
      @events = []
    end

    def items
      @items
    end

    def events
      @events.dup.freeze
    end

    def confirm!(occurred_at: Time.now.utc)
      raise Errors::InvalidState, "only draft orders can be confirmed" unless status == :draft
      raise Errors::EmptyOrder, "cannot confirm an empty order" if items.empty?
      event = Events::OrderConfirmed.new(order_id: id, occurred_at: occurred_at)
      @status = :confirmed
      @events << event
      self
    end

    # Восстановление из БД не повторяет подтверждение.
    def self.restore(id:, status:, items:, events: [])
      raise Errors::InvalidInput, "unknown order status" unless %i[draft confirmed].include?(status)
      raise Errors::EmptyOrder, "confirmed order cannot be empty" if status == :confirmed && items.empty?
      unless events.all? { |event| event.is_a?(Events::OrderConfirmed) && event.order_id == id }
        raise Errors::InvalidInput, "events must belong to this order"
      end
      order = new(id: id, items: items)
      order.instance_variable_set(:@status, status)
      order.instance_variable_set(:@events, events.dup)
      order
    end
  end
end
