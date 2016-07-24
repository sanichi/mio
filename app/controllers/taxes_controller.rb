class TaxesController < ApplicationController
  authorize_resource
  before_action :find_tax, only: [:destroy, :edit, :show, :update]
  before_action :get_year_number, only: [:index, :new]

  def index
    @taxes = Tax.search(@year_number)
  end

  def new
    @tax = Tax.new(year_number: @year_number)
  end

  def create
    @tax = Tax.new(strong_params)
    if @tax.save
      redirect_to @tax
    else
      render "new"
    end
  end

  def update
    if @tax.update(strong_params)
      redirect_to @tax
    else
      render "edit"
    end
  end

  def destroy
    @tax.destroy
    redirect_to taxes_path(year_number: @tax.year_number)
  end

  private

  def find_tax
    @tax = Tax.find(params[:id])
  end

  def get_year_number
    @year_number = params[:year_number].present?? params[:year_number].to_i : Tax.current_year_number
  end

  def strong_params
    params.require(:tax).permit(:description, :free, :income, :paid, :times, :year_number)
  end
end
