module PP
  class PricesController < ApplicationController
    def index
      @prices = PP::Price.search(params, pp_prices_path, per_page: 15)
    end
  end
end
