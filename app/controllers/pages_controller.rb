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
end
