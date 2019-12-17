class MisasController < ApplicationController
  authorize_resource
  before_action :find_misa, only: [:show, :edit, :update, :destroy]

  def index
    @misas = Misa.search(params, misas_path, per_page: 20)
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
      render :new
    end
  end

  def update
    if @misa.update(strong_params)
      redirect_to @misa
    else
      failure @misa
      render :edit
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
    params.require(:misa).permit(:alt, :category, :japanese, :minutes, :note, :published, :title, :url)
  end
end
