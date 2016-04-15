FactoryGirl.define do
  factory :bucket do
    mark     { rand(I18n.t("bucket.level").size - 1) + 1 }
    name     { Faker::Book.title }
    sandra   { rand(I18n.t("bucket.level").size) }
    notes    { Faker::Lorem.paragraph }
  end
end
