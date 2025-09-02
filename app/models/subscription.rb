class Subscription < ApplicationRecord
  include Constrainable

  MAX_PAYEE = 50
  MAX_SOURCE = 40

  # The values are not arbitrary: they are the number of periods in 1 year and are used to calculate annual cost.
  enum :frequency, { monthly: 12, annually: 1, weekly: 52, daily: 365 }

  validates :amount, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :payee, presence: true, length: { maximum: MAX_PAYEE }, uniqueness: true
  validates :source, presence: true, length: { maximum: MAX_SOURCE }

  before_validation :canonicalize

  def self.search(params)
    matches = all
    if sql = cross_constraint(params[:payee], %w{payee})
      matches = matches.where(sql)
    end
    matches = matches.where(source: params[:source]) if params[:source].present?
    matches.to_a.sort_by(&:annual_cost).reverse
  end
  
  def amount=(value)
    if value.is_a?(String)
      # Remove £ symbol and whitespace, then convert to float, multiply by 100 and round to get pennies.
      cleaned = value.gsub(/[£\s]/, '')
      if cleaned.match?(/^\d+(\.\d+)?$/)
        super((cleaned.to_f * 100).round)
      else
        super(value)
      end
    else
      super(value)
    end
  end

  def annual_cost
    @annual_cost ||= self.class.frequencies[frequency] * amount
  end

  def human_frequency
    I18n.t("activerecord.attributes.subscription.frequency.#{frequency}")
  end

  private

  def canonicalize
    payee&.squish!
    source&.squish!
  end
end
