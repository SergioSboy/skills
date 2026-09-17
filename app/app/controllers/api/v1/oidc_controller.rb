require "net/http"
require "uri"
require "json"
require "openssl"
require "base64"
require "securerandom"

module Api
  module V1
    class OidcController < ApplicationController
      def login
        state = random_urlsafe
        nonce = random_urlsafe
        code_verifier = random_urlsafe(64)

        session[:oidc_state] = state
        session[:oidc_nonce] = nonce
        session[:oidc_code_verifier] = code_verifier

        code_challenge = base64url(
          OpenSSL::Digest::SHA256.digest(code_verifier)
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

        redirect_to(
          "#{Auth::Keycloak::AUTHORIZATION_ENDPOINT}?#{URI.encode_www_form(params)}",
          allow_other_host: true
        )
      end

      def callback
        # Keycloak сообщил об ошибке
        if params[:error]
          Rails.logger.warn(
            "OIDC authorization failed: #{params[:error]}"
          )

          return head :ok
        end

        # Проверяем наличие authorization code
        return head :bad_request unless params[:code]

        # Защита callback с помощью state
        unless secure_compare(params[:state], session.delete(:oidc_state))
          return head :unauthorized
        end

        nonce = session.delete(:oidc_nonce)
        code_verifier = session.delete(:oidc_code_verifier)

        return head :bad_request unless nonce && code_verifier

        tokens = exchange_code(
          code: params[:code],
          code_verifier: code_verifier
        )

        # Пока просто сохраним информацию о пользователе в session.

        session[:user] = {
          access_token: tokens.fetch("access_token"),
          refresh_token: tokens["refresh_token"]
        }

        render json: {
          data: {
            message: "login successful"
          },
          meta: {
            request_id: request.request_id
          }
        }, status: :ok
      rescue KeyError => e
        Rails.logger.warn("OIDC token response error: #{e.message}")
        head :unauthorized
      end

      private

      def exchange_code(code:, code_verifier:)
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

        JSON.parse(response.body)
      end

      def random_urlsafe(bytes = 32)
        SecureRandom.urlsafe_base64(bytes)
      end

      def base64url(value)
        Base64.urlsafe_encode64(value, padding: false)
      end

      def secure_compare(a, b)
        return false unless a && b
        return false unless a.bytesize == b.bytesize

        ActiveSupport::SecurityUtils.fixed_length_secure_compare(a, b)
      end
    end
  end
end