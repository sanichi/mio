class MatchesController < ApplicationController
  authorize_resource

  def index
    @matches = Match.search(params, matches_path)
  end
end
