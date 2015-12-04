require 'rails_helper'

describe "Todo Elm" do
  include_context "test_data"

  before(:each) do
    @todo = [1, 2, 3].each_with_index.map do |p, i|
      create(:todo, description: "Todo #{5-i}", priority: p, done: false)
    end
    login
    click_link t(:todo_todos)
    click_link t(:todo_elm_app)
  end

  context "updates", js: true do
    let(:data) { build(:todo) }

    def cell(row, i)
      tmpl = '//div[@id="elm"]/div/table/tbody/tr[%d][td[1]/span[@class="%s" and .="%s"] and td[2]/span[.="%s"]]'
      text = @todo[i].description
      done = @todo[i].done ? "inactive" : "active"
      prty = t(:todo_priorities)[@todo[i].priority]
      tmpl % [row, done, text, prty]
    end

    def button(i, text)
      '//tr[@id="todo_%d"]/td[3]/span[.="%s"]' % [@todo[i].id, text]
    end

    def description(i)
      '//tr[@id="todo_%d"]/td[1]/span' % @todo[i].id
    end

    def input(i=nil)
      '//input[@id="description_%d"]' % (i ? @todo[i].id : 0)
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

      find(:xpath, button(0, t(:todo_elm_down))).click
      reload
      expect(@todo[0].priority).to eq 2
      expect_rows(page, 1, 0, 2)

      find(:xpath, button(2, t(:todo_elm_up))).click
      reload
      expect(@todo[2].priority).to eq 2
      expect_rows(page, 2, 1, 0)

      find(:xpath, button(1, t(:todo_elm_up))).click
      reload
      expect(@todo[1].priority).to eq 1
      expect_rows(page, 1, 2, 0)
    end

    it "done" do
      expect(Todo.count).to eq 3
      expect(@todo[0].done).to eq false
      expect(@todo[1].done).to eq false
      expect(@todo[2].done).to eq false
      expect_rows(page, 0, 1, 2)

      find(:xpath, button(0, t(:todo_elm_done))).click
      reload
      expect(@todo[0].done).to eq true
      expect_rows(page, 1, 2, 0)

      find(:xpath, button(1, t(:todo_elm_done))).click
      reload
      expect(@todo[1].done).to eq true
      expect_rows(page, 2, 0, 1)

      find(:xpath, button(2, t(:todo_elm_done))).click
      reload
      expect(@todo[2].done).to eq true
      expect_rows(page, 0, 1, 2)

      [0, 1, 2].each { |i| find(:xpath, button(i, t(:todo_elm_done))).click }
      reload
      expect(@todo[0].done).to eq false
      expect(@todo[1].done).to eq false
      expect(@todo[2].done).to eq false
      expect_rows(page, 0, 1, 2)
    end

    it "delete" do
      expect(Todo.count).to eq 3
      expect_rows(page, 0, 1, 2)

      find(:xpath, button(0, t(:todo_elm_delete))).click
      find(:xpath, button(0, t(:todo_elm_cancel))).click
      wait_a_while
      expect(Todo.count).to eq 3
      expect_rows(page, 0, 1, 2)

      find(:xpath, button(1, t(:todo_elm_delete))).click
      find(:xpath, button(1, t(:todo_elm_confirm))).click
      wait_a_while
      expect(Todo.count).to eq 2
      expect_rows(page, 0, 2)

      find(:xpath, button(2, t(:todo_elm_delete))).click
      find(:xpath, button(2, t(:todo_elm_confirm))).click
      wait_a_while
      expect(Todo.count).to eq 1
      expect_rows(page, 0)

      find(:xpath, button(0, t(:todo_elm_delete))).click
      find(:xpath, button(0, t(:todo_elm_confirm))).click
      wait_a_while
      expect(Todo.count).to eq 0
    end

    it "edit" do
      find(:xpath, description(0)).click
      find(:xpath, input(0)).send_keys("x")
      find(:xpath, input(0)).send_keys(:return)
      reload

      expect(@todo[0].description).to eq "Todo 5x"
      expect_rows(page, 0, 1, 2)
    end

    it "create" do
      find(:xpath, input).send_keys(data.description)
      find(:xpath, input).send_keys(:return)

      wait_a_while
      expect(Todo.count).to eq 4

      todo = Todo.last
      expect(todo.description).to eq data.description
      expect(todo.priority).to eq Todo::PRIORITIES[0]
      expect(todo.done).to eq false
    end
  end
end
