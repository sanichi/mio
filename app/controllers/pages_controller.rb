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
    @dun, @due, @more_dun, @most_dun, @deft_dun, @more_due, @most_due, @deft_due = dun_due(params[:dun], params[:due])
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

  private

  def dun_due(dun, due)
    if dun.present? && dun.match?(/\A(10|\d)\z/)
      dun = dun.to_i
      due = 10 - dun
    elsif due.present? && due.match?(/\A(10|\d)\z/)
      due = due.to_i
      dun = 10 - due
    else
      dun = 5
      due = 5
    end
    more_dun = most_dun = deft_dun = more_due = most_due = deft_due = nil
    most_dun = 10      if dun < 10
    more_dun = dun + 1 if dun < 9
    deft_dun = 5       if dun < 4
    most_due = 10      if due < 10
    more_due = due + 1 if due < 9
    deft_due = 5       if due < 4
    [dun, due, more_dun, most_dun, deft_dun, more_due, most_due, deft_due]
  end
end
