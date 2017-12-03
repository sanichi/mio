class KanjiTestsController < ApplicationController
  authorize_resource
  before_action :find_test, only: [:destroy, :show]

  def index
    @tests = KanjiTest.search(params, kanji_tests_path, remote: true)
  end

  def show
    if params[:redo_last].present?
      @next_question = @test.next_question(@test.drop_last_question)
    else
      @next_question = @test.next_question(params[:ask_again])
    end
    @vocabs = Vocab.kanji_vocabs(@next_question.kanji) if @next_question
  end

  def new
    @test = KanjiTest.new
  end

  def create
    @test = KanjiTest.new(strong_params)
    if @test.save
      redirect_to @test
    else
      render action: "new"
    end
  end

  def destroy
    @test.destroy
    redirect_to kanji_tests_path
  end

  private

  def find_test
    @test = KanjiTest.includes(kanji_questions: { kanji: { yomis: :reading } }).find(params[:id])
  end

  def strong_params
    params.require(:kanji_test).permit(:complete, :level)
  end
end
