class Misa < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable

  CATEGORIES = %w/none beginners difference native howto dajare/
  MAX_CATEGORY = 10
  MAX_MINUTES = 6
  MAX_SHORT = 15
  MAX_TITLE = 150

  before_validation :normalize_attributes
  after_save :count_lines

  validates :category, inclusion: { in: CATEGORIES }
  validates :minutes, format: { with: /\A\d{1,3}:[0-5]\d\z/ }
  validates :short, format: { with: /\A\S+\z/}, length: { maximum: MAX_SHORT }
  validates :title, presence: true, length: { maximum: MAX_TITLE }

  def self.search(params, path, opt={})
    matches = case params[:order]
    when "created"
      order(:id)
    else
      order(updated_at: :desc)
    end
    matches = matches.where(category: params[:category]) if CATEGORIES.include?(params[:category])
    if sql = cross_constraint(params[:q], %w{title note})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def note_html
    to_html(note)
  end

  def full_title
    "#{title} (#{I18n.t("misa.categories.#{category}")})"
  end

  def short_url
    "https://www.youtube.com/watch?v=#{short}"
  end

  def target
    "misa"
  end

  private

  def normalize_attributes
    title.squish!
    note&.lstrip!
    note&.rstrip!
    note&.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
  end

  def count_lines
    count = note ? note.split("\n").size : 0
    update_column(:lines, count) unless lines == count
  end
end
