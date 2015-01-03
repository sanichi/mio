require 'rails_helper'

describe Upload do
  let(:delete)      { I18n.t("delete") }
  let(:file_upload) { I18n.t("upload.file") }
  let(:load)        { I18n.t("upload.load") }
  let(:name)        { I18n.t("name") }
  let(:new_upload)  { I18n.t("upload.new") }
  let(:upload)      { I18n.t("upload.upload") }
  let(:uploads)     { I18n.t("upload.uploads") }

  let(:sample) { "capital-1.csv" }
  let(:title)  { "//h1[.='%s']" }

  context "create" do
    let(:table) { "//table/tbody/tr[th[.='%s'] and td[.='%s']]" }

    it "success" do
      visit root_path
      click_link new_upload
      attach_file file_upload, test_file_path(sample)
      click_button load

      expect(page).to have_xpath title % upload
      expect(page).to have_xpath table % [name, sample]

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
        visit root_path
        click_link new_upload
        click_button load

        expect(page).to have_xpath title % new_upload
        expect(page).to have_xpath error % "missing"

        expect(Upload.count).to eq 0
      end

      it "empty file" do
        visit root_path
        click_link new_upload
        attach_file file_upload, test_file_path(empty)
        click_button load

        expect(page).to have_xpath title % new_upload
        expect(page).to have_xpath error % "blank"

        expect(Upload.count).to eq 0
      end

      it "wrong content-type" do
        visit root_path
        click_link new_upload
        attach_file file_upload, test_file_path(image)
        click_button load

        expect(page).to have_xpath title % new_upload
        expect(page).to have_xpath error % "image/png"

        expect(Upload.count).to eq 0
      end
    end
  end

  context "delete" do
    it "success" do
      visit root_path
      click_link new_upload
      attach_file file_upload, test_file_path(sample)
      click_button load

      expect(Upload.count).to eq 1
      expect(Transaction.count).to eq 5

      click_link delete
      expect(page).to have_xpath title % uploads

      expect(Upload.count).to eq 0
      expect(Transaction.count).to eq 0
    end
  end
end
