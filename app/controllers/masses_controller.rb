class MassesController < ApplicationController
  authorize_resource
  before_action :find_mass, only: [:edit, :update, :destroy]
  before_action :get_unit, only: [:index]

  def index
    response.headers["Access-Control-Allow-Origin"] = "*" # allow cross origin requests
    @masses = Mass.search(params, masses_path)
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @masses.matches.map(&:to_json) }
    end
  end

  def new
    @mass = Mass.new
    @mass.date = Mass.any?? Mass.maximum(:date) + 1 : Date.today
  end

  def create
    @mass = Mass.new(strong_params)
    if @mass.save
      redirect_to weight_path
    else
      failure @mass
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @mass.update(strong_params)
      redirect_to weight_path
    else
      failure @mass
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @mass.destroy
    redirect_to weight_path
  end

  private

  def find_mass
    @mass = Mass.find(params[:id])
  end

  def get_unit
    @unit = Mass::UNITS[params[:unit].try(:to_sym)] || Mass::DEFAULT_UNIT
  end

  def strong_params
    params.require(:mass).permit(:date, :start, :finish)
  end
end
