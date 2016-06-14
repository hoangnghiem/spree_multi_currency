class Spree::Currency < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :exchange_rate, presence: true , numericality: true, allow_blank: true

  before_save :set_rate_applied

  private

  def set_rate_applied
    if exchange_rate_changed?
      self.rate_applied = false
      true
    end
  end
end
