# HAProxy

## Архитектура HAProxy

### Назначение секций `global`, `defaults`, `frontend`, `backend` и `listen`.

Конфигурация HAProxy обычно состоит из нескольких типов секций:

| Секция     | Назначение                                                 |
| ---------- | ---------------------------------------------------------- |
| `global`   | Глобальные параметры всего HAProxy                         |
| `defaults` | Настройки по умолчанию для `frontend`, `backend`, `listen` |
| `frontend` | Принимает входящие подключения от клиентов                 |
| `backend`  | Определяет серверы, на которые HAProxy отправляет запросы  |
| `listen`   | Объединяет функции `frontend` и `backend`                  |

Разберем по пунктам

#### global

Содержит параметры, действующие для всего процесса HAProxy.
`global` задает общие параметры HAProxy:

- расположение и параметры логирования;
- максимальное количество соединений;
- пользователя и группу процесса;
- параметры процессов и потоков;
- системные и административные настройки.

Например:

```
global
    log /dev/log local0
    maxconn 2000
    user haproxy
    group haproxy
```

#### defaults

Задаёт настройки по умолчанию для последующих секций.
Это позволяет не повторять одинаковые настройки в каждом frontend и backend.
Оба раздела наследуют настройки defaults.

```
defaults
    mode http
    timeout connect 5s
    timeout client 30s
    timeout server 30s
```

#### frontend

Отвечает за приём клиентских соединений.

```
frontend web
    bind :80
    default_backend web_servers
```

Основные задачи:

- открыть IP/порт для клиентов;
- принять соединение;
- определить, что делать с запросом;
- выбрать backend;
- передать запрос дальше.


#### backend

Описывает серверы назначения.
HAProxy выбирает сервер и передаёт ему запрос.

В backend можно задавать:

- список серверов;
- алгоритм балансировки;
- health checks;
- ограничения соединений;
- параметры серверов.


```
backend web_servers
    balance roundrobin
    server web1 10.0.0.10:8080
    server web2 10.0.0.11:8080
```

`check` означает, что HAProxy будет проверять доступность серверов.

#### listen

listen объединяет frontend и backend в одной секции.

```
listen stats
    bind :8404
    mode http
    stats enable
```

### Режимы TCP и HTTP.

HAProxy умеет работать на разных уровнях.

#### TCP

HAProxy работает с TCP-соединением и не анализирует HTTP-содержимое.

```
mode tcp
```

Применяется для TCP-сервисов.

HAProxy при этом может балансировать TCP-соединения,
но не знает, какой HTTP URL находится внутри TCP-потока.

#### HTTP

```
mode http
```

HAProxy понимает HTTP-протокол и может анализировать:

- URL;
- HTTP method (GET, POST и т. д.);
- заголовки;
- cookies;
- Host;
- HTTP status.

Можно маршрутизировать запросы.

### Обработка соединений, таймауты и модель процессов и потоков.

Упрощённый жизненный цикл HTTP-запроса:

```
1. Клиент устанавливает соединение
          ↓
2. HAProxy принимает его на frontend
          ↓
3. HAProxy анализирует запрос
          ↓
4. Выбирает backend
          ↓
5. Выбирает сервер
          ↓
6. Устанавливает соединение с сервером
          ↓
7. Передаёт запрос
          ↓
8. Получает ответ
          ↓
9. Передаёт ответ клиенту
```


#### Timeouts

Таймауты нужны, чтобы HAProxy не держал ресурсы бесконечно занятыми.
Время, за которое HAProxy должен установить соединение с сервером.

timeout connect

```
timeout connect 5s
```

Если сервер не отвечает на установление соединения в течение 5 секунд — происходит ошибка.

timeout client

Время ожидания активности со стороны клиента.

```
timeout client 30s
```


timeout server

Время ожидания активности со стороны backend-сервера.

```
timeout server 30s
```

Типичная конфигурация:

```
defaults
    timeout connect 5s
    timeout client 30s
    timeout server 30s
```

#### Модель процессов и потоков

Процессы

Процесс имеет собственное адресное пространство и ресурсы.

HAProxy исторически использовал несколько процессов для масштабирования и изоляции.

Потоки

Современный HAProxy активно использует многопоточность.


### Чтение конфигурации и проверка её командой `haproxy -c`.

При чтении конфигурации удобно двигаться сверху вниз.

```
global
    log /dev/log local0
    maxconn 2000

defaults
    mode http
    timeout connect 5s
    timeout client 30s
    timeout server 30s

frontend web
    bind :80
    default_backend web_servers

backend web_servers
    balance roundrobin
    server web1 10.0.0.10:8080 check
    server web2 10.0.0.11:8080 check
```

Перед запуском или перезагрузкой HAProxy конфигурацию можно проверить:

```
haproxy -c -f /etc/haproxy/haproxy.cfg
```

## Базовое проксирование

`inventory.yml`, `haproxy.yml`

Создан inventory Ansible.

Добавлен хост haproxy.

Указан IP-адрес сервера.

Указан пользователь, под которым Ansible подключается к серверу.

Создан основной Ansible playbook.

Подключена роль haproxy.

Включено выполнение задач от имени root.

`tasks/main.yml`

Устанавливаем пакет HAProxy.

Копируем сгенерированную конфигурацию на сервер.

### Настройка frontend и backend для тестового HTTP-сервиса.

`templates/haproxy.cfg.j2`

```
                    HTTP :80
Client ──────────────────────────> HAProxy
                                      │
                                      │
                              backend http_back
                                  /          \
                                 /            \
                                ▼              ▼
                         web1:8080        web2:8080
```

frontend принимает соединение. То есть HAProxy слушает TCP-порт 80.

HAProxy распределяет запросы между web1 и web2.

check включает health check серверов.


### Передача `Host`, `X-Forwarded-For` и `X-Forwarded-Proto`.

#### Host

Заголовок Host сохраняется при обычном HTTP-проксировании, поэтому upstream получает имя хоста, указанное клиентом.

#### X-Forwarded-For

```
option forwardfor
```

option forwardfor позволяет передать backend реальный IP-адрес клиента через HTTP-заголовок X-Forwarded-For.

#### X-Forwarded-Proto

```
http-request set-header X-Forwarded-Proto http
```

X-Forwarded-Proto сообщает backend, какой протокол использовал клиент при обращении к HAProxy.


### Настройка connect, client и server timeouts.

#### Таймауты

В конфигурации заданы три основных таймаута: connect — подключение к upstream, client — взаимодействие с клиентом, server — взаимодействие с backend-сервером.


### Проверка поведение при недоступности upstream.

У нас указано:

```
server web1 10.0.0.11:8080 check
server web2 10.0.0.12:8080 check
```

Директива check включает проверку доступности backend-серверов.
Недоступный сервер исключается из балансировки до тех пор,
пока снова не станет доступен.

## Балансировка нагрузки

### алгоритмы round-robin, least connections, source и random.

Алгоритм балансировки определяет, какой backend-сервер получит очередной запрос или соединение.

`roundrobin`

Самый простой вариант — серверы используются по очереди.

```
backend http_back
    balance roundrobin

    server web1 10.0.0.11:8080 check
    server web2 10.0.0.12:8080 check
```

roundrobin последовательно распределяет запросы между доступными серверами backend. Это простой способ равномерного распределения нагрузки между одинаковыми серверами.

`leastconn`

Алгоритм выбирает сервер, у которого меньше всего активных соединений.

```
backend http_back
    balance leastconn

    server web1 10.0.0.11:8080 check
    server web2 10.0.0.12:8080 check
```

`source`

При source сервер выбирается на основании IP-адреса клиента.

```
backend http_back
    balance source

    server web1 10.0.0.11:8080 check
    server web2 10.0.0.12:8080 check
```

source использует IP-адрес клиента для выбора backend-сервера.
Это позволяет получить некоторую привязку клиента к серверу без cookie.


leastconn направляет новое соединение на сервер с наименьшим количеством активных соединений.
Алгоритм полезен при неодинаковой длительности запросов.


`random`

random выбирает сервер случайным образом с учётом его веса.

```
backend http_back
    balance random

    server web1 10.0.0.11:8080 check
    server web2 10.0.0.12:8080 check
```

random выбирает backend случайным образом. Вес сервера влияет на вероятность его выбора.


### веса серверов и резервный backend.

Можно указать, что серверы имеют разную производительность.

```
backend http_back
    balance roundrobin

    server web1 10.0.0.11:8080 check weight 3
    server web2 10.0.0.12:8080 check weight 1
```

weight позволяет учитывать различную производительность серверов.
Сервер с большим весом получает большую долю нагрузки при алгоритмах, учитывающих вес.

#### Резервный backend-сервер

Можно определить сервер как резервный с помощью backup.

```
backend http_back
    balance roundrobin

    server web1 10.0.0.11:8080 check
    server web2 10.0.0.12:8080 check
    server web_backup 10.0.0.13:8080 check backup
```

Директива backup обозначает сервер как резервный.
Он используется, когда основные серверы backend недоступны.

### sticky sessions и их ограничения.

#### sticky sessions

Иногда приложение хранит состояние пользовательской сессии локально на конкретном backend-сервере.

```
backend http_back
    balance roundrobin

    cookie SERVERID insert indirect nocache

    server web1 10.0.0.11:8080 check cookie web1
    server web2 10.0.0.12:8080 check cookie web2
```

Для таких приложений может потребоваться session persistence, то есть привязка клиента к определённому серверу.

HAProxy устанавливает cookie, например:
```
SERVERID=web1
```

Sticky sessions сохраняют привязку клиента к backend-серверу,
но могут приводить к неравномерному распределению нагрузки и не устраняют проблему потери состояния при отказе сервера.



### распределение запросов под нагрузкой.

выбор алгоритма зависит от характера нагрузки

Разные алгоритмы по-разному распределяют соединения.
roundrobin не учитывает текущую загрузку,
а leastconn ориентируется на количество активных соединений.
Поэтому выбор алгоритма зависит от характера приложения и нагрузки.

## Health checks

### Настройка TCP- и HTTP-проверки состояния

Самый простой health check:

```
server web1 10.0.0.11:8080 check
```

TCP health check проверяет, доступен ли сервер и принимает ли он соединения на указанном TCP-порту.
Директива check включает проверку состояния сервера.

Директива check включает проверку состояния сервера.

добавляем:

```
option httpchk GET /health
```

HTTP health check проверяет доступность HTTP-приложения путём отправки специального HTTP-запроса, например GET /health.

### Проверка ожидаемого статуса и содержимого ответа

#### проверка HTTP status

```
http-check expect status 200
```

Теперь недостаточно просто получить HTTP-ответ.

HAProxy ожидает:
```
HTTP/1.1 200 OK
```

#### проверка содержимого ответа

```
http-check expect string OK
```

Одного HTTP-кода иногда недостаточно.

http-check expect string OK дополнительно проверяет содержимое HTTP-ответа.
Сервер считается исправным только при наличии ожидаемой строки.

### интервалы, пороги отказа и восстановления

```
default-server inter 5s
```

Это означает, что проверки выполняются примерно каждые 5 сеунд 

```
fall 3
```

Это означает, что сервер не будет считаться неисправным после одной случайной ошибки.
Нужно получить 3 последовательных неуспешных проверки.


```
rise 2
```

После восстановления сервера HAProxy не возвращает его в балансировку сразу после первой успешной проверки.
rise 2 задаёт количество последовательных успешных проверок, необходимых для возврата сервера в рабочее состояние.

### исключать неисправный узел и автоматически возвращать его в балансировку

ри достижении порога fall HAProxy автоматически исключает неисправный сервер из балансировки. Новые запросы направляются на доступные серверы.

После восстановления сервера и прохождения заданного количества успешных проверок HAProxy автоматически переводит его обратно в состояние UP и возвращает в балансировку.


## ACL и маршрутизация

### ACL по домену, пути, методу и заголовкам.

#### по домену

Для проверки Host используем:

```
acl host_app hdr(host) -i app.example.com
acl host_api hdr(host) -i api.example.com
```

ACL hdr(host) используется для маршрутизации запросов в зависимости от значения HTTP-заголовка Host. Это позволяет обслуживать несколько доменов через один HAProxy.

#### по пути

Для проверки URL используем:

```
acl path_api path_beg /api
acl path_admin path_beg /admin
```

ACL path_beg позволяет определить маршрут по началу URL. Например, все запросы /api/* можно отправлять в API backend, а /admin/* — в административный backend.

#### по HTTP-методу

```
acl method_get method GET
acl method_post method POST
```

ACL method позволяет маршрутизировать запросы в зависимости от HTTP-метода: GET, POST, PUT, DELETE и т. д.

#### по HTTP-заголовку

```
acl has_api_key req.hdr(X-API-Key) -m found
```

ACL req.hdr() позволяет проверять HTTP-заголовки запроса. Это можно использовать для маршрутизации или реализации дополнительных правил доступа.

### Маршрутизация запросы в разные backend.

Теперь объединяем ACL и use_backend.

```
use_backend api_backend if host_api path_api
```

use_backend используется для выбора backend на основании ACL. Условие после if определяет,
при каких обстоятельствах запрос направляется в конкретный backend.



### redirect с HTTP на HTTPS.

В frontend http_front добавили:

```
http-request redirect scheme https code 301
```

На HTTP frontend настроен redirect с кодом 301 на HTTPS.
Это заставляет клиентов использовать защищённое соединение.

#### HTTPS frontend

```
frontend https_front
    bind *:443 ssl crt /etc/haproxy/certs/example.pem
```

Сертификат для лабораторного HTTPS frontend генерируется автоматически средствами Ansible/OpenSSL.
Сертификат является self-signed и предназначен для тестирования, а не для production.

### понятный ответ для неизвестного маршрута.

```
backend not_found_backend
    http-request return status 404 \
        content-type "text/plain" \
        lf-string "404 Not Found: route is not configured"
```

Для запросов, которые не соответствуют ни одному ACL,
настроен отдельный default_backend,
возвращающий HTTP 404 и понятное текстовое сообщение.


## TLS

### Настроить TLS termination и корректную цепочку сертификатов.

#### TLS termination

При TLS termination HTTPS завершается на HAProxy

То есть HAProxy:

1. принимает TLS-соединение;
2. использует сертификат;
3. расшифровывает запрос;
4. применяет ACL и маршрутизацию;
5. отправляет запрос backend.

```
frontend https_front
    bind *:443 ssl crt /etc/haproxy/certs/

    http-request set-header X-Forwarded-Proto https

    default_backend app_backend
```

#### Цепочка сертификатов

TLS termination настроен на HAProxy.
Сертификат, приватный ключ и необходимые промежуточные сертификаты объединены в PEM-файл. HAProxy использует этот файл для обработки HTTPS-соединений.

### Ограничить версии протокола и слабые cipher suites.

Разрешаем только современные версии:

```
ssl-default-bind-min-ver TLSv1.2
ssl-default-bind-max-ver TLSv1.3
```

Также зададим допустимые cipher suites:

```
ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384

ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
```

### Настроить SNI для нескольких доменов.

```
frontend https_front
    bind *:443 ssl crt /etc/haproxy/certs/

    acl host_app hdr(host) -i app.example.com
    acl host_api hdr(host) -i api.example.com

    use_backend app_backend if host_app
    use_backend api_backend if host_api

    default_backend not_found_backend
```

### Изучить TLS passthrough и повторное шифрование до backend.

При passthrough HAProxy не расшифровывает TLS.

```
frontend https_passthrough
    mode tcp
    bind *:443

    default_backend https_servers

backend https_servers
    mode tcp

    server web1 10.0.0.11:443 check
    server web2 10.0.0.12:443 check
```

TLS passthrough выполняется в TCP-режиме.
HAProxy не завершает TLS-соединение,
а передаёт зашифрованный трафик непосредственно backend.
Это позволяет сохранить end-to-end TLS,
но ограничивает возможности HTTP-маршрутизации.

#### TLS re-encryption

HAProxy может анализировать HTTP и одновременно поддерживать шифрование трафика до backend.

```
backend app_backend
    balance roundrobin

    server app1 10.0.0.11:8443 ssl verify none check
    server app2 10.0.0.12:8443 ssl verify none check
```

TLS re-encryption означает, что HAProxy завершает TLS-соединение клиента,
обрабатывает HTTP-запрос и устанавливает новое TLS-соединение с backend.
Для безопасной production-конфигурации сертификат backend должен проверяться через доверенный CA.


## Управление трафиком

#### Настройка лимитов соединений и очередей

У HAProxy есть несколько уровней ограничения соединений.

```
global
    maxconn 2048
```

Параметр maxconn задаёт максимальное количество одновременных соединений, которые HAProxy может обслуживать.
Ограничение защищает процесс от чрезмерной нагрузки.


#### Лимит на frontend

```
frontend https_front
    bind *:443
    maxconn 1000

    default_backend app_backend
```

#### Лимит на backend

```
backend app_backend
    maxconn 300

    server app1 10.0.0.11:8080 check
    server app2 10.0.0.12:8080 check
```

### Очереди

HAProxy может удерживать запросы в очереди до освобождения ресурсов.

```
defaults
    timeout queue 10s
```

ЕОчередь позволяет временно удерживать запросы, когда backend достиг лимита соединений.
timeout queue ограничивает время ожидания запроса в очереди.

### rate limiting через stick tables.

```
frontend https_front
    bind *:443 ssl crt /etc/haproxy/certs/

    stick-table type ip size 100k expire 10s store http_req_rate(10s)

    http-request track-sc0 src

    http-request deny deny_status 429 \
        if { sc_http_req_rate(0) gt 100 }

    default_backend app_backend
```

Для rate limiting используется stick-table.
HAProxy сохраняет количество запросов от каждого IP за определённый интервал времени.
При превышении установленного порога запрос отклоняется с кодом HTTP 429 Too Many Requests

### безопасные retry только для подходящих операций.

```
backend app_backend
    balance roundrobin

    option redispatch

    retries 2

    server app1 10.0.0.11:8080 check
    server app2 10.0.0.12:8080 check
```

Retry следует применять только там,
где повторная операция не приводит к нежелательным побочным эффектам.
Особенно осторожно нужно относиться к POST и другим изменяющим состояние операциям.

### connection reuse, keep-alive и влияние буферизации.

```
defaults
    mode http

    timeout client 30s
    timeout server 30s
    timeout http-keep-alive 10s
```

timeout http-keep-alive определяет, сколько HAProxy будет ждать следующий HTTP-запрос по уже установленному соединению.


HAProxy может повторно использовать соединения с backend. 

Это снижает нагрузку на backend, потому что не нужно постоянно создавать новые TCP-соединения.

Особенно полезно при большом количестве коротких HTTP-запросов.

#### Буферизация

Буферизация позволяет HAProxy временно хранить данные и управлять различием скорости передачи между клиентом и backend. Большие буферы увеличивают потребление памяти, поэтому их размер необходимо подбирать с учётом количества одновременных соединений.

## Безостановочное обновление



### graceful reload без разрыва активных соединений

```
systemctl restart haproxy
```

может привести к разрыву активных соединений.

При graceful reload старый процесс HAProxy перестаёт принимать новые соединения, но продолжает обслуживать уже существующие.
Новый процесс принимает новые подключения.

### Настраиваем Runtime API / stats socket

Для управления HAProxy удобно включить Unix socket.

```
global
    stats socket /run/haproxy/admin.sock mode 660 level admin
```

Runtime API позволяет управлять работающим экземпляром HAProxy без изменения основного конфигурационного файла и без перезапуска процесса.
Для доступа можно использовать Unix stats socket.

### Вывод сервера из балансировки

Перед обслуживанием сервер можно перевести его в состояние drain.
Новые соединения больше не направляются, но существующие соединения получают возможность завершиться.

```
echo "set server app_backend/app1 state drain" \
  | socat stdio /run/haproxy/admin.sock
```

#### READY / DRAIN / MAINT

READY

Сервер участвует в балансировке

DRAIN

Новые соединения не направляются на сервер, но существующие продолжают обслуживаться.

MAINT

Сервер полностью исключён из балансировки.

#### сценарий обновления и отката конфигурации.

Шаг 1 - DRAIN

```
echo "set server app_backend/app1 state drain" \
  | socat stdio /run/haproxy/admin.sock
```

Шаг 2 - Дожидаемся завершения соединений

```
echo "show servers state" \
  | socat stdio /run/haproxy/admin.sock
```

Шаг 3 - обновить приложение

```
systemctl restart my-app
```

Шаг 4 - проверить health check

Шаг 5 - вернуть сервер

```
echo "set server app_backend/app1 state ready" \
  | socat stdio /run/haproxy/admin.sock
```


#### Обновление HAProxy

```
haproxy -c -f /etc/haproxy/haproxy.cfg
```

```
systemctl reload haproxy
```


## Наблюдаемость

### Структурированные HTTP-логи

Для начала включим HTTP logging.

```
global
    log /dev/log local0
    log /dev/log local1 notice
```


```
defaults
    mode http
    log global
    option httplog

    timeout connect 5s
    timeout client 30s
    timeout server 30s
```

Для систем мониторинга удобнее JSON.

```
defaults
    mode http
    log global

    log-format '{"timestamp":"%t","client_ip":"%ci","frontend":"%f","backend":"%b","server":"%s","method":"%HM","path":"%HP","status":%ST,"bytes":%B,"request_time_ms":%TR,"connect_time_ms":%Tc,"response_time_ms":%Tr}'
```


### Stats page

```
listen stats
    bind *:8404

    mode http

    stats enable
    stats uri /stats

    stats refresh 10s
```

### Prometheus

Для Prometheus нам нужен endpoint с метриками.

В зависимости от версии HAProxy можно использовать встроенный Prometheus endpoint.

```
frontend prometheus
    bind *:8405

    http-request use-service prometheus-exporter

    acl prometheus_network src 10.0.0.0/8
    http-request deny unless prometheus_network
```

#### Алерт: backend недоступен

```
groups:
  - name: haproxy
    rules:
      - alert: HAProxyBackendDown
        expr: haproxy_backend_active_servers == 0
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "No HAProxy backend servers available"
          description: "Backend {{ $labels.proxy }} has no active servers."
```

#### Алерт на рост HTTP ошибок

```
- alert: HAProxyHigh5xxRate
  expr: |
    rate(haproxy_backend_http_responses_total{code="5xx"}[5m])
    > 1
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "High HAProxy 5xx rate"
    description: "HAProxy is returning an elevated number of 5xx responses."
```

## Безопасность

### Минимальные привилегии

HAProxy настроен для работы с отдельным системным пользователем:

```haproxy
global
    user haproxy
    group haproxy
```

Системный пользователь не должен использовать интерактивную оболочку.

Проверить пользователя процесса можно:

```bash
ps -eo user,group,pid,cmd | grep haproxy
```

Использование отдельного непривилегированного пользователя уменьшает последствия возможной компрометации процесса.

### Защита административных интерфейсов

Runtime API настроен через Unix socket:

```haproxy
stats socket /run/haproxy/admin.sock mode 660 level admin
```

Socket не публикуется в сеть и ограничивается правами файловой системы.

Stats page также ограничивается доверенной сетью:

```haproxy
acl allowed_network src 10.0.0.0/8
http-request deny unless allowed_network
```

Дополнительно Stats page защищается Basic Authentication. Пароль хранится в Ansible Vault, а не в открытом конфигурационном файле.

### Защита логов

В структурированные HTTP-логи включаются только необходимые для диагностики данные:

* IP клиента;
* HTTP method;
* путь;
* frontend/backend;
* сервер;
* HTTP status;
* время обработки;
* размер ответа.

Не следует журналировать:

* `Authorization`;
* cookies;
* session tokens;
* API keys;
* пароли;
* JWT и другие секреты.

Это предотвращает попадание секретов в системы централизованного хранения логов.

### Безопасные HTTP-заголовки

Для ответов добавлены security headers:

```haproxy
http-response set-header X-Content-Type-Options nosniff
http-response set-header X-Frame-Options SAMEORIGIN
http-response set-header Referrer-Policy strict-origin-when-cross-origin
```

Если приложение полностью работает через HTTPS, может использоваться HSTS:

```haproxy
http-response set-header Strict-Transport-Security "max-age=31536000"
```

Набор заголовков должен соответствовать требованиям конкретного приложения.

### Ограничение размера запросов

Для защиты backend от чрезмерно больших HTTP-запросов установлен лимит размера тела:

```haproxy
http-request deny deny_status 413 if { req.body_size gt 10485760 }
```

В данном примере максимальный размер составляет 10 MB.

Если запрос превышает лимит, HAProxy возвращает:

```text
413 Payload Too Large
```

и не передаёт такой запрос в backend.



