FactoryBot.define do
  factory :similar_word do
    readings { Faker::Lorem.words.sort.join(" ") }
  end
end
