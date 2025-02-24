class MisasController < ApplicationController
  authorize_resource
  before_action :find_misa, only: [:show, :edit, :update, :destroy]

  def index
    remember_last_search(misas_path)
    @misas = Misa.search(params, misas_path, locale: :jp)
  end

  def new
    @misa = Misa.new
  end

  def create
    @misa = Misa.new(strong_params)
    if @misa.save
      redirect_to @misa
    else
      failure @misa
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @misa.update(strong_params)
      redirect_to @misa
    else
      failure @misa
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @misa.destroy
    redirect_to misas_path
  end

  private

  def find_misa
    @misa = Misa.find(params[:id])
  end

  def strong_params
    params.require(:misa).permit(:alt, :japanese, :minutes, :note, :number, :published, :series, :title, :url)
  end
end
