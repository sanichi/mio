class SoundsController < ApplicationController
  load_and_authorize_resource only: [:index, :show]

  def index
    @sounds = Sound.search(@sounds, params, sounds_path, per_page: 10)
  end

  private

  def strong_params
    params.require(:sound).permit(:note)
  end
end
