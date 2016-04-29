FactoryGirl.define do
  factory :position do
    pieces     "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
    active     "w"
    castling   "KQkq"
    en_passant "-"
    half_move  0
    move       1
    name       { Faker::Lorem.words(3).join(" ") }
    notes      { Faker::Lorem.paragraphs(3).join(" ") }

    factory :ending do
      pieces     "R7/6k1/P7/8/8/3K4/8/r7"
      active     "b"
      castling   "-"
    end
  end
end
