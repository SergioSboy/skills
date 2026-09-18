require "net/http"
require "uri"
require "json"

module Auth
  module Oidc
    class TokenExchange
      def self.call(code:, code_verifier:)
        uri = URI(Auth::Keycloak::TOKEN_ENDPOINT)

        request = Net::HTTP::Post.new(uri)
        request["Content-Type"] = "application/x-www-form-urlencoded"

        request.body = URI.encode_www_form(
          grant_type: "authorization_code",
          client_id: Auth::Keycloak::CLIENT_ID,
          client_secret: Auth::Keycloak::CLIENT_SECRET,
          code: code,
          redirect_uri: Auth::Keycloak::REDIRECT_URI,
          code_verifier: code_verifier
        )

        response = Net::HTTP.start(
          uri.host,
          uri.port,
          use_ssl: uri.scheme == "https"
        ) do |http|
          http.request(request)
        end

        unless response.is_a?(Net::HTTPSuccess)
          Rails.logger.warn(
            "OIDC token exchange failed: HTTP #{response.code}"
          )

          raise KeyError, "token exchange failed"
        end

        tokens = JSON.parse(response.body)

        Rails.logger.info(
          "OIDC token exchange successful " \
          "client=#{Auth::Keycloak::CLIENT_ID}"
        )

        tokens
      end
    end
  end
end
