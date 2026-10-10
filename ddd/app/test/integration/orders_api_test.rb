ENV["RAILS_ENV"] = "test"
require_relative "../../config/environment"
require_relative "../support/in_memory_order_repository"
require "active_support/testing/autorun"
require "action_dispatch/testing/integration"

class OrdersApiTest < ActionDispatch::IntegrationTest
  def run
    @repository = OrderTestSupport::InMemoryOrderRepository.new
    repository_class = Orders::Repositories::ActiveRecordOrderRepository
    repository = @repository
    repository_class.define_singleton_method(:new) { repository }
    super
  ensure
    repository_class.singleton_class.remove_method(:new) if repository_class
  end

  def test_confirm_returns_json_and_rejects_repeated_confirmation
    item = Orders::LineItem.new(id: "item-1", name: "Книга",
      price: Orders::Money.new(amount: 19900, currency: "RUB"), quantity: 1)
    order = @repository.save(Orders::Order.new(items: [item]))
    post "/orders/#{order.id}/confirm", as: :json
    assert_response :ok
    assert_equal "application/json", response.media_type
    assert_equal "confirmed", response.parsed_body["status"]
    assert_equal "order_confirmed", response.parsed_body["events"].first["type"]
    post "/orders/#{order.id}/confirm", as: :json
    assert_response :conflict
    assert_equal 1, @repository.find(order.id).events.size
  end

  def test_empty_order_returns_422
    order = @repository.save(Orders::Order.new)
    post "/orders/#{order.id}/confirm", as: :json
    assert_response 422
    assert_equal "empty_order", response.parsed_body["error"]
    assert_equal :draft, @repository.find(order.id).status
  end

  def test_missing_order_returns_404
    post "/orders/missing/confirm", as: :json
    assert_response :not_found
  end
end
