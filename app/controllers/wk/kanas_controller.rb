module Wk
  class KanasController < ApplicationController
    authorize_resource
    before_action :find_vocab, only: [:edit, :show, :update]

    def index
      remember_last_search(wk_kanas_path)
      @kanas = Wk::Kana.search(params, wk_kanas_path, per_page: 10, locale: :jp)
      shortcut_search(@kanas)
    end

    def update
      if @kana.update(strong_params)
        redirect_to @kana
      else
        failure @kana
        render :edit
      end
    end

    def quick_accent_update
      @kana = Wk::Kana.find(params[:id])
      @kana.update_accent(params[:accent])
    end

    private

    def find_vocab
      if params[:id].to_i > 0
        @kana = Wk::Kana.find(params[:id])
      else
        @kana = Wk::Kana.find_by!(characters: params[:id])
      end
    end

    def strong_params
      params.require(:wk_kana).permit(:notes)
    end
  end
end
