class AddUrlsToMisa < ActiveRecord::Migration[6.0]
  def up
    add_column :misas, :url, :string, limit: Misa::MAX_URL
    add_column :misas, :alt, :string, limit: Misa::MAX_URL
    Misa.find_each do |m|
      if m.long.present? && m.short.present?
        m.update_column(:url, "https://youtu.be/#{m.long}")
        m.update_column(:alt, "https://www.youtube.com/watch?v=#{m.short}")
      elsif m.long.present?
        m.update_column(:url, "https://youtu.be/#{m.long}")
      elsif m.short.present?
        m.update_column(:url, "https://www.youtube.com/watch?v=#{m.short}")
      end
    end
  end

  def down
    remove_column :misas, :url
    remove_column :misas, :alt
  end
end
