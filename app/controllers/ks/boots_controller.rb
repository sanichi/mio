module Ks
  class BootsController < ApplicationController
    authorize_resource

    def index
      @boots = Ks::Boot.search(params, ks_boots_path, per_page: 10)
    end
  end
end
