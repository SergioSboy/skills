# ISP — Interface Segregation Principle

**Принцип разделения интерфейсов:** клиент не должен зависеть от методов, которые он не использует.

Разделяй большие интерфейсы на небольшие, соответствующие потребностям клиентов.

**Пример:** вместо общего интерфейса с методами печати и сканирования выделяем `Printer` и `Scanner`. Обычный принтер реализует только печать.

**Запомнить:** интерфейсы определяются нуждами клиентов; не заставляй реализации добавлять ненужные методы-заглушки.

---

Примеры на Ruby. Рабочие сценарии упрощены; внешние клиенты передаются при сборке приложения.

## 1. Простой пример: принтер

**До:** общий интерфейс заставляет обычный принтер поддерживать сканирование.

```ruby
class BasicPrinter
  def print(text)
    puts text
  end

  def scan
    raise NotImplementedError, "No scanner"
  end
end
```

**После:** клиент печати требует только `print`, клиент сканирования — только `scan`.

```ruby
class BasicPrinter
  def print(text)
    puts text
  end
end

class Scanner
  def scan = "document bytes"
end

class PrintReceipt
  def call(printer:, text:)
    printer.print(text)
  end
end

PrintReceipt.new.call(printer: BasicPrinter.new, text: "Total: 100")
```

В Ruby интерфейс может быть неявным: важен набор методов, нужных конкретному клиенту. Один класс может поддерживать несколько таких интерфейсов.

## 2. Рабочий сценарий: чтение заказов и администрирование

**До:** страницу заказа связывают с большим административным API, содержащим `find`, `save`, `delete` и `refund`. Адаптер реплики для чтения вынужден добавлять заглушки для записи.

**После:** клиент страницы получает только чтение; клиент отмены — только нужную ему операцию записи.

```ruby
class OrderReader
  def initialize(scope:)
    @scope = scope
  end

  def find(id)
    @scope.find(id)
  end
end

class OrderCanceller
  def initialize(scope:)
    @scope = scope
  end

  def cancel(id)
    @scope.find(id).cancel!
  end
end

class ShowOrder
  def initialize(reader:)
    @reader = reader
  end

  def call(id:)
    order = @reader.find(id)
    { id: order.id, status: order.status }
  end
end

# Rails: scope уже ограничен заказами текущего пользователя.
reader = OrderReader.new(scope: current_user.orders)
ShowOrder.new(reader: reader).call(id: order_id)
```

`ShowOrder` зависит только от `find`; ему не нужны заглушки `save` и `refund`. Правила допустимой отмены остаются в `cancel!`. Разделение интерфейсов само по себе не заменяет проверку прав доступа.
