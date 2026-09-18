module Api
  module V1
        class AuthenticateController < ApplicationController
          before_action :authenticate!

          attr_reader :current_user

          private

          def authenticate!
            token = request.headers["Authorization"]&.split(" ")&.last

            return head :unauthorized unless token

            @current_user = Auth::TokenVerifier.call(token)

            head :unauthorized unless @current_user
          end
        end
  end
end
