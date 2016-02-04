class TapasController < ApplicationController
  authorize_resource
  before_action :find_tapa, only: [:edit, :update, :destroy]

  def index
    @tapas = Tapa.search(params, tapas_path, remote: true)
  end

  def new
    @tapa = Tapa.new
  end

  def create
    @tapa = Tapa.new(strong_params)
    if @tapa.save
      redirect_to tapas_path
    else
      render action: "new"
    end
  end

  def update
    if @tapa.update(strong_params)
      redirect_to tapas_path
    else
      render action: "edit"
    end
  end

  def destroy
    @tapa.destroy
    redirect_to tapas_path
  end

  private

  def find_tapa
    @tapa = Tapa.find(params[:id])
  end

  def strong_params
    params.require(:tapa).permit(:keywords, :number, :title)
  end
end
