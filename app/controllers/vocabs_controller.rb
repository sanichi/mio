class VocabsController < ApplicationController
  authorize_resource
  before_action :find_vocab, only: [:destroy, :edit, :show, :update, :quick_accent_update]
  before_action :lazy_accent, only: [:update]
  JDIGITS = "０１２３４５６７８９"
  EDIGITS = "0123456789"

  def index
    @vocabs = Vocab.search(params, vocabs_path, remote: true, per_page: 20)
  end

  def show
    @kanji = Kanji.find_by(symbol: @vocab.kanji) if @vocab.kanji.length == 1
  end

  def verbs
    @verbs = Vocab.verb_search(params, verbs_vocabs_path, remote: true, per_page: 20)
  end

  def homonyms
    @homonyms = Vocab.homonym_search(params, homonyms_vocabs_path, remote: true, per_page: 20)
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

  def quick_accent_update
    @vocab.update_accent(params[:accent])
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
    params.require(:vocab).permit(:accent, :audio, :burned, :category, :kanji, :level, :meaning, :reading)
  end

  # Don't force the user to switch input language just to input a single digit.
  def lazy_accent
    a = params[:vocab][:accent]
    i = JDIGITS.index(a) if a&.length == 1
    params[:vocab][:accent] = EDIGITS[i] unless i.nil?
  end
end
