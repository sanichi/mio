require 'rails_helper'

describe Transaction do
  include_context "test_data"

  before(:each) do
    login
    visit new_upload_path
  end

  context "duplicates" do
    let(:sample1) { "capital-1.csv" }
    let(:sample2) { "capital-2.csv" }

    it "one order" do
      select capital, from: account
      attach_file file_upload, test_file_path(sample1)
      click_button load

      expect(Upload.count).to eq 1
      u = Upload.last
      expect(u.transactions.count).to eq 5
      expect(u.error).to be_nil

      visit uploads_path
      click_link new_upload
      select capital, from: account
      attach_file file_upload, test_file_path(sample1)
      click_button load

      expect(Upload.count).to eq 2
      u = Upload.last
      expect(u.transactions.count).to eq 0
      expect(u.error).to match(/all.*duplicates/i)

      visit uploads_path
      click_link new_upload
      select capital, from: account
      attach_file file_upload, test_file_path(sample2)
      click_button load

      expect(Upload.count).to eq 3
      u = Upload.last
      expect(u.transactions.count).to eq 4
      expect(u.error).to match(/some.*duplicates/i)

      expect(Transaction.count).to eq 9
    end

    it "other order" do
      select capital, from: account
      attach_file file_upload, test_file_path(sample2)
      click_button load

      expect(Upload.count).to eq 1
      u = Upload.last
      expect(u.transactions.count).to eq 8
      expect(u.error).to be_nil

      visit uploads_path
      click_link new_upload
      select capital, from: account
      attach_file file_upload, test_file_path(sample2)
      click_button load

      expect(Upload.count).to eq 2
      u = Upload.last
      expect(u.transactions.count).to eq 0
      expect(u.error).to match(/all.*duplicates/i)

      visit uploads_path
      click_link new_upload
      select capital, from: account
      attach_file file_upload, test_file_path(sample1)
      click_button load

      expect(Upload.count).to eq 3
      u = Upload.last
      expect(u.transactions.count).to eq 1
      expect(u.error).to match(/some.*duplicates/i)

      expect(Transaction.count).to eq 9
    end
  end
end
