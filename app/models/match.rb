class Match < ApplicationRecord
  include Pageable

  MIN_SEASON = 2010

  belongs_to :home_team, class_name: "Team"
  belongs_to :away_team, class_name: "Team"

  validates :home_team_id, numericality: { integer_only: true, greater_than: 0 }, uniqueness: { scope: [:season, :away_team_id] }
  validates :away_team_id, numericality: { integer_only: true, greater_than: 0 }, uniqueness: { scope: [:season, :home_team_id] }
  validates :home_score, :away_score, numericality: { integer_only: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :season, numericality: { integer_only: true, greater_than_or_equal_to: MIN_SEASON }
  validates :date, presence: true, uniqueness: { scope: :home_team_id }
  validate :team_cant_play_itself

  scope :by_date, -> { order(date: :desc) }

  def score
    "#{home_score || '?'}-#{away_score || '?'}"
  end

  def summary
    "#{home_team.short} - #{away_team.short} #{score} #{date}"
  end

  def self.search(params, path, opt={})
    matches = by_date
    if (season = params[:season].to_i) > 0
      matches = matches.where(season: season)
    end
    if (team_id = params[:team_id].to_i) > 0
      matches = matches.where("home_team_id = ? OR away_team_id = ?", team_id, team_id)
    end
    case params[:played].to_i
      when 1 then matches = matches.where("home_score IS NOT NULL AND away_score IS NOT NULL")
      when 2 then matches = matches.where("home_score IS NULL AND away_score IS NULL")
    end
    paginate(matches, params, path, opt)
  end

  def self.current_season
    today = Date.today
    if today.month <= 5
      today.year - 1
    else
      today.year
    end
  end

  def self.seasons() = pluck(:season).uniq.sort
  def self.latest_season() = maximum(:season)

  private

  def team_cant_play_itself
    if home_team_id.present? && home_team_id == away_team_id
      errors.add(:home_team_id, "a team can't play itself")
    end
  end
end
