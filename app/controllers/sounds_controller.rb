class SoundsController < ApplicationController
  load_and_authorize_resource only: [:index, :show, :quick_level_update]

  def index
    @sounds = Sound.search(@sounds, params, sounds_path, per_page: 10)
  end

  def quick_level_update
    @sound.update_level!(params[:delta].to_i)
  end

  private

  def strong_params
    params.require(:sound).permit(:note)
  end
end
