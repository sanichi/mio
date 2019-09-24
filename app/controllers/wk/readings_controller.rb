module Wk
  class ReadingsController < ApplicationController
    authorize_resource

    def quick_accent_update
      @reading = Wk::Reading.find(params[:id])
      @reading.update_accent(params[:accent])
    end
  end
end
