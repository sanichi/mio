class MassesController < ApplicationController
  before_action :find_mass, only: [:edit, :update, :destroy]

  def index
    @masses = Mass.search(params, masses_path)
  end

  def graph
    @mgd = MassGraphData.new
  end

  def new
    @mass = Mass.new
    @mass.date = Mass.any?? Mass.maximum(:date) + 1 : Date.today
  end

  def create
    @mass = Mass.new(strong_params)
    if @mass.save
      redirect_to masses_path
    else
      render "new"
    end
  end

  def update
    if @mass.update(strong_params)
      redirect_to masses_path
    else
      render "edit"
    end
  end

  def destroy
    @mass.destroy
    redirect_to masses_path
  end

  private

  def find_mass
    @mass = Mass.find(params[:id])
  end

  def strong_params
    params.require(:mass).permit(:date, :start, :finish)
  end
end
