class Place < ApplicationRecord
  include Constrainable
  include Pageable

  MAX_NAME = 30
  MAX_WIKI = 50
  MIN_POP = 1 # in units of 100,000
  CATS = {"region" => 0, "prefecture" => 1, "city" => 2}

  has_many :subregions, class_name: "Place", foreign_key: "region_id"
  belongs_to :region, class_name: "Place", optional: true

  before_validation :normalize_attributes

  validates :ename, presence: true, length: { maximum: MAX_NAME }, uniqueness: { scope: :category }
  validates :jname, presence: true, length: { maximum: MAX_NAME }, uniqueness: { scope: :category }
  validates :reading, presence: true, length: { maximum: MAX_NAME }
  validates :wiki, presence: true, length: { maximum: MAX_WIKI }, uniqueness: true
  validates :category, inclusion: { in: CATS.keys }
  validates :pop, numericality: { integer_only: true, more_than_or_equal_to: MIN_POP }

  scope :by_ename,   -> { order(:ename) }
  scope :by_pop,     -> { order(pop: :desc) }
  scope :by_created, -> { order(:created_at) }

  def self.search(params, path, opt={})
    matches = by_ename
    if sql = cross_constraint(params[:q], %w{ename jname reading})
      matches = matches.where(sql)
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
    wiki&.squish!
  end
end
