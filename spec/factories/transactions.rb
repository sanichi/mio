FactoryBot.define do
  factory :transaction do
    account     "cap"
    cost        nil
    description "Transfer from Income Account"
    quantity    nil
    reference   "Transfer"
    settle_date { Date.today }
    signature   { Digest::MD5.hexdigest([trade_date,settle_date,description,reference,cost,quantity,value].join("|")) }
    trade_date  { Date.today }
    upload
    value       18.6
  end
end
