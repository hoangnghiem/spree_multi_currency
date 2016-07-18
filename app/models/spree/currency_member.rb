class Spree::CurrencyMember < ActiveRecord::Base
  belongs_to :currency, class_name: 'Spree::Currency', inverse_of: :currency_members
  belongs_to :country, class_name: 'Spree::Country'
end
