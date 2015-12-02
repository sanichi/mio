require 'rails_helper'

describe Person do
  include_context "test_data"

  let(:data) { build(:blog) }

  before(:each) do
    login
    click_link blogs
  end

  context "create" do
    it "success" do
      click_link new_blog
      fill_in blog_title, with: data.title
      if data.draft
        check blog_draft
      else
        uncheck blog_draft
      end
      fill_in blog_story, with: data.story
      click_button save

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
      click_link new_blog
      fill_in blog_story, with: data.story
      click_button save

      expect(page).to have_title new_blog
      expect(Blog.count).to eq 0
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "edit" do
    let(:blog) { create(:blog, draft: true) }

    it "change title and publish" do
      visit blog_path(blog)
      click_link edit

      expect(page).to have_title edit_blog
      fill_in blog_title, with: data.title
      uncheck blog_draft
      click_button save

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
      click_link edit
      click_link delete

      expect(page).to have_title blogs
      expect(Blog.count).to eq 0
    end
  end
end
