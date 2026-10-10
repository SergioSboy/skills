require_relative "order_repository"
require_relative "../order"

module Orders
  module Repositories
    class ActiveRecordOrderRepository < OrderRepository
      def find(id)
        with_order(id) { |order| order }
      end

      def with_order(id)
        Persistence::OrderRecord.transaction do
          record = Persistence::OrderRecord.lock.find_by(id: id)
          raise Errors::OrderNotFound, "order #{id} not found" unless record
          yield restore(record)
        end
      end

      def save(order)
        Persistence::OrderRecord.transaction do
          record = Persistence::OrderRecord.lock.find_by(id: order.id)
          record ||= Persistence::OrderRecord.new(id: order.id)
          record.update!(status: order.status.to_s)
          record.line_item_records.delete_all
          order.items.each_with_index do |item, position|
            record.line_item_records.create!(
              id: item.id, name: item.name, quantity: item.quantity,
              price_amount: item.price.amount, price_currency: item.price.currency,
              position: position
            )
          end
          order.events.each do |event|
            record.event_records.find_or_create_by!(event_type: "order_confirmed") do |row|
              row.occurred_at = event.occurred_at
            end
          end
        end
        order
      end

      private

      def restore(record)
        items = record.line_item_records.map do |row|
          LineItem.new(id: row.id, name: row.name, quantity: row.quantity,
            price: Money.new(amount: row.price_amount, currency: row.price_currency))
        end
        events = record.event_records.map do |row|
          raise Errors::InvalidInput, "unknown persisted event type" unless row.event_type == "order_confirmed"
          Events::OrderConfirmed.new(order_id: record.id, occurred_at: row.occurred_at)
        end
        Order.restore(id: record.id, status: record.status.to_sym, items: items, events: events)
      end
    end
  end
end
