module Api
  module Admin
    class UsersController < Api::AdminController
      def index
        render json: {
          data: [
            {
              id: 1,
              name: "John"
            },
            {
              id: 2,
              name: "Alice"
            }
          ],
          meta: {}
        }
      end
    end
  end
end
