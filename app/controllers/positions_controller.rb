class PositionsController < ApplicationController
  authorize_resource
  before_action :find_position, only: [:edit, :update, :show, :destroy]

  def index
    @positions = Position.search(params, positions_path, per_page: 25)
  end

  def new
    @position = Position.new
  end

  def create
    @position = Position.new(strong_params)
    if @position.save
      redirect_to @position
    else
      render :new
    end
  end

  def update
    if @position.update(strong_params)
      redirect_to @position
    else
      render :edit
    end
  end

  def destroy
    @position.destroy
    redirect_to positions_path
  end

  private

  def find_position
    @position = Position.find(params[:id])
  end

  def strong_params
    params.require(:position).permit(:active, :castling, :en_passant, :half_move, :move, :name, :notes, :opening_id, :opening_365, :pieces, :reviewed_today)
  end
end
