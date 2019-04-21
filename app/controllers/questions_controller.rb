class QuestionsController < ApplicationController
  authorize_resource
  before_action :find_question, only: [:show, :edit, :update, :destroy]

  def new
    @question = Question.new(problem_id: params[:problem_id].to_i)
  end

  def create
    @question = Question.new(strong_params)
    if @question.save
      redirect_to url_for_problem(@question)
    else
      render "new"
    end
  end

  def update
    if @question.update(strong_params)
      redirect_to url_for_problem(@question)
    else
      render action: "edit"
    end
  end

  def destroy
    @question.destroy
    redirect_to @question.problem
  end

  def show
    @qids = JSON.parse(params[:qids]) if params[:qids]
  end

  private

  def find_question
    @question = Question.find(params[:id])
  end

  def strong_params
    params.require(:question).permit(:problem_id, :question, :answer1, :answer2, :answer3, :answer4, :solution, :note, :picture, :audio)
  end

  def url_for_problem(question)
    url_for(controller: "problems", action: "show", id: question.problem.id, question_id: question.id)
  end
end
