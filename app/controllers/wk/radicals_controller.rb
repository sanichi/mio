module Wk
  class RadicalsController < ApplicationController
    authorize_resource

    def index
      @radicals = Wk::Radical.search(params, wk_radicals_path, remote: true, per_page: 20)
    end

    def show
      @radical = Wk::Radical.find(params[:id])
    end
  end
end
