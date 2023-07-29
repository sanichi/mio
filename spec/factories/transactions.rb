FactoryBot.define do
  factory :transaction do
    account        { Transaction::ACCOUNTS.values.uniq.sample }
    amount         { [rand(100), -rand(100)].sample }
    balance        { [rand(1000), -rand(1000)].sample }
    category       { %w{POS D/D S/O FOO FII FUM ZAK PAZ POO WAK NAK PAK}.sample }
    date           { Date.today }
    description    { %w{MARKS ARTISAN TRANSFER LOTTERY PENSION REFUND}.sample }
    upload_id      { rand(10) + 1 }
  end
end
