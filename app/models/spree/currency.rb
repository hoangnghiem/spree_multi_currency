class Spree::Currency < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :exchange_rate, presence: true , numericality: true, allow_blank: true

  has_many :currency_members, class_name: 'Spree::CurrencyMember', dependent: :destroy, inverse_of: :currency
  has_many :countries, through: :currency_members, source: :country

  alias :members :currency_members
  accepts_nested_attributes_for :currency_members, allow_destroy: true, reject_if: proc { |a| a['country_id'].blank? }

  before_save :set_rate_applied

  private

  def set_rate_applied
    if exchange_rate_changed?
      self.rate_applied = false
      true
    end
  end
end
