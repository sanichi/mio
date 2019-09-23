class SimilarWordsController < ApplicationController
  authorize_resource

  def index
    @similar_words = SimilarWord.search(params, similar_words_path, per_page: 20)
  end

  def show
    @similar_word = SimilarWord.find(params[:id])
    @vocabs = Vocab.by_reading.where(reading: @similar_word.readings.split).to_a
  end
end
