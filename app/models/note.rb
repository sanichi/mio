class Note < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable

  MAX_TITLE = 150

  before_validation :normalize_attributes

  validates :stuff, presence: true
  validates :title, presence: true, length: { maximum: MAX_TITLE }

  def self.search(params, path, opt={})
    matches = case params[:order]
    when "created" then order(created_at: :asc)
    when "title"   then order(:title)
    else                order(updated_at: :desc)
    end
    if sql = cross_constraint(params[:q], %w{title stuff})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def stuff_html
    to_html(stuff)
  end

  private

  def normalize_attributes
    title.squish!
    stuff.lstrip!
    stuff.rstrip!
    stuff.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
  end
end
