FactoryBot.define do
  factory :misa do
    category { Misa::CATEGORIES.sample }
    japanese { [true, false].sample }
    minutes  { "#{rand(1000)}:#{sprintf('%02d', rand(60))}" }
    note     { Faker::Lorem.paragraph(3) }
    short    { Faker::Bitcoin.address.truncate(11, omission: "") }
    title    { Faker::Lorem.paragraph.truncate(Note::MAX_TITLE) }
  end
end
