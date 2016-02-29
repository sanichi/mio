class AddTimeToParkings < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :parkings do |t|
        dir.up do
          t.datetime :noted_at
          Parking.all.each { |p| p.update_column(:noted_at, p.created_at) }
        end

        dir.down do
          t.remove :noted_at
        end
      end
    end
  end
end
