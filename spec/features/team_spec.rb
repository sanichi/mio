require 'rails_helper'

describe Team do
  let(:data) { build(:team) }
  let!(:team) { create(:team) }

  before(:each) do
    login
    click_link t("team.teams")
  end

  context "create" do
    it "success" do
      click_link t("team.new")
      fill_in t("team.name"), with: data.name
      fill_in t("team.short"), with: data.short
      fill_in t("team.slug"), with: data.slug
      select data.division, from: t("team.division")

      click_button t("save")

      expect(Team.count).to eq 2
      t = Team.by_created.last

      expect(page).to have_title data.name

      expect(t.name).to eq data.name
      expect(t.short).to eq data.short
      expect(t.slug).to eq data.slug
      expect(t.division).to eq data.division
    end

    it "failure" do
      click_link t("team.new")
      fill_in t("team.name"), with: data.name
      fill_in t("team.short"), with: data.short
      select data.division, from: t("team.division")
      click_button t("save")

      expect(page).to have_title t("team.new")
      expect(Team.count).to eq 1
      expect_error(page, "blank")
    end
  end

  context "edit" do
    it "success" do
      visit team_path(team)
      click_link t("edit")

      expect(page).to have_title t("team.edit")
      fill_in t("team.name"), with: data.name
      click_button t("save")

      expect(page).to have_title data.name

      expect(Team.count).to eq 1
      t = Team.by_created.last

      expect(t.name).to eq data.name
    end
  end

  context "delete" do
    it "success" do
      expect(Team.count).to eq 1

      visit team_path(team)
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("team.teams")
      expect(Team.count).to eq 0
    end
  end
end
