module Orders
  module Application
    # Прикладной сценарий связывает хранение и доменное действие.
    class ConfirmOrder
      def initialize(repository:)
        @repository = repository
      end

      def call(order_id:)
        @repository.with_order(order_id) do |order|
          order.confirm!
          @repository.save(order)
        end
      end
    end
  end
end
