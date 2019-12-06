require 'rails_helper'

describe Upload do
  before(:each) do
    login
    visit new_upload_path
  end

  let(:sample) { "capital-1.csv" }

  context "create" do
    let(:table) { "//table/tbody/tr[th[.='%s'] and td[.='%s']]" }

    it "success" do
      select t("upload.account.cap"), from: t("upload.account.acc")
      attach_file t("upload.file"), test_file_path(sample)
      click_button t("upload.load")

      expect(page).to have_title t("upload.upload")
      expect(page).to have_xpath table % [t(:name), sample]

      expect(Upload.count).to eq 1
      u = Upload.first

      expect(u.content).to be_present
      expect(u.content.length).to eq u.size
      expect(Upload::TYPES).to include(u.content_type)
      expect(u.error).to be_nil
      expect(u.name).to eq sample
      expect(u.transactions.count).to eq 5
    end

    context "errors" do
      let(:error)  { "//fieldset//div[contains(@class,'help-block') and contains(.,'%s')]" }
      let(:empty)  { "empty.csv" }
      let(:image)  { "small-image.png" }

      it "missing file" do
        select t("upload.account.cap"), from: t("upload.account.acc")
        click_button t("upload.load")

        expect(page).to have_title t("upload.new")
        expect(page).to have_xpath error % "missing"

        expect(Upload.count).to eq 0
      end

      it "empty file" do
        select t("upload.account.cap"), from: t("upload.account.acc")
        attach_file t("upload.file"), test_file_path(empty)
        click_button t("upload.load")

        expect(page).to have_title t("upload.new")
        expect(page).to have_xpath error % "blank"

        expect(Upload.count).to eq 0
      end

      it "wrong content-type" do
        select t("upload.account.cap"), from: t("upload.account.acc")
        attach_file t("upload.file"), test_file_path(image)
        click_button t("upload.load")

        expect(page).to have_title t("upload.new")
        expect(page).to have_xpath error % "image/png"

        expect(Upload.count).to eq 0
      end
    end
  end

  context "delete" do
    it "success" do
      select t("upload.account.cap"), from: t("upload.account.acc")
      attach_file t("upload.file"), test_file_path(sample)
      click_button t("upload.load")

      expect(Upload.count).to eq 1
      expect(Transaction.count).to eq 5

      click_link t("delete")
      expect(page).to have_title t("upload.uploads")

      expect(Upload.count).to eq 0
      expect(Transaction.count).to eq 0
    end
  end
end
