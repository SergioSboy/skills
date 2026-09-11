# mTLS

- В отличие от обычного TLS, аутентифицируются обе стороны:
    - сервер предъявляет server certificate
    - клиент предъявляет client certificate

- Нужен CA, которому доверяют обе стороны.
    - ca.crt — публичный сертификат CA, можно распространять
    - ca.key — приватный ключ CA, хранить в секрете

- Серверный сертификат:
    - server.crt
    - server.key
    - EKU: serverAuth

- Клиентский сертификат:
    - client.crt
    - client.key
    - EKU: clientAuth

- Nginx:
  ssl_client_certificate /etc/nginx/certs/ca.crt;
  ssl_verify_client on;

- Клиент передаёт:
  client.crt + client.key
  и использует ca.crt для проверки server.crt

- Для каждого клиента лучше выпускать отдельный сертификат.

- TLS можно разделить по портам:
  :443  → обычный TLS
  :8443 → TLS + mTLS

- CA не обязательно должен быть публичным:
  для внутреннего mTLS можно использовать собственный CA.

# КОМАНДЫ

## Сертификаты сервера

### Проверка СА

```bash
openssl x509 -in ca.crt -noout -subject -issuer -dates
```

### Создание ключа

```bash
openssl genrsa -out server.key 4096
```

### CSR

```bash
openssl req -new \
  -key server.key \
  -out server.csr \
  -subj "/CN=example.com"
```

### Подписываем CSR
```bash
openssl x509 -req \
  -in server.csr \
  -CA ca.crt \
  -CAkey ca.key \
  -CAcreateserial \
  -out server.crt \
  -days 825 \
  -sha256 \
  -extfile server.ext
```

## Сертификаты клиента

### Создание ключа

```bash
openssl genrsa -out client.key 4096
```

### CSR

```bash
openssl req -new \
  -key client.key \
  -out client.csr \
  -subj "/CN=my-client"
```

### Подписываем CSR

```bash
openssl x509 -req \
  -in client.csr \
  -CA ca.crt \
  -CAkey ca.key \
  -CAcreateserial \
  -out client.crt \
  -days 825 \
  -sha256 \
  -extfile client.ext
```

# Список литературы
https://habr.com/ru/articles/1025856/ - руководство по настройке mTLS