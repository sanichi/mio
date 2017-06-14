class VerbPairsController < ApplicationController
  authorize_resource
  before_action :find_verb_pair, only: [:destroy, :edit, :show, :update]

  def index
    @verb_pairs = VerbPair.search(params, verb_pairs_path, remote: true, per_page: 20)
  end

  def new
    @verb_pair = VerbPair.new
  end

  def create
    @verb_pair = VerbPair.new(strong_params)
    if @verb_pair.save
      redirect_to @verb_pair
    else
      render action: "new"
    end
  end

  def update
    if @verb_pair.update(strong_params)
      redirect_to @verb_pair
    else
      render action: "edit"
    end
  end

  def destroy
    @verb_pair.destroy
    redirect_to verb_pairs_path
  end

  private

  def find_verb_pair
    @verb_pair = VerbPair.find(params[:id])
  end

  def strong_params
    params.require(:verb_pair).permit(:category, :transitive_id, :intransitive_id)
  end
end
