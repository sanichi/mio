require 'rails_helper'

describe Bucket do
  let(:data)    { build(:bucket) }
  let!(:bucket) { create(:bucket) }

  before(:each) do
    login
    click_link t("bucket.buckets")
  end

  context "create" do
    it "success" do
      click_link t("bucket.new")
      fill_in t("name"), with: data.name
      select t("bucket.level")[data.mark], from: t("bucket.mark")
      select t("bucket.level")[data.sandra], from: t("bucket.sandra")
      fill_in t("notes"), with: data.notes
      click_button t("save")

      expect(page).to have_title t("bucket.bucket")

      expect(Bucket.count).to eq 2
      b = Bucket.last

      expect(b.name).to eq data.name
      expect(b.mark).to eq data.mark
      expect(b.sandra).to eq data.sandra
      expect(b.notes).to eq data.notes
    end

    it "failure" do
      click_link t("bucket.new")
      select t("bucket.level")[data.mark], from: t("bucket.mark")
      select t("bucket.level")[data.sandra], from: t("bucket.sandra")
      fill_in t("notes"), with: data.notes
      click_button t("save")

      expect(page).to have_title t("bucket.new")
      expect(Bucket.count).to eq 1
      expect_error(page, "blank")
    end
  end

  context "edit" do
    it "success" do
      click_link bucket.name
      click_link t("edit")

      expect(page).to have_title t("bucket.edit")
      fill_in t("name"), with: data.name
      click_button t("save")

      expect(page).to have_title t("bucket.bucket")

      expect(Bucket.count).to eq 1
      b = Bucket.last

      expect(b.name).to eq data.name
    end

    it "failure" do
      click_link bucket.name
      click_link t("edit")

      expect(page).to have_title t("bucket.edit")
      select t("bucket.level")[0], from: t("bucket.mark")
      select t("bucket.level")[0], from: t("bucket.sandra")
      click_button t("save")

      expect(page).to have_title t("bucket.edit")
      expect_error(page, "at least one")

      expect(Bucket.count).to eq 1
      b = Bucket.last

      expect(b.mark + b.sandra).to be > 0
    end
  end

  context "delete" do
    it "success" do
      expect(Bucket.count).to eq 1

      click_link bucket.name
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("bucket.buckets")
      expect(Bucket.count).to eq 0
    end
  end
end
