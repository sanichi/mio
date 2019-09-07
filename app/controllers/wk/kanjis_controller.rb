module Wk
  class KanjisController < ApplicationController
    authorize_resource

    def index
      @kanjis = Wk::Kanji.search(params, wk_kanjis_path, per_page: 20)
      if @kanjis.count == 1
        redirect_to @kanjis.matches.first
      end
    end

    def show
      @kanji = Wk::Kanji.find(params[:id])
    end
  end
end
