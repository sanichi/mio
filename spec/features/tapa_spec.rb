require 'rails_helper'

describe Tapa do
  let(:data)  { build(:tapa) }
  let!(:tapa) { create(:tapa) }

  before(:each) do
    login
    click_link t(:tapa_tapas)
  end

  context "create" do
    it "success" do
      click_link t(:tapa_new)
      fill_in t(:tapa_number), with: data.number
      fill_in t(:tapa_title), with: data.title
      fill_in t(:tapa_keywords), with: data.keywords
      fill_in t(:tapa_post__id), with: data.post_id
      check t(:tapa_star) if data.star
      fill_in t(:notes), with: data.notes
      click_button t(:save)

      expect(page).to have_title t(:tapa_tapas)

      expect(Tapa.count).to eq 2
      t = Tapa.last

      expect(t.number).to eq data.number
      expect(t.title).to eq data.title
      expect(t.keywords).to eq data.keywords
      expect(t.post_id).to eq data.post_id
      expect(t.star).to eq data.star
      expect(t.notes).to eq data.notes
    end

    it "failure" do
      click_link t(:tapa_new)
      fill_in t(:tapa_number), with: tapa.number
      fill_in t(:tapa_title), with: data.title
      fill_in t(:tapa_keywords), with: data.keywords
      fill_in t(:tapa_post__id), with: data.post_id
      check t(:tapa_star) if data.star
      fill_in t(:notes), with: data.notes
      click_button t(:save)

      expect(page).to have_title t(:tapa_new)
      expect(Tapa.count).to eq 1
      expect(page).to have_css(error, text: "taken")
    end
  end

  context "edit" do
    it "success" do
      click_link t(:edit)

      expect(page).to have_title t(:tapa_edit)
      fill_in t(:tapa_title), with: data.title
      click_button t(:save)

      expect(page).to have_title t(:tapa_tapas)

      expect(Tapa.count).to eq 1
      t = Tapa.last

      expect(t.title).to eq data.title
    end

    it "failure" do
      click_link t(:edit)

      fill_in t(:tapa_title), with: ""
      click_button t(:save)

      expect(page).to have_title t(:tapa_edit)
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "delete" do
    it "success" do
      expect(Tapa.count).to eq 1

      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:tapa_tapas)
      expect(Tapa.count).to eq 0
    end
  end
end
