FactoryBot.define do
  factory :ks_journal, class: Ks::Journal do
    warnings    { rand(20) }
    problems    { rand(3) }
    note        { Faker::Lorem.paragraphs(number: 3) }
  end
end
