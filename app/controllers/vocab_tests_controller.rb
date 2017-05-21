class VocabTestsController < ApplicationController
  authorize_resource
  before_action :find_test, only: [:destroy, :show]

  def index
    @tests = VocabTest.search(params, vocab_tests_path, remote: true)
  end

  def show
    @next_question = @test.next_question
  end

  def new
    @test = VocabTest.new
  end

  def create
    @test = VocabTest.new(strong_params)
    if @test.save
      redirect_to @test
    else
      render action: "new"
    end
  end

  def destroy
    @test.destroy
    redirect_to vocab_tests_path
  end

  private

  def find_test
    @test = VocabTest.includes(:vocab_questions).find(params[:id])
  end

  def strong_params
    params.require(:vocab_test).permit(:category, :complete, :level)
  end
end
