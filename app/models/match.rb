class Match < ApplicationRecord
  include Pageable

  belongs_to :home_team, class_name: "Team"
  belongs_to :away_team, class_name: "Team"

  validates :home_team_id, numericality: { integer_only: true, greater_than: 0 }, uniqueness: { scope: [:season, :away_team_id] }
  validates :away_team_id, numericality: { integer_only: true, greater_than: 0 }, uniqueness: { scope: [:season, :home_team_id] }
  validates :home_score, :away_score, numericality: { integer_only: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :season, numericality: { integer_only: true, greater_than_or_equal_to: 2020 }
  validates :date, presence: true, uniqueness: { scope: :home_team_id }
  validate :team_cant_play_itself

  scope :by_date, -> { order(date: :desc) }

  def score
    if home_score.present? && away_score.present?
      "#{home_score}-#{away_score}"
    else
      "-"
    end
  end

  def self.search(params, path, opt={})
    matches = by_date
    if (season = params[:season].to_i) > 0
      matches = matches.where(season: season)
    end
    if (team_id = params[:team_id].to_i) > 0
      matches = matches.where("away_team_id = ? OR away_team_id = ?", team_id, team_id)
    end
    paginate(matches, params, path, opt)
  end

  private

  def team_cant_play_itself
    if home_team_id.present? && home_team_id == away_team_id
      errors.add(:home_team_id, "a team can't play itself")
    end
  end
end
