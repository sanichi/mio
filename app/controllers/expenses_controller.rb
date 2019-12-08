class ExpensesController < ApplicationController
  authorize_resource
  before_action :find_expense, only: [:edit, :update, :destroy]

  def index
    @expenses, @category = Expense.search(params)
  end

  def new
    @expense = Expense.new
  end

  def create
    @expense = Expense.new(strong_params)
    if @expense.save
      redirect_to expenses_path
    else
      render :new
    end
  end

  def update
    if @expense.update(strong_params)
      redirect_to expenses_path
    else
      render :edit
    end
  end

  def destroy
    @expense.destroy
    redirect_to expenses_path
  end

  private

  def find_expense
    @expense = Expense.find(params[:id])
  end

  def strong_params
    params.require(:expense).permit(:amount, :category, :description, :period)
  end
end
