FactoryBot.define do
  factory :verb_pair do
    transitive   { vocab }
    intransitive { vocab }
    group        { rand(VerbPair::MAX_GROUP + 1) }
  end
end
