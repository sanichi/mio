module Wk
  class VocabsController < ApplicationController
    authorize_resource

    def index
      @vocabs = Wk::Vocab.search(params, wk_vocabs_path, per_page: 20)
      if @vocabs.count == 1
        redirect_to @vocabs.matches.first
      end
    end

    def show
      @vocab = Wk::Vocab.find(params[:id])
    end

    def quick_accent_update
      @vocab = Wk::Vocab.find(params[:id])
      @vocab.update_accent(params[:accent])
    end
  end
end
