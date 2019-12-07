class PagesController < ApplicationController
  authorize_resource

  def risle
    @flats = Flat.where.not(bay: nil).order(:bay).all
  end

  def check
    respond_to do |format|
      format.json { render json: ::Checker.check }
    end
  end

  def pam
    @answer = Flat.pam(params[:q])
  end
end
