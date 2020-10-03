class AddSeriesNumberToMisas < ActiveRecord::Migration[6.0]
  def up
    add_column :misas, :series, :string, limit: Misa::MAX_SERIES
    add_column :misas, :number, :integer, limit: 2

    last_id = Hash.new(0)

    Misa.where.not(category: ["none", "dogen"]).each do |m|
      if m.title =~ /^#([1-9]\d*)\s+/
        num = $1.to_i
        last_id[m.category] = num if num > last_id[m.category]
        m.update_columns(series: I18n.t("misa.categories.#{m.category}"), number: num)
      end
    end

    Misa.order(:created_at).where.not(category: ["none", "dogen"]).each do |m|
      if m.title !~ /^#([1-9]\d*)\s+/
        last_id[m.category] += 1
        m.update_columns(series: I18n.t("misa.categories.#{m.category}"), number: last_id[m.category])
      end
    end

    Misa.order(:created_at).where(category: "dogen").each do |m|
      last_id[m.category] += 1
      m.update_columns(series: I18n.t("misa.categories.#{m.category}"), number: last_id[m.category])
    end
  end

  def down
    remove_column :misas, :series, :string
    remove_column :misas, :number, :integer
  end
end
