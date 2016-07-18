class CreateSpreeCurrencies < ActiveRecord::Migration

  def change
    create_table :spree_currencies do |t|
      t.string :name
      t.decimal :exchange_rate, :precision => 11, :scale => 6, :null => true
      t.boolean :rate_applied, null: false, default: false

      t.timestamps null: false
    end
  end

end
