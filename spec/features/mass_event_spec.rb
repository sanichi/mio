require 'rails_helper'

describe MassEvent, js: true do
  let!(:event) { create(:mass_event) }
  let(:data)   { build(:mass_event) }

  before(:each) do
    login
    visit mass_events_path
  end

  context "create" do
    it "success" do
      click_link t("mass.event.new")

      fill_in t("mass.event.name"), with: data.name
      fill_in t("mass.event.start"), with: data.start
      fill_in t("mass.event.finish"), with: data.finish
      click_button t("save")

      expect(page).to have_title t("mass.event.title")

      expect(MassEvent.count).to eq 2
      me = MassEvent.order(:id).last

      expect(me.name).to eq data.name
      expect(me.start).to eq data.start
      expect(me.finish).to eq data.finish
    end

    context "failure" do
      it "missing name" do
        click_link t("mass.event.new")

        fill_in t("mass.event.start"), with: data.start
        fill_in t("mass.event.finish"), with: data.finish
        click_button t("save")

        expect(page).to have_title t("mass.event.new")
        expect_error(page, "Name can't be blank")
        expect(MassEvent.count).to eq 1
      end

      it "missing start" do
        click_link t("mass.event.new")

        fill_in t("mass.event.name"), with: data.name
        fill_in t("mass.event.finish"), with: data.finish
        click_button t("save")

        expect(page).to have_title t("mass.event.new")
        expect_error(page, "Start can't be blank")
        expect(MassEvent.count).to eq 1
      end

      it "missing finish" do
        click_link t("mass.event.new")

        fill_in t("mass.event.name"), with: data.name
        fill_in t("mass.event.start"), with: data.start
        click_button t("save")

        expect(page).to have_title t("mass.event.new")
        expect_error(page, "Finish can't be blank")
        expect(MassEvent.count).to eq 1
      end

      it "reversed dates" do
        click_link t("mass.event.new")

        fill_in t("mass.event.name"), with: data.name
        fill_in t("mass.event.start"), with: data.finish + 1
        fill_in t("mass.event.finish"), with: data.start - 1
        click_button t("save")

        expect(page).to have_title t("mass.event.new")
        expect_error(page, "Finish must be on or after Start")
        expect(MassEvent.count).to eq 1
      end

      it "future dates" do
        click_link t("mass.event.new")

        fill_in t("mass.event.name"), with: data.name
        fill_in t("mass.event.start"), with: data.start + 400
        fill_in t("mass.event.finish"), with: data.finish + 400
        click_button t("save")

        expect(page).to have_title t("mass.event.new")
        expect_error(page, "Start must not be in the future")
        expect_error(page, "Finish must not be in the future")
        expect(MassEvent.count).to eq 1
      end

      it "non-unique dates" do
        click_link t("mass.event.new")

        fill_in t("mass.event.name"), with: data.name
        fill_in t("mass.event.start"), with: event.start
        fill_in t("mass.event.finish"), with: event.finish
        click_button t("save")

        expect(page).to have_title t("mass.event.new")
        expect_error(page, "Start has already been taken");
        expect_error(page, "Finish has already been taken");
        expect(MassEvent.count).to eq 1
      end
    end
  end

  context "edit" do
    it "success" do
      click_link t("symbol.edit")

      expect(page).to have_title t("mass.event.edit")
      fill_in t("mass.event.name"), with: data.name
      click_button t("save")

      expect(page).to have_title t("mass.event.title")

      expect(MassEvent.count).to eq 1
      me = MassEvent.first

      expect(me.name).to eq data.name
    end
  end

  context "delete" do
    it "success" do
      expect(MassEvent.count).to eq 1

      click_link t("symbol.edit")
      accept_confirm do
        click_link t("delete")
      end

      expect(page).to have_title t("mass.event.title")
      expect(MassEvent.count).to eq 0
    end
  end
end
