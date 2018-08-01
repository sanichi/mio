class SimilarKanjisController < ApplicationController
  authorize_resource
  before_action :find_similar_kanji, only: [:show, :edit, :update, :destroy]

  def index
    @similar_kanjis = SimilarKanji.search(params, similar_kanjis_path, per_page: 20)
  end

  def show
    @kanjis = Kanji.by_symbol.where(symbol: @similar_kanji.kanjis.split('')).to_a
  end

  def new
    @similar_kanji = SimilarKanji.new
  end

  def create
    @similar_kanji = SimilarKanji.new(strong_params)
    if @similar_kanji.save
      redirect_to @similar_kanji
    else
      render "new"
    end
  end

  def update
    if @similar_kanji.update(strong_params)
      redirect_to @similar_kanji
    else
      render "edit"
    end
  end

  def destroy
    @similar_kanji.destroy
    redirect_to similar_kanjis_path
  end

  private

  def find_similar_kanji
    @similar_kanji = SimilarKanji.find(params[:id])
  end

  def strong_params
    params.require(:similar_kanji).permit(:kanjis, :category)
  end
end
