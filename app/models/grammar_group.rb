class GrammarGroup < ApplicationRecord
  include Constrainable
  include Pageable

  MAX_TITLE = 200

  before_validation :normalize_attributes

  validates :title, presence: true, length: { maximum: MAX_TITLE }, uniqueness: true

  scope :by_title, -> { order(:title) }

  def self.search(matches, params, path, opt={})
    matches = matches.by_title
    if sql = cross_constraint(params[:title], %w{title})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  private

  def normalize_attributes
    title&.squish!
  end
end
