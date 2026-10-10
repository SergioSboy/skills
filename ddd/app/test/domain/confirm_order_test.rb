require "minitest/autorun"
require_relative "../../app/models/orders/application/confirm_order"
require_relative "../support/in_memory_order_repository"

class ConfirmOrderTest < Minitest::Test
  def setup
    @repository = OrderTestSupport::InMemoryOrderRepository.new
    @service = Orders::Application::ConfirmOrder.new(repository: @repository)
  end

  def test_success_is_saved
    item = Orders::LineItem.new(id: "item-1", name: "Книга",
      price: Orders::Money.new(amount: 100, currency: "RUB"), quantity: 1)
    order = @repository.save(Orders::Order.new(items: [item]))
    @service.call(order_id: order.id)
    assert_equal :confirmed, @repository.find(order.id).status
    assert_equal 1, @repository.find(order.id).events.size
  end

  def test_failure_is_not_saved
    order = @repository.save(Orders::Order.new)
    assert_raises(Orders::Errors::EmptyOrder) { @service.call(order_id: order.id) }
    assert_equal :draft, @repository.find(order.id).status
    assert_empty @repository.find(order.id).events
  end
end
