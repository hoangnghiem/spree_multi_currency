class Spree::Currency < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :exchange_rate, presence: true, numericality: true, allow_blank: true
  # validates :zone_id, presence: true

  belongs_to :zone, class_name: 'Spree::Zone'

  before_save :set_rate_applied

  def self.by_country(country_id)
    joins(:zone => :countries).where('spree_countries.id = ?', country_id).first
  end

  private

  def set_rate_applied
    if exchange_rate_changed?
      self.rate_applied = false
      true
    end
  end
end
