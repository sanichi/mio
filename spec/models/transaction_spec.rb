require 'rails_helper'

describe Transaction do
  context "create" do
    let(:upload) { create(:upload) }

    it "success" do
      expect(upload.error).to be_nil
      expect(upload.transactions.count).to eq 5
      t = upload.transactions

      expect(t[0].trade_date).to eq Date.new(2014, 12, 10)
      expect(t[1].trade_date).to eq Date.new(2014, 11, 24)
      expect(t[2].trade_date).to eq Date.new(2014, 11, 17)
      expect(t[3].trade_date).to eq Date.new(2014, 11, 10)
      expect(t[4].trade_date).to eq Date.new(2014, 10,  2)

      expect(t[0].settle_date).to eq Date.new(2014, 12, 10)
      expect(t[1].settle_date).to eq Date.new(2014, 11, 24)
      expect(t[2].settle_date).to eq Date.new(2014, 11, 19)
      expect(t[3].settle_date).to eq Date.new(2014, 11, 10)
      expect(t[4].settle_date).to eq Date.new(2014, 10,  2)

      expect(t[0].reference).to eq "Transfer"
      expect(t[1].reference).to eq "FPD"
      expect(t[2].reference).to eq "S564913611"
      expect(t[3].reference).to eq "Transfer"
      expect(t[4].reference).to eq "MANAGE FEE"

      expect(t[0].description).to eq "Transfer from Income Account"
      expect(t[1].description).to eq "Payment to Client"
      expect(t[2].description).to eq "Computacenter plc Ord 6 2/3p"
      expect(t[3].description).to eq "Transfer from Income Account"
      expect(t[4].description).to eq "Management Fee"

      expect(t[0].cost).to be_nil
      expect(t[1].cost).to be_nil
      expect(t[2].cost).to eq 603.27
      expect(t[3].cost).to be_nil
      expect(t[4].cost).to be_nil

      expect(t[0].quantity).to be_nil
      expect(t[1].quantity).to be_nil
      expect(t[2].quantity).to eq 167
      expect(t[3].quantity).to be_nil
      expect(t[4].quantity).to be_nil

      expect(t[0].value).to eq 47.80
      expect(t[1].value).to eq -1002.60
      expect(t[2].value).to eq 995.50
      expect(t[3].value).to eq 7.24
      expect(t[4].value).to eq -2.47
    end
  end

  context "errors" do
    let(:upload) { build(:upload) }

    it "missing description" do
      upload.content.sub!(/Transfer from Income Account/, "")
      expect{upload.save!}.to_not raise_error
      expect(upload.error).to match(/line 7.*description.*blank/i)
      expect(upload.transactions.count).to eq 0
    end

    it "date order" do
      upload.content.sub!(/"17\/11\/2014","19\/11\/2014"/, '"19/11/2014","17/11/2014"')
      expect{upload.save!}.to_not raise_error
      expect(upload.error).to match(/line 9.*settle.*before.*trade/i)
      expect(upload.transactions.count).to eq 2
    end

    it "future date" do
      upload.content.gsub!(/02\/10\/2014/, Date.today.days_since(1).strftime('%d/%m/%Y'))
      expect{upload.save!}.to_not raise_error
      expect(upload.error).to match(/line 11.*can't be in the future/i)
      expect(upload.transactions.count).to eq 4
    end
  end

  context "corrections" do
    let(:extra_spaces) { create(:transaction, description: "Transfer  from Income Account ", reference: " MANAGEMENT  FEE\t")}
    let(:changed_name) { create(:transaction, description: "Computacenter plc Ordinary 6p", quantity: 186) }
    let(:spaces_name)  { create(:transaction, description: " Computacenter plc Ordinary 6p ") }

    it "squishing" do
      expect(extra_spaces.description).to eq "Transfer from Income Account"
      expect(extra_spaces.reference).to eq "MANAGEMENT FEE"
    end

    it "description" do
      expect(changed_name.description).to eq "Computacenter plc Ord 6 2/3p"
      expect(changed_name.quantity).to eq 167
    end

    it "both" do
      expect(spaces_name.description).to eq "Computacenter plc Ord 6 2/3p"
    end
  end
end
