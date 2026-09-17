## Основные понятия

### Resource Owner, Client, Authorization Server и Resource Server

Перечислены основные участники OAuth 2.0

- Resource Owner — владелец ресурса, обычно пользователь;
- Client — приложение, которое хочет получить доступ к ресурсу от имени пользователя;
- Authorization Server (AS) — сервер, который аутентифицирует пользователя и выдаёт токены;
- Resource Server (RS) — API/сервер, который хранит защищённые данные и проверяет access token.

### Аунтефикация и авторизация. Какие бывают?

Аутентификация (Authentication) — «Кто ты?»

Определяет личность пользователя.

Для этого используются:

- логин + пароль;
- MFA;
- passkey;
- Session Cookie;
- OpenID Connect.

Авторизация (Authorization) — «Что тебе разрешено?»
Определяет доступ к ресурсам.

OAuth 2.0 — протокол авторизации, а не аутентификации. Для аутентификации поверх OAuth 2.0 используется OpenID Connect (OIDC)

### Назначение access token, refresh token и ID token

Access token — токен, с которым Client обращается к Resource Server.

Например:

```
Authorization: Bearer <access_token>
```

- ограниченный срок жизни;
- определённые scopes;
- ограниченный доступ к API.

access token предназначен для Resource Server, а не для идентификации пользователя в Client.

---

Refresh token -  позволяет получить новый access token после его истечения, не заставляя пользователя снова проходить авторизацию.

---

ID token — понятие из OpenID Connect.

Он сообщает Client:

«Вот информация о пользователе, который прошёл аутентификацию».

sub = уникальный ID пользователя
iss = кто выдал токен
aud = для какого Client
exp = когда истекает

### Scopes, claims, consent и redirect URI

Scope — запрашиваемый уровень доступа.

Например:

```text
openid
profile
email
read:orders
write:orders
```

Пользователь может увидеть экран consent и подтвердить или отклонить доступ.

---

Claim — отдельное утверждение/свойство о субъекте.

```text
{
  "sub": "12345",
  "name": "Ivan",
  "email": "ivan@example.com"
}
```

Claims могут находиться, например, в ID token или предоставляться через UserInfo Endpoint в OIDC.

---

Consent — согласие пользователя на предоставление Client определённых разрешений.

```text
Приложение хочет:

прочитать ваш email;
посмотреть профиль;
получить доступ к календарю.
```

Пользователь подтверждает или отклоняет запрос.

---

Redirect URI — адрес, куда Authorization Server возвращает пользователя после авторизации.

Authorization Server должен проверять redirect URI.

Почему это важно: неправильная проверка redirect URI может привести к краже authorization code или токенов.


## OAuth 2.0

### Authorization Code, Client Credentials и Device Authorization Grant.

Authorization Code Grant

Основной flow для веб-приложений и пользовательской авторизации.

Идея: сначала Client получает временный authorization code, а затем обменивает его на токены.

Преимущества:

токены не передаются через браузер напрямую;
хорошо подходит для OIDC;
вместе с PKCE безопасен для public clients.

---

### Назначение PKCE и обязательность его применения для публичных клиентов.

PKCE (Proof Key for Code Exchange) защищает Authorization Code от перехвата.

Client перед началом авторизации создаёт:

```text
ode_verifier → секретное случайное значение
      ↓
code_challenge → производное от verifier
```

### Причины отказа от Implicit Grant и Resource Owner Password Credentials 

Implicit Grant возвращал access token непосредственно через browser redirect.
Токен оказывается в окружении браузера, где выше риск утечки через историю, URL, сторонние скрипты и другие механизмы.

---

При ROPC приложение получает логин и пароль пользователя напрямую:

```
User → Client → username + password
```

Это плохо, потому что Client должен получить пароль пользователя.

Проблемы:

- Client видит credentials пользователя;
- сложнее использовать MFA и современные методы аутентификации;
- пользователь вынужден доверять паролю стороннему приложению;
- хуже разделяется ответственность между Client и Authorization Server.

Современные рекомендации:

Не использовать ROPC. Использовать Authorization Code + PKCE.

### Сравнение confidential и public clients.

Public Client и Confidential Client — это типы приложений в OAuth 2.0,
различающиеся тем, может ли приложение безопасно хранить секрет.

Confidential Client
Это приложение, которое работает на сервере, и его секреты не видны пользователю.

Например:

- Серверное веб-приложение;
- backend;
- отдельный сервис.


---

Public Client
Это приложение, код которого находится у пользователя, поэтому секрет внутри него нельзя считать секретом.

Например: 
- SPA
- desktop-приложение
- мобильное приложение

| Public Client                          | Confidential Client               |
| -------------------------------------- | --------------------------------- |
| Не может надёжно хранить секрет        | Может безопасно хранить секрет    |
| SPA                                    | Backend                           |
| Mobile App                             | Server-side Web App               |
| Desktop App                            | Backend Service                   |
| Client secret нельзя считать секретным | Client secret может быть секретом |


## OpenID Connect

OpenID Connect — это слой аутентификации поверх OAuth 2.0.

OAuth отвечает:

«Можно ли приложению получить доступ к ресурсу?»

OIDC добавляет:

«Кто этот пользователь?»

Главный результат OIDC-аутентификации — ID Token.

### Discovery, UserInfo и стандартные OIDC scopes.

Discovery

Discovery позволяет приложению автоматически узнать настройки OIDC-провайдера.

---

UserInfo

UserInfo Endpoint — endpoint, через который Client может получить информацию о пользователе.

Запрос обычно выполняется с access token:

```
Authorization: Bearer <access_token>
```

Ответ содержит claims:

```
{
  "sub": "123456",
  "name": "Ivan",
  "email": "ivan@example.com"
}
```

---

Стандартные OIDC scopes

Для доступа к определённым данным нужны соответствующие scopes.

| Scope     | Что даёт                              |
| --------- |---------------------------------------|
| `openid`  | включает OIDC-аутентификацию          |
| `profile` | базовая информация о пользователе     |
| `email`   | email и информация о его подтверждении |
| `address` | адрес                                 |
| `phone`   | номер телефона                        |

openid обязателен, если мы используем именно OpenID Connect.

### содержимое и назначение ID token.

ID Token — обычно JWT, который сообщает Client информацию об успешной аутентификации пользователя.

Пример payload:

```
{
  "iss": "https://auth.example.com",
  "sub": "12345",
  "aud": "my-client",
  "exp": 1750000000,
  "iat": 1749999000,
  "nonce": "abc123"
}
```

Важные claims:

- iss — кто выпустил токен;
- sub — уникальный идентификатор пользователя;
- aud — для какого Client предназначен токен;
- exp — время истечения;
- iat — время выпуска;
- nonce — связывает токен с конкретным запросом авторизации.

ID Token предназначен Client для информации об аутентификации. Для вызова API используется access token.

### проверять issuer, audience, подпись, срок действия и nonce.

При получении ID Token нельзя просто декодировать JWT и доверять его содержимому.

1. Issuer

    ```
    iss == ожидаемый Authorization Server
    ```
    
    Иначе токен мог быть выпущен другим сервером.

2. Audience

    Токен должен предназначаться именно твоему Client.

3. Подпись

    Проверить криптографическую подпись JWT с помощью публичного ключа провайдера (jwks_uri).

4. Срок действия

    Просроченный токен использовать нельзя.
5. Nonce
   
    Значение nonce в ID Token должно совпадать с тем nonce, который Client отправлял в Authorization Request.

### назначение параметров `state`, `nonce` и `prompt`.

1. state

   state защищает OAuth/OIDC flow от CSRF и подмены ответа авторизации.

2. nonce
   
   nonce используется именно в OIDC для связывания ID Token с конкретным authentication request.

3. prompt
   
   prompt управляет поведением Authorization Server при аутентификации.


## JWT и непрозрачные токены

JWT (JSON Web Token) — формат токена,
содержащего JSON-данные (claims) и криптографическую подпись.

### структура JWT и алгоритмы подписи.

```
xxxxx.yyyyy.zzzzz
```

JWT состоит из 3 частей:

```
HEADER.PAYLOAD.SIGNATURE
```

Например:

```
// Header
{
  "alg": "RS256",
  "typ": "JWT"
}
```

```
// Payload
{
  "sub": "123",
  "iss": "https://auth.example.com",
  "aud": "my-api",
  "exp": 1750000000
}
```

```
Signature
```


payload JWT обычно не зашифрован, а просто закодирован Base64URL. Поэтому его содержимое может прочитать любой, у кого есть токен.


---

Алгоритмы подписи

Подпись позволяет проверить выпущен ли токен, тот кто владеет соответствующим ключом и 
его содержимое не изменилось.

Симметричное и  ассимитричное шифрование см в разделе TLS/mTLS

```
HS256
```

```
RS256
ES256
EdDSA
```


### JWK, JWKS и ротацию ключей.

JWK (JSON Web Key) — описание одного криптографического ключа в JSON.

```
{
  "kty": "RSA",
  "kid": "key-123",
  "alg": "RS256"
}
```

JWKS (JSON Web Key Set) — набор JWK.

```
JWKS
 ├── key-123
 ├── key-456
 └── key-789
```

Authorization Server обычно публикует JWKS endpoint.

Resource Server получает оттуда публичные ключи и использует их для проверки JWT.

---

Ротация ключей

Ключи нельзя использовать бесконечно.

При key rotation Authorization Server:

```
Старый ключ
    ↓
Новый ключ
    ↓
Новые JWT подписываются новым ключом
```

JWT содержит kid:

```
{
  "alg": "RS256",
  "kid": "key-456"
}
```

Resource Server смотрит на kid и выбирает соответствующий публичный ключ из JWKS.

### Сравнение локальной проверки JWT с token introspection.

Локальная проверка JWT

Если API знает публичный ключ, оно может проверить JWT самостоятельно, без обращения к Authorization Server


Плюсы:

- быстро;
- не нужен сетевой запрос к Authorization Server;
- хорошо масштабируется.

Минус:

- Если JWT уже выдан, его сложно немедленно отозвать.

---

Token Introspection

Introspection — API спрашивает Authorization Server

Плюсы:

- можно централизованно отзывать токены;
- Authorization Server всегда знает актуальное состояние.

Минусы:

- дополнительный network request;
- нагрузка на Authorization Server;
- API зависит от его доступности.


### Не использовать содержимое неподписанного или непроверенного токена.

Нельзя доверять содержимому JWT до проверки его подлинности.

Нельзя делать так:

```
получили JWT
    ↓
прочитали payload
    ↓
"role": "admin"
    ↓
дали доступ
```

Правильно:

```
JWT
 ↓
проверить подпись
 ↓
проверить alg / допустимый алгоритм
 ↓
проверить iss
 ↓
проверить aud
 ↓
проверить exp / другие необходимые claims
 ↓
только теперь доверять claims
```


## Безопасность потоков


### Защититься от CSRF, authorization code interception и mix-up атак.

CSRF

CSRF — злоумышленник пытается заставить браузер пользователя выполнить OAuth-действие, которое пользователь сам не инициировал.

Для защиты используется параметр state

---

Authorization Code Interception

Злоумышленник перехватывает authorization code до того, как Client успевает обменять его на токен.

PKCE → защита authorization code от перехвата.

---

Mix-Up Attack

При mix-up attack Client путает Authorization Server'ы.

Атакующий пытается заставить Client принять ответ от неправильного Authorization Server.

Защита:

- корректно проверять iss (issuer);
- использовать корректно настроенный Discovery;
- связывать запрос с конкретным Authorization Server;
- использовать state и другие предусмотренные протоколом механизмы.

### Настроить точное сравнение redirect URI.

Redirect URI должен проверяться точно, а не приблизительно.
Redirect URI должен соответствовать заранее зарегистрированному значению.

### Ограничить срок жизни токенов и права scopes.

Access token не должен жить дольше, чем необходимо.
Если access token украден, короткий lifetime уменьшает окно атаки.

Не нужно давать приложению больше прав, чем ему необходимо.

```
Каждому Client — только необходимые права.
```

### Реализовать безопасное хранение и ротацию client secrets.

Client secret — действительно секретная информация.

Для confidential client его нельзя:

- хранить в frontend JavaScript;
- помещать в Git;
- отправлять пользователю;
- записывать в логи;
- встраивать в мобильное приложение.

Для этого стоит использовать `Secret Manager`

Secret не должен существовать вечно.


## Управление сессиями и токенами

### Обновление access token через refresh token.

Access Token обычно живёт недолго. Когда он истекает, Client использует Refresh Token, чтобы получить новый.
Refresh Token нельзя отправлять в Resource Server/API как access token.

При Refresh Token Rotation старый refresh token после использования становится недействительным, а сервер выдаёт новый.

### Refresh token rotation и обнаружение повторного использования.

Authorization Server может обнаружить reuse и инвалидировать соответствующую цепочку/сессию.

Если refresh token уже был использован и внезапно используется снова — вероятна кража.

### Отзыв токенов и завершение пользовательской сессии.

Revocation — принудительно сделать токен недействительным до его естественного истечения.

Особенно важно отзывать/инвалидировать refresh tokens при:

- logout;
- компрометации аккаунта;
- смене credentials;
- подозрительной активности.

При выходе желательно:

- удалить локальную сессию/куки;
- инвалидировать refresh token;
- при необходимости завершить сессию у OIDC Provider.

### повторная аутентификацию для критичных операций.

Для критичных операций одной существующей сессии иногда недостаточно.

Особенно для:

- смены пароля;
- изменения MFA;
- удаления аккаунта;
- изменения платёжных данных;
- выдачи высоких привилегий.

В OIDC можно потребовать более свежую/сильную аутентификацию, например через prompt=login или механизмы max_age и acr.

## Authorization Server

### keycloak

описал плейбук для разворачивания keycloak

- добавил клиента app
- добавил user/admin (обязательно заполнить все поля!)
- добавил роли


### выдача token

```
curl -X POST "http://192.168.64.10/realms/app/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "client_id=rails-api" \
  -d "username=admin" \
  -d "password=1234"
```

### проверка запроса для приложения

получаем токен
```
TOKEN=$(curl -s -X POST \             
  "http://192.168.64.10/realms/app/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "client_id=rails-api" \
  -d "username=admin" \
  -d "password=1234" \
```


делаем запрос в приложение

```
curl http://localhost:3000/api/v1/me \
  -H "Authorization: Bearer $TOKEN"
```

## Клиентское приложение

- Реализован вход через OIDC с использованием Keycloak.
- Реализована безопасная обработка callback с проверкой state, nonce и ошибок провайдера.
- Реализован обмен authorization code на токены с использованием PKCE. Токены не выводятся в URL и не записываются в журналы.
- Реализован logout через Keycloak с очисткой локальной Rails-сессии и последующим возвратом в приложение.



## Список литературы

https://habr.com/ru/companies/slurm/articles/654475/ - Keycloak