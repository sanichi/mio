module Wk
  class Tweak
    EXTRA_SIMILAR_KANJIS = {
      1059 => 1868, # 減, 滅
      1044 => 1045, # 胸, 脳
      1206 => 2263, # 優, 憂
    }

    def self.update
      EXTRA_SIMILAR_KANJIS.each do |id1, id2|
        if id1 != id2
          k1 = Wk::Kanji.find_by(wk_id: id1)
          k2 = Wk::Kanji.find_by(wk_id: id2)
          if k1 && k2
            k1.similar_kanjis.push(k2) unless k1.similar_kanjis.include?(k2)
            k2.similar_kanjis.push(k1) unless k2.similar_kanjis.include?(k1)
          end
        end
      end
    end
  end
end
