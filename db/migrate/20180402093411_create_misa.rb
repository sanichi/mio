class CreateMisa < ActiveRecord::Migration[5.1]
  def change
    create_table :misas do |t|
      t.string   :category, limit: Misa::MAX_CATEGORY, default: "none"
      t.boolean  :japanese, default: false
      t.string   :minutes, limit: Misa::MAX_MINUTES
      t.text     :note
      t.string   :short, limit: Misa::MAX_SHORT
      t.string   :title, limit: Misa::MAX_TITLE

      t.timestamps null: false
    end

    Misa.new(short: "eInkgfRZ7-M", japanese: false, minutes: "30:56", title: "What does 'By no MEANS are you MEANT to MEAN it, you MEANY.' MEAN in Japanese?").save!
    Misa.new(short: "hv4z_7bEIX0", japanese: true,  minutes:  "4:28", title: "Vlog : Toronto to Montreal").save!
    Misa.new(short: "MNyxSjdoRQg", japanese: true,  minutes:  "5:45", title: "Talking about hobbies").save!
    Misa.new(short: "UneYOL0DQxk", japanese: false, minutes: "14:12", title: "#1 は and です Japanese Grammar Lesson for Absolute Beginners").save!
    Misa.new(short: "uBkGTniizTA", japanese: false, minutes:  "2:50", title: "Can't be bothered / A pain in the neck / Hassle in Japanese").save!
    Misa.new(short: "jxTg8VTHp8E", japanese: false, minutes:  "3:36", title: "How to say series : picky and nitpicker in Japanese").save!
    Misa.new(short: "S-PWsxeHyZo", japanese: true,  minutes:  "5:44", title: "Talking about Health").save!
    Misa.new(short: "tecppGPsaPg", japanese: false, minutes: "16:01", title: "#2 Japanese Lesson for Absolute Beginners : This / That + adjectives これ / それ / あれ").save!
    Misa.new(short: "Y6OxSpzRM-o", japanese: false, minutes: "14:06", title: "#3 Noun Negation - Japanese Lesson for Absolute Beginners").save!
    Misa.new(short: "pqkEblIwSoA", japanese: false, minutes: "10:38", title: "#4 Japanese Lesson for Absolute Beginners - I and NA adjectives").save!
    Misa.new(short: "4zGXK6pE5fc", japanese: true,  minutes:  "4:08", title: "Otaku culture and Steins; Gate").save!
    Misa.new(short: "UmqDpm0dJeI", japanese: true,  minutes:  "2:50", title: "Japanese Game - Magical Banana").save!
    Misa.new(short: "pcawLiCtw-s", japanese: true,  minutes:  "0:50", title: "Japanese Vocabulary - #1 The 30 day DAJARE Challenge").save!
    Misa.new(short: "m5szhZgsrBU", japanese: false, minutes:  "0:50", title: "Japanese Vocabulary - #2 The 30 day DAJARE Challenge").save!
    Misa.new(short: "RCVehIMPDg8", japanese: true,  minutes:  "3:16", title: "Christmas in Japan!").save!
    Misa.new(short: "IP-8m2LyHTQ", japanese: false, minutes:  "0:48", title: "Japanese Vocabulary - #3 The 30 day DAJARE Challenge").save!
    Misa.new(short: "m6xP4RNawtM", japanese: false, minutes:  "0:47", title: "Japanese Vocabulary - #4 The 30 day DAJARE Challenge").save!
    Misa.new(short: "UtIJvxxZJbA", japanese: false, minutes: "10:54", title: "#5 Japanese Lesson for Absolute Beginners - Negative Adjectives").save!
    Misa.new(short: "SMptw45RQWU", japanese: false, minutes:  "0:49", title: "Japanese Vocabulary - #5 The 30 day DAJARE Challenge").save!
    Misa.new(short: "3iHlfxmHjoc", japanese: false, minutes:  "0:48", title: "Japanese Vocabulary - #6 The 30 day DAJARE Challenge").save!
    Misa.new(short: "3Rl3kfMY85Q", japanese: false, minutes:  "0:34", title: "Japanese Vocabulary - #7 The 30 day DAJARE Challenge").save!
    Misa.new(short: "5_woSKucmUg", japanese: false, minutes: "16:38", title: "#6 Japanese Lesson for Absolute Beginners -Adjectives Past and Past Negatives").save!
    Misa.new(short: "l8CgzJyz-Do", japanese: false, minutes:  "0:45", title: "Japanese Vocabulary - #8 The 30 day DAJARE Challenge").save!
    Misa.new(short: "3BqfSiojHvo", japanese: true,  minutes:  "4:26", title: "New Year and End-of-Year in Japan!").save!
    Misa.new(short: "Rcct0oSnkic", japanese: false, minutes:  "0:43", title: "Japanese Vocabulary - #9 The 30 day DAJARE Challenge").save!
    Misa.new(short: "LxXSsngdHPs", japanese: false, minutes:  "1:07", title: "Japanese Vocabulary - #10 The 30 day DAJARE Challenge").save!
    Misa.new(short: "ePTdpMF-_H0", japanese: false, minutes: "16:43", title: "#7 Verbs basics and を particle - Japanese Lesson for Absolute Beginners").save!
    Misa.new(short: "Zv67JaEBtYA", japanese: false, minutes:  "1:26", title: "Japanese Vocabulary - #11 The 30 day DAJARE Challenge").save!
    Misa.new(short: "OuycVXVSrTc", japanese: false, minutes:  "0:57", title: "Japanese Vocabulary - #12 The 30 day DAJARE Challenge").save!
    Misa.new(short: "ojIdA-oioDA", japanese: false, minutes:  "1:44", title: "Japanese Vocabulary - #13 The 30 day DAJARE Challenge").save!
    Misa.new(short: "3gNpfoVSn2A", japanese: false, minutes:  "2:49", title: "Japanese Vocabulary - #14 The 30 day DAJARE Challenge").save!
    Misa.new(short: "11IX-v_3uJE", japanese: false, minutes:  "2:22", title: "Japanese Vocabulary - #15 The 30 day DAJARE Challenge").save!
    Misa.new(short: "BukPfz-d-jA", japanese: false, minutes:  "2:11", title: "Japanese Vocabulary - #16 The 30 day DAJARE Challenge").save!
    Misa.new(short: "GtJTtBdbI2I", japanese: false, minutes:  "1:16", title: "Japanese Vocabulary – #17 The 30 day DAJARE Challenge").save!
    Misa.new(short: "j2l3QjMfZ_g", japanese: false, minutes:  "2:38", title: "Japanese Vocabulary – #18 The 30 day DAJARE Challenge").save!
    Misa.new(short: "DLDSqmvWPvY", japanese: false, minutes:  "1:13", title: "Japanese Vocabulary – #19 The 30 day DAJARE Challenge").save!
    Misa.new(short: "89L2Ea-cuZQ", japanese: false, minutes:  "2:11", title: "Japanese Vocabulary – #20 The 30 day DAJARE Challenge").save!
    Misa.new(short: "jYbLQL9DKMI", japanese: false, minutes:  "2:51", title: "Japanese Vocabulary – #21 The 30 day DAJARE Challenge").save!
    Misa.new(short: "7yQVncLzIiQ", japanese: false, minutes:  "1:21", title: "Japanese Vocabulary – #22 The 30 day DAJARE Challenge").save!
    Misa.new(short: "tCZ3kkpyoW4", japanese: false, minutes:  "1:33", title: "Japanese Vocabulary – #23 The 30 day DAJARE Challenge").save!
    Misa.new(short: "mIK7NwgF6cI", japanese: false, minutes:  "2:34", title: "Japanese Vocabulary – #24 The 30 day DAJARE Challenge").save!
    Misa.new(short: "WI-mZnExFec", japanese: false, minutes:  "2:37", title: "Japanese Vocabulary – #25 The 30 day DAJARE Challenge").save!
    Misa.new(short: "vxHdj6MaRy0", japanese: false, minutes:  "1:54", title: "Japanese Vocabulary – #26 The 30 day DAJARE Challenge").save!
    Misa.new(short: "XZaxXe7KMBE", japanese: false, minutes:  "1:27", title: "Japanese Vocabulary – #27 The 30 day DAJARE Challenge").save!
    Misa.new(short: "INxB9Hrw09M", japanese: false, minutes:  "2:55", title: "Japanese Vocabulary – #28 The 30 day DAJARE Challenge").save!
    Misa.new(short: "d9ZY2Ad85hA", japanese: false, minutes:  "2:15", title: "Japanese Vocabulary – #29 The 30 day DAJARE Challenge").save!
    Misa.new(short: "283-P6UXPtg", japanese: false, minutes:  "3:04", title: "Japanese Vocabulary – #30 The 30 day DAJARE Challenge").save!
    Misa.new(short: "00kDTCOr1Do", japanese: false, minutes: "18:54", title: "#8 *Verb*ing is *adj.*- Japanese Lesson for Absolute Beginners").save!
    Misa.new(short: "nZXZElTzWjY", japanese: false, minutes: "12:18", title: "#9 Japanese Lesson for Absolute Beginners - Masu form").save!
    Misa.new(short: "iXHp_JjXgPk", japanese: true,  minutes:  "5:24", title: "My Birthday わたしの誕生日").save!
    Misa.new(short: "TgguUw-ixF4", japanese: false, minutes: "23:37", title: "#10 Particles  at / in / with に / で / と- Japanese Lesson for Absolute Beginners").save!
    Misa.new(short: "NC90Tf3fQo8", japanese: false, minutes: "15:37", title: "#11 negation of masu verbs ません - Japanese Lesson for Absolute Beginners").save!
    Misa.new(short: "L6UU-AYJuVI", japanese: false, minutes: "15:00", title: "#12 past tense and past negative of masu verbs - Japanese Lesson for Absolute Beginners").save!
    Misa.new(short: "sFiP5YW1m48", japanese: false, minutes: "43:29", title: "The Easiest Way To Learn Hiragana").save!
    Misa.new(short: "Xu9HIypscSM", japanese: false, minutes: "14:01", title: "Learn Kanji with Vocab for Beginners #1").save!
    Misa.new(short: "xljZH3cjkoA", japanese: false, minutes: "22:50", title: "Learn Kanji with Vocab for Beginners #2").save!
    Misa.new(short: "iNF7ntoPDCs", japanese: false, minutes: "21:33", title: "#13  Request (TE) form + Present Continuous (doING)-Japanese Lesson for  Beginners").save!
    Misa.new(short: "IqLKD3nVS60", japanese: false, minutes: "21:20", title: "#14 TE form う/つ/る ending - Japanese Lesson for Beginners").save!
    Misa.new(short: "f9IOmD9LbtA", japanese: false, minutes: "12:06", title: "#15 TE form く and ぐ ending - Japanese Lesson for Beginners").save!
    Misa.new(short: "WbWnQhQW0Fo", japanese: false, minutes: "13:09", title: "#16 TE form む/ぶ/ぬ ending - Japanese Lesson for Absolute Beginners").save!
    Misa.new(short: "lOx1cWP2x-o", japanese: false, minutes: "15:19", title: "#17 TE form す, する and くる ending - Japanese Lesson for Beginners").save!
    Misa.new(short: "FRd6XQWJrpE", japanese: false, minutes:  "5:01", title: "Jet lag, Sickness, Tokyo, Disney Sea and Thank you Vlog ♡ 時差ぼけ！").save!
    Misa.new(short: "e6uB1-iJSSo", japanese: false, minutes: "22:57", title: "Review Test : Masu and TE form (ます, ています) verb conjugation - Absolute Beginner 18").save!
    Misa.new(short: "QdPJTFYvj20", japanese: false, minutes: "18:56", title: "INFORMAL PAST TENSE - Japanese lesson Beginner 19").save!
    Misa.new(short: "77krgJkkywg", japanese: false, minutes: "19:30", title: "Have been / done たことがある - Japanese lesson Beginner 20").save!
    Misa.new(short: "CiJF9fs0ESE", japanese: false, minutes: "20:43", title: "Want to / たい - Japanese Beginner Lesson  #21").save!
    Misa.new(short: "fW9myvPDhto", japanese: false, minutes: "16:51", title: "DON'T Want to do - Japanese Beginner Lesson  #22").save!
    Misa.new(short: "ZT6upZrmmnA", japanese: false, minutes: "19:03", title: "The Easiest Way to Learn KATAKANA #1").save!
    Misa.new(short: "z6kDTtlTpwU", japanese: false, minutes: "17:34", title: "The Easiest Way to Learn KATAKANA #2").save!
    Misa.new(short: "tTTzWUnGH5M", japanese: false, minutes: "15:07", title: "The Easiest Way to Learn KATAKANA #3").save!
    Misa.new(short: "CYCDyeT9ZDc", japanese: false, minutes: "13:47", title: "KATAKANA SO vs N vs SHI vs TSU ソンシツ #4").save!
    Misa.new(short: "g2jDrGU2d-4", japanese: false, minutes: "22:10", title: "Write Your Countries and Names in KATAKANA").save!
    Misa.new(short: "Tf2q36mOCxw", japanese: false, minutes: "18:37", title: "How to say 'My Japanese is bad' / 上手 下手 vs 得意 苦手").save!
    Misa.new(short: "JFqM09OnpqM", japanese: true,  minutes:  "7:59", title: "PIKACHU SHOW in Japan!!").save!
    Misa.new(short: "nzWMEOla0iM", japanese: false, minutes: "15:50", title: "#23 May / Can I do ~? Can I use?").save!
    Misa.new(short: "pNYQQBwwmtY", japanese: false, minutes: "10:41", title: "How to say 'Im HUNGRY / PECKISH / STARVING / FULL' + SLANGS").save!
    Misa.new(short: "w6pYsJg10cs", japanese: true,  minutes:  "7:17", title: "Let's Read Manga in Japanese #Yotsubato").save!
    Misa.new(short: "dt1L2Ew1-bM", japanese: false, minutes: "24:20", title: "Learn Kanji with Vocab for Beginners #3").save!
    Misa.new(short: "Sjl-NMxYZW0", japanese: false, minutes: "27:46", title: "Learn Kanji with Vocab for Beginners #4 NUMBERS").save!
    Misa.new(short: "n9gvhXF4MMk", japanese: true,  minutes: "11:45", title: "Let's Read Manga in Japanese #Shirokuma Cafe").save!
    Misa.new(short: "TLabUxZby9E", japanese: false, minutes:  "3:53", title: "Japanese Ammo is on Patreon - Help Misa create more videos").save!
    Misa.new(short: "CR-r4IqLlQw", japanese: false, minutes: "23:19", title: "#24 INFORMAL NEGATION VERBS (ない do / will not)").save!
    Misa.new(short: "9d3EUwb8Loo", japanese: false, minutes: "17:43", title: "#25 Don't do ~ (ないでください").save!
    Misa.new(short: "wJflZhmsCaw", japanese: false, minutes: "22:54", title: "#26 Informal Past Negative form of Verbs").save!
    Misa.new(short: "WBVCNZEY_8s", japanese: false, minutes: "17:07", title: "あげる vs もらう vs くれる (DIFFERENCES) to give, to get / receive").save!
    Misa.new(short: "qSvnEuLc9kE", japanese: false, minutes: "13:25", title: "#27 Haven't done yet (てない)").save!
    Misa.new(short: "TXkhWLEKsHI", japanese: false, minutes:  "0:56", title: "あけおめ！ Happy New Year! 2017").save!
    Misa.new(short: "zFmFh1La_14", japanese: false, minutes: "32:20", title: "#28 たり form").save!
    Misa.new(short: "otETsmOVik0", japanese: false, minutes: "28:36", title: "#29 ちゃだめ - can't / must not").save!
    Misa.new(short: "4Elnque1I1Q", japanese: false, minutes: "24:25", title: "#30 connecting verbs (AND / TE form sequence)").save!
    Misa.new(short: "YKGyqYiI-Fs", japanese: false, minutes: "32:20", title: "#31 connecting adjectives (AND)").save!
    Misa.new(short: "gmNiWhWVjJ8", japanese: false, minutes: "46:32", title: "#32 Review Test of VERBS (masu, te, negation) ┃Japanese Grammar").save!
    Misa.new(short: "ZXf5kaRnHc0", japanese: false, minutes:  "8:52", title: "Happy Birthday / Happy Early and Belated Birthday + ages in Japanese").save!
    Misa.new(short: "GKgMe1fNVMc", japanese: false, minutes:  "4:54", title: "Valentine's Day in Japan (Men Don't Need to Do Anything!)").save!
    Misa.new(short: "zUzymwuP2oE", japanese: false, minutes: "32:18", title: "#33 HAVE TO なきゃ, なければ,いけない / ならない┃Grammar Lesson").save!
    Misa.new(short: "zaX9EX3G5Mw", japanese: false, minutes: "21:52", title: "#34 Go to do *purpose* / in order to ┃Japanese Grammar Lesson").save!
    Misa.new(short: "XKRWa2UPNxU", japanese: false, minutes: "23:21", title: "#35 LET'S in Japanese┃Japanese Grammar Lesson").save!
    Misa.new(short: "5Ll-4hiQUlU", japanese: false, minutes: "22:13", title: "#36 I think (~と思う) in Japanese ┃Japanese Lesson").save!
    Misa.new(short: "TdppYDLXP0E", japanese: false, minutes: "27:38", title: "#37 said in Japanese (と言った vs って言ってた)").save!
    Misa.new(short: "J_7gQAO-cxE", japanese: false, minutes: "16:53", title: "#38 INFORMAL 'said' / A called 'B' in Japanese (という)").save!
    Misa.new(short: "bX8zfeI7Vg4", japanese: false, minutes: "34:24", title: "11 Study Tips For Learning Japanese").save!
    Misa.new(short: "1e4jyTdR8ig", japanese: false, minutes: "26:33", title: "#39 ある and いる  + particles (There is / I have)").save!
    Misa.new(short: "y8isOzPtRjc", japanese: false, minutes: "33:40", title: "#40 Don't Have to ~（なくてもいい").save!
    Misa.new(short: "0CyJ01dYgxE", japanese: false, minutes: "37:44", title: "#41 CAN /potential form（られる/ことができる").save!
    Misa.new(short: "sS0065xVA8I", japanese: false, minutes: "50:13", title: "Learn Japanese through the Lyrics of Zen-zen-zense (Your Name song)").save!
    Misa.new(short: "jNlowhoi7iw", japanese: false, minutes: "23:45", title: "'To Learn / To Study' - 勉強する vs 学ぶ vs 習う the Differences").save!
    Misa.new(short: "xU2UoujQwU0", japanese: false, minutes:  "5:12", title: "#1 'Hello' / 'Hi' (inf. and form.)").save!
    Misa.new(short: "L6l_6Q7tFro", japanese: false, minutes:  "6:42", title: "#2 'Thank you' (inf. and form.)").save!
    Misa.new(short: "3mDenG7Aymw", japanese: false, minutes:  "6:38", title: "#3 How to say Sorry (Differences)").save!
    Misa.new(short: "HpuqEitMr5o", japanese: false, minutes:  "9:19", title: "#4 How to say / use WHERE (DOKO)").save!
    Misa.new(short: "r93lQF30wTA", japanese: true,  minutes:  "7:21", title: "The Pokémon Center (Tokyo) HAUL!").save!
    Misa.new(short: "0w-sliXX6rw", japanese: false, minutes: "12:02", title: "#5 How to say 'I see', 'I agree', 'That's right' (そう family)").save!
    Misa.new(short: "XhCBzgiIfRQ", japanese: false, minutes: "19:05", title: "How to INTRODUCE Yourself (Without Sounding Annoying) in Japanese").save!
    Misa.new(short: "s1m91QGqiOU", japanese: false, minutes: "22:33", title: "#42 A is MORE / BETTER than B (comparison)").save!
    Misa.new(short: "Xp9s1NyXjoM", japanese: false, minutes:  "2:26", title: "Twitter Manga (Yotsubaand! in Japanese) GIVEAWAY ^_^").save!
    Misa.new(short: "m9BPjQCS7Zw", japanese: false, minutes: "11:04", title: "#6 Stop saying 'Sayonara' - How to say 'Bye'").save!
    Misa.new(short: "UMLQVmALv0E", japanese: false, minutes: "10:17", title: "Learn Japanese through 'Your Name (Kimi no Na wa)' + unboxing").save!
    Misa.new(short: "jXNPNrnpVwA", japanese: false, minutes: "19:18", title: "#43 A is the best / most ~ +は vs が").save!
    Misa.new(short: "RH2YCn6E824", japanese: false, minutes:  "4:40", title: "Pikachu Outbreak 2017 Vlog (In Japanese w/ English + Japanese subs)").save!
    Misa.new(short: "frTm94LmvMI", japanese: false, minutes: "29:08", title: "RUDE Japanese Words You Use Without Knowing + What You Should Say Instead").save!
    Misa.new(short: "5zafsjXCmx4", japanese: false, minutes: "34:41", title: "How To / How Not To Speak Like ANIME characters in Japanese").save!
    Misa.new(short: "TJetxzGpbfA", japanese: false, minutes: "51:14", title: "BECAUSE (から vs ので, からです vs ですから) + WHY (どうして vs なんで vs なぜ) in Japanese").save!
    Misa.new(short: "FUb3WNbPtxk", japanese: false, minutes: "15:50", title: "Japanese Candy / Snacks 'Bokksu' October Unboxing + Useful Vocab").save!
    Misa.new(short: "QkTXzCvmCmM", japanese: false, minutes: "30:19", title: "Halloween Facts in JAPANESE / How to Explain Halloween").save!
    Misa.new(short: "lfdps6hqiow", japanese: false, minutes: "22:08", title: "How Stereotypically Japanese Am I?! SUSHI Everyday?! 日本人らしい？").save!
    Misa.new(short: "FknmUij6ZIk", japanese: false, minutes: "40:10", title: "The Ultimate Guide To: は vs が (The ONLY lesson you need!)").save!
    Misa.new(short: "_hV0wPuAGuU", japanese: false, minutes:  "6:32", title: "A Japanese Girl's Opinion on ANIME Dakimakura Pillow + Bedroom Vocab").save!
    Misa.new(short: "UGCg-9CTMMY", japanese: false, minutes: "20:01", title: "#45 てしまう / ちゃう How To Stop Sounding Like a Robot").save!
    Misa.new(short: "reo2_bpHEZQ", japanese: false, minutes: "14:17", title: "Kyoto Snacks (Bokksu DEC) Review (JP + JP / ENG subs) + Counters").save!
    Misa.new(short: "6FpckFf2SP0", japanese: false, minutes: "29:22", title: "#46 'doing ~ TOO (MUCH)' / It's TOO~to...(すぎる) in Jappanese").save!
    Misa.new(short: "wLzt2XqwCjI", japanese: false, minutes: "18:22", title: "To Wear / To Put On in Japanese (Differences 着る vs はく vs つける etc)").save!
    Misa.new(short: "gvzkBG9Vh_M", japanese: false, minutes: "24:53", title: "'Zenzen Daijoubu / Heiki' - Is it CORRECT? / How to say 'Not At All' in Japanese").save!
    Misa.new(short: "e05o4JWKbdg", japanese: false, minutes: "26:51", title: "Differences: WAKARU vs SHIRU / SHITTEIRU ('I know / I don't know / understand')").save!
    Misa.new(short: "F-THHO4iHWE", japanese: false, minutes: "39:50", title: "'IF' / 'WHEN' （と vs たら vs とき) Differences").save!
    Misa.new(short: "DFX0AaNhlEw", japanese: false, minutes: "46:50", title: "PART 2 たら 'IF' / 'WHEN'（と vs たら vs とき) Differences").save!
  end
end
