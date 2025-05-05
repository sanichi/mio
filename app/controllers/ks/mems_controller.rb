module Ks
  class MemsController < ApplicationController
    authorize_resource

    def index
      @mems = Ks::Mem.search(params, ks_mems_path, per_page: 10)
    end
  end
end
