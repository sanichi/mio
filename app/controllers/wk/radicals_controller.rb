module Wk
  class RadicalsController < ApplicationController
    authorize_resource

    def index
      @radicals = Wk::Radical.search(params, wk_radicals_path, per_page: 20)
      if @radicals.count == 1
        redirect_to @radicals.matches.first
      end
    end

    def show
      @radical = Wk::Radical.find(params[:id])
      @kanji = Wk::Kanji.find_by(character: @radical.character) if @radical.character
    end
  end
end
