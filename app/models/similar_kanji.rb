class SimilarKanji < ApplicationRecord
  include Constrainable
  include Pageable

  MAX_KANJIS = 20

  before_validation :canonicalize

  validates :kanjis, length: { maximum: MAX_KANJIS, minimum: 2 }, format: { with: /\A\S+\z/ }, uniqueness: true

  scope :by_kanjis, -> { order('kanjis COLLATE "C"') }

  def self.search(params, path, opt={})
    matches = by_kanjis
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
end
