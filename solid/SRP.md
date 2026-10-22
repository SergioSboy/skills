# SRP — Single Responsibility Principle

**Принцип единственной ответственности:** у класса должна быть одна причина для изменения — одна область ответственности.

**Пример:** расчёт зарплаты, сохранение в БД и формирование отчёта разделены между разными классами: эти задачи меняются по разным причинам.

**Запомнить:** объединяй то, что меняется по одной причине, и разделяй то, что меняется по разным. Это не требование «один метод на класс».

---

Примеры на Ruby. Рабочие сценарии упрощены; внешние клиенты передаются при сборке приложения.

## 1. Простой пример: отчёт

**Проблема:** формат отчёта и способ доставки меняются по разным причинам, но находятся в одном классе.

```ruby
class Report
  def generate(rows)
    rows.map { |row| row.join(",") }.join("\n")
  end

  def deliver(email, text)
    MailClient.send(to: email, body: text)
  end
end
```

**Разделяем ответственности:**

```ruby
require "csv"

class CsvReport
  def generate(rows)
    CSV.generate { |csv| rows.each { |row| csv << row } }
  end
end

class ReportDelivery
  def initialize(mail_client:)
    @mail_client = mail_client
  end

  def deliver(email, text)
    @mail_client.send(to: email, body: text)
  end
end
```

Теперь изменение почтового сервиса не затрагивает формирование CSV. `CSV` также корректно экранирует запятые и кавычки.

## 2. Рабочий сценарий: ежемесячный отчёт о продажах

**До:** один сервис содержит SQL, форматирование CSV и отправку письма. Изменение схемы БД, колонок отчёта или доставки требует править его.

**После:** получение данных, формат и доставка разделены; сценарий связывает их вместе.

```ruby
class SalesQuery
  def call(period:)
    Order.where(status: :paid, paid_at: period)
         .group(:currency).sum(:total_cents).to_a
  end
end

class SendSalesReport
  def initialize(query:, formatter:, delivery:)
    @query = query
    @formatter = formatter
    @delivery = delivery
  end

  def call(period:, email:)
    rows = @query.call(period: period)
    csv = @formatter.generate([["currency", "total_cents"], *rows])
    @delivery.deliver(email, csv)
  end
end

# Rails: Order — модель; mail_client — настроенный почтовый клиент.
service = SendSalesReport.new(
  query: SalesQuery.new,
  formatter: CsvReport.new,
  delivery: ReportDelivery.new(mail_client: mail_client)
)
service.call(period: month_start...next_month_start, email: "finance@example.com")
```

Оркестрация — отдельная ответственность: сценарий определяет порядок действий, но не знает SQL и формат CSV. Для большого отчёта выборку и формирование файла обычно делают порциями.
