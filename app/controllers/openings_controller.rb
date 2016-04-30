class OpeningsController < ApplicationController
  authorize_resource
  before_action :find_opening, only: [:edit, :update, :show, :destroy]

  def index
    @openings = Opening.search(params, openings_path, per_page: 20)
  end

  def new
    @opening = Opening.new
  end

  def create
    @opening = Opening.new(strong_params)
    if @opening.save
      redirect_to @opening
    else
      render "new"
    end
  end

  def update
    if @opening.update(strong_params)
      redirect_to @opening
    else
      render action: "edit"
    end
  end

  def destroy
    @opening.destroy
    redirect_to openings_path
  end

  private

  def find_opening
    @opening = Opening.find(params[:id])
  end

  def strong_params
    params.require(:opening).permit(:code, :description)
  end
end
