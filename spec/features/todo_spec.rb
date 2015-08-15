require 'rails_helper'

describe Todo do
  include_context "test_data"

  let(:data) { build(:todo) }

  before(:each) do
    login
  end

  context "create" do
    before(:each) do
      click_link todo_rails
    end

    it "success" do
      click_link new_todo
      fill_in description, with: data.description
      select todo_priorities[data.priority], from: todo_priority
      click_button save

      expect(page).to have_title todo_todo

      expect(Todo.count).to eq 1
      t = Todo.last

      expect(t.description).to eq data.description
      expect(t.priority).to eq data.priority
      expect(t.done).to be false
    end
  end

  context "failure" do
    before(:each) do
      click_link todo_rails
    end

    it "no description" do
      click_link new_todo
      select todo_priorities[data.priority], from: todo_priority
      click_button save

      expect(page).to have_title new_todo
      expect(Todo.count).to eq 0
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "edit" do
    let!(:todo) { create(:todo, done: false) }

    it "priority" do
      new_priority = (todo.priority + 1) % Todo::PRIORITIES.size

      click_link todo_rails
      click_link edit

      select todo_priorities[new_priority], from: todo_priority
      click_button save

      todo.reload
      expect(todo.priority).to eq new_priority
    end

    it "done", js: true do
      expect(todo.done).to be false

      click_link todo_todos
      click_link todo_rails
      click_link todo_done
      wait_a_while

      expect(page).to have_xpath("//td/span[@id='todo_#{todo.id}' and @class='inactive']")

      todo.reload
      expect(todo.done).to be true

      click_link todo_done
      wait_a_while

      expect(page).to have_xpath("//td/span[@id='todo_#{todo.id}' and @class='active']")

      todo.reload
      expect(todo.done).to be false
    end

    it "delete" do
      expect(Todo.count).to eq 1

      click_link todo_rails
      click_link edit
      click_link delete

      expect(page).to have_title todo_todos

      expect(Todo.count).to eq 0
    end
  end
end
