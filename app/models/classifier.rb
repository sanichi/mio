class Classifier < ApplicationRecord
  include Constrainable
  include Pageable

  MAX_CATEGORY = 100
  MAX_COLOR = 6
  MAX_NAME = 30

  has_many :transactions, dependent: :nullify, inverse_of: :classifier

  before_validation :normalize_attributes, :check_regexes, :check_amounts

  after_save :reclassify

  validates :category, presence: true, length: { maximum: MAX_CATEGORY }
  validates :color, presence: true, length: { maximum: MAX_COLOR }, format: { with: /\A[0-9a-f]{6}\z/ }
  validates :max_amount, :min_amount, numericality: { greater_than_or_equal_to: -Transaction::MAX_AMOUNT, less_than_or_equal_to: Transaction::MAX_AMOUNT }
  validates :description, presence: true
  validates :name, presence: true, length: { maximum: MAX_NAME }, uniqueness: { case_sensitive: false }

  default_scope { order(name: :asc) }

  def cre = @cre ||= Regexp.new(category.to_s)
  def dre = @dre ||= Regexp.new(description.to_s.split("\n").join("|"), "i")

  def dark?
    color.scan(/../).map{|h| h.to_i(16)}.keep_if{|d| d < 128}.size > 1
  end

  def self.search(params)
    matches = all
    if sql = cross_constraint(params[:query], %w{name description category})
      matches = matches.where(sql)
    end
    matches
  end

  private

  def normalize_attributes
    if category.present?
      self.category = category.split("|").keep_if{|c| c.present?}.map(&:strip).map(&:upcase).sort.join("|")
    end
    color&.gsub!(/\s/, "")
    color&.downcase!
    if description.present?
      self.description = description.split(/\s*\n\s*/).keep_if{|c| c.present?}.map(&:strip).sort.join("\n")
    end
    self.max_amount = 0.0 unless max_amount.present?
    self.min_amount = 0.0 unless min_amount.present?
    name&.squish!
  end

  def check_regexes
    cre rescue errors.add(:category, "invalid regexp")
    dre rescue errors.add(:description, "invalid regexp")
  end

  def check_amounts
    if max_amount < min_amount
      errors.add(:max_amount, "less than Min amount")
    elsif max_amount == 0.0 && min_amount == 0.0
      errors.add(:max_amount, "and Min amount both zero")
    end
  end

  def reclassify
    @cre = @dre = nil
    Transaction.where(classifier_id: [nil, id]).each do |t|
      if t.match?(self)
        t.update_column(:classifier_id, id) unless t.classifier_id == id
      else
        t.update_column(:classifier_id, nil) unless t.classifier_id.nil?
      end
    end
  end
end
