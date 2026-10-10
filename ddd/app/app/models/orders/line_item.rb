require_relative "money"

module Orders
  LineItem = Data.define(:id, :name, :price, :quantity) do
    def initialize(id:, name:, price:, quantity:)
      raise Errors::InvalidInput, "id must be a non-empty string" unless id.is_a?(String) && !id.strip.empty?
      raise Errors::InvalidInput, "name must be a non-empty string" unless name.is_a?(String) && !name.strip.empty?
      raise Errors::InvalidInput, "price must be Money" unless price.is_a?(Money)
      raise Errors::InvalidInput, "quantity must be a positive integer" unless quantity.is_a?(Integer) && quantity > 0
      super(id: id.dup.freeze, name: name.dup.freeze, price: price, quantity: quantity)
    end
  end
end
