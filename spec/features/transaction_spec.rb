require 'rails_helper'

describe Transaction do
  def load_file(page, name)
    attach_file("file", test_file_path(name))
    click_button t("transaction.upload")
    expect(page).to have_title t("transaction.transactions")
  end

  def load_data(page, text)
    file = Tempfile.new(%w/foo .csv/)
    begin
      file.write(text)
      file.close
      attach_file("file", file.path)
      click_button t("transaction.upload")
      expect(page).to have_title t("transaction.transactions")
    ensure
      file.unlink
    end
  end

  before(:each) do
    login
    click_link t("transaction.transactions")
  end

  context "success" do
    it "upload files" do
      expect(Transaction.count).to eq 0

      load_file page, "mrbs.csv"

      expect_notice(page, "rows: 48, created: 45, duplicates: 0")
      expect(Transaction.where(upload_id: 1).count).to eq 45
      expect(Transaction.count).to eq 45

      load_file page, "jrbs.csv"

      expect_notice(page, "rows: 75, created: 72, duplicates: 0")
      expect(Transaction.where(upload_id: 2).count).to eq 72
      expect(Transaction.count).to eq 117

      load_file page, "mrbs.csv"

      expect_notice(page, "rows: 48, created: 0, duplicates: 45")
      expect(Transaction.where(upload_id: 1).count).to eq 0
      expect(Transaction.where(upload_id: 2).count).to eq 72
      expect(Transaction.where(upload_id: 3).count).to eq 45
      expect(Transaction.where(account: "jrbs").count).to eq 72
      expect(Transaction.where(account: "mrbs").count).to eq 45
      expect(Transaction.count).to eq 117
    end

    it "upload data" do
      load_data page, <<~EOF
        Date,Type,Description,Value,Balance,Account Name,Account Number
        " 12/06/2023 "," POS "," blah blah\t",-26.7,"-7.61","House account","831909-101456"
      EOF

      expect_notice(page, "rows: 2, created: 1, duplicates: 0")
      expect(Transaction.where(upload_id: 1).count).to eq 1
      expect(Transaction.count).to eq 1

      t = Transaction.first
      expect(t.date.to_s).to eq "2023-06-12"
      expect(t.category).to eq "POS"
      expect(t.description).to eq "blah blah"
      expect(t.amount).to eq -26.7
      expect(t.balance).to eq -7.61
      expect(t.account).to eq "jrbs"
      expect(t.upload_id).to eq 1
    end
  end

  context "failure" do
    it "wrong file type" do
      load_file page, "malcolm.png"
      expect_error(page, "wrong file type (image/png)")
    end

    it "empty file" do
      load_data page, ""
      expect_error(page, "no records found")
      expect(Transaction.count).to eq 0
    end

    it "rubbish file" do
      load_data page, <<~EOF
        Why always me
        どうしていつも私なの？
      EOF
      expect_error(page, "wrong number of columns (1) on row 1")
      expect(Transaction.count).to eq 0
    end

    it "invalid account" do
      load_data page, <<~EOF
        "12/06/2023 ","POS","ARTISAN",-5.7,"100.61","House account","831909-101456"
        "12/06/2023","POS","DESC","-1","9","","831909-102456"
      EOF
      expect_error(page, "invalid account (831909-102456) on row 2")
      expect(Transaction.count).to eq 0
    end

    it "invalid category" do
      load_data page, <<~EOF
        "30/05/2023","DPC","To A/C 00234510",-25,"813.04","House account","831909-234510"
        "12/06/2023","POSX","COSTA","-1.50","235.21","","831909-101456"
      EOF
      expect_error(page, "Category is invalid")
      expect(Transaction.count).to eq 0
    end

    it "invalid desription" do
      load_data page, <<~EOF
      "12/06/2023 ","POS","ARTISAN",-5.7,"100.61","House account","831909-101456"
      "30/05/2023","DPC","To A/C 00234510",-25,"813.04","House account","831909-234510"
      "12/06/2023","POS"," ","4.50","18.76","","831909-101456"
      EOF
      expect_error(page, "Description can't be blank")
      expect(Transaction.count).to eq 0
    end
  end
end
