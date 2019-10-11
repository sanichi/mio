require 'rails_helper'

describe Wk::Example do
  let(:data)     { build(:wk_example) }
  let!(:example) { create(:wk_example) }

  before(:each) do
    login
    click_link t(:wk_example_examples)
  end

  context "create" do
    it "success" do
      click_link t(:wk_example_new)
      fill_in t(:wk_example_japanese), with: data.japanese
      fill_in t(:wk_example_english), with: data.english
      click_button t(:save)

      expect(page).to have_title t(:wk_example_examples)

      expect(Wk::Example.count).to eq 2
      e = Wk::Example.last

      expect(e.japanese).to eq data.japanese
      expect(e.english).to eq data.english
    end

    it "failure" do
      click_link t(:wk_example_new)
      fill_in t(:wk_example_japanese), with: data.japanese
      click_button t(:save)

      expect(page).to have_title t(:wk_example_new)
      expect(Wk::Example.count).to eq 1
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "edit" do
    it "success" do
      click_link t(:edit)

      expect(page).to have_title t(:wk_example_edit)
      fill_in t(:wk_example_english), with: data.english
      click_button t(:save)

      expect(page).to have_title t(:wk_example_examples)

      expect(Wk::Example.count).to eq 1
      e = Wk::Example.last

      expect(e.english).to eq data.english
    end
  end

  context "delete" do
    it "success" do
      expect(Wk::Example.count).to eq 1

      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:wk_example_examples)
      expect(Wk::Example.count).to eq 0
    end
  end
end
