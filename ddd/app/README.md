# Два небольших примера: отдельный домен и Rails MVC

Оставили по одному бизнес-действию на модель:

- Заказ: `Orders::Order#confirm!` — только непустой черновик можно подтвердить.
- Товар: `Product#publish!` — только черновик с названием и положительной ценой можно опубликовать.

Повторное действие запрещено. Это два разных объекта для сравнения реализации.
MVC и DDD совместимы: правила внутри Active Record также могут следовать DDD.
Мы сравниваем отделение домена от ORM с привычным Rails MVC, а не «правильный» и «неправильный» код.

## Заказ: отдельная доменная модель

```text
POST /orders/:id/confirm
    ↓
OrdersController#confirm
    ↓
Orders::Application::ConfirmOrder#call
    ↓
repository.with_order(id)         загрузка, транзакция, блокировка
    ↓
Orders::Order#confirm!            бизнес-правила и событие
    ↓
repository.save(order)           записи Active Record, затем commit
    ↓
orders/show.json.jbuilder
```

Сначала прочитайте `app/controllers/orders_controller.rb`, затем
`app/models/orders/application/confirm_order.rb`, затем `app/models/orders/order.rb`.

Прикладной сервис организует действие:

```ruby
@repository.with_order(order_id) do |order|
  order.confirm!
  @repository.save(order)
end
```

Доменный `Order` — обычный Ruby-класс. Его можно тестировать без Rails и базы.
У него нет `save!` или `find`, поэтому `ActiveRecordOrderRepository` переводит
записи таблиц в доменные объекты и обратно. ORM-модели находятся в
`app/models/orders/persistence`.

`LineItem` — неизменяемый снимок позиции с идентификатором, `Money` — объект-значение.
Название, цена и количество передаются при создании заказа. API добавления и изменения
позиций удалён: этот этап посвящён только подтверждению.
Сумма `19900 RUB` означает 199 рублей. В одном заказе одна валюта.

`OrderConfirmed` фиксирует факт подтверждения; событие сохраняется в истории,
но никуда не публикуется. `Order.restore` восстанавливает сохранённое состояние
без повторного выполнения команды.

Блокировка строки заказа удерживается на весь цикл загрузки, изменения и сохранения.
Сценарии изменения должны использовать `with_order`; отдельные `find` и `save`
не защищают от записи устаревшего объекта.

## Товар: обычный Rails MVC

```text
POST /products/:id/publish
    ↓
ProductsController#publish
    ↓
Product.find(id).publish!
    ↓
with_lock → валидации → update! → commit
    ↓
products/show.json.jbuilder
```

Сначала прочитайте `app/controllers/products_controller.rb`, затем `app/models/product.rb`.

Контроллер вызывает модель напрямую:

```ruby
product = Product.find(params[:id])
product.publish!
```

`Product < ApplicationRecord` одновременно представляет товар и запись в таблице.
`publish!` блокирует запись, проверяет исходный статус и вызывает `update!`.
Валидации требуют название и положительную цену при публикации.
Транзакцией, SQL и соединениями управляет Active Record.
Сервис и репозиторий для этого примера не нужны.

В обоих примерах контроллер не содержит бизнес-правил, а JSON формируется Jbuilder.
Отдельный домен позволяет запускать тесты правил без базы, но требует преобразования
объектов и дополнительных классов. MVC короче, но модель связана с ORM.
Для простого действия вариант товара обычно достаточен.

## Ошибки

`ErrorsCommon` формирует единый ответ через `shared/error.json.jbuilder`:

- Заказ или товар не найден — `404`.
- Повторное подтверждение или публикация — `409`.
- Пустой заказ или неверные данные товара — `422`.

Успешные действия возвращают `200`.

## Подготовка и запуск

Ruby 3.4.1, PostgreSQL; настройки БД — `config/database.yml`.
База в этой работе не поднималась, миграции не запускались.

```sh
bundle config set --local path vendor/bundle
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server -b 127.0.0.1 -p 3000
```

Seeds создают два готовых черновика и печатают пути запросов.
Каждый запуск создаёт новые примеры. Используйте выведенные идентификаторы:

```sh
curl -i -X POST http://127.0.0.1:3000/orders/ORDER_ID/confirm
curl -i -X POST http://127.0.0.1:3000/products/PRODUCT_ID/publish
```

Повторите запросы — получите `409`. Для ошибки публикации создайте в Rails console
`Product.create!(name: "Без цены")` и отправьте запрос с его id.
API создания, редактирования, отмены и отправки здесь больше нет.

После миграций также можно выполнить `bundle exec ruby script/orders_demo.rb`.
Он создаёт два примера и вызывает их действия без HTTP.

## Проверки

Без PostgreSQL:

```sh
bundle exec ruby -Itest -e 'Dir["test/domain/*_test.rb"].sort.each { |file| require_relative file }'
bundle exec ruby test/integration/orders_api_test.rb
bin/rails zeitwerk:check
```

HTTP-тесты заказа используют тестовый репозиторий из `test/support`.
Это проверка API и сценария, но не SQL. Для проверки обеих реализаций на PostgreSQL:

```sh
RAILS_ENV=test bin/rails db:create db:migrate
TEST_ORDERS_DATABASE=1 bundle exec ruby test/integration/comparison_database_test.rb
```

Без флага эти тесты пропускаются. Они проверяют успешное сохранение заказа с событием,
публикацию товара, повторную публикацию и сохранение черновика при отказе.
Тесты с настоящей базой ещё не выполнялись.
