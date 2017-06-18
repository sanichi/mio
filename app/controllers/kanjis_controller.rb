class KanjisController < ApplicationController
  authorize_resource

  def index
    @kanjis = Kanji.search(params, kanjis_path, remote: true, per_page: 20)
  end

  def show
    @kanji = Kanji.find(params[:id])
  end
end
