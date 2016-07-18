class CreateSpreeCurrencyMembers < ActiveRecord::Migration
  def change
    create_table :spree_currency_members do |t|
      t.references :currency, index: true
      t.references :country, index: true

      t.timestamps null: false
    end

    add_foreign_key :spree_currency_members, :spree_currencies, column: :currency_id
    add_foreign_key :spree_currency_members, :spree_countries, column: :country_id
  end
end
