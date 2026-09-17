require "uri"

module Auth
  module Oidc
    class Logout
      def self.url(id_token_hint: nil)
        params = {
          post_logout_redirect_uri: Auth::Keycloak::POST_LOGOUT_REDIRECT_URI,
          client_id: Auth::Keycloak::CLIENT_ID
        }

        params[:id_token_hint] = id_token_hint if id_token_hint

        "#{Auth::Keycloak::LOGOUT_ENDPOINT}?#{URI.encode_www_form(params)}"
      end
    end
  end
end
