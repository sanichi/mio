class TestsController < ApplicationController
  authorize_resource

  def index
    params[:number] = TestHelper::DEFAULT unless TestHelper::NUMBERS.include?(params[:number].to_i)
    @tests = Test.search(params, tests_path, per_page: params[:number])
    remember_last_search(tests_path)
  end

  def review
    @tests = Test.includes(:testable).where(id: params[:ids])
  end

  def update
    @test = Test.find(params[:id])
    unless @test.update(strong_params)
      @error = @test.errors.full_messages.join(", ")
    end
  end

  private

  def strong_params
    params.require(:test).permit(:last)
  end
end
