require 'rails_helper'

describe Position do
  let(:data)  { build(:position) }

  context "initial position" do
    it "valid" do
      expect(data).to be_valid
    end

    it "#fen" do
      expect(data.fen).to eq "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    end
  end

  context "normalization" do
    it "castling" do
      [
        ["", "-"],
        [" ", "-"],
        [" - ", "-"],
        ["QK", "KQ"],
        [" K Q  kq ", "KQkq"],
        [" k - kQ qK - QkK ", "KQkq"],
      ].each do |val, exp|
        position = build(:position, castling: val)
        expect(position).to be_valid
        expect(position.castling).to eq exp
      end
    end

    it "active" do
      [
        ["b", "b"],
        [" W ", "w"],
        ["white", "w"],
        [" BB LAC kk", "b"],
      ].each do |val, exp|
        position = build(:position, active: val)
        expect(position).to be_valid
        expect(position.active).to eq exp
      end
    end

    it "en_passant" do
      [
        ["", "-"],
        [" ", "-"],
        [" - ", "-"],
        [" E3 ", "e3"],
        [" - h 6 1 ", "h6"],
      ].each do |val, exp|
        position = build(:position, en_passant: val)
        expect(position).to be_valid
        expect(position.en_passant).to eq exp
      end
    end

    it "half_move" do
      [
        [nil, 0],
      ].each do |val, exp|
        position = build(:position, half_move: val)
        expect(position).to be_valid
        expect(position.half_move).to eq exp
      end
    end

    it "move" do
      [
        [nil, 1],
        [0, 1],
      ].each do |val, exp|
        position = build(:position, move: val)
        expect(position).to be_valid
        expect(position.move).to eq exp
      end
    end
  end

  context "FEN" do
    it "start position" do
      position = build(:position, pieces: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", active: "", castling: "", en_passant: "", half_move: "", move: "")
      expect(position).to be_valid
      expect(position.pieces).to eq "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
      expect(position.active).to eq "w"
      expect(position.castling).to eq "KQkq"
      expect(position.en_passant).to eq "-"
      expect(position.half_move).to eq 0
      expect(position.move).to eq 1
    end
  end

  context "invalid" do
    it "active" do
      ["", "wb"].each do |val|
        expect(build(:position, active: val)).to_not be_valid
      end
    end

    it "en_passant" do
      ["e", "ff3", "d4", "6", "i6", "b33"].each do |val|
        expect(build(:position, en_passant: val)).to_not be_valid
      end
    end

    it "half_move" do
      [-1].each do |val|
        expect(build(:position, half_move: val)).to_not be_valid
      end
    end

    it "move" do
      [-1].each do |val|
        expect(build(:position, move: val)).to_not be_valid
      end
    end
  end

  context "invalid pieces" do
    let(:start) { "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR" }

    it "bad count" do
      position = build(:position, pieces: start.sub("8", "7"))
      expect(position).to_not be_valid
      expect(position.errors[:pieces].first).to eq t("position_error_badc")
    end

    it "no black king" do
      position = build(:position, pieces: start.sub("k", "q"))
      expect(position).to_not be_valid
      expect(position.errors[:pieces].first).to eq t("position_error_nobk")
    end

    it "no white king" do
      position = build(:position, pieces: start.sub("K", "1"))
      expect(position).to_not be_valid
      expect(position.errors[:pieces].first).to eq t("position_error_nowk")
    end

    it "pawn on the eighth rank" do
      position = build(:position, pieces: start.sub("r", "p"))
      expect(position).to_not be_valid
      expect(position.errors[:pieces].first).to eq t("position_error_pote")
    end

    it "pawn on the first rank" do
      position = build(:position, pieces: start.sub("N", "P"))
      expect(position).to_not be_valid
      expect(position.errors[:pieces].first).to eq t("position_error_potf")
    end

    it "too many black kings" do
      position = build(:position, pieces: start.sub("r", "k"))
      expect(position).to_not be_valid
      expect(position.errors[:pieces].first).to eq t("position_error_tmbk")
    end

    it "too many white kings" do
      position = build(:position, pieces: start.sub("8/P", "7K/P"))
      expect(position).to_not be_valid
      expect(position.errors[:pieces].first).to eq t("position_error_tmwk")
    end
  end

  context "symbol proxies" do
    it "evaluations" do
      position = build(:position, notes: "$14 $15 $16 $17 $18 $19 +/= =/+ +/- -/+")
      expect(position).to be_valid
      expect(position.notes).to eq "⩲ ⩱ ± ∓ +- -+ ⩲ ⩱ ± ∓"
    end

    it "pieces" do
      position = build(:position, notes: "Kf2⩲ Qa8 Bg2 N8f6 Rfe1! a8(Q)+ fg8(N)")
      expect(position).to be_valid
      expect(position.notes).to eq "♔f2⩲ ♕a8 ♗g2 ♘8f6 ♖fe1! a8(♕)+ fg8(♘)"
    end
  end
end
