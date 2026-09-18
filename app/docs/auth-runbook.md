# Authentication Runbook

## 1. Login doesn't work

1. Check Rails logs.
2. Check Keycloak availability.
3. Check client_id.
4. Check redirect_uri.
5. Check client secret.
6. Check authorization code.
7. Check state and nonce.

## 2. 401 from API

Check:

- Authorization header
- JWT signature
- issuer
- audience
- expiration
- JWKS availability

Expected issuer:

http://192.168.64.10/realms/app

API audience:

rails-api

## 3. 403 from API

Token is valid, but user doesn't have required role/scope.

Check:

realm_access.roles
scope

## 4. Key rotation

If JWT verification suddenly fails:

1. Check Keycloak JWKS endpoint.
2. Check current `kid` in JWT header.
3. Refresh JWKS.
4. Verify that the new public key is available.
5. Do not disable signature verification.

## 5. Never log

- access_token
- refresh_token
- id_token
- client_secret