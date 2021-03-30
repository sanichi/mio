class PlacesController < ApplicationController
  authorize_resource
  before_action :find_place, only: [:show, :edit, :update, :destroy]

  def index
    remember_last_search(places_path)
    @places = Place.search(params, places_path, per_page: 10)
  end

  def new
    @place = Place.new
  end

  def create
    @place = Place.new(strong_params)
    if @place.save
      redirect_to @place
    else
      failure @place
      render :new
    end
  end

  def update
    if @place.update(strong_params)
      redirect_to @place
    else
      failure @place
      render :edit
    end
  end

  def destroy
    @place.destroy
    redirect_to places_path
  end

  private

  def find_place
    if action_name == "show" && params[:id].to_i == 0
      @place = Place.find_by!(jname: params[:id])
    else
      @place = Place.find(params[:id])
    end
  end

  def strong_params
    params.require(:place).permit(:capital, :category, :ename, :jname, :notes, :pop, :reading, :parent_id, :vbox, :wiki)
  end
end
