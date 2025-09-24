class PagesController < ApplicationController
  # see https://github.com/CanCanCommunity/cancancan/wiki/Non-RESTful-Controllers
  authorize_resource class: false

  def env
    @passenger_version = `env -i /usr/bin/passenger-config --version`.scan(/\d+\.\d+\.\d+/).first if Rails.env.production?
    psql = ActiveRecord::Base.connection.execute('select version();').values[0][0] rescue "oops"
    @postgres_version = psql.match(/PostgreSQL (1[4-8]\.\d+)/)? $1 : "not found"
    @puma_version = Puma::Const::VERSION if Rails.env.development?
    @host = ENV["HOSTNAME"] || `hostname`.chop.sub(".local", "")
  end

  def pam
    @answer = Flat.pam(params[:q])
  end

  def prefectures
    @elements = Place.map_elements.to_a
  end

  def premier
    @season = params[:season].to_i
    @season = Match.latest_season unless Match.seasons.include?(@season)
  end

  def premier_table
    @data = PremierStats.new(params[:season], params[:date])
    render :premier_table, layout: false
  end

  def risle
    @flats = Flat.where.not(bay: nil).order(:bay).all
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

  def weight
    @kilos = Mass.kilos
    @dates = Mass.dates
    @events = MassEvent.events
  end
end
