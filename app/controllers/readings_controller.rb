class ReadingsController < ApplicationController
  authorize_resource

  def index
    @readings = Reading.search(params, readings_path, remote: true, per_page: 20)
  end

  def show
    @reading = Reading.includes(yomis: { kanji: { yomis: :reading } }).find(params[:id])
  end
end
