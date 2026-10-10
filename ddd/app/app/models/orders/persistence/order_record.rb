module Orders
  module Persistence
    class OrderRecord < ApplicationRecord
      self.table_name = "orders"
      has_many :line_item_records, -> { order(:position) },
        class_name: "Orders::Persistence::LineItemRecord", foreign_key: :order_id,
        inverse_of: :order_record, dependent: :delete_all
      has_many :event_records, -> { order(:id) },
        class_name: "Orders::Persistence::EventRecord", foreign_key: :order_id,
        inverse_of: :order_record, dependent: :delete_all
    end
  end
end
