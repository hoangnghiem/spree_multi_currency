module Spree
  module Calculator::Shipping
    class ExchangeableFlatRate < ShippingCalculator
      preference :amount, :decimal, default: 0
      preference :base_currency, :string, default: ->{ Spree::Config[:currency] }

      def self.description
        "Multi Currency Flat Rate"
      end

      def compute_package(package)
        order_currency = package.currency
        spree_base_currency = Spree::Currency.find_by_name(preferred_base_currency)
        spree_target_currency = Spree::Currency.find_by_name(order_currency)
        if spree_base_currency && spree_target_currency
          self.preferred_amount * spree_base_currency.exchange_rate * spree_target_currency.exchange_rate
        else
          0
        end
      end
    end
  end
end

