class PartnershipsController < ApplicationController
  authorize_resource
  before_action :find_partnership, only: [:destroy, :edit, :show, :update]

  def index
    @partnerships = Partnership.search(params, partnerships_path, remote: true)
  end

  def new
    @partnership = Partnership.new
  end

  def create
    @partnership = Partnership.new(strong_params)
    if @partnership.save
      redirect_to @partnership
    else
      render "new"
    end
  end

  def update
    if @partnership.update(strong_params)
      redirect_to @partnership
    else
      render "edit"
    end
  end

  def destroy
    @partnership.destroy
    redirect_to partnerships_path
  end

  private

  def find_partnership
    @partnership = Partnership.find(params[:id])
  end

  def strong_params
    params.require(:partnership).permit(:divorce, :husband_id, :marriage, :wedding, :wife_id)
  end
end
