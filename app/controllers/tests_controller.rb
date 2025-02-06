class TestsController < ApplicationController
  authorize_resource

  def index
    params[:number] = TestHelper::DEFAULT unless TestHelper::NUMBERS.include?(params[:number].to_i)
    @tests = Test.search(params, tests_path, per_page: params[:number], locale: :jp)
    remember_last_search(tests_path)
  end

  def review
    tests = Test.includes(:testable).where(id: params[:ids])
    @tests = same_order(tests, params[:ids])
  end

  def update
    @test = Test.find(params[:id])
    if params[:test][:last] == "skip"
      @test.update_column(:last, "skip") # doesn't change updated_at
    else
      unless @test.update(strong_params)
        @error = @test.errors.full_messages.join(", ")
      end
    end
  end

  private

  def strong_params
    params.require(:test).permit(:last)
  end

  def same_order(tests, ids)
    lookup = ids.each_with_index.each_with_object({}) { |(id, i), h| h[id.to_i] = i }
    tests.sort_by { |t| lookup[t.id] }
  end
end
