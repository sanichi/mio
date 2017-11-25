require 'rails_helper'

describe Conversation do
  let(:data) { build(:conversation) }

  before(:each) do
    login
    click_link t(:conversation_conversations)
  end

  context "create" do
    it "success" do
      click_link t(:conversation_new)
      fill_in t(:conversation_audio), with: data.audio
      fill_in t(:conversation_story), with: data.story
      fill_in t(:conversation_title), with: data.title
      click_button t(:save)

      expect(page).to have_title data.title

      expect(Conversation.count).to eq 1
      c = Conversation.last

      expect(c.audio).to eq data.audio
      expect(c.story).to eq data.story
      expect(c.title).to eq data.title
    end
  end

  context "failure" do
    it "no audio" do
      click_link t(:conversation_new)
      fill_in t(:conversation_story), with: data.story
      fill_in t(:conversation_title), with: data.title
      click_button t(:save)

      expect(page).to have_title t(:conversation_new)
      expect(Conversation.count).to eq 0
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "edit" do
    let(:conversation) { create(:conversation) }

    it "change title" do
      visit conversation_path(conversation)
      click_link t(:edit)

      expect(page).to have_title t(:conversation_edit)
      fill_in t(:conversation_title), with: data.title
      click_button t(:save)

      expect(page).to have_title data.title

      expect(Conversation.count).to eq 1
      c = Conversation.last

      expect(c.title).to eq data.title
    end
  end

  context "delete" do
    let!(:conversation) { create(:conversation) }

    it "success" do
      expect(Conversation.count).to eq 1

      visit conversation_path(conversation)
      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:conversation_conversations)
      expect(Conversation.count).to eq 0
    end
  end
end
