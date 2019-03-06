FactoryBot.define do
  factory :misa do
    category  { Misa::CATEGORIES.sample }
    japanese  { [true, false].sample }
    long      { [Faker::Blockchain::Bitcoin.address.truncate(11, omission: ""), nil].sample }
    minutes   { "#{rand(1000)}:#{sprintf('%02d', rand(60))}" }
    note      { Faker::Lorem.paragraph(3) }
    published { Faker::Date.between(5.years.ago, Date.today) }
    short     { Faker::Blockchain::Bitcoin.address.truncate(11, omission: "") }
    title     { Faker::Lorem.paragraph.truncate(Note::MAX_TITLE) }
  end
end
