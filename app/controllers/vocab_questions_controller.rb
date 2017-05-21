class VocabQuestionsController < ApplicationController
  authorize_resource
  before_action :find_test, only: [:destroy, :show]

  def create
    @question = VocabQuestion.new(strong_params)
    @question.save
    redirect_to @question.vocab_test
  end

  private

  def strong_params
    params.require(:vocab_question).permit(:kanji, :meaning, :reading, :vocab_id, :vocab_test_id)
  end
end
