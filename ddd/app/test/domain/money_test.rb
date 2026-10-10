require "minitest/autorun"
require_relative "../../app/models/orders/money"

class MoneyTest < Minitest::Test
  def test_equality_depends_on_amount_and_currency
    money = Orders::Money.new(amount: 100, currency: "RUB")
    assert_equal money, Orders::Money.new(amount: 100, currency: "RUB")
    refute_equal money, Orders::Money.new(amount: 100, currency: "USD")
    assert_equal 0, Orders::Money.new(amount: 0, currency: "RUB").amount
  end

  def test_invalid_values_are_rejected
    [-1, 1.5, "100", nil].each do |amount|
      assert_raises(ArgumentError) { Orders::Money.new(amount: amount, currency: "RUB") }
    end
    ["rub", "", nil].each do |currency|
      assert_raises(ArgumentError) { Orders::Money.new(amount: 100, currency: currency) }
    end
  end

  def test_currency_is_an_immutable_snapshot
    currency = +"RUB"
    money = Orders::Money.new(amount: 100, currency: currency)
    currency.replace("USD")
    assert_equal "RUB", money.currency
    assert_raises(FrozenError) { money.currency.replace("USD") }
  end
end
