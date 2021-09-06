class PagesController < ApplicationController
  # see https://github.com/CanCanCommunity/cancancan/wiki/Non-RESTful-Controllers
  authorize_resource class: false

  def risle
    @flats = Flat.where.not(bay: nil).order(:bay).all
  end

  def pam
    @answer = Flat.pam(params[:q])
  end

  def weight
    @kilos = Mass.kilos
    @dates = Mass.dates
    @unit = Mass::UNITS[params[:unit].try(:to_sym)] || Mass::DEFAULT_UNIT
  end

  def premier
    @season = helpers.check_season(params[:season])
    @teams = Team.stats(@season)
  end

  def prefectures
    @elements = Place.map_elements.to_a
  end

  def ruby
    year = params[:year].to_i
    day  = params[:day].to_i
    part = params[:part].to_i
    answer = nil
    begin
      raise "invalid part" unless part == 1 || part == 2
      @part = part
      file = Rails.root + "public/aoc/#{year}/#{day}.txt"
      raise "no data" unless file.file?
      @data = file.read
      file = Rails.root + "lib/aoc/y#{year}d#{day}.rb"
      raise "no code" unless file.file?
      answer = eval(file.read)
    rescue => e
      answer = e.message
    end
    render plain: answer
  end
end
