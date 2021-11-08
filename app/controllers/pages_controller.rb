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
    @season = helpers.premier_check_season(params[:season])
    @dun, @due, @more_dun, @most_dun, @deft_dun, @more_due, @most_due, @deft_due = helpers.premier_dun_due(params[:dun], params[:due])
    @teams = Team.stats(@season, @dun, @due)
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

      file = Rails.root + "public/aoc/#{year}/#{day}.txt"
      raise "no data" unless file.file?
      input = file.read

      klass = "Aoc::Y#{year}d#{day}"
      raise "no class" unless Object.const_defined?(klass)
      obj = klass.constantize.new(input)

      answer = obj.answer(part)
    rescue => e
      answer = e.message
    end

    render plain: answer
  end
end
