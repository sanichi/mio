class Star < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable

  MAX_NAME = 40

  before_validation :normalize_attributes

  validates :name, presence: true, length: { maximum: MAX_NAME }, uniqueness: { case_sensitive: false }
  validates :distance, numericality: { integer_only: true, greater_than: 0 }

  def self.search(params, path, opt={})
    matches = case params[:order]
    when "created"
      order(:id)
    when "distance"
      order(:distance)
    else
      order(:name)
    end
    if sql = cross_constraint(params[:q], %w{title note})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def note_html
    data = [
      [I18n.t('star.distance'), distance, I18n.t('star.unit.distance')],
    ].map do |d|
      "* #{d[0]}: #{d[1]} #{d[2]}"
    end.join("\n")
    to_html(data + "\n\n" + note)
  end

  private

  def normalize_attributes
    name&.squish!
    self.note = "" if note.nil?
    note.lstrip!
    note.rstrip!
    note.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
  end
end
