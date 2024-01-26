class Constellation < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable

  MAX_NAME = 30
  MAX_IAU = 3

  before_validation :normalize_attributes

  validates :name, presence: true, length: { maximum: MAX_NAME }, uniqueness: { case_sensitive: false }
  validates :iau, presence: true, format: { with: /\A[A-Z][A-Za-z][a-z]\z/ }, uniqueness: { case_sensitive: false }

  def self.search(params, path, opt={})
    matches = case params[:order]
    when "created"
      order(:id)
    when "iau"
      order(:iau)
    else
      order(:name)
    end
    if sql = cross_constraint(params[:q], %w{name iau note})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def note_html = to_html(note)

  # https://www.iau.org/public/themes/constellations/
  def iau_image_link
    path = "images/iau_%s.gif" % name.downcase.gsub(" ", "_")
    return nil unless (Rails.root + "public" + path).exist?
    return "/#{path}"
  end

  private

  def normalize_attributes
    name&.squish!
    iau&.squish!
    self.note = "" if note.nil?
    note.lstrip!
    note.rstrip!
    note.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
  end
end
