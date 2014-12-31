require 'rails_helper'

describe Upload do
  let(:file_upload) { I18n.t("upload.file") }
  let(:new_upload)  { I18n.t("upload.new") }
  let(:load)        { I18n.t("upload.load") }
  let(:name)        { I18n.t("name") }
  let(:upload)      { I18n.t("upload.upload") }

  context "create" do
    let(:sample_1) { "capital-1.csv" }
    let(:image)    { "small-image.png" }

    it "succeeds" do
      visit root_path
      click_link new_upload
      attach_file file_upload, test_file_path(sample_1)
      click_button load

      expect(page).to have_xpath "/html/head/title[.='#{upload}']", visible: false
      expect(page).to have_xpath "//table/tbody/tr[th[.='#{name}'] and td[.='#{sample_1}']]"

      expect(Upload.count).to eq 1
      u = Upload.first

      expect(u.content).to be_present
      expect(u.content.length).to eq u.size
      expect(Upload::TYPES).to include(u.content_type)
      expect(u.error).to be_nil
      expect(u.name).to eq sample_1
      expect(u.parsed).to be false
    end

    it "fails due to wrong content-type" do
      visit root_path
      click_link new_upload
      attach_file file_upload, test_file_path(image)
      click_button load

      expect(page).to have_xpath "/html/head/title[.='#{new_upload}']", visible: false
      expect(page).to have_xpath "//fieldset//div[contains(@class,'help-block') and contains(.,'image/png')]"

      expect(Upload.count).to eq 0
    end
  end
end
