# OCP — Open/Closed Principle

**Принцип открытости/закрытости:** код должен быть открыт для расширения и закрыт для изменения.

Новое поведение добавляют через предусмотренные точки расширения, без переписывания работающей логики.

**Пример:** для нового способа оплаты добавляем реализацию общего контракта оплаты; код оформления заказа остаётся прежним.

**Запомнить:** расширяй поведение через абстракции и композицию. Принцип не запрещает исправлять ошибки или менять требования.

---

Примеры на Ruby. Рабочие сценарии упрощены; внешние клиенты передаются при сборке приложения.

## 1. Простой пример: скидка

**До:** при каждой новой скидке меняем условие внутри расчёта.

```ruby
class Checkout
  def total(cents, discount_type)
    case discount_type
    when :regular then cents
    when :vip then cents * 90 / 100
    else raise ArgumentError, "Unknown discount"
    end
  end
end
```

**После:** расчёт принимает объект с методом `apply`.

```ruby
class NoDiscount
  def apply(cents) = cents
end

class VipDiscount
  def apply(cents) = cents * 90 / 100
end

class Checkout
  def total(cents, discount:)
    discount.apply(cents)
  end
end

Checkout.new.total(10_000, discount: VipDiscount.new) # => 9000
```

Для новой скидки добавляем реализацию `apply`; `Checkout` не меняется. Суммы здесь — целые копейки, округление скидки вниз задано явно целочисленным делением.

## 2. Рабочий сценарий: стоимость доставки

**До:** оформление заказа содержит `case carrier`, тарифы каждого перевозчика и обращения к их API.

**После:** оформление использует общий контракт `quote(order:)`, возвращающий стоимость в копейках в валюте заказа.

```ruby
class PickupRate
  def quote(order:) = 0
end

class CourierRate
  def initialize(client:)
    @client = client
  end

  def quote(order:)
    @client.quote_cents(
      postal_code: order.postal_code,
      weight_grams: order.weight_grams,
      currency: order.currency
    )
  end
end

class OrderTotal
  def call(order:, shipping:)
    order.subtotal_cents + shipping.quote(order: order)
  end
end

# Сборка приложения: client — настроенный клиент перевозчика.
rates = {
  pickup: PickupRate.new,
  courier: CourierRate.new(client: client)
}
shipping = rates.fetch(order.shipping_method.to_sym)
OrderTotal.new.call(order: order, shipping: shipping)
```

Нового перевозчика добавляем отдельным адаптером и регистрируем в `rates`. Меняется состав приложения, а не формула `OrderTotal`. Таймауты и ошибки API обрабатываются на границе адаптера; бесплатная доставка при ошибке не подставляется.
