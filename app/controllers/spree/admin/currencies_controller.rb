module Spree
  module Admin
    class CurrenciesController < ResourceController
      
      def index
        defined_currency_codes = @currencies.map {|sc| sc.name }
        @undefined_currencies = supported_currencies.reject {|currency| defined_currency_codes.include?(currency.iso_code) }
      end

      def collection
        super.order(:name)
      end

      def new
        if params[:create].present?
          new_currency = Spree::Currency.find_or_create_by(name: params[:create])
          redirect_to edit_admin_currency_path(new_currency)
        else
          super
        end
      end

      # def apply
      #   @currency = Spree::Currency.find(params[:id])
      #   if @currency.exchange_rate.present?
      #     ApplyExchangeRateToProductsJob.perform_later(@currency.id)
      #     flash[:success] = "#{@currency.name}'s exchange rate is being applied. It might take a while."
      #   else
      #     flash[:error] = "#{@currency.name}'s exchange rate is not defined." 
      #   end
      #   redirect_to collection_url
      # end

    end
  end
end

