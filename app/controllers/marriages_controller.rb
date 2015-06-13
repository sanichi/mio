class MarriagesController < ApplicationController
  authorize_resource
  before_action :find_marriage, only: [:destroy, :edit, :show, :update]

  def index
    @marriages = Marriage.search(params, marriages_path, remote: true)
  end

  def new
    @marriage = Marriage.new
  end

  def create
    @marriage = Marriage.new(strong_params)
    if @marriage.save
      redirect_to @marriage
    else
      render "new"
    end
  end

  def update
    if @marriage.update(strong_params)
      redirect_to @marriage
    else
      render "edit"
    end
  end

  def destroy
    @marriage.destroy
    redirect_to marriages_path
  end

  private

  def find_marriage
    @marriage = Marriage.find(params[:id])
  end

  def strong_params
    params.require(:marriage).permit(:divorce, :husband_id, :wedding, :wife_id)
  end
end
