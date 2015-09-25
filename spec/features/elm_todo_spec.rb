require 'rails_helper'

describe "Todo Elm" do
  include_context "test_data"

  before(:each) do
    @todo = [1, 2, 3].each_with_index.map do |p, i|
      create(:todo, description: "Todo #{5-i}", priority: p, done: false)
    end
    login
    click_link todo_todos
    click_link todo_elm
  end

  context "updates", js: true do
    def cell(row, i)
      tmpl = '//div[@id="elm"]/div/table/tbody/tr[%d][td[1]/span[@class="%s" and .="%s"] and td[2]/span[.="%s"]]'
      text = @todo[i].description
      done = @todo[i].done ? "inactive" : "active"
      prty = todo_priorities[@todo[i].priority]
      tmpl % [row, done, text, prty]
    end

    def button(i, text)
      '//tr[@id="todo_%d"]/td[3]/span[.="%s"]' % [@todo[i].id, text]
    end

    def expect_rows(page, i, j=nil, k=nil)
      expect(page).to have_xpath(cell(1, i))
      expect(page).to have_xpath(cell(2, j)) if j
      expect(page).to have_xpath(cell(3, k)) if k
    end

    def reload
      wait_a_while
      @todo.each { |t| t.reload }
    end

    it "priority" do
      expect(Todo.count).to eq 3
      expect(@todo[0].priority).to eq 1
      expect(@todo[1].priority).to eq 2
      expect(@todo[2].priority).to eq 3
      expect_rows(page, 0, 1, 2)

      find(:xpath, button(0, todo_elm_down)).click
      reload
      expect(@todo[0].priority).to eq 2
      expect_rows(page, 1, 0, 2)

      find(:xpath, button(2, todo_elm_up)).click
      reload
      expect(@todo[2].priority).to eq 2
      expect_rows(page, 2, 1, 0)

      4.times { find(:xpath, button(1, todo_elm_up)).click }
      reload
      expect(@todo[1].priority).to eq 0
      expect_rows(page, 1, 2, 0)

      6.times { find(:xpath, button(1, todo_elm_down)).click }
      reload
      expect(@todo[1].priority).to eq 4
      expect_rows(page, 2, 0, 1)
    end

    it "done" do
      expect(Todo.count).to eq 3
      expect(@todo[0].done).to eq false
      expect(@todo[1].done).to eq false
      expect(@todo[2].done).to eq false
      expect_rows(page, 0, 1, 2)

      find(:xpath, button(0, todo_elm_done)).click
      reload
      expect(@todo[0].done).to eq true
      expect_rows(page, 1, 2, 0)

      find(:xpath, button(1, todo_elm_done)).click
      reload
      expect(@todo[1].done).to eq true
      expect_rows(page, 2, 0, 1)

      find(:xpath, button(2, todo_elm_done)).click
      reload
      expect(@todo[2].done).to eq true
      expect_rows(page, 0, 1, 2)

      [0, 1, 2].each { |i| find(:xpath, button(i, todo_elm_done)).click }
      reload
      expect(@todo[0].done).to eq false
      expect(@todo[1].done).to eq false
      expect(@todo[2].done).to eq false
      expect_rows(page, 0, 1, 2)
    end

    it "delete" do
      expect(Todo.count).to eq 3
      expect_rows(page, 0, 1, 2)

      find(:xpath, button(0, todo_elm_delete)).click
      find(:xpath, button(0, todo_elm_cancel)).click
      wait_a_while
      expect(Todo.count).to eq 3
      expect_rows(page, 0, 1, 2)

      find(:xpath, button(1, todo_elm_delete)).click
      find(:xpath, button(1, todo_elm_confirm)).click
      wait_a_while
      expect(Todo.count).to eq 2
      expect_rows(page, 0, 2)

      find(:xpath, button(2, todo_elm_delete)).click
      find(:xpath, button(2, todo_elm_confirm)).click
      wait_a_while
      expect(Todo.count).to eq 1
      expect_rows(page, 0)

      find(:xpath, button(0, todo_elm_delete)).click
      find(:xpath, button(0, todo_elm_confirm)).click
      wait_a_while
      expect(Todo.count).to eq 0
    end
  end
end
