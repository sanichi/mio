class TeamsController < ApplicationController
  authorize_resource
  before_action :find_team, only: [:show, :edit, :update, :destroy]

  def index
    remember_last_search(teams_path)
    @teams = Team.search(params, teams_path, per_page: 10)
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(strong_params)
    if @team.save
      redirect_to @team
    else
      failure @team
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @team.update(strong_params)
      redirect_to @team
    else
      failure @team
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_path
  end

  private

  def find_team
    @team = Team.find(params[:id])
  end

  def strong_params
    params.require(:team).permit(:name, :slug, :short, :division)
  end
end
