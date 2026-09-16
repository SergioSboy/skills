require "net/http"
require "uri"
require "json"
require "jwt"

module Auth
  module Keycloak
    ISSUER = "http://192.168.64.10/realms/app"
    AUDIENCE = "rails-api"
    JWKS_URL = "#{ISSUER}/protocol/openid-connect/certs"
  end
end