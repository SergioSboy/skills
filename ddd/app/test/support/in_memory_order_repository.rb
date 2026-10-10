require_relative "../../app/models/orders/repositories/order_repository"
require_relative "../../app/models/orders/order"

module OrderTestSupport
  class InMemoryOrderRepository < Orders::Repositories::OrderRepository
    def initialize
      @orders = {}
    end

    def find(id)
      snapshot = @orders.fetch(id) { raise Orders::Errors::OrderNotFound, "order #{id} not found" }
      order = Marshal.load(snapshot)
      items = order.items.map do |item|
        Orders::LineItem.new(id: item.id, name: item.name, quantity: item.quantity,
          price: Orders::Money.new(amount: item.price.amount, currency: item.price.currency))
      end
      events = order.events.map do |event|
        Orders::Events::OrderConfirmed.new(order_id: event.order_id, occurred_at: event.occurred_at)
      end
      Orders::Order.restore(id: order.id, status: order.status, items: items, events: events)
    end

    def save(order)
      @orders[order.id] = Marshal.dump(order)
      order
    end
  end
end
