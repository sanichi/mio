module Wk
  class VerbPairsController < ApplicationController
    authorize_resource

    def index
      @verb_pairs = VerbPair.search(params, wk_verb_pairs_path, per_page: 10)
    end
  end
end
