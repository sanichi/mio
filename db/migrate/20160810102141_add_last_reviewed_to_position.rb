class AddLastReviewedToPosition < ActiveRecord::Migration[5.0]
  def up
    add_column :positions, :last_reviewed, :date
    Position.all.each do |p|
      p.update_column(:last_reviewed, p.done ? p.created_at.to_date : nil)
    end
    remove_column :positions, :done
  end

  def down
    add_column :positions, :done, :boolean, default: false
    Position.all.each do |p|
      p.update_column(:done, p.last_reviewed.present?)
    end
    remove_column :positions, :last_reviewed
  end
end
