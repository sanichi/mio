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
    @pq = ProblemQuestion.new(params[:pqids])
    pids = @pq.available? ? @pq.pids : Problem.natural_order.pluck(:id)
    indx = pids.find_index(@problem.id)
    @last = pids[indx - 1] if indx && indx > 0
    @next = pids[indx + 1] if indx && indx < pids.size - 1
    @count = pids.size
    @number = indx.to_i + 1
    @qids = @pq.qids(@problem.id) || Question.where(problem_id: @problem.id).pluck(:id)
    question_id = params[:question].to_i
    question_id = @qids.first unless question_id > 0
    @question = Question.find_by(id: question_id)
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
