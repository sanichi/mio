FactoryBot.define do
  factory :grammar_group do
    title { Faker::Lorem.paragraph.truncate(GrammarGroup::MAX_TITLE) }
  end
end
