class Reading < ApplicationRecord
  include Pageable

  MAX_KANA = 5

  has_many :yomis
  has_many :kanjis, through: :yomis

  validates :kana, presence: true, length: { maximum: MAX_KANA }, uniqueness: true

  scope :by_onyomi,  -> { order("onyomi DESC", 'kana COLLATE "C"') }
  scope :by_kunyomi, -> { order("kunyomi DESC", 'kana COLLATE "C"') }
  scope :by_kanjis,  -> { order("(onyomi + kunyomi) DESC", 'kana COLLATE "C"') }

  def total
    onyomi + kunyomi
  end

  def self.search(params, path, opt={})
    matches = case params[:order]
    when "onyomi"   then by_onyomi
    when "kunyomi"  then by_kunyomi
    else                 by_kanjis
    end
    matches = matches.includes(yomis: :kanji)
    paginate(matches, params, path, opt)
  end
end
