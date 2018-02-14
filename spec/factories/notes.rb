FactoryBot.define do
  factory :note do
    stuff { Faker::Lorem.paragraph(3) }
    title { Faker::Lorem.paragraph.truncate(Note::MAX_TITLE) }
  end
end
