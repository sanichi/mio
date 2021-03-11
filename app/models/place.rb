class Place < ApplicationRecord
  include Constrainable
  include Pageable

  MAX_NAME = 30
  MAX_VBOX = 17
  MAX_WIKI = 50
  MIN_POP = 1 # in units of 100,000
  CATS = {"region" => 0, "prefecture" => 1, "designated" => 2, "core" => 2, "city" => 2}
  DEF_VBOX = "-100 300 750 750"

  has_many :children, class_name: "Place", foreign_key: "parent_id"
  belongs_to :parent, class_name: "Place", optional: true

  before_validation :normalize_attributes

  validates :ename, presence: true, length: { maximum: MAX_NAME }, uniqueness: true
  validates :jname, presence: true, length: { maximum: MAX_NAME }, uniqueness: true
  validates :reading, presence: true, length: { maximum: MAX_NAME }
  validates :vbox, length: { maximum: MAX_VBOX }, format: { with: /\A-?(0|[1-9]\d{0,2}) ([1-9]\d{0,3}) ([1-9]\d{0,2}) ([1-9]\d{0,2})\z/ }, uniqueness: true, allow_nil: true
  validates :wiki, presence: true, length: { maximum: MAX_WIKI }, uniqueness: true
  validates :category, inclusion: { in: CATS.keys }
  validates :pop, numericality: { integer_only: true, more_than_or_equal_to: MIN_POP }

  validate :check_parent
  validate :check_capital

  scope :by_ename,   -> { order(:ename) }
  scope :by_pop,     -> { order(pop: :desc) }
  scope :by_created, -> { order(:created_at) }

  def self.search(params, path, opt={})
    matches =
      case params[:order]
      when "pop" then by_pop
                 else by_ename
      end
    matches = matches.includes(:parent).includes(:children)
    if sql = cross_constraint(params[:q], %w{ename jname reading})
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
    "%.1f" % (pop / 10.0)
  end

  def vb
    vbox.present?? vbox : (parent.present?? parent.vb : DEF_VBOX)
  end

  def wiki_link
    "https://en.wikipedia.org/wiki/#{wiki}"
  end

  private

  def normalize_attributes
    ename&.squish!
    jname&.squish!
    reading&.squish!
    vbox&.squish!
    wiki&.squish!
    self.vbox = nil unless vbox.present?
    self.parent_id = nil if parent_id.to_i == 0
  end

  def check_parent
    return unless parent.present?
    my_level = CATS[category].to_i
    errors.add(:parent_id, "top level can't have a parent") if my_level == 0
    their_level = CATS[parent.category].to_i
    errors.add(:parent_id, "invalid parent level (#{their_level}) for level (#{my_level})") unless my_level == their_level + 1
  end

  def check_capital
    return unless capital
    errors.add(:capital, "only cities can be capitals") unless CATS[category].to_i == 2
  end
end
