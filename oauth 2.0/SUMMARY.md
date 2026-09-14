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

### Сравнение confidential и public clients.