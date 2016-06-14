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
          new_currency = Spree::Currency.create!(name: params[:create])
          redirect_to edit_admin_currency_path(new_currency)
        else
          super
        end
      end

    end
  end
end

