class TapasController < ApplicationController
  authorize_resource
  before_action :find_tapa, only: [:edit, :update, :destroy, :notes]

  def index
    @tapas = Tapa.search(params, tapas_path, remote: true)
  end

  def new
    @tapa = Tapa.new
  end

  def create
    @tapa = Tapa.new(strong_params)
    if @tapa.save
      redirect_to top_of_index
    else
      render action: "new"
    end
  end

  def update
    if @tapa.update(strong_params)
      redirect_to top_of_index
    else
      render action: "edit"
    end
  end

  def destroy
    @tapa.destroy
    redirect_to tapas_path
  end

  def notes
    render html: @tapa.notes_html
  end

  private

  def find_tapa
    @tapa = Tapa.find(params[:id])
  end

  def strong_params
    params.require(:tapa).permit(:keywords, :notes, :number, :post_id, :star, :title)
  end

  def top_of_index
    url_for controller: "tapas", action: "index", number: "<=#{@tapa.number}", only_path: true
  end
end
