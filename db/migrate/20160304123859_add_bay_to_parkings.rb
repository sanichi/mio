class AddBayToParkings < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :parkings do |t|
        dir.up do
          t.integer :bay, limit: 1
          id_num = Bay.all.each_with_object({}) { |b, m| m[b.id] = b.number }
          Parking.all.each { |p| p.update_column(:bay, id_num[p.bay_id]) }
        end

        dir.down do
          t.remove :bay
        end
      end
    end
  end
end
