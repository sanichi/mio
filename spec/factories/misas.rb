FactoryBot.define do
  factory :misa do
    category  { Misa::CATEGORIES.sample }
    japanese  { [true, false].sample }
    long      { [Faker::Blockchain::Bitcoin.address.truncate(11, omission: ""), nil].sample }
    minutes   { "#{rand(1000)}:#{sprintf('%02d', rand(60))}" }
    note      { Faker::Lorem.paragraphs(number: 3) }
    published { Faker::Date.between(from: 5.years.ago, to: Date.today) }
    short     { Faker::Blockchain::Bitcoin.address.truncate(11, omission: "") }
    title     { Faker::Lorem.sentence.truncate(Misa::MAX_TITLE) }
  end
end
