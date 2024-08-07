class PlacesController < ApplicationController
  authorize_resource
  before_action :find_place, only: [:show, :edit, :update, :destroy, :move, :shift]

  def index
    remember_last_search(places_path)
    @places = Place.search(params, places_path, per_page: 10)
  end

  def show
    @elements = Place.map_elements.to_a
    if @place.category == "attraction"
      attractions = Place.where(category: "attraction").by_ename.to_a
      @prev = attractions.select{|a| a.ename < @place.ename}.last
      @next = attractions.select{|a| a.ename > @place.ename}.first
    end
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

  def move
    @elements = Place.map_elements.to_a
  end

  def shift
    @place.move(params[:type], params[:direction], params[:delta])
    @elements = Place.map_elements.to_a
    render :shift, layout: false
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
    params.require(:place).permit(:capital, :category, :ename, :jname, :mark_position, :notes, :pop, :reading, :parent_id, :text_position, :vbox, :wiki)
  end
end
