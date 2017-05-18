class VocabsController < ApplicationController
  authorize_resource
  before_action :find_vocab, only: [:destroy, :edit, :show, :update]

  def index
    @vocabs = Vocab.search(params, vocabs_path, remote: true, per_page: 20)
  end

  def new
    @vocab = Vocab.new
  end

  def create
    @vocab = Vocab.new(strong_params)
    if @vocab.save
      redirect_to @vocab
    else
      render action: "new"
    end
  end

  def update
    if @vocab.update(strong_params)
      redirect_to @vocab
    else
      render action: "edit"
    end
  end

  def destroy
    @vocab.destroy
    redirect_to vocabs_path
  end

  private

  def find_vocab
    @vocab = Vocab.find(params[:id])
  end

  def strong_params
    params.require(:vocab).permit(:audio, :category, :kanji, :level, :meaning, :reading)
  end
end
