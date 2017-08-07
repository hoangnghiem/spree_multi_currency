class ApplyExchangeRateToProductsJob < ActiveJob::Base
  queue_as :default

  def perform(currency_id)
    puts "===================================================================="
    puts "Start exchange all products for currency #{currency.name}"
    currency = Spree::Currency.find(currency_id)
    base_spree_currency = Spree::Currency.find_by_name(Spree::Config['currency'])

    if currency.exchange_rate.present?
      Spree::Product.includes(:variants_including_master).where(bespoke: false).find_each(batch_size: 100) do |product|
        # apply to master
        product.variants_including_master.each do |variant|
          base_price = variant.price_in(Spree::Config['currency'])
          if base_price.price
            exchanged_price = base_price.price * currency.exchange_rate * base_spree_currency.exchange_rate
            if currency.rounding
              exchanged_price = exchanged_price.to_i.to_f
            end
            exchanged_price_amount = Spree::Money.new(exchanged_price, currency: currency.name)

            price = variant.price_in(currency.name)
            price.price = exchanged_price_amount.money
            price.save!
          else
            puts "Product #{product.name} - Variant #{variant.options_text} does not have USD price."
          end
        end
      end

      supported_currencies = Spree::Config[:supported_currencies].split(',').map { |code| ::Money::Currency.find(code.strip) }
      Spree::Product.where(bespoke: true).each do |product|
        product.bespoke_option_types.each do |bot|
          bot.option_values.each do |bov|
            base_price = bov.prices.find_by_currency(Spree::Config['currency'])
            unless base_price
              base_price = bov.prices.create(currency: Spree::Config['currency'], amount: 0.0)
            end

            exchanged_price = base_price.price
            if bov.price_modifier_type == 'flat_rate'
              exchanged_price = base_price.price * currency.exchange_rate * base_spree_currency.exchange_rate
            end

            exchanged_price_amount = Spree::Money.new(exchanged_price, currency: currency.name)
            price = bov.price_in(currency.name)
            price.price = exchanged_price_amount.money
            price.save!
          end
        end
      end

      currency.update_column(:rate_applied, true)
    end
    puts "===================================================================="
  end
end
