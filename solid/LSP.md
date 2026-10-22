# LSP — Liskov Substitution Principle

**Принцип подстановки Барбары Лисков:** объект подтипа должен заменять объект базового типа, сохраняя ожидаемое поведение программы.

Подтип не должен усиливать предусловия, ослаблять постусловия или нарушать инварианты базового типа.

**Пример нарушения:** базовое хранилище обещает сохранять данные, а его подтип «только для чтения» выбрасывает ошибку при сохранении. Для него нужен отдельный контракт чтения.

**Запомнить:** совпадения методов недостаточно — нужно соблюдать их поведенческий контракт.

---

Примеры на Ruby. Рабочие сценарии упрощены; внешние клиенты передаются при сборке приложения.

## 1. Простой пример: птицы

**Нарушение:** базовый класс обещает полёт, но пингвин не способен выполнить этот контракт.

```ruby
class Bird
  def fly = "flying"
end

class Penguin < Bird
  def fly
    raise NotImplementedError, "Penguins cannot fly"
  end
end

# Код ожидает, что любая переданная Bird умеет летать.
def launch(bird)
  bird.fly
end

launch(Penguin.new) # => ошибка вместо обещанного поведения
```

**Исправление:** не объявляем полёт свойством всех птиц.

```ruby
class Bird
end

class FlyingBird < Bird
  def fly = "flying"
end

class Sparrow < FlyingBird
end

class Penguin < Bird
end

launch(Sparrow.new) # => "flying"
# Penguin не передаём в сценарий, требующий FlyingBird.
```

Наследование должно отражать обещанное поведение. В Ruby совместимость проверяется не только родством классов, но и контрактом переданного объекта.

## 2. Рабочий сценарий: замена хранилища файлов

Контракт `read(key)` возвращает **байтовую строку** или выбрасывает `FileMissing`, если файла нет. Клиент должен одинаково работать с памятью и облаком.

**Нарушение:** облачный адаптер возвращает `nil` для отсутствующего файла. Клиент, ожидающий строку или оговорённую ошибку, ломается.

```ruby
class BrokenCloudFiles
  def initialize(client:)
    @client = client
  end

  def read(key)
    @client.download(key)
  rescue CloudSDK::NotFound
    nil # Нарушение: контракт не допускает nil.
  end
end
```

**Исправление:** адаптеры сохраняют одинаковые результаты и семантику ошибок.

```ruby
class FileMissing < StandardError; end

class MemoryFiles
  def initialize(files:)
    @files = files
  end

  def read(key)
    @files.fetch(key) { raise FileMissing, key }.b
  end
end

class CloudFiles
  def initialize(client:)
    @client = client
  end

  def read(key)
    @client.download(key).b
  rescue CloudSDK::NotFound
    raise FileMissing, key
  end
end

def download_size(files, key)
  files.read(key).bytesize
rescue FileMissing
  0
end

download_size(MemoryFiles.new(files: { "a.txt" => "hello" }), "a.txt") # => 5
```

`CloudSDK` — условный SDK, у которого `download` возвращает строку. Сетевые ошибки не маскируются под отсутствие файла. Для проверки взаимозаменяемости один набор контрактных тестов запускают для обоих адаптеров.
