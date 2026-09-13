module Api
  module Admin
    class UsersController < Api::AdminController
      def index
        @users = Kaminari
          .paginate_array(users)
          .page(params.fetch(:page, 1))
          .per(params.fetch(:per_page, 20))
      end

      private

      def users
        [
          OpenStruct.new(
            id: 1,
            name: "John"
          ),
          OpenStruct.new(
            id: 2,
            name: "Alice"
          ),
          OpenStruct.new(
            id: 3,
            name: "Bob"
          ),
          OpenStruct.new(
            id: 4,
            name: "Emma"
          ),
          OpenStruct.new(
            id: 5,
            name: "Michael"
          )
        ]
      end
    end
  end
end
