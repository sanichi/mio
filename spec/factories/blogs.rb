FactoryGirl.define do
  factory :blog do
    draft false
    story { Faker::Lorem.paragraph(3) }
    title { Faker::Lorem.paragraph.truncate(Blog::MAX_TITLE) }
    user
  end
end
