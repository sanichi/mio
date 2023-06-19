FactoryBot.define do
  factory :classifier do
    name           { Faker::Lorem.sentence.truncate(Classifier::MAX_NAME) }
    category       { %w{POS D/D S/O FOO FII FUM ZAK PAZ POO WAK NAK PAK}.sample(rand(5) + 1).join("|")}
    color          { %w/b1a4b6 d8a98e b08fa2 3a99d8 0f1413 898577 b3ac93/.sample}
    description    { %w{MARKS ARTISAN TRANSFER LOTTERY PENSION REFUND}.sample(rand(5) + 1).join("\n")}
    max_amount     { 1 + rand(100) }
    min_amount     { -1 - rand(100) }
  end
end
