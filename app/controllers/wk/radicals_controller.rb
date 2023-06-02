module Wk
  class RadicalsController < ApplicationController
    authorize_resource

    def index
      remember_last_search(wk_radicals_path)
      @radicals = Wk::Radical.search(params, wk_radicals_path, per_page: 15, locale: :jp)
      shortcut_search(@radicals)

    end

    def show
      @radical = Wk::Radical.find(params[:id])
      @kanji = Wk::Kanji.find_by(character: @radical.character) if @radical.character
    end
  end
end
