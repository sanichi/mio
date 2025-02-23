module Wk
  class KanjisController < ApplicationController
    authorize_resource

    def index
      remember_last_search(wk_kanjis_path)
      @kanjis = Wk::Kanji.search(params, wk_kanjis_path, per_page: 15, locale: :jp)
    end

    def show
      @kanji = Wk::Kanji.find(params[:id])
      @vocabs = Wk::Vocab.by_reading.where("characters LIKE '%#{@kanji.character}%'")
      @daily = Note.find_by(title: @kanji.character, series: t("wk.daily.text"))
    end

    def similar
      @kanjis, @message = Wk::Kanji.similar(params, similar_wk_kanjis_path, per_page: 8)
    end
  end
end
