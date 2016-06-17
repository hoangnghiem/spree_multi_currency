class CreateSpreeCurrencies < ActiveRecord::Migration

  def change
    create_table :spree_currencies do |t|
      t.string :name
      t.decimal :exchange_rate, :precision => 11, :scale => 6, :null => true
      t.boolean :rate_applied, null: false, default: false

      t.timestamps null: false
    end

    puts "Setup #{Spree::Config['currency']} as base currency"
    unless Spree::Currency.find_by_name(Spree::Config['currency'])
      Spree::Currency.create!(name: Spree::Config['currency'], exchange_rate: 1.0, rate_applied: true)
    end
  end

end
