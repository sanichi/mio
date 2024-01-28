class ConstellationsController < ApplicationController
  authorize_resource
  before_action :find_constellation, only: [:show, :edit, :update, :destroy]

  def index
    @constellations = Constellation.search(params, constellations_path, per_page: 10)
  end

  def new
    @constellation = Constellation.new
  end

  def create
    @constellation = Constellation.new(strong_params)
    if @constellation.save
      redirect_to @constellation
    else
      failure @constellation
      render :new
    end
  end

  def update
    if @constellation.update(strong_params)
      redirect_to @constellation
    else
      failure @constellation
      render :edit
    end
  end

  def destroy
    @constellation.destroy
    redirect_to constellations_path
  end

  private

  def find_constellation
    @constellation = Constellation.find(params[:id])
  end

  def strong_params
    params.require(:constellation).permit(:name, :iau, :wikipedia, :note)
  end
end
