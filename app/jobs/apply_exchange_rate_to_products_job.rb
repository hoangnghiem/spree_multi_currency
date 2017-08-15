class ApplyExchangeRateToProductsJob < ActiveJob::Base
  queue_as :default

  def perform(currency_id)
    puts "===================================================================="
    currency = Spree::Currency.find(currency_id)
    base_spree_currency = Spree::Currency.find_by_name(Spree::Config['currency'])

    puts "Start exchange all products for currency #{currency.name}"

    if currency.exchange_rate.present?
      Spree::Product.includes(:variants_including_master).where(bespoke: false).find_each(batch_size: 100) do |product|
        puts '------------------------------------'
        puts "Product: #{product.name}"
        # apply to master
        product.variants_including_master.each do |variant|
          puts "VID: #{variant.id}"
          base_price = variant.prices.find_or_initialize_by(currency: Spree::Config['currency'])
          if base_price.price
            puts "base price: #{base_price.inspect}, #{base_price.price}"
            exchanged_price = base_price.price * currency.exchange_rate * base_spree_currency.exchange_rate
            exchanged_price = BigDecimal.new(exchanged_price.to_s).round(0, BigDecimal::ROUND_FLOOR)

            price = variant.prices.find_or_initialize_by(currency: currency.name)
            price.amount = exchanged_price
            puts "exchange price: #{price.inspect}, #{exchanged_price}"
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
            price = bov.prices.find_by_currency(currency.name)
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
