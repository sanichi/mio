require 'rails_helper'

describe Bucket do
  let(:data)    { build(:bucket) }
  let!(:bucket) { create(:bucket) }

  before(:each) do
    login
    click_link t(:bucket_buckets)
  end

  context "create" do
    it "success" do
      click_link t(:bucket_new)
      fill_in t(:name), with: data.name
      select t(:bucket_level)[data.mark], from: t(:bucket_mark)
      select t(:bucket_level)[data.sandra], from: t(:bucket_sandra)
      fill_in t(:notes), with: data.notes
      click_button t(:save)

      expect(page).to have_title t(:bucket_bucket)

      expect(Bucket.count).to eq 2
      b = Bucket.last

      expect(b.name).to eq data.name
      expect(b.mark).to eq data.mark
      expect(b.sandra).to eq data.sandra
      expect(b.notes).to eq data.notes
    end

    it "failure" do
      click_link t(:bucket_new)
      select t(:bucket_level)[data.mark], from: t(:bucket_mark)
      select t(:bucket_level)[data.sandra], from: t(:bucket_sandra)
      fill_in t(:notes), with: data.notes
      click_button t(:save)

      expect(page).to have_title t(:bucket_new)
      expect(Bucket.count).to eq 1
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "edit" do
    it "success" do
      click_link bucket.name
      click_link t(:edit)

      expect(page).to have_title t(:bucket_edit)
      fill_in t(:name), with: data.name
      click_button t(:save)

      expect(page).to have_title t(:bucket_bucket)

      expect(Bucket.count).to eq 1
      b = Bucket.last

      expect(b.name).to eq data.name
    end

    it "failure" do
      click_link bucket.name
      click_link t(:edit)

      expect(page).to have_title t(:bucket_edit)
      select t(:bucket_level)[0], from: t(:bucket_mark)
      select t(:bucket_level)[0], from: t(:bucket_sandra)
      click_button t(:save)

      expect(page).to have_title t(:bucket_edit)
      expect(page).to have_css(error, text: "at least one")

      expect(Bucket.count).to eq 1
      b = Bucket.last

      expect(b.mark + b.sandra).to be > 0
    end
  end

  context "delete" do
    it "success" do
      expect(Bucket.count).to eq 1

      click_link bucket.name
      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:bucket_buckets)
      expect(Bucket.count).to eq 0
    end
  end
end
