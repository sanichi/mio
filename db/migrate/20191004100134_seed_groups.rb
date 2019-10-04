class SeedGroups < ActiveRecord::Migration[6.0]
  def up
    Wk::Group.create!(category: "synonyms", vocab_list: "増やす 増す")
    Wk::Group.create!(category: "sounds_like", vocab_list: "過程 家庭 仮定")
    Wk::Group.create!(category: "sounds_like", vocab_list: "優しい 易しい")
    Wk::Group.create!(category: "sounds_like", vocab_list: "反応 本能")
    Wk::Group.create!(category: "related_to", vocab_list: "失敗 大失敗 失態 大違い 間違い 大間違い 間違える")
    Wk::Group.create!(category: "antonyms", vocab_list: "人気 不人気")
    Wk::Group.create!(category: "synonyms", vocab_list: "自覚 意識")
    Wk::Group.create!(category: "antonyms", vocab_list: "意識 無意識")
    Wk::Group.create!(category: "synonyms", vocab_list: "地域 区域 地区")
    Wk::Group.create!(category: "synonyms", vocab_list: "妙 奇妙 変 異常 珍しい")
  end

  def down
    Wk::Group.destroy_all
  end
end
