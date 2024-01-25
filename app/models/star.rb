class Star < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable

  MAX_NAME = 40
  ALPHA = /\A([01][0-9]|2[0-3])([0-5][0-9])([0-5][0-9])\z/
  DELTA = /\A(-)?([0-8][0-9])([0-5][0-9])([0-5][0-9])\z/

  before_validation :normalize_attributes

  validates :alpha, format: { with: ALPHA }
  validates :delta, format: { with: DELTA }
  validates :name, presence: true, length: { maximum: MAX_NAME }, uniqueness: { case_sensitive: false }
  validates :distance, numericality: { integer_only: true, greater_than: 0 }
  validates :magnitude, numericality: { greater_than: -2.0, less_than: 7.0 }

  def self.search(params, path, opt={})
    matches = case params[:order]
    when "created"
      order(:id)
    when "distance"
      order(:distance)
    when "magnitude"
      order(:magnitude)
    else
      order(:name)
    end
    if sql = cross_constraint(params[:q], %w{title note})
      matches = matches.where(sql)
    end
    if sql = numerical_constraint(params[:magnitude], :magnitude)
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def note_html = to_html(note)

  private

  def normalize_attributes
    alpha&.gsub!(/\D+/, "")
    delta&.gsub!(/[^-0-9]+/, "")
    name&.squish!
    self.note = "" if note.nil?
    note.lstrip!
    note.rstrip!
    note.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
  end
end
