class TradesController < ApplicationController
  authorize_resource
  before_action :find_trade, only: [:show, :edit, :update, :destroy]

  def index
    @trades = Trade.search(params, trades_path, per_page: 20)
  end

  def new
    @trade = Trade.new
  end

  def create
    @trade = Trade.new(strong_params)
    if @trade.save
      redirect_to @trade
    else
      render "new"
    end
  end

  def update
    if @trade.update(strong_params)
      redirect_to @trade
    else
      render action: "edit"
    end
  end

  def destroy
    @trade.destroy
    redirect_to trades_path
  end

  private

  def find_trade
    @trade = Trade.find(params[:id])
  end

  def strong_params
    params.require(:trade).permit(:buy_date, :buy_factor, :buy_price, :stock, :sell_date, :sell_factor, :sell_price, :units)
  end
end
