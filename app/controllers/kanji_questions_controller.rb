class KanjiQuestionsController < ApplicationController
  authorize_resource

  def create
    @question = KanjiQuestion.new(strong_params)
    @question.save
    redirect_to @question.kanji_test
  end

  private

  def strong_params
    params.require(:kanji_question).permit(:kanji_id, :kanji_test_id, :answer)
  end
end
