class VerbPairsController < ApplicationController
  authorize_resource

  def index
    @verb_pairs = VerbPair.search(params, verb_pairs_path, remote: true, per_page: 20)
  end

  def show
    @verb_pair = VerbPair.find(params[:id])
  end
end
