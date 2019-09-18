class String
  def shift_row(new_row)
    return self unless match(/\A#{Moji.hira}+\z/) && new_row.match(/\A[aiueo]\z/)
    old_roma = romaji
    old_row = old_roma[-1]
    return self unless old_row.match(/\A[aiueo]\z/) && new_row != old_row
    old_roma[-3,3] = "tu" if old_roma.match(/tsu\z/)
    old_roma[-3,3] = "ti" if old_roma.match(/chi\z/)
    old_roma[-2,2] = "hu" if old_roma.match(/fu\z/)
    new_roma = old_roma
    new_roma[-1] = new_row
    new_roma[-2,2] = "tsu" if old_roma.match(/tu\z/)
    new_roma[-2,2] = "chi" if old_roma.match(/ti\z/)
    new_roma[-2,2] = "fu"  if old_roma.match(/hu\z/)
    new_roma.hiragana
  end
  def is_row?(row)
    if match(/\A#{Moji.hira}+\z/) && row.match(/\A[aiueo]\z/)
      romaji[-1] == row
    else
      false
    end
  end
end
