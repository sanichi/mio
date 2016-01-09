FactoryGirl.define do
  factory :favourite do
    category { rand(I18n.t("favourite.categories").size) }
    link     { Faker::Internet.url("wikipedia.org") }
    mark     { rand(I18n.t("favourite.votes").size - 1) + 1 }
    name     { Faker::Book.title }
    sandra   { rand(I18n.t("favourite.votes").size) }
    year     { (Favourite::MIN_YEAR..Date.today.year).to_a.sample }
  end
end
