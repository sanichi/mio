class SeedPlaces < ActiveRecord::Migration[6.1]
  def up
    # Chuukoku
    r = Place.create!(jname: "中国地方", reading: "ちゅうごくちほう", ename: "Chuugoku", category: "region", wiki: "Chūgoku_region", pop: 76)
    p = Place.create!(jname: "広島県", reading: "ひろしまけん", ename: "Hiroshima Prefecture", category: "prefecture", wiki: "Hiroshima_Prefecture", pop: 28, region: r)
    c = Place.create!(jname: "広島市", reading: "ひろしまし", ename: "Hiroshima", category: "city", wiki: "Hiroshima", pop: 1.2, region: p)
    p = Place.create!(jname: "岡山県", reading: "おかやまけん", ename: "Okayama Prefecture", category: "prefecture", wiki: "Okayama_Prefecture", pop: 19, region: r)
    c = Place.create!(jname: "岡山市", reading: "おかやまし", ename: "Okayama", category: "city", wiki: "Okayama", pop: 7, region: p)
    p = Place.create!(jname: "山口県", reading: "やまぐちけん", ename: "Yamaguchi Prefecture", category: "prefecture", wiki: "Yamaguchi_Prefecture", pop: 14, region: r)
    c = Place.create!(jname: "山口市", reading: "やまぐちし", ename: "Yamaguchi", category: "city", wiki: "Yamaguchi", pop: 2, region: p)
    c = Place.create!(jname: "下関市", reading: "しものせきし", ename: "Shimonoseki", category: "city", wiki: "Shimonoseki", pop: 3, region: p)
    p = Place.create!(jname: "島根県", reading: "しまねけん", ename: "Shimane Prefecture", category: "prefecture", wiki: "Shimane_Prefecture", pop: 7, region: r)
    c = Place.create!(jname: "松江市", reading: "まつえし", ename: "Matsue", category: "city", wiki: "Matsue", pop: 2, region: p)
    p = Place.create!(jname: "鳥取県", reading: "とっとりけん", ename: "Tottori Prefecture", category: "prefecture", wiki: "Tottori_Prefecture", pop: 6, region: r)
    c = Place.create!(jname: "鳥取市", reading: "とっとりし", ename: "Tottori", category: "city", wiki: "Tottori_(city)", pop: 2, region: p)

    # Kyuushuu
    r = Place.create!(jname: "九州地方", reading: "きゅうしゅうちほう", ename: "Kyushu", category: "region", wiki: "Kyushu", pop: 143)
    p = Place.create!(jname: "福岡県", reading: "ふくおかけん", ename: "Fukuoka Prefecture", category: "prefecture", wiki: "Fukuoka_Prefecture", pop: 51, region: r)
    c = Place.create!(jname: "福岡市", reading: "ふくおかし", ename: "Fukuoka", category: "city", wiki: "Fukuoka", pop: 26, region: p)
    p = Place.create!(jname: "熊本県", reading: "くまもとけん", ename: "Kumamoto Prefecture", category: "prefecture", wiki: "Kumamoto_Prefecture", pop: 17, region: r)
    c = Place.create!(jname: "熊本市", reading: "くまもとし", ename: "Kumamoto", category: "city", wiki: "Kumamoto", pop: 7, region: p)
    p = Place.create!(jname: "鹿児島県", reading: "かごしまけん", ename: "Kagoshima Prefecture", category: "prefecture", wiki: "Kagoshima_Prefecture", pop: 16, region: r)
    c = Place.create!(jname: "鹿児島市", reading: "かごしまし", ename: "Kagoshima", category: "city", wiki: "Kagoshima", pop: 6, region: p)
    p = Place.create!(jname: "沖縄県", reading: "おきなわけん", ename: "Okinawa Prefecture", category: "prefecture", wiki: "Okinawa_Prefecture", pop: 15, region: r)
    c = Place.create!(jname: "那覇市", reading: "なはし", ename: "Naha", category: "city", wiki: "Naha", pop: 3, region: p)
    p = Place.create!(jname: "長崎県", reading: "ながさきけん", ename: "Nagasaki Prefecture", category: "prefecture", wiki: "Nagasaki_Prefecture", pop: 13, region: r)
    c = Place.create!(jname: "長崎市", reading: "なかさきし", ename: "Nagasaki", category: "city", wiki: "Nagasaki", pop: 4, region: p)
    p = Place.create!(jname: "大分県", reading: "おおいたけん", ename: "Ōita Prefecture", category: "prefecture", wiki: "Ōita_Prefecture", pop: 11, region: r)
    c = Place.create!(jname: "大分市", reading: "おおいたし", ename: "Ōita", category: "city", wiki: "Ōita_(city)", pop: 5, region: p)
    p = Place.create!(jname: "宮崎県", reading: "みやざきけん", ename: "Miyazaki Prefecture", category: "prefecture", wiki: "Miyazaki_Prefecture", pop: 1, region: r)
    c = Place.create!(jname: "宮崎市", reading: "みやざきし", ename: "Miyazaki", category: "city", wiki: "Miyazaki_(city)", pop: 4, region: p)
    p = Place.create!(jname: "佐賀県", reading: "さがけん", ename: "Saga Prefecture", category: "prefecture", wiki: "Saga_Prefecture", pop: 8, region: r)
    c = Place.create!(jname: "佐賀市", reading: "さがし", ename: "Saga", category: "city", wiki: "Saga_(city)", pop: 2, region: p)

    # Shikoku
    r = Place.create!(jname: "四国地方", reading: "しこくちほう", ename: "Shikoku", category: "region", wiki: "Shikoku", pop: 38)
    p = Place.create!(jname: "愛媛県", reading: "えひめけん", ename: "Ehime Prefecture", category: "prefecture", wiki: "Ehime_Prefecture", pop: 13, region: r)
    c = Place.create!(jname: "松山市", reading: "まつやまし", ename: "Matsuyama", category: "city", wiki: "Matsuyama", pop: 5, region: p)
    p = Place.create!(jname: "香川県", reading: "かがわけん", ename: "Kagawa Prefecture", category: "prefecture", wiki: "Kagawa_Prefecture", pop: 9, region: r)
    c = Place.create!(jname: "高松市", reading: "たかまつし", ename: "Takamatsu", category: "city", wiki: "Takamatsu,_Kagawa", pop: 4, region: p)
    p = Place.create!(jname: "高知県", reading: "こうちけん", ename: "Kochi Prefecture", category: "prefecture", wiki: "Kochi_Prefecture", pop: 8, region: r)
    c = Place.create!(jname: "高知市", reading: "こうちし", ename: "Kōchi", category: "city", wiki: "Kōchi_(city)", pop: 3, region: p)
    p = Place.create!(jname: "徳島県", reading: "とくしまけん", ename: "Tokushima Prefecture", category: "prefecture", wiki: "Tokushima_Prefecture", pop: 7, region: r)
    c = Place.create!(jname: "徳島市", reading: "とくしまし", ename: "Tokushima", category: "city", wiki: "Tokushima_(city)", pop: 3, region: p)
  end

  def down
    Place.delete_all
  end
end
