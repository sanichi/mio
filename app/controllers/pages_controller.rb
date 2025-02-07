class PagesController < ApplicationController
  # see https://github.com/CanCanCommunity/cancancan/wiki/Non-RESTful-Controllers
  authorize_resource class: false

  def env
    dirs = `ls /home/sanichi/.passenger/native_support 2>&1`
    vers = dirs.scan(/\d*\.\d*\.\d*/)
    @passenger_version = vers.any? ? vers.last : "not found"
    vers = ActiveRecord::Base.connection.execute('select version();').values[0][0] rescue "oops"
    @postgres_version = vers.match(/(1[4-6]\.\d+)/)? $1 : "not found"
    @host = ENV["HOSTNAME"] || `hostname`.chop.sub(".local", "")
  end

  def pam
    @answer = Flat.pam(params[:q])
  end

  def prefectures
    @elements = Place.map_elements.to_a
  end

  def premier
    @data = helpers.premier_data(params[:season], params[:dun_due])
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
    @unit = Mass::UNITS[params[:unit].try(:to_sym)] || Mass::DEFAULT_UNIT
  end
end
