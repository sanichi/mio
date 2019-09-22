module Wk
  class VocabsController < ApplicationController
    authorize_resource
    before_action :find_vocab, only: [:edit, :show, :update, :quick_accent_update]

    def index
      @vocabs = Wk::Vocab.search(params, wk_vocabs_path, per_page: 20)
      if @vocabs.count == 1
        redirect_to @vocabs.matches.first
      end
    end

    def update
      if @vocab.update(strong_params)
        @vocab.update_column(:last_noted, Time.now)
        redirect_to @vocab
      else
        render action: "edit"
      end
    end

    def quick_accent_update
      @vocab.update_accent(params[:accent])
    end

    private

    def find_vocab
      if params[:id].to_i > 0
        @vocab = Wk::Vocab.find(params[:id])
      else
        @vocab = Wk::Vocab.find_by!(characters: params[:id])
      end
    end

    def strong_params
      params.require(:wk_vocab).permit(:notes)
    end
  end
end
