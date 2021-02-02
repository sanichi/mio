class Team < ApplicationRecord
  include Constrainable
  include Pageable

  MAX_NAME = 30
  MAX_SHORT = 15
  MAX_DIVISION = 4
  MIN_DIVISION = 1

  before_validation :normalize_attributes

  validates :name, presence: true, length: { maximum: MAX_NAME }, uniqueness: true
  validates :short, presence: true, length: { maximum: MAX_SHORT }, uniqueness: true
  validates :slug, presence: true, length: { maximum: MAX_NAME }, uniqueness: true, format: { with: /\A[a-z]+(-[a-z]+)*\z/ }
  validates :division, numericality: { integer_only: true, more_than_or_equal_to: MIN_DIVISION, less_than_or_equal_to: MAX_DIVISION }

  scope :by_name,    -> { order(:name) }
  scope :by_created, -> { order(:created_at) }

  def self.search(params, path, opt={})
    matches = by_name
    if sql = cross_constraint(params[:q], %w{name})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def results
    url = "https://www.bbc.co.uk/sport/football/teams/#{slug}/scores-fixtures"
    uri = URI.parse(url)
    begin
      # get the response
      response = Net::HTTP.get_response(uri)
      body = response.body

      # pick out the line containing the data
      if body =~ /<script>Morph\.toInit\.payloads\.push\(function\(\) \{ Morph\.setPayload\('\/data\/bbc-morph-football-scores-match-list-data([^<]+)/
        script = $1
      else
        raise "can't find script"
      end

      # try to extract the JSON from this
      if script =~ /(\{"meta":\{.*\}\]\}\]\}\}\]\}\})/
        json = $1
      else
        raise "can't get JSON"
      end

      # parse and return the JSON
      data = JSON.parse(json)
      raise "json data is not a hash" unless data.is_a?(Hash)

      # this should have a body hash
      body = data['body']
      raise "can't find body" unless body.is_a?(Hash)

      # this should have matchData array
      matchData = body['matchData']
      raise "can't find matchData" unless matchData.is_a?(Array) && matchData.size > 0

      # this should be an array of hashes with tournamentDatesWithEvents entries
      tournamentDatesWithEvents = matchData.map do |md|
        md.is_a?(Hash) ? md['tournamentDatesWithEvents'] : nil
      end.compact
      raise "can't get tournamentDatesWithEvents" unless tournamentDatesWithEvents.size == matchData.size

      tournamentDatesWithEvents
    rescue => e
      e.message
    end
  end

  private

  def normalize_attributes
    name&.squish!
    slug&.squish!
    short&.squish!
  end
end
