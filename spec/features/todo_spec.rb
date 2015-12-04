require 'rails_helper'

describe Todo do
  let(:data) { build(:todo) }

  before(:each) do
    login
  end

  context "create" do
    before(:each) do
      click_link t(:todo_rails)
    end

    it "success" do
      click_link t(:todo_new)
      fill_in t(:description), with: data.description
      select t(:todo_priorities)[data.priority], from: t(:todo_priority)
      click_button t(:save)

      expect(page).to have_title t(:todo_todo)

      expect(Todo.count).to eq 1
      t = Todo.last

      expect(t.description).to eq data.description
      expect(t.priority).to eq data.priority
      expect(t.done).to be false
    end
  end

  context "failure" do
    before(:each) do
      click_link t(:todo_rails)
    end

    it "no description" do
      click_link t(:todo_new)
      select t(:todo_priorities)[data.priority], from: t(:todo_priority)
      click_button t(:save)

      expect(page).to have_title t(:todo_new)
      expect(Todo.count).to eq 0
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "edit" do
    let!(:todo) { create(:todo, done: false) }

    it "priority" do
      new_priority = (todo.priority + 1) % Todo::PRIORITIES.size

      click_link t(:todo_rails)
      click_link t(:edit)

      select t(:todo_priorities)[new_priority], from: t(:todo_priority)
      click_button t(:save)

      todo.reload
      expect(todo.priority).to eq new_priority
    end

    it "done", js: true do
      expect(todo.done).to be false

      click_link t(:todo_todos)
      click_link t(:todo_rails)
      click_link t(:todo_done)
      wait_a_while

      expect(page).to have_xpath("//tr[@id='todo_tr_#{todo.id}']/td/span[@class='inactive']")

      todo.reload
      expect(todo.done).to be true

      click_link t(:todo_done)
      wait_a_while

      expect(page).to have_xpath("//tr[@id='todo_tr_#{todo.id}']/td/span[@class='active']")

      todo.reload
      expect(todo.done).to be false
    end

    it "delete" do
      expect(Todo.count).to eq 1

      click_link t(:todo_rails)
      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:todo_todos)

      expect(Todo.count).to eq 0
    end
  end
end
