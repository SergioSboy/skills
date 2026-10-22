# DIP — Dependency Inversion Principle

**Принцип инверсии зависимостей:** высокоуровневая логика и низкоуровневые детали должны зависеть от абстракций. Абстракции не должны зависеть от деталей; детали зависят от абстракций.

**Пример:** оформление заказа использует контракт `PaymentGateway`, а конкретный клиент банка реализует этот контракт и передаётся извне.

**Запомнить:** бизнес-логика задаёт нужный ей контракт, инфраструктура его реализует. Передача зависимости через конструктор помогает, но сама по себе ещё не гарантирует DIP.

---

Примеры на Ruby. Рабочие сценарии упрощены; внешние клиенты передаются при сборке приложения.

## 1. Простой пример: уведомление

**До:** сценарий сам создаёт конкретный почтовый клиент и знает его API.

```ruby
class NotifyUser
  def call(email:, text:)
    SmtpClient.new.send_mail(to: email, body: text)
  end
end
```

**После:** сценарий требует контракт `deliver(to:, text:)`, а почтовый адаптер его реализует.

```ruby
class NotifyUser
  def initialize(sender:)
    @sender = sender
  end

  def call(email:, text:)
    @sender.deliver(to: email, text: text)
  end
end

class SmtpSender
  def initialize(client:)
    @client = client
  end

  def deliver(to:, text:)
    @client.send_mail(to: to, body: text)
  end
end

# Сборка приложения; smtp_client — настроенный почтовый клиент.
NotifyUser.new(sender: SmtpSender.new(client: smtp_client))
          .call(email: "user@example.com", text: "Order accepted")
```

Контракт задан потребностью сценария. Детали SMTP находятся в адаптере; сценарий от них не зависит.

## 2. Рабочий сценарий: оплата заказа

**До:** бизнес-сценарий создаёт SDK банка, собирает его параметры и читает поля ответа. Замена банка требует менять бизнес-логику.

**После:** сценарий использует свой контракт платежей; адаптер переводит его в API банка.

```ruby
class PaymentDeclined < StandardError; end

# Контракт charge:
# принимает сумму в копейках, валюту, токен и ключ идемпотентности;
# возвращает ID платежа или выбрасывает PaymentDeclined при отказе.
class PayOrder
  def initialize(payments:)
    @payments = payments
  end

  def call(order:, token:, attempt_key:)
    raise "Order is not payable" unless order.pending?

    @payments.charge(
      amount_cents: order.total_cents,
      currency: order.currency,
      token: token,
      idempotency_key: attempt_key
    )
  end
end

class BankPayments
  def initialize(client:)
    @client = client
  end

  def charge(amount_cents:, currency:, token:, idempotency_key:)
    result = @client.create_payment(
      amount: amount_cents,
      currency: currency,
      source: token,
      request_id: idempotency_key
    )
    raise PaymentDeclined unless result.approved?

    result.id
  end
end

payments = BankPayments.new(client: bank_client)
payment_id = PayOrder.new(payments: payments).call(
  order: order, token: payment_token, attempt_key: stored_attempt_key
)
```

API банка условный; предполагается поддержка идемпотентности по `request_id`. Ключ сохраняют до вызова и повторно используют для той же попытки. Сохранение результата, вебхуки и сверка неопределённого исхода оплаты требуют отдельного процесса — пример показывает только границу зависимостей.

**DIP и DI:** DI — передача зависимости извне. DIP — зависимость бизнес-кода от своего контракта, который реализуют детали. Передать банковский SDK напрямую в конструктор недостаточно, если сценарий продолжает знать его API.
