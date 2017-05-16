class AddRoundingToCurrencies < ActiveRecord::Migration
  def change
    add_column :spree_currencies, :rounding, :boolean, default: false
  end
end
