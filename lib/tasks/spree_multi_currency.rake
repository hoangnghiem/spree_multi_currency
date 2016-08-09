namespace :spree_multi_currency do
  task :generate_default_currency => :environment do
    unless Spree::Currency.find_by_name(Spree::Config['currency'])
      default_country = Spree::Country.default
      default_currency = Spree::Currency.create!(name: Spree::Config['currency'], exchange_rate: 1.0, rate_applied: true)
      puts "Default currency #{Spree::Config['currency']} is set for #{default_country.name}"
    end
  end
end
