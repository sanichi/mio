class FundsController < ApplicationController
  authorize_resource
  before_action :find_fund, only: [:edit, :update, :destroy]

  def index
    @funds = Fund.search(params, funds_path)
  end

  def show
    @fund = Fund.includes(:returns).includes(:comments).find(params[:id])
  end

  def new
    @fund = Fund.new
  end

  def create
    @fund = Fund.new(strong_params)
    if @fund.save
      redirect_to funds_path
    else
      render "new"
    end
  end

  def update
    if @fund.update(strong_params)
      redirect_to @fund
    else
      render "edit"
    end
  end

  def destroy
    @fund.destroy
    redirect_to funds_path
  end

  private

  def find_fund
    @fund = Fund.find(params[:id])
  end

  def strong_params
    params.require(:fund).permit(:annual_fee, :category, :company, :name, :risk_reward_profile, :performance_fee, :sector)
  end
end
