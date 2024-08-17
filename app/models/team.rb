class Team < ApplicationRecord
  include Constrainable
  include Pageable

  [:won, :diff, :drawn, :lost, :played, :points, :for, :against].each do |a|
    attribute a, :integer, default: 0
  end
  attribute :latest_results
  attribute :upcoming_fixtures

  MAX_NAME = 30
  MAX_SHORT = 15
  MAX_DIVISION = 4
  MIN_DIVISION = 1
  DEDUCTIONS = {
    2023 => {
      "everton" => 8,
      "nottingham-forest" => 4,
    }
  }

  has_many :home_matches, class_name: "Match", dependent: :destroy, foreign_key: "home_team_id"
  has_many :away_matches, class_name: "Match", dependent: :destroy, foreign_key: "away_team_id"

  before_validation :normalize_attributes

  validates :name, presence: true, length: { maximum: MAX_NAME }, uniqueness: true
  validates :short, presence: true, length: { maximum: MAX_SHORT }, uniqueness: true
  validates :slug, presence: true, length: { maximum: MAX_NAME }, uniqueness: true, format: { with: /\A[a-z]+(-[a-z]+)*\z/ }
  validates :division, numericality: { integer_only: true, more_than_or_equal_to: MIN_DIVISION, less_than_or_equal_to: MAX_DIVISION }

  scope :by_name,    -> { order(:name) }
  scope :by_short,   -> { order(:short) }
  scope :by_created, -> { order(:created_at) }

  def self.search(params, path, opt={})
    matches = by_name
    if sql = cross_constraint(params[:q], %w{name})
      matches = matches.where(sql)
    end
    if (division = params[:division].to_i) >= MIN_DIVISION
      matches = matches.where(division: division)
    end
    paginate(matches, params, path, opt)
  end

  def self.find_top_team(q)
    matches = by_name.where(division: 1)
    if sql = cross_constraint(q, %w{name short})
      matches = matches.where(sql)
    end
    matches.to_a
  end

  def max(season)
    home_tot = home_matches.where(season: season).count
    away_tot = away_matches.where(season: season).count
    home_due = home_matches.where(season: season).where(home_score: nil).where(away_score: nil).count
    away_due = away_matches.where(season: season).where(home_score: nil).where(away_score: nil).count
    home_dun = home_tot - home_due
    away_dun = away_tot - away_due
    [home_dun + away_dun, home_due + away_due]
  end

  def stats(season, dun, due)
    # use completed matches to update teams points, goal difference, etc
    home = home_matches.by_date.where(season: season).where.not(home_score: nil).where.not(away_score: nil)
    away = away_matches.by_date.where(season: season).where.not(home_score: nil).where.not(away_score: nil)
    home.each { |m| goals m.home_score, m.away_score }
    away.each { |m| goals m.away_score, m.home_score }

    # check for deductions
    if deduction = DEDUCTIONS.dig(season, slug)
      self.points -= deduction
    end

    # latest results
    if dun > 0
      self.latest_results = (home.take(dun) + away.take(dun)).sort_by{ |m| m.date }.reverse.take(dun).reverse
    else
      self.latest_results = []
    end

    # latest upcoming fixtures
    if due > 0
      home = home_matches.by_date.where(season: season).where(home_score: nil).where(away_score: nil)
      away = away_matches.by_date.where(season: season).where(home_score: nil).where(away_score: nil)
      self.upcoming_fixtures = (home.reverse.take(due) + away.reverse.take(due)).sort_by{ |m| m.date }.take(due)
    else
      self.upcoming_fixtures = []
    end

    self
  end

  private

  def normalize_attributes
    name&.squish!
    slug&.squish!
    short&.squish!
  end

  def goals(us, them)
    self.played += 1
    self.for += us
    self.against += them
    self.diff += us - them
    if us > them
      self.won += 1
      self.points += 3
    end
    if us == them
      self.drawn += 1
      self.points += 1
    end
    if us < them
      self.lost += 1
    end
  end
end
