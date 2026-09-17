module Api
  module V1
    class OidcController < ApplicationController
      def login
        authorization = Auth::Oidc::Authorization.call

        session[:oidc_state] = authorization[:state]
        session[:oidc_nonce] = authorization[:nonce]
        session[:oidc_code_verifier] = authorization[:code_verifier]

        redirect_to(
          authorization[:authorization_url],
          allow_other_host: true
        )
      end

      def callback
        return head :ok if params[:error]
        return head :bad_request unless params[:code]

        unless Auth::Oidc::Authorization.secure_compare(
          params[:state],
          session.delete(:oidc_state)
        )
          return head :unauthorized
        end

        nonce = session.delete(:oidc_nonce)
        code_verifier = session.delete(:oidc_code_verifier)

        return head :bad_request unless nonce && code_verifier

        tokens = Auth::Oidc::TokenExchange.call(
          code: params[:code],
          code_verifier: code_verifier
        )

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
    end
  end
end
