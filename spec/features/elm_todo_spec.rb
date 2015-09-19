require 'rails_helper'

describe "Todo Elm" do
  include_context "test_data"

  before(:each) do
    login
    click_link todo_todos
    click_link todo_elm
  end

  context "updates", js: true do
    let!(:todo1) { create(:todo, priority: 1, done: false) }
    let!(:todo2) { create(:todo, priority: 2, done: false) }
    let!(:todo3) { create(:todo, priority: 3, done: false) }

    xit "priority and done" do
      expect(Todo.count).to eq 3

      expect(page).to have_xpath("//div[@id='elm']/div/table")
    end
  end
end
