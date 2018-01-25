class OccupationsController < ApplicationController
  authorize_resource
  before_action :find_occupation, only: [:destroy, :edit, :show, :update]

  def index
    @occupations = Occupation.search(params, occupations_path, remote: true, per_page: 20)
  end

  def new
    @occupation = Occupation.new
  end

  def create
    @occupation = Occupation.new(strong_params)
    if @occupation.save
      redirect_to @occupation
    else
      render action: "new"
    end
  end

  def update
    if @occupation.update(strong_params)
      redirect_to @occupation
    else
      render action: "edit"
    end
  end

  def destroy
    @occupation.destroy
    redirect_to occupations_path
  end

  private

  def find_occupation
    @occupation = Occupation.find(params[:id])
  end

  def strong_params
    params.require(:occupation).permit(:kanji, :meaning, :reading)
  end
end
