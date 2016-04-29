FactoryGirl.define do
  factory :position do
    pieces     "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
    active     "w"
    castling   "KQkq"
    en_passant "-"
    half_move  0
    move       1
  end
end
