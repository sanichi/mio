FactoryBot.define do
  factory :upload do
    account      "cap"
    content      <<-EOC
Portfolio Summary, , , ,
Client Name:,Dr Mark Orr, , ,
Client Number:,1412732, , ,
Valuation as at,26-12-2014 14:32, , ,

Trade date,Settle date,Reference,Description,Unit cost (p),Quantity,Value (£),
"10/12/2014","10/12/2014","Transfer","Transfer from Income Account","","","47.80"
"24/11/2014","24/11/2014","FPD","Payment to Client","","","-1,002.60"
"17/11/2014","19/11/2014","S564913611","Computacenter plc Ord 6 2/3p","603.27","167","995.50"
"10/11/2014","10/11/2014","Transfer","Transfer from Income Account","","","7.24"
"02/10/2014","02/10/2014","MANAGE FEE","HL Vantage Stocks & Shares NISA","","","-2.47"
EOC
    content_type "text/csv"
    error        nil
    name         "transactions.csv"
    size         { content.length }
  end
end
