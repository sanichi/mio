module Ks
  class JournalsController < ApplicationController
    authorize_resource

    def index
      @journals = Ks::Journal.search(params, ks_journals_path, per_page: 10)
    end

    def show
      @journal = Ks::Journal.find(params[:id])
    end
  end
end
