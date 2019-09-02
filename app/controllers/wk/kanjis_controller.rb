module Wk
  class KanjisController < ApplicationController
    authorize_resource

    def index
      @kanjis = Wk::Kanji.search(params, wk_kanjis_path, remote: true, per_page: 20)
    end

    def show
      @kanji = Wk::Kanji.find(params[:id])
    end
  end
end
