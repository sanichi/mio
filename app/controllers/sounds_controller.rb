class SoundsController < ApplicationController
  load_and_authorize_resource only: [:index, :show, :edit, :update, :quick_level_update]

  def index
    @sounds = Sound.search(@sounds, params, sounds_path, per_page: 10)
  end

  def show
    @prev = Sound.find_by(ordinal: @sound.ordinal - 1)
    @next = Sound.find_by(ordinal: @sound.ordinal + 1)
  end

  def update
    if @sound.update(strong_params)
      redirect_to @sound
    else
      failure @sound
      render :edit
    end
  end

  def quick_level_update
    @sound.update_level!(params[:delta].to_i)
  end

  private

  def strong_params
    params.require(:sound).permit(:note)
  end
end
