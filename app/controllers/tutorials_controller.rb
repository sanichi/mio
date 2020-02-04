class TutorialsController < ApplicationController
  authorize_resource
  before_action :find_tutorial, only: [:show, :edit, :update, :destroy]

  def index
    remember_last_search(tutorials_path)
    @tutorials = Tutorial.search(params, tutorials_path, per_page: 10)
  end

  def new
    @tutorial = Tutorial.new
  end

  def create
    @tutorial = Tutorial.new(strong_params)
    if @tutorial.save
      redirect_to @tutorial
    else
      failure @tutorial
      render :new
    end
  end

  def update
    if @tutorial.update(strong_params)
      redirect_to @tutorial
    else
      failure @tutorial
      render :edit
    end
  end

  def destroy
    @tutorial.destroy
    redirect_to tutorials_path
  end

  private

  def find_tutorial
    @tutorial = Tutorial.find(params[:id])
  end

  def strong_params
    params.require(:tutorial).permit(:date, :notes, :summary)
  end
end
