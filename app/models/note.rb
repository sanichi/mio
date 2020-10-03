class Note < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable
  include Vocabable

  MAX_SERIES = 50
  MAX_TITLE = 150
  MAX_NUMBER = 127

  before_validation :normalize_attributes

  validates :number, numericality: { integer_only: true, greater_than: 0, less_than_or_equal_to: MAX_NUMBER }, uniqueness: { scope: :series }, allow_nil: true
  validates :stuff, presence: true
  validates :series, presence: true, length: { maximum: MAX_SERIES }, allow_nil: true
  validates :title, presence: true, length: { maximum: MAX_TITLE }

  def self.search(params, path, opt={})
    matches = case params[:order]
    when "created" then order(created_at: :asc)
    when "title"   then order(:title)
    when "series"  then order(:series, :number)
    else                order(updated_at: :desc)
    end
    if params[:series].present? && Note.pluck(:series).uniq.compact.include?(params[:series])
      matches = matches.where(series: params[:series])
    end
    if sql = cross_constraint(params[:q], %w{title stuff})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def self.random
    find_by(id: where(series: "Daily").pluck(:id).sample)
  end

  def stuff_html
    to_html(link_vocabs(stuff))
  end

  def series_number(links: false)
    return "" unless series
    text = ["#{series} #{number}"]
    if links
      sorted = Note.where(series: series).order(:number)
      index = sorted.index { |n| n.id == id }
      if index
        prv = sorted[index - 1] if index > 0
        nxt = sorted[index + 1] if index < sorted.size - 1
        if prv
          txt = I18n.t("note.prev")
          txt = "#{txt} #{prv.title}" if prv.title.length == 1
          text.unshift(%Q{<a href="/notes/#{prv.id}">#{txt}</a>})
        end
        if nxt
          txt = I18n.t("note.next")
          txt = "#{nxt.title} #{txt}" if nxt.title.length == 1
          text.push(%Q{<a href="/notes/#{nxt.id}">#{txt}</a>})
        end
      end
    end
    text.join(" ").html_safe
  end

  private

  def normalize_attributes
    series&.squish!
    if series.blank?
      self.series = nil
      self.number = nil
    else
      if number.blank? || number < 1
        self.number = Note.where(series: series).maximum(:number).to_i + 1
      end
    end
    stuff&.lstrip!
    stuff&.rstrip!
    stuff&.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
    title&.squish!
  end
end
