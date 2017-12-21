class KanjisController < ApplicationController
  authorize_resource

  def index
    @kanjis = Kanji.search(params, kanjis_path, per_page: 20)
    if @kanjis.count == 1
      redirect_to @kanjis.matches.first
    end
  end

  def show
    @kanji = Kanji.find(params[:id])
    @vocabs = Vocab.kanji_vocabs(@kanji)
  end
end
