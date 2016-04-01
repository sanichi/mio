class PagesController < ApplicationController
  authorize_resource

  def risle
    @flats = Flat.all
  end
end
