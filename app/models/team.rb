class Team < ApplicationRecord
  include Constrainable
  include Pageable

  MAX_NAME = 30
  MAX_SHORT = 15

  has_many :home_matches, class_name: "Match", dependent: :destroy, foreign_key: "home_team_id"
  has_many :away_matches, class_name: "Match", dependent: :destroy, foreign_key: "away_team_id"

  before_validation :normalize_attributes

  validates :name, presence: true, length: { maximum: MAX_NAME }, uniqueness: true
  validates :short, presence: true, length: { maximum: MAX_SHORT }, uniqueness: true

  scope :by_name,    -> { order(:name) }
  scope :by_short,   -> { order(:short) }
  scope :by_created, -> { order(:created_at) }

  def self.search(params, path, opt={})
    matches = by_name
    if sql = cross_constraint(params[:q], %w{name})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def self.find_top_team(q)
    matches = by_name
    if sql = cross_constraint(q, %w{name short})
      matches = matches.where(sql)
    end
    matches.to_a
  end

  private

  def normalize_attributes
    name&.squish!
    short&.squish!
  end
end
