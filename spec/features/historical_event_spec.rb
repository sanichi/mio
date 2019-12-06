require 'rails_helper'

describe HistoricalEvent do
  let(:data) { build(:historical_event) }

  before(:each) do
    login
    visit historical_events_path
  end

  context "create" do
    it "success" do
      click_link t("historical_event.new")
      fill_in t("description"), with: data.description
      fill_in t("historical_event.start"), with: data.start
      fill_in t("historical_event.finish"), with: data.finish
      click_button t("save")

      expect(page).to have_title t("historical_event.events")

      expect(HistoricalEvent.count).to eq 1
      e = HistoricalEvent.first

      expect(e.description).to eq data.description
      expect(e.start).to eq data.start
      expect(e.finish).to eq data.finish
    end
  end

  context "failure" do
    it "no decription" do
      click_link t("historical_event.new")
      fill_in t("historical_event.start"), with: data.start
      fill_in t("historical_event.finish"), with: data.finish
      click_button t("save")

      expect(page).to have_title t("historical_event.new")
      expect(HistoricalEvent.count).to eq 0
      expect(page).to have_css(error, text: "blank")
    end

    it "invalid years" do
      click_link t("historical_event.new")
      fill_in t("description"), with: data.description
      fill_in t("historical_event.start"), with: data.finish
      fill_in t("historical_event.finish"), with: data.start
      click_button t("save")

      expect(page).to have_title t("historical_event.new")
      expect(HistoricalEvent.count).to eq 0
      expect(page).to have_css(error, text: "finish before start")
    end
  end

  context "edit" do
    let!(:historical_event) { create(:historical_event) }

    it "success" do
      visit historical_events_path
      click_link t("edit")

      expect(HistoricalEvent.count).to eq 1
      e = HistoricalEvent.first
      finish = e.finish

      expect(page).to have_title t("historical_event.edit")
      fill_in t("historical_event.finish"), with: finish + 1
      click_button t("save")

      expect(page).to have_title t("historical_event.events")

      e.reload
      expect(e.finish).to eq finish + 1
    end
  end

  context "delete" do
    let!(:historical_event) { create(:historical_event) }

    it "success" do
      visit historical_events_path
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("historical_event.events")
      expect(HistoricalEvent.count).to eq 0
    end
  end
end
