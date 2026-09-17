require "net/http"
require "uri"
require "json"
require "jwt"

module Auth
  module Oidc
    class IdTokenVerifier
      def self.call(id_token:, expected_nonce:)
        jwks = fetch_jwks

        payload, = JWT.decode(
          id_token,
          nil,
          true,
          algorithms: [ "RS256" ],
          jwks: jwks,
          iss: Auth::Keycloak::ISSUER,
          verify_iss: true,
          aud: Auth::Keycloak::CLIENT_ID,
          verify_aud: true
        )

        verify_nonce!(payload.fetch("nonce"), expected_nonce)

        payload
      rescue KeyError, JWT::DecodeError => e
        Rails.logger.warn("OIDC ID token verification failed: #{e.message}")
        raise
      end

      def self.fetch_jwks
        uri = URI(Auth::Keycloak::JWKS_URL)
        response = Net::HTTP.get_response(uri)

        unless response.is_a?(Net::HTTPSuccess)
          raise JWT::DecodeError, "JWKS fetch failed: HTTP #{response.code}"
        end

        JSON.parse(response.body)
      end

      def self.verify_nonce!(actual, expected)
        return if ActiveSupport::SecurityUtils.fixed_length_secure_compare(
          actual,
          expected
        )

        raise JWT::DecodeError, "Invalid nonce"
      end

      private_class_method :fetch_jwks, :verify_nonce!
    end
  end
end
