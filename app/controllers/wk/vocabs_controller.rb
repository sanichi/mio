module Wk
  class VocabsController < ApplicationController
    authorize_resource
    before_action :find_vocab, only: [:edit, :show, :update]

    def index
      remember_last_search(wk_vocabs_path)
      @vocabs = Wk::Vocab.search(params, wk_vocabs_path, per_page: 15, locale: :jp)
      @shortcut = @vocabs.count == 1 && [0,1].include?(params[:page].to_i)
    end

    def show
      @homos = Reading.where(characters: @vocab.readings.pluck(:characters)).map(&:vocab).uniq.reject{ |v| v == @vocab }
      @examples = @vocab.examples.by_updated_at.includes([:vocabs]).to_a
    end

    def update
      if @vocab.update(strong_params)
        @vocab.update_column(:last_noted, Time.now)
        redirect_to @vocab
      else
        failure @vocab
        render :edit
      end
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
