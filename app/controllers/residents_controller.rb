class ResidentsController < ApplicationController
  authorize_resource
  before_action :find_resident, only: [:show, :edit, :update, :destroy]

  def index
    @residents = Resident.search(params, residents_path, remote: true)
  end

  def new
    @resident = Resident.new
  end

  def create
    @resident = Resident.new(strong_params)
    if @resident.save
      redirect_to @resident
    else
      render action: "new"
    end
  end

  def update
    if @resident.update(strong_params)
      redirect_to @resident
    else
      render action: "edit"
    end
  end

  def destroy
    @resident.destroy
    redirect_to residents_path
  end

  private

  def find_resident
    @resident = Resident.find(params[:id])
  end

  def strong_params
    params.require(:resident).permit(:first_names, :last_name, :email)
  end
end
