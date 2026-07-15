module Wk
  class KanjisController < ApplicationController
    authorize_resource

    def index
      remember_last_search(wk_kanjis_path)
      @kanjis = Wk::Kanji.search(params, wk_kanjis_path, per_page: 15, locale: :jp)
      @shortcut = @kanjis.count == 1 && [0,1].include?(params[:page].to_i)
    end

    def show
      @kanji = Wk::Kanji.find(params[:id])
      @vocabs = Wk::Vocab.by_reading.where("characters LIKE '%#{@kanji.character}%'")
      @daily = Note.find_by(title: @kanji.character, series: t("wk.daily.text"))
    end

    def favourites
      favourites = Wk::Kanji.where.not(favourite: nil)
      @favourites =
        case params[:order]
        when "newest" then favourites.order(favourite: :desc).to_a
        when "oldest" then favourites.order(favourite: :asc).to_a
        else               favourites.shuffle
        end
    end

    def candidates
      @candidates = Wk::Kanji.candidates
    end

    def similar
      @kanjis, @message = Wk::Kanji.similar(params, similar_wk_kanjis_path, per_page: 8)
    end

    def quick_favourite_toggle
      @kanji = Wk::Kanji.find(params[:id])
      @kanji.update_column(:favourite, @kanji.favourite ? nil : Time.current)
    end
  end
end
