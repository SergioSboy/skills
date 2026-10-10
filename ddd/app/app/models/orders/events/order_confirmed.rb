module Orders
  module Events
    # Доменное событие: неизменяемый факт, а не команда подтвердить заказ.
    OrderConfirmed = Data.define(:order_id, :occurred_at) do
      def initialize(order_id:, occurred_at:)
        super(order_id: order_id.dup.freeze, occurred_at: occurred_at.dup.freeze)
      end
    end
  end
end
