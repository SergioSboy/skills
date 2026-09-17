
require "net/http"
require "uri"
require "json"
require "jwt"

module Auth
  class TokenVerifier
    def self.call(token)
      jwks = JSON.parse(Net::HTTP.get(URI(Auth::Keycloak::JWKS_URL)))

      payload, = JWT.decode(
        token,
        nil,
        true,
        algorithms: [ "RS256" ],
        jwks: jwks,
        iss: Auth::Keycloak::ISSUER,
        verify_iss: true,
        aud: Auth::Keycloak::AUDIENCE,
        verify_aud: true
      )

      {
        id: payload["sub"],
        username: payload["preferred_username"],
        roles: payload.dig("realm_access", "roles") || []
      }
    rescue JWT::DecodeError => e
      Rails.logger.warn("JWT verification failed: #{e.message}")
       nil
    end
  end
end
