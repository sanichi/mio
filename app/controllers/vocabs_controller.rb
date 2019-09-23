class VocabsController < ApplicationController
  authorize_resource

  def index
    @vocabs = Vocab.search(params, vocabs_path, remote: true, per_page: 20)
  end

  def show
    @vocab = Vocab.find(params[:id])
    @kanji = Kanji.find_by(symbol: @vocab.kanji) if @vocab.kanji.length == 1
  end
end
