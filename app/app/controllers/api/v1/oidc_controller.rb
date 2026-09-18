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

        def logout
          user_id = session.dig(:user, :id)

          Rails.logger.info(
            "OIDC logout started user_id=#{user_id}"
          )

          id_token = session[:oidc_id_token]

          reset_session

          redirect_to(
            Auth::Oidc::Logout.url(id_token_hint: id_token),
            allow_other_host: true
          )
        end

        def logout_callback
            Rails.logger.info("OIDC logout successful")

          render json: {
            data: {
              message: "logout successful"
            }
          }, status: :ok
        end

      def callback
        if params[:error]
            Rails.logger.warn("OIDC authorization failed: #{params[:error]}")
          return head :bad_request
        end
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

        id_token = tokens.fetch("id_token")

        session[:oidc_id_token] = id_token
        user = Auth::Oidc::IdTokenVerifier.call(id_token: id_token, expected_nonce: nonce)

        Rails.logger.info(
          "OIDC login successful " \
          "user_id=#{user["sub"]} " \
          "username=#{user["preferred_username"]}"
        )

        session[:user] = {
          id: user.fetch("sub"), username: user["preferred_username"], email: user["email"]
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
