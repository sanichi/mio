class MassesController < ApplicationController
  authorize_resource
  before_action :find_mass, only: [:edit, :update, :destroy]
  before_action :get_unit, only: [:index, :graph]
  before_action :get_start, only: :graph

  def index
    response.headers["Access-Control-Allow-Origin"] = "*" # allow cross origin requests
    @masses = Mass.search(params, masses_path, remote: true)
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @masses.matches.map(&:to_json) }
    end
  end

  def graph
    @mgd = MassGraphData.new(@unit, @start)
  end

  def new
    @mass = Mass.new
    @mass.date = Mass.any?? Mass.maximum(:date) + 1 : Date.today
  end

  def create
    @mass = Mass.new(strong_params)
    if @mass.save
      redirect_to graph_masses_path
    else
      failure @mass
      render :new
    end
  end

  def update
    if @mass.update(strong_params)
      redirect_to graph_masses_path
    else
      failure @mass
      render :edit
    end
  end

  def destroy
    @mass.destroy
    redirect_to graph_masses_path
  end

  private

  def find_mass
    @mass = Mass.find(params[:id])
  end

  def get_unit
    @unit = Mass::UNITS[params[:unit].try(:to_sym)] || Mass::DEFAULT_UNIT
  end

  def get_start
    @start = params[:start] || Mass::DEFAULT_START
  end

  def strong_params
    params.require(:mass).permit(:date, :start, :finish)
  end
end
