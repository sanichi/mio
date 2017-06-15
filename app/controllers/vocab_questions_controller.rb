class VocabQuestionsController < ApplicationController
  authorize_resource
  before_action :find_test, only: [:destroy, :show]

  def create
    @question = VocabQuestion.new(strong_params)
    if @question.blanks?
      redirect_to vocab_test_path(@question.vocab_test, ask_again: @question.vocab_id)
    else
      @question.save
      redirect_to @question.vocab_test
    end
  end

  private

  def strong_params
    params.require(:vocab_question).permit(:kanji, :meaning, :reading, :vocab_id, :vocab_test_id)
  end
end
