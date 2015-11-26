FactoryGirl.define do
  factory :blog do
    story { Faker::Lorem.paragraph(3) }
    title { Faker::Lorem.paragraph.truncate(Blog::MAX_TITLE) }
    user
  end
end
