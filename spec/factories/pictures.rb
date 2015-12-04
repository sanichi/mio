FactoryGirl.define do
  factory :picture do
    description { Faker::Lorem.paragraph(2) }
    image       { File.new(Rails.root + "spec" + "files" + "malcolm.jpg") }
    people      { Array.new }
    portrait    { [true, false].sample }
  end
end
