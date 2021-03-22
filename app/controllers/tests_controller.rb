class TestsController < ApplicationController
  authorize_resource

  def index
    per_page = params[:number].to_i
    per_page = TestHelper::NUMBER.first unless TestHelper::NUMBER.include?(per_page)
    @tests = Test.search(params, tests_path, per_page: per_page)
  end
end
