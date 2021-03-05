class Place < ApplicationRecord
  include Constrainable
  include Pageable

  MAX_NAME = 30
  MAX_VBOX = 17
  MAX_WIKI = 50
  MIN_POP = 1 # in units of 100,000
  CATS = {"region" => 0, "prefecture" => 1, "city" => 2}
  DEF_VBOX = "-100 300 750 750"

  has_many :subregions, class_name: "Place", foreign_key: "region_id"
  belongs_to :region, class_name: "Place", optional: true

  before_validation :normalize_attributes

  validates :ename, presence: true, length: { maximum: MAX_NAME }, uniqueness: true
  validates :jname, presence: true, length: { maximum: MAX_NAME }, uniqueness: true
  validates :reading, presence: true, length: { maximum: MAX_NAME }
  validates :vbox, length: { maximum: MAX_VBOX }, format: { with: /\A-?(0|[1-9]\d{0,2}) ([1-9]\d{0,3}) ([1-9]\d{0,2}) ([1-9]\d{0,2})\z/ }, uniqueness: true, allow_nil: true
  validates :wiki, presence: true, length: { maximum: MAX_WIKI }, uniqueness: true
  validates :category, inclusion: { in: CATS.keys }
  validates :pop, numericality: { integer_only: true, more_than_or_equal_to: MIN_POP }

  validate :check_region

  scope :by_ename,   -> { order(:ename) }
  scope :by_pop,     -> { order(pop: :desc) }
  scope :by_created, -> { order(:created_at) }

  def self.search(params, path, opt={})
    matches =
      case params[:order]
      when "pop" then by_pop
                 else by_ename
      end
    matches = matches.includes(:region)
    if sql = cross_constraint(params[:q], %w{ename jname reading})
      matches = matches.where(sql)
    end
    if (cat = params[:cat]).present?
      matches = matches.where(category: cat)
    end
    if (kanji = params[:kanji]).present?
      matches = matches.where("jname ILIKE '%%%s%%'", kanji)
    end
    paginate(matches, params, path, opt)
  end

  def millions
    "%.1f" % (pop / 10.0)
  end

  private

  def normalize_attributes
    ename&.squish!
    jname&.squish!
    reading&.squish!
    vbox&.squish!
    wiki&.squish!
    self.vbox = nil unless vbox.present?
    self.region_id = nil if region_id.to_i == 0
  end

  def check_region
    return unless region.present?
    my_level = CATS[category].to_i
    errors.add(:region_id, "top level can't have a parent") if my_level == 0
    their_level = CATS[region.category].to_i
    errors.add(:region_id, "invalid parent level (#{their_level}) for level (#{my_level})") unless my_level == their_level + 1
  end
end
