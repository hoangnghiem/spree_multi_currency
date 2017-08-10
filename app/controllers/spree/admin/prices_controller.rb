module Spree
  module Admin
    class PricesController < ResourceController
      belongs_to 'spree/product', find_by: :slug

      def create
        params[:vp].each do |variant_id, prices|
          variant = Spree::Variant.find(variant_id)
          next unless variant
          supported_currencies.each do |currency|
            price = variant.price_in(currency.iso_code)
            price.price = (prices[currency.iso_code].blank? ? nil : prices[currency.iso_code].to_money)
            price.save! if price.new_record? && price.price || !price.new_record? && price.changed?
          end
        end
        flash[:success] = Spree.t('notice_messages.prices_saved')
        redirect_to admin_product_path(parent)
      end

      def apply
        exchange_currencies = Spree::Currency.where(name: Spree::Config[:supported_currencies].split(',') - [Spree::Config['currency']]) 
        base_spree_currency = Spree::Currency.find_by_name(Spree::Config['currency'])

        parent.variants_including_master.each do |variant|
          base_price = variant.price_in(Spree::Config['currency'])
          if base_price.price
            exchange_currencies.each do |currency|
              exchanged_price = base_price.price * currency.exchange_rate * base_spree_currency.exchange_rate
              if currency.rounding
                exchanged_price = exchanged_price.to_i.to_f
              end
              exchanged_price_amount = Spree::Money.new(exchanged_price, currency: currency.name)
              puts "exchanged_price_amount = #{exchanged_price_amount}"

              price = variant.price_in(currency.name)
              price.price = exchanged_price_amount.money
              price.save!
            end
          else
            puts "Product #{product.name} - Variant #{variant.options_text} does not have USD price."
          end
        end

        flash[:success] = "Exchange rate applied to this product."
        redirect_to admin_product_prices_path(parent)
      end
    end
  end
end
