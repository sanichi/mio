class AddBorderRecords < ActiveRecord::Migration[6.1]
  def up
    # Hiroshima Prefecture
    Border.create!(from_id: 2, to_id: 4, direction: 'east')
    Border.create!(from_id: 2, to_id: 11, direction: 'northeast')
    Border.create!(from_id: 2, to_id: 9, direction: 'north')
    Border.create!(from_id: 2, to_id: 6, direction: 'southwest')
    # Okayama Prefecture
    Border.create!(from_id: 4, to_id: 11, direction: 'north')
    Border.create!(from_id: 4, to_id: 66, direction: 'east')
    Border.create!(from_id: 4, to_id: 2, direction: 'west')
    # Yamaguchi Prefecture
    Border.create!(from_id: 6, to_id: 9, direction: 'north')
    Border.create!(from_id: 6, to_id: 2, direction: 'northeast')
    # Shimane Prefecture
    Border.create!(from_id: 9, to_id: 6, direction: 'southwest')
    Border.create!(from_id: 9, to_id: 2, direction: 'south')
    Border.create!(from_id: 9, to_id: 11, direction: 'east')
    # Tottori Prefecture
    Border.create!(from_id: 11, to_id: 9, direction: 'west')
    Border.create!(from_id: 11, to_id: 2, direction: 'southwest')
    Border.create!(from_id: 11, to_id: 4, direction: 'south')
    Border.create!(from_id: 11, to_id: 66, direction: 'east')
    # Fukuoka Prefecture
    Border.create!(from_id: 14, to_id: 28, direction: 'southwest')
    Border.create!(from_id: 14, to_id: 16, direction: 'south')
    Border.create!(from_id: 14, to_id: 24, direction: 'southeast')
    # Kumamoto Prefecture
    Border.create!(from_id: 16, to_id: 14, direction: 'north')
    Border.create!(from_id: 16, to_id: 24, direction: 'northeast')
    Border.create!(from_id: 16, to_id: 26, direction: 'southeast')
    Border.create!(from_id: 16, to_id: 18, direction: 'south')
    # Kagoshima Prefecture
    Border.create!(from_id: 18, to_id: 16, direction: 'north')
    Border.create!(from_id: 18, to_id: 26, direction: 'northeast')
    # Nagasaki Prefecture
    Border.create!(from_id: 22, to_id: 28, direction: 'northeast')
    # Ōita Prefecture
    Border.create!(from_id: 24, to_id: 14, direction: 'northwest')
    Border.create!(from_id: 24, to_id: 16, direction: 'southwest')
    Border.create!(from_id: 24, to_id: 26, direction: 'south')
    # Miyazaki Prefecture
    Border.create!(from_id: 26, to_id: 24, direction: 'north')
    Border.create!(from_id: 26, to_id: 16, direction: 'northwest')
    Border.create!(from_id: 26, to_id: 18, direction: 'southwest')
    # Saga Prefecture
    Border.create!(from_id: 28, to_id: 14, direction: 'northeast')
    Border.create!(from_id: 28, to_id: 22, direction: 'southwest')
    # Ehime Prefecture
    Border.create!(from_id: 31, to_id: 33, direction: 'northeast')
    Border.create!(from_id: 31, to_id: 37, direction: 'east')
    Border.create!(from_id: 31, to_id: 35, direction: 'southeast')
    # Kagawa Prefecture
    Border.create!(from_id: 33, to_id: 31, direction: 'southwest')
    Border.create!(from_id: 33, to_id: 37, direction: 'south')
    # Kōchi Prefecture
    Border.create!(from_id: 35, to_id: 31, direction: 'northwest')
    Border.create!(from_id: 35, to_id: 37, direction: 'northeast')
    # Tokushima Prefecture
    Border.create!(from_id: 37, to_id: 33, direction: 'north')
    Border.create!(from_id: 37, to_id: 31, direction: 'west')
    Border.create!(from_id: 37, to_id: 35, direction: 'southwest')
    # Akita Prefecture
    Border.create!(from_id: 44, to_id: 43, direction: 'north')
    Border.create!(from_id: 44, to_id: 45, direction: 'east')
    Border.create!(from_id: 44, to_id: 47, direction: 'southeast')
    Border.create!(from_id: 44, to_id: 46, direction: 'south')
    # Iwate Prefecture
    Border.create!(from_id: 45, to_id: 43, direction: 'north')
    Border.create!(from_id: 45, to_id: 44, direction: 'west')
    Border.create!(from_id: 45, to_id: 47, direction: 'south')
    # Yamagata Prefecture
    Border.create!(from_id: 46, to_id: 44, direction: 'north')
    Border.create!(from_id: 46, to_id: 47, direction: 'east')
    Border.create!(from_id: 46, to_id: 48, direction: 'south')
    Border.create!(from_id: 46, to_id: 89, direction: 'southwest')
    # Miyagi Prefecture
    Border.create!(from_id: 47, to_id: 45, direction: 'north')
    Border.create!(from_id: 47, to_id: 44, direction: 'northwest')
    Border.create!(from_id: 47, to_id: 46, direction: 'west')
    Border.create!(from_id: 47, to_id: 48, direction: 'south')
    # Fukushima Prefecture
    Border.create!(from_id: 48, to_id: 47, direction: 'northeast')
    Border.create!(from_id: 48, to_id: 46, direction: 'northwest')
    Border.create!(from_id: 48, to_id: 89, direction: 'west')
    Border.create!(from_id: 48, to_id: 93, direction: 'southwest')
    Border.create!(from_id: 48, to_id: 91, direction: 'south')
    Border.create!(from_id: 48, to_id: 95, direction: 'southeast')
    # Mie Prefecture
    Border.create!(from_id: 56, to_id: 76, direction: 'north')
    Border.create!(from_id: 56, to_id: 68, direction: 'northwest')
    Border.create!(from_id: 56, to_id: 62, direction: 'west')
    Border.create!(from_id: 56, to_id: 58, direction: 'southwest')
    Border.create!(from_id: 56, to_id: 60, direction: 'south')
    Border.create!(from_id: 56, to_id: 72, direction: 'northeast')
    # Nara Prefecture
    Border.create!(from_id: 58, to_id: 62, direction: 'north')
    Border.create!(from_id: 58, to_id: 64, direction: 'northwest')
    Border.create!(from_id: 58, to_id: 60, direction: 'southwest')
    Border.create!(from_id: 58, to_id: 56, direction: 'east')
    # Wakayama Prefecture
    Border.create!(from_id: 60, to_id: 64, direction: 'north')
    Border.create!(from_id: 60, to_id: 56, direction: 'east')
    Border.create!(from_id: 60, to_id: 58, direction: 'northeast')
    # Kyoto Prefecture
    Border.create!(from_id: 62, to_id: 74, direction: 'northeast')
    Border.create!(from_id: 62, to_id: 68, direction: 'east')
    Border.create!(from_id: 62, to_id: 56, direction: 'southeast')
    Border.create!(from_id: 62, to_id: 58, direction: 'south')
    Border.create!(from_id: 62, to_id: 64, direction: 'southwest')
    Border.create!(from_id: 62, to_id: 66, direction: 'west')
    # Osaka Prefecture
    Border.create!(from_id: 64, to_id: 66, direction: 'northwest')
    Border.create!(from_id: 64, to_id: 62, direction: 'north')
    Border.create!(from_id: 64, to_id: 58, direction: 'southeast')
    Border.create!(from_id: 64, to_id: 60, direction: 'south')
    # Hyōgo Prefecture
    Border.create!(from_id: 66, to_id: 62, direction: 'northeast')
    Border.create!(from_id: 66, to_id: 64, direction: 'southeast')
    Border.create!(from_id: 66, to_id: 4, direction: 'southwest')
    Border.create!(from_id: 66, to_id: 11, direction: 'northwest')
    # Shiga Prefecture
    Border.create!(from_id: 68, to_id: 74, direction: 'north')
    Border.create!(from_id: 68, to_id: 76, direction: 'northeast')
    Border.create!(from_id: 68, to_id: 56, direction: 'southeast')
    Border.create!(from_id: 68, to_id: 62, direction: 'west')
    # Aichi Prefecture
    Border.create!(from_id: 72, to_id: 56, direction: 'west')
    Border.create!(from_id: 72, to_id: 76, direction: 'northwest')
    Border.create!(from_id: 72, to_id: 87, direction: 'northeast')
    Border.create!(from_id: 72, to_id: 82, direction: 'east')
    # Fukui Prefecture
    Border.create!(from_id: 74, to_id: 85, direction: 'north')
    Border.create!(from_id: 74, to_id: 76, direction: 'east')
    Border.create!(from_id: 74, to_id: 68, direction: 'south')
    Border.create!(from_id: 74, to_id: 62, direction: 'southwest')
    # Gifu Prefecture
    Border.create!(from_id: 76, to_id: 78, direction: 'north')
    Border.create!(from_id: 76, to_id: 85, direction: 'northwest')
    Border.create!(from_id: 76, to_id: 74, direction: 'west')
    Border.create!(from_id: 76, to_id: 68, direction: 'southwest')
    Border.create!(from_id: 76, to_id: 56, direction: 'south')
    Border.create!(from_id: 76, to_id: 72, direction: 'southeast')
    Border.create!(from_id: 76, to_id: 87, direction: 'east')
    # Toyama Prefecture
    Border.create!(from_id: 78, to_id: 85, direction: 'west')
    Border.create!(from_id: 78, to_id: 76, direction: 'south')
    Border.create!(from_id: 78, to_id: 87, direction: 'east')
    Border.create!(from_id: 78, to_id: 89, direction: 'northeast')
    # Yamanashi Prefecture
    Border.create!(from_id: 80, to_id: 99, direction: 'northeast')
    Border.create!(from_id: 80, to_id: 87, direction: 'northwest')
    Border.create!(from_id: 80, to_id: 82, direction: 'southwest')
    Border.create!(from_id: 80, to_id: 101, direction: 'southeast')
    Border.create!(from_id: 80, to_id: 103, direction: 'east')
    # Shizuoka Prefecture
    Border.create!(from_id: 82, to_id: 101, direction: 'east')
    Border.create!(from_id: 82, to_id: 80, direction: 'northeast')
    Border.create!(from_id: 82, to_id: 87, direction: 'north')
    Border.create!(from_id: 82, to_id: 72, direction: 'west')
    # Ishikawa Prefecture
    Border.create!(from_id: 85, to_id: 78, direction: 'east')
    Border.create!(from_id: 85, to_id: 76, direction: 'southeast')
    Border.create!(from_id: 85, to_id: 74, direction: 'south')
    # Nagano Prefecture
    Border.create!(from_id: 87, to_id: 89, direction: 'north')
    Border.create!(from_id: 87, to_id: 93, direction: 'northeast')
    Border.create!(from_id: 87, to_id: 99, direction: 'east')
    Border.create!(from_id: 87, to_id: 80, direction: 'southeast')
    Border.create!(from_id: 87, to_id: 82, direction: 'south')
    Border.create!(from_id: 87, to_id: 72, direction: 'southwest')
    Border.create!(from_id: 87, to_id: 76, direction: 'west')
    Border.create!(from_id: 87, to_id: 78, direction: 'northwest')
    # Niigata Prefecture
    Border.create!(from_id: 89, to_id: 78, direction: 'southwest')
    Border.create!(from_id: 89, to_id: 87, direction: 'south')
    Border.create!(from_id: 89, to_id: 93, direction: 'southeast')
    Border.create!(from_id: 89, to_id: 48, direction: 'east')
    Border.create!(from_id: 89, to_id: 46, direction: 'northeast')
    # Tochigi Prefecture
    Border.create!(from_id: 91, to_id: 48, direction: 'north')
    Border.create!(from_id: 91, to_id: 93, direction: 'west')
    Border.create!(from_id: 91, to_id: 99, direction: 'south')
    Border.create!(from_id: 91, to_id: 95, direction: 'southeast')
    # Gunma Prefecture
    Border.create!(from_id: 93, to_id: 89, direction: 'northwest')
    Border.create!(from_id: 93, to_id: 48, direction: 'northeast')
    Border.create!(from_id: 93, to_id: 87, direction: 'southwest')
    Border.create!(from_id: 93, to_id: 99, direction: 'south')
    Border.create!(from_id: 93, to_id: 91, direction: 'east')
    # Ibaraki Prefecture
    Border.create!(from_id: 95, to_id: 48, direction: 'north')
    Border.create!(from_id: 95, to_id: 91, direction: 'northwest')
    Border.create!(from_id: 95, to_id: 99, direction: 'southwest')
    Border.create!(from_id: 95, to_id: 97, direction: 'south')
    # Chiba Prefecture
    Border.create!(from_id: 97, to_id: 95, direction: 'north')
    Border.create!(from_id: 97, to_id: 99, direction: 'northwest')
    Border.create!(from_id: 97, to_id: 103, direction: 'southwest')
    # Saitama Prefecture
    Border.create!(from_id: 99, to_id: 91, direction: 'north')
    Border.create!(from_id: 99, to_id: 93, direction: 'northwest')
    Border.create!(from_id: 99, to_id: 87, direction: 'west')
    Border.create!(from_id: 99, to_id: 80, direction: 'southwest')
    Border.create!(from_id: 99, to_id: 103, direction: 'south')
    Border.create!(from_id: 99, to_id: 97, direction: 'southeast')
    Border.create!(from_id: 99, to_id: 95, direction: 'northeast')
    # Kanagawa Prefecture
    Border.create!(from_id: 101, to_id: 103, direction: 'north')
    Border.create!(from_id: 101, to_id: 80, direction: 'northwest')
    Border.create!(from_id: 101, to_id: 82, direction: 'west')
    # Tokyo
    Border.create!(from_id: 103, to_id: 80, direction: 'west')
    Border.create!(from_id: 103, to_id: 97, direction: 'northeast')
    Border.create!(from_id: 103, to_id: 99, direction: 'north')
    Border.create!(from_id: 103, to_id: 101, direction: 'south')
  end

  def down
    Border.delete_all
  end
end
