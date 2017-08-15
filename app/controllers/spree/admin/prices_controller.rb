module Spree
  module Admin
    class PricesController < ResourceController
      belongs_to 'spree/product', find_by: :slug

      def create
        params[:vp].each do |variant_id, prices|
          variant = Spree::Variant.find(variant_id)
          next unless variant
          supported_currencies.each do |currency|
            price = variant.orig_price_in(currency.iso_code)
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
          base_price = variant.orig_price_in(Spree::Config['currency'])
          if base_price.price
            puts "base #{base_price.price}"
            exchange_currencies.each do |currency|
              exchanged_price = base_price.price * currency.exchange_rate * base_spree_currency.exchange_rate
              exchanged_price = BigDecimal.new(exchanged_price.to_s).round(0, BigDecimal::ROUND_FLOOR)

              price = variant.prices.find_or_initialize_by(currency: currency.name)
              price.update_column(:amount, exchanged_price)
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
