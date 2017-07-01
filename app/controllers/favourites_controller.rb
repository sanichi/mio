class FavouritesController < ApplicationController
  authorize_resource
  before_action :find_favourite, only: [:show, :edit, :update, :destroy]

  def index
    @favourites = Favourite.search(params, favourites_path, per_page: 20, remote: true)
  end

  def new
    @favourite = Favourite.new
  end

  def create
    @favourite = Favourite.new(strong_params)
    if @favourite.save
      redirect_to @favourite
    else
      render "new"
    end
  end

  def update
    if @favourite.update(strong_params)
      redirect_to @favourite
    else
      render action: "edit"
    end
  end

  def destroy
    @favourite.destroy
    redirect_to favourites_path
  end

  private

  def find_favourite
    @favourite = Favourite.find(params[:id])
  end

  def strong_params
    params.require(:favourite).permit(:category, :link, :mark, :name, :note, :sandra, :year)
  end
end
