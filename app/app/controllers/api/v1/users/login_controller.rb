module Api
    module V1
      module Users
        class LoginController < V1Controller

          def create
            email = params[:email]
            password = params[:password]

            if email == "john@example.com" && password == "secret"
              token = JWT.encode(
                {
                  user_id: 42,
                  exp: 15.minutes.from_now.to_i
                },
                Rails.application.credentials.jwt_secret,
                "HS256"
              )

              render json: {
                data: {
                  token: token,
                  token_type: "Bearer",
                  expires_in: 15.minutes.to_i
                }
              }, status: :ok
            else
              render json: {
                data: nil,
                errors: [
                  {
                    code: "invalid_credentials",
                    field: nil,
                    message: "Invalid email or password"
                  }
                ],
                meta: {
                  request_id: request.request_id
                }
              }, status: :unauthorized
            end
          end
        end
      end
    end
end
