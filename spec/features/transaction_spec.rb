require 'rails_helper'

describe Transaction, js: true do
  def load_file(page, name)
    attach_file("file", test_file_path(name))
    click_button t("transaction.analyse")
    expect(page).to have_title t("transaction.transactions")
  end

  def load_data(page, text)
    file = Tempfile.new(%w/foo .csv/)
    begin
      file.write(text)
      file.close
      attach_file("file", file.path)
      click_button t("transaction.analyse")
      expect(page).to have_title t("transaction.transactions")
    ensure
      file.unlink
    end
  end

  before(:each) do
    login
    click_link t("other")
    click_link t("transaction.transactions")
  end

  context "success" do
    it "upload files" do
      expect(Transaction.count).to eq 0

      load_file page, "mrbs.csv"

      expect_notice(page, "rows: 48, created: 45, duplicates: 0, upload: 1")
      expect(Transaction.where(upload_id: 1).count).to eq 45
      expect(Transaction.count).to eq 45

      load_file page, "jrbs.csv"

      expect_notice(page, "rows: 75, created: 72, duplicates: 0, upload: 2")
      expect(Transaction.where(upload_id: 2).count).to eq 72
      expect(Transaction.count).to eq 117

      load_file page, "mrbs.csv"

      expect_notice(page, "rows: 48, created: 0, duplicates: 45, upload: 3")
      expect(Transaction.where(upload_id: 1).count).to eq 45
      expect(Transaction.where(upload_id: 2).count).to eq 72
      expect(Transaction.where(upload_id: 3).count).to eq 0
      expect(Transaction.where(account: "jrbs").count).to eq 72
      expect(Transaction.where(account: "mrbs").count).to eq 45
      expect(Transaction.count).to eq 117

      load_file page, "mcc.csv"

      expect_notice(page, "rows: 76, created: 70, duplicates: 0, upload: 3")
      expect(Transaction.where(upload_id: 1).count).to eq 45
      expect(Transaction.where(upload_id: 2).count).to eq 72
      expect(Transaction.where(upload_id: 3).count).to eq 70
      expect(Transaction.where(account: "mcc").count).to eq 70
      expect(Transaction.where(account: "jrbs").count).to eq 72
      expect(Transaction.where(account: "mrbs").count).to eq 45
      expect(Transaction.count).to eq 187

      load_file page, "starling.csv"

      expect_notice(page, "rows: 41, created: 40, duplicates: 0, upload: 4")
      expect(Transaction.where(upload_id: 1).count).to eq 45
      expect(Transaction.where(upload_id: 2).count).to eq 72
      expect(Transaction.where(upload_id: 3).count).to eq 70
      expect(Transaction.where(upload_id: 4).count).to eq 40
      expect(Transaction.where(account: "mcc").count).to eq 70
      expect(Transaction.where(account: "jrbs").count).to eq 72
      expect(Transaction.where(account: "mrbs").count).to eq 45
      expect(Transaction.where(account: "ms").count).to eq 40
      expect(Transaction.count).to eq 227
    end

    it "upload RBS account data" do
      load_data page, <<~EOF
        Date,Type,Description,Value,Balance,Account Name,Account Number
        " 12/06/2023 "," POS "," blah blah\t",-26.7,"-7.61","House account","831909-101456"
      EOF

      expect_notice(page, "rows: 2, created: 1, duplicates: 0, upload: 1")
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

    it "upload RBS credit card data" do
      load_data page, <<~EOF

      Date, Type, Description, Value, Balance, Account Name, Account Number

      20 Mar 2023,Purchase,"'AMZNMKTPLACE ",8.99,,"'M ORR","'543484******5254",
      05 Apr 2023,Payment," ' DIRECT DEBIT PAYMENT ",-1088.91,,"'M ORR","'543484******5254",
      04 Apr 2023,Fee,"'NON-STERLING TRANSACTION FEE",.54,,"'M ORR","'543484******5254",
      19 Jun 2023,,"'Balance as at 19 Jun 2023",,400.28,"'M ORR","'543484******5254"

      EOF

      expect_notice(page, "rows: 8, created: 3, duplicates: 0, upload: 1")
      expect(Transaction.where(upload_id: 1).count).to eq 3
      expect(Transaction.count).to eq 3

      t = Transaction.find_by(date: "2023-03-20")
      expect(t.category).to eq "PUR"
      expect(t.description).to eq "AMZNMKTPLACE"
      expect(t.amount).to eq -8.99
      expect(t.balance).to eq 0.0
      expect(t.account).to eq "mcc"
      expect(t.upload_id).to eq 1

      t = Transaction.find_by(date: "2023-04-05")
      expect(t.category).to eq "PAY"
      expect(t.description).to eq "DIRECT DEBIT PAYMENT"
      expect(t.amount).to eq 1088.91
      expect(t.balance).to eq 0.0
      expect(t.account).to eq "mcc"
      expect(t.upload_id).to eq 1

      t = Transaction.find_by(date: "2023-04-04")
      expect(t.category).to eq "FEE"
      expect(t.description).to eq "NON-STERLING TRANSACTION FEE"
      expect(t.amount).to eq -0.54
      expect(t.balance).to eq 0.0
      expect(t.account).to eq "mcc"
      expect(t.upload_id).to eq 1
    end

    it "upload more RBS credit card data" do
      load_data page, <<~EOF

      Date, Type, Description, Value, Balance, Account Name, Account Number

      10 Jul 2025,FEES,CASH FEE,0.30,,Marks credit,543484******5254
      10 Jul 2025,CASH,ULSTER BANK NORTH,10.00,,Marks credit,543484******5254
      10 Jul 2025,PURCHASE,APPLE.COM/BILL,2.99,,Marks credit,543484******5254
      11 Jul 2025,CASH,INTEREST - SEE SUMMARY,0.01,,Marks credit,543484******5254

      EOF

      expect_notice(page, "rows: 8, created: 4, duplicates: 0, upload: 1")
    end

    it "upload Starling data" do
      load_data page, <<~EOF
      Date,Counter Party,Reference,Type,Amount (GBP),Balance (GBP),Spending Category,Notes
      16/08/2025,ORR M J L,Watashi,FASTER PAYMENT,500.00,500.00,INCOME,
      17/08/2025,Mark Orr,Transfer into Easy Saver,TRANSFER,-500.00,500.00,SAVING,
      18/08/2025,Waterstones,WATERSTONES EFL969,APPLE PAY,-9.99,481.86,SHOPPING,
      19/08/2025,Costa Coffee,COSTA COFFEE 43010636,APPLE PAY,-7.15,434.06,EATING_OUT,
      EOF

      expect_notice(page, "rows: 5, created: 4, duplicates: 0, upload: 1")
      expect(Transaction.where(upload_id: 1).count).to eq 4
      expect(Transaction.count).to eq 4

      t = Transaction.find_by(date: "2025-08-16")
      expect(t.category).to eq "PAY"
      expect(t.description).to eq "ORR M J L"
      expect(t.amount).to eq 500.0
      expect(t.balance).to eq 500.0
      expect(t.account).to eq "ms"
      expect(t.upload_id).to eq 1

      t = Transaction.find_by(date: "2025-08-17")
      expect(t.category).to eq "DPC"
      expect(t.description).to eq "Mark Orr"
      expect(t.amount).to eq -500.00
      expect(t.balance).to eq 500.0
      expect(t.account).to eq "ms"
      expect(t.upload_id).to eq 1

      t = Transaction.find_by(date: "2025-08-18")
      expect(t.category).to eq "PUR"
      expect(t.description).to eq "Waterstones"
      expect(t.amount).to eq -9.99
      expect(t.balance).to eq 481.86
      expect(t.account).to eq "ms"
      expect(t.upload_id).to eq 1

      t = Transaction.find_by(date: "2025-08-19")
      expect(t.category).to eq "PUR"
      expect(t.description).to eq "Costa Coffee"
      expect(t.amount).to eq -7.15
      expect(t.balance).to eq 434.06
      expect(t.account).to eq "ms"
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
        "12/06/2023","POSX","COSTA","-1.50","235.21","","831909-234510"
      EOF
      expect_error(page, "Category is invalid")
      expect(Transaction.count).to eq 0
    end

    it "invalid desription" do
      load_data page, <<~EOF
      "12/06/2023 ","POS","ARTISAN",-5.7,"100.61","House account","831909-101456"
      "30/05/2023","DPC","To A/C 00234510",-25,"813.04","House account","831909-101456"
      "12/06/2023","POS"," ","4.50","18.76","","831909-101456"
      EOF
      expect_error(page, "Description can't be blank")
      expect(Transaction.count).to eq 0
    end

    it "unexpected balance" do
      load_data page, <<~EOF
        13 Mar 2023,Purchase,"'AMZNMktplace amazon.co.uk GBR",7.19,,"'M ORR","'543484******5254",
        14 Mar 2023,Purchase,"'WWWHEBRIDEANSMOKEHOUSE ISLE OF NORTH",24.15,10,"'M ORR","'543484******5254",
      EOF
      expect_error(page, "unexpected balance (10) on row 2")
      expect(Transaction.count).to eq 0
    end

    it "unrecognised category" do
      load_data page, <<~EOF
        20 Mar 2023,Purchase,"'APPLE.COM/BILL APPLE.COM/BILIRL",10.99,,"'M ORR","'543484******5254",
        20 Mar 2023,Rubbish,"'AMZNMktplace amazon.co.uk GBR",3.96,,"'M ORR","'543484******5254",
      EOF
      expect_error(page, "unrecognised category (Rubbish) on row 2")
      expect(Transaction.count).to eq 0
    end
  end
end
