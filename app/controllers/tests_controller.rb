class TestsController < ApplicationController
  authorize_resource

  def index
    @tests = Test.search(params, tests_path)
  end
end
