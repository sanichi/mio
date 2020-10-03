FactoryBot.define do
  factory :misa do
    alt                  { [Faker::Internet.url, nil].sample }
    japanese             { [true, false].sample }
    minutes              { "#{rand(1000)}:#{sprintf('%02d', rand(60))}" }
    note                 { Faker::Lorem.paragraphs(number: 3) }
    published            { Faker::Date.between(from: 5.years.ago, to: Date.today) }
    title                { Faker::Lorem.sentence.truncate(Misa::MAX_TITLE) }
    url                  { Faker::Internet.url }
    series               { [Faker::Lorem.word.truncate(Misa::MAX_SERIES), nil].sample }
    sequence(:number, 1) { |n| n }
  end
end
