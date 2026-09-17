require "net/http"
require "uri"
require "json"
require "jwt"

module Auth
  module Keycloak
    ISSUER = "http://192.168.64.10/realms/app"
    AUDIENCE = "rails-api"
    JWKS_URL = "#{ISSUER}/protocol/openid-connect/certs"

    CLIENT_ID = "rails-web"
    CLIENT_SECRET = ENV.fetch("KEYCLOAK_CLIENT_SECRET")

    AUTHORIZATION_ENDPOINT =
          "#{ISSUER}/protocol/openid-connect/auth"

    TOKEN_ENDPOINT =
      "#{ISSUER}/protocol/openid-connect/token"

    LOGOUT_ENDPOINT =
      "#{ISSUER}/protocol/openid-connect/logout"

    REDIRECT_URI =
      "http://localhost:3000/api/v1/auth/keycloak/callback"
  end
end