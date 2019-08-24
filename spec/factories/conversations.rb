FactoryBot.define do
  factory :conversation do
    audio { Faker::Lorem.word + "." + %w/mp3 m4a ogg/.sample }
    story { Faker::Lorem.paragraphs(number: 3) }
    title { Faker::Lorem.sentence.truncate(Conversation::MAX_TITLE) }
  end
end
