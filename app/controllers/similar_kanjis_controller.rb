class SimilarKanjisController < ApplicationController
  authorize_resource

  def index
    @similar_kanjis = SimilarKanji.search(params, similar_kanjis_path, per_page: 20)
  end

  def show
    @similar_kanji = SimilarKanji.find(params[:id])
    @kanjis = Kanji.by_symbol.where(symbol: @similar_kanji.kanjis.split('')).to_a
  end
end
