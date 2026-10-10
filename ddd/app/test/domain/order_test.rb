require "minitest/autorun"
require_relative "../../app/models/orders/order"

class OrderTest < Minitest::Test
  def populated_order
    item = Orders::LineItem.new(id: "item-1", name: "Книга",
      price: Orders::Money.new(amount: 19900, currency: "RUB"), quantity: 1)
    Orders::Order.new(id: "order-1", items: [item])
  end

  def test_new_order_is_a_draft
    assert_equal :draft, Orders::Order.new.status
  end

  def test_nonempty_order_is_confirmed_and_records_event
    order = populated_order
    time = Time.utc(2026, 10, 11, 12)
    assert_same order, order.confirm!(occurred_at: time)
    assert_equal :confirmed, order.status
    assert_equal 1, order.events.size
    assert_equal order.id, order.events.first.order_id
    assert_equal time, order.events.first.occurred_at
  end

  def test_empty_order_is_rejected_without_changes
    order = Orders::Order.new
    assert_raises(Orders::Errors::EmptyOrder) { order.confirm! }
    assert_equal :draft, order.status
    assert_empty order.events
  end

  def test_repeated_confirmation_is_rejected_without_duplicate_event
    order = populated_order
    order.confirm!
    assert_raises(Orders::Errors::InvalidState) { order.confirm! }
    assert_equal :confirmed, order.status
    assert_equal 1, order.events.size
  end

  def test_composition_is_immutable
    order = populated_order
    assert_raises(FrozenError) { order.items.clear }
    assert_raises(NoMethodError) { order.items.first.quantity = 2 }
  end
end
