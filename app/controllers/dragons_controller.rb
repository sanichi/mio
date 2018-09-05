class DragonsController < ApplicationController
  authorize_resource
  before_action :find_dragon, only: [:edit, :update, :destroy]

  def index
    @dragons = Dragon.search(params, dragons_path, per_page: 2, remote: true)
  end

  def new
    @dragon = Dragon.new
  end

  def create
    @dragon = Dragon.new(strong_params)
    if @dragon.save
      redirect_to dragons_path
    else
      render "new"
    end
  end

  def update
    if @dragon.update(strong_params)
      redirect_to dragons_path
    else
      render "edit"
    end
  end

  def destroy
    @dragon.destroy
    redirect_to dragons_path
  end

  private

  def find_dragon
    @dragon = Dragon.find(params[:id])
  end

  def strong_params
    params.require(:dragon).permit(:first_name, :last_name, :male)
  end
end
