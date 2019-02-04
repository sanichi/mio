FactoryBot.define do
  factory :book do
    author    { Faker::Name.name }
    borrower  { [Faker::Name.name, nil].sample }
    category  { Book::CATEGORIES.sample }
    medium    { Book::MEDIA.sample }
    note      { [nil, Faker::Lorem.paragraph(3)].sample }
    title     { Faker::Lorem.words(3).join(" ") }
    year      { (Book::MIN_YEAR..Date.today.year).to_a.sample }
  end
end
