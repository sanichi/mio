module Ks
  class PcpusController < ApplicationController
    authorize_resource

    def index
      @pcpus = Ks::Pcpu.search(params, ks_pcpus_path, per_page: 10)
    end
  end
end
