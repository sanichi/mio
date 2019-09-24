FactoryBot.define do
  factory :reading, class: Wk::Reading do
    characters { Faker::Lorem.word }
    primary    { [true, false].sample }
  end
end
