class Problem < ApplicationRecord
  include Linkable
  include Pageable
  include Remarkable

  MAX_AUDIO = 20
  MAX_LEVEL = I18n.t("problem.levels").size - 1
  MAX_CATEGORY = I18n.t("problem.categories").size - 1
  MAX_SUBCATEGORY = I18n.t("problem.subcategories").size - 1

  has_many :questions, dependent: :destroy

  before_validation :normalize_attributes

  validates :level, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_LEVEL }
  validates :category, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_CATEGORY }
  validates :subcategory, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_SUBCATEGORY }, uniqueness: { scope: [:level, :category] }
  validates :audio, length: { maximum: MAX_AUDIO }, format: { with: /\A[-A-Za-z_\d]+\.(mp3|m4a)\z/ }, uniqueness: { scope: :level }, allow_nil: true
  validates :note, presence: true
  validate  :check_audio

  scope :natural_order, -> { order(:level, :category, :subcategory) }

  def self.search(params, path, opt={})
    matches = natural_order.includes(:questions)
    matches = filter(matches, params, :level, MAX_LEVEL)
    matches = filter(matches, params, :category, MAX_CATEGORY)
    matches = filter(matches, params, :subcategory, MAX_SUBCATEGORY)
    if params[:question].present?
      pids = matches.pluck(:id)
      unless pids.empty?
        pq = Question.search(params[:question])
        if pq.available?
          # filter the problem matches (ActiveRecord_Relation) by the question matches
          matches = matches.where(id: pq.pids)
          # filter the question matches (ProblemQuestion) by the problem matches
          pq.filter(pids)
          # store the ProblemQuestion object for later
          opt[:extra] = pq
        else
          # no question matches, so squash the problem matches
          matches = matches.none
        end
      end
    end
    paginate(matches, params, path, opt)
  end

  def note_html
    to_html(link_vocabs(note))
  end

  def description(locale="jp")
    lev = I18n.t("problem.levels", locale: "en")[level]
    cat = I18n.t("problem.categories", locale: locale)[category]
    sub = I18n.t("problem.subcategories", locale: locale)[subcategory]
    ("%s %s [%s]" % [lev, cat, sub]).html_safe
  end

  def audio_path(abs: false)
    return nil unless audio.present?
    path = "audio/jlpt/n#{1 + level}/#{audio}"
    abs ? (Rails.root + "public" + path).to_s : "/#{path}"
  end

  def audio_type
    return nil unless audio.present?
    "audio/#{audio =~ /\.mp3\z/ ? 'mpeg' : 'mp4'}"
  end

  private

  def normalize_attributes
    audio&.squish!
    self.audio = nil if audio.blank?
    note&.lstrip!
    note&.rstrip!
    note&.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
  end

  def check_audio
    if audio.present?
      errors.add(:audio, "file does not exist") unless File.file?(audio_path(abs: true))
    end
  end

  class << self

    private

    def filter(matches, params, param, max)
      return matches unless params[param]&.match(/\A(0|[1-9]\d*)\z/)
      value = params[param].to_i
      return matches if value > max
      matches.where(param => value)
    end
  end
end
