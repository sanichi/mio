FactoryGirl.define do
  factory :favourite do
    category { rand(I18n.t("favourite.categories").size) }
    link     { Faker::Internet.url("wikipedia.org") }
    mark     { (1..Favourite::MAX_SCORE).to_a.sample }
    name     { Faker::Book.title }
    note     { Faker::Lorem.words(3).join(" ") }
    sandra   { (1..Favourite::MAX_SCORE).to_a.sample }
    year     { (Favourite::MIN_YEAR..Date.today.year).to_a.sample }
  end
end
