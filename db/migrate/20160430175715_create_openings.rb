class CreateOpenings < ActiveRecord::Migration
  def change
    create_table :openings do |t|
      t.string   :code, limit: 3
      t.string   :description, limit: Opening::MAX_DESC

      t.timestamps null: false
    end

    Opening.new(code: "A00", description: "Irregular Openings").save!
    Opening.new(code: "A01", description: "Larsen's Opening: 1.b3").save!
    Opening.new(code: "A02", description: "Bird's Opening: 1.f4 (Dutch Attack, without: 1...d5, 1...g6 2.e4, 1...Nf6 2.d4, 1...e5 2.e4, 1...c5 2.e4, 1...d6 2.e4)").save!
    Opening.new(code: "A03", description: "Bird's Opening: 1...d5 (without: 2.d4)").save!
    Opening.new(code: "A04", description: "Réti Opening, 1.Nf3 (without: 1...Nf6, 1...d5)").save!
    Opening.new(code: "A05", description: "Réti Opening: 1...Nf6 (without: 2.c4, 2.d4, 2.Nc3, 2.g3 d5 2.d3 d5)").save!
    Opening.new(code: "A06", description: "Réti Opening: 1...d5").save!
    Opening.new(code: "A07", description: "Réti Opening, King's Indian Attack (Barcza System): 1...d5 2.g3").save!
    Opening.new(code: "A08", description: "Réti Opening, King's Indian Attack: 1...d5 2.g3 c5 3.Bg2").save!
    Opening.new(code: "A09", description: "Réti Opening: 1...d5 2.c4 (without: 2...c6, 2...e6)").save!
    Opening.new(code: "A10", description: "English Opening: 1.c4 (without: 1...e5, 1...c5, 1...e6, 1...c6, 1...Nf6, 1...g6 2.d4, 1...f5 2.d4, 1...b6 2.d4, 1...d6 2.e4, 1...d6 2.d4, 1...Nc6 2.d4)").save!
    Opening.new(code: "A11", description: "English, Caro–Kann defensive system, 1...c6 (without: 2.e4, 2.d4)").save!
    Opening.new(code: "A12", description: "English, Caro–Kann defensive system, 1...c6 2.Nf3 d5 3.b3").save!
    Opening.new(code: "A13", description: "English Opening: 1...e6 (without: 2.e4, 2.d4)").save!
    Opening.new(code: "A14", description: "English, Neo-Catalan declined: 1...e6 2.Nf3 d5 3.g3 Nf6 4.Bg2 Be7").save!
    Opening.new(code: "A15", description: "English, Anglo-Indian Defence: 1...Nf6 (without: 2.Nc3, 2.d4, 2.g3 c6, 2.g3 e5, 2.Nf3 c5, 2.Nf3 e6, 2.Nf3 c6)").save!
    Opening.new(code: "A16", description: "English Opening, Anglo-Indian Defence: 1...Nf6 2.Nc3 (without: 2...c5, 2...e5, 2...e6)").save!
    Opening.new(code: "A17", description: "English Opening, Hedgehog Defence, 1...Nf6 2.Nc3 e6 (without: 3.e4, 3.d4, 3.Nf3 c5, 3...d5 4.d4, 3...b5 4.d4, 3...Bb4 4.d4)").save!
    Opening.new(code: "A18", description: "English, Mikenas–Carls Variation: 1...Nf6 2.Nc3 e6 3.e4 (without: 3...c5)").save!
    Opening.new(code: "A19", description: "English, Mikenas–Carls, Sicilian Variation: 1...Nf6 2.Nc3 e6 3.e4 c5").save!
    Opening.new(code: "A20", description: "English Opening: 1...e5 (without: 2.e4, 2.Nc3, 2.Nf3 Nc6 3.Nc3, 2.Nf3 Nf6 3.Nc3, 2.Nf3 d6 3.Nc3)").save!
    Opening.new(code: "A21", description: "English Opening: 1...e5 2.Nc3 (without: 2...Nf6, 2...Nc6, 2...Bb4 3.g3 Nf6, 2...Bb4 3.Nf3 Nc6 2...Bb4 3.e3 Nf6)").save!
    Opening.new(code: "A22", description: "English Opening: 1...e5 2.Nc3 Nf6 (without: 3.Nf3 Nc6, 3.e3 Nc6, 3.g3 Nc6, 3.g3 c6, 3.g3 g6, 3.e4 Nc6 4.Nf3)").save!
    Opening.new(code: "A23", description: "English Opening, Bremen System, Keres Variation: 1...e5 2.Nc3 Nf6 3.g3 c6").save!
    Opening.new(code: "A24", description: "English Opening, Bremen System with 1...e5 2.Nc3 Nf6 3.g3 g6 (without: 4.Bg2 Bg7 5.d3 d6)").save!
    Opening.new(code: "A25", description: "English Opening, Sicilian Reversed: 1...e5 2 Nc3 Nc6 (without 3.Nf3, 3.g3 Nf6 4.Nf3, 3.e3 Nf6 4.Nf3)").save!
    Opening.new(code: "A26", description: "English Opening, Closed System; 1...e5 2.Nc3 Nc6 3.g3 g6 4.Bg2 Bg7 5.d3 d6").save!
    Opening.new(code: "A27", description: "English Opening, Three Knights System: 1...e5 2.Nc3 Nc6 3.Nf3 (without: 3...Nf6)").save!
    Opening.new(code: "A28", description: "English Opening, Four Knights System: 1...e5 2.Nc3 Nc6 3.Nf3 Nf6 (without 4.g3)").save!
    Opening.new(code: "A29", description: "English Opening, Four Knights, Kingside Fianchetto: 1...e5 2.Nc3 Nc6 3.Nf3 Nf6 4.g3").save!
    Opening.new(code: "A30", description: "English Opening, Symmetrical defence: 1.c4 c5 (without: 2.Nc3, 2.e4, 2.g3 g6 3.Nc3, 2.g3 Nc6 3.Nc3, 2.Nf3 Nc6 3.Nc3, 2.e3 Nf6 4.d4)").save!
    Opening.new(code: "A31", description: "English Opening, Symmetrical, Benoni formation: 1...c5 2.Nf3 Nf6 3.d4 (without: 3...cxd4 4.Nxd4 e6, 3...cxd4 4.Nxd4 a6 5.Nc3 e6, 3...cxd4 4.Nxd4 Nc6 5.Nc3 e6)").save!
    Opening.new(code: "A32", description: "English Opening, Symmetrical: 1...c5 2.Nf3 Nf6 3.d4 cxd4 4.Nxd4 e6 (without: 5.Nc3 Nc6)").save!
    Opening.new(code: "A33", description: "English Opening, Symmetrical: 1...c5 2.Nf3 Nf6 3.d4 cxd4 4.Nxd4 e6 5.Nc3 Nc6").save!
    Opening.new(code: "A34", description: "English Opening, Symmetrical: 1...c5 2.Nc3 (without 2...Nc6, 2...Nf6 3.Nf3 Nc6, 2...Nf6 3.e4 e6, 2...e6 3.Nf3 Nf6, 4.g3 Nc6)").save!
    Opening.new(code: "A35", description: "English Opening, Symmetrical: 1...c5 2.Nc3 Nc6 (without 3.g3, 3.e4, 3.Nf3 Nf6, 4.g3 e6, 3.Nf3 Nf6 4.d4 cxd4 5.Nxd4, 3.Nf3 e5 4.g3 g6 5.Bg2 Bg7)").save!
    Opening.new(code: "A36", description: "English Opening, Symmetrical: 1...c5 2.Nc3 Nc6 3.g3 (without: 3...g6 4.Bg2 Bg7 5.Nf3 (A37-A39), 3...g6 4.Bg2 Bg7 5.Rb1 Nf6 6.d3 0-0 7.Nf3 d6 8.O-O (A38))").save!
    Opening.new(code: "A37", description: "English Opening, Symmetrical: 1...c5 2.Nc3 Nc6 3.g3 g6 4.Bg2 Bg7 5.Nf3 (without: 5...Nf6 (A38-A39))").save!
    Opening.new(code: "A38", description: "English Opening, Symmetrical: 1...c5 2.Nc3 Nc6 3.g3 g6 4.Bg2 Bg7 5.Nf3 Nf6 (without: 6.O-O O-O 7.d4 (A39) and 6.d4 cxd4 7.Nxd4 0-0 (A39))").save!
    Opening.new(code: "A39", description: "English Opening, Symmetrical, Main line with 1...c5 2.Nc3 Nc6 3.g3 g6 4.Bg2 Bg7 5.Nf3 Nf6 6.O-O O-O 7.d4 or 1...c5 2.Nc3 Nc6 3.g3 g6 4.Bg2 Bg7 5.Nf3 Nf6 6.d4 cxd4 7.Nd4 0-0 8.0-0").save!
    Opening.new(code: "A40", description: "Queen's Pawn Game (including English Defence, Englund Gambit, Queen's Knight Defence, Polish Defence and Keres Defence)").save!
    Opening.new(code: "A41", description: "Queen's Pawn Game, Wade Defence").save!
    Opening.new(code: "A42", description: "Modern Defence, Averbakh System also Wade Defence").save!
    Opening.new(code: "A43", description: "Old Benoni Defence").save!
    Opening.new(code: "A44", description: "Old Benoni Defence").save!
    Opening.new(code: "A45", description: "Queen's Pawn Game").save!
    Opening.new(code: "A46", description: "Queen's Pawn Game, Torre Attack").save!
    Opening.new(code: "A47", description: "Queen's Indian Defence").save!
    Opening.new(code: "A48", description: "King's Indian, East Indian Defence").save!
    Opening.new(code: "A49", description: "King's Indian, Fianchetto without c4").save!
    Opening.new(code: "A50", description: "Queen's Pawn Game, Black Knights' Tango").save!
    Opening.new(code: "A51", description: "Budapest Gambit declined").save!
    Opening.new(code: "A52", description: "Budapest Gambit").save!
    Opening.new(code: "A53", description: "Old Indian Defence (Chigorin Indian Defence)").save!
    Opening.new(code: "A54", description: "Old Indian, Ukrainian Variation").save!
    Opening.new(code: "A55", description: "Old Indian, Main line").save!
    Opening.new(code: "A56", description: "Benoni defence").save!
    Opening.new(code: "A57", description: "Benko Gambit").save!
    Opening.new(code: "A58", description: "Benko Gambit Accepted").save!
    Opening.new(code: "A59", description: "Benko Gambit, 7.e4").save!
    Opening.new(code: "A60", description: "Benoni defence").save!
    Opening.new(code: "A61", description: "Benoni defence").save!
    Opening.new(code: "A62", description: "Benoni, Fianchetto Variation without early ...Nbd7").save!
    Opening.new(code: "A63", description: "Benoni, Fianchetto Variation, 9...Nbd7").save!
    Opening.new(code: "A64", description: "Benoni, Fianchetto Variation, 11...Re8").save!
    Opening.new(code: "A65", description: "Benoni, 6.e4").save!
    Opening.new(code: "A66", description: "Benoni, Pawn Storm Variation").save!
    Opening.new(code: "A67", description: "Benoni, Taimanov Variation").save!
    Opening.new(code: "A68", description: "Benoni, Four Pawns Attack").save!
    Opening.new(code: "A69", description: "Benoni, Four Pawns Attack, Main line").save!
    Opening.new(code: "A70", description: "Benoni, Classical with e4 and Nf3").save!
    Opening.new(code: "A71", description: "Benoni, Classical, 8.Bg5").save!
    Opening.new(code: "A72", description: "Benoni, Classical without 9.0-0").save!
    Opening.new(code: "A73", description: "Benoni, Classical, 9.0-0").save!
    Opening.new(code: "A74", description: "Benoni, Classical, 9...a6, 10.a4").save!
    Opening.new(code: "A75", description: "Benoni, Classical with ...a6 and 10...Bg4").save!
    Opening.new(code: "A76", description: "Benoni, Classical, 9...Re8").save!
    Opening.new(code: "A77", description: "Benoni, Classical, 9...Re8, 10.Nd2").save!
    Opening.new(code: "A78", description: "Benoni, Classical with ...Re8 and ...Na6").save!
    Opening.new(code: "A79", description: "Benoni, Classical, 11.f3").save!
    Opening.new(code: "A80", description: "Dutch Defence (without 2.c4 (A84-A99), 2.e4 (A82-A83), 2.g3 (A81))").save!
    Opening.new(code: "A81", description: "Dutch Defence 2.g3").save!
    Opening.new(code: "A82", description: "Dutch, Staunton Gambit 2.e4").save!
    Opening.new(code: "A83", description: "Dutch, Staunton Gambit, Staunton's line 2.e4 fxe4 3.Nc3 Nf6 4.Bg5").save!
    Opening.new(code: "A84", description: "Dutch Defence 2.c4 (without 2...Nf6 3.Nc3 (A85), 2...Nf6 3.g3 (A86-A99))").save!
    Opening.new(code: "A85", description: "Dutch with 2.c4 Nf6 3.Nc3").save!
    Opening.new(code: "A86", description: "Dutch with 2.c4 Nf6 3.g3 (without 3...g6 4.Bg2 Bg7 5.Nf3 (A87) and 3...e6 4.Bg2 (A90-A99))").save!
    Opening.new(code: "A87", description: "Dutch, Leningrad, Main Variation 2.c4 Nf6 3.g3 g6 4.Bg2 Bg7 5.Nf3 (without 5...O-O 6.O-O d6 7.Nc3 c6 (A88) and 7...Nc6 (A89))").save!
    Opening.new(code: "A88", description: "Dutch, Leningrad, Main Variation with 5...O-O 6.O-O d6 7.Nc3 c6").save!
    Opening.new(code: "A89", description: "Dutch, Leningrad, Main Variation with 5...O-O 6.O-O d6 7.Nc3 Nc6").save!
    Opening.new(code: "A90", description: "Dutch Defence 2.c4 Nf6 3.g3 e6 4.Bg2 (without 4...Be7 (A91-A99))").save!
    Opening.new(code: "A91", description: "Dutch Defence 2.c4 Nf6 3.g3 e6 4.Bg2 Be7 (without 5.Nf3 (A92-A99))").save!
    Opening.new(code: "A92", description: "Dutch Defence 2.c4 Nf6 3.g3 e6 4.Bg2 Be7 5.Nf3 O-O (without 6.O-O (A93-A99))").save!
    Opening.new(code: "A93", description: "Dutch, Stonewall, Botvinnik Variation 2.c4 Nf6 3.g3 e6 4.Bg2 Be7 5.Nf3 O-O 6.O-O d5.7 b3 (without 7...c6 8.Ba3 (A94))").save!
    Opening.new(code: "A94", description: "Dutch, Stonewall with 6.O-O d5.7.b3 c6 8.Ba3").save!
    Opening.new(code: "A95", description: "Dutch, Stonewall with 6.O-O d5.7.Nc3 c6").save!
    Opening.new(code: "A96", description: "Dutch, Classical Variation 2.c4 Nf6 3.g3 e6 4.Bg2 Be7 5.Nf3 O-O 6.O-O d6 (without 7.Nc3 Qe8 (A97-A99))").save!
    Opening.new(code: "A97", description: "Dutch, Ilyin–Genevsky Variation 7.Nc3 Qe8 (without 8.Qc2 (A98) and 8.b3 (A99))").save!
    Opening.new(code: "A98", description: "Dutch, Ilyin–Genevsky Variation with 7.Nc3 Qe8 8.Qc2").save!
    Opening.new(code: "A99", description: "Dutch, Ilyin–Genevsky Variation with 7.Nc3 Qe8 8.b3").save!
    Opening.new(code: "B00", description: "King's Pawn Opening without 1...e5, 1...d5, 1...Nf6, 1...g6, 1...d6, 1...c6, 1...c5").save!
    Opening.new(code: "B01", description: "Scandinavian Defence (Center Counter Defence)").save!
    Opening.new(code: "B02", description: "Alekhine's Defence").save!
    Opening.new(code: "B03", description: "Alekhine's Defence 3.d4").save!
    Opening.new(code: "B04", description: "Alekhine's Defence, Modern Variation").save!
    Opening.new(code: "B05", description: "Alekhine's Defence, Modern Variation, 4...Bg4").save!
    Opening.new(code: "B06", description: "Robatsch (Modern) Defence, including Monkey's Bum").save!
    Opening.new(code: "B07", description: "Pirc Defence").save!
    Opening.new(code: "B08", description: "Pirc, Classical (Two Knights) System").save!
    Opening.new(code: "B09", description: "Pirc, Austrian attack").save!
    Opening.new(code: "B10", description: "Caro-Kann Defence").save!
    Opening.new(code: "B11", description: "Caro–Kann, Two knights, 3...Bg4").save!
    Opening.new(code: "B12", description: "Caro–Kann Defence").save!
    Opening.new(code: "B13", description: "Caro–Kann, Exchange Variation").save!
    Opening.new(code: "B14", description: "Caro–Kann, Panov–Botvinnik Attack, 5...e6").save!
    Opening.new(code: "B15", description: "Caro–Kann Defence").save!
    Opening.new(code: "B16", description: "Caro–Kann, Bronstein–Larsen Variation").save!
    Opening.new(code: "B17", description: "Caro–Kann, Steinitz Variation, Smyslov Systems").save!
    Opening.new(code: "B18", description: "Caro–Kann, Classical Variation").save!
    Opening.new(code: "B19", description: "Caro–Kann, Classical, 7...Nd7").save!
    Opening.new(code: "B20", description: "Sicilian Defence, (any move for white without 2.Nc3 (B23-B26), 2.c3 (B22), 2.d4 (B21), 2.f4 (B21) and 2.Nf3 (B27-B99))").save!
    Opening.new(code: "B21", description: "Sicilian, two line: 2.f4, 2.d4 (Grand Prix, Smith-Morra)").save!
    Opening.new(code: "B22", description: "Sicilian, Alapin Variation, 2.c3 (without 2...d6 3.Nf3 (C50), 2...e6 3.Nf3 d5 (B40), 2...e6 3.d4 d5 4.e5 (C02), 2...g6 3.Nf3 (B27))").save!
    Opening.new(code: "B23", description: "Sicilian, Closed, 2.Nc3 (without 2...a6 3.Nf3 (B28), 2...d6 3.Nf3 (B50), 2...Nc6 3.g3 (B24-B26))").save!
    Opening.new(code: "B24", description: "Sicilian, Closed, 2.Nc3 Nc6 3.g3 (without 3...g6 (B25-B26))").save!
    Opening.new(code: "B25", description: "Sicilian, Closed, 2.Nc3 Nc6 3.g3 g6 4.Bg2 Bg7 5.d3 d6 (without 6.Be3 (B26))").save!
    Opening.new(code: "B26", description: "Sicilian, Closed, 6.Be3").save!
    Opening.new(code: "B27", description: "Sicilian Defence, 2.Nf3 (without 2...a6 (B28), 2...Nc6 (B30), 2...d6 (B50), 2...e6 (B40), 2...Nf6 (B29))").save!
    Opening.new(code: "B28", description: "Sicilian, O'Kelly Variation, 2.Nf3 a6 (without 3.d4 cxd4 4.Nxd4 e6 (B41, B43))").save!
    Opening.new(code: "B29", description: "Sicilian, Nimzovich–Rubinstein Variation, 2.Nf3 Nf6 (without 3.e5 Nd5 4.c3 (B22), 3.Nc3 Nc6 (B30), 3.Nc3 d6 (B50), 3.d4 cxd4 4.Nd4 d6 (B54, B56, B94-B99))").save!
    Opening.new(code: "B30", description: "Sicilian Defence, 2.Nf3 Nc6 (without 3.Bb5 g6 (B31) 3.Bb5 d6 (B51))").save!
    Opening.new(code: "B31", description: "Sicilian, Nimzovich–Rossolimo Attack, 3.Bb5 g6").save!
    Opening.new(code: "B32", description: "Sicilian Defence, 2.Nf3 Nc6 3.d4 (without 3...cxd4 4.Nxd4 Nf6 (B33), 4...e6 (B44-B47) 4...g6 (B34))").save!
    Opening.new(code: "B33", description: "Sicilian, Sveshnikov (Lasker–Pelikan) Variation, 2.Nf3 Nc6 3.d4 cxd4 4.Nxd4 Nf6 (without 5.Nc3 e6 (B45) 5...g6 (B34) 5...d6 (B56))").save!
    Opening.new(code: "B34", description: "Sicilian, Accelerated Fianchetto, Exchange Variation, 2.Nf3 Nc6 3 d4.cxd4 4.Nxd4 g6 (without 5.c4 (B36), 5.Nc3 Bg7 6.Be3 Nf6 7.Bc4 (B35))").save!
    Opening.new(code: "B35", description: "Sicilian, Accelerated Fianchetto, Modern Variation with 2.Nf3 Nc6 3.d4 cxd4 4.Nxd4 g6 5.Nc3 Bg7 6.Be3 Nf6 7.Bc4 (without 7...b6 (B72, B75))").save!
    Opening.new(code: "B36", description: "Sicilian, Accelerated Fianchetto, Maroczy bind 2.Nf3 Nc6 3.d4 cxd4 4.Nxd4 g6 5.c4 (without 5...Bg7 (B37-B39))").save!
    Opening.new(code: "B37", description: "Sicilian, Accelerated Fianchetto, Maroczy bind, 5...Bg7 (without 6.Be3 (B38))").save!
    Opening.new(code: "B38", description: "Sicilian, Accelerated Fianchetto, Maroczy bind, 5...Bg7 6.Be3 (without 6...Nf6 7.Nc3 Ng4 (B39))").save!
    Opening.new(code: "B39", description: "Sicilian, Accelerated Fianchetto, Breyer Variation, 5...Bg7 6.Be3 Nf6 7.Nc3 Ng4").save!
    Opening.new(code: "B40", description: "Sicilian Defence, 2.Nf3 e6").save!
    Opening.new(code: "B41", description: "Sicilian, Kan Variation, 2.Nf3 e6 3.d4 cxd4 4.Nxd4 a6 (without 5.Bd3 (B42), 5.Nc3 (B43), 5.Be2 Nf6 6.Nc3 Qc7 (B43))").save!
    Opening.new(code: "B42", description: "Sicilian, Kan, 5.Bd3").save!
    Opening.new(code: "B43", description: "Sicilian, Kan, 5.Nc3").save!
    Opening.new(code: "B44", description: "Sicilian Defence, 2.Nf3 e6 3.d4 cxd4 4.Nd4 Nc6").save!
    Opening.new(code: "B45", description: "Sicilian, Taimanov Variation, 5.Nc3").save!
    Opening.new(code: "B46", description: "Sicilian, Taimanov Variation").save!
    Opening.new(code: "B47", description: "Sicilian, Taimanov (Bastrikov) variation").save!
    Opening.new(code: "B48", description: "Sicilian, Taimanov Variation").save!
    Opening.new(code: "B49", description: "Sicilian, Taimanov Variation").save!
    Opening.new(code: "B50", description: "Sicilian").save!
    Opening.new(code: "B51", description: "Sicilian, Canal–Sokolsky Attack").save!
    Opening.new(code: "B52", description: "Sicilian, Canal–Sokolsky Attack, 3...Bd7").save!
    Opening.new(code: "B53", description: "Sicilian, Chekhover Variation").save!
    Opening.new(code: "B54", description: "Sicilian").save!
    Opening.new(code: "B55", description: "Sicilian, Prins Variation, Venice Attack").save!
    Opening.new(code: "B56", description: "Sicilian").save!
    Opening.new(code: "B57", description: "Sicilian, Sozin (not Scheveningen) including Magnus Smith Trap").save!
    Opening.new(code: "B58", description: "Sicilian, Classical").save!
    Opening.new(code: "B59", description: "Sicilian, Boleslavsky Variation, 7.Nb3").save!
    Opening.new(code: "B60", description: "Sicilian, Richter-Rauzer").save!
    Opening.new(code: "B61", description: "Sicilian, Richter–Rauzer, Larsen Variation, 7.Qd2").save!
    Opening.new(code: "B62", description: "Sicilian, Richter–Rauzer, 6...e6").save!
    Opening.new(code: "B63", description: "Sicilian, Richter–Rauzer, Rauzer Attack").save!
    Opening.new(code: "B64", description: "Sicilian, Richter–Rauzer, Rauzer Attack, 7...Be7 defence, 9.f4").save!
    Opening.new(code: "B65", description: "Sicilian, Richter–Rauzer, Rauzer Attack, 7...Be7 defence, 9...Nxd4").save!
    Opening.new(code: "B66", description: "Sicilian, Richter–Rauzer, Rauzer Attack, 7...a6").save!
    Opening.new(code: "B67", description: "Sicilian, Richter–Rauzer, Rauzer Attack, 7...a6 defence, 8...Bd7").save!
    Opening.new(code: "B68", description: "Sicilian, Richter–Rauzer, Rauzer Attack, 7...a6 defence, 9...Be7").save!
    Opening.new(code: "B69", description: "Sicilian, Richter–Rauzer, Rauzer Attack, 7...a6 defence, 11.Bxf6").save!
    Opening.new(code: "B70", description: "Sicilian, Dragon Variation").save!
    Opening.new(code: "B71", description: "Sicilian, Dragon, Levenfish Variation").save!
    Opening.new(code: "B72", description: "Sicilian, Dragon, 6.Be3").save!
    Opening.new(code: "B73", description: "Sicilian, Dragon, Classical, 8.0-0").save!
    Opening.new(code: "B74", description: "Sicilian, Dragon, Classical, 9.Nb3").save!
    Opening.new(code: "B75", description: "Sicilian, Dragon, Yugoslav Attack").save!
    Opening.new(code: "B76", description: "Sicilian, Dragon, Yugoslav Attack, 7...0-0").save!
    Opening.new(code: "B77", description: "Sicilian, Dragon, Yugoslav Attack, 9.Bc4").save!
    Opening.new(code: "B78", description: "Sicilian, Dragon, Yugoslav Attack, 10.0-0-0").save!
    Opening.new(code: "B79", description: "Sicilian, Dragon, Yugoslav Attack, 12.h4").save!
    Opening.new(code: "B80", description: "Sicilian, Scheveningen, English Attack").save!
    Opening.new(code: "B81", description: "Sicilian, Scheveningen, Keres Attack").save!
    Opening.new(code: "B82", description: "Sicilian, Scheveningen, 6.f4").save!
    Opening.new(code: "B83", description: "Sicilian, Scheveningen, 6.Be2").save!
    Opening.new(code: "B84", description: "Sicilian, Scheveningen (Paulsen), Classical Variation").save!
    Opening.new(code: "B85", description: "Sicilian, Scheveningen, Classical Variation with ...Qc7 and ...Nc6").save!
    Opening.new(code: "B86", description: "Sicilian, Sozin Attack").save!
    Opening.new(code: "B87", description: "Sicilian, Sozin with ...a6 and ...b5").save!
    Opening.new(code: "B88", description: "Sicilian, Sozin, Leonhardt Variation").save!
    Opening.new(code: "B89", description: "Sicilian, Sozin, 7.Be3").save!
    Opening.new(code: "B90", description: "Sicilian, Najdorf").save!
    Opening.new(code: "B91", description: "Sicilian, Najdorf, Zagreb (Fianchetto) Variation (6.g3)").save!
    Opening.new(code: "B92", description: "Sicilian, Najdorf, Opocensky Variation (6.Be2)").save!
    Opening.new(code: "B93", description: "Sicilian, Najdorf, 6.f4").save!
    Opening.new(code: "B94", description: "Sicilian, Najdorf, 6.Bg5").save!
    Opening.new(code: "B95", description: "Sicilian, Najdorf, 6...e6").save!
    Opening.new(code: "B96", description: "Sicilian, Najdorf, 7.f4").save!
    Opening.new(code: "B97", description: "Sicilian, Najdorf, 7...Qb6 including Poisoned Pawn Variation").save!
    Opening.new(code: "B98", description: "Sicilian, Najdorf, 7...Be7").save!
    Opening.new(code: "B99", description: "Sicilian, Najdorf, 7...Be7 Main line").save!
    Opening.new(code: "C00", description: "French Defence").save!
    Opening.new(code: "C01", description: "French, Exchange Variation").save!
    Opening.new(code: "C02", description: "French, Advance Variation").save!
    Opening.new(code: "C03", description: "French, Tarrasch").save!
    Opening.new(code: "C04", description: "French, Tarrasch, Guimard Main line").save!
    Opening.new(code: "C05", description: "French, Tarrasch, Closed Variation").save!
    Opening.new(code: "C06", description: "French, Tarrasch, Closed Variation, Main line").save!
    Opening.new(code: "C07", description: "French, Tarrasch, Open Variation").save!
    Opening.new(code: "C08", description: "French, Tarrasch, Open, 4.exd5 exd5").save!
    Opening.new(code: "C09", description: "French, Tarrasch, Open Variation, Main line").save!
    Opening.new(code: "C10", description: "French, Paulsen Variation").save!
    Opening.new(code: "C11", description: "French Defence").save!
    Opening.new(code: "C12", description: "French, MacCutcheon Variation").save!
    Opening.new(code: "C13", description: "French, Classical").save!
    Opening.new(code: "C14", description: "French, Classical Variation").save!
    Opening.new(code: "C15", description: "French, Winawer (Nimzovich) Variation").save!
    Opening.new(code: "C16", description: "French, Winawer, Advance Variation").save!
    Opening.new(code: "C17", description: "French, Winawer, Advance Variation").save!
    Opening.new(code: "C18", description: "French, Winawer, Advance Variation").save!
    Opening.new(code: "C19", description: "French, Winawer, Advance, 6...Ne7").save!
    Opening.new(code: "C20", description: "King's Pawn Game (includes Alapin's Opening, Lopez Opening, Napoleon Opening, Portuguese Opening and Wayward Queen Attack)").save!
    Opening.new(code: "C21", description: "Center Game (includes Danish Gambit)").save!
    Opening.new(code: "C22", description: "Center Game").save!
    Opening.new(code: "C23", description: "Bishop's Opening").save!
    Opening.new(code: "C24", description: "Bishop's Opening, Berlin Defence").save!
    Opening.new(code: "C25", description: "Vienna Game").save!
    Opening.new(code: "C26", description: "Vienna Game, Falkbeer Variation").save!
    Opening.new(code: "C27", description: "Vienna Game, Frankenstein-Dracula Variation").save!
    Opening.new(code: "C28", description: "Vienna Game").save!
    Opening.new(code: "C29", description: "Vienna Gambit, Kaufmann Variation including Würzburger Trap").save!
    Opening.new(code: "C30", description: "King's Gambit").save!
    Opening.new(code: "C31", description: "King's Gambit Declined, Falkbeer and Nimzowitsch (3....c6) Countergambits").save!
    Opening.new(code: "C32", description: "King's Gambit Declined, Falkbeer, 5.dxe4").save!
    Opening.new(code: "C33", description: "King's Gambit Accepted").save!
    Opening.new(code: "C34", description: "King's Gambit Accepted, including Fischer Defence").save!
    Opening.new(code: "C35", description: "King's Gambit Accepted, Cunningham Defence").save!
    Opening.new(code: "C36", description: "King's Gambit Accepted, Abbazia Defence (Classical Defence, Modern Defence)").save!
    Opening.new(code: "C37", description: "King's Gambit Accepted, Quaade Gambit").save!
    Opening.new(code: "C38", description: "King's Gambit Accepted").save!
    Opening.new(code: "C39", description: "King's Gambit Accepted, Allgaier and Kieseritsky Gambits including Rice Gambit").save!
    Opening.new(code: "C40", description: "King's Knight Opening (includes Gunderam Defence, Greco Defence, Damiano Defence, Elephant Gambit, and Latvian Gambit.)").save!
    Opening.new(code: "C41", description: "Philidor Defence").save!
    Opening.new(code: "C42", description: "Petrov's Defence, including Marshall Trap").save!
    Opening.new(code: "C43", description: "Petrov's Defence, Modern (Steinitz) Attack").save!
    Opening.new(code: "C44", description: "King's Pawn Game (includes Ponziani Opening, Inverted Hungarian Opening, Irish Gambit, Konstantinopolsky Opening and some Scotch Game)").save!
    Opening.new(code: "C45", description: "Scotch Game").save!
    Opening.new(code: "C46", description: "Three Knights Game including Halloween Gambit").save!
    Opening.new(code: "C47", description: "Four Knights Game").save!
    Opening.new(code: "C48", description: "Four Knights Game, Spanish Variation").save!
    Opening.new(code: "C49", description: "Four Knights Game, Double Ruy Lopez").save!
    Opening.new(code: "C50", description: "King's Pawn Game (includes Blackburne Shilling Gambit, Hungarian Defence, Semi-Italian Opening, Italian Gambit, Légal Trap, Rousseau Gambit and Giuoco Pianissimo)").save!
    Opening.new(code: "C51", description: "Evans Gambit").save!
    Opening.new(code: "C52", description: "Evans Gambit with 4...Bxb4 5.c3 Ba5").save!
    Opening.new(code: "C53", description: "Giuoco Piano").save!
    Opening.new(code: "C54", description: "Giuoco Piano").save!
    Opening.new(code: "C55", description: "Two Knights Defence").save!
    Opening.new(code: "C56", description: "Two Knights Defence").save!
    Opening.new(code: "C57", description: "Two Knights Defence, including the Fried Liver Attack").save!
    Opening.new(code: "C58", description: "Two Knights Defence").save!
    Opening.new(code: "C59", description: "Two Knights Defence").save!
    Opening.new(code: "C60", description: "Ruy Lopez Unusual Black 3rd moves and 3...g6").save!
    Opening.new(code: "C61", description: "Ruy Lopez, Bird's Defence").save!
    Opening.new(code: "C62", description: "Ruy Lopez, Old Steinitz Defence").save!
    Opening.new(code: "C63", description: "Ruy Lopez, Schliemann Defence").save!
    Opening.new(code: "C64", description: "Ruy Lopez, Classical (Cordel) Defence").save!
    Opening.new(code: "C65", description: "Ruy Lopez, Berlin Defence including Mortimer Trap").save!
    Opening.new(code: "C66", description: "Ruy Lopez, Berlin Defence, 4.0-0 d6").save!
    Opening.new(code: "C67", description: "Ruy Lopez, Berlin Defence, Open Variation").save!
    Opening.new(code: "C68", description: "Ruy Lopez, Exchange Variation").save!
    Opening.new(code: "C69", description: "Ruy Lopez, Exchange Variation, 5.0-0").save!
    Opening.new(code: "C70", description: "Ruy Lopez").save!
    Opening.new(code: "C71", description: "Ruy Lopez, Modern Steinitz Defence including Noah's Ark Trap").save!
    Opening.new(code: "C72", description: "Ruy Lopez, Modern Steinitz Defence 5.0-0").save!
    Opening.new(code: "C73", description: "Ruy Lopez, Modern Steinitz Defence, Richter Variation").save!
    Opening.new(code: "C74", description: "Ruy Lopez, Modern Steinitz Defence").save!
    Opening.new(code: "C75", description: "Ruy Lopez, Modern Steinitz Defence").save!
    Opening.new(code: "C76", description: "Ruy Lopez, Modern Steinitz Defence, Fianchetto (Bronstein) Variation").save!
    Opening.new(code: "C77", description: "Ruy Lopez, Morphy Defence").save!
    Opening.new(code: "C78", description: "Ruy Lopez, 5.0-0").save!
    Opening.new(code: "C79", description: "Ruy Lopez, Steinitz Defence Deferred (Russian Defence)").save!
    Opening.new(code: "C80", description: "Ruy Lopez, Open (Tarrasch) Defence").save!
    Opening.new(code: "C81", description: "Ruy Lopez, Open, Howell Attack").save!
    Opening.new(code: "C82", description: "Ruy Lopez, Open, 9.c3").save!
    Opening.new(code: "C83", description: "Ruy Lopez, Open, Classical Defence").save!
    Opening.new(code: "C84", description: "Ruy Lopez, Closed Defence").save!
    Opening.new(code: "C85", description: "Ruy Lopez, Exchange Variation Doubly Deferred (DERLD)").save!
    Opening.new(code: "C86", description: "Ruy Lopez, Worrall Attack").save!
    Opening.new(code: "C87", description: "Ruy Lopez, Closed, Averbakh Variation").save!
    Opening.new(code: "C88", description: "Ruy Lopez, Closed").save!
    Opening.new(code: "C89", description: "Ruy Lopez, Marshall Counterattack").save!
    Opening.new(code: "C90", description: "Ruy Lopez, Closed, 7...d6").save!
    Opening.new(code: "C91", description: "Ruy Lopez, Closed, 9.d4").save!
    Opening.new(code: "C92", description: "Ruy Lopez, Closed, 9.h3 (Zaitsev Variation)").save!
    Opening.new(code: "C93", description: "Ruy Lopez, Closed, Smyslov Defence").save!
    Opening.new(code: "C94", description: "Ruy Lopez, Closed, Breyer Defence, 10.d3").save!
    Opening.new(code: "C95", description: "Ruy Lopez, Closed, Breyer Defence, 10.d4").save!
    Opening.new(code: "C96", description: "Ruy Lopez, Closed, 8...Na5").save!
    Opening.new(code: "C97", description: "Ruy Lopez, Closed, Chigorin Defence").save!
    Opening.new(code: "C98", description: "Ruy Lopez, Closed, Chigorin, 12...Nc6").save!
    Opening.new(code: "C99", description: "Ruy Lopez, Closed, Chigorin, 12...cxd4").save!
    Opening.new(code: "D00", description: "Queen's Pawn Game (including Blackmar–Diemer Gambit, Halosar Trap and others)").save!
    Opening.new(code: "D01", description: "Richter–Veresov Attack").save!
    Opening.new(code: "D02", description: "Queen's Pawn Game, 2.Nf3").save!
    Opening.new(code: "D03", description: "Torre Attack, Tartakower Variation").save!
    Opening.new(code: "D04", description: "Queen's Pawn Game, Colle System").save!
    Opening.new(code: "D05", description: "Queen's Pawn Game, Zukertort Variation (including Colle System)").save!
    Opening.new(code: "D06", description: "Queen's Gambit (including Baltic, Marshall and Symmetrical Defences)").save!
    Opening.new(code: "D07", description: "QGD; Chigorin Defence").save!
    Opening.new(code: "D08", description: "QGD; Albin Countergambit and Lasker Trap").save!
    Opening.new(code: "D09", description: "QGD; Albin Countergambit, 5.g3").save!
    Opening.new(code: "D10", description: "QGD; Slav Defence").save!
    Opening.new(code: "D11", description: "QGD; Slav Defence, 3.Nf3").save!
    Opening.new(code: "D12", description: "QGD; Slav Defence, 4.e3 Bf5").save!
    Opening.new(code: "D13", description: "QGD; Slav Defence, Exchange Variation").save!
    Opening.new(code: "D14", description: "QGD; Slav Defence, Exchange Variation").save!
    Opening.new(code: "D15", description: "QGD; Slav, 4.Nc3").save!
    Opening.new(code: "D16", description: "QGD; Slav accepted, Alapin Variation").save!
    Opening.new(code: "D17", description: "QGD; Slav Defence, Czech Defence").save!
    Opening.new(code: "D18", description: "QGD; Dutch Variation").save!
    Opening.new(code: "D19", description: "QGD; Dutch Variation").save!
    Opening.new(code: "D20", description: "Queen's Gambit Accepted").save!
    Opening.new(code: "D21", description: "QGA, 3.Nf3").save!
    Opening.new(code: "D22", description: "QGA; Alekhine Defence").save!
    Opening.new(code: "D23", description: "Queen's Gambit Accepted").save!
    Opening.new(code: "D24", description: "QGA, 4.Nc3").save!
    Opening.new(code: "D25", description: "QGA, 4.e3").save!
    Opening.new(code: "D26", description: "QGA; Classical Variation").save!
    Opening.new(code: "D27", description: "QGA; Classical Variation").save!
    Opening.new(code: "D28", description: "QGA; Classical Variation 7.Qe2").save!
    Opening.new(code: "D29", description: "QGA; Classical Variation 8...Bb7").save!
    Opening.new(code: "D30", description: "Queen's Gambit Declined: Orthodox Defence").save!
    Opening.new(code: "D31", description: "QGD, 3.Nc3").save!
    Opening.new(code: "D32", description: "QGD; Tarrasch Defence").save!
    Opening.new(code: "D33", description: "QGD; Tarrasch, Schlechter–Rubinstein System").save!
    Opening.new(code: "D34", description: "QGD; Tarrasch, 7...Be7").save!
    Opening.new(code: "D35", description: "QGD; Exchange Variation").save!
    Opening.new(code: "D36", description: "QGD; Exchange, positional line, 6.Qc2").save!
    Opening.new(code: "D37", description: "QGD; 4.Nf3").save!
    Opening.new(code: "D38", description: "QGD; Ragozin Variation").save!
    Opening.new(code: "D39", description: "QGD; Ragozin, Vienna Variation").save!
    Opening.new(code: "D40", description: "QGD; Semi-Tarrasch Defence").save!
    Opening.new(code: "D41", description: "QGD; Semi-Tarrasch, 5.cxd5").save!
    Opening.new(code: "D42", description: "QGD; Semi-Tarrasch, 7.Bd3").save!
    Opening.new(code: "D43", description: "QGD; Semi-Slav Defence").save!
    Opening.new(code: "D44", description: "QGD; Semi-Slav 5.Bg5 dxc4").save!
    Opening.new(code: "D45", description: "QGD; Semi-Slav 5.e3").save!
    Opening.new(code: "D46", description: "QGD; Semi-Slav 6.Bd3").save!
    Opening.new(code: "D47", description: "QGD; Semi-Slav 7.Bc4").save!
    Opening.new(code: "D48", description: "QGD; Meran, 8...a6").save!
    Opening.new(code: "D49", description: "QGD; Meran, 11.Nxb5").save!
    Opening.new(code: "D50", description: "QGD; 4.Bg5").save!
    Opening.new(code: "D51", description: "QGD; 4.Bg5 Nbd7 (Cambridge Springs Defence and Elephant Trap)").save!
    Opening.new(code: "D52", description: "QGD").save!
    Opening.new(code: "D53", description: "QGD; 4.Bg5 Be7").save!
    Opening.new(code: "D54", description: "QGD; Anti-neo-Orthodox Variation").save!
    Opening.new(code: "D55", description: "QGD; 6.Nf3").save!
    Opening.new(code: "D56", description: "QGD; Lasker Defence").save!
    Opening.new(code: "D57", description: "QGD; Lasker Defence, Main line").save!
    Opening.new(code: "D58", description: "QGD; Tartakower (Tartakower–Makogonov–Bondarevsky) System").save!
    Opening.new(code: "D59", description: "QGD; Tartakower (Tartakower–Makogonov–Bondarevsky) System, 8.cxd5 Nxd5").save!
    Opening.new(code: "D60", description: "QGD; Orthodox Defence").save!
    Opening.new(code: "D61", description: "QGD; Orthodox Defence, Rubinstein Variation").save!
    Opening.new(code: "D62", description: "QGD; Orthodox Defence, 7.Qc2 c5, 8.cxd5 (Rubinstein)").save!
    Opening.new(code: "D63", description: "QGD; Orthodox Defence, 7.Rc1").save!
    Opening.new(code: "D64", description: "QGD; Orthodox Defence, Rubinstein Attack (with Rc1)").save!
    Opening.new(code: "D65", description: "QGD; Orthodox Defence, Rubinstein Attack, Main line").save!
    Opening.new(code: "D66", description: "QGD; Orthodox Defence, Bd3 line including Rubinstein Trap").save!
    Opening.new(code: "D67", description: "QGD; Orthodox Defence, Bd3 line, Capablanca freeing manoeuvre").save!
    Opening.new(code: "D68", description: "QGD; Orthodox Defence, Classical Variation").save!
    Opening.new(code: "D69", description: "QGD; Orthodox Defence, Classical, 13.dxe5").save!
    Opening.new(code: "D70", description: "Neo-Grünfeld Defence").save!
    Opening.new(code: "D71", description: "Neo-Grünfeld, 5.cxd5").save!
    Opening.new(code: "D72", description: "Neo-Grünfeld, 5.cxd5, Main line").save!
    Opening.new(code: "D73", description: "Neo-Grünfeld, 5.Nf3").save!
    Opening.new(code: "D74", description: "Neo-Grünfeld, 6.cxd5 Nxd5, 7.0-0").save!
    Opening.new(code: "D75", description: "Neo-Grünfeld, 6.cxd5 Nxd5, 7.0-0 c5, 8.Nc3").save!
    Opening.new(code: "D76", description: "Neo-Grünfeld, 6.cxd5 Nxd5, 7.0-0 Nb6").save!
    Opening.new(code: "D77", description: "Neo-Grünfeld, 6.0-0").save!
    Opening.new(code: "D78", description: "Neo-Grünfeld, 6.0-0 c6").save!
    Opening.new(code: "D79", description: "Neo-Grünfeld, 6.0-0, Main line").save!
    Opening.new(code: "D80", description: "Grünfeld Defence").save!
    Opening.new(code: "D81", description: "Grünfeld; Russian Variation").save!
    Opening.new(code: "D82", description: "Grünfeld 4.Bf4").save!
    Opening.new(code: "D83", description: "Grünfeld Gambit").save!
    Opening.new(code: "D84", description: "Grünfeld Gambit accepted").save!
    Opening.new(code: "D85", description: "Grünfeld, Nadanian Variation").save!
    Opening.new(code: "D86", description: "Grünfeld, Exchange, Classical Variation").save!
    Opening.new(code: "D87", description: "Grünfeld, Exchange, Spassky Variation").save!
    Opening.new(code: "D88", description: "Grünfeld, Spassky Variation, Main line, 10...cxd4, 11.cxd4").save!
    Opening.new(code: "D89", description: "Grünfeld, Spassky Variation, Main line, 13.Bd3").save!
    Opening.new(code: "D90", description: "Grünfeld, Three Knights Variation").save!
    Opening.new(code: "D91", description: "Grünfeld, Three Knights Variation").save!
    Opening.new(code: "D92", description: "Grünfeld, 5.Bf4").save!
    Opening.new(code: "D93", description: "Grünfeld with 5.Bf4 0-0 6.e3").save!
    Opening.new(code: "D94", description: "Grünfeld, 5.e3").save!
    Opening.new(code: "D95", description: "Grünfeld with 5.e3 0-0 6.Qb3").save!
    Opening.new(code: "D96", description: "Grünfeld, Russian Variation").save!
    Opening.new(code: "D97", description: "Grünfeld, Russian Variation with 7.e4").save!
    Opening.new(code: "D98", description: "Grünfeld, Russian, Smyslov Variation").save!
    Opening.new(code: "D99", description: "Grünfeld Defence, Smyslov, Main line").save!
    Opening.new(code: "E00", description: "Queen's Pawn Game (including Neo-Indian and Trompowsky Attacks)").save!
    Opening.new(code: "E01", description: "Catalan, Closed").save!
    Opening.new(code: "E02", description: "Catalan, open, 5.Qa4").save!
    Opening.new(code: "E03", description: "Catalan, open, Alekhine Variation").save!
    Opening.new(code: "E04", description: "Catalan, Open, 5.Nf3").save!
    Opening.new(code: "E05", description: "Catalan, Open, Classical line").save!
    Opening.new(code: "E06", description: "Catalan, Closed, 5.Nf3").save!
    Opening.new(code: "E07", description: "Catalan, Closed, 6...Nbd7").save!
    Opening.new(code: "E08", description: "Catalan, Closed, 7.Qc2").save!
    Opening.new(code: "E09", description: "Catalan, Closed, Main line").save!
    Opening.new(code: "E10", description: "Queen's Pawn Game 3.Nf3").save!
    Opening.new(code: "E11", description: "Bogo-Indian Defence").save!
    Opening.new(code: "E12", description: "Queen's Indian Defence").save!
    Opening.new(code: "E13", description: "Queen's Indian, 4.Nc3, Main line").save!
    Opening.new(code: "E14", description: "Queen's Indian, 4.e3").save!
    Opening.new(code: "E15", description: "Queen's Indian, 4.g3").save!
    Opening.new(code: "E16", description: "Queen's Indian, Capablanca Variation").save!
    Opening.new(code: "E17", description: "Queen's Indian, 5.Bg2 Be7").save!
    Opening.new(code: "E18", description: "Queen's Indian, Old Main line, 7.Nc3").save!
    Opening.new(code: "E19", description: "Queen's Indian, Old Main line, 9.Qxc3").save!
    Opening.new(code: "E20", description: "Nimzo-Indian Defence").save!
    Opening.new(code: "E21", description: "Nimzo-Indian, Three Knights Variation").save!
    Opening.new(code: "E22", description: "Nimzo-Indian, Spielmann Variation").save!
    Opening.new(code: "E23", description: "Nimzo-Indian, Spielmann, 4...c5, 5.dxc5 Nc6").save!
    Opening.new(code: "E24", description: "Nimzo-Indian, Sämisch Variation").save!
    Opening.new(code: "E25", description: "Nimzo-Indian, Sämisch Variation, Keres Variation").save!
    Opening.new(code: "E26", description: "Nimzo-Indian, Sämisch Variation, 4.a3 Bxc3+ 5.bxc3 c5 6.e3").save!
    Opening.new(code: "E27", description: "Nimzo-Indian, Sämisch Variation, 5...0-0").save!
    Opening.new(code: "E28", description: "Nimzo-Indian, Sämisch Variation, 6.e3").save!
    Opening.new(code: "E29", description: "Nimzo-Indian, Sämisch Variation, Main line").save!
    Opening.new(code: "E30", description: "Nimzo-Indian, Leningrad Variation,").save!
    Opening.new(code: "E31", description: "Nimzo-Indian, Leningrad Variation, Main line").save!
    Opening.new(code: "E32", description: "Nimzo-Indian, Classical Variation (4.Qc2)").save!
    Opening.new(code: "E33", description: "Nimzo-Indian, Classical Variation, 4...Nc6").save!
    Opening.new(code: "E34", description: "Nimzo-Indian, Classical, Noa Variation (4...d5)").save!
    Opening.new(code: "E35", description: "Nimzo-Indian, Classical, Noa Variation, 5.cxd5 exd5").save!
    Opening.new(code: "E36", description: "Nimzo-Indian, Classical, Noa Variation, 5.a3").save!
    Opening.new(code: "E37", description: "Nimzo-Indian, Classical, Noa Variation, Main line, 7.Qc2").save!
    Opening.new(code: "E38", description: "Nimzo-Indian, Classical, 4...c5").save!
    Opening.new(code: "E39", description: "Nimzo-Indian, Classical, Pirc Variation").save!
    Opening.new(code: "E40", description: "Nimzo-Indian, 4.e3").save!
    Opening.new(code: "E41", description: "Nimzo-Indian, 4.e3 c5 5.Bd3 Nc6 6.Nf3 Bxc3+ 7.bxc3 d6 (Hübner Variation)").save!
    Opening.new(code: "E42", description: "Nimzo-Indian, 4.e3 c5 5.Ne2 (Rubinstein)").save!
    Opening.new(code: "E43", description: "Nimzo-Indian, Fischer Variation").save!
    Opening.new(code: "E44", description: "Nimzo-Indian, Fischer Variation, 5.Ne2").save!
    Opening.new(code: "E45", description: "Nimzo-Indian, 4.e3, Bronstein (Byrne) Variation").save!
    Opening.new(code: "E46", description: "Nimzo-Indian, 4.e3 0-0").save!
    Opening.new(code: "E47", description: "Nimzo-Indian, 4.e3 0-0, 5.Bd3").save!
    Opening.new(code: "E48", description: "Nimzo-Indian, 4.e3 0-0, 5.Bd3 d5").save!
    Opening.new(code: "E49", description: "Nimzo-Indian, 4.e3, Botvinnik System").save!
    Opening.new(code: "E50", description: "Nimzo-Indian, 4.e3 0-0, 5.Nf3, without ...d5").save!
    Opening.new(code: "E51", description: "Nimzo-Indian, 4.e3 0-0, 5.Nf3 d5").save!
    Opening.new(code: "E52", description: "Nimzo-Indian, 4.e3, Main line with ...b6").save!
    Opening.new(code: "E53", description: "Nimzo-Indian, 4.e3, Main line with ...c5").save!
    Opening.new(code: "E54", description: "Nimzo-Indian, 4.e3, Gligoric System with 7...dxc4").save!
    Opening.new(code: "E55", description: "Nimzo-Indian, 4.e3, Gligoric System, Bronstein Variation").save!
    Opening.new(code: "E56", description: "Nimzo-Indian, 4.e3, Main line with 7...Nc6").save!
    Opening.new(code: "E57", description: "Nimzo-Indian, 4.e3, Main line with 8...dxc4 and 9...Bxc4 cxd4").save!
    Opening.new(code: "E58", description: "Nimzo-Indian, 4.e3, Main line with 8...Bxc3").save!
    Opening.new(code: "E59", description: "Nimzo-Indian, 4.e3, Main line").save!
    Opening.new(code: "E60", description: "King's Indian Defence").save!
    Opening.new(code: "E61", description: "King's Indian Defence, 3.Nc3").save!
    Opening.new(code: "E62", description: "King's Indian, Fianchetto Variation").save!
    Opening.new(code: "E63", description: "King's Indian, Fianchetto, Panno Variation").save!
    Opening.new(code: "E64", description: "King's Indian, Fianchetto, Yugoslav System").save!
    Opening.new(code: "E65", description: "King's Indian, Yugoslav, 7.0-0").save!
    Opening.new(code: "E66", description: "King's Indian, Fianchetto, Yugoslav Panno").save!
    Opening.new(code: "E67", description: "King's Indian, Fianchetto with ...Nd7").save!
    Opening.new(code: "E68", description: "King's Indian, Fianchetto, Classical Variation, 8.e4").save!
    Opening.new(code: "E69", description: "King's Indian, Fianchetto, Classical Main line").save!
    Opening.new(code: "E70", description: "King's Indian, 4.e4").save!
    Opening.new(code: "E71", description: "King's Indian, Makogonov System (5.h3)").save!
    Opening.new(code: "E72", description: "King's Indian with e4 and g3").save!
    Opening.new(code: "E73", description: "King's Indian, 5.Be2").save!
    Opening.new(code: "E74", description: "King's Indian, Averbakh, 6...c5").save!
    Opening.new(code: "E75", description: "King's Indian, Averbakh, Main line").save!
    Opening.new(code: "E76", description: "King's Indian, Four Pawns Attack").save!
    Opening.new(code: "E77", description: "King's Indian, Four Pawns Attack, 6.Be2").save!
    Opening.new(code: "E78", description: "King's Indian, Four Pawns Attack, with Be2 and Nf3").save!
    Opening.new(code: "E79", description: "King's Indian, Four Pawns Attack, Main line").save!
    Opening.new(code: "E80", description: "King's Indian, Sämisch Variation").save!
    Opening.new(code: "E81", description: "King's Indian, Sämisch, 5...0-0").save!
    Opening.new(code: "E82", description: "King's Indian, Sämisch, Double Fianchetto Variation").save!
    Opening.new(code: "E83", description: "King's Indian, Sämisch, 6...Nc6 (Panno Variation)").save!
    Opening.new(code: "E84", description: "King's Indian, Sämisch, Panno Main line").save!
    Opening.new(code: "E85", description: "King's Indian, Sämisch, Orthodox Variation").save!
    Opening.new(code: "E86", description: "King's Indian, Sämisch, Orthodox, 7.Nge2 c6").save!
    Opening.new(code: "E87", description: "King's Indian, Sämisch, Orthodox, 7.d5").save!
    Opening.new(code: "E88", description: "King's Indian, Sämisch, Orthodox, 7.d5 c6").save!
    Opening.new(code: "E89", description: "King's Indian, Sämisch, Orthodox Main line").save!
    Opening.new(code: "E90", description: "King's Indian, 5.Nf3").save!
    Opening.new(code: "E91", description: "King's Indian, 6.Be2").save!
    Opening.new(code: "E92", description: "King's Indian, Classical Variation").save!
    Opening.new(code: "E93", description: "King's Indian, Petrosian System, Main line").save!
    Opening.new(code: "E94", description: "King's Indian, Orthodox Variation").save!
    Opening.new(code: "E95", description: "King's Indian, Orthodox, 7...Nbd7, 8.Re1").save!
    Opening.new(code: "E96", description: "King's Indian, Orthodox, 7...Nbd7, Main line").save!
    Opening.new(code: "E97", description: "King's Indian, Orthodox, Aronin–Taimanov Variation (Yugoslav Attack / Mar del Plata Variation)").save!
    Opening.new(code: "E98", description: "King's Indian, Orthodox, Aronin–Taimanov, 9.Ne1").save!
    Opening.new(code: "E99", description: "King's Indian, Orthodox, Aronin–Taimanov, Main").save!
  end
end
