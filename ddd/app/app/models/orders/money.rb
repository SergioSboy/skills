require_relative "errors"

module Orders
  # Сумма в минимальных единицах валюты: 19900 означает 199 рублей.
  Money = Data.define(:amount, :currency) do
    def initialize(amount:, currency:)
      raise Errors::InvalidInput, "amount must be a non-negative integer" unless amount.is_a?(Integer) && amount >= 0
      raise Errors::InvalidInput, "currency must be a three-letter code" unless currency.is_a?(String) && currency.match?(/\A[A-Z]{3}\z/)

      super(amount: amount, currency: currency.dup.freeze)
    end
  end
end
