require_relative "../errors"

module Orders
  module Repositories
    class OrderRepository
      def find(id)
        raise NotImplementedError, "implement find in a repository adapter"
      end

      def save(order)
        raise NotImplementedError, "implement save in a repository adapter"
      end

      def with_order(id)
        yield find(id)
      end
    end
  end
end
