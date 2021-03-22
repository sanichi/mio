class TestsController < ApplicationController
  authorize_resource

  def index
    per_page = params[:number].to_i
    per_page = TestHelper::NUMBER.first unless TestHelper::NUMBER.include?(per_page)
    @tests = Test.search(params, tests_path, per_page: per_page)
    helpers.test_new_save(@tests.matches.pluck(:id))
    remember_last_search(tests_path)
  end

  def update
    @test = Test.find(params[:id])
    if @test.update(strong_params)
      helpers.test_add_answer(@test.last)
    end
    redirect_to resume_tests_path
  end

  def review
    if helpers.test_new_review?
      helpers.test_new_use
      redirect_to resume_tests_path
    else
      redirect_to tests_path
    end
  end

  def resume
    if helpers.test_review?
      ids = helpers.test_review_ids
      ind = helpers.test_index
      @number = ind + 1
      @total = ids.length
      @answers = helpers.test_answers
      @test = Test.find(ids[ind]) if @number <= @total
    else
      redirect_to tests_path
    end
  end

  private

  def strong_params
    params.require(:test).permit(:last)
  end
end
