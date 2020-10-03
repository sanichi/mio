class RemoveCategoryFromMisas < ActiveRecord::Migration[6.0]
  def up
    remove_column :misas, :category

    Misa.all.each do |m|
      if m.title =~ /^#[1-9]\d*\s+\S/
        m.update_column(:title, m.title.sub(/^#[1-9]\d*\s+/, ""))
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
