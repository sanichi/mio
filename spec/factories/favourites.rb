FactoryGirl.define do
  factory :favourite do
    name     { Faker::Book.title }
    category { rand(I18n.t("favourite.categories").size) }
    year     { (Favourite::MIN_YEAR..Date.today.year).to_a.sample }
    link     { Faker::Internet.url("wikipedia.org") }
    fans     { %w/Mark Sandra/.sample([1, 2].sample).sort.join(", ") }
  end
end
