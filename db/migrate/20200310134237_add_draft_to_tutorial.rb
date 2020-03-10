class AddDraftToTutorial < ActiveRecord::Migration[6.0]
  def up
    add_column :tutorials, :draft, :boolean, default: true
    Tutorial.all.to_a.each { |t| t.update_column(:draft, false) }
  end

  def down
    remove_column :tutorials, :draft, :boolean
  end
end
