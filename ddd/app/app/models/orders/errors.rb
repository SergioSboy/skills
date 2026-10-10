module Orders
  module Errors
    class InvalidInput < ArgumentError; end
    class InvalidState < StandardError; end
    class EmptyOrder < StandardError; end
    class OrderNotFound < StandardError; end
  end
end
