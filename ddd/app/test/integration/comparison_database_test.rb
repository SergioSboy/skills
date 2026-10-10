ENV["RAILS_ENV"] = "test"
require_relative "../../config/environment"
require "active_support/testing/autorun"
require "action_dispatch/testing/integration"

# Эти проверки требуют подготовленной test-базы PostgreSQL.
class ComparisonDatabaseTest < ActionDispatch::IntegrationTest
  def setup
    skip "Set TEST_ORDERS_DATABASE=1 after test migrations" unless ENV["TEST_ORDERS_DATABASE"] == "1"
    @connection = ApplicationRecord.connection
    @connection.begin_transaction(joinable: false)
  end

  def teardown
    @connection.rollback_transaction if @connection
  end

  def test_order_confirmation_persists_with_event
    repository = Orders::Repositories::ActiveRecordOrderRepository.new
    item = Orders::LineItem.new(id: SecureRandom.uuid, name: "Книга",
      price: Orders::Money.new(amount: 100, currency: "RUB"), quantity: 1)
    order = repository.save(Orders::Order.new(items: [item]))
    post "/orders/#{order.id}/confirm", as: :json
    assert_response :ok
    assert_equal :confirmed, repository.find(order.id).status
    assert_equal 1, repository.find(order.id).events.size
  end

  def test_product_publication_persists
    product = Product.create!(name: "Книга", price_cents: 19900)
    post "/products/#{product.id}/publish", as: :json
    assert_response :ok
    assert_equal "published", response.parsed_body["status"]
    assert_equal "published", product.reload.status
    post "/products/#{product.id}/publish", as: :json
    assert_response :conflict
  end

  def test_product_without_price_remains_draft
    product = Product.create!(name: "Книга")
    post "/products/#{product.id}/publish", as: :json
    assert_response 422
    assert_equal "draft", product.reload.status
  end

  def test_empty_order_remains_draft
    repository = Orders::Repositories::ActiveRecordOrderRepository.new
    order = repository.save(Orders::Order.new)
    post "/orders/#{order.id}/confirm", as: :json
    assert_response 422
    assert_equal :draft, repository.find(order.id).status
    assert_empty repository.find(order.id).events
  end
end
