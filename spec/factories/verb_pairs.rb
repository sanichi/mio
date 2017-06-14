FactoryGirl.define do
  factory :verb_pair do
    transitive   { vocab }
    intransitive { vocab }
    category     { VerbPair::CATEGORIES.sample }
  end
end
