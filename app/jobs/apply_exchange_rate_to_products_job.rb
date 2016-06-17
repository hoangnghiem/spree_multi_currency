class ApplyExchangeRateToProductsJob < ActiveJob::Base
  queue_as :default

  def perform(currency)
    puts "===================================================================="
    puts "Start exchange all products for currency #{currency.name}"
    base_spree_currency = Spree::Currency.find_by_name(Spree::Config['currency'])

    if currency.exchange_rate.present?
      Spree::Product.all.each do |product|
        # apply to master
        product.variants_including_master.each do |variant|
          base_price = variant.price_in(Spree::Config['currency'])
          exchanged_price = base_price.price * currency.exchange_rate * base_spree_currency.exchange_rate
          exchanged_price_amount = Spree::Money.new(exchanged_price, currency: currency.name)

          price = variant.price_in(currency.name)
          price.price = exchanged_price_amount.money
          price.save!
        end
        puts "Product #{product.name} Done."
      end

      currency.update_column(:rate_applied, true)
    end
    puts "===================================================================="
  end
end
