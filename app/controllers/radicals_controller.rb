class RadicalsController < ApplicationController
  authorize_resource

  def index
    @radicals = Radical.search(params, radicals_path, remote: true, per_page: 20)
  end
end
