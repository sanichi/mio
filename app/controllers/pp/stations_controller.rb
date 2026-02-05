module Pp
  class StationsController < ApplicationController
    before_action :find_station, only: [:edit, :show, :update]

    def index
      @stations = Pp::Station.search(params, pp_stations_path, per_page: 15)
    end

    def show
    end

    def edit
    end

    def update
      if @station.update(strong_params)
        redirect_to @station
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def find_station
      @station = Pp::Station.find(params[:id])
    end

    def strong_params
      params.require(:pp_station).permit(:preferred_name)
    end
  end
end
