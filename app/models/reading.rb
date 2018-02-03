class Reading < ApplicationRecord
  include Pageable

  MAX_KANA = 5

  has_many :yomis
  has_many :kanjis, through: :yomis

  validates :kana, presence: true, length: { maximum: MAX_KANA }, uniqueness: true

  scope :by_onyomi,  -> { order("onyomi DESC", 'kana COLLATE "C"') }
  scope :by_kunyomi, -> { order("kunyomi DESC", 'kana COLLATE "C"') }
  scope :by_total,   -> { order("(onyomi + kunyomi) DESC", 'kana COLLATE "C"') }
  scope :by_kana,    -> { order('kana COLLATE "C"', "(onyomi + kunyomi) DESC") }

  def total
    onyomi + kunyomi
  end

  def self.search(params, path, opt={})
    params[:q] = params[:qr] if params[:qr].present? # for views/vocabs/_multi_search
    matches = case params[:order]
    when "onyomi"   then by_onyomi
    when "kunyomi"  then by_kunyomi
    when "kana"     then by_kana
    else                 by_total
    end
    matches = matches.includes(yomis: :kanji)
    if (q = params[:q]).present?
      matches = matches.where("kana LIKE ?", "%#{q}%")
    end
    paginate(matches, params, path, opt)
  end
end
