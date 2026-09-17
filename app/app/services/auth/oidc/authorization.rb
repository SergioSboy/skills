require "openssl"
require "base64"
require "securerandom"
require "uri"

module Auth
  module Oidc
    class Authorization
      def self.call
        state = random_urlsafe
        nonce = random_urlsafe
        code_verifier = random_urlsafe(64)

        code_challenge = Base64.urlsafe_encode64(
          OpenSSL::Digest::SHA256.digest(code_verifier),
          padding: false
        )

        params = {
          client_id: Auth::Keycloak::CLIENT_ID,
          response_type: "code",
          scope: "openid",
          redirect_uri: Auth::Keycloak::REDIRECT_URI,
          state: state,
          nonce: nonce,
          code_challenge: code_challenge,
          code_challenge_method: "S256"
        }

        {
          state: state,
          nonce: nonce,
          code_verifier: code_verifier,
          authorization_url: build_authorization_url(params)
        }
      end

      def self.secure_compare(a, b)
        return false unless a && b
        return false unless a.bytesize == b.bytesize

        ActiveSupport::SecurityUtils.fixed_length_secure_compare(a, b)
      end

      def self.random_urlsafe(bytes = 32)
        SecureRandom.urlsafe_base64(bytes)
      end

      private_class_method :random_urlsafe

      def self.build_authorization_url(params)
        "#{Auth::Keycloak::AUTHORIZATION_ENDPOINT}?#{URI.encode_www_form(params)}"
      end

      private_class_method :build_authorization_url
    end
  end
end
