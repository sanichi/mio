class VerbPair < ApplicationRecord
  include Pageable

  MAX_GROUP = I18n.t("verb_pair.groups").length - 1
  MAX_TAG = 2 * (Vocab::MAX_KANJI + Vocab::MAX_READING + Vocab::MAX_MEANING) + 5

  after_save :set_tag

  belongs_to :transitive, class_name: "Vocab", foreign_key: :transitive_id
  belongs_to :intransitive, class_name: "Vocab", foreign_key: :intransitive_id

  validates :group, numericality: { integer_only: true, greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_GROUP }
  validates :transitive_id, numericality: { integer_only: true, greater_than: 0 }
  validates :intransitive_id, numericality: { integer_only: true, greater_than: 0 }, uniqueness: { scope: :transitive_id }

  scope :by_tag,   -> { order('tag COLLATE "C"') }
  scope :by_group, -> { order(:group, 'tag COLLATE "C"') }

  def self.search(params, path, opt={})
    matches = case params[:order]
    when "group"
      by_group
    else
      by_tag
    end
    if params[:group].present? && (g = params[:group].to_i) >= 0 && g <= MAX_GROUP
      matches = matches.where(group: g)
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
