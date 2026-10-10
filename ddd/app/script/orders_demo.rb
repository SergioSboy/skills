require_relative "../config/environment"

# Запускать после миграций PostgreSQL. Сравниваем два пути на разных моделях.
repository = Orders::Repositories::ActiveRecordOrderRepository.new
item = Orders::LineItem.new(id: SecureRandom.uuid, name: "Книга",
  price: Orders::Money.new(amount: 19900, currency: "RUB"), quantity: 1)
order = repository.save(Orders::Order.new(items: [item]))
confirmed = Orders::Application::ConfirmOrder.new(repository: repository).call(order_id: order.id)
puts "Сервис → домен → репозиторий: заказ #{confirmed.id}, #{confirmed.status}"

product = Product.create!(name: "Книга", price_cents: 19900)
product.publish!
puts "MVC → Active Record: товар #{product.id}, #{product.status}"
