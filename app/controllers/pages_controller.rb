class PagesController < ApplicationController
  authorize_resource

  def risle
    @flats = Flat.where.not(bay: nil).order(:bay).all
    @pdata = ParkingData.new if can?(:read, Parking) || params[:p]
    @pstat = ParkingStat.new if can?(:read, Parking)
  end

  def risle_stats
    @pstat = ParkingStat.new(params)
  end

  def check
    respond_to do |format|
      format.json { render json: ::Checker.check }
    end
  end

  def pam
    @answer = Flat.pam(params[:q])
  end

  def tribute
    @dragons = Dragon.by_last_name.all
    render "tribute", layout: "blank"
  end
end
