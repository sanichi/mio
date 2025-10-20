class Place < ApplicationRecord
  include Constrainable
  include Linkable
  include Pageable
  include Remarkable

  MAX_NAME = 30
  MAX_VBOX = 17
  MAX_WIKI = 50
  MAX_POSN = 9
  MIN_POP = 0 # in units of 100,000
  X, Y, W, H = [-100, 300, 750, 750]
  DEF_VBOX = "#{X} #{Y} #{W} #{H}"
  POSITION = /\A(0|-?[1-9]\d{0,2}),([1-9]\d{2,3})\z/

  CATS = {
    "region" => 0,
    "prefecture" => 1,
    "designated" => 2,
    "core" => 2,
    "city" => 2,
    "attraction" => 3,
  }
  CATS.keys.each do |cat|
    define_method "#{cat}?" do
      self.category == cat
    end
  end

  has_many :children, class_name: "Place", foreign_key: "parent_id"
  belongs_to :parent, class_name: "Place", optional: true

  before_validation :normalize_attributes

  with_options presence: true, length: { maximum: MAX_NAME } do
    validates :ename, uniqueness: true
    validates :jname, uniqueness: true
    validates :reading
  end
  validates :vbox, length: { maximum: MAX_VBOX }, format: { with: /\A-?(0|[1-9]\d{0,2}) ([1-9]\d{0,3}) ([1-9]\d{0,2}) ([1-9]\d{0,2})\z/ }, uniqueness: true, allow_nil: true
  validates :wiki, presence: true, length: { maximum: MAX_WIKI }, uniqueness: true
  validates :category, inclusion: { in: CATS.keys }
  validates :pop, numericality: { integer_only: true, more_than_or_equal_to: MIN_POP }
  validates :mark_position, :text_position, length: { maximum: MAX_POSN }, format: { with: POSITION }, allow_nil: true

  validate :check_parent
  validate :check_capital
  validate :check_pop

  scope :by_ename,     -> { order(:ename) }
  scope :by_pop,       -> { order(pop: :desc) }
  scope :by_created,   -> { order(:created_at) }
  scope :map_elements, -> { where("mark_position IS NOT NULL OR text_position IS NOT NULL") }

  def self.search(params, path, opt={})
    matches =
      case params[:order]
      when "pop" then by_pop
                 else by_ename
      end
    matches = matches.includes(:parent).includes(:children)
    if sql = cross_constraint(params[:q], %w{ename jname reading notes})
      matches = matches.where(sql)
    end
    if CATS.has_key?(params[:cat])
      matches = matches.where(category: params[:cat])
    elsif params[:cat] == "cities"
      matches = matches.where(category: ["city", "core", "designated"])
    end
    if (kanji = params[:kanji]).present?
      matches = matches.where("jname ILIKE '%%%s%%'", kanji)
    end
    paginate(matches, params, path, opt)
  end

  def millions
    pop == 0 ? "" : "%.1f" % (pop / 10.0)
  end

  def vb
    vbox.present?? vbox : (parent.present?? parent.vb : DEF_VBOX)
  end

  def wiki_link
    "https://en.wikipedia.org/wiki/#{wiki}"
  end

  def notes_html
    to_html(link_vocabs(notes))
  end

  def mark_x
    mark_position&.match(POSITION) && $1
  end

  def mark_y
    mark_position&.match(POSITION) && $2
  end

  def text_x
    text_position&.match(POSITION) && $1
  end

  def text_y
    text_position&.match(POSITION) && $2
  end

  def move(type, direction, delta)
    d = delta.to_i
    return unless d > 0
    dx = direction == "e" ? d : (direction == "w" ? -d : 0)
    dy = direction == "s" ? d : (direction == "n" ? -d : 0)
    return if dx == 0 && dy == 0
    case type
    when "mark"
      if mark_y
        update_column(:mark_position, "%d,%d" % [mark_x.to_i + dx, mark_y.to_i + dy])
      end
    when "text"
      if text_y
        update_column(:text_position, "%d,%d" % [text_x.to_i + dx, text_y.to_i + dy])
      end
    end
  end

  def sjname
    case category
    when "region"
      jname.sub(/地方\z/, "")
    when "prefecture"
      jname.sub(/(県|府|都)\z/, "")
    when "attraction"
      jname
    else
      jname.sub(/(市|都|特別区)\z/, "")
    end
  end

  def name_echo?
    parent.present? && sjname == parent.sjname
  end

  def to_markdown(display: nil)
    display = jname unless display
    "[#{display}](/places/#{id})"
  end

  private

  def normalize_attributes
    ename&.squish!
    jname&.squish!
    reading&.squish!
    vbox&.squish!
    wiki&.squish!
    notes&.lstrip!
    notes&.rstrip!
    notes&.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
    self.pop = 0 if attraction?
    self.vbox = nil if vbox.blank?
    self.parent_id = nil if parent_id.to_i == 0
    self.text_position = nil if text_position.blank?
    self.mark_position = nil if mark_position.blank?
  end

  def check_parent
    return unless parent.present?
    my_level = CATS[category].to_i
    errors.add(:parent_id, "top level can't have a parent") if my_level == 0
    their_level = CATS[parent.category].to_i
    unless my_level == their_level + 1 || (my_level == 3 && their_level == 1)
      errors.add(:parent_id, "invalid parent level (#{their_level}) for level (#{my_level})")
    end
  end

  def check_capital
    return unless capital?
    errors.add(:capital, "only cities can be capitals") unless CATS[category].to_i == 2
  end

  def check_pop
    if attraction?
      errors.add(:pop, "attractions should have no population") unless pop == 0
    else
      errors.add(:pop, "non-attractions should have non-zero population") unless pop > 0
    end
  end
end
