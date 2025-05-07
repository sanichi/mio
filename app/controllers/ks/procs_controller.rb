module Ks
  class ProcsController < ApplicationController
    authorize_resource

    def index
      @procs = Ks::Proc.search(params, ks_procs_path, per_page: 10)
    end
  end
end
