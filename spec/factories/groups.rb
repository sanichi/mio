FactoryBot.define do
  factory :wk_group, class: 'Wk::Group' do
    category { Wk::Group::CATEGORIES.sample }
    vocab_list { Faker::Lorem.words.join(" ") }
  end
end
