class SimilarKanji < ApplicationRecord
  include Constrainable
  include Pageable

  MAX_KANJIS = 20
  MAX_CATEGORY = 10

  CATEGORIES = %w[shape reading meaning]

  before_validation :canonicalize

  validates :kanjis, length: { maximum: MAX_KANJIS, minimum: 2 }, format: { with: /\A\S+\z/ }
  validates :category, inclusion: { in: CATEGORIES }
  validate :cant_be_substring_or_duplicate_of_previous_entry

  scope :by_kanjis, -> { order(Arel.sql('kanjis COLLATE "C"')) }

  def self.search(params, path, opt={})
    matches = by_kanjis
    matches = matches.where(category: params[:category]) if CATEGORIES.include?(params[:category])
    if sql = cross_constraint(params[:q], %w{kanjis})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def self.tidy(k)
    k.to_s.squish.split('').sort.uniq.join('')
  end

  private

  def canonicalize
    self.kanjis = self.class.tidy(kanjis)
  end

  def cant_be_substring_or_duplicate_of_previous_entry
    errors.add(:kanjis, "can't be duplicate or substring") if self.class.where("kanjis LIKE ?", "%#{kanjis}%").count > 0
  end
end
