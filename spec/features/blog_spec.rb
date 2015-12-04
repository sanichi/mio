require 'rails_helper'

describe Person do
  include_context "test_data"

  let(:data) { build(:blog) }

  before(:each) do
    login
    click_link t(:blog_blog)
  end

  context "create" do
    it "success" do
      click_link t(:blog_new)
      fill_in t(:blog_title), with: data.title
      if data.draft
        check t(:blog_draft)
      else
        uncheck t(:blog_draft)
      end
      fill_in t(:blog_story), with: data.story
      click_button t(:save)

      expect(page).to have_title data.title

      expect(Blog.count).to eq 1
      b = Blog.last

      expect(b.title).to eq data.title
      expect(b.draft).to eq data.draft
      expect(b.story).to eq data.story
      expect(b.user_id).to be > 0
    end
  end

  context "failure" do
    it "no title" do
      click_link t(:blog_new)
      fill_in t(:blog_story), with: data.story
      click_button t(:save)

      expect(page).to have_title t(:blog_new)
      expect(Blog.count).to eq 0
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "edit" do
    let(:blog) { create(:blog, draft: true) }

    it "change title and publish" do
      visit blog_path(blog)
      click_link t(:edit)

      expect(page).to have_title t(:blog_edit)
      fill_in t(:blog_title), with: data.title
      uncheck t(:blog_draft)
      click_button t(:save)

      expect(page).to have_title data.title

      expect(Blog.count).to eq 1
      b = Blog.last

      expect(b.title).to eq data.title
      expect(b.draft).to eq false
    end
  end

  context "delete" do
    let!(:blog) { create(:blog) }

    it "success" do
      expect(Blog.count).to eq 1

      visit blog_path(blog)
      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:blog_blog)
      expect(Blog.count).to eq 0
    end
  end
end
