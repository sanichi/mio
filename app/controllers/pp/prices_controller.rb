module Pp
  class PricesController < ApplicationController
    def index
      @prices = Pp::Price.search(params, pp_prices_path, per_page: 15)
    end
  end
end
