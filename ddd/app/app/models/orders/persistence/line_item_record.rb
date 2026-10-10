module Orders
  module Persistence
    class LineItemRecord < ApplicationRecord
      self.table_name = "order_line_items"
      belongs_to :order_record, class_name: "Orders::Persistence::OrderRecord",
        foreign_key: :order_id, inverse_of: :line_item_records
    end
  end
end
