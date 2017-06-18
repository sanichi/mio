class Kanji < ApplicationRecord
  include Pageable

  MAX_SYMBOL = 1

  has_many :yomis, dependent: :destroy
  has_many :readings, through: :yomis

  validates :symbol, presence: true, length: { maximum: MAX_SYMBOL }, uniqueness: true

  scope :by_onyomi,  -> { order("onyomi DESC", 'symbol COLLATE "C"') }
  scope :by_kunyomi, -> { order("kunyomi DESC", 'symbol COLLATE "C"') }
  scope :by_total,   -> { order("(onyomi + kunyomi) DESC", 'symbol COLLATE "C"') }

  def total
    onyomi + kunyomi
  end

  def self.search(params, path, opt={})
    matches = case params[:order]
    when "onyomi"   then by_level
    when "kunyomi"  then by_kunyomi
    else                 by_total
    end
    matches = matches.includes(yomis: :reading)
    paginate(matches, params, path, opt)
  end
end
