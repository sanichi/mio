class Tutorial < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable

  MAX_SUMMARY = 100

  before_validation :normalize_attributes

  validates :summary, presence: true, length: { maximum: MAX_SUMMARY }
  validates :date, date: { before_or_equal: Proc.new { Date.today } }, uniqueness: true

  scope :by_date,    -> { order(:date) }
  scope :by_created, -> { order(:created_at) }

  def self.search(params, path, opt={})
    matches = by_date
    if sql = cross_constraint(params[:q], %w{summary})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def number
    self.class.where("date < ?", date).count + 1
  end

  def note_html
    to_html(I18n.t("tutorial.summary") + ": " + summary)
  end

  private

  def normalize_attributes
    summary&.squish!
  end
end
