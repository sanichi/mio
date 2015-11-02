require 'rails_helper'

describe HistoricalEvent do
  include_context "test_data"

  let(:data) { build(:historical_event) }

  before(:each) do
    login
    visit historical_events_path
  end

  context "create" do
    it "success" do
      click_link new_historical_event
      fill_in description, with: data.description
      fill_in historical_event_start, with: data.start
      fill_in historical_event_finish, with: data.finish
      click_button save

      expect(page).to have_title historical_events

      expect(HistoricalEvent.count).to eq 1
      e = HistoricalEvent.first

      expect(e.description).to eq data.description
      expect(e.start).to eq data.start
      expect(e.finish).to eq data.finish
    end
  end

  context "failure" do
    it "no decription" do
      click_link new_historical_event
      fill_in historical_event_start, with: data.start
      fill_in historical_event_finish, with: data.finish
      click_button save

      expect(page).to have_title new_historical_event
      expect(HistoricalEvent.count).to eq 0
      expect(page).to have_css(error, text: "blank")
    end

    it "invalid years" do
      click_link new_historical_event
      fill_in description, with: data.description
      fill_in historical_event_start, with: data.finish
      fill_in historical_event_finish, with: data.start
      click_button save

      expect(page).to have_title new_historical_event
      expect(HistoricalEvent.count).to eq 0
      expect(page).to have_css(error, text: "finish before start")
    end
  end

  context "edit" do
    let!(:historical_event) { create(:historical_event) }

    it "success" do
      visit historical_events_path
      click_link edit

      expect(HistoricalEvent.count).to eq 1
      e = HistoricalEvent.first
      finish = e.finish

      expect(page).to have_title edit_historical_event
      fill_in historical_event_finish, with: finish + 1
      click_button save

      expect(page).to have_title historical_events

      e.reload
      expect(e.finish).to eq finish + 1
    end
  end

  context "delete" do
    let!(:historical_event) { create(:historical_event) }

    it "success" do
      visit historical_events_path
      click_link edit
      click_link delete

      expect(page).to have_title historical_events
      expect(HistoricalEvent.count).to eq 0
    end
  end
end
