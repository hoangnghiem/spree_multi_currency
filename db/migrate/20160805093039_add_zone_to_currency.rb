class AddZoneToCurrency < ActiveRecord::Migration
  def change
    add_column :spree_currencies, :zone_id, :integer, index: true
  end
end
