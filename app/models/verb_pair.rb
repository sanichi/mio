class VerbPair < ApplicationRecord
  include Pageable

  CATEGORIES = %w/eru_aru u_eru eru_u asu_eru irregular/
  MAX_CATEGORY = 10
  MAX_TAG = 2 * (Vocab::MAX_KANJI + Vocab::MAX_READING + Vocab::MAX_MEANING) + 5

  after_save :set_tag

  belongs_to :transitive, class_name: "Vocab", foreign_key: :transitive_id
  belongs_to :intransitive, class_name: "Vocab", foreign_key: :intransitive_id

  validates :category, inclusion: { in: CATEGORIES }
  validates :transitive_id, numericality: { integer_only: true, greater_than: 0 }
  validates :intransitive_id, numericality: { integer_only: true, greater_than: 0 }, uniqueness: { scope: :transitive_id }

  scope :by_tag, -> { order('tag COLLATE "C"') }

  def self.search(params, path, opt={})
    matches = by_tag
    if CATEGORIES.include?(c = params[:category])
      matches = matches.where(category: c)
    end
    if (q = params[:query]).present?
      matches = matches.where("tag ILIKE ?", "%#{q}%")
    end
    paginate(matches, params, path, opt)
  end

  def title
    transitive.kanji + " → " + intransitive.kanji
  end

  private

  def set_tag
    update_column :tag, [transitive.reading, intransitive.reading, transitive.kanji, intransitive.kanji, transitive.meaning, intransitive.meaning].join("|")
  end
end
