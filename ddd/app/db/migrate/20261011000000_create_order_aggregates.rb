class CreateOrderAggregates < ActiveRecord::Migration[8.1]
  def change
    # UUID генерируется доменной моделью; строковый PK также допускает учебные id.
    create_table :orders, id: :string do |t|
      t.string :status, null: false, default: "draft"
      t.timestamps
    end
    add_check_constraint :orders,
      "status IN ('draft', 'confirmed', 'cancelled', 'shipped')", name: "orders_valid_status"

    create_table :order_line_items, id: :string do |t|
      t.references :order, type: :string, null: false, foreign_key: true
      t.string :name, null: false
      t.bigint :price_amount, null: false
      t.string :price_currency, null: false, limit: 3
      t.integer :quantity, null: false
      t.integer :position, null: false
      t.timestamps
    end
    add_index :order_line_items, [:order_id, :position], unique: true
    add_check_constraint :order_line_items, "quantity > 0", name: "order_items_positive_quantity"
    add_check_constraint :order_line_items, "price_amount >= 0", name: "order_items_nonnegative_price"
    add_check_constraint :order_line_items, "position >= 0", name: "order_items_nonnegative_position"
    add_check_constraint :order_line_items, "length(trim(name)) > 0", name: "order_items_nonempty_name"
    add_check_constraint :order_line_items, "price_currency ~ '^[A-Z]{3}$'", name: "order_items_currency_code"

    create_table :order_events do |t|
      t.references :order, type: :string, null: false, foreign_key: true
      t.string :event_type, null: false
      t.datetime :occurred_at, null: false, precision: 6
      t.timestamps
    end
    # В текущей машине состояний заказ подтверждается ровно один раз.
    add_index :order_events, [:order_id, :event_type], unique: true
    add_check_constraint :order_events, "event_type = 'order_confirmed'", name: "order_events_known_type"
  end
end
