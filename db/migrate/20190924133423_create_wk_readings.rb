class CreateWkReadings < ActiveRecord::Migration[6.0]
  def up
    create_table :wk_readings do |t|
      t.integer  :accent_pattern, :accent_position, limit: 1
      t.string   :characters, limit: Wk::Reading::MAX_CHARACTERS
      t.boolean  :primary
      t.integer  :vocab_id
    end

    add_index :wk_readings, :vocab_id

    Wk::Vocab.all.to_a.each do |v|
      v.reading.split(", ").each_with_index do |r, i|
        if i == 0
          v.readings << Wk::Reading.create!(characters: r, primary: true, accent_pattern: v.accent_pattern, accent_position: v.accent_position)
        else
          v.readings << Wk::Reading.create!(characters: r, primary: false)
        end
      end
    end
  end

  def down
    drop_table :wk_readings
  end
end
