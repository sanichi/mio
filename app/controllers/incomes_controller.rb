class IncomesController < ApplicationController
  authorize_resource
  before_action :find_income, only: [:edit, :update, :destroy]

  def index
    @incomes, @category = Income.search(params)
  end

  def graph
    @igd = IncomeGraphData.new
  end

  def new
    @income = Income.new
  end

  def create
    @income = Income.new(strong_params)
    if @income.save
      redirect_to incomes_path
    else
      render "new"
    end
  end

  def update
    if @income.update(strong_params)
      redirect_to incomes_path
    else
      render "edit"
    end
  end

  def destroy
    @income.destroy
    redirect_to incomes_path
  end

  private

  def find_income
    @income = Income.find(params[:id])
  end

  def strong_params
    params.require(:income).permit(:amount, :category, :description, :period, :start, :finish)
  end
end
