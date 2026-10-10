module Orders
  module Persistence
    class EventRecord < ApplicationRecord
      self.table_name = "order_events"
      belongs_to :order_record, class_name: "Orders::Persistence::OrderRecord",
        foreign_key: :order_id, inverse_of: :event_records
    end
  end
end
