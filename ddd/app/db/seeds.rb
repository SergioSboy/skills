# Два черновика для сравнения API. Каждый запуск создаёт новые примеры.
repository = Orders::Repositories::ActiveRecordOrderRepository.new
item = Orders::LineItem.new(id: SecureRandom.uuid, name: "Книга",
  price: Orders::Money.new(amount: 19900, currency: "RUB"), quantity: 1)
order = repository.save(Orders::Order.new(items: [item]))
product = Product.create!(name: "Книга", price_cents: 19900)
puts "POST /orders/#{order.id}/confirm"
puts "POST /products/#{product.id}/publish"
