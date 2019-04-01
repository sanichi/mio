class ProblemsController < ApplicationController
  authorize_resource
  before_action :find_problem, only: [:show, :edit, :update, :destroy]

  def index
    @problems = Problem.search(params, problems_path, per_page: 15)
  end

  def new
    @problem = Problem.new
  end

  def create
    @problem = Problem.new(strong_params)
    if @problem.save
      redirect_to @problem
    else
      render "new"
    end
  end

  def show
    all = Problem.natural_order.to_a
    ind = all.find_index(@problem)
    @last = all[ind - 1] if ind && ind > 0
    @next = all[ind + 1] if ind && ind < all.size
    @question = Question.find_by(id: params[:question_id]&.to_i)
    @question = @problem.questions.first unless @question && @question.problem.id == @problem.id
  end

  def update
    if @problem.update(strong_params)
      redirect_to @problem
    else
      render action: "edit"
    end
  end

  def destroy
    @problem.destroy
    redirect_to problems_path
  end

  private

  def find_problem
    @problem = Problem.find(params[:id])
  end

  def strong_params
    params.require(:problem).permit(:audio, :category, :level, :note, :subcategory)
  end
end
