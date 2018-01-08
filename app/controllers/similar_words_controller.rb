class SimilarWordsController < ApplicationController
  authorize_resource
  before_action :find_similar_word, only: [:show, :edit, :update, :destroy]

  def index
    @similar_words = SimilarWord.search(params, similar_words_path)
  end

  def show
    @vocabs = Vocab.by_reading.where(reading: @similar_word.readings.split).to_a
  end

  def new
    @similar_word = SimilarWord.new
  end

  def create
    @similar_word = SimilarWord.new(strong_params)
    if @similar_word.save
      redirect_to @similar_word
    else
      render "new"
    end
  end

  def update
    if @similar_word.update(strong_params)
      redirect_to @similar_word
    else
      render "edit"
    end
  end

  def destroy
    @similar_word.destroy
    redirect_to similar_words_path
  end

  private

  def find_similar_word
    @similar_word = SimilarWord.find(params[:id])
  end

  def strong_params
    params.require(:similar_word).permit(:readings)
  end
end
