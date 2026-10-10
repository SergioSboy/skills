require "minitest/autorun"
require_relative "../../app/models/orders/order"

class OrderRestoreTest < Minitest::Test
  def test_restoration_does_not_replay_confirmation
    item = Orders::LineItem.new(id: "item-1", name: "Книга",
      price: Orders::Money.new(amount: 100, currency: "RUB"), quantity: 1)
    original = Orders::Order.new(items: [item])
    original.confirm!
    restored = Orders::Order.restore(id: original.id, status: original.status,
      items: original.items, events: original.events)
    assert_equal original.id, restored.id
    assert_equal :confirmed, restored.status
    assert_equal original.events, restored.events
    assert_raises(Orders::Errors::InvalidState) { restored.confirm! }
  end

  def test_invalid_saved_state_is_rejected
    assert_raises(Orders::Errors::InvalidInput) { Orders::Order.restore(id: "one", status: :unknown, items: []) }
    assert_raises(Orders::Errors::EmptyOrder) { Orders::Order.restore(id: "one", status: :confirmed, items: []) }
  end
end
