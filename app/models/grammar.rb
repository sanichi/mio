class Grammar < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable
  include Vocabable

  LEVELS = (1..5).to_a
  MAX_TITLE = 100
  MAX_REGEXP = 50

  before_validation :normalize_attributes
  after_save :reset_examples_on_regexp_change

  validates :level, inclusion: { in: LEVELS }
  validates :title, presence: true, length: { maximum: MAX_TITLE }, uniqueness: true
  validates :regexp, length: { maximum: MAX_REGEXP }, allow_nil: true
  validates :last_example_checked, numericality: { integer_only: true, greater_than_or_equal_to: 0 }
  validate :check_regexp

  def self.search(matches, params, path, opt={})
    case params[:order]
    when "title"
      matches = matches.order(:title)
    when "level"
      matches = matches.order(level: :desc, title: :asc)
    else
      matches = matches.order(:title)
    end
    if LEVELS.include?(params[:level].to_i)
      matches = matches.where(level: params[:level].to_i)
    end
    if sql = cross_constraint(params[:query], %w{title note})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def update_level!(delta)
    if delta == 1 || delta == -1
      new_level = level + delta
      update_column(:level, new_level) if LEVELS.include?(new_level)
    end
  end

  def update_examples
    if regexp.present?
      last_example = Wk::Example.maximum(:id).to_i
      if last_example_checked < last_example
        re = Regexp.new(regexp)
        new_examples = Wk::Example.where("id > #{last_example_checked}").filter_map do |e|
          e.id if e.japanese.match?(re)
        end
        update_column(:examples, examples.concat(new_examples)) unless new_examples.empty?
        update_column(:last_example_checked, last_example)
      end
    end
    Wk::Example.where(id: examples).includes([:vocabs]).to_a
  end

  def note_html
    extra = regexp.present? ? "Regexp: `#{regexp}`\n\n" : ""
    markdown = (note || "").prepend(extra)
    to_html(link_vocabs(markdown))
  end

  private

  def normalize_attributes
    self.regexp = nil if regexp.blank?
    title&.squish!
    if note.blank?
      self.note = nil
    else
      note.lstrip!
      note.rstrip!
      note.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
    end
  end

  def check_regexp
    return unless regexp.present?
    begin
      Regexp.new(regexp)
    rescue RegexpError
      errors.add(:regexp, "invalid")
    end
  end

  def reset_examples_on_regexp_change
    if regexp_previously_changed?
      update_column(:examples, []) unless examples.empty?
      update_column(:last_example_checked, 0) unless last_example_checked == 0
    end
  end
end
